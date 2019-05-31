ARG BUILD_ARCH
FROM homeassistant/${BUILD_ARCH}-homeassistant-base:2.1

ARG BUILD_VERSION

WORKDIR /usr/src

## Install Home Assistant
# hadolint ignore=DL3013,SC2086
RUN git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && rm -rf homeassistant/.git \
    && default_components="home-assistant-frontend= sqlalchemy= netdisco= zeroconf= hass-nabucasa= aiohttp_cors= av= distro= xmltodict= PyNaCl="; \
        for component in ${default_components}; do \
            grep -E "^${component}" homeassistant/requirements_all.txt >> homeassistant/requirements_default.txt; \
        done \
    && pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} \
        -r homeassistant/requirements_default.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} -e ./homeassistant

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
