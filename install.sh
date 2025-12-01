#!/bin/bash
# -*- MonkeyBrew Installer — by ᏗᏗDHI -*-

set -e  # Exit on error

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "install.sh : must be run as root or with sudo."
  exit 1
fi

ARGUMENT="$1"
CC="clang"
LFLG="-lcurl"
SRC="mbrew.c"
OUT="mbrew"
PKGDIR="/opt/mbrew"
PKGHDR="$PKGDIR/packages.h"
MANPAGE="mbrew.1"
MANDIR="/usr/share/man/man1"
REPO_URL="https://github.com/Monkeybrews/monkeybrew-core.git"
CLONE_DIR="/tmp/mbrew-src"

echo "== MonkeyBrew Installer =="

# ------------------------------
# Setup directory + header file
# ------------------------------

fetch_source() {
  echo "[*] Fetching MonkeyBrew source code from GitHub..."

  rm -rf "$CLONE_DIR"
  git clone --depth=1 "$REPO_URL" "$CLONE_DIR"

  echo "[*] Locating main .c source file..."

  # Prefer src/mbrew.c if it exists
  if [ -f "$CLONE_DIR/src/mbrew.c" ]; then
    SRC="$CLONE_DIR/src/mbrew.c"
    echo "[+] Using source file: $SRC"
    return
  fi

  # Otherwise, search whole tree for a .c file
  SRC=$(find "$CLONE_DIR" -type f -name "*.c" | head -n 1)

  if [ -z "$SRC" ]; then
    echo "[!] ERROR: No .c files found in cloned repo!"
    exit 1
  fi

  echo "[+] Using source file: $SRC"
}

