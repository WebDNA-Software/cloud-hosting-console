# Cloud Console

A WebDNA-based console for managing **Linode (Akamai Cloud)** resources —
Linodes, Cloud Firewalls, DNS, Object Storage, Backups, Linux Images,
NodeBalancers and Block Storage — backed by a provider-agnostic **client /
asset** store.

Built with WebDNA + Bootstrap 5. Server-rendered, one template per page. Intended
as a starting point: use it as-is, build your own on top, or enhance this one.

## Screens
- **Dashboard** — live counts + recent Linodes
- **Linodes** — instances with plan, public IP, status, backups
- **Firewalls** — rules and default policies
- **DNS Manager** — zones + records
- **Object Storage** — S3-compatible buckets
- **Backups** — per-instance backup status
- **Linux Images** — distributions + custom disk images
- **NodeBalancers / Block Storage** — activate with extra token scopes
- **Clients** — CRUD over the local client store

## Requirements
- **WebDNA 8.6.5** on **Apache + mod_webdna** (`.html` must be WebDNA-processed)
- `[shell]` enabled with `curl` available (outbound API calls use curl)
- A **Linode API token** (scoped personal access token)

## Setup
```sh
# 1. secrets (gitignored)
cp config/secrets.inc.example config/secrets.inc
#    edit config/secrets.inc — set LINODE_API_TOKEN to a scoped token

# 2. data stores (live data gitignored; .example stubs are tracked)
cp db/clients.db.example db/clients.db
cp db/assets.db.example  db/assets.db
#    make db/ and the .db files writable by the web server user (e.g. www-data)

# 3. serve the directory with Apache + mod_webdna, then open it in a browser
```

`bin/deploy.sh` can rsync the tree to a remote server (dry-run by default;
override `DEPLOY_HOST` / `DEPLOY_USER` / `DEPLOY_KEY` / `DEPLOY_PATH`).

## Token scopes
The core screens need: Linodes, Firewalls, Domains, Object Storage, Backups,
Images. The **NodeBalancers** and **Block Storage** screens activate once you add
the **NodeBalancers** and **Volumes** scopes to your token.

## Documentation
- WebDNA implementation gotchas — [`docs/webdna-notes.md`](docs/webdna-notes.md)
- Data model — [`docs/schema.md`](docs/schema.md)
- Integration seam — [`docs/integration-boundary.md`](docs/integration-boundary.md)

## Notes
- Bootstrap / icons / fonts load from a CDN — vendor them locally for offline or
  production use.
- The console is privileged (it holds an API token): serve it over HTTPS, behind
  authentication and IP restriction.

## License
Apache 2.0 — see [LICENSE](LICENSE).
