#!/bin/bash

# This script automates test data movement between the test RSEs DCACHE_BJWHITE_START and DCACHE_BJWHITE_END

# Upload the test files into Rucio
for f in baratheon greyjoy lannister stark targaryen; do
    echo "$FNAL_RUCIO_DIR/bjwhite-stuff/test_data/$f.txt"
    rucio upload --rse DCACHE_BJWHITE_START $FNAL_RUCIO_DIR/bjwhite-stuff/test_data/$f.txt
done
echo "Uploaded Game of Thrones test files to DCACHE_BJWHITE_START RSE."

# Add a dataset for the files
echo "Creating user.root:bjwhite_test_files dataset and adding files"
rucio add-dataset user.root:bjwhite_test_files
rucio attach user.root:bjwhite_test_files \
    user.root:baratheon.txt \
    user.root:greyjoy.txt \
    user.root:lannister.txt \
    user.root:stark.txt \
    user.root:targaryen.txt

# Add rule to move the dataset from DCACHE_BJWHITE_START to DCACHE_BJWHITE_END 
echo "Making a rule to start the transfer of user.root:bjwhite_test_files -> DCACHE_BJWHITE_END"
rucio add-rule user.root:bjwhite_test_files 1 DCACHE_BJWHITE_END

# Check transfers submitted
# TODO
echo "Sleeping for 120 seconds to let the transfers work."
sleep 120

# Check file locations include both DCACHE_BJWHITE_START and DCACHE_BJWHITE_END
echo "Printing the file replicas for verification"
for f in baratheon greyjoy lannister stark targaryen; do
    rucio list-file-replicas user.root:$f.txt
done

