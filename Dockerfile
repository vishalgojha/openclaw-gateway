FROM ghcr.io/openclaw/openclaw:latest

USER root

COPY defaults /opt/oc-defaults
COPY entrypoint.sh /usr/local/bin/openclaw-gateway-entrypoint

RUN chmod 0755 /usr/local/bin/openclaw-gateway-entrypoint

ENTRYPOINT ["/usr/local/bin/openclaw-gateway-entrypoint"]
