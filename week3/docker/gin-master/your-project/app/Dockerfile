# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS builder
WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/app ./main.go

FROM alpine:3.22
WORKDIR /app

RUN addgroup -S app && adduser -S app -G app \
    && apk add --no-cache ca-certificates wget

COPY --from=builder /out/app /app/app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz >/dev/null || exit 1

USER app
ENTRYPOINT ["/app/app"]
