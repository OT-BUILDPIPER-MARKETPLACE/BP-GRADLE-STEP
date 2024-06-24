FROM gradle:jdk11

RUN apt update || true \
    && apt install jq -y
ENV SLEEP_DURATION 5s
COPY build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
ENV ACTIVITY_SUB_TASK_CODE GRADLE_EXECUTE
ENV INSTUCTION build

ENTRYPOINT [ "./build.sh" ]