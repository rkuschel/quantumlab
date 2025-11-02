#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
#!/bin/bash
set -euo pipefail

# -------------------------------------------------
# Build a quantum-safe Apache container
# -------------------------------------------------
docker build -t qsafe-httpd - <<'EOF'
FROM openquantumsafe/oqs-ossl3:latest

# ---- 1. Install Apache -------------------------------------------------
RUN apk add --no-cache apache2 apache2-ssl

# ---- 2. Web page --------------------------------------------------------
RUN mkdir -p /var/www/localhost/htdocs && \
    cat > /var/www/localhost/htdocs/index.html <<'HTML'
<!DOCTYPE html>
<html><head><title>Quantum-Safe Demo</title>
<style>body{font-family:Arial;text-align:center;margin-top:10%;background:#f4f9ff}</style>
</head><body>
<h1>Quantum-Safe HTTPS Server</h1>
<p>TLS 1.3 + <strong>X25519MLKEM768</strong> (hybrid KEM) + <strong>Dilithium3</strong></p>
<hr><p><em>Harvest-now-decrypt-later safe</em></p>
</body></html>
HTML

# ---- 3. Generate hybrid PQ key + cert ----------------------------------
RUN set -e && \
    # 3a – Dilithium3 signature key
    openssl genpkey -algorithm dilithium3 -out /tmp/sig.key && \
    # 3b – ML-KEM-768 KEM key
    openssl genpkey -algorithm mlkem768 -out /tmp/kem.key && \
    # 3c – Combine into a hybrid key (OpenSSL understands this)
    openssl pkey -in /tmp/sig.key -inkey /tmp/kem.key -out /etc/ssl/private/server.key && \
    # 3d – Self-signed X.509 (uses the hybrid key)
    openssl req -x509 -new \
        -key /etc/ssl/private/server.key \
        -subj "/CN=localhost" \
        -days 365 -nodes \
        -out /etc/ssl/certs/server.crt && \
    rm -f /tmp/sig.key /tmp/kem.key

# ---- 4. Enable SSL module -----------------------------------------------
RUN sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /etc/apache2/httpd.conf

# ---- 5. Apache SSL virtual host -----------------------------------------
RUN mkdir -p /etc/apache2/conf.d && \
    cat > /etc/apache2/conf.d/ssl.conf <<'APACHE'
Listen 443
<VirtualHost *:443>
    DocumentRoot /var/www/localhost/htdocs
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/server.crt
    SSLCertificateKeyFile   /etc/ssl/private/server.key

    # TLS 1.3 only
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
    SSLCipherSuite TLS_AES_256_GCM_SHA384

    # Force hybrid PQ key-exchange (works with OQS-enabled clients)
    SSLGroups X25519MLKEM768:p384_mlkem768
</VirtualHost>
APACHE

EXPOSE 443
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF

# -------------------------------------------------
# Clean up any old container and start a fresh one
# -------------------------------------------------
docker stop qsafe-httpd 2>/dev/null || true
docker rm   qsafe-httpd 2>/dev/null || true

docker run -d -p 8443:443 --name qsafe-httpd qsafe-httpd

echo ""
echo "Quantum-Safe Apache is running!"
echo "   https://localhost:8443"
echo ""
echo "Quick test (OQS curl):"
echo "   docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 https://host.docker.internal:8443"
echo ""
echo "Stop with: docker stop qsafe-httpd"
