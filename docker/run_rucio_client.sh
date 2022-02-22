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
rucio_account=${rucio_account}

if [[ $experiment == "int" ]]; then
	server_host=https://int-rucio.okd.fnal.gov:443
	auth_host=https://auth-int-rucio.okd.fnal.gov:443
        voms_str=fermilab:/fermilab/Role=Production
elif [[ $experiment == "dune" ]]; then
	server_host=https://dune-rucio.fnal.gov:443
	auth_host=https://auth-dune-rucio.fnal.gov:443
        voms_str=dune:/dune/Role=Production
elif [[ $experiment == "icarus" ]]; then
	server_host=https://icarus-rucio.okd.fnal.gov:443
	auth_host=https://auth-icarus-rucio.okd.fnal.gov:443
        voms_str=fermilab:/fermilab/icarus/Role=Production
elif [[ $experiment == "rubin" ]]; then
	server_host=https://rucio-eval01.slac.stanford.edu:8443
	auth_host=https://rucio-eval01.slac.stanford.edu:8443
        voms_str=lsst:/lsst/Role=ddmopr
	if [[ ${rucio_account} == "root" ]]; then
		rucio_account=bjwhite
	fi
else
	echo "Set the experiment... Dying."
	exit -1
fi

container=$(podman run \
	-e RUCIO_CFG_RUCIO_HOST=${server_host} \
	-e RUCIO_CFG_AUTH_HOST=${auth_host} \
	-e RUCIO_CFG_AUTH_TYPE=x509_proxy \
        -e RUCIO_CFG_CLIENT_X509_PROXY=/tmp/x509up_u1000 \
	-e RUCIO_CFG_ACCOUNT=${rucio_account} \
        -e VOMS_STR=${voms_str} \
        -v ${cert}:/opt/certs/hostcert.pem \
        -v ${cert}:/opt/certs/hostkey.pem \
	--name=rucio-client-${experiment} \
	-it -d donkeyman)
podman cp ${PWD}/certificates ${container}:/etc/grid-security/certificates
