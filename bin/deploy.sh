#!/usr/bin/env bash
#
# deploy.sh — push the Console working tree to your WebDNA server.
#
#   dev (source of truth)  →  server web root
#   then test in a browser and read the WebDNA log.
#
# SAFETY: dry-run by DEFAULT. It shows exactly what WOULD change and transfers
# nothing. Pass --apply to actually deploy. Secrets and live .db data are never
# transferred (the server keeps its own per-box config/secrets.inc and live db).
#
# Usage:
#   bin/deploy.sh                 # dry-run (default) — preview changes
#   bin/deploy.sh --apply         # really deploy
#   bin/deploy.sh --apply --delete  # also remove remote files not in the tree
#   bin/deploy.sh --clean         # PREVIEW removing dev-only files stranded on
#                                 #   the server (CLAUDE.md, docs/, bin/, …)
#   bin/deploy.sh --apply --clean # deploy AND remove those stale files
#
# --clean only ever removes a fixed allowlist of dev-only paths. It can NEVER
# touch config/secrets.inc or db/*.db — those are not on the list, by design.
#
# Override any of these via env, e.g.  DEPLOY_HOST=10.0.0.5 bin/deploy.sh
#   DEPLOY_HOST  (default: your-webdna-host)
#   DEPLOY_USER  (default: deploy)
#   DEPLOY_KEY   (default: ~/.ssh/id_rsa)
#   DEPLOY_PATH  (default: /var/www/html/console)
#
set -euo pipefail

DEPLOY_HOST="${DEPLOY_HOST:-your-webdna-host}"
DEPLOY_USER="${DEPLOY_USER:-deploy}"
DEPLOY_KEY="${DEPLOY_KEY:-$HOME/.ssh/id_rsa}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/html/console}"

# Repo root = parent of this script's dir, regardless of where it's invoked.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APPLY=0
DELETE=0
CLEAN=0
for arg in "$@"; do
  case "$arg" in
    --apply)  APPLY=1 ;;
    --delete) DELETE=1 ;;
    --clean)  CLEAN=1 ;;
    -h|--help) sed -n '2,34p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# Dev-only artifacts that may end up on the server (e.g. from earlier SFTP
# uploads) but should NOT be served. --clean removes exactly these, nothing
# else. NOTE: secrets and live data are deliberately absent — never list
# config/secrets.inc or db/*.db here.
CLEAN_TARGETS=( CLAUDE.md README.md LICENSE docs bin .git .gitignore .vscode .DS_Store )

# Things we must NEVER push: secrets, live data, logs, dev-only tooling, VCS noise.
# (config/secrets.inc is per-box; db/*.db is live data — both stay on the server.)
EXCLUDES=(
  --exclude '.git/'
  --exclude '.gitignore'
  --exclude '.vscode/'
  --exclude '.DS_Store'
  --exclude 'config/secrets.inc'
  --exclude 'db/*.db'
  --exclude '*.log'
  --exclude 'ErrorLog.txt'
  --exclude 'bin/'
  --exclude 'docs/'
  --exclude 'README.md'
  --exclude 'LICENSE'
  --exclude 'CLAUDE.md'
)

# The remote web root is owned by www-data; the deploy user can write files into it
# (group member) but cannot chmod/chown/utime the dirs it doesn't own. So we
# transfer CONTENT only and let the box manage metadata: the setgid web root
# fixes group ownership, umask sets sane file modes. Without these, rsync's -a
# tries to set perms/times on the www-data-owned root and exits non-zero on an
# otherwise-clean push.
RSYNC_FLAGS=(--recursive --links --compress --human-readable --itemize-changes
             --no-perms --no-owner --no-group --omit-dir-times)
[[ "$APPLY"  -eq 0 ]] && RSYNC_FLAGS+=(--dry-run)
[[ "$DELETE" -eq 1 ]] && RSYNC_FLAGS+=(--delete)

SSH_CMD="ssh -i $DEPLOY_KEY -o StrictHostKeyChecking=accept-new"

echo "──────────────────────────────────────────────────────────────"
echo "  Console deploy"
echo "  from : $REPO_ROOT/"
echo "  to   : ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/"
echo "  mode : $([[ $APPLY -eq 1 ]] && echo 'APPLY (live)' || echo 'DRY-RUN (preview only)')$([[ $DELETE -eq 1 ]] && echo ' + --delete' || true)$([[ $CLEAN -eq 1 ]] && echo ' + --clean' || true)"
echo "──────────────────────────────────────────────────────────────"

# Preflight: key present + SSH reachable. Fail loud before touching rsync.
[[ -f "$DEPLOY_KEY" ]] || { echo "ERROR: SSH key not found: $DEPLOY_KEY" >&2; exit 1; }
if ! $SSH_CMD -o ConnectTimeout=8 -o BatchMode=yes "${DEPLOY_USER}@${DEPLOY_HOST}" true 2>/dev/null; then
  echo "ERROR: cannot SSH to ${DEPLOY_USER}@${DEPLOY_HOST}." >&2
  echo "       Check the host is reachable and the key is authorized." >&2
  exit 1
fi

rsync "${RSYNC_FLAGS[@]}" "${EXCLUDES[@]}" \
  -e "$SSH_CMD" \
  "$REPO_ROOT/" "${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/"

if [[ "$CLEAN" -eq 1 ]]; then
  echo "──────────────────────────────────────────────────────────────"
  echo "  Cleanup: stale dev-only files on the server"
  # Guard against a catastrophic rm: DEPLOY_PATH must be an absolute path and
  # not the filesystem root. Targets are a fixed allowlist, joined under it.
  case "$DEPLOY_PATH" in
    /|"" ) echo "  ERROR: refusing to clean with DEPLOY_PATH='$DEPLOY_PATH'" >&2; exit 1 ;;
    /*   ) : ;;
    *    ) echo "  ERROR: DEPLOY_PATH must be absolute, got '$DEPLOY_PATH'" >&2; exit 1 ;;
  esac
  # Run the loop remotely: report each target, removing only when APPLY=1.
  $SSH_CMD "${DEPLOY_USER}@${DEPLOY_HOST}" \
    "ROOT='$DEPLOY_PATH'; APPLY='$APPLY'; for rel in ${CLEAN_TARGETS[*]}; do \
       full=\"\$ROOT/\$rel\"; \
       [ -e \"\$full\" ] || continue; \
       if [ \"\$APPLY\" = 1 ]; then rm -rf -- \"\$full\" && echo \"  removed  \$rel\"; \
       else echo \"  would remove  \$rel\"; fi; \
     done; \
     echo '  (config/secrets.inc and db/*.db are never touched)'"
fi

echo "──────────────────────────────────────────────────────────────"
if [[ "$APPLY" -eq 0 ]]; then
  echo "  Dry-run complete. Nothing was transferred."
  echo "  Re-run with --apply to deploy for real."
else
  echo "  Deploy complete. Test your console URL in a browser."
  echo "  Then read the WebDNA log on the server (see CLAUDE.md › Commands)."
fi
echo "──────────────────────────────────────────────────────────────"
