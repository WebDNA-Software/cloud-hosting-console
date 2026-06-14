# Integration boundary (WebDNA ↔ optional sidecar)

**Status: STUB / contract only.** No integrations are implemented. This document
defines the seam so an external integration (e.g. payments or accounting) can be
added later behind a small sidecar without reworking the WebDNA side.

See the implementing stub: [lib/integration_adapter.inc](../lib/integration_adapter.inc).

## Why a boundary at all
WebDNA is the UI and system of record. Some integrations are messy, stateful, and
better handled in a dedicated service. Rather than scatter those calls through
templates later, every call that will leave WebDNA goes through **one adapter
function**, returning a uniform envelope. When a sidecar exists, only the
adapter's body changes.

## The contract

**Call (WebDNA side):**
```
[integration_adapter service=<service> action=<action> payload_json=<json>]
```

**Transport (what the adapter will do once live):**
```
POST  [INTEGRATION_BASE_URL]/v1/<service>/<action>
Header: X-Console-Secret: [INTEGRATION_SHARED_SECRET]
Body  : application/json   <payload_json>
```

`INTEGRATION_BASE_URL` and `INTEGRATION_SHARED_SECRET` come from the per-box
`config/secrets.inc` (see `config/secrets.inc.example`). A sidecar is typically
co-located (e.g. `http://127.0.0.1:8000`) and never exposed publicly.

**Response envelope (always this shape, stub or live):**
```json
{ "ok": true, "data": { ... }, "error": null }
```
On failure: `{ "ok": false, "data": {}, "error": "<machine-readable-code>" }`.

Today every call returns `{"ok":false,"data":{},"error":"integration_disabled"}`
so callers can be written and exercised before a sidecar exists.

## Rules
- The adapter signature and the envelope shape are frozen — the flip from stub to
  live must not change any caller.
- Any inbound webhook path is separate; like the console itself it must read the
  client IP from `X-Forwarded-For` when behind a reverse proxy.
