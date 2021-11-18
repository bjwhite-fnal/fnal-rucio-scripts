#!/bin/bash

#rucio_account=root
rucio_account=bjwhite

#server_host=https://int-rucio.fnal.gov:443
#auth_host=https://auth-int-rucio.fnal.gov:443
server_host=https://rucio-eval01.slac.stanford.edu:8443
auth_host=https://rucio-eval01.slac.stanford.edu:8443

# Easiest way to get the cert into the container for this is to just `docker cp <cert> <container id>:/opt/rucio/etc/user<cert|key>.pem`

docker run \
	-e RUCIO_CFG_RUCIO_HOST=${server_host} \
	-e RUCIO_CFG_AUTH_HOST=${auth_host} \
	-e RUCIO_CFG_AUTH_TYPE=x509 \
	-e RUCIO_CFG_CLIENT_CERT=/opt/rucio/etc/usercert.pem \
	-e RUCIO_CFG_CLIENT_KEY=/opt/rucio/etc/userkey.pem \
	-e RUCIO_CFG_ACCOUNT=${rucio_account} \
	--name=rucio-client \
	-it -d rucio/rucio-clients
