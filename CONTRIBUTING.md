# Contributing

Thanks for your interest in improving the Cloud Hosting Console.

## How to propose a change
1. **Fork** this repository and create a branch for your change.
2. Make your edits. Keep them focused — one logical change per pull request.
3. **Never commit secrets or live data** — `config/secrets.inc` and `db/*.db`
   stay local (see the README's *Security first* section).
4. Open a **pull request** against `main` with a clear description of what and why.

## What to expect
The maintainer will review the diff, test it, and either merge it, ask for
changes, or explain why it's out of scope. Direct pushes to `main` are disabled;
all changes go through pull requests.

## Reporting security issues
Please do **not** open a public issue — see [SECURITY.md](SECURITY.md).
