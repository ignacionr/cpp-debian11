FROM mcr.microsoft.com/devcontainers/cpp:1-debian-11

ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="none"

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git zip unzip python3-pip \
    build-essential gdb cmake cppcheck \
    wget tar \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install dependency manager Conan
RUN pip3 install conan

# Install newer cmake (works better with Conan)
RUN cd /tmp \
    && wget https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.tar.gz \
    && tar xf cmake-3.27.7-linux-x86_64.tar.gz \
    && mv cmake-3.27.7-linux-x86_64 /opt/ \
    && ln -s /opt/cmake-3.27.7-linux-x86_64/bin/cmake /usr/local/bin/cmake \
    && rm cmake-3.27.7-linux-x86_64.tar.gz

RUN mkdir -p /var/conan && chmod 777 /var/conan
ENV CONAN_USER_HOME=/var/conan
ENV CONAN_HOME=/var/conan

USER vscode
COPY conanfile.txt /tmp/.
RUN conan profile detect
RUN conan install /tmp/. --build=missing -s compiler.cppstd=gnu20

USER root


