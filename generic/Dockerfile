ARG BUILD_ARCH
FROM homeassistant/amd64-homeassistant-base:2.2 AS installer

ARG BUILD_VERSION
WORKDIR /usr/src

## Setup Home Assistant
# hadolint ignore=DL3013
RUN git clone --depth 1 --branch "${BUILD_VERSION}" https://github.com/home-assistant/home-assistant homeassistant \
    && rm -rf homeassistant/.git \
    && cp homeassistant/requirements_all.txt homeassistant/requirements_freeze.txt \
    && sed -i "s|# pytradfri|pytradfri|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# pybluez|pybluez|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# bluepy|bluepy|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# beacontools|beacontools|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# RPi.GPIO|RPi.GPIO|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# raspihats|raspihats|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# rpi-rf|rpi-rf|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# blinkt|blinkt|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# fritzconnection|fritzconnection|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# pyuserinput|pyuserinput|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# evdev|evdev|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# smbus-cffi|smbus-cffi|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# i2csense|i2csense|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# python-eq3bt|python-eq3bt|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# pycups|pycups|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# homekit|homekit|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# decora_wifi|decora_wifi|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# decora|decora|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# PySwitchbot|PySwitchbot|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# pySwitchmate|pySwitchmate|g" homeassistant/requirements_freeze.txt \
    && sed -i "s|# face_recognition|face_recognition|g" homeassistant/requirements_freeze.txt \
    && sed -i -E "/^(#.*)$/d" homeassistant/requirements_freeze.txt \
    &&  xargs -t -n1 -P9 pip download --dest .cache --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -c homeassistant/homeassistant/package_constraints.txt < homeassistant/requirements_freeze.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links .cache \
        -r homeassistant/requirements_freeze.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 freeze > homeassistant/homeassistant/package_constraints.txt \
    && rm -rf .cache


FROM homeassistant/${BUILD_ARCH}-homeassistant-base:2.2

WORKDIR /usr/src
COPY --from=installer /usr/src/homeassistant /usr/src/homeassistant
COPY create_requirements.sh /usr/src/

## Install Home Assistant
# hadolint ignore=DL3013
RUN ./create_requirements.sh \
    &&  xargs -t -n1 -P9 pip download --dest .cache --no-deps --no-index --only-binary=:all: \
        --find-links "${WHEELS_LINKS}" < homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links .cache/ \
        -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links .cache/ \
        -e ./homeassistant \
    && rm -rf create_requirements.sh .cache

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
