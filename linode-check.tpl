[!]
  linode-check.tpl — prove Linode connectivity from WebDNA.
    1) GET /v4/regions   (unauthenticated)
    2) GET /v4/account   (Bearer token from config/secrets.inc — never hardcoded)
  Diagnostic page. Read-only GETs. Proof = HTTP status (split off the response)
  + a head slice of the JSON body. /account body is never displayed (billing PII).
  NOTE: deep field extraction from live JSON uses [JSONstore2] (see the resource
  screens) — [middle] is unreliable on curl-returned JSON (it re-parses the [ ]
  brackets in arrays). Status + body-slice is enough to prove the path.
[/!]
[include file=config/secrets.inc]
[include file=lib/linode_adapter.inc]

[!]-- is a real token configured? 1 = yes, 0 = no.
     Use digit sentinels, NOT T/F: WebDNA [if] reads a bare T/F as a boolean
     keyword, so [if [flag]=T] never matches a string "T". Compare with = only. --[/!]
[text]tok_set=1[/text]
[if [LINODE_API_TOKEN]=PUT-SCOPED-DEV-PAT-HERE][then][text]tok_set=0[/text][/then][/if]

[!]-- 1) /regions (unauth). Split status off the marker; slice a JSON head. --[/!]
[text]r1=[linode_get path=/v4/regions][/text]
[text]r1_code=[getchars start=1&end=3][middle startafter=__CONSOLE_HTTP__][r1][/middle][/getchars][/text]
[text]r1_head=[getchars start=1&end=90][r1][/getchars][/text]

[!]-- 2) /account (authed) — only if a token is configured --[/!]
[if [tok_set]=1][then]
  [text]r2=[linode_get path=/v4/account&authed=1][/text]
  [text]r2_code=[getchars start=1&end=3][middle startafter=__CONSOLE_HTTP__][r2][/middle][/getchars][/text]
[/then][/if]

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Console — Linode connectivity check</title>
  <style>
    body { font: 15px/1.5 system-ui, sans-serif; max-width: 52rem; margin: 3rem auto; padding: 0 1rem; }
    h1 { margin-bottom: 0; } .sub { color:#888; margin-top:.25rem; }
    .card { border:1px solid #8884; border-radius:8px; padding:1rem 1.25rem; margin:1.25rem 0; }
    .ok { color:#2a8; font-weight:600; } .bad { color:#d44; font-weight:600; }
    code { background:#8882; padding:.1rem .3rem; border-radius:3px; }
    pre { background:#8881; padding:.75rem; border-radius:6px; overflow:auto; max-height:14rem; }
  </style>
</head>
<body>
  <h1>Linode connectivity</h1>
  <p class="sub">token read from <code>config/secrets.inc</code></p>

  <div class="card">
    <h2>1 · <code>GET /v4/regions</code> <span class="sub">(unauthenticated)</span></h2>
    <p>HTTP status: <span class="[if [r1_code]=200][then]ok[/then][else]bad[/else][/if]">[r1_code]</span>
       [if [r1_code]=200][then]<span class="ok">✓ reached &amp; returned JSON</span>[/then][else]<span class="bad">✗</span>[/else][/if]</p>
    <p>Response head:</p>
    <pre>[r1_head]</pre>
  </div>

  <div class="card">
    <h2>2 · <code>GET /v4/account</code> <span class="sub">(Bearer auth)</span></h2>
    [if [tok_set]=1][then]
      <p>HTTP status: <span class="[if [r2_code]=200][then]ok[/then][else]bad[/else][/if]">[r2_code]</span>
         [if [r2_code]=200][then]<span class="ok">✓ authenticated</span>[/then][else]<span class="bad">✗ check token scope/value</span>[/else][/if]</p>
      <p class="sub">Account body is intentionally not displayed (contains billing PII).</p>
    [/then][else]
      <p class="bad">No token configured.</p>
      <p class="sub">On the box, copy <code>config/secrets.inc.example</code> to
        <code>config/secrets.inc</code> and set <code>LINODE_API_TOKEN</code> to a
        scoped dev PAT, then reload this page.</p>
    [/else][/if]
  </div>
</body>
</html>
