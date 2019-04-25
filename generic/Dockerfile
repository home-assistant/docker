ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION

## Install Home Assistant
# hadolint ignore=DL3013
RUN apk add --no-cache \
        bluez-libs eudev-libs libxslt libxml2 cups-libs \
        libffi openssl gmp mpfr3 mpc1 ffmpeg-libs \
    && apk add --no-cache --virtual .build-dependencies \
        gcc g++ musl-dev cmake make git linux-headers \
        bluez-dev libffi-dev openssl-dev glib-dev eudev-dev \
        libxml2-dev libxslt-dev libpng-dev libjpeg-turbo-dev tiff-dev \
        autoconf automake cups-dev linux-headers gmp-dev mpfr-dev mpc1-dev \
        ffmpeg-dev \
    && git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && sed -i "s|# pytradfri|pytradfri|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pybluez|pybluez|g" homeassistant/requirements_all.txt \
    && sed -i "s|# bluepy|bluepy|g" homeassistant/requirements_all.txt \
    && sed -i "s|# beacontools|beacontools|g" homeassistant/requirements_all.txt \
    && sed -i "s|# RPi.GPIO|RPi.GPIO|g" homeassistant/requirements_all.txt \
    && sed -i "s|# raspihats|raspihats|g" homeassistant/requirements_all.txt \
    && sed -i "s|# rpi-rf|rpi-rf|g" homeassistant/requirements_all.txt \
    && sed -i "s|# blinkt|blinkt|g" homeassistant/requirements_all.txt \
    && sed -i "s|# fritzconnection|fritzconnection|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pyuserinput|pyuserinput|g" homeassistant/requirements_all.txt \
    && sed -i "s|# evdev|evdev|g" homeassistant/requirements_all.txt \
    && sed -i "s|# smbus-cffi|smbus-cffi|g" homeassistant/requirements_all.txt \
    && sed -i "s|# i2csense|i2csense|g" homeassistant/requirements_all.txt \
    && sed -i "s|# python-eq3bt|python-eq3bt|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pycups|pycups|g" homeassistant/requirements_all.txt \
    && sed -i "s|# homekit|homekit|g" homeassistant/requirements_all.txt \
    && sed -i "s|# decora_wifi|decora_wifi|g" homeassistant/requirements_all.txt \
    && sed -i "s|# decora|decora|g" homeassistant/requirements_all.txt \
    && sed -i "s|# PySwitchbot|PySwitchbot|g" homeassistant/requirements_all.txt \
    && sed -i "s|# pySwitchmate|pySwitchmate|g" homeassistant/requirements_all.txt \
    && export MAKEFLAGS="-j$(nproc)" \
    && pip3 install --no-cache-dir -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir ./homeassistant \
    && apk del .build-dependencies \
    && cp -f homeassistant/requirements_all.txt /root/ \
    && rm -r homeassistant

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
