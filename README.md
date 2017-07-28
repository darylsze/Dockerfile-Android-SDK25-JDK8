# Dockerfile-Android-SDK25-JDK8

# usage - copy this file to android project root directory #

# pull the docker image from docker hub
image: darylsze/android-sdk25-jdk8

build:
  stage: build
  variables:
    ANDROID_HOME: "/opt/android-sdk-linux"

  before_script:
  # define sdk location and accept all license which docker image missed.
    - apt-get --quiet install --yes curl
    - mkdir -p "${ANDROID_HOME}/licenses"
    - echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
    - echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "${ANDROID_HOME}/licenses/android-sdk-preview-license"
    - echo -e "\nd975f751698a77b662f1254ddbeed3901e976f5a" > "${ANDROID_HOME}/licenses/intel-android-extra-license"
    - export ANDROID_HOME=${ANDROID_HOME}
    - export PATH=$PATH:${ANDROID_HOME}
    - chmod +x ./gradlew
  script:
  # build
    - ./gradlew assemble --stacktrace
  tags:
  # with usage of docker runner
    - docker
  artifacts:
    paths:
    - app/build/outputs/
  #  trigger on master or tag with prefix 'release-'
  only:
      - master
      - /^release-.*$/
