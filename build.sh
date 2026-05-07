#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
#source /opt/buildpiper/shell-functions/log-functions.sh
#source /opt/buildpiper/shell-functions/str-functions.sh
#source /opt/buildpiper/shell-functions/file-functions.sh
#source /opt/buildpiper/shell-functions/aws-functions.sh

# ---------------------------------------------------------------
# NOTE: ACTIVITY_SUB_TASK_CODE is managed by the BuildPiper
#       environment. Do NOT override it here to ensure events
#       appear correctly in the UI.
# ---------------------------------------------------------------

TASK_STATUS=0
WORKSPACE="${WORKSPACE:-/bp/workspace}"
CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

if [ "$DEBUG" = true ]; then
  set -x
fi

# ---------------------------------------------------------------
# 1. Initialization
# ---------------------------------------------------------------
logInfoMessage "> Starting step: gradle"
logInfoMessage "> Codebase location: ${CODEBASE_LOCATION}"

add_event "INITIALIZATION" "Successful" \
    "Gradle step initialized" \
    "Codebase: ${CODEBASE_DIR} | Workspace: ${WORKSPACE}"

if [ -n "$SLEEP_DURATION" ]; then
    logInfoMessage "> Sleeping for ${SLEEP_DURATION} second(s)..."
    sleep "$SLEEP_DURATION"
fi

# ---------------------------------------------------------------
# 2. Workspace Navigation
# ---------------------------------------------------------------
logInfoMessage "> Navigating to codebase directory..."

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "> Failed to navigate to codebase directory: ${CODEBASE_LOCATION}"
    add_event "WORKSPACE_NAVIGATION" "Failed" \
        "Failed to switch to codebase directory" \
        "Path: ${CODEBASE_LOCATION} | Verify WORKSPACE and CODEBASE_DIR are set correctly"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
}

logInfoMessage "> Successfully navigated to: ${CODEBASE_LOCATION}"
add_event "WORKSPACE_NAVIGATION" "Successful" \
    "Navigated to codebase directory" \
    "Path: ${CODEBASE_LOCATION}"

# ---------------------------------------------------------------
# 3. Instruction Validation
# ---------------------------------------------------------------
logInfoMessage "> Validating instruction..."

if [ -z "$INSTRUCTION" ]; then
    logErrorMessage "> INSTRUCTION is not set — cannot proceed"
    add_event "INSTRUCTION_VALIDATION" "Failed" \
        "INSTRUCTION variable is not set — cannot execute build" \
        "Set INSTRUCTION in pipeline config (e.g. clean build)"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
fi

logInfoMessage "> Instruction validated: ${INSTRUCTION}"
add_event "INSTRUCTION_VALIDATION" "Successful" \
    "Build instruction validated" \
    "Instruction: ${INSTRUCTION}"

# ---------------------------------------------------------------
# 4. Gradle Execution
# ---------------------------------------------------------------
echo ""
echo "> Gradle Execution Summary"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Parameter" "Value"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Codebase" "${CODEBASE_DIR}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Instruction" "${INSTRUCTION:0:48}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
echo ""

logInfoMessage "> Executing: gradle ${INSTRUCTION}"

add_event "GRADLE_EXECUTION_START" "Successful" \
    "Starting Gradle build" \
    "Command: gradle ${INSTRUCTION:0:100}"

gradle $INSTRUCTION
TASK_STATUS=$?

if [ "${TASK_STATUS}" -eq 0 ]; then
    logInfoMessage "> Gradle instruction executed successfully (exit: ${TASK_STATUS})"
    add_event "GRADLE_EXECUTION_RESULT" "Successful" \
        "Gradle build completed successfully" \
        "Instruction: ${INSTRUCTION:0:100} | Status: Success"
    generateOutput "${GRADLE_EXECUTE}" build true "executed"
else
    logErrorMessage "> Gradle instruction failed (exit: ${TASK_STATUS})"
    add_event "GRADLE_EXECUTION_RESULT" "Failed" \
        "Gradle build failed — review command output above" \
        "Instruction: ${INSTRUCTION:0:100} | Status: Failed | Exit code: ${TASK_STATUS}"
    generateOutput "${GRADLE_EXECUTE}" build false "not executed"
    saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
fi

saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
exit "${TASK_STATUS}"