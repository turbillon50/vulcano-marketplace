/* extract-tokens.js — correr via javascript_tool en Claude in Chrome.
   Devuelve JSON con tokens visuales REALES + tiempos. Cero invento. */
(() => {
  const rgb = s => (s.match(/\d+(\.\d+)?/g) || []).map(Number);
  const lum = ([r,g,b]) => { const f=c=>{c/=255;return c<=.03928?c/12.92:((c+.055)/1.055)**2.4}; return .2126*f(r)+.7152*f(g)+.0722*f(b); };
  const ratio = (a,b) => { const L1=lum(rgb(a)),L2=lum(rgb(b)); const hi=Math.max(L1,L2),lo=Math.min(L1,L2); return +((hi+.05)/(lo+.05)).toFixed(2); };
  const els = [...document.querySelectorAll('body *')].slice(0,4000);
  const tally = {};
  const bump = (o,k)=>{o[k]=(o[k]||0)+1};
  const colors={}, bgs={}, fonts={}, radii={}, shadows={}, gaps={};
  let textPairs=[];
  for (const el of els){
    const cs=getComputedStyle(el);
    if (el.textContent && el.textContent.trim().length>1){ bump(colors, cs.color); }
    if (cs.backgroundColor && cs.backgroundColor!=='rgba(0, 0, 0, 0)') bump(bgs, cs.backgroundColor);
    bump(fonts, cs.fontFamily.split(',')[0].replace(/["']/g,''));
    if (cs.borderRadius && cs.borderRadius!=='0px') bump(radii, cs.borderRadius);
    if (cs.boxShadow && cs.boxShadow!=='none') bump(shadows, cs.boxShadow.slice(0,40));
    if (cs.gap && cs.gap!=='normal') bump(gaps, cs.gap);
  }
  const top = (o,n=6)=>Object.entries(o).sort((a,b)=>b[1]-a[1]).slice(0,n).map(([k,v])=>({v:k,n:v}));
  // contraste de pares texto/fondo clave
  const key = ['h1','h2','p','a','button'].map(sel=>{const e=document.querySelector(sel); if(!e)return null; const cs=getComputedStyle(e);
    let bg=cs.backgroundColor, p=e; while((bg==='rgba(0, 0, 0, 0)'||!bg)&&p.parentElement){p=p.parentElement;bg=getComputedStyle(p).backgroundColor;}
    const r=ratio(cs.color, bg||'rgb(255,255,255)'); const fs=parseFloat(cs.fontSize);
    const large=fs>=24||(fs>=18.66&&+cs.fontWeight>=700);
    return {sel, size:cs.fontSize, weight:cs.fontWeight, ratio:r, AA:(large?r>=3:r>=4.5), AAA:r>=7};}).filter(Boolean);
  const t=performance.timing||{}; const nav=performance.getEntriesByType('navigation')[0]||{};
  const res=performance.getEntriesByType('resource');
  const kb=res.reduce((s,r)=>s+(r.transferSize||0),0)/1024;
  const cont=[...document.querySelectorAll('main,section,header,div')].map(e=>e.getBoundingClientRect().width).filter(w=>w>320&&w<1600).sort((a,b)=>b-a)[0];
  return JSON.stringify({
    url: location.href,
    colores_texto: top(colors), fondos: top(bgs), fuentes: top(fonts,4),
    radios: top(radii,4), sombras: top(shadows,3), gaps: top(gaps,4),
    max_width_contenido: cont? Math.round(cont)+'px':'?',
    contraste: key,
    tiempos: { TTFB: Math.round(nav.responseStart||0), DOMContentLoaded: Math.round(nav.domContentLoadedEventEnd||0), load: Math.round(nav.loadEventEnd||0) },
    peso_KB: Math.round(kb), requests: res.length,
    imagenes: res.filter(r=>r.initiatorType==='img').length, fuentes_cargadas: res.filter(r=>/\.(woff2?|ttf|otf)/.test(r.name)).length
  }, null, 2);
})();
