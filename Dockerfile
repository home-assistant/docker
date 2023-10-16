ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG \
    BUILD_ARCH \
    QEMU_CPU \
    SSOCR_VERSION \
    LIBCEC_VERSION \
    PICOTTS_HASH \
    TELLDUS_COMMIT

# Set pip & S6 defaults
ENV \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_EXTRA_INDEX_URL="https://wheels.home-assistant.io/musllinux-index/" \
    PIP_NO_CACHE_DIR=1 \
    PIP_PREFER_BINARY=1 \
    S6_SERVICES_GRACETIME=220000

##
# Install component packages
RUN \
    apk add --no-cache \
        bluez \
        bluez-deprecated \
        bluez-libs \
        curl \
        eudev-libs \
        ffmpeg \
        iperf3 \
        git \
        grep \
        hwdata-usb \
        libgpiod \
        libjpeg-turbo \
        libpulse \
        libzbar \
        mariadb-connector-c \
        net-tools \
        nmap \
        openssh-client \
        pianobar \
        pulseaudio-alsa \
        socat

####
## Install pip module for component/homeassistant
COPY requirements.txt /usr/src/
RUN \
    pip3 install --only-binary=:all: \
        -r /usr/src/requirements.txt \
    && rm -f /usr/src/requirements.txt

####
## Build library
WORKDIR /usr/src/

# ssocr
RUN \
    apk add --no-cache \
        imlib2 \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        imlib2-dev \
    && git clone --depth 1 -b "v${SSOCR_VERSION}" https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make -j"$(nproc)" \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/ssocr

# libcec
COPY patches/libcec-fix-null-return.patch /usr/src/
RUN apk add --no-cache \
        eudev-libs \
        p8-platform \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        cmake \
        eudev-dev \
        swig \
        p8-platform-dev \
        linux-headers \
    && git clone --depth 1 -b "libcec-${LIBCEC_VERSION}" https://github.com/Pulse-Eight/libcec \
    && cd libcec \
    && git apply ../libcec-fix-null-return.patch \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
        -DPYTHON_LIBRARY="/usr/local/lib/libpython3.11.so" \
        -DPYTHON_INCLUDE_DIR="/usr/local/include/python3.11" \
        -DHAVE_LINUX_API=1 \
        .. \
    && make -j"$(nproc)" \
    && make install \
    && echo "cec" > "/usr/local/lib/python3.11/site-packages/cec.pth" \
    && apk del .build-dependencies \
    && rm -rf \
        /usr/src/libcec \
        /usr/src/libcec-fix-null-return.patch

# PicoTTS - it has no specific version - commit should be taken from build.json
RUN apk add --no-cache \
        popt \
    && apk add --no-cache --virtual .build-dependencies \
       automake \
       autoconf \
       libtool \
       popt-dev \
       build-base \ 
    && git clone https://github.com/naggety/picotts.git pico \
    && cd pico/pico \
    && git reset --hard "${PICOTTS_HASH}" \
    && ./autogen.sh \
    && ./configure \
         --disable-static \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/pico

# Telldus
COPY patches/telldus-fix-gcc-11-issues.patch /usr/src/
COPY patches/telldus-fix-alpine-3-17-issues.patch /usr/src/
RUN \
    apk add --no-cache \
        confuse \
        libftdi1 \
    && apk add --no-cache --virtual .build-dependencies \
        argp-standalone \
        build-base \
        cmake \
        confuse-dev \
        doxygen \
        libftdi1-dev \
    && git clone https://github.com/telldus/telldus \
    && cd telldus \
    && git reset --hard "${TELLDUS_COMMIT}" \
    && git apply ../telldus-fix-gcc-11-issues.patch \
    && git apply ../telldus-fix-alpine-3-17-issues.patch \
    && cd telldus-core \
    && cmake . -DBUILD_LIBTELLDUS-CORE=ON \
        -DBUILD_TDADMIN=OFF -DBUILD_TDTOOL=OFF -DGENERATE_MAN=OFF \
        -DFORCE_COMPILE_FROM_TRUNK=ON \
    && make -j"$(nproc)" \
    && make install \
    && apk del .build-dependencies \
    && rm -rf \
        /usr/src/telldus \
        /usr/src/telldus-fix-gcc-11-issues.patch \
        /usr/src/telldus-fix-alpine-3-17-issues.patch
###
# Base S6-Overlay
COPY rootfs /
