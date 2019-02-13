#!/bin/bash

# Exit immediately if a command exits with a non-zero status:
set -e

showUsage() {
	>&2 echo "Usage: $0 organization repoName repoBranch appId libraryName"
	>&2 echo "I.e: $0 myOrganization_EG_navikt myRepoName_EG_oppgave myRepoBranch_EG_master 12345 myLibraryName_EG_pipeline-lib"
	>&2 echo "(The prefix organization prefix is assumed and must NOT be passed as part of the repoName parameter)"
}

if [[ $# -ne 5 ]];
then
	showUsage
    exit 1
fi

# =======================================
# Constants for all users of this script:
# ---------------------------------------
#
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
originalCurrentDir=$(pwd)
#
# =======================================

organization="$1"
repoName="$2"
repoBranch="$3"
appId="$4"
libraryName="$5"

repoPrefix=${organization}/
workingDir="./../${JOB_NAME}@libs/${libraryName}"

>&2 echo "originalCurrentDir: ${originalCurrentDir}"
>&2 echo "scriptDir         : ${scriptDir}"
>&2 echo "organization      : ${organization}"
>&2 echo "repoName          : ${repoName}"
>&2 echo "repoBranch        : ${repoBranch}"
>&2 echo "appId             : ${appId}"
>&2 echo "libraryName       : ${libraryName}"
>&2 echo "repoPrefix        : ${repoPrefix}"
>&2 echo "workingDir        : ${workingDir}"

rm -frd ${workingDir}/*.*
mkdir -p ${workingDir}
cd ${workingDir}

git init > /dev/null 2>&1

headCommitHash=$(${scriptDir}/pull-whatever-repo-using-GitHub-App.sh ${scriptDir} ${appId} ${organization} ${repoName} ${repoBranch} ${workingDir})
>&2 echo "headCommitHash: ${headCommitHash}"
cd ${originalCurrentDir}

echo "${workingDir}"