#!/bin/sh
set -e

mkdir -p /root/.openclaw

# Always copy config defaults to ensure updates are applied
cp /opt/oc-defaults/openclaw.json /root/.openclaw/openclaw.json

if [ ! -d /root/.openclaw/workspace ]; then
  cp -r /opt/oc-defaults/workspace /root/.openclaw/workspace
else
  # Merge defaults into existing workspace
  cp -r /opt/oc-defaults/workspace/* /root/.openclaw/workspace/ 2>/dev/null || true
fi

exec openclaw gateway --port 18789
