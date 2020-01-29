ARG BUILD_FROM
FROM $BUILD_FROM

# Install core & build packages
RUN apk --no-cache add nginx

# Copy data
COPY www/ /usr/share/www/
COPY data/nginx.conf /etc/nginx/
COPY data/run.sh /

CMD ["/run.sh"]
