#!/bin/bash

#Exit immediately if a command exits with a non-zero status:
set -e

showUsage() {
	>&2 echo "Usage: $0 ORGANIZATION APP_TOKEN"
}

if [[ $# -ne 2 ]];
then
    >&2 echo "Error: Organization and/or app token not provided"
	showUsage
    exit 1
fi

# Name of the organization we want to generate token for
ACCOUNT_NAME="$1"
APP_TOKEN="$2"

INSTALLATION_ID_RESPONSE=$(curl -s -H "Authorization: Bearer ${APP_TOKEN}" \
    -H "Accept: application/vnd.github.machine-man-preview+json" \
    https://api.github.com/app/installations)
	
INSTALLATION_ID=$(echo $INSTALLATION_ID_RESPONSE | jq '.[] | select(.account.login=="'${ACCOUNT_NAME}'")' | jq -r '.id')

if [ -z "$INSTALLATION_ID" ];
then
   >&2 echo "Unable to obtain installation ID"
   >&2 echo "$INSTALLATION_ID_RESPONSE"
   exit 1
fi

# authenticate as github app and get access token
INSTALLATION_TOKEN_RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer ${APP_TOKEN}" \
        -H "Accept: application/vnd.github.machine-man-preview+json" \
        https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens)
		
INSTALLATION_TOKEN=$(echo $INSTALLATION_TOKEN_RESPONSE | jq -r '.token')

if [ -z "$INSTALLATION_TOKEN" ];
then
   >&2 echo "Unable to obtain installation token"
   >&2 echo "$INSTALLATION_TOKEN_RESPONSE"
   exit 1
fi

echo $INSTALLATION_TOKEN