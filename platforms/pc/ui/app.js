const $ = s => document.querySelector(s);
let state, pending = Promise.resolve(), signature = '', drag = null;
const time = n => `${Math.floor(n / 60)}:${String(Math.floor(n % 60)).padStart(2, '0')}`;
function element(tag, cls, text) { const e = document.createElement(tag); if(cls)e.className=cls; if(text!==undefined)e.textContent=text; return e; }
function bar(cls, percent) { const outer=element('div',cls),inner=element('div'); inner.style.width=`${Math.max(0,Math.min(100,percent))}%`;outer.append(inner);return outer; }
function render(s) {
 state=s; $('#title').textContent=s.title; $('#title').title=s.title; $('#subtitle').textContent=s.subtitle;
 $('#receiver').textContent=s.receiver || 'Not connected'; $('#transport').textContent=s.playing?'▶':'Ⅱ'; $('#volume').textContent=`VOL ${s.volume}`;
 $('#notice').textContent=s.notice || ''; $('#position').textContent=s.kind==='playing'?`${s.queue_position} / ${s.queue_count}`:s.rows.length?`${s.selected+1} / ${s.rows.length}`:'0 / 0';
 $('#footer-left').textContent=s.kind==='playing'?'TURN WHEEL FOR VOLUME':'MENU: BACK · CENTER: SELECT';
 const sig=JSON.stringify([s.kind,s.title,s.rows,s.selected,s.track,s.playing]);
 if(sig!==signature) {
  signature=sig; const content=$('#content'); content.replaceChildren();
  if(s.kind==='playing' && s.track) {
   const wrap=element('div','now'),record=element('div','record'); record.append(element('div','record-label',s.playing?'PLAY':'PAUSE'));wrap.append(record);
   wrap.append(element('h3','song-title',s.track.title),element('p','song-meta',s.track.artist),element('p','song-meta',s.track.album));
   wrap.append(bar('timeline',0));const times=element('div','times');times.append(element('span','elapsed','0:00'),element('span','duration',time(s.track.duration)));wrap.append(times);
   const vol=element('div','volume-control');vol.append(element('span','','VOL'),bar('volume-track',s.volume),element('span','volume-number',s.volume));wrap.append(vol);content.append(wrap);
  } else if(s.kind==='playing') {content.append(element('p','empty','Nothing playing yet. Choose a song from Music.'));}
  else {for(const [i,row] of s.rows.entries()) {const button=element('button',`row${i===s.selected?' selected':''}`);button.setAttribute('aria-label',row.label+(row.detail?`, ${row.detail}`:''));button.setAttribute('aria-current',i===s.selected?'true':'false');button.title=row.label;const txt=element('span','row-text');txt.append(element('span','row-label',row.label));if(row.detail)txt.append(element('span','row-detail',row.detail));button.append(txt,element('span','row-arrow',row.playing?'♪':row.chevron?'›':''));button.onclick=()=>act('row',i);content.append(button);}const selected=content.querySelector('.selected');if(selected) {if(selected.offsetTop<content.scrollTop)content.scrollTop=selected.offsetTop;selected.scrollIntoView({block:'nearest'});}}
 }
 if(s.kind==='playing'&&s.track){$('.timeline>div').style.width=`${Math.min(100,s.elapsed/Math.max(1,s.track.duration)*100)}%`;$('.elapsed').textContent=time(s.elapsed);$('.volume-track>div').style.width=`${s.volume}%`;$('.volume-number').textContent=s.volume;}
 $('#error').hidden=true;
}
async function request(path,opts) {const r=await fetch(path,opts);if(!r.ok)throw Error(`Prototype request failed (${r.status})`);render(await r.json());}
function error(e){$('#error').hidden=false;$('#error').textContent=`${e.message}. Restart the local prototype server if it has stopped.`;}
function act(name,value){pending=pending.then(()=>request('/api/action',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({name,value})})).catch(error);return pending;}
document.querySelectorAll('[data-action]').forEach(b=>b.onclick=()=>act(b.dataset.action));
window.addEventListener('keydown',e=>{if(e.altKey||e.metaKey||e.ctrlKey)return;const map={ArrowUp:['rotate',-1],ArrowDown:['rotate',1],ArrowLeft:['previous'],ArrowRight:['next'],Enter:['select'],Escape:['back'],Backspace:['back'],' ':['play_pause']};if(map[e.key]){e.preventDefault();act(...map[e.key]);}});
let wheelSum=0;
$('#device').addEventListener('wheel',e=>{e.preventDefault();wheelSum+=e.deltaY;if(Math.abs(wheelSum)>=24){act('rotate',Math.sign(wheelSum));wheelSum=0;}},{passive:false});
function angle(e){const r=$('#wheel').getBoundingClientRect();return Math.atan2(e.clientY-r.top-r.height/2,e.clientX-r.left-r.width/2);}
$('#wheel').addEventListener('pointerdown',e=>{if(e.target.closest('button'))return;drag={id:e.pointerId,angle:angle(e),sum:0};$('#wheel').setPointerCapture(e.pointerId);});
$('#wheel').addEventListener('pointermove',e=>{if(!drag||drag.id!==e.pointerId)return;const a=angle(e);let d=a-drag.angle; if(d>Math.PI)d-=Math.PI*2;if(d<-Math.PI)d+=Math.PI*2;drag.angle=a;drag.sum+=d;const steps=Math.trunc(drag.sum/.23);if(steps){act('rotate',steps);drag.sum-=steps*.23;}});
for(const event of ['pointerup','pointercancel'])$('#wheel').addEventListener(event,()=>drag=null);
setInterval(()=>{pending=pending.then(()=>request('/api/state')).catch(error);},1000);
request('/api/state').catch(error);
