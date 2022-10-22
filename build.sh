#!/bin/bash
source functions.sh

echo "Build the code available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

cd  $WORKSPACE/${CODEBASE_DIR}
gradle $INSTRUCTION
if [ $? -eq 0 ]
then
  generateOutput gradlew build true "executed"
  echo "build sucessfull"
elif  [ $? != 0 ]
then 
  generateOutput gradlew build false "not executed"
  echo "build unsucessfull"
fi