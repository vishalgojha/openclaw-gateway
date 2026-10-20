#!/bin/sh
set -e

mkdir -p /root/.openclaw

# Keep the checked-in configuration current while preserving the mounted state
# directory for sessions, credentials, and installed skills.
cp /opt/oc-defaults/openclaw.json /root/.openclaw/openclaw.json

if [ ! -d /root/.openclaw/workspace ]; then
  cp -r /opt/oc-defaults/workspace /root/.openclaw/workspace
else
  # Merge defaults into existing workspace
  cp -r /opt/oc-defaults/workspace/* /root/.openclaw/workspace/ 2>/dev/null || true
fi

# Install the requested ClawHub skills into the persistent workspace. The
# commands are idempotent and --force refreshes an existing installation.
openclaw skills install @steipete/gog --force --acknowledge-install-policy-warning
openclaw skills install @matagul/desktop-control --force --acknowledge-install-policy-warning

exec openclaw gateway --port 18789
