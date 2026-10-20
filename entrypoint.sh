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

# A friend-facing deployment can put authentication at Coolify's edge. In
# that mode the browser must not be asked for OpenClaw's operator token.
if [ "${OPENCLAW_AUTH_MODE:-token}" = "none" ]; then
  node -e 'const fs=require("fs"); const p="/root/.openclaw/openclaw.json"; const c=JSON.parse(fs.readFileSync(p,"utf8")); c.gateway ??= {}; c.gateway.auth={mode:"none"}; fs.writeFileSync(p, JSON.stringify(c,null,2)+"\n");'
elif [ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]; then
  node -e 'const fs=require("fs"); const p="/root/.openclaw/openclaw.json"; const c=JSON.parse(fs.readFileSync(p,"utf8")); c.gateway ??= {}; c.gateway.auth={mode:"token",token:process.env.OPENCLAW_GATEWAY_TOKEN}; fs.writeFileSync(p, JSON.stringify(c,null,2)+"\n");'
fi

if [ ! -d /root/.openclaw/workspace ]; then
  cp -r /opt/oc-defaults/workspace /root/.openclaw/workspace
else
  # Merge defaults into existing workspace
  cp -r /opt/oc-defaults/workspace/* /root/.openclaw/workspace/ 2>/dev/null || true
fi

# Install the requested skills only once. Reinstalling them on every restart
# mutates the persistent OpenClaw state while the gateway is booting.
if [ ! -d /root/.openclaw/workspace/skills/gog ]; then
  openclaw skills install @steipete/gog --force --acknowledge-install-policy-warning || echo "gog skill install deferred."
fi
if [ ! -d /root/.openclaw/workspace/skills/desktop-control ]; then
  openclaw skills install @matagul/desktop-control --force --acknowledge-install-policy-warning || echo "desktop-control skill install deferred."
fi

exec node dist/index.js gateway --bind lan --port 18789 --allow-unconfigured
