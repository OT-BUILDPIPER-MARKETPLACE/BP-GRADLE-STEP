#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

echo "Build the code available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"

add_event "WORKSPACE SETUP" "Successful" \
      "Workspace and codebase location initialized" \
      "Location: ${CODEBASE_LOCATION}"

cd "$CODEBASE_LOCATION" || { 
  add_event "DIRECTORY CHANGE" "Failed" \
        "Failed to switch to codebase directory" \
        "Path: $CODEBASE_LOCATION"
  logErrorMessage "Failed to cd to $CODEBASE_LOCATION"
  exit 1 
}

add_event "GRADLE EXECUTION" "In-Progress" \
      "Starting Gradle build" \
      "Command: gradle ${INSTRUCTION}"

gradle $INSTRUCTION
STATUS=$?

if [ $STATUS -eq 0 ]
then
  add_event "GRADLE EXECUTION" "Successful" \
        "Gradle build completed successfully" \
        "Status: Success"
  generateOutput ${GRADLE_EXECUTE} build true "executed"
  logInfoMessage "Build Sucessfull"
  exit 0
elif  [ $STATUS != 0 ]
then 
  add_event "GRADLE EXECUTION" "Failed" \
        "Gradle build failed during execution" \
        "Status: Failed"
  generateOutput ${GRADLE_EXECUTE} build false "not executed"
  logErrorMessage "Build Unsucessfull"
  exit 1
fi