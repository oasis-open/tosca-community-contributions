#!/bin/bash

docker inspect $container_id | jq ".[0].NetworkSettings.Networks[\"$macvlan\"].MacAddress"
