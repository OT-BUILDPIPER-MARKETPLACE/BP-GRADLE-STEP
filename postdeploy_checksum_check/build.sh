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
# 🧪 Check deploy_jar vs deploy_jar
# =============================

CHECKSUM_FILE="$CODEBASE_LOCATION/checksum.json"
TASK_STATUS=$?
if [[ ! -f "$CHECKSUM_FILE" ]]; then
    logErrorMessage "checksum.json not found at $CHECKSUM_FILE"
    exit 1
fi

JAR_NAME=$JAR_NAME
SBOM_OUT="bom-with-deploy-jar.json"
logInfoMessage "Generating CycloneDX SBOM for JAR [$JAR_NAME]"
cyclonedx add files \
  --no-input \
  --base-path ./build/libs \
  --include "$JAR_NAME" \
  --output-file "$SBOM_OUT" \
  --output-format json
if [[ $? -ne 0 ]]; then
    logErrorMessage "CycloneDX SBOM generation failed!"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} false "CycloneDX SBOM generation failed!"
    exit 1
fi
logInfoMessage "CycloneDX SBOM successfully created at [$SBOM_OUT]"
# Extract SHA-256 from $SBOM_OUT
SHA256=$(grep -A1 '"alg": "SHA-256"' $SBOM_OUT | awk -F'"' '/"content"/ { print $4 }')

# Update only the deploy_jar value
tmpfile=$(mktemp)
jq --arg sha "$SHA256" '.deploy_jar = $sha' $CHECKSUM_FILE > "$tmpfile" && mv "$tmpfile" $CHECKSUM_FILE 

TASK_STATUS=$?  
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}