ARG BUILD_FROM
FROM $BUILD_FROM

# Install core & build packages
RUN apk --no-cache add nginx

# Copy data
COPY www/ /usr/share/www/
COPY nginx.conf /etc/
COPY entry.sh /usr/bin/entry.sh

# Modify entry point
ENTRYPOINT ["/usr/bin/entry.sh"]
