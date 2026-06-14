# CLAUDE.md — Console

Standing reference for working on this codebase. WebDNA 8.6.5 gotchas (the
`[if]`/`[switch]` traps, JSONstore2 `table=` model, db-write rules, comment
syntax, etc.) live in `docs/webdna-notes.md` — read it before writing WebDNA.

## What this is
A WebDNA console to manage **Linode (Akamai Cloud)** resources, backed by a
provider-agnostic client / asset system of record. Linodes, domains, firewalls
and buckets are all *assets* of different `type`.

## Stack
- **UI + system of record:** WebDNA (templates + `.db` files).
- **Linode API:** called from WebDNA via `[shell]` + curl. REST/JSON, scoped
  personal access token (see `lib/linode_adapter.inc`).
- **Data model (provider-agnostic):** `client`, and `asset` = { `type`,
  `provider`, `cost`, `renewal`, `status`, `client_id` }. A new provider or
  resource type is a new adapter + `type`, never a schema reshape. See
  `docs/schema.md`.
- **Optional integrations:** keep any call that would leave WebDNA HTTP-shaped
  behind a thin adapter (`lib/integration_adapter.inc`) so a later sidecar slots
  in without a rewrite. See `docs/integration-boundary.md`.

## Layout
- `*.html` / `*.tpl` — pages (WebDNA-processed).
- `lib/*.inc` — shared shell + adapters (HTTP-denied via `.htaccess`).
- `assets/` — static css / images / favicons.
- `db/` — `.db` stores (live data gitignored; `*.db.example` stubs tracked).
- `config/secrets.inc` — per-box secrets (gitignored).

## Setup
1. `cp config/secrets.inc.example config/secrets.inc` and set `LINODE_API_TOKEN`
   to a scoped token.
2. `cp db/clients.db.example db/clients.db` and `cp db/assets.db.example
   db/assets.db` (make them writable by the web server user).
3. Serve the directory with Apache + mod_webdna. `.html` must be WebDNA-processed.

## Workflow
Edit → deploy (`bin/deploy.sh`, dry-run by default; `--apply` to push) → test in
a browser → read the WebDNA log. A case-sensitive Linux server catches bugs a
case-insensitive Mac hides.

## Conventions
- **Case-sensitivity:** `[include]`, file, and `.db` names must match exactly.
- **Secrets:** in `config/secrets.inc` per box, gitignored. Never in templates,
  never committed. Scope the Linode token to only what the console uses.
- **Client IP:** behind a reverse proxy, read `X-Forwarded-For`, not the
  connecting IP (for any IP lockdown / webhook).
- **Privileged console:** it holds API tokens — HTTPS + auth + IP restriction
  from the start.

## Linode API
- **No sandbox** — calls create real, billable infrastructure. Use a separate
  dev token, nano instances only for tests, tag test resources, and clean them up.
- Endpoints used here: `/regions`, `/account`, `/linode/instances`,
  `/networking/firewalls`, `/domains` + `/domains/{id}/records`,
  `/object-storage/buckets`, `/linode/instances/{id}/backups`, `/images`,
  `/nodebalancers`, `/volumes`.

## Never
- Edit a production box by hand.
- Commit secrets or live `.db` data.
- Provision larger than nano for tests.
