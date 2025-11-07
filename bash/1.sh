#!/usr/bin/env bash
# 1.sh — CyberKujo's Quantum-Safe Lab (FINAL — NO MORE BULLSHIT)
# Port: 4433 → X25519MLKEM768 + dilithium3

set -euo pipefail

docker kill qsafe-httpd 2>/dev/null || true
docker rm -f qsafe-httpd 2>/dev/null || true

docker run -d --name qsafe-httpd -p 4433:443 openquantumsafe/httpd:latest

sleep 5

echo -e "\nLIVE — https://localhost:4433"
echo -e "   X25519MLKEM768 + dilithium3\n"

docker run --rm openquantumsafe/curl:latest curl -k -v --tlsv1.3 https://host.docker.internal:4433
