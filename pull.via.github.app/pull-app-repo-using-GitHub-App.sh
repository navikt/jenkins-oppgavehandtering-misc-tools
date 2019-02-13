#!/bin/bash

# Exit immediately if a command exits with a non-zero status:
set -e

showUsage() {
	>&2 echo "Usage: $0 organization repoName repoBranch appId"
	>&2 echo "I.e: $0 myOrg_EG_navikt myRepo_EG_oppgave myBranch_EG_master myGitHubAppId_EG_12345"
	>&2 echo "(The prefix organization prefix is assumed and must NOT be passed as part of the repoName parameter)"
}

if [[ $# -ne 4 ]];
then
	showUsage
    exit 1
fi

# =======================================
# Constants for all users of this script:
# ---------------------------------------
#
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
workingDir="."
#
# =======================================

makeWorkspaceTabulaRasa() {
	tempBuildFiles="$workingDir/*"
	GLOBIGNORE='.:..:*/.:*/..'
	
	>&2 echo "About to clean up the Jenkins build directory ${tempBuildFiles}"
	rm -frd ${tempBuildFiles}
}

organization="$1"
repoName="$2"
repoBranch="$3"
appId="$4"

repoPrefix=${organization}/

>&2 echo "organization: ${organization}"
>&2 echo "repoName    : ${repoName}"
>&2 echo "repoBranch  : ${repoBranch}"
>&2 echo "appId       : ${appId}"
>&2 echo "repoPrefix  : ${repoPrefix}"

makeWorkspaceTabulaRasa

git init > /dev/null 2>&1

headCommitHash=$(${scriptDir}/pull-whatever-repo-using-GitHub-App.sh ${scriptDir} ${appId} ${organization} ${repoName} ${repoBranch} ${workingDir})
>&2 echo "headCommitHash: ${headCommitHash}"

GIT_COMMIT=${headCommitHash}
export GIT_COMMIT

>&2 echo "Just set GIT_COMMIT to: ${GIT_COMMIT}"

echo "${GIT_COMMIT}"