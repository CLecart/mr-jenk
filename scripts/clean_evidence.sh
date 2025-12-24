#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Simple evidence cleanup/archival script
# Usage:
#   ./scripts/clean_evidence.sh            # archive now, keep raw files
#   ./scripts/clean_evidence.sh --prune-days 30   # archive then delete raw files older than 30d
#   ./scripts/clean_evidence.sh --keep-archives 7 # keep last 7 archives, delete older archives

ARCHIVE_DIR="evidence/archives"
TMP_DIR="/tmp/mr-jenk-evidence-$$"
PRUNE_DAYS=0
KEEP_ARCHIVES=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prune-days)
      PRUNE_DAYS="$2"; shift 2;;
    --keep-archives)
      KEEP_ARCHIVES="$2"; shift 2;;
    --help|-h)
      sed -n '1,120p' "$0"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

mkdir -p "$ARCHIVE_DIR"
mkdir -p "$TMP_DIR"

ts=$(date -u +%Y%m%dT%H%M%SZ)
tarball="$TMP_DIR/evidence-$ts.tar.gz"

echo "Creating tarball of evidence/ (excluding archives) -> $tarball"
tar --exclude="$ARCHIVE_DIR" -czf "$tarball" evidence || { echo "Tar failed"; rm -rf "$TMP_DIR"; exit 1; }

# Determine passphrase: prefer .env.local (single-line passphrase file), else prompt
PASSPHRASE=""
if [ -f .env.local ]; then
  PASSPHRASE=$(sed -n '1p' .env.local)
fi

if [ -z "$PASSPHRASE" ]; then
  echo -n "No .env.local found or empty. Enter passphrase to encrypt archive (input hidden): "
  read -r -s PASSPHRASE
  echo
fi

encfile="$ARCHIVE_DIR/evidence-$ts.tar.gz.gpg"
echo "Encrypting archive -> $encfile (prefer gpg, fallback openssl)"

# Try GPG first (non-interactive). If it fails, fall back to OpenSSL.
if command -v gpg >/dev/null 2>&1; then
  if [ -n "$PASSPHRASE" ]; then
    gpg --batch --yes --symmetric --cipher-algo AES256 --passphrase "$PASSPHRASE" -o "$encfile" "$tarball" 2>/tmp/gpg.err || true
  else
    gpg --batch --yes --symmetric --cipher-algo AES256 -o "$encfile" "$tarball" 2>/tmp/gpg.err || true
  fi
  rc=$?
else
  rc=127
fi

if [ $rc -ne 0 ]; then
  echo "GPG encryption failed (rc=$rc). Falling back to OpenSSL AES-256-CBC."
  encfile_openssl="${encfile%.gpg}.enc"
  if command -v openssl >/dev/null 2>&1; then
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"$PASSPHRASE" -in "$tarball" -out "$encfile_openssl"
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "OpenSSL encryption failed (rc=$rc)"; rm -f "$tarball"; rm -rf "$TMP_DIR"; exit 2
    else
      encfile="$encfile_openssl"
    fi
  else
    echo "Neither gpg nor openssl available; cannot encrypt"; rm -f "$tarball"; rm -rf "$TMP_DIR"; exit 2
  fi
fi

rm -f "$tarball"
rm -rf "$TMP_DIR"

echo "Archive created: $encfile"

if [ "$PRUNE_DAYS" -gt 0 ]; then
  echo "Pruning raw evidence files older than $PRUNE_DAYS days..."
  # careful: only remove files under evidence/ except archives dir
  find evidence -mindepth 1 -maxdepth 2 -path "$ARCHIVE_DIR" -prune -o -type f -mtime "+$PRUNE_DAYS" -print -exec rm -v {} \;
fi

echo "Pruning old archives, keeping last $KEEP_ARCHIVES..."
ls -1t "$ARCHIVE_DIR" | tail -n +$((KEEP_ARCHIVES+1)) | while read -r f; do
  [ -z "$f" ] && continue
  echo "Removing old archive: $ARCHIVE_DIR/$f"
  rm -v "$ARCHIVE_DIR/$f"
done

echo "Cleanup complete. Archives in: $ARCHIVE_DIR"
