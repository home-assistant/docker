#!/usr/bin/env bashio

# MFA modules requirements (pip)
MFA_MODULES=(pyotp PyQRCode)

# Core components
COMPONENTS=(frontend stream tts recorder cloud zeroconf ssdp http updater mobile_app ptvsd)

# IoT
COMPONENTS+=(zwave mqtt zha proxy ffmpeg esphome iftt html5 influxdb)

# Featured hubs
COMPONENTS+=(hue deconz homekit homematic ecobee xiaomi_miio xiaomi_aqara broadlink tradfri harmony knx wink wemo mysensors amcrest toon dyson tellstick)

# Featured platforms
COMPONENTS+=(sonos doorbird nuki darksky yr apple_tv cast miflora youtube_dl google_translate plex kodi yeelight lifx mystrom)

# Featured locals
COMPONENTS+=(systemmonitor cpuspeed fastdotcom speedtestdotnet)

# Featured clouds
COMPONENTS+=(netatmo homematicip_cloud icloud pushbullet tellduslive)


REQUIREMENTS="homeassistant/requirements_default.txt"
touch ${REQUIREMENTS}

# MFA
for module in "${MFA_MODULES[@]}"; do
    bashio::log.info "Add ${module}"
    echo "${module}" >> ${REQUIREMENTS}
done

# Components
for component in "${COMPONENTS[@]}"; do
    bashio::log.info "Prepare ${component}"
    component_manifest="homeassistant/homeassistant/components/${component}/manifest.json"
    jq --raw-output '.requirements | join("\n")' "${component_manifest}" >> ${REQUIREMENTS}
done
