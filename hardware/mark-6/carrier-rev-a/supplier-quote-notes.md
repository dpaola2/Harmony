# Carrier quote preparation, September 26

The [quote request](supplier-request-draft.md) and supplier ZIP were sent to PCBWay through AgentMail on September 26. No price, lead time or order is confirmed. The supplier response is pending.

The 33-file ZIP passed CRC and all 32 manifest hash checks. Its SHA256 is `e8294f7d03469f21e3c4bf66140f071b38da8a98badd338901bbf9099a8ac114`. AgentMail returned thread `e327fcca-4cd2-48d5-9ca7-24af9e06b54f`. The [send receipt](supplier-quote-send-receipt.json) records the message ID. The ZIP preserves the request as prepared before sending.

Fresh ERC and saved-rule DRC pass. Fresh strict DRC reports only the documented U1 warning and no opens. All eleven regenerated Gerber plots match the previous geometry after timestamp removal. The supplier package passed scans for local paths and private mailbox links, including extracted schematic PDF text.

PCBWay is the proposed first supplier. Its published capabilities include turnkey sourcing, SMT and through-hole assembly, and epoxy-filled, copper-capped vias. Its assembly page states a five-piece minimum. The request therefore asks for one, two and five assembled carriers, with minimum bare-board and assembly quantities separated.

The selected process fits the carrier's mixed assembly and via-in-pad requirements. The supplier must confirm this particular design, exact MPN availability and total cost. Its advertised assembly starting price is not an estimate for this board.

## Physical evidence and limits

Dave reports that the revision B shells close evenly. The LCD sits flat, all four retainers align, and the carrier gauge rests on its mounting posts. Dave accepted the wheel coupon with 14 mm spacers and a 33 mm opening. These observations do not verify a populated carrier.

The screws and 0.5 mm foam are ordered. Final fastener fit, display retention, complete rotary stack and cable routing remain open. The delivered LCD ribbon has contacts on the same face. The socket photo suggests bottom contacts, but pin mapping remains unverified. The real Feather sockets cannot be tested with the printed gauge.

Quote preparation can proceed while those checks remain open. Production release needs supplier DFM acceptance and an explicit decision about any physical checks deferred until carrier arrival. That decision has not been made.

## Package checks

`package_supplier_quote.py` builds a separate supplier package from an allowlist. It regenerates Gerbers, drills and ERC/DRC reports from the current CAD. It checks source hashes against the saved electrical and assembly audits before packaging. The supplier package omits internal purchase records, mailbox links and the outdated mechanical review PDF. It supplies current mechanical context in its README.

The September 22 strict audit documents one U1 component-type warning caused by its two plated thermal holes. U1 remains an SMT component. A fresh strict audit accompanies this quote package. Hash checks bind the saved pad and placement audits to the unchanged CAD; they do not establish supplier approval or electrical performance.

## Supplier sources

Checked September 26, 2026:

- [Assembly capabilities](https://www.pcbway.com/assembly-capabilities.html): turnkey sourcing, mixed assembly and stated five-piece minimum.
- [Via covering](https://www.pcbway.com/pcb_prototype/PCB_Via_Covering.html): Type VII filled and copper-capped construction.
- [Contact](https://www.pcbway.com/contact.html): service@pcbway.com.

The supplier's current notice lists factory closures on September 25 and October 1–4 (GMT+8). The request asks for the effect on this quote's schedule.

## Cross-references

- Harmony Mark-6: Bluetooth bench player (HARMONY-17).
- [Assembly review](assembly-readiness.md).
- [Revision B assembly plan](../../../enclosure/mark-6/fit-rev-b/README.md).
- [Power review](power-review.md).
