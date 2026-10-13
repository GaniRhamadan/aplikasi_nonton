#!/usr/bin/env bash
set -e

echo "=== Building Anirama for Linux Desktop ==="
cd "$(dirname "$0")/.."

# Clean and get dependencies
flutter pub get

# Build Release binary
flutter build linux --release

DIST_DIR="build/linux/x64/release/bundle"
ARCHIVE_NAME="Anirama-Linux-x64.tar.gz"

echo "=== Packaging Linux Release ==="
tar -czf "$ARCHIVE_NAME" -C "$DIST_DIR" .

echo "=== Sukses! Paket Linux tersimpan di: mobile/$ARCHIVE_NAME ==="
ls -lh "$ARCHIVE_NAME"
