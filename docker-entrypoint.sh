#!/usr/bin/env sh
set -eu

# Debug gstreamer
ulimit -c unlimited

envsubst '${AWS_ACCESS_KEY} ${AWS_SECRET_KEY} ${AWS_REGION}' < /opt/bin/kvs-producer.template > /opt/bin/kvs-producer && rm /opt/bin/kvs-producer.template
chmod +x /opt/bin/kvs-producer

exec "$@"