#!/bin/bash

# Add account attributes that the <experiment>pro account will need
#   in order to manage the experiment's data with Rucio

dryrun=${2:-true}

usage(){
    echo "Usage: $0 <account> <dryrun: Default=true>"
    echo "Note: Does NOT apply attributes to the account by default. Must set dryrun to \"false\""
    exit 1
}

actions=(
    "add_rule"
    "add_subscription"
    "declare_bad_file_replicas"
    "add_replicas"
    "update_replicas_states"
    "del_rule"
    "update_rule"
    "approve_rule"
    "update_subscription"
    "reduce_rule"
    "move_rule"
    "add_did"
    "add_dids"
    "attach_dids"
    "detach_dids"
    "create_did_sample"
    "queue_requests"
    "query_request"
    "cancel_request"
    "get_next"
    "resurrect"
    "update_lifetime_exceptions"
    "add_bad_pfns"
    "remove_did_from_followed"
    "remove_dids_from_followed"
)

[[ $# -eq 0 ]] && usage
[[ "$1" == "-h" ]] && usage

account=$1
if [ -z ${account} ]; then
    echo "Please provide an account name to add the attributes to."
    exit 1
fi
echo "Adding attributes to account: ${account}"

for action in ${actions[@]}; do
    if [ $dryrun == true ]; then
        echo "Would add attribute: ${action}"
    else
        echo "Adding attribute: ${action}"
        rucio-admin -a root account add-attribute --key ${action} --value 1 ${account}
        if [ $? != 0 ]; then
            echo "Something broke."
            exit 666
        fi
    fi
done
