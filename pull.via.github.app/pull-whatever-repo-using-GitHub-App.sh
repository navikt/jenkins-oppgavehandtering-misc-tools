#!/bin/bash

# Exit immediately if a command exits with a non-zero status:
set -e

showUsage() {
	>&2 echo "Usage: $0 scriptDir appId organization repoName repoBranch workingDir"
	>&2 echo "I.e: $0 myScriptDir_EG__slash_var_slash_lib_slash_jenkins myGitHubAppId_EG_12345 myOrg_EG_navikt myRepo_EG_oppgave myBranch_EG_master myWorkingDir_EG__slash_data_slash_jenkins_slash_workspace_slash_oppgave-master-pipeline-via-GitHub-App-unstable"
	>&2 echo "(The prefix organization prefix is assumed and must NOT be passed as part of the repoName parameter)"
}

if [[ $# -ne 6 ]];
then
	showUsage
    exit 1
fi

scriptDir="$1"
appId="$2"
organization="$3"
repoName="$4"
repoBranch="$5"
workingDir="$6"
repoPrefix=${organization}/

REPO="${repoPrefix}${repoName}"

>&2 echo "scriptDir   : ${scriptDir}"
>&2 echo "appId       : ${appId}"
>&2 echo "organization: ${organization}"
>&2 echo "repoPrefix  : ${repoPrefix}"
>&2 echo "REPO        : ${REPO}"
>&2 echo "repoBranch  : ${repoBranch}"
>&2 echo "workingDir  : ${workingDir}"

# create and sign app jwt
APP_TOKEN=$(${scriptDir}/generate-jwt.sh ${scriptDir}/oppgavehandtering-ci.2019-01-17.private-key.pem $appId)
ACCESS_TOKEN=$(${scriptDir}/generate-installation-token.sh $organization $APP_TOKEN)

# clone repository:
>&2 echo "Pulling ${REPO} from GitHub..."
git pull https://x-access-token:$ACCESS_TOKEN@github.com/${REPO}.git > /dev/null 2>&1
headCommitHash=$(git rev-parse HEAD)
>&2 echo "About to return headCommitHash: ${headCommitHash}"
echo $headCommitHash