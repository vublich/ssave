FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget unzip git sed \
    apktool \
    adb \
    zipalign \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH"
WORKDIR /app
