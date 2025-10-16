# Base image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    git \
    zip \
    libicu-dev \
    ca-certificates \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install multiple Gradle versions
ENV GRADLE_HOME_BASE=/opt/gradle
RUN mkdir -p $GRADLE_HOME_BASE && \
    curl -sSL https://services.gradle.org/distributions/gradle-7.4.2-bin.zip -o gradle-7.4.2-bin.zip && \
    curl -sSL https://services.gradle.org/distributions/gradle-8.4-bin.zip -o gradle-8.4-bin.zip && \
    curl -sSL https://services.gradle.org/distributions/gradle-8.9-bin.zip -o gradle-8.9-bin.zip && \
    unzip -q gradle-7.4.2-bin.zip -d $GRADLE_HOME_BASE && \
    unzip -q gradle-8.4-bin.zip -d $GRADLE_HOME_BASE && \
    unzip -q gradle-8.9-bin.zip -d $GRADLE_HOME_BASE && \
    rm gradle-*.zip

# Default versions (can be overridden at runtime)
ENV JAVA_VERSION=17
ENV GRADLE_VERSION=7.4.2


# Copy buildpiper shell functions and build script
COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
RUN chmod +x /opt/buildpiper/shell-functions/*

WORKDIR /workspace
COPY build.sh .

# Default environment variables
ENV SLEEP_DURATION="5s"
ENV ACTIVITY_SUB_TASK_CODE=""
ENV INSTRUCTION=""


# Run env setup then build script
ENTRYPOINT ["bash", "./build.sh"]
