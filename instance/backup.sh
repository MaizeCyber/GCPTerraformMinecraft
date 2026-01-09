#!/bin/bash
screen -r mcs -X stuff '/save-all\n/save-off\n'
/usr/bin/gcloud storage cp -R ${BASH_SOURCE%/*}/world gs://potato-swirl-landbridge-deaf/$(date "+%Y%m%d-%H%M%S")-world/world
screen -r mcs -X stuff '/save-on\n'
