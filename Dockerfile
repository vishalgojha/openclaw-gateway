FROM node:24-alpine

WORKDIR /app

RUN npm install -g openclaw@latest

COPY defaults/ /opt/oc-defaults/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/entrypoint.sh"]
