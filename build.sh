#!/usr/bin/env bash
# Builds hud-system-monitor-<version>.plasmoid (the file you upload to the KDE Store or install with kpackagetool6).
set -euo pipefail
cd "$(dirname "$0")/package"
version=$(python3 -c 'import json; print(json.load(open("metadata.json"))["KPlugin"]["Version"])')
out="../hud-system-monitor-$version.plasmoid"
rm -f "$out"
zip -qr "$out" metadata.json contents
echo "Built ${out#../}"
