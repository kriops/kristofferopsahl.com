#!/bin/bash
set -euo pipefail

SITE=kristofferopsahl
REMOTE=kristoffer@git.kristofferopsahl.com
DEST=/var/www/$SITE

echo "→ Building Hugo site..."
hugo --minify --gc

echo "→ Shipping to $REMOTE:$DEST..."
rsync -az --delete public/ "$REMOTE:$DEST.new/"

echo "→ Atomic swap on remote..."
ssh "$REMOTE" bash <<EOF
set -euo pipefail
rm -rf '$DEST.old'
[ -d '$DEST' ] && mv '$DEST' '$DEST.old'
mv '$DEST.new' '$DEST'
rm -rf '$DEST.old'
EOF

echo "✓ Deployed: https://kristofferopsahl.com"
