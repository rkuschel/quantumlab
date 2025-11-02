#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
#!/bin/bash

docker build -t qsafe-httpd - << 'EOF'
FROM openquantumsafe/oqs-ossl3:latest
RUN apk add --no-cache apache2 apache2-ssl
RUN mkdir -p /var/www/localhost/htdocs && echo "<h1>Quantum-Safe Server Active</h1>" > /var/www/localhost/htdocs/index.html
RUN openssl req -x509 -new -newkey dilithium3 -pkeyopt kem:mlkem768 -subj "/CN=localhost" -days 365 -nodes -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt
RUN echo 'LoadModule ssl_module modules/mod_ssl.so' >> /etc/apache2/httpd.conf
RUN echo 'Listen 443' > /etc/apache2/conf.d/ssl.conf
RUN echo '<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    DocumentRoot /var/www/localhost/htdocs
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
    SSLCipherSuite TLS_AES_256_GCM_SHA384
    SSLGroups X25519MLKEM768
</VirtualHost>' >> /etc/apache2/conf.d/ssl.conf
EXPOSE 443
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF

docker run -d -p 8443:443 --name qsafe-httpd qsafe-httpd

echo "Quantum-Safe Server Running: https://localhost:8443"
echo "Test: curl -k -v --tlsv1.3 https://localhost:8443"
