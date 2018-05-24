FROM node:latest
MAINTAINER Kristoph Junge <kristoph.junge@gmail.com>

ENV DEBIAN_FRONTEND="noninteractive"

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Utilities
RUN apt-get update && \
    apt-get -y install apt-transport-https unzip curl usbutils --no-install-recommends

# NativeScript
RUN npm install -g nativescript --unsafe-perm && \
    tns error-reporting disable

# Android build requirements
RUN apt-get -y install lib32stdc++6 lib32z1 --no-install-recommends

RUN apt-get update && apt-get install -y software-properties-common python-software-properties && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && apt-get update && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && apt-get install -y oracle-java8-installer && rm -rf /var/cache/oracle-jdk8-installer 
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Android SDK
ARG ANDROID_SDK_URL
ARG ANDROID_SYSTEM_PACKAGE
ARG ANDROID_BUILD_TOOLS_PACKAGE
ARG ANDROID_PACKAGES="$ANDROID_SYSTEM_PACKAGE,$ANDROID_BUILD_TOOLS_PACKAGE,platform-tools,extra-android-m2repository,extra-google-m2repository"
RUN wget $ANDROID_SDK_URL -O /tmp/android-sdk.zip
RUN mkdir /opt/android-sdk /app /dist

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools
RUN tns error-reporting disable && \
    unzip -q /tmp/android-sdk.zip -d /opt/android-sdk && \
    rm /tmp/android-sdk.zip
RUN echo "y" | /opt/android-sdk/tools/android --silent update sdk -a -u -t $ANDROID_PACKAGES

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

VOLUME ["/app","/dist"]

WORKDIR /app

CMD ["/docker-entrypoint.sh"]
