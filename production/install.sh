#!/usr/bin/env bash
cd $(dirname $0)
set -eE
PRODUCTION_ENV_DIR=~/Projects/Octoblu/the-stack-env-production
rsync -avh --progress ./deployment-files/* $PRODUCTION_ENV_DIR


npm i -g deployinate-configurator

dplcfg service forwarder-service -d service-files

STACK_SERVICES_DIR=~/Projects/Octoblu/the-stack-services/services.d/forwarder-service
rsync -avh --progress ./service-files/* $STACK_SERVICES_DIR

echo "\n\n\n"

echo "Alright, I'm not going to do the rest for you, because I could be wrong and it could be dangerous. But you need to:"

echo "get octoblu/tools from brew if you don't have them"

echo "run 'minorsync load forwarder-service'"
echo "run 'majorsync load forwarder-service'"
echo "run 'vulcansync load forwarder-service'"
echo "run quayify forwarder-service"
echo "Add a route to forwarder-service.octoblu.com in Route 53"
echo "in fleetmux:"
echo "run 'fleetctl submit $STACK_SERVICES_DIR/*.service'"
echo "do this over and over until you don't get any more output"

echo "commit the changes to the-stack-env-production"
echo "commit the changes to the-stack-services"

echo "...and do the quay stuff, and everything else you normally do."
