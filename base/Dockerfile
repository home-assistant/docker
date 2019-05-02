ARG BUILD_FROM
FROM $BUILD_FROM

####
# Install core
RUN apk add --no-cache \
        bsd-compat-headers \
        libstdc++ \
        libpng \
        tiff \
        libjpeg \
        libjpeg-turbo \
        openssl \
        musl \
        eudev \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

####
## Build library
WORKDIR /usr/src/
ARG BUILD_ARCH

# ssocr
ARG SSOCR_VERSION=v2.19.0
RUN apk add --no-cache \
        imlib2 \
    && apk add --no-cache --virtual .build-dependencies \
        git gcc make musl-dev imlib2-dev \
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
        autoconf automake libpcap-dev git gcc g++ make \
    && git clone --depth 1 -b ${ARPSCAN_VERSION} https://github.com/royhills/arp-scan \
    && cd arp-scan \
    && autoreconf --install \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/arp-scan

# OpenCV/scipy
ARG OPENCV_VERSION=3.4.5
RUN apk add --no-cache \
        libwebp ffmpeg-libs libdc1394 jasper-libs zlib \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ musl-dev cmake make ncurses linux-headers \
        ffmpeg-dev libwebp-dev git libpng-dev zlib-dev \
        libjpeg-turbo-dev tiff-dev jasper-dev libdc1394-dev \
    && export MAKEFLAGS="-j$(nproc)" \
    && pip3 install --no-cache-dir \
        numpy==1.16.3 \
    && git clone --depth 1 -b ${OPENCV_VERSION} https://github.com/opencv/opencv \
    && cd opencv \
    && mkdir -p build \
    && cd build \
    && if [ "${BUILD_ARCH}" != "armhf" ] && [ "${BUILD_ARCH}" != "armv7" ]; then \
            cmake .. -DCMAKE_BUILD_TYPE=Release \
                -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF \
                -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF; \
        else \
            cmake .. -DCMAKE_BUILD_TYPE=Release \
                -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF \
                -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
                -DENABLE_NEON=OFF -DCPU_BASELINE_REQUIRE=""; \
        fi \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/opencv

# OpenALPR & Log4Cplus
ARG LOGCPLUS_VERSION=REL_1_2_0
ARG OPENALPR_VERSION=v2.3.0
RUN apk add --no-cache \
        tesseract-ocr \
    && apk add --no-cache --virtual .build-dependencies \
        cmake ncurses make g++ tesseract-ocr-dev \
        git autoconf automake libtool \
    && git clone --depth 1 -b ${LOGCPLUS_VERSION} https://github.com/log4cplus/log4cplus \
    && cd log4cplus \
    && autoreconf -f -i \
    && ./configure --with-working-locale \
    && make -j$(nproc) \
    && make install \
    && cd /usr/src \
    && rm -rf /usr/src/log4cplus \
    && git clone --depth 1 -b ${OPENALPR_VERSION} https://github.com/openalpr/openalpr \
    && cd openalpr/src \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DWITH_TESTS=FALSE -DWITH_BINDING_JAVA=FALSE -DWITH_BINDING_PYTHON=FALSE -DWITH_BINDING_GO=FALSE -DWITH_DAEMON=FALSE -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/openalpr

# Telldus
RUN apk add --no-cache \
        confuse libftdi1 \
    && apk add --no-cache --virtual .build-dependencies \
        cmake build-base gcc doxygen confuse-dev argp-standalone libftdi1-dev git \
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

##
# Install component packages
RUN apk add --no-cache \
    ffmpeg \
    nmap \
    net-tools \
    bluez \
    bluez-deprecated \
    curl \
    libsodium \
    openssh-client \
    libffi \
    glib \
    socat \
    iperf3

####
## Install pip module for component/homeassistant
COPY requirements.txt /usr/src/
RUN apk add --no-cache \
        mariadb-connector-c postgresql-libs freetds libffi \
    && export MAKEFLAGS="-j$(nproc)" \
    && pip3 install --no-cache-dir --find-links https://wheels.hass.io/alpine-3.9/${BUILD_ARCH}/ \
        -r /usr/src/requirements.txt \
    && rm -f /usr/src/requirements.txt \
    && apk del .build-dependencies

###
# Setup entry point for udevd
COPY entry.sh /bin/

ENTRYPOINT ["/bin/entry.sh"]
