#!/bin/bash

# Add account attributes that the <experiment>pro account will need
#   in order to manage the experiment's data with Rucio

dryrun=${2:-true}

usage(){
    echo "Usage: $0 <account> <dryrun: Default=true>"
    echo "Note: Does NOT apply attributes to the account by default. Must set dryrun to \"false\""
    exit 1
}

#"declare_suspicious_file_replicas"

actions=(
    "add_account"
    "del_account"
    "update_account"
    "add_rule"
    "add_subscription"
    "add_scope"
    "add_rse"
    "update_rse"
    "add_protocol"
    "del_protocol"
    "update_protocol"
    "add_qos_policy"
    "delete_qos_policy"
    "declare_bad_file_replicas"
    "add_replicas"
    "delete_replicas"
    "skip_availability_check"
    "update_replicas_states"
    "add_rse_attribute"
    "del_rse_attribute"
    "del_rse"
    "del_rule"
    "update_rule"
    "approve_rule"
    "update_subscription"
    "reduce_rule"
    "move_rule"
    "get_auth_token_user_pass"
    "get_auth_token_gss"
    "get_auth_token_x509"
    "get_auth_token_saml"
    "add_account_identity"
    "add_did"
    "add_dids"
    "attach_dids"
    "detach_dids"
    "attach_dids_to_dids"
    "create_did_sample"
    "set_metadata"
    "set_status"
    "queue_requests"
    "set_rse_usage"
    "set_rse_limits"
    "query_request"
    "get_request_by_did"
    "cancel_request"
    "get_next"
    "set_local_account_limit"
    "set_global_account_limit"
    "delete_local_account_limit"
    "delete_global_account_limit"
    "config_sections"
    "config_add_section"
    "config_has_section"
    "config_options"
    "config_has_option"
    "config_get"
    "config_items"
    "config_set"
    "config_remove_section"
    "config_remove_option"
    "get_local_account_usage"
    "get_global_account_usage"
    "add_attribute"
    "del_attribute"
    "list_heartbeats"
    "resurrect"
    "update_lifetime_exceptions"
    "get_ssh_challenge_token"
    "get_signed_url"
    "add_bad_pfns"
    "del_account_identity"
    "del_identity"
    "remove_did_from_followed"
    "remove_dids_from_followed"
    "add_distance"
    "update_distance"
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
