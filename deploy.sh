#!/bin/bash
set -euo pipefail

SITE=kristofferopsahl
REMOTE=kristoffer@git.kristofferopsahl.com
DEST=/var/www/$SITE

echo "→ Building Hugo site..."
hugo --minify --gc

echo "→ Shipping to $REMOTE:$DEST..."
rsync -az --delete public/ "$REMOTE:$DEST/"

echo "✓ Deployed: https://kristofferopsahl.com"
