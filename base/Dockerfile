ARG BUILD_ARCH
FROM homeassistant/${BUILD_ARCH}-base-python:3.7

# Add Hass.io wheels repository
ARG BUILD_ARCH
ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.9/${BUILD_ARCH}/

####
# Install core
RUN apk add --no-cache \
        bsd-compat-headers \
        libstdc++ \
        libpng \
        tiff \
        libffi \
        libjpeg \
        libjpeg-turbo \
        openssl \
        musl \
        eudev \
        eudev-libs \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

##
# Install component packages
RUN apk add --no-cache \
    bluez \
    bluez-libs \
    bluez-deprecated \
    cups-libs \
    curl \
    ffmpeg \
    ffmpeg-libs \
    freetds \
    libsodium \
    glib \
    gmp \
    git \
    iperf3 \
    libxslt \
    libxml2 \
    nmap \
    net-tools \
    mariadb-connector-c \
    mpfr3 \
    mpc1 \
    openssh-client \
    postgresql-libs \
    socat

####
## Install pip module for component/homeassistant
COPY requirements.txt /usr/src/
RUN pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} \
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
ARG ARPSCAN_VERSION=1.9.5
RUN apk add --no-cache \
        libpcap \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        autoconf \
        automake \
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
        build-base \
        cmake \
        doxygen \
        confuse-dev \
        argp-standalone \
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
# Setup entry point for udevd
COPY entry.sh /bin/

ENTRYPOINT ["/bin/entry.sh"]
