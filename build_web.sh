#!/bin/bash
set -e

# Download and install Flutter SDK
curl -sS https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.2-stable.tar.xz | tar xJ -C /tmp
export PATH="/tmp/flutter/bin:$PATH"

# Configure and build
flutter config --no-analytics
flutter build web --release --base-href / --web-renderer canvaskit
