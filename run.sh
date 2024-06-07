#!/bin/sh
docker-compose -f docker-compose-build.yml up
docker-compose rm -f
sudo rm -rf ./data/genesis_volume
docker-compose build
docker-compose up