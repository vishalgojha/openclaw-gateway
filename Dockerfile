FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o whatsapp-agent main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/whatsapp-agent .
EXPOSE 18789
CMD ["./whatsapp-agent"]
