[!]
-------------------------------------------------------------------------------
  lib/integration_adapter.inc  —  thin HTTP adapter to an (optional) sidecar
-------------------------------------------------------------------------------
  PURPOSE
    A single choke point for every call that would eventually leave WebDNA for
    an external integration (e.g. payments or accounting). Keeping the WebDNA
    side HTTP-shaped now means a later sidecar is a config change, not a rewrite.

  STATUS: STUB. No integration is implemented. Every call short-circuits to a
    uniform "disabled" response so callers can be written and tested today.

  CONTRACT (documented in docs/integration-boundary.md — keep them in sync):
    Request  : integration_adapter(service, action, payload_json)
    Transport: HTTP POST [INTEGRATION_BASE_URL]/v1/[service]/[action]
               header  X-Console-Secret: [INTEGRATION_SHARED_SECRET]
               body    application/json  ([payload_json])
    Response : JSON envelope  { "ok": bool, "data": {...}, "error": "..." }

  This file defines the contract surface only. The actual HTTP send is left
  unimplemented until a sidecar exists; calling it today returns ok=false with
  error="integration_disabled".

  USAGE
    [include file=config/secrets.inc]      [!]-- provides INTEGRATION_* --[/!]
    [include file=lib/integration_adapter.inc]
    [text]res=[integration_adapter service=example action=ping payload_json={...}][/text]
    [!]-- then parse [res] as the JSON envelope above --[/!]
-------------------------------------------------------------------------------
[/!]

[function name=integration_adapter]
  [!]-- params: [service] [action] [payload_json] --[/!]
  [!]----------------------------------------------------------------------
    STUB. Uniform disabled envelope. To go live, replace the body below with the
    HTTP POST to:
        [INTEGRATION_BASE_URL]/v1/[service]/[action]
    sending header  X-Console-Secret: [INTEGRATION_SHARED_SECRET]
    and body [payload_json], then return the raw JSON response verbatim.
    Keep the signature and the envelope shape identical — callers must not
    change when this flips from stub to live.
  ----------------------------------------------------------------------[/!]
  {"ok":false,"data":{},"error":"integration_disabled","service":"[service]","action":"[action]"}
[/function]
