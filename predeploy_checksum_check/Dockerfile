# Use a minimal base with bash + jq
FROM alpine:3.19

# Install bash, jq, and coreutils
RUN apk add --no-cache bash jq coreutils

COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
RUN chmod +x /opt/buildpiper/shell-functions/*
COPY build.sh .

# Set environment variables
ENV SLEEP_DURATION="5s"
ENV ACTIVITY_SUB_TASK_CODE=""


# Entry point for the container
ENTRYPOINT ["bash", "./build.sh"]