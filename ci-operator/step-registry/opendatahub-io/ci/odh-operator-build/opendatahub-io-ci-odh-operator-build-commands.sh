#!/bin/sh

# Ensure necessary tools are installed: make, sed, bash, golang
apk update && apk add --no-cache make sed bash curl

wget https://go.dev/dl/go1.21.13.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.13.linux-amd64.tar.gz 
cd /usr/local/go/src/ 
export PATH="/usr/local/go/bin:$PATH"
export GOPATH=/opt/go/ 
export PATH=$PATH:$GOPATH/bin 
echo "$(go version) has been installed"
cd



# Log in to the registry
DOCKER_USER=$(cat "${SECRETS_PATH}/${REGISTRY_SECRET_FILE}" | jq -r ".auths[\"${REGISTRY_HOST}\"].auth" | base64 -d | cut -d':' -f1)
DOCKER_PASS=$(cat "${SECRETS_PATH}/${REGISTRY_SECRET_FILE}" | jq -r ".auths[\"${REGISTRY_HOST}\"].auth" | base64 -d | cut -d':' -f2)

docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}" "${REGISTRY_HOST}"

#create and publish image
make docker-buildx IMAGE_TAG_BASE=${REGISTRY_HOST}/${REGISTRY_ORG}/${IMAGE_REPO} IMG_TAG=latest

#create and publish bundle
make bundle bundle-docker-buildx IMAGE_TAG_BASE=${REGISTRY_HOST}/${REGISTRY_ORG}/${IMAGE_REPO} VERSION=latest

