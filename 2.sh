#!/bin/bash

# Create a temporary directory for build context
BUILD_DIR=$(mktemp -d)
echo "Building in temporary directory: $BUILD_DIR"

# === Dockerfile: Build Apache with OQS OpenSSL ===
cat > "$BUILD_DIR/Dockerfile" << 'EOF'
FROM openquantumsafe/oqs-ossl3:latest

# Install Apache and utilities
RUN apk add --no-cache apache2 apache2-ssl apache2-proxy apache2-utils

# Create web root and demo page
RUN mkdir -p /var/www/localhost/htdocs && \
    echo "<h1>Quantum-Safe HTTPS Server</h1><p>Using ML-KEM + Dilithium via OQS-OpenSSL</p>" > /var/www/localhost/htdocs/index.html

# Generate self-signed quantum-safe certificate (ML-KEM-768 + Dilithium3 hybrid)
RUN openssl req -x509 -new \
    -newkey dilithium3 \
    -pkeyopt kem:mlkem768 \
    -subj "/CN=localhost" \
    -days 365 \
    -nodes \
    -keyout /etc/ssl/private/server.key \
    -out /etc/ssl/certs/server.crt

# Configure Apache to use quantum-safe TLS
RUN sed -i 's|^#*LoadModule ssl_module.*|LoadModule ssl_module modules/mod_ssl.so|' /etc/apache2/httpd.conf && \
    sed -i 's|^#*LoadModule socache_shmcb_module.*|LoadModule socache_shmcb_module modules/mod_socache_shmcb.so|' /etc/apache2/httpd.conf && \
    sed -i 's|^#*Include /etc/apache2/conf.d/\*.conf|Include /etc/apache2/conf.d/*.conf|' /etc/apache2/httpd.conf

# Create SSL config
RUN mkdir -p /etc/apache2/conf.d && \
    cat > /etc/apache2/conf.d/ssl.conf << 'APACHE'
Listen 443
<VirtualHost _default_:443>
    DocumentRoot /var/www/localhost/htdocs
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key

    # Enable TLS 1.3 and quantum-safe groups
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
    SSLCipherSuite TLS_AES_256_GCM_SHA384
    SSLHonorCipherOrder on

    # Force hybrid post-quantum key exchange
    SSLGroups X25519MLKEM768:p384_mlkem768
</VirtualHost>
APACHE

# Expose port
EXPOSE 443

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF

# === Build the image ===
docker build -t qsafe-httpd "$BUILD_DIR"

# === Run the container ===
docker run -d -p 8443:443 --name qsafe-httpd qsafe-httpd

# === Cleanup ===
rm -rf "$BUILD_DIR"

# === Final Instructions ===
echo ""
echo "Quantum-Safe Apache Server is RUNNING!"
echo "   → https://localhost:8443"
echo ""
echo "Test with quantum-safe curl:"
echo "   docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 --ciphers TLS_AES_256_GCM_SHA384 https://host.docker.internal:8443"
echo ""
echo "Stop with: docker stop qsafe-httpd"
echo "Remove with: docker rm qsafe-httpd"
