ARG BUILD_ARCH
FROM homeassistant/amd64-homeassistant-base:2.1 AS installer

ARG BUILD_VERSION
WORKDIR /usr/src

## Setup Home Assistant
# hadolint ignore=DL3013
RUN git clone --depth 1 --branch "${BUILD_VERSION}" https://github.com/home-assistant/home-assistant homeassistant \
    && rm -rf homeassistant/.git \
    && pip3 install --no-cache-dir --find-links "${WHEELS_LINKS}" \
        -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 freeze > homeassistant/homeassistant/package_constraints.txt


FROM homeassistant/${BUILD_ARCH}-homeassistant-base:2.1

COPY --from=installer /usr/src/homeassistant /usr/src/homeassistant
COPY create_requirements.sh /usr/src/
WORKDIR /usr/src

## Install Home Assistant
# hadolint ignore=DL3013
RUN ./create_requirements.sh \
    && pip3 install --no-cache-dir --find-links "${WHEELS_LINKS}" \
        -r requirements_default.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --find-links "${WHEELS_LINKS}" -e ./homeassistant \
    && rm -f create_requirements.sh

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
