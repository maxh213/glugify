#!/usr/bin/env sh
# Rebuilds docs/glugify.bundle.js from the real library source.
# Run from the repo root after changing src/.
set -e
gleam build --target javascript
npx -y esbuild docs/playground-entry.mjs --bundle --minify --format=iife --outfile=docs/glugify.bundle.js
echo "Playground bundle rebuilt: docs/glugify.bundle.js"
