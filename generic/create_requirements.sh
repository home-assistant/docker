#!/usr/bin/env bashio

# MFA modules requirements (pip)
MFA_MODULES=(pyotp PyQRCode)

# Core components
COMPONENTS=(frontend stream tts recorder cloud zeroconf ssdp http updater mobile_app)

# IoT
COMPONENTS+=(zwave mqtt zha proxy ffmpeg)

# Featured
COMPONENTS+=(hue deconz esphome homekit)


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
