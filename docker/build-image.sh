#!/bin/bash
export DOCKER_BUILDKIT=1
export ocirunner=docker

ver="1.26.9"

echo "Building with version: ${ver}"

${ocirunner} build --no-cache \
    -t donkeyman \
    --build-arg rucio_version=${ver} \
    ${PWD}
