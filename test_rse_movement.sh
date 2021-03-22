#!/bin/bash

# This script automates test data movement between the test RSEs DCACHE_BJWHITE_START and DCACHE_BJWHITE_END
data_dir=$1

echo "Uploading files from $data_dir"
for f in $(ls $data_dir); do
    echo $f
done
echo

# Upload the test files into Rucio
for f in $(ls $data_dir); do
    echo "Uploading $data_dir/$f"
    if ! rucio upload --rse DCACHE_BJWHITE_START $data_dir/$f; then
        exit 1
    fi
done
echo "Uploaded test files to DCACHE_BJWHITE_START RSE."

# Add a dataset for the files
# First create DID file
for f in $(ls $data_dir); do
    echo "user.root:$f" >> /tmp/tmpdids
done

echo "Creating user.root:rucio_test_files dataset and adding files"
rucio add-dataset user.root:rucio_test_files
if ! rucio attach user.root:rucio_test_files -f /tmp/tmpdids; then
    exit 1
fi
rm /tmp/tmpdids

# Add rule to move the dataset from DCACHE_BJWHITE_START to DCACHE_BJWHITE_END 
echo "Making a rule to start the transfer of user.root:rucio_test_files -> DCACHE_BJWHITE_END"
if ! rucio add-rule user.root:rucio_test_files 1 DCACHE_BJWHITE_END; then
    exit 1
fi

# Check transfers submitted
# TODO
echo "Sleeping for 120 seconds to let the transfers work."
sleep 120

# Check file locations include both DCACHE_BJWHITE_START and DCACHE_BJWHITE_END
echo "Printing the file replicas for verification"
for f in $(ls $data_dir); do
    if ! rucio list-file-replicas user.root:$f; then
        exit 1
    fi
done