setup() {
  echo "[*] Setting up MonkeyBrew system directory..."
  mkdir -p "$PKGDIR"

  echo "[*] Creating packages.h..."
  cat > "$PKGHDR" <<'EOF'
// WARNING! : DO NOT EDIT! THIS FILE WAS AUTO-CREATED BY MONKEYBREW //

#ifndef PACKAGES_H
#define PACKAGES_H

#include <string.h>

typedef struct {
    const char *name;
    const char *desc;
    const char *homepage;
    const char *url;
    const char *sha256;
    const char *license;
    const char *configure;
    const char *build;
} PackageInfo;

// ===============================
// Package Database
// ===============================

static const PackageInfo pkg_wget = {
    "wget",
    "Internet file retriever",
    "https://www.gnu.org/software/wget/",
    "https://ftp.gnu.org/gnu/wget/wget-1.24.5.tar.gz",
    "fa2dc35bab5184ecbc46a9ef83def2aaaa3f4c9f3c97d4bd19dcb07d4da637de",
    "GPL-3.0-or-later",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_curl = {
    "curl",
    "Command line tool and library for transferring data with URLs",
    "https://curl.se/",
    "https://curl.se/download/curl-8.9.1.tar.xz",
    "f62c83a8d2ab24f1f7d96c7d235b7c9881b4a0a2363bba6f91ecb6cfa01cbf7f",
    "curl",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_git = {
    "git",
    "Distributed version control system",
    "https://git-scm.com/",
    "https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.46.0.tar.xz",
    "9c47e6b722cf49e5fae62a39cf089e02b4d2a94b604372b4dfda1b4b5d263a24",
    "GPL-2.0-only",
    "make configure && ./configure --prefix=/usr/local",
    "make all install"
};

static const PackageInfo pkg_zlib = {
    "zlib",
    "Compression library implementing the deflate algorithm",
    "https://zlib.net/",
    "https://zlib.net/zlib-1.3.1.tar.gz",
    "b36ec3e3572c9cc40df6fd8b8f4a23a53a58e9d1a6a2c781b22b0b93b9e4b6e3",
    "Zlib",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_openssl = {
    "openssl",
    "Toolkit for SSL/TLS protocols and general-purpose cryptography library",
    "https://www.openssl.org/",
    "https://www.openssl.org/source/openssl-3.3.1.tar.gz",
    "b3c7e3d8e5a826e6a032c3e7e6cdd0e24de3e51380b7b99c01c5469e2b8e9f74",
    "Apache-2.0",
    "./Configure --prefix=/usr/local",
    "make install_sw"
};

static const PackageInfo pkg_ncurses = {
    "ncurses",
    "Terminal handling library for text-based interfaces",
    "https://invisible-island.net/ncurses/",
    "https://invisible-island.net/datafiles/release/ncurses.tar.gz",
    "cce05daf61a64501ef6cd8da1e906c9218db6e3c687f0fbd938b5d3d4c2216e1",
    "MIT",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_bzip2 = {
    "bzip2",
    "High-quality block-sorting file compressor",
    "https://sourceware.org/bzip2/",
    "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz",
    "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269",
    "bzip2-1.0.6",
    "make install PREFIX=/usr/local",
    "make install"
};

static const PackageInfo pkg_xz = {
    "xz",
    "Compression utility with LZMA algorithm support",
    "https://tukaani.org/xz/",
    "https://tukaani.org/xz/xz-5.6.2.tar.gz",
    "9f083b2dc0ed01c138e0cd9f64dc24e3da03e7c9e818a0ee4a3b9a1ec7af7467",
    "Public Domain",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_python = {
    "python",
    "Interpreted, interactive, object-oriented programming language",
    "https://www.python.org/",
    "https://www.python.org/ftp/python/3.12.6/Python-3.12.6.tgz",
    "88f1c16dfe2b66b4a90c7f1a9692a66c1c70a1da243244f96e8c6464b2c1e5b0",
    "Python-2.0",
    "./configure --prefix=/usr/local --enable-optimizations",
    "make install"
};

static const PackageInfo pkg_perl = {
    "perl",
    "Highly capable, feature-rich programming language",
    "https://www.perl.org/",
    "https://www.cpan.org/src/5.0/perl-5.40.0.tar.gz",
    "c42d1e327b853a97b75ffb90a15b1a1dc5a26f82d531e58a5f6d1e1c4bb9af6a",
    "Artistic-1.0-Perl",
    "./Configure -des -Dprefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_ruby = {
    "ruby",
    "Powerful, open-source object-oriented scripting language",
    "https://www.ruby-lang.org/",
    "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.5.tar.xz",
    "b7f31a91b3f1e1278b882a828dd58a5db0f7b6a5a21855b0f7cc930122b1f1e3",
    "Ruby",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_lua = {
    "lua",
    "Lightweight, embeddable scripting language",
    "https://www.lua.org/",
    "https://www.lua.org/ftp/lua-5.4.7.tar.gz",
    "96c5c7d2a5c1bbecf58e0b4cf16a8d3c3b8cde75b1d4b02dc6db8b7a61eaa98e",
    "MIT",
    "make linux install INSTALL_TOP=/usr/local",
    "make install"
};

static const PackageInfo pkg_ffmpeg = {
    "ffmpeg",
    "Play, record, convert, and stream audio and video",
    "https://ffmpeg.org/",
    "https://ffmpeg.org/releases/ffmpeg-7.0.2.tar.xz",
    "a92b873b2e8b7dcad083f1c7f51991b4f04b75f0917cfb038d9a9c2dd2f47c26",
    "GPL-3.0-or-later",
    "./configure --prefix=/usr/local --enable-gpl --enable-nonfree",
    "make install"
};

static const PackageInfo pkg_vim = {
    "vim",
    "Vi Improved, a highly configurable text editor",
    "https://www.vim.org/",
    "https://github.com/vim/vim/archive/refs/tags/v9.1.0703.tar.gz",
    "c1ecf918bdbdfb8f1e3c9c07e723baed9d23cb122b2c3db889a11c2a5ebaa821",
    "Vim",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_emacs = {
    "emacs",
    "Extensible, customizable, self-documenting text editor",
    "https://www.gnu.org/software/emacs/",
    "https://ftp.gnu.org/gnu/emacs/emacs-29.4.tar.xz",
    "13c1b86df2da8c5f7c92497f5a0f558e5a3e8a42d45ef156f1b14f8e0b7ed760",
    "GPL-3.0-or-later",
    "./configure --prefix=/usr/local",
    "make install"
};

static const PackageInfo pkg_make = {
    "make",
    "Utility to maintain groups of programs",
    "https://www.gnu.org/software/make/",
    "https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz",
    "9a1f65cfb37f8a1e947b8a604317d5a201cd70531f6b1c81c66f631761c9a54d",
    "GPL-3.0-or-later",
    "./configure --prefix=/usr/local",
    "make install"
};

// ===============================
// Registry list
// ===============================
static const PackageInfo *all_packages[] = {
    &pkg_wget, &pkg_curl, &pkg_git, &pkg_zlib, &pkg_openssl,
    &pkg_ncurses, &pkg_bzip2, &pkg_xz, &pkg_python, &pkg_perl,
    &pkg_ruby, &pkg_lua, &pkg_ffmpeg, &pkg_vim, &pkg_emacs, &pkg_make,
    NULL
};

static const PackageInfo *find_package(const char *name) {
    for (int i = 0; all_packages[i]; i++) {
        if (strcmp(all_packages[i]->name, name) == 0)
            return all_packages[i];
    }
    return NULL;
}

#endif // PACKAGES_H
EOF
  echo "[+] packages.h written successfully!"
}

# ------------------------------
# Generate man page (mbrew.1)
# ------------------------------
generate_manpage() {
  echo "[*] Generating man page..."
  cat > "$MANPAGE" <<'EOF'
.TH MBREW 1 "November 2025" "MonkeyBrew 1.0" "User Commands"
.SH NAME
mbrew \- a lightweight, brew-inspired package manager written in C
.SH SYNOPSIS
.B mbrew
[\fICOMMAND\fR] [\fIOPTIONS\fR]
.SH DESCRIPTION
MonkeyBrew (mbrew) is a minimalistic package manager inspired by Homebrew,
written in pure C. It allows users to install, build, and manage software
packages using simple package definition headers.

Packages are stored in
.B /opt/mbrew/
and can include metadata such as description, homepage, and build scripts.

.SH COMMANDS
.TP
.B install <package>
Installs the specified package from the MonkeyBrew package definitions.

.TP
.B remove <package>
Uninstalls the given package and its files.

.TP
.B list
Displays all available packages.

.TP
.B update
Updates the MonkeyBrew database.

.TP
.B search <name>
Searches for a package by name.

.TP
.B info <package>
Shows detailed information about a package.

.TP
.B help
Displays usage information.

.SH FILES
.TP
.B /usr/local/bin/mbrew
Main executable.

.TP
.B /opt/mbrew/packages.h
Auto-generated header containing package definitions.

.TP
.B /usr/share/man/man1/mbrew.1.gz
Manual page.

.SH AUTHOR
Written by Aaha3 / JJDHI-3.

.SH LICENSE
This software is distributed under the MIT License.
EOF
  echo "[+] Man page written to ./$MANPAGE"
}

# ------------------------------
# Update Packages
# ------------------------------
update_packages() {
    echo "[*] Updating packages.h..."
    setup  # This will recreate /opt/mbrew/packages.h
    echo "[+] packages.h updated successfully!"
}

# ------------------------------
# Compile locally
# ------------------------------
local_build() {
  setup
  fetch_source
  echo "[*] Compiling MonkeyBrew locally..."
  $CC "$SRC" -o "$OUT" $LFLG
  echo "[+] Build complete: ./$OUT"
}

# ------------------------------
# Global install (binary + man page)
# ------------------------------
global_install() {
  setup
  generate_manpage
  fetch_source

  echo "[*] Compiling and installing MonkeyBrew globally..."
  $CC "$SRC" -o "$OUT" $LFLG
  mv "$OUT" /usr/local/bin/
  echo "[+] Installed binary to /usr/local/bin/$OUT"

  echo "[*] Installing man page..."
  mkdir -p "$MANDIR"
  cp "$MANPAGE" "$MANDIR/"
  gzip -f "$MANDIR/$MANPAGE"
  echo "[+] Man page installed to $MANDIR/$MANPAGE.gz"

  if command -v mandb >/dev/null 2>&1; then
    echo "[*] Updating man database..."
    mandb -q || true
  fi

  echo "[+] Installation complete!"
}


# ------------------------------
# CLI argument handler
# ------------------------------
case "$ARGUMENT" in
  local)
    local_build
    ;;
  global)
    global_install
    ;;
  update)
    update_packages
    ;;
  *)
    echo "Usage: sudo ./install.sh [local|global|update]"
    exit 1
    ;;
esac
