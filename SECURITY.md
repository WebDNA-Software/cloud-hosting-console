# Security Policy

This project is a **starter template** for a WebDNA-based hosting console. Each
deployment is privileged: it holds a **Linode (Akamai Cloud) API token** that
controls real, billable infrastructure. Treat any instance accordingly.

## Reporting a vulnerability

**Please do not open public issues for security problems.**

Report privately instead:

- **GitHub** — use [Security advisories → *Report a vulnerability*](https://github.com/WebDNA-Software/cloud-hosting-console/security/advisories/new)
  (private vulnerability reporting), or
- **Email** — stuart@plsoftware.com.au

Please include:

- a description of the issue and its impact,
- steps to reproduce (or a proof of concept),
- affected file(s) / template(s) and any relevant configuration.

We aim to acknowledge a report within **5 business days** and to agree a
disclosure timeline once the issue is confirmed. Please give us reasonable time
to release a fix before any public disclosure. We're happy to credit reporters
who ask to be named.

## Supported versions

This is a template that evolves on `main` rather than a versioned product.
Security fixes land on `main`; pull the latest and re-apply to your deployment.
There is no support for older snapshots or forks you have customised.

## Scope

In scope:

- vulnerabilities in this repository's templates, includes, adapters, and
  deploy tooling (e.g. injection, auth/access-control flaws, secret exposure,
  unsafe handling of the Linode API token or client data).

Out of scope:

- vulnerabilities in **your own deployment's** configuration, hosting, or
  customisations (see *Operator responsibilities* below);
- third-party software the template runs on (WebDNA, Apache, mod_webdna,
  Bootstrap, Linode's API) — report those to their respective maintainers;
- the Linode API itself, or actions taken with a valid token.

## Operator responsibilities

This template ships safe-by-default protections, but **you must verify them on
every box you deploy.** See the README's *Security first* section for the full
checklist. In short:

- **Never commit secrets or live data.** `config/secrets.inc` and `db/*.db` are
  gitignored; only the tracked `*.example` stubs belong in git. After your first
  commit, confirm `git ls-files | grep -E 'secrets\.inc$|db/.*\.db$'` returns
  nothing.
- **Keep server-side files out of the served path.** The bundled `.htaccess`
  files (`config/`, `db/`, `lib/`, and the root catch-all) deny direct HTTP
  access to `.inc` / `.db` / `.dat` and similar. Verify a request for
  `config/secrets.inc` returns **403**, never the file contents.
- **Lock down the console.** Serve it over **HTTPS**, behind **authentication**,
  with **IP restriction**. Behind a reverse proxy, read the client IP from
  `X-Forwarded-For`, not the connecting address.
- **Scope your token, and separate dev from prod.** Use a scoped Linode personal
  access token. The API has **no sandbox** — every call creates real, billable
  resources — so never test against a production token or account.
- **Rotate on exposure.** If a token is ever committed, logged, or otherwise
  leaked, revoke and reissue it immediately; removing it from git history is not
  enough.
