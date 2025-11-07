docker kill $(docker ps -q -f name=qsafe-lab) 2>$null | Out-Null
docker rm -f $(docker ps -a -q -f name=qsafe-lab) 2>$null | Out-Null
docker rmi -f openquantumsafe/httpd:latest 2>$null | Out-Null
docker system prune -af --volumes >$null

Write-Host @"
NUCLEAR FALLOUT, HEAD FOR THE BUNKER!

GROUND ZERO, NOT EVEN RADIATION REMAINS
   No containers
   No images
   No volumes

Ready.
"@ -ForegroundColor Green
