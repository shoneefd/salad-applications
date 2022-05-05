#!/usr/bin/env bash
set -eufo pipefail

echo 'Building application...'
yarn run build || { echo 'Build failed!'; exit 1; }
echo 'Built application'
