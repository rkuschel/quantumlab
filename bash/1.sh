#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
#!/bin/bash
# === Create build context ===
BUILD_DIR=$(mktemp -d)
cat > "$BUILD_DIR/Dockerfile" << 'EOF'
FROM openquantumsafe/oqs-ossl3:latest

# Install bash, editor, curl, and apache
RUN apk add --no-cache \
    bash \
    vim \
    curl \
    apache2 \
    apache2-ssl

# Set bash as default shell
ENV SHELL=/bin/bash
ENTRYPOINT ["/bin/bash"]

# Demo page
RUN mkdir -p /var/www/localhost/htdocs && \
    echo "<h1>Quantum-Safe Dev Environment</h1><p>OpenSSL + Apache + ML-KEM + Dilithium</p>" > /var/www/localhost/htdocs/index.html

# Generate hybrid PQ cert at startup (so it's fresh)
CMD ["bash", "-c", "\
    if [ ! -f /etc/ssl/private/server.key ]; then \
        echo 'Generating quantum-safe cert...'; \
        openssl req -x509 -new -newkey dilithium3 -pkeyopt kem:mlkem768 \
            -subj '/CN=localhost' -days 1 -nodes \
            -keyout /etc/ssl/private/server.key \
            -out /etc/ssl/certs/server.crt; \
    fi; \
    echo 'Container ready. Try:'; \
    echo '  openssl list -signature-algorithms | grep -i dilithium'; \
    echo '  curl -k https://localhost'; \
    exec bash"]
EOF

# === Build image ===
docker build -t oqs-dev "$BUILD_DIR" --quiet

# === Run interactive container ===
docker run -it --rm \
    -p 8080:80 \
    -p 8443:443 \
    --name oqs-dev-shell \
    oqs-dev

# === Cleanup ===
rm -rf "$BUILD_DIR"
