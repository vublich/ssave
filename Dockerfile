
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget unzip git sed \
    apktool \
    adb \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH"

WORKDIR /app
