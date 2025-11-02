#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
#!/bin/bash

# Build and run quantum-safe Apache server

docker build -t qsafe-httpd - <<'EOF'
FROM openquantumsafe/oqs-ossl3:latest

# Install Apache
RUN apk add --no-cache apache2 apache2-ssl

# Create web content
RUN mkdir -p /var/www/localhost/htdocs && \
    cat > /var/www/localhost/htdocs/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Quantum-Safe Server</title></head>
<body style="font-family:Arial;text-align:center;margin-top:10%;">
  <h1>Quantum-Safe HTTPS Server</h1>
  <p>TLS 1.3 + <strong>X25519MLKEM768</strong> + <strong>Dilithium3</strong></p>
  <hr>
  <p><em>Protected from future quantum attacks</em></p>
</body>
</html>
HTML

# Generate hybrid PQ cert
RUN openssl req -x509 -new \
    -newkey dilithium3 \
    -pkeyopt kem:mlkem768 \
    -subj "/CN=localhost" \
    -days 365 \
    -nodes \
    -keyout /etc/ssl/private/server.key \
    -out /etc/ssl/certs/server.crt

# Enable SSL module
RUN sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /etc/apache2/httpd.conf

# Create SSL config using heredoc
RUN mkdir -p /etc/apache2/conf.d && \
    cat > /etc/apache2/conf.d/ssl.conf <<'APACHE'
Listen 443
<VirtualHost *:443>
    DocumentRoot /var/www/localhost/htdocs
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key

    # TLS 1.3 only
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
    SSLCipherSuite TLS_AES_256_GCM_SHA384

    # Force hybrid post-quantum key exchange
    SSLGroups X25519MLKEM768:p384_mlkem768
</VirtualHost>
APACHE

EXPOSE 443
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF

# Stop and remove old container
docker stop qsafe-httpd 2>/dev/null || true
docker rm qsafe-httpd 2>/dev/null || true

# Run new container
docker run -d -p 8443:443 --name qsafe-httpd qsafe-httpd

echo ""
echo "Quantum-Safe Server Running!"
echo "   → https://localhost:8443"
echo ""
echo "Test with:"
echo "   docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 https://host.docker.internal:8443"
echo ""
echo "Stop: docker stop qsafe-httpd"
