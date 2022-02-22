# Dockerfile for customizations to the Rucio client
# Generate an experiment appropriate VOMS proxy inside the container
# Brandon White <bjwhite@fnal.gov> 2022
ARG rucio_version

FROM rucio/rucio-clients:release-${rucio_version}

ADD docker-entrypoint.sh /docker-entrypoint.sh
USER root
RUN mkdir /opt/proxy
USER 1000

ENTRYPOINT /docker-entrypoint.sh
