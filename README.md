# Cloud Console

A WebDNA-based console for managing **Linode (Akamai Cloud)** resources —
Linodes, Cloud Firewalls, DNS, Object Storage, Backups, Linux Images,
NodeBalancers and Block Storage — backed by a provider-agnostic **client /
asset** store.

Built with WebDNA + Bootstrap 5. Server-rendered, one template per page. Intended
as a starting point: use it as-is, build your own on top, or enhance this one.

> **This console is privileged — it holds a Linode API token that controls
> billable infrastructure.** Read [Security first](#security-first) before you
> serve it or commit anything.

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

## Security first
This is a starter template. **Two protections are your responsibility before the
first commit and the first request** — get them in place up front, not as a later
hardening pass.

### 1. Never commit secrets or live data
Create a `.gitignore` at the repo root **before `git add`** so your real token and
client data can't be committed by accident:

```gitignore
# secrets — per box, never committed
config/secrets.inc

# live data — real client/asset records
db/*.db

# logs and local tooling
*.log
```

Only the tracked `*.example` stubs should ever reach git. After your first commit,
double-check: `git ls-files | grep -E 'secrets\.inc$|db/.*\.db$'` must return
**nothing**.

### 2. Keep secrets and data out of the served path
`config/secrets.inc` lives inside the web root, so Apache must be told never to
serve it (or `db/`, or the includes). Add a deny-all `.htaccess` to each
sensitive directory:

```apache
# config/.htaccess, db/.htaccess, lib/.htaccess
Require all denied
```

Verify it works — this **must** return `403`, never the file's contents:

```sh
curl -s -o /dev/null -w '%{http_code}\n' https://your-console/config/secrets.inc
```

### 3. Lock down the console itself
Serve it over **HTTPS**, behind **authentication**, and restrict access by IP.
Behind a reverse proxy, read the client IP from **`X-Forwarded-For`**, not the
connecting address.


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
