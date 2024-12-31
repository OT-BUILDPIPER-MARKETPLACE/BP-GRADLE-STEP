# Base image with Gradle and JDK 11
FROM gradle:7.0.2-jdk11

# Install necessary tools
RUN apt update && apt install -y \
    wget \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set up Android SDK
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O commandlinetools.zip && \
    unzip commandlinetools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/tools && \
    rm commandlinetools.zip
    BP-BASE-SHELL-STEPS
# Accept licenses and install necessary SDK components
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "platform-tools" "build-tools;33.0.2" "platforms;android-33"

# Copy shell functions and build script
COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
COPY build.sh .

# Set environment variables
ENV SLEEP_DURATION="5s"
ENV ACTIVITY_SUB_TASK_CODE=""
ENV INSTRUCTION=""

# Entry point for the container
ENTRYPOINT [ "./build.sh" ]
