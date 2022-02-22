#!/bin/bash
export DOCKER_BUILDKIT=1

ver="1.26.9"

echo "Building with version: ${ver}"

podman build --no-cache \
    -t donkeyman \
    --build-arg rucio_version=${ver} \
    ${PWD}
