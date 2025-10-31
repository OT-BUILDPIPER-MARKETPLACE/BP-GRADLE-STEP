#!/bin/bash
set -e

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

logInfoMessage "Starting build process at WORKSPACE: [$WORKSPACE], CODEBASE_DIR: [$CODEBASE_DIR]"
sleep "${SLEEP_DURATION:-5s}"

# ==================================================
# Navigate to codebase directory
# ==================================================
cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "Failed to navigate to $CODEBASE_LOCATION. Directory does not exist."
    exit 1
}

# ==================================================
# Configure Java version dynamically
# ==================================================
case "$JAVA_VERSION" in
  11) JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 ;;
  17) JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ;;
  21) JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 ;;
  *)
    logWarningMessage "Unsupported JAVA_VERSION: $JAVA_VERSION. Defaulting to Java 17"
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    ;;
esac

export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

logInfoMessage "Using Java: $(java -version 2>&1 | head -n 1)"
logInfoMessage " java path: $(command -v java)"

# ==================================================
# Configure Gradle version dynamically
# ==================================================
case "$GRADLE_VERSION" in
  7.4.2) GRADLE_PATH="/opt/gradle/gradle-7.4.2" ;;
  8.4)   GRADLE_PATH="/opt/gradle/gradle-8.4" ;;
  8.9)   GRADLE_PATH="/opt/gradle/gradle-8.9" ;;
  *)
    logWarningMessage " Unsupported GRADLE_VERSION: $GRADLE_VERSION. Defaulting to 7.4.2"
    GRADLE_PATH="/opt/gradle/gradle-7.4.2"
    ;;
esac

if [[ -d "$GRADLE_PATH" ]]; then
  export GRADLE_HOME="$GRADLE_PATH"
  export PATH="$GRADLE_HOME/bin:$PATH"
  GRADLE_VERSION_OUTPUT=$(gradle --version 2>/dev/null | grep Gradle | head -n 1)
  logInfoMessage "Using Gradle: ${GRADLE_VERSION_OUTPUT:-Unknown}"
  logInfoMessage " gradle path: $(command -v gradle)"
else
  logErrorMessage "Gradle directory not found at $GRADLE_PATH"
  exit 1
fi

# ==================================================
# Run Gradle Build (Wrapper First, System Fallback)
# ==================================================
logInfoMessage " Beginning Gradle build in: [$CODEBASE_LOCATION]"

if [[ -f "./gradlew" ]]; then
  logInfoMessage "Gradle wrapper detected — executing './gradlew ${INSTRUCTION}'"
  chmod +x ./gradlew
  ./gradlew ${INSTRUCTION}
else
  logInfoMessage " No Gradle wrapper found — using system Gradle"
  gradle ${INSTRUCTION}
fi

TASK_STATUS=$?
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

if [[ ${TASK_STATUS} -eq 0 ]]; then
  logInfoMessage " Build completed successfully for task: ${INSTRUCTION}"
else
  logErrorMessage "❌ Build failed for task: ${INSTRUCTION}"
  exit ${TASK_STATUS}
fi
