ARG BUILD_FROM
####
## Builder stage for ssocr, installs to /opt/ssocr
FROM ${BUILD_FROM} AS ssocr-builder
ARG SSOCR_VERSION
ARG BUILD_FROM
WORKDIR /tmp/
RUN \
    --mount=type=cache,target=/etc/apk/cache,sharing=locked,id=apk-cache-${BUILD_FROM} \
    apk add \
        build-base \
        imlib2-dev
RUN mkdir /opt/ssocr /tmp/ssocr \
    && curl --silent --fail --location "https://github.com/auerswal/ssocr/archive/refs/tags/v${SSOCR_VERSION}.tar.gz" \
            | tar zxv -C /tmp/ssocr --strip-components 1 \
    && cd /tmp/ssocr \
    && make -j"$(nproc)" \
    && make PREFIX=/opt/ssocr install \
    && rm -rf /tmp/ssocr


####
## Install pip module for component/homeassistant. Installs to /root/.local
FROM ${BUILD_FROM} AS pip-install-builder
ARG BUILD_FROM
WORKDIR /tmp/
COPY requirements.txt /tmp/requirements.txt
RUN \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked,id=pip-builder-${BUILD_FROM} \
    pip3 install --user --only-binary=:all: \
        -r /tmp/requirements.txt


####
## Builder stage for libcec, installs to /opt/libcec
FROM ${BUILD_FROM} AS libcec-builder
ARG LIBCEC_VERSION
ARG BUILD_FROM
WORKDIR /tmp/
COPY patches/libcec-fix-null-return.patch /tmp/
COPY patches/libcec-python313.patch /tmp/
RUN \
    --mount=type=cache,target=/etc/apk/cache,sharing=locked,id=apk-cache-${BUILD_FROM} \
    apk add  \
        build-base \
        cmake \
        eudev-dev \
        git \
        linux-headers \
        p8-platform-dev \
        swig
RUN python_version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')") \
    && git clone --depth 1 -b "libcec-${LIBCEC_VERSION}" https://github.com/Pulse-Eight/libcec \
    && cd libcec \
    && git apply ../libcec-fix-null-return.patch \
    && git apply ../libcec-python313.patch \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/libcec \
        -DPYTHON_LIBRARY="/usr/local/lib/libpython${python_version}.so" \
        -DPYTHON_INCLUDE_DIR="/usr/local/include/python${python_version}" \
        -DHAVE_LINUX_API=1 \
        .. \
    && make -j"$(nproc)" \
    && make install


# Build stage for PicoTTS, installs to /opt/picotts
# PicoTTS - it has no specific version - commit should be taken from build.json
FROM ${BUILD_FROM} AS picotts-builder
ARG PICOTTS_HASH
ARG BUILD_FROM
WORKDIR /tmp/
RUN \
    --mount=type=cache,target=/etc/apk/cache,sharing=locked,id=apk-cache-${BUILD_FROM} \
    apk add \
       autoconf \
       automake \
       build-base \
       git \
       libtool \
       popt-dev
RUN git clone https://github.com/naggety/picotts.git pico \
    && cd pico/pico \
    && git reset --hard "${PICOTTS_HASH}" \
    && ./autogen.sh \
    && mkdir /opt/picotts \
    && ./configure \
         --disable-static \
         --prefix=/opt/picotts \
    && make \
    && make install


# Build stage for Telldus, installs to /opt/telldus
FROM ${BUILD_FROM} AS telldus-builder
ARG TELLDUS_COMMIT
ARG BUILD_FROM
WORKDIR /tmp/
COPY patches/telldus-fix-gcc-11-issues.patch /tmp/
COPY patches/telldus-fix-alpine-3-17-issues.patch /tmp/
RUN \
    --mount=type=cache,target=/etc/apk/cache,sharing=locked,id=apk-cache-${BUILD_FROM} \
    apk add \
        argp-standalone \
        build-base \
        cmake \
        confuse-dev \
        doxygen \
        git \
        libftdi1-dev
RUN git clone https://github.com/telldus/telldus \
    && cd telldus \
    && git reset --hard "${TELLDUS_COMMIT}" \
    && git apply ../telldus-fix-gcc-11-issues.patch \
    && git apply ../telldus-fix-alpine-3-17-issues.patch \
    && cd telldus-core \
    && mkdir /opt/telldus \
    && cmake . -DBUILD_LIBTELLDUS-CORE=ON \
        -DBUILD_TDADMIN=OFF -DBUILD_TDTOOL=OFF -DGENERATE_MAN=OFF \
        -DFORCE_COMPILE_FROM_TRUNK=ON \
        -DCMAKE_INSTALL_PREFIX:PATH=/opt/telldus \
    && make -j"$(nproc)" \
    && make install


FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG QEMU_CPU
ARG BUILD_FROM

##
# Install component packages
RUN \
    --mount=type=cache,target=/etc/apk/cache,sharing=locked,id=apk-cache-${BUILD_FROM} \
    apk add \
        bluez \
        bluez-deprecated \
        bluez-libs \
        confuse \
        curl \
        eudev-libs \
        ffmpeg \
        grep \
        hwdata-usb \
        imlib2 \
        iperf3 \
        libftdi1 \
        libgpiod \
        libpulse \
        libturbojpeg \
        libzbar \
        mariadb-connector-c \
        net-tools \
        nmap \
        openssh-client \
        p8-platform \
        pianobar \
        popt \
        pulseaudio-alsa \
        socat

WORKDIR /usr/src/

####
## Copy from pip builder
COPY --link --from=pip-install-builder /root/.local/ /root/.local/

# Copy from ssocr builder
COPY --link --from=ssocr-builder /opt/ssocr/ /usr/local/

# Copy from libcec builder
COPY --link --from=libcec-builder /opt/libcec/ /usr/local/
RUN python_version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')") \
    && echo "cec" > "/usr/local/lib/python${python_version}/site-packages/cec.pth"

# Copy from picotts builder
COPY --link --from=picotts-builder /opt/picotts/ /usr/local/

# Copy from Telldus builder
COPY --link --from=telldus-builder /opt/telldus/ /usr/local/

###
# Base S6-Overlay
COPY rootfs /
