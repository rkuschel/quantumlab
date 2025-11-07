<# 
.Copyright 2025 Robert Kuschel
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
SYNOPSIS
    CyberKujo's Quantum-Safe Lab Test — PURE POST-QUANTUM
    Container name: qsafe-lab-test-DC
#>
docker kill qsafe-httpd 2>$null | Out-Null
docker rm -f qsafe-httpd 2>$null | Out-Null

docker run -d --name qsafe-httpd -p 4433:443 openquantumsafe/httpd:latest

Start-Sleep -Seconds 5

Write-Host "`nLIVE — https://localhost:4443" -ForegroundColor Green
Write-Host "   X25519MLKEM768 + dilithium3`n"

docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 https://host.docker.internal:4433
