FROM gradle:jdk11

RUN groupadd -g 65522 buildpiper && \
    useradd -m -u 65522 -g buildpiper -s /bin/bash buildpiper

RUN apt update || true \
    && apt install jq -y

RUN mkdir -p /bp/workspace && mkdir -p /bp/execution_dir && chown -R buildpiper:buildpiper /bp/workspace && \
    chown -R buildpiper:buildpiper /bp/execution_dir && chown -R buildpiper:buildpiper /bp /opt

USER buildpiper
WORKDIR /home/buildpiper

ENV SLEEP_DURATION 5s

COPY --chown=buildpiper:buildpiper build.sh .
ADD --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

ENV ACTIVITY_SUB_TASK_CODE GRADLE_EXECUTE
ENV WORKSPACE="/bp/workspace"\
    CODEBASE_DIR="javaparser-gradle-sample-master" \
    INSTRUCTION="build" 

RUN chmod +x build.sh

ENTRYPOINT [ "./build.sh" ]