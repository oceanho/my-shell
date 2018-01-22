#!/bin/bash

# start ssh service
service ssh start

# Execute other command by docker-engine
exec "$@"