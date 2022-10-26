# BP-GRADLE-STEP
I'll enable gradle as a build tool in BuildPiper

## Setup
* Clone the code available at [BP-GRADLE-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-GRADLE-STEP.git)
* Build the docker image

```
git submodule init
git submodule update
docker build -t ot/gradle:0.1 .
```

* Testing
```
docker run -it --rm -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src ot/gradle:0.1
```

* Debugging
```
docker run -it --rm -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src --entrypoint bash  ot/gradle:0.1
```

## Reference
* [Documentation](https://docs.gradle.org/current/userguide/userguide.html)
* [Sample Mobile App](https://github.com/feedhenry-templates/helloworld-android-gradle)