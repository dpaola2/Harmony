"""Simulate the Q4 (AO3401A) peripheral-rail switch and its gate network (review findings PWR-1, ESP32-2, FW-HW-1).

Run with uv:  uv run --with numpy --with scipy --with matplotlib python q4_gate_sim.py
Writes review/q4-gate-sim.json and review/q4-gate-sim.png. Changes nothing else.

Circuit (design.py, block 'screen'):
  R13  3V3 -> PERIPH_DIV            R14  PERIPH_EN_N (GPIO13) -> PERIPH_DIV
  R34  PERIPH_DIV -> PERIPH_GATE    C18  PERIPH_GATE -> 3V3 (gate to source)
  C26  PERIPH_GATE -> 3V3_PERIPH (gate to drain, the Miller capacitor that sets the ramp)
  Q4   AO3401A, source 3V3, drain 3V3_PERIPH, gate PERIPH_GATE
R13 and R14 form a divider. With GPIO13 driven low the divider puts about 1 V on the gate, so Q4 is fully on.
With GPIO13 floating at its internal pull-down (after reset release, before firmware) the divider holds the
gate within a few hundred mV of the source, so Q4 stays off. R34 and C26 set the drain ramp: once the gate
reaches the Miller plateau, the gate current through R34 flows through C26, so dV/dt = I_gate / C26.

Models (all values from the datasheets in the folder or the review datasheets):
  AO3401A: EKV-style square law with a subthreshold tail (n 1.5, 90 mV per decade). VGS(th) is the datasheet
    value at ID = 250 uA (min 0.5, typ 0.9, max 1.3 V); K from RDS(on) (60 mOhm typ at -2.5 V gives about 5 A/V2;
    the review used 5 to 18 A/V2). Ciss 645 pF, Crss 55 pF.
  RT9080: ideal 3.3 V source, 0.055 ohm output resistance (1 % load regulation over 600 mA), current limit
    610 mA (datasheet minimum, the worst case). Output capacitance at the pin C11, effective value after DC bias.
  3V3 to U1: 0.22 ohm of track (review PWR-7) to C5 (22 uF 0603, about 9 uF effective at 3.3 V) and the
    ESP32 load (250 mA, Bluetooth transmit).
  3V3_PERIPH load: C19 + C21 (10 uF 0603 each, about 5.5 uF effective at 3.3 V) + C20 + C22 + the screen and
    card input capacitance: 10 to 30 uF in all, plus a resistive load of 0 to 100 mA at 3.3 V.
  GPIO13: output low through 30 ohm; after reset release an internal pull-down of 30 to 80 kOhm (45 k typ, no
    min or max in the ESP32 datasheet); during reset no pull (high impedance).
"""
import json
import math
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp

HERE = Path(__file__).resolve().parent

# --- chosen network ------------------------------------------------------------------------------
NET = dict(R13=2.2e3, R14=1.0e3, R34=4.7e3, C18=1.0e-6, C26=100e-9)

# --- device and board models --------------------------------------------------------------------
VREG, R_LDO, I_LIM = 3.3, 0.055, 0.61
C_LDO = 5.0e-6            # C11 10 uF 0603 at U4 (about 5 uF effective at 3.3 V) plus the small 3V3 caps
R_U1, C_U1, I_ESP = 0.22, 9e-6, 0.25
CISS, CRSS = 645e-12, 55e-12
NUT = 1.5 * 0.02585       # n * kT/q
R_GPIO = 30.0


def vt0(vth_spec, k):
    """Model threshold that gives 250 uA at |VGS| = vth_spec in saturation (datasheet definition)."""
    u = math.log(math.exp(math.sqrt(250e-6 / k) / (2 * NUT)) - 1)
    return vth_spec - u * 2 * NUT


def f_ekv(v):
    x = v / (2 * NUT)
    return (2 * NUT * np.logaddexp(0, x)) ** 2


def i_fet(vsg, vsd, vt, k):
    """Source-to-drain channel current of the PMOS (positive when it feeds the drain)."""
    return k * (f_ekv(vsg - vt) - f_ekv(vsg - vt - vsd))


