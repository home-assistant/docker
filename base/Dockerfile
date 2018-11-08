ARG BUILD_FROM
FROM $BUILD_FROM

####
# Install core
RUN apk add --no-cache \
        bsd-compat-headers \
        libgcc \
        libstdc++ \
        libpng \
        tiff \
        libjpeg \
        libjpeg-turbo \
        libressl \
        musl \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h

####
## Build library
WORKDIR /usr/src/

# ssocr
ARG SSOCR_VERSION=5e47e26b125a1a13bc79de93a5e87dd0b51354ca
RUN apk add --no-cache \
        imlib2 \
    && apk add --no-cache --virtual .build-dependencies \
        git gcc make musl-dev imlib2-dev \
    && git clone --depth 1 https://github.com/auerswal/ssocr \
    && cd ssocr \
    && git checkout $SSOCR_VERSION \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/ssocr

# OpenCV/scipy
ARG OPENCV_VERSION=3.4.2
RUN apk add --no-cache \
        libwebp ffmpeg-libs libgfortran libdc1394 jasper-libs zlib \
        lapack \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ musl-dev cmake make ncurses linux-headers \
        gfortran ffmpeg-dev libwebp-dev lapack-dev \
        git libpng-dev libjpeg-turbo-dev tiff-dev \
        jasper-dev libdc1394-dev zlib-dev \
    && pip3 install --no-cache-dir numpy scipy \
    && git clone --depth 1 -b $OPENCV_VERSION https://github.com/opencv/opencv \
    && cd opencv \
    && mkdir -p build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DWITH_LAPACK=OFF -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF \
        -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/opencv

# Dlib
ARG DLIB_VERSION=19.14.0
RUN apk add --no-cache --virtual .build-dependencies \
        cmake ncurses make g++ git \
    && pip3 install --no-cache-dir dlib==$DLIB_VERSION \
    && apk del .build-dependencies

# OpenALPR & Log4Cplus
ARG LOGCPLUS_VERSION=REL_1_2_0
ARG OPENALPR_VERSION=v2.3.0
RUN apk add --no-cache \
        tesseract-ocr \
    && apk add --no-cache --virtual .build-dependencies \
        cmake ncurses make g++ tesseract-ocr-dev \
        git autoconf automake libtool \
    && git clone --depth 1 -b $LOGCPLUS_VERSION https://github.com/log4cplus/log4cplus \
    && cd log4cplus \
    && autoreconf -f -i \
    && ./configure --with-working-locale \
    && make \
    && make install \
    && cd /usr/src \
    && rm -rf /usr/src/log4cplus \
    && git clone --depth 1 -b $OPENALPR_VERSION https://github.com/openalpr/openalpr \
    && cd openalpr/src \
    && mkdir -p build \
    && cd build \
    && cmake ../ -DWITH_TESTS=FALSE -DWITH_BINDING_JAVA=FALSE -DWITH_BINDING_PYTHON=FALSE -DWITH_BINDING_GO=FALSE -DWITH_DAEMON=FALSE -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/openalpr

# TensorFlow Deps
ARG HDF5_VERSION=1.8.21
RUN apk add --no-cache \
        freetype musl openblas \
    && apk add --no-cache --virtual=.build-dependencies \
        curl g++ musl-dev autoconf automake libtool file make \
    && curl -SL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz | tar xzf - \
    && cd /usr/src/hdf5-$HDF5_VERSION \
    && autoreconf -f -i \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/hdf5-$HDF5_VERSION

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
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus

##
# Install component packages
RUN apk add --no-cache \
    ffmpeg \
    nmap \
    libcec \
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
RUN apk add --no-cache \
        mariadb-connector-c postgresql-libs freetds libffi \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ musl-dev make \
        mariadb-dev postgresql-dev freetds-dev libffi-dev \
    && pip3 install --no-cache-dir cython \
    && pip3 install --no-cache-dir mysqlclient psycopg2 \
    && pip3 install --no-cache-dir https://github.com/wayfair/pymssql/archive/v2.1.3.0.0.1.zip \
    && pip3 install --no-cache-dir \
        cchardet==2.1.1 \
        uvloop==0.11.3 \
        brotlipy==0.7.0 \
    && apk del .build-dependencies

###
# Setup entry point for udevd
COPY entry.sh /bin/
RUN apk add --no-cache eudev \
    && chmod a+x /bin/entry.sh

ENTRYPOINT ["/bin/entry.sh"]
