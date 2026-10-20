#!/bin/bash
# Baut Translate-with-Claude.alfredworkflow from src/ (double-click it to install)
set -e
cd "$(dirname "$0")"
rm -f Translate-with-Claude.alfredworkflow
(cd src && zip -qr ../Translate-with-Claude.alfredworkflow . -x '.*')
echo "Built: $(pwd)/Translate-with-Claude.alfredworkflow"
