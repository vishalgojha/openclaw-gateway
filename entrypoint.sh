#!/bin/sh
set -e

mkdir -p /root/.openclaw

if [ ! -f /root/.openclaw/openclaw.json ]; then
  cp /opt/oc-defaults/openclaw.json /root/.openclaw/openclaw.json
fi

if [ ! -d /root/.openclaw/workspace ]; then
  cp -r /opt/oc-defaults/workspace /root/.openclaw/workspace
fi

exec openclaw gateway --port 18789
