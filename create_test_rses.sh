#!/bin/bash
# Quickly recreate two test RSEs and the protocols/distances between them

#default_prefix=/pnfs/fnal.gov/usr/$EXPERIMENT/scratch/users/bjwhite/rucio_test

# Integration prefix. Volatile storage, files will be deleted (~30 day lifetime according to Dmitry)
default_prefix=/pnfs/fnal.gov/usr/fermilab/volatile/rucio-int

# ICARUS Prefix
#default_prefix=/pnfs/fnal.gov/usr/icarus/persistent/icaruspro/rucio_test

echo "Adding RSE's"
rucio-admin rse add DCACHE_BJWHITE_START
rucio-admin rse add DCACHE_BJWHITE_END
echo

sleep 5

echo "Adding RSE protocols"
rucio-admin rse add-protocol \
    --hostname fndca1.fnal.gov \
    --scheme gsiftp \
    --prefix $default_prefix/start_location \
    --port 2811 \
    --impl rucio.rse.protocols.gfal.Default \
    --domain-json '{"wan": {"read": 1, "write":1, "delete": 1, "third_party_copy": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' \
    DCACHE_BJWHITE_START
echo "Should have added the start RSE protocol"

sleep 5

rucio-admin rse add-protocol \
    --hostname fndca1.fnal.gov \
    --scheme gsiftp \
    --prefix $default_prefix/end_location \
    --port 2811 \
    --impl rucio.rse.protocols.gfal.Default \
    --domain-json '{"wan": {"read": 1, "write":1, "delete": 1, "third_party_copy": 1}, "lan": {"read": 1, "write": 1, "delete": 1}}' \
    DCACHE_BJWHITE_END
echo "Should have added the end RSE protocol"
echo

sleep 5

echo "Adding FTS3 RSE attributes"
rucio-admin rse set-attribute --rse DCACHE_BJWHITE_START --key fts --value https://fts-dev.fnal.gov:8446
rucio-admin rse set-attribute --rse DCACHE_BJWHITE_END --key fts --value https://fts-dev.fnal.gov:8446
rucio-admin rse set-attribute --rse DCACHE_BJWHITE_END --key greedyDeletion --value True
echo
sleep 5
echo "Setting RSE limits"
rucio-admin account set-limits root DCACHE_BJWHITE_START infinity 
rucio-admin account set-limits root DCACHE_BJWHITE_END infinity
echo
sleep 5
echo "Adding RSE distances"
rucio-admin rse add-distance --distance 1 --ranking 1 DCACHE_BJWHITE_START DCACHE_BJWHITE_END
rucio-admin rse add-distance --distance 1 --ranking 1 DCACHE_BJWHITE_END DCACHE_BJWHITE_START
echo
echo "Adding scope"
rucio-admin scope add --scope user.root --account root
echo "All done"
