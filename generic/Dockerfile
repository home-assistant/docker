ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION

WORKDIR /usr/src

## Install Home Assistant
# hadolint ignore=DL3013
RUN git clone --depth 1 --branch $BUILD_VERSION https://github.com/home-assistant/home-assistant homeassistant \
    && rm -rf homeassistant/.git \
    && default_components="home-assistant-frontend netdisco zeroconf hass-nabucasa aiohttp_cors"; \
        for component in ${default_components}; do \
            grep ${component} homeassistant/requirements_all.txt >> homeassistant/requirements_default.txt; \
        done \
    && pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} \
        -r homeassistant/requirements_default.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --find-links ${WHEELS_LINKS} -e ./homeassistant

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
