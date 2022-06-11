ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG \
    BUILD_ARCH \
    SSOCR_VERSION \
    ARPSCAN_VERSION \
    LIBCEC_VERSION \
    PICOTTS_HASH \
    TELLDUS_COMMIT \
    IPERF3_VERSION

# Add Home Assistant wheels repository
ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.14/${BUILD_ARCH}/

####
# Install core
RUN \
    apk add --no-cache \
        bsd-compat-headers \
        eudev \
        eudev-libs \
        grep \
        libc6-compat \
        libffi \
        libjpeg \
        libjpeg-turbo \
        libpng \
        libstdc++ \
        yaml-dev \
        musl \
        openssl \
        pulseaudio-alsa \
        tiff \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

##
# Install component packages
RUN \
    apk add --no-cache \
        bluez \
        bluez-deprecated \
        bluez-libs \
        cups-libs \
        curl \
        ffmpeg \
        ffmpeg-libs \
        gammu-libs \
        git \
        glib \
        gmp \
        libexecinfo \
        libgpiod \
        libpcap \
        libsodium \
        libwebp \
        libxml2 \
        libxslt \
        libzbar \
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
        zlib

####
## Install pip module for component/homeassistant
COPY requirements.txt /usr/src/
RUN \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} \
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
    && git clone --depth 1 -b v${SSOCR_VERSION} https://github.com/auerswal/ssocr \
    && cd ssocr \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/ssocr

# arp-scan
RUN \
    apk add --no-cache \
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

# libcec
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
    && git clone --depth 1 -b libcec-${LIBCEC_VERSION} https://github.com/Pulse-Eight/libcec \
    && mkdir -p libcec/build \
    && cd libcec/build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
        -DPYTHON_LIBRARY="/usr/local/lib/libpython3.9.so" \
        -DPYTHON_INCLUDE_DIR="/usr/local/include/python3.9" \
        -DHAVE_LINUX_API=1 \
        .. \
    && make -j$(nproc) \
    && make install \
    && echo "cec" > "/usr/local/lib/python3.9/site-packages/cec.pth" \
    && apk del .build-dependencies \
    && rm -rf /usr/src/libcec

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
    && git reset --hard ${PICOTTS_HASH} \
    && ./autogen.sh \
    && ./configure \
         --disable-static \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/pico

# Telldus
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
    && ln -s /usr/include/libftdi1/ftdi.h /usr/include/ftdi.h \
    && git clone https://github.com/telldus/telldus \
    && cd telldus/telldus-core \
    && git reset --hard ${TELLDUS_COMMIT} \
    && sed -i "/\<sys\/socket.h\>/a \#include \<sys\/select.h\>" common/Socket_unix.cpp \
    && cmake . -DBUILD_LIBTELLDUS-CORE=ON \
        -DBUILD_TDADMIN=OFF -DBUILD_TDTOOL=OFF -DGENERATE_MAN=OFF \
        -DFORCE_COMPILE_FROM_TRUNK=ON -DFTDI_LIBRARY=/usr/lib/libftdi1.so \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus


# iperf3 - https://github.com/esnet/iperf/pull/1202
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base \
    && git clone --depth 1 -b "${IPERF3_VERSION}" https://github.com/esnet/iperf \
    && cd iperf \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/iperf

###
# Base S6-Overlay
COPY rootfs /
