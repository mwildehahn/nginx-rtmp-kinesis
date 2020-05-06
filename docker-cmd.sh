#!/bin/bash

# turn on bash's job control
set -m

# Start nginx and put it in the background
nginx -g "daemon off;" &

# Start healthcheck
health-check

# Bring nginx back to the foreground
fg %1