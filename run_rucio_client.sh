#!/bin/bash

# Start a Rucio client container
# ./run_rucio_client <experiment> <rucio_account> <user> <id> <fermihost>
#
# Brandon White (bjwhite@fnal.gov)

usage()
{
    echo "Hello, I'm here to make your life suck less by easily starting Rucio clients for you."
    echo
    echo "Syntax: run_rucio_client.sh <experiment> <rucio_account> <user> <id> <fermihost> -h"
    echo -e "\tPositional (note that they are positional, defaults provided according to the whim of bjwhite)"
    echo -e "\texperiment     The experiment designation (duh). Default: int"
    echo -e "\trucio_account     Account to be used for Rucio. Default: root"
    echo -e "\tuser     FNAL Linux username used for ssh. Default: bjwhite"
    echo -e "\tid     FNAL user id number. Default: 51660"
    echo -e "\tfermihost     Fermilab machine to use for remote access to proxy initialization and grid certificates. Default: fermicloud523.fnal.gov"
    echo
    echo -e "\tOptional"
    echo -e "\t-h    Display help"
    echo
}

if [ $OPTIND -eq -1 ]; then usage; exit; fi
while getopts ":h" option; do
   case $option in
      h) # display Help
         usage
         exit;;
   esac
done

# Arguments
experiment=${1:-int}
rucio_account=${2:-root}
user=${3:-bjwhite}
id=${4:-51660}
fermihost=${5:-fermicloud523.fnal.gov}

cert=x509up_u${id}

echo "Making sure there is a x509 proxy for ${user} (id: ${id}) on ${fermihost} at /tmp/${cert}"
ssh ${user}@${fermihost} "sh -c voms-proxy-destroy; kx509"
if [[ $? != 0 ]]; then
	echo "Error initializing x509 certificate for ${user} on ${fermihost}"
	exit -1
fi


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
	ssh ${user}@${fermihost} voms-proxy-init -rfc -noregen -voms fermilab:/fermilab/icarus/Role=Production
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

# Grab the proxy from the remote machine and the OSG certificates
scp ${user}@${fermihost}:/tmp/${cert} ${PWD}
scp -r ${user}@${fermihost}:/etc/grid-security/certificates ${PWD}
chmod 600 ${PWD}/${cert}

container=$(podman run \
	-e RUCIO_CFG_RUCIO_HOST=${server_host} \
	-e RUCIO_CFG_AUTH_HOST=${auth_host} \
	-e RUCIO_CFG_AUTH_TYPE=x509_proxy \
        -e RUCIO_CFG_CLIENT_X509_PROXY=/tmp/x509up_u1000 \
	-e RUCIO_CFG_ACCOUNT=${rucio_account} \
	--name=rucio-client-${experiment} \
	-it -d rucio/rucio-clients)
# Easiest way to get the Rucio client cert and OSG certificates into the container is to just `podman cp`
podman cp ${PWD}/${cert} ${container}:/tmp/x509up_u1000
podman cp ${PWD}/certificates ${container}:/etc/grid-security/certificates

# Clean up the X509 proxy.
rm ${PWD}/${cert}
