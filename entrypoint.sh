#!/bin/sh
set -e

mkdir -p /root/.openclaw

# Seed configuration exactly once. OpenClaw owns this file after that point;
# overwriting it on every restart can trigger config-integrity protection and
# discard changes made through the Control UI.
if [ ! -f /root/.openclaw/.config-seeded ]; then
  cp /opt/oc-defaults/openclaw.json /root/.openclaw/openclaw.json
  touch /root/.openclaw/.config-seeded
fi

if [ ! -d /root/.openclaw/workspace ]; then
  cp -r /opt/oc-defaults/workspace /root/.openclaw/workspace
else
  # Merge defaults into existing workspace
  cp -r /opt/oc-defaults/workspace/* /root/.openclaw/workspace/ 2>/dev/null || true
fi

# Install the requested ClawHub skills into the persistent workspace. The
# commands are idempotent and --force refreshes an existing installation.
openclaw skills install @steipete/gog --force --acknowledge-install-policy-warning || echo "gog skill install deferred."
openclaw skills install @matagul/desktop-control --force --acknowledge-install-policy-warning || echo "desktop-control skill install deferred."

# Apply any pending OpenClaw state/database migrations before accepting traffic.
openclaw doctor --fix || echo "OpenClaw doctor reported a warning; continuing with gateway startup."

exec node dist/index.js gateway --port 18789 --allow-unconfigured
