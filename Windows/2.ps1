#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
# Start-QSafeHttpd.ps1
# Auto-builds and runs quantum-safe Apache server
$imageName = "qsafe-httpd"
$containerName = "qsafe-httpd"
$hostPort = 8443

# Inline Dockerfile (no temp files needed)
$dockerfile = @"
FROM openquantumsafe/oqs-ossl3:latest

RUN apk add --no-cache apache2 apache2-ssl

# Create web root
RUN mkdir -p /var/www/localhost/htdocs && \
    echo '<!DOCTYPE html>
<html><head><title>Quantum-Safe Server</title>
<style>body{font-family:Arial;text-align:center;margin-top:10%;background:#f0f8ff}
h1{color:#0066cc}</style></head>
<body>
<h1>Quantum-Safe HTTPS Server Active</h1>
<p>TLS 1.3 + <strong>X25519MLKEM768</strong> + <strong>Dilithium3</strong></p>
<hr>
<p><em>Protected against harvest-now-decrypt-later attacks</em></p>
</body></html>' > /var/www/localhost/htdocs/index.html

# Generate hybrid post-quantum cert
RUN openssl req -x509 -new -newkey dilithium3 -pkeyopt kem:mlkem768 \
    -subj "/CN=localhost" -days 365 -nodes \
    -keyout /etc/ssl/private/server.key \
    -out /etc/ssl/certs/server.crt

# Enable SSL module
RUN sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /etc/apache2/httpd.conf

# SSL VirtualHost config
RUN echo 'Listen 443
<VirtualHost *:443>
    DocumentRoot /var/www/localhost/htdocs
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
    SSLCipherSuite TLS_AES_256_GCM_SHA384
    SSLGroups X25519MLKEM768:p384_mlkem768
</VirtualHost>' > /etc/apache2/conf.d/ssl.conf

EXPOSE 443
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
"@

Write-Host "Building quantum-safe Apache image..." -ForegroundColor Cyan
$dockerfile | docker build -t $imageName -

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed."
    exit 1
}

# Stop existing container if running
if (docker ps -q -f name=$containerName) {
    Write-Host "Stopping old container..." -ForegroundColor Yellow
    docker stop $containerName | Out-Null
}
if (docker ps -aq -f name=$containerName) {
    docker rm $containerName | Out-Null
}

Write-Host "Starting server on https://localhost:$hostPort" -ForegroundColor Green
docker run -d -p "$hostPort`:443" --name $containerName $imageName

Start-Sleep -Seconds 2

if (docker ps -q -f name=$containerName) {
    Write-Host "`nServer is LIVE!" -ForegroundColor Green
    Write-Host "   URL: https://localhost:$hostPort" -ForegroundColor White
    Write-Host "`nTest with OQS curl:" -ForegroundColor Yellow
    Write-Host "   docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 https://host.docker.internal:$hostPort" -ForegroundColor Gray
    Write-Host "`nStop with: docker stop $containerName" -ForegroundColor Gray
} else {
    Write-Error "Container failed to start."
}
