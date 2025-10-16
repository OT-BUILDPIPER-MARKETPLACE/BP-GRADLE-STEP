#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

logInfoMessage "Build the code available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep "$SLEEP_DURATION"

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "Failed to navigate to $CODEBASE_LOCATION. Directory does not exist."
    exit 1
}

# =============================
# 🧪 Check build_jar vs deploy_jar
# =============================

CHECKSUM_FILE="$CODEBASE_LOCATION/checksum.json"
TASK_STATUS=$?
if [[ ! -f "$CHECKSUM_FILE" ]]; then
    logErrorMessage "checksum.json not found at $CHECKSUM_FILE"
    exit 1
fi

BUILD_JAR=$(jq -r '.build_jar' "$CHECKSUM_FILE")
DEPLOY_JAR=$(jq -r '.deploy_jar' "$CHECKSUM_FILE")

logInfoMessage "build_jar: $BUILD_JAR"
logInfoMessage "deploy_jar: $DEPLOY_JAR"

if [[ -z "$DEPLOY_JAR" ]]; then
    logInfoMessage "deploy_jar is empty. Skipping comparison."
else
    if [[ "$BUILD_JAR" == "$DEPLOY_JAR" ]]; then
        logInfoMessage "✅ build_jar matches deploy_jar."
        TASK_STATUS=0
    else
        logInfoMessage "❌ build_jar and deploy_jar do not match."
        TASK_STATUS=1
    fi
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}