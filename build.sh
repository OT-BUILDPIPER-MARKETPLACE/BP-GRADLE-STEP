#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

echo "Build the code available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"

cd "$CODEBASE_LOCATION" || { logErrorMessage "Failed to cd to $CODEBASE_LOCATION"; exit 1; }
gradle $INSTRUCTION
if [ $? -eq 0 ]
then
  generateOutput ${GRADLE_EXECUTE} build true "executed"
  logInfoMessage "Build Sucessfull"
  exit 0
elif  [ $? != 0 ]
then 
  generateOutput ${GRADLE_EXECUTE} build false "not executed"
  logErrorMessage "Build Unsucessfull"
  exit 1
fi