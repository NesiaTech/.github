#!/bin/sh
# Renders profile/assets/banner-{dark,light}.png (2560x800) from banner.html.
# Needs Chromium or Google Chrome, network access to nesia.tech and Google
# Fonts, and Python 3 with Pillow.
#   CHROME=/path/to/chrome banner/render.sh
set -eu
cd "$(dirname "$0")/.."
CHROME=${CHROME:-/Applications/Chromium.app/Contents/MacOS/Chromium}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for theme in dark light; do
  # Headless Chrome leaves the bottom of the capture blank when the window is
  # as tall as the page, so render a taller window and crop the top 1280x400.
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size=1280,700 \
    --virtual-time-budget=10000 --run-all-compositor-stages-before-draw \
    --screenshot="$tmp/$theme.png" \
    "file://$PWD/banner/banner.html?theme=$theme" >/dev/null 2>&1
  python3 -c 'import sys; from PIL import Image; Image.open(sys.argv[1]).crop((0, 0, 2560, 800)).save(sys.argv[2], optimize=True)' \
    "$tmp/$theme.png" "profile/assets/banner-$theme.png"
  echo "profile/assets/banner-$theme.png"
done
