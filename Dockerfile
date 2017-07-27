FROM ubuntu:16.10



# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Dependencies to execute Android builds
#RUN dpkg --add-architecture i386
#RUN apt-get update -qq
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386
RUN apt-get install -y openjdk-8-jdk wget expect unzip

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_SDK_HOME

RUN useradd -u 1000 -M -s /bin/bash android
RUN chown 1000 /opt


#  - apt-get --quiet update --yes
#  - apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
#  - wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip
#  - apt-get install unzip
#  - unzip android-sdk.zip -d android-sdk-linux
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter android-${ANDROID_TARGET_SDK}
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter platform-tools
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS}
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services
#  - echo y | ${ANDROID_HOME}/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository
#  - mkdir -p "${ANDROID_HOME}/licenses"
#  - echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
#  - echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "${ANDROID_HOME}/licenses/android-sdk-preview-license"
#  - echo -e "\nd975f751698a77b662f1254ddbeed3901e976f5a" > "${ANDROID_HOME}/licenses/intel-android-extra-license"
#  - export ANDROID_HOME=$PWD/${ANDROID_HOME}
#  - export PATH=$PATH:$PWD/${ANDROID_HOME}
#  - chmod +x ./gradlew

USER android
ENV ANDROID_SDK_HOME /opt/android-sdk-linux

RUN cd /opt && wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/tools_r25.0.2-linux.zip
RUN cd /opt && unzip android-sdk.zip -d android-sdk-linux
RUN cd /opt && rm -f android-sdk.zip

ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOSDK_ME}/platform-tools:/opt/tools


# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter extra-android-support | grep 'package installed'

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-25 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-24 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-23 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-18 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-16 | grep 'package installed'

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.2 | grep 'package installed'

# Android System Images, for emulators
# Please keep these in descending order!
#RUN echo y | android update --silent sdk --no-ui --all --filter android-25 | grep 'package installed'
#RUN echo y | android --silent update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# Extras
RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-google_play_services | grep 'package installed'


# licenses
RUN mkdir -p "${ANDROID_HOME}/licenses"
RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
RUN echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "${ANDROID_HOME}/licenses/android-sdk-preview-license"
RUN echo -e "\nd975f751698a77b662f1254ddbeed3901e976f5a" > "${ANDROID_HOME}/licenses/intel-android-extra-license"

# google apis
# Please keep these in descending order!
#RUN echo y | android update sdk --no-ui --all --filter addon-google_apis-google-23 | grep 'package installed'

# Copy install tools
COPY tools /opt/tools

#Copy accepted android licenses
COPY licenses ${ANDROID_SDK_HOME}/licenses

# Update SDK
RUN /opt/tools/android-accept-licenses.sh android update sdk --no-ui --obsolete --force

USER root

RUN apt-get clean

VOLUME ["/opt/android-sdk-linux"]