#!/usr/bin/env bash
# Generate /public/og-image.png from /scripts/og-image.svg using rsvg-convert.
# Runs in prebuild (after tokens sync). Idempotent: skips if PNG is newer than SVG.
# If rsvg-convert is missing, warns and continues (PNG will be stale or absent).
set -euo pipefail

cd "$(dirname "$0")/.."

SVG="scripts/og-image.svg"
OUT="public/og-image.png"

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "⚠ rsvg-convert not found — OG image not regenerated." >&2
  echo "  Install: brew install librsvg" >&2
  if [ -f "$OUT" ]; then
    echo "  Existing $OUT will be used." >&2
    exit 0
  else
    exit 0
  fi
fi

# Skip if PNG exists and is newer than SVG (idempotent rebuilds)
if [ -f "$OUT" ] && [ "$SVG" -ot "$OUT" ]; then
  echo "✓ OG image up to date (skip)"
  exit 0
fi

echo "→ Generating OG image: $SVG → $OUT"
rsvg-convert -w 1200 -h 630 "$SVG" -o "$OUT"
echo "✓ OG image generated: $(file "$OUT" | cut -d: -f2)"
