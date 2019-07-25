echo "Building Jenkins master on the latest CentOS image..."
docker build -f Dockerfile -t nginx-reverse-proxy .