def run(case, net=NET, vth=0.9, k=5.0, cl=20e-6, il=0.05, t_end=40e-3, rpd=45e3, t_ramp=0.2e-3):
    """case: 'on' (GPIO13 high -> low at t = 0), 'off' (low -> high), 'reset' (no pull -> pull-down),
    'powerup' (3V3 ramps from 0 in t_ramp with GPIO13 floating, as while ESP_EN is held low)."""
    R13, R14, R34, C18, C26 = (net[x] for x in ('R13', 'R14', 'R34', 'C18', 'C26'))
    vt = vt0(vth, k)
    rl = VREG / il if il > 0 else 1e9
    cgs, cgd = CISS - CRSS + C18, CRSS + C26
    # state y = [vs (Q4 source, 3V3 at U4), vg, vd, v1 (3V3 at U1)]
    # mass matrix for the capacitive currents: node equations M dy/dt = currents
    M = np.array([[C_LDO + cgs, -cgs, 0, 0],
                  [-cgs, cgs + cgd, -cgd, 0],
                  [0, -cgd, cl + cgd, 0],
                  [0, 0, 0, C_U1]])
    Mi = np.linalg.inv(M)

    def gpio(t):
        """(voltage, series resistance) seen by R14 at time t, or None for high impedance."""
        if case == 'on':
            return (0.0, R_GPIO) if t >= 0 else (VREG, R_GPIO)
        if case == 'off':
            return (VREG, R_GPIO) if t >= 0 else (0.0, R_GPIO)
        if case == 'reset':
            return (0.0, rpd) if t >= 0 else None
        if case == 'powerup':
            return None
        raise ValueError(case)

    def vset(t):
        if case == 'powerup':
            return VREG * min(1.0, max(0.0, t / t_ramp))
        return VREG

    def vx_of(t, vs, vg):
        g = gpio(t)
        num, den = vs / R13 + vg / R34, 1 / R13 + 1 / R34
        if g is not None:
            num += g[0] / (R14 + g[1]); den += 1 / (R14 + g[1])
        return num / den

    def rhs(t, y):
        vs, vg, vd, v1 = y
        i_ldo = min(max((vset(t) - vs) / R_LDO, 0.0), I_LIM)
        vx = vx_of(t, vs, vg)
        idr = i_fet(vs - vg, vs - vd, vt, k)
        i_body = max(0.0, (vd - vs - 0.55) / 0.1)            # body diode, drain above source
        i_u1 = (vs - v1) / R_U1
        esp = I_ESP if case != 'powerup' else I_ESP * min(1.0, v1 / VREG)
        cur = np.array([i_ldo - idr + i_body - i_u1,
                        (vx - vg) / R34,
                        idr - i_body - vd / rl,
                        i_u1 - esp])
        return Mi @ cur

    if case == 'on':
        y0 = [VREG - (I_ESP) * R_LDO, VREG - I_ESP * R_LDO, 0.0, VREG - I_ESP * (R_LDO + R_U1)]
    elif case == 'off':
        vs0 = VREG - (I_ESP + il) * R_LDO
        vx0 = (vs0 / R13) / (1 / R13 + 1 / (R14 + R_GPIO))
        y0 = [vs0, vx0, vs0 - 0.01, vs0 - I_ESP * R_U1]
    elif case == 'reset':
        y0 = [VREG - I_ESP * R_LDO, VREG - I_ESP * R_LDO, 0.0, VREG - I_ESP * (R_LDO + R_U1)]
    else:
        y0 = [0.0, 0.0, 0.0, 0.0]
    ts = np.linspace(0, t_end, 4001)
    sol = solve_ivp(rhs, (0, t_end), y0, method='Radau', t_eval=ts, max_step=20e-6, rtol=1e-6, atol=1e-9)
    vs, vg, vd, v1 = sol.y
    idr = i_fet(vs - vg, vs - vd, vt, k)
    return dict(t=sol.t, vs=vs, vg=vg, vd=vd, v1=v1, id=idr)


