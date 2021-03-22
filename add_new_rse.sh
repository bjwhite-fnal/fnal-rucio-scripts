#!/bin/bash

# Add a new RSE and the protocols and attributes associated with it.


usage(){
    echo -e "Usage: $0 <account> <hostname> <port> <protocol prefix> <rse>"
    echo -e "\taccount: The Rucio account to perform the operation as. (Includes setting the limits for this account)"
    echo -e "\thostname: The hostname that is to be used for connections to the new RSE."
    echo -e "\tport: The port number for connections to the new RSE (usually dependent on the protocol being used.)"
    echo -e "\tprefix: The part of the URL that comes after the hostname/port and before the Rucio generated part of the path.\
        Determines where Rucio managed storage for the RSE will reside on the target filesystem."
    echo -e "\trse: The name of the RSE to be added. Convention is to use all capital letters."

    exit 1
}

# Print the help if asked or if given no arguments whatsoever
[[ $# -eq 0 ]] && usage
[[ "$1" == "-h" ]] && usage


# Get all of the arguments.
account=$1
if [ -z ${account} ]; then
    echo "Please provide an account name to use for subsequent Rucio operations."
    exit 1
fi
hostname=$2
if [ -z ${hostname} ]; then
    echo "Please provide a hostname for the new RSE protocol endpoint."
    exit 1
fi
port=$3
if [ -z ${port} ]; then
    echo "Please provide a port for the new RSE protocol endpoint."
    exit 1
fi
protocol=$4
if [ -z ${protocol} ]; then
    echo 'Please provide a protocol to be used (e.g. "scheme", ex. "gsiftp", "root", "http", "https").'
    exit 1
fi
prefix=$5
if [ -z ${prefix} ]; then
    echo "Please provide a resource endpoint prefix to be used for building resource URLs."
    exit 1
fi
rse=$6
if [ -z ${rse} ]; then
    echo "Please provide a name for the new RSE."
    exit 1
fi

# TODO: Make this another parameter?
fts="https://fts3-dev.fnal.gov:8446"
if [ -z ${fts} ]; then
    echo "Please provide a URL for the FTS3 instance to be used for transfer management."
    exit 1
fi

impl='rucio.rse.protocols.gfal.Default'
domainjson='{"wan": {"read": 1, "write":1, "delete": 1, "third_party_copy": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}'

#`rucio-admin rse add MANCHESTER`
echo "Adding RSE ${rse} as account ${account}"
rucio-admin -a ${account} rse add ${rse}

#`rucio-admin rse add-protocol --hostname bohr3226.tier2.hep.manchester.ac.uk --scheme gsiftp --prefix /dpm/tier2.hep.manchester.ac.uk/home/skatelescope.eu/rucio --port 2811 --impl rucio.rse.protocols.gfal.Default --domain-json '{"wan": {"read": 1, "write":1, "delete": 1, "third_party_copy": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' MANCHESTER`
echo "Adding protocol to the RSE ${rse}"
rucio-admin -a ${account} rse add-protocol --hostname ${hostname} --port ${port} --scheme ${scheme} --prefix ${prefix} --domain-json ${domainjson} ${rse}

#`rucio-admin rse set-attribute --rse MANCHESTER --key fts --value https://fts3-test.gridpp.rl.ac.uk:8446`
echo "Setting the FTS attribute on the RSE to ${fts}."
rucio-admin -a ${account} rse set-attribute --rse ${rse} --key fts --value ${fts}

#`rucio-admin account set-limits root MANCHESTER -1`
echo "Setting the limits on the RSE to ${limits}"
rucio-admin -a ${account} account set-limits ${account} ${rse} ${limits}

echo "RSE ${rse} has been added! Don't forget to add a distance to the RSEs that you wish to transfer to from your new RSE."
echo "TODO: Make it lookup the list of RSEs. Query user which one to add distance to, and the distance to be added."
echo "\tSorry, that functionality isn't here yet. Add distances manually with\n\t`rucio-admin rse add-distance --distance <dist\
        ance> --ranking <ranking> ${rse} <destination RSE>`"
