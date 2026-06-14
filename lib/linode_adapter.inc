[!]
-------------------------------------------------------------------------------
  lib/linode_adapter.inc  —  thin Linode (Akamai Cloud) API adapter
-------------------------------------------------------------------------------
  Outbound HTTPS is done with [shell] + curl. curl handles TLS, redirects, and
  returns just the response body (no HTTP headers to strip). This wraps it so
  callers never hand-write a request; the scoped PAT is added as a header.

  REQUIRES (from config/secrets.inc):  [LINODE_API_TOKEN]
  See CLAUDE.md › Linode API for the endpoints in scope.

  [linode_get path=/v4/regions]            -> JSON body + status marker (no auth)
  [linode_get path=/v4/account&authed=1]   -> JSON body + status marker (Bearer)

  The return value is the response body followed by a bracket-free marker:
      <json body>
      __CONSOLE_HTTP__200
  Split it in the caller with [middle] (marker chosen to be [middle]-param safe):
      [text]code=[middle startafter=__CONSOLE_HTTP__][resp][/middle][/text]
      [text]body=[middle endbefore=__CONSOLE_HTTP__][resp][/middle][/text]

  SECURITY NOTE: with curl -H the token is on curl's argv and is briefly visible
  to local `ps`. Acceptable on a single-tenant box with a SEPARATE dev token;
  before prod, move the header into a curl -K config file (mode 600) so the
  token never touches argv. The token is never echoed/logged here.
  path is always a constant we control (never user input) — no shell injection.
-------------------------------------------------------------------------------
[/!]

[!]-- GET a Linode API path. params: path (required), authed (1 to send token).
     Use 1/0, not T/F: WebDNA [if] treats a bare T/F as a boolean keyword, so
     [if [authed]=T] would never match the string "T" and auth would be dropped. --[/!]
[function name=linode_get]
  [if [authed]=1][then][text]_auth=-H "Authorization: Bearer [LINODE_API_TOKEN]"[/text][/then][else][text]_auth=[/text][/else][/if]
  [shell]curl -sS --max-time 20 -H "Accept: application/json" [_auth] -w "[unurl]%0A[/unurl]__CONSOLE_HTTP__%{http_code}" "https://api.linode.com[path]"[/shell]
[/function]

[!]-- Friendly city for a Linode region code (param: code). Extend as needed.
     Use [switch]/[case], NOT [if]: WebDNA [if] mis-parses a hyphen, so
     [if [code]=ap-southeast] never matches. [switch] compares cleanly. --[/!]
[function name=region_label]
  [switch value=[code]]
    [case value=ap-southeast]Sydney[/case]
    [case value=au-mel]Melbourne[/case]
    [case value=ap-south]Singapore[/case]
    [case value=ap-northeast]Tokyo[/case]
    [case value=eu-central]Frankfurt[/case]
    [case value=us-east]Newark[/case]
    [case value=us-west]Fremont[/case]
  [/switch] <span class="muted">[code]</span>
[/function]
