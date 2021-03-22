#!/bin/bash

# Brandon White <bjwhite@fnal.gov>
# Add a user to Rucio, and then add an identity to authenticate with (x509 only to start)

# Required
user=$1 # Provided username of the Rucio account that is to be created
a_type=$2 # Account type: (USER, GROUP, SERVICE)
email=$3 # Email address for the account
identity=$4 # Make sure to put this in single quotes

# Optional
# ( None yet )

# Add the account
rucio-admin account add --type $a_type --email $email  $user

# Add the identity
rucio-admin identity add --account $user --type X509 --id $identity --email $email

# What else do we need to set
# limits?
# 
