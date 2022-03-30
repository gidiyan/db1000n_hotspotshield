#!/bin/bash
timing=30s
while true
do
        if hotspotshield status | grep -q 'disconnected'
        then 
        	tput setaf 1; echo "disconnected from hotspotshield server"; tput setaf 6;
        	tput setaf 1; echo "$(date +%T) connecting ru vpn"; hotspotshield connect RU; sleep 5s; \
        else
	        tput setaf 2;echo "$(date +%T) hotspotshield still active";tput setaf 6;sleep $timing
        fi
done

