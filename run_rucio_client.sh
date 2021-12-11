#!/bin/bash

cert=x509up_u51660
user=bjwhite
fermihost=fermicloud523.fnal.gov
echo "Using local certificate ${cert}"

echo "Making sure there is a x509 proxy for ${user} on ${fermihost}"
ssh ${user}@${fermihost} "sh -c kx509"
if [[ $? != 0 ]]; then
	echo "Error initializing x509 certificate for ${user} on ${fermihost}"
	exit -1
fi

experiment=${1:-int}
rucio_account=${2:-root}

if [[ $experiment == "int" ]]; then
	server_host=https://int-rucio.okd.fnal.gov:443
	auth_host=https://auth-int-rucio.okd.fnal.gov:443
	rucio_account=${rucio_account}
elif [[ $experiment == "dune" ]]; then
	server_host=https://dune-rucio.okd.fnal.gov:443
	auth_host=https://auth-dune-rucio.okd.fnal.gov:443
	rucio_account=${rucio_account}
elif [[ $experiment == "icarus" ]]; then
	server_host=https://icarus-rucio.okd.fnal.gov:443
	auth_host=https://auth-icarus-rucio.okd.fnal.gov:443
	rucio_account=${rucio_account}
elif [[ $experiment == "rubin" ]]; then
	server_host=https://rucio-eval01.slac.stanford.edu:8443
	auth_host=https://rucio-eval01.slac.stanford.edu:8443
	if [[ ${rucio_account} == "root" ]]; then
		rucio_account=bjwhite
	fi
	ssh ${user}@${fermihost} voms-proxy-init -rfc -noregen -voms lsst
else
	echo "Set the experiment... Dying."
	exit -1
fi


scp ${user}@${fermihost}:/tmp/${cert} .
chmod 600 ${PWD}/${cert}

container=$(podman run \
	-e RUCIO_CFG_RUCIO_HOST=${server_host} \
	-e RUCIO_CFG_AUTH_HOST=${auth_host} \
	-e RUCIO_CFG_AUTH_TYPE=x509 \
	-e RUCIO_CFG_CLIENT_CERT=/opt/rucio/etc/usercert.pem \
	-e RUCIO_CFG_CLIENT_KEY=/opt/rucio/etc/userkey.pem \
	-e RUCIO_CFG_ACCOUNT=${rucio_account} \
	--name=rucio-client-${experiment} \
	-it -d rucio/rucio-clients)
# Easiest way to get the Rucio client cert into the container is to just `podman cp`
podman cp ${cert} ${container}:/opt/rucio/etc/usercert.pem
podman cp ${cert} ${container}:/opt/rucio/etc/userkey.pem
