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

#back up version for download
#check_version=`curl -sL https://api.github.com/repos/Arriven/db1000n/releases/latest | grep "tag_name" | cut -d ':' -f2 | sed -e 's/ "v//' | sed -e 's/".$//'`
#if ls | grep -q $check_version
#	then
#       		tput setaf 2; tput setb 6; echo "The latest version already downloaded and installed"
#	else
#		tput setaf 6; rm -rf db1000n* ; source <(curl https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh); mv db1000n ./db1000n_${check_version}; rm db1000n_${check_version}_*
#fi

#checking for installation
if ls | grep -q db1000n
then
	tput setaf 2; echo "Application already downloaded"
else
	tput setaf 6; source <(curl https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh); rm db1000n_*
fi

#running main script
function connect_db1000n {
if $use_proxy
then
	./db1000n -enable-self-update -self-update-check-frequency=1h -restart-on-update=false \
        	 --proxy '{{ join (split (get_url "https://raw.githubusercontent.com/porthole-ascend-cinnamon/proxy_scraper/main/proxies.txt") "\n") "," }}' 
else
        ./db1000n -enable-self-update -self-update-check-frequency=1h -restart-on-update=false&
fi

}

while true
do
	if hotspotshield status | grep -q 'disconnected'
	then 
		if pgrep db1000n > /dev/null
		then
			tput setaf 1; echo "disconnected from hotspotshield server"; echo "killing db1000n to restart connection to hotspotshield"; tput setaf 6;\
			pgrep -f db1000n | xargs kill -9; sleep 2s;  \
		fi 	
			tput setaf 1; echo "$(date +%T) connecting ru vpn"; hotspotshield connect $location; sleep 5s; \
			echo "starting new instance db1000n"; tput setaf 6; \
			connect_db100n
	else
		if $connected
		then
			if pgrep db1000n > /dev/null
			then
				tput setaf 2;echo "$(date +%T) hotspotshield still active and db1000n running";tput setaf 6; sleep  $timing
			else
				connect_db1000n
			fi
		else	
			sleep $timing
		fi
	fi	
done
