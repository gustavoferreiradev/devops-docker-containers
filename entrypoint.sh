#!/bin/sh
corepack enable
corepack prepare yarn@4.9.2 --activate
exec "$@"