def t_at(t, v, level, rising=True):
    idx = np.where(v >= level)[0] if rising else np.where(v <= level)[0]
    return float(t[idx[0]]) if len(idx) else None


def summarize_on(r):
    t, vd = r['t'], r['vd']
    t10, t90 = t_at(t, vd, 0.33), t_at(t, vd, 2.97)
    return dict(t10_ms=round(t10 * 1e3, 3) if t10 else None, t90_ms=round(t90 * 1e3, 3) if t90 else None,
                rise_10_90_ms=round((t90 - t10) * 1e3, 3) if t10 and t90 else None,
                inrush_peak_mA=round(float(r['id'].max()) * 1e3, 1),
                v3v3_at_U4_min=round(float(r['vs'].min()), 3), v3v3_at_U1_min=round(float(r['v1'].min()), 3),
                vsg_final=round(float(r['vs'][-1] - r['vg'][-1]), 3))


def main():
    out = dict(network=dict(R13='2.2k (3V3 to PERIPH_DIV)', R14='1k (GPIO13 to PERIPH_DIV)',
                            R34='4.7k (PERIPH_DIV to PERIPH_GATE)', C18='1 uF (gate to source)',
                            C26='100 nF (gate to drain)'),
               assumptions=dict(ldo_current_limit_A=I_LIM, esp32_load_A=I_ESP, c11_effective_uF=C_LDO * 1e6,
                                c5_effective_uF=C_U1 * 1e6, track_U4_to_U1_ohm=R_U1, gpio_low_ohm=R_GPIO))
    # 1. Reset release: the internal pull-down alone must keep Q4 off.
    reset = []
    for rpd in (30e3, 45e3, 80e3):
        vg = VREG * (NET['R14'] + rpd) / (NET['R13'] + NET['R14'] + rpd)
        vsg = VREG - vg
        row = dict(pulldown_kohm=rpd / 1e3, vsg_V=round(vsg, 3))
        for vth in (0.5, 0.9, 1.3):
            for k in (5.0, 18.0):
                leak = float(i_fet(vsg, VREG, vt0(vth, k), k))
                row['leak_uA_vth%.1f_k%d' % (vth, k)] = round(leak * 1e6, 4)
        # hot part: |VGS(th)| falls about 2.5 mV/K; 0.5 V minimum at 25 C becomes about 0.4 V at 65 C
        row['leak_uA_vth0.4_hot_k18'] = round(float(i_fet(vsg, VREG, vt0(0.4, 18.0), 18.0)) * 1e6, 3)
        reset.append(row)
    # the transient into the reset state (no pull -> pull-down) for the strongest pull-down and lowest Vth
    r = run('reset', vth=0.5, k=18.0, cl=10e-6, il=0.0, rpd=30e3, t_end=60e-3)
    out['reset_release'] = dict(table=reset, transient_vth0p5_k18_30k=dict(
        max_vsg_V=round(float((r['vs'] - r['vg']).max()), 3), max_drain_V=round(float(r['vd'].max()), 4),
        max_drain_current_uA=round(float(r['id'].max()) * 1e6, 3)))
    # 2. Turn-on: ramp time, inrush and the 3V3 minimum across the corners.
    on = []
    worst = None
    for vth in (0.5, 0.9, 1.3):
        for k in (5.0, 18.0):
            for cl in (10e-6, 20e-6, 30e-6):
                for il in (0.0, 0.1):
                    rr = run('on', vth=vth, k=k, cl=cl, il=il)
                    s = summarize_on(rr)
                    s.update(vth=vth, k=k, cload_uF=cl * 1e6, periph_load_mA=il * 1e3)
                    on.append(s)
                    if worst is None or s['v3v3_at_U1_min'] < worst['v3v3_at_U1_min']:
                        worst = s
    out['turn_on'] = dict(cases=on, worst_3v3_at_U1=worst,
                          t90_ms_range=[min(c['t90_ms'] for c in on), max(c['t90_ms'] for c in on)],
                          rise_10_90_ms_range=[min(c['rise_10_90_ms'] for c in on), max(c['rise_10_90_ms'] for c in on)],
                          inrush_peak_mA_max=max(c['inrush_peak_mA'] for c in on),
                          v3v3_at_U1_min=min(c['v3v3_at_U1_min'] for c in on),
                          v3v3_at_U4_min=min(c['v3v3_at_U4_min'] for c in on))
    # 3. Power-up with GPIO13 floating (ESP_EN low): Q4 must not switch the rail on.
    pu = []
    for tr in (0.05e-3, 0.3e-3, 1e-3):
        for vth in (0.5, 0.9):
            rr = run('powerup', vth=vth, k=18.0, cl=10e-6, il=0.0, t_end=30e-3, t_ramp=tr)
            pu.append(dict(ramp_ms=tr * 1e3, vth=vth, max_vsg_V=round(float((rr['vs'] - rr['vg']).max()), 3),
                           max_drain_V=round(float(rr['vd'].max()), 4)))
    out['power_up_gpio_floating'] = pu
    # 4. Turn-off (GPIO13 high): time until Q4 stops conducting (drain current below 1 mA above the load).
    off = []
    for vth in (0.5, 1.3):
        rr = run('off', vth=vth, k=5.0, cl=20e-6, il=0.02, t_end=40e-3)
        t_off = t_at(rr['t'], -(rr['vs'] - rr['vg']), -vth, rising=True)
        off.append(dict(vth=vth, t_vsg_below_vth_ms=round(t_off * 1e3, 2) if t_off else None))
    out['turn_off'] = off
    ok_reset = all(row['vsg_V'] < 0.25 for row in reset) and out['reset_release']['transient_vth0p5_k18_30k']['max_drain_V'] < 0.1
    ok_dip = out['turn_on']['v3v3_at_U1_min'] >= 3.0
    ok_pu = all(x['max_drain_V'] < 0.3 for x in pu)
    out['result'] = dict(q4_off_after_reset=ok_reset, no_3v3_dip_below_3V=ok_dip, q4_off_at_power_up=ok_pu,
                         firmware_SLAB_PERIPH_RAMP_MS_min=math.ceil(out['turn_on']['t90_ms_range'][1] * 1.5))
    (HERE / 'review').mkdir(exist_ok=True)
    (HERE / 'review/q4-gate-sim.json').write_text(json.dumps(out, indent=1) + '\n')
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(2, 1, figsize=(8, 7), sharex=True)
        for vth, ls in ((0.5, '-'), (0.9, '--'), (1.3, ':')):
            rr = run('on', vth=vth, k=18.0, cl=30e-6, il=0.1)
            ax[0].plot(rr['t'] * 1e3, rr['vd'], 'b' + ls, label='3V3_PERIPH, Vth %.1f' % vth)
            ax[0].plot(rr['t'] * 1e3, rr['v1'], 'r' + ls, label='3V3 at U1, Vth %.1f' % vth)
            ax[1].plot(rr['t'] * 1e3, rr['id'] * 1e3, 'k' + ls, label='Q4 current, Vth %.1f' % vth)
        ax[0].axhline(3.0, color='gray', lw=0.5)
        ax[0].set_ylabel('V'); ax[0].legend(fontsize=7); ax[0].grid(lw=0.3)
        ax[1].set_ylabel('mA'); ax[1].set_xlabel('ms after GPIO13 goes low'); ax[1].legend(fontsize=7); ax[1].grid(lw=0.3)
        fig.suptitle('Q4 turn-on, K 18 A/V2, 30 uF + 100 mA load, RT9080 limit 610 mA, ESP32 250 mA')
        fig.savefig(HERE / 'review/q4-gate-sim.png', dpi=110)
    except ImportError:
        pass
    print(json.dumps({k_: out[k_] for k_ in ('reset_release', 'power_up_gpio_floating', 'turn_off', 'result')}, indent=1))
    print(json.dumps({k_: v_ for k_, v_ in out['turn_on'].items() if k_ != 'cases'}, indent=1))


if __name__ == '__main__':
    main()
