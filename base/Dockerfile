ARG BUILD_FROM
FROM ${BUILD_FROM}

# Add Hass.io wheels repository
ARG BUILD_ARCH
ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.12/${BUILD_ARCH}/

####
# Install core
RUN apk add --no-cache \
        bsd-compat-headers \
        eudev \
        eudev-libs \
        grep \
        libffi \
        libjpeg \
        libjpeg-turbo \
        libpng \
        libstdc++ \
        musl \
        openssl \
        pulseaudio-alsa \
        tiff \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

##
# Install component packages
RUN apk add --no-cache \
    bluez \
    bluez-deprecated \
    bluez-libs \
    cups-libs \
    curl \
    ffmpeg \
    ffmpeg-libs \
    freetds \
    gammu-libs \
    git \
    glib \
    gmp \
    lapack \
    iperf3 \
    libexecinfo \
    libsodium \
    libwebp \
    libxml2 \
    libxslt \
    mariadb-connector-c \
    mpc1 \
    mpfr4 \
    net-tools \
    nmap \
    openssh-client \
    pianobar \
    postgresql-libs \
    pulseaudio-utils \
    socat \
    unixodbc \
    zlib

####
## Install pip module for component/homeassistant
COPY requirements.txt /usr/src/
RUN pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} \
        -r /usr/src/requirements.txt \
    && rm -f /usr/src/requirements.txt

####
## Build library
WORKDIR /usr/src/

# ssocr
ARG SSOCR_VERSION=v2.19.0
RUN apk add --no-cache \
        imlib2 \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        imlib2-dev \
    && git clone --depth 1 -b ${SSOCR_VERSION} https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/ssocr

# arp-scan
ARG ARPSCAN_VERSION=1.9.7
RUN apk add --no-cache \
        libpcap \
    && apk add --no-cache --virtual .build-dependencies \
        autoconf \
        automake \
        build-base \
        libpcap-dev \
    && git clone --depth 1 -b ${ARPSCAN_VERSION} https://github.com/royhills/arp-scan \
    && cd arp-scan \
    && autoreconf --install \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/arp-scan

# Telldus
RUN apk add --no-cache \
        confuse \
        libftdi1 \
    && apk add --no-cache --virtual .build-dependencies \
        argp-standalone \
        build-base \
        cmake \
        confuse-dev \
        doxygen \
        libftdi1-dev \
    && ln -s /usr/include/libftdi1/ftdi.h /usr/include/ftdi.h \
    && git clone -b master --depth 1 https://github.com/telldus/telldus \
    && cd telldus/telldus-core \
    && sed -i "/\<sys\/socket.h\>/a \#include \<sys\/select.h\>" common/Socket_unix.cpp \
    && cmake . -DBUILD_LIBTELLDUS-CORE=ON \
        -DBUILD_TDADMIN=OFF -DBUILD_TDTOOL=OFF -DGENERATE_MAN=OFF \
        -DFORCE_COMPILE_FROM_TRUNK=ON -DFTDI_LIBRARY=/usr/lib/libftdi1.so \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus

###
# Base S6-Overlay
COPY rootfs /
