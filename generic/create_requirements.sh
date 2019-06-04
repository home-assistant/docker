#!/usr/bin/env bashio

# MFA modules requirements (pip)
MFA_MODULES=(pyotp PyQRCode)

# Core components
COMPONENTS=(frontend stream tts recorder cloud zeroconf ssdp http updater mobile_app ptvsd)

# IoT
COMPONENTS+=(zwave mqtt zha proxy ffmpeg esphome ifttt html5 influxdb)

# Featured hubs
COMPONENTS+=(hue homekit ecobee xiaomi_miio xiaomi_aqara broadlink tradfri harmony knx wink wemo mysensors amcrest toon dyson)

# Featured platforms
COMPONENTS+=(sonos doorbird nuki apple_tv cast miflora media_extractor google_translate plex kodi yeelight lifx mystrom)

# Featured locals
COMPONENTS+=(systemmonitor cpuspeed fastdotcom speedtestdotnet iperf3 nmap_tracker)

# Featured weather
COMPONENTS+=(darksky yr openweathermap)

# Featured add-ons
COMPONENTS+=(pi_hole tellstick homematic deconz)

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
