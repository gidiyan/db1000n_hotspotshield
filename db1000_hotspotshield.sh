#!/bin/bash

#script requires installed and configured hotspotshield VPN client
#для роботи скрипту необхідний встановленний та налаштований hotspotshield VPN

#script for automatic download newest version of db1000n and running it only if hotspotshield is active
#you can choose whatever server to connect to. to change server change RU to another country from country list availibaly by commend hotspotshield locations
#скрипт для автоматичного встановлення останньої версії db1000n та запуску тільки якщо hotspotshield під'єднаний до сервера.список локацій доступний по команді hotspotshield locations
#сервер можете вибрати будь-який,але найефективніше працювати з Росії. 
location=RU

#to get info that you are still connected to VPN server leave the line below without changes. else change to false
#щоб отримувати інформацію про стан з'єднання з VPN, залиште значення нижче без змін.щоб вимкнути вивід про стан підключення, змініть значення на false
connected=true #true are false 

#timing between checks if still connected to VPN server.put number in seconds
#як часто перевіряти з'єднання з VPN сервером.час в секундах
timing=10s

#if you don't want to use proxy leave the line unchanged. for using proxy change value to true
#якщо не хочете використовувати проксі, залиште значення без змін. для використання проксі змініть на true
use_proxy=false

#script

source <(curl https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh)

while true
do
	if hotspotshield status | grep -q 'disconnected'
		then 
			if pgrep db1000n 
			then
				tput setaf 1;echo "disconnected from hotspotshield server";echo "killing db1000n to restart connection to hotspotshield";tput setaf 6;\
				pgrep -f db1000n | xargs kill -9; sleep 2s;  \
			fi 	
				tput setaf 1;echo "$(date +%T) connecting ru vpn";hotspotshield connect $location; sleep 5s; \
				echo "starting new instance db1000n";tput setaf 6; \
				if $use_proxy
				then
					./db1000n --proxy '{{ join (split (get_url "https://raw.githubusercontent.com/porthole-ascend-cinnamon/proxy_scraper/main/proxies.txt") "\n") "," }}'& 
				else
					./db1000n&
				fi

else
			if $connected
			then
				tput setaf 1;echo "$(date +%T) hotspotshield still active";tput setaf 6; sleep  $timing
			else 
				sleep $timing
			fi
	fi	
done
