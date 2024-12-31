#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

logInfoMessage "Build the code available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"

sleep $SLEEP_DURATION
# Change to codebase location
cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "Failed to navigate to $CODEBASE_LOCATION. Directory does not exist."
    TASK_STATUS="1"
    saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
}
# Checking versions
logInfoMessage "Checking versions..." &&gradle gradle --version && java --version

logInfoMessage "Starting processing at [$CODEBASE_LOCATION]"

export ANDROID_SDK_ROOT="/usr/local/android-sdk"
logInfoMessage "Accepting Android SDK licenses"
$ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses <<< "y" >/dev/null


# Check if ROOT_BUILD_DIR is set and navigate accordingly
if [ -n "$ROOT_BUILD_DIR" ]; then
    logInfoMessage "Navigating to gradle root build directory: $ROOT_BUILD_DIR"
    cd "$ROOT_BUILD_DIR" || {
        logErrorMessage "Failed to navigate to gradle root build directory: $ROOT_BUILD_DIR. Directory does not exist."
        exit 1
    }
else
    logInfoMessage "ROOT_BUILD_DIR is not set. Running gradle command in the current directory."
fi

logInfoMessage "gradle $INSTRUCTION"
gradle $INSTRUCTION
TASK_STATUS=$?
logInfoMessage "exit_code: ${TASK_STATUS}"

logInfoMessage "Listing directory to check build...."
ls -ltr 

logInfoMessage "Finding apk files in $ROOT_BUILD_DIR dir...."
find . -type f -name "*.apk"

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}