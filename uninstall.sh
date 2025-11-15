#!/bin/bash
# -*- MonkeyBrew Uninstaller — by ᏗᏗDHI -*-

set -e  # Exit on any error

PKGDIR="/opt/mbrew"
BINPATH="/usr/local/bin/mbrew"
MANDIR="/usr/share/man/man1"
MANPAGE="$MANDIR/mbrew.1.gz"

echo "== MonkeyBrew Uninstaller =="

# --- Must be root ---
if [ "$EUID" -ne 0 ]; then
  echo "uninstall.sh : must be run as root or with sudo."
  exit 1
fi

# --- Remove installed binary ---
if [ -f "$BINPATH" ]; then
  echo "[*] Removing binary: $BINPATH"
  rm -f "$BINPATH"
else
  echo "[!] Binary not found at $BINPATH"
fi

# --- Remove package directory ---
if [ -d "$PKGDIR" ]; then
  echo "[*] Removing MonkeyBrew system directory: $PKGDIR"
  rm -rf "$PKGDIR"
else
  echo "[!] Directory not found: $PKGDIR"
fi

# --- Remove man page ---
if [ -f "$MANPAGE" ]; then
  echo "[*] Removing man page: $MANPAGE"
  rm -f "$MANPAGE"
else
  # Try the uncompressed version just in case
  if [ -f "${MANPAGE%.gz}" ]; then
    echo "[*] Removing uncompressed man page: ${MANPAGE%.gz}"
    rm -f "${MANPAGE%.gz}"
  else
    echo "[!] Man page not found in $MANDIR"
  fi
fi

# --- Refresh man database (if available) ---
if command -v mandb >/dev/null 2>&1; then
  echo "[*] Updating man database..."
  mandb -q || true
fi

# --- Check for leftovers ---
if [ ! -f "$BINPATH" ] && [ ! -d "$PKGDIR" ] && [ ! -f "$MANPAGE" ]; then
  echo "[+] MonkeyBrew has been fully uninstalled."
else
  echo "[!] Some components could not be removed."
fi

exit 0
