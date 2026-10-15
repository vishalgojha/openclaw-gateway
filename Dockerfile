FROM python:3.11-slim
WORKDIR /app
COPY index.html .
EXPOSE 18789
CMD ["python","-m","http.server","18789"]
