ARG BUILD_FROM
FROM ${BUILD_FROM}:4.2

WORKDIR /usr/src

## Setup Home Assistant
COPY homeassistant homeassistant
RUN pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -e ./homeassistant \
    && python3 -m compileall homeassistant/homeassistant

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
