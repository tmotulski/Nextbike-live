#!/bin/bash
while true
do
	curl https://nextbike.net/maps/nextbike-live.xml > $(date +"%Y-%m-%dT%H_%M_%S").xml
	sleep 10m
done &