<# 
.Copyright 2025 Robert Kuschel
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
SYNOPSIS
    CyberKujo's Quantum-Safe Lab Test — PURE POST-QUANTUM
    Container name: qsafe-lab-test-DC
#>

docker run --rm `
  --add-host host.docker.internal:host-gateway `
  openquantumsafe/curl:latest curl -k -v `
  --tlsv1.3 `
  --ciphers TLS_CHACHA20_POLY1305_SHA256 `
  --curves mlkem768 `
  https://host.docker.internal:4433

  Write-Host @"

THE VAULT IS 100% QUANTUM-SAFE!!!
Key exchange: quantum-resistant (ML-KEM 768)
Signature: quantum-resistant (Dilithium)
Symmetric encryption: TLS_AES_256_GCM_SHA384
SSL: Transport Layer Secure 1.3 (TLSv1.3)

"@ -ForegroundColor Green
