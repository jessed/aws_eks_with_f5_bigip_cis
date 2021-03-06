#! /bin/bash

if [[ -n $1 ]]; then
  bigip_host=$1
  echo "Running for Big-IP: $bigip_host"
else
  echo "ERROR: Host not provided"
  echo "USAGE: ./$0 <bigip_host> [bigiq_host]"
  exit
fi

if [[ -n $2 ]]; then bigiq_host=$2; else bigiq_host="bigiq01"; fi
if [[ -n $3 ]]; then run=$3; else run=0; fi

if [[ $run == 0 || $run == "false" ]]; then exit 0; fi

user='azadmin'
pass='NeverWillYouEver!'
CREDS="$user:$pass"

bigiqLicUrl="mgmt/cm/device/tasks/licensing/pool/member-management"

# get bigiq name/addr
#bigiq=$(curl -sku $CREDS https://localhost/mgmt/shared/declarative-onboarding | jq .declaration.Common.myLicenses.bigIqHost | tr -d \")

# get baseMac and mgmtAddr for license revocation
bigipInfo=$(curl -sku $CREDS https://$bigip_host/mgmt/tm/cm/device)
baseMac=$(echo $bigipInfo | jq -r '.items[0].baseMac' | tr [:lower:] [:upper:])
mgmtAddr=$(echo $bigipInfo | jq -r '.items[0].managementIp')

echo "bigiq: $bigiq_host"
echo "baseMac: $baseMac"
echo "mgmtAddr: $mgmtAddr"

# posted to Big-IQ to get a token
authData=$(printf '{"username":"%s","password":"%s","loginProviderName":"tmos"}' $user $pass)

# Revoke a license for an unreachable system
revokeLicense=$(printf '{"licensePoolName":"azure_test","command":"revoke","assignmentType":"UNREACHABLE","addresss":"%s","macAddress":"%s"}' $mgmtAddr $bashMac)

# Get access token
echo curl -sku $CREDS -X POST https://$bigiq/mgmt/shared/authn/login -d "$authData"
accessToken=$(curl -sku $CREDS -X POST https://$bigiq_host/mgmt/shared/authn/login -d "$authData" | jq -r '.token.token')
if [[ -z $accessToken || $accessToken =~ "null" ]]; then
  echo "Bad access token: ($accessToken)"
  curl -sku $CREDS -X POST https://$bigiq/mgmt/shared/authn/login -d "$authData"
  exit
fi

# populate X-F5-Auth-Token header
auth="X-F5-Auth-Token: $accessToken"

# Call Big-IQ to revoke license
curl -sk -H "$auth" -X POST https://$bigiq_host/$bigiqLicUrl -d "$revokeLicense" 


# set vim: set syntax=sh tabstop=2 expandtab:
