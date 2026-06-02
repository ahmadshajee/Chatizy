#!/bin/bash
set -e

# Fix git safe directory (Vercel runs as root)
git config --global --add safe.directory /tmp/flutter
git config --global --add safe.directory /vercel/path0

# Download and install Flutter SDK
curl -sS https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz | tar xJ -C /tmp
export PATH="/tmp/flutter/bin:$PATH"
export FLUTTER_ROOT="/tmp/flutter"

# Configure and build
flutter config --no-analytics
flutter build web --release --base-href / --web-renderer canvaskit
