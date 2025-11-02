#Copyright 2025 Robert Kuschel
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License...
# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
# Start-OqsDevShell.ps1
# Interactive OQS dev container with bash, vim, curl, Apache

$imageName = "oqs-dev"

# Create temporary build context
$buildDir = [System.IO.Path]::GetTempPath() + "oqs-dev-build"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

# Write Dockerfile
@"
FROM openquantumsafe/oqs-ossl3:latest

RUN apk add --no-cache bash vim curl apache2 apache2-ssl

RUN mkdir -p /var/www/localhost/htdocs && \
    echo '<h1>Quantum-Safe Dev Lab</h1><p>bash + vim + curl + Apache + OQS-OpenSSL</p>' > /var/www/localhost/htdocs/index.html

ENTRYPOINT ["/bin/bash"]
"@ | Out-File -FilePath "$buildDir\Dockerfile" -Encoding UTF8

Write-Host "Building image: $imageName ..." -ForegroundColor Cyan
docker build -t $imageName "$buildDir" --quiet

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build image."
    Remove-Item -Recurse -Force $buildDir
    exit 1
}

Write-Host "Starting interactive shell..." -ForegroundColor Green
Write-Host "Try: openssl list -kem-algorithms | grep mlkem" -ForegroundColor Yellow

# Run interactive container (auto-remove on exit)
docker run -it --rm `
    -p 8080:80 `
    -p 8443:443 `
    --name oqs-dev-shell `
    $imageName

# Cleanup
Remove-Item -Recurse -Force $buildDir
