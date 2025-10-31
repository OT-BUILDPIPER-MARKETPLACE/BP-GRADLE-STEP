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

logInfoMessage "Copying Artifact to the Windows Server"

JAR_FILE=$(basename "$ARTIFACT_PATH")
JAR_DIR=$(dirname "$ARTIFACT_PATH")

# Only attempt to cd if the artifact is in a real path (not just a filename)
if [[ "$JAR_DIR" != "." && "$JAR_DIR" != "$JAR_FILE" ]]; then
    cd "$JAR_DIR" || {
        logErrorMessage "❌ Failed to cd into $JAR_DIR"
        exit 1
    }
else
    logInfoMessage "Artifact is in current directory, no need to change directory"
fi

smbclient "//$WIN_SERVER/$SHARED_FOLDER" -U "${WIN_USER}%${WIN_PASSWORD}" \
  --option='client min protocol=SMB2' \
  --option='client max protocol=SMB3' \
  -c "lcd .; cd $TARGET_PATH; put $JAR_FILE"
  
TASK_STATUS=$?
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}