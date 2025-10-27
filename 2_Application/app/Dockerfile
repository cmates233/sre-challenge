# ---- Builder Stage ----
FROM golang:1.22 as builder

WORKDIR /workspace
COPY . .

# Build the Go binary (same as before)
RUN CGO_ENABLED=0 GOOS=linux go build -o app -ldflags="-w -s" .

# Generate a self-signed cert for TLS termination
RUN mkdir -p /workspace/certs && \
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
      -nodes -keyout /workspace/certs/server.key -out /workspace/certs/server.crt \
      -subj "/CN=localhost"

# ---- Final Stage ----
FROM nginx:1.27-alpine

WORKDIR /

# Copy app binary and certs
COPY --from=builder /workspace/app /app
COPY --from=builder /workspace/certs /etc/ssl/private/

# Replace the default Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTPS port
EXPOSE 443

# Run both Nginx (in foreground) and the Go app
CMD /app & nginx -g 'daemon off;'