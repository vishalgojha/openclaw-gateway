FROM python:3.11-slim
WORKDIR /app
COPY index.html .
EXPOSE 18789
CMD ["python","-m","http.server","18789"]
# build Thu Oct 15 07:18:43 PM IST 2026
# build Thu Oct 15 07:18:49 PM IST 2026
# rebuild Thu Oct 15 07:54:19 PM IST 2026
