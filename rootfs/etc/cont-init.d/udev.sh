#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start udev service if env USING_UDEV is true
# ==============================================================================
if ! bashio::var.true "${USING_UDEV+x}"; then
    bashio::exit.ok
fi

bashio::log.info "Setup udev backend inside container"
udevd --daemon

bashio::log.info "Update udev information"
if udevadm trigger; then
    udevadm settle || true
else
    bashio::log.warning "Triggering of udev rules fails!"
fi
