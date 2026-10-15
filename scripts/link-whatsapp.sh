#!/usr/bin/env bash
set -euo pipefail
export OPENCLAW_GATEWAY_URL="https://sd.vishalojha.me/agent"
export OPENCLAW_GATEWAY_TOKEN="21ebff2a2ab5382f8fc8f0db1809b22bdc560cf5475353c4"
npx --yes openclaw@latest channels login --channel whatsapp
