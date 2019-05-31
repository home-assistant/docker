ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION
ARG BUILD_ARCH

WORKDIR /usr/src

## Install Home Assistant
# hadolint ignore=DL3013
RUN git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && rm -rf homeassistant/.git \
    && pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} -e ./homeassistant

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
