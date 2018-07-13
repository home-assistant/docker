#!/bin/bash
set -e

exec nginx -c /etc/nginx.conf < /dev/null
