const SITE_KEY = '0x4AAAAAAExk8XNcJX4N-XR-';
export default {
  async fetch(request) {
    const url = new URL(request.url);
    if (request.method !== 'GET' || url.pathname !== '/') return new Response('Not found', {status:404});
    const state = url.searchParams.get('state') || '';
    if (state && !/^[a-f0-9]{64}$/.test(state)) return new Response('Invalid state', {status:400});
    const nonce = crypto.randomUUID().replaceAll('-', '');
    const html = `<!doctype html><html lang="it"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Verifica di sicurezza · Vibra Staging</title><style nonce="${nonce}">body{font:17px system-ui;background:#13151b;color:#f5f5fa;display:grid;place-items:center;min-height:95vh;margin:0}main{max-width:360px;padding:28px}h1{font-size:26px}p{line-height:1.5;color:#c8cad4}a{color:#c3b3ff}textarea{width:100%;height:80px}#result{display:none}</style><script nonce="${nonce}">window.ready=function(){turnstile.render('#challenge',{sitekey:'${SITE_KEY}',action:'vibra_auth',callback:function(token){document.getElementById('status').textContent='Verifica completata.';const state=${JSON.stringify(state)};if(state){const link=document.getElementById('return');link.href='com.vibra.app://captcha?state='+encodeURIComponent(state)+'&token='+encodeURIComponent(token);link.hidden=false;window.location.href=link.href;}else{document.getElementById('result').style.display='block';document.getElementById('token').value=token;}},'expired-callback':function(){document.getElementById('status').textContent='Verifica scaduta. Riprova.';document.getElementById('return').hidden=true;document.getElementById('token').value='';turnstile.reset();},'error-callback':function(){document.getElementById('status').textContent='Verifica non riuscita. Ricarica la pagina e riprova.';}})};</script><script nonce="${nonce}" src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=ready&render=explicit" async defer></script></head><body><main><h1>Verifica di sicurezza</h1><p id="status">Un breve controllo per proteggere il tuo account Vibra.</p><div id="challenge"></div><p><a id="return" hidden>Torna a Vibra</a></p><div id="result"><label for="token">Token di verifica temporaneo per il collaudo</label><textarea id="token" readonly></textarea></div><p>Ambiente di test · <a href="https://www.cloudflare.com/privacypolicy/" rel="noreferrer">Privacy Cloudflare</a></p></main></body></html>`;
    return new Response(html, {headers:{
      'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store',
      'Referrer-Policy':'no-referrer','X-Content-Type-Options':'nosniff',
      'Permissions-Policy':'camera=(), microphone=(), geolocation=()',
      'Content-Security-Policy':`default-src 'none'; script-src 'nonce-${nonce}' https://challenges.cloudflare.com; style-src 'nonce-${nonce}'; frame-src https://challenges.cloudflare.com; connect-src https://challenges.cloudflare.com; img-src data:; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`
    }});
  }
};
