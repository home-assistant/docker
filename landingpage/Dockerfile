ARG BUILD_ARCH
FROM homeassistant/${BUILD_ARCH}-base:3.8

# Add env
ENV LANG C.UTF-8

# Install core & build packages
RUN apk --no-cache add nginx

# Copy data
COPY www/ /usr/share/www/
COPY nginx.conf /etc/
COPY entry.sh /usr/bin/entry.sh

# Modify entry point
ENTRYPOINT ["/usr/bin/entry.sh"]
