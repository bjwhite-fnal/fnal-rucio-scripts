#!/bin/bash

# This script tests that Rucio is taking file uploads, and transferring files appropriately
experiment=${1:-int}
start_rse=${2:-DCACHE_BJWHITE_START}
end_rse=${3:-DCACHE_BJWHITE_END}
cert=${5:-/tmp/x509up_u}
key=${6:-/tmp/x509up_u}

topic=${7:-/topic/rucio.events.}
durable=${8:-false}
unsubscribe=${9:-false}
debug=${10:-false}
dry_run=${11:-true}

host=${experiment}-msg-rucio.okd.fnal.gov
cert=${cert}$(id -u)
key=${key}$(id -u)
topic=${topic}${experiment}


if [[ ! $dry_run == true ]]; then
    dry_run=false
fi


echo ${dry_run}
data_dir=/tmp/rucio_status_test.$(uuidgen)
dataset_name=rucio_transfer_test_$(uuidgen)
num_files=5
rucio_user=icaruspro

# Settings controlling the number and size of files to generate
START=0
END=0
file_size=1024

echo "Using data dir: ${data_dir}"
mkdir ${data_dir}
 
echo "Generating files to be uploaded."
for (( c=$START; c<=$END; c++ ))
do
    name=$(uuidgen)
    if ! dd if=/dev/zero of=$data_dir/$name bs=$file_size count=1 > /dev/null 2>&1; then
        echo "Error during generation of data file: ${?}"
        exit 1
    fi
    echo "Files generated"
done

# Upload the test files into Rucio
for f in $(ls ${data_dir}); do
    if [[ ${dry_run} == false ]]; then
        echo "Uploading ${data_dir}/${f} to ${start_rse}"
        if ! rucio -a ${rucio_user} upload --rse $start_rse $data_dir/$f; then
            exit 1
        fi
        echo "Uploaded test files to ${start_rse} RSE."
    fi
done

# Add a dataset for the files
# First create DID file
for f in $(ls $data_dir); do
    echo "Adding DID to: ${data_dir}/tmdids"
    echo "user.${rucio_user}:${f}" >> ${data_dir}/tmpdids
done

if [[ ${dry_run} == false ]]; then
    echo "Creating dataset ${dataset_name} and adding files"
    rucio add-dataset user.${rucio_user}:${dataset_name}
    if ! rucio -a ${rucio_user} attach user.${rucio_user}:${dataset_name} -f ${data_dir}/tmpdids; then
        exit 1
    fi
fi

# Add rule to move the dataset from $start_rse to $end_rse
if [[ ${dry_run} == false ]]; then
    echo "Making a rule to start the transfer of user.${rucio_user}:${dataset_name} from ${start_rse} -> ${end_rse}"
    if ! rucio -a ${rucio_user} add-rule user.${rucio_user}:${dataset_name} 1 ${end_rse}; then
        exit 1
    fi
fi

all_done=0
# Subscribe to the STOMP broker and wait for notifiations that the transfers have been completed
# TODO
# Arguments to the Python script that will actually subscribe and listen
#
if [[ ${dry_run} == false ]]; then
    python listen_for_event.py host \
        --cert ${cert} \
        --key ${key} \
        --topic ${topic} \
        --durable ${durable} \
        --unsubscribe ${unsubscribe} \
        --debug ${debug}
fi



all_done=1
if [ $all_done == 1 ]; then
    rm -r $data_dir
fi
