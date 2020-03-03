#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start udev service
# ==============================================================================
udevd --daemon

bashio::log.info "Update udev information"
udevadm trigger
udevadm settle
