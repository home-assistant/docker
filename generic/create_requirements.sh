#!/usr/bin/env bashio

# MFA modules requirements (pip)
MFA_MODULES=(pyotp PyQRCode)

# Core components
COMPONENTS=(frontend stream tts recorder cloud zeroconf ssdp http updater mobile_app)

# IoT
COMPONENTS+=(zwave mqtt zha proxy ffmpeg esphome iftt html5)

# Featured Hubs
COMPONENTS+=(hue deconz homekit homematic ecobee xiaomi_miio xiaomi_aqara broadlink tradfri)

# Featured platforms
COMPONENTS+=(sonos doorbird netatmo nuki darksky yr apple_tv cast systemmonitor miflora)


REQUIREMENTS="homeassistant/requirements_default.txt"
touch ${REQUIREMENTS}

# MFA
for module in "${MFA_MODULES[@]}"; do
  echo "${module}" >> ${REQUIREMENTS}
done

# Components
for component in "${COMPONENTS[@]}"; do
    component_manifest="homeassistant/homeassistant/components/$component/manifest.json"
    jq --raw-output '.requirements | join("\n")' "${component_manifest}" >> ${REQUIREMENTS}
done
