#!/usr/bin/env bash
# 3.sh — NUCLEAR FALLOUT, HEAD FOR THE BUNKER!

set -euo pipefail

docker kill $(docker ps -q -f name=qsafe-httpd) 2>/dev/null || true
docker rm -f $(docker ps -a -q -f name=qsafe-httpd) 2>/dev/null || true
docker rmi -f openquantumsafe/httpd:latest 2>/dev/null || true
docker system prune -af --volumes -f >/dev/null

echo -e "\nNUCLEAR FALLOUT, HEAD FOR THE BUNKER!\n"
echo -e "GROUND ZERO, NOT EVEN RADIATION REMAINS"
echo -e "   No containers"
echo -e "   No images"
echo -e "   No volumes\n"
echo -e "Ready.\n"