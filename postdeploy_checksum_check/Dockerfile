# Base image with Gradle and JDK 17
FROM gradle:7.4.2-jdk17

# Install required utilities and CycloneDX CLI dependencies
RUN apt update && apt install -y \
    wget \
    unzip \
    jq \
    curl \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Install CycloneDX CLI
RUN curl -sSL https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.24.2/cyclonedx-linux-x64 -o /usr/local/bin/cyclonedx \
    && chmod +x /usr/local/bin/cyclonedx

# Copy shell functions and build script
COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
RUN chmod +x /opt/buildpiper/shell-functions/*
COPY build.sh .

# Set environment variables
ENV SLEEP_DURATION="5s"
ENV ACTIVITY_SUB_TASK_CODE=""
ENV INSTRUCTION=""
ENV JAR_NAME="cyclonedx-sbom-examples-1.0-SNAPSHOT.jar"

# Entry point for the container
ENTRYPOINT ["bash", "./build.sh"]