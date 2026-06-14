# `db/` — WebDNA databases

Live `.db` files hold real client/asset data and are **gitignored** (`db/*.db`).
Only the schema stubs `db/*.db.example` (header row only) are tracked.

## Setup on a fresh box
Copy each stub to its live name (this gives an empty, correctly-structured db):

```sh
cp db/clients.db.example db/clients.db
cp db/assets.db.example  db/assets.db
```

WebDNA appends records below the header row. **Keep the header line intact and
tab-delimited** — field order is the contract (see [../docs/schema.md](../docs/schema.md)).

## Rules
- Never commit live `db/*.db` (real client data — CLAUDE.md › Never).
- Case-sensitivity: reference `clients.db` / `assets.db` exactly. Ubuntu won't
  forgive a `Client.db` that the Mac silently accepts.
- Off-box backups can go to Linode Object Storage (S3-compatible).
