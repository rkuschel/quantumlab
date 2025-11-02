# Created as the first step within a Macbook or Linux with use of bash and docker.
# Requires docker: https://www.docker.com/get-started/
#!/bin/bash

# Pull the latest image
docker pull openquantumsafe/oqs-ossl3:latest

# Run the container interactively with /bin/sh
docker run -it openquantumsafe/oqs-ossl3:latest /bin/sh
