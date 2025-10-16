#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

logInfoMessage "📁 Build the code available at [$WORKSPACE] and mounted at [$CODEBASE_DIR]"
sleep "$SLEEP_DURATION"

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "❌ Failed to navigate to $CODEBASE_LOCATION. Directory does not exist."
    exit 1
}

# ===============================
# 🧠 Set Java version dynamically
# ===============================
case "$JAVA_VERSION" in
  11)
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    ;;
  17)
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    ;;
  21)
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
    ;;
  *)
    logErrorMessage "❗ Unsupported JAVA_VERSION: $JAVA_VERSION. Defaulting to Java 17"
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    ;;
esac
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

logInfoMessage "✅ Using Java: $(java -version 2>&1 | head -n 1)"
logInfoMessage "👉 java path: $(command -v java)"

# ===============================
# 🧠 Set Gradle version dynamically
# ===============================
case "$GRADLE_VERSION" in
  7.4.2)
    GRADLE_PATH="/opt/gradle/gradle-7.4.2"
    ;;
  8.4)
    GRADLE_PATH="/opt/gradle/gradle-8.4"
    ;;
  8.9)
    GRADLE_PATH="/opt/gradle/gradle-8.9"
    ;;
  *)
    logErrorMessage "❗ Unsupported GRADLE_VERSION: $GRADLE_VERSION. Defaulting to 7.4.2"
    GRADLE_PATH="/opt/gradle/gradle-7.4.2"
    ;;
esac

if [[ -d "$GRADLE_PATH" ]]; then
  export GRADLE_HOME="$GRADLE_PATH"
  export PATH="$GRADLE_HOME/bin:$PATH"
  GRADLE_VERSION_OUTPUT=$(gradle --version 2>/dev/null | grep Gradle | head -n 1)
  logInfoMessage "✅ Using Gradle: ${GRADLE_VERSION_OUTPUT:-Unknown or Not Found}"
  logInfoMessage "👉 gradle path: $(command -v gradle)"
else
  logErrorMessage "❌ Gradle directory not found at $GRADLE_PATH"
  exit 1
fi

# ===============================
# 🏗️  Run Gradle Build
# ===============================
logInfoMessage "🚀 Starting processing at [$CODEBASE_LOCATION]"
logInfoMessage "🔧 Executing: gradle $INSTRUCTION"

gradle $INSTRUCTION
TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}