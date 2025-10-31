# Use a minimal Alpine base
FROM alpine:3.19

# Install required packages
RUN apk add --no-cache bash jq coreutils samba-client

# Create shell-functions directory and copy shell scripts
COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
RUN chmod +x /opt/buildpiper/shell-functions/*

# Copy your main build script
COPY build.sh .

# Make it executable
RUN chmod +x build.sh

# Set environment variables with defaults (override at runtime if needed)
ENV SLEEP_DURATION="5s"
ENV ACTIVITY_SUB_TASK_CODE=""
ENV JAR_PATH=""
ENV WIN_SERVER=""
ENV WIN_USER=""
ENV WIN_PASSWORD=""
ENV TARGET_PATH=""


# Entrypoint to execute the script
ENTRYPOINT ["bash", "./build.sh"]