ARG BUILD_FROM
FROM $BUILD_FROM

# Install core & build packages
RUN apk --no-cache add nginx

# Copy data
COPY rootfs /
