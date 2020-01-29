#!/bin/bash
set -e

exec nginx -c /etc/nginx/nginx.conf < /dev/null
