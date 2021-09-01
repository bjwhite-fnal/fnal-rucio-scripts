#!/bin/bash

# This script tests that Rucio is taking file uploads, and transferring files appropriately
data_dir=/tmp/rucio_status_test.$(uuidgen)
dataset_name=rucio_transfer_test_$(uuidgen)
end_rse=DCACHE_BJWHITE_END
num_files=5
rucio_user=root
start_rse=DCACHE_BJWHITE_START

START=0
END=4
file_size=1024

echo "Using data dir: ${data_dir}"
mkdir ${data_dir}
 
echo "Generating files to be uploaded."
for (( c=$START; c<=$END; c++ ))
do
    name=$(uuidgen)
    dd if=/dev/zero of=$data_dir/$name bs=$file_size count=1
done

# Upload the test files into Rucio
for f in $(ls $data_dir); do
    echo "Uploading $data_dir/$f"
    if ! rucio upload --rse $start_rse $data_dir/$f; then
        exit 1
    fi
done
echo "Uploaded test files to DCACHE_BJWHITE_START RSE."

# Add a dataset for the files
# First create DID file
echo "${data_dir}"
for f in $(ls $data_dir); do
    echo "${data_dir}"
    echo "Adding DID to: ${data_dir}/tmdids"
    echo "user.${rucio_user}:${f}" >> ${data_dir}/tmpdids
done

echo "Creating dataset ${dataset_name} and adding files"
rucio add-dataset user.${rucio_user}:${dataset_name}
if ! rucio attach user.${rucio_user}:${dataset_name} -f ${data_dir}/tmpdids; then
    exit 1
fi

# Add rule to move the dataset from $start_rse to $end_rse
echo "Making a rule to start the transfer of user.${rucio_user}:${dataset_name} -> DCACHE_BJWHITE_END"
if ! rucio add-rule user.${rucio_user}:${dataset_name} 1 ${end_rse}; then
    exit 1
fi

# Subscribe to the STOMP broker and wait for notifiations that the transfers have been completed
# TODO

# Check file locations include both DCACHE_BJWHITE_START and DCACHE_BJWHITE_END
#echo "Printing the file replicas for verification"
#for f in $(ls $data_dir); do
#    if ! rucio list-file-replicas user.root:$f; then
#        exit 1
#    fi
#done

all_done=0
if [ $all_done == 0 ]; then
    rm -r $data_dir
fi
