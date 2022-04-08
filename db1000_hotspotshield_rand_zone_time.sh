#!/bin/bash

#script requires installed and configured hotspotshield VPN client
#для роботи скрипту необхідний встановленний та налаштований hotspotshield VPN

#script for automatic download newest version of db1000n and running it only if hotspotshield is active
#you can choose whatever server to connect to. to change server change RU to another country from country list availibaly by commend hotspotshield locations
#скрипт для автоматичного встановлення останньої версії db1000n та запуску тільки якщо hotspotshield під'єднаний до сервера.список локацій доступний по команді hotspotshield locations
#сервер можете вибрати будь-який,але найефективніше працювати з Росії. 
location=(RU BY AZ GE)

#продолжительность скрипта
runtime="10 minute"

#to get info that you are still connected to VPN server leave the line below without changes. else change to false
#щоб отримувати інформацію про стан з'єднання з VPN, залиште значення нижче без змін.щоб вимкнути вивід про стан підключення, змініть значення на false
connected=true #true are false 

#timing between checks if still connected to VPN server.put number in seconds
#як часто перевіряти з'єднання з VPN сервером.час в секундах
timing=10s

#if you don't want to use proxy leave the line unchanged. for using proxy change value to true
#якщо не хочете використовувати проксі, залиште значення без змін. для використання проксі змініть на true
use_proxy=false


#Procedure:
#1) git clone https://github.com/gidiyan/db1000n_hotspotshield.git
#2) cd db1000n_hotspotshield
#3) ./db1000_hotspotshield.sh
	
EXE=db1000n	

#running main script
if pgrep "$EXE" > /dev/null
   then
	pgrep -f db1000n | xargs kill 
fi

function connect {
if $use_proxy
then
	./db1000n -enable-self-update -self-update-check-frequency=1h -restart-on-update=false \
        	 --proxy '{{ join (split (get_url "https://raw.githubusercontent.com/porthole-ascend-cinnamon/proxy_scraper/main/proxies.txt") "\n") "," }}'&
else
        ./db1000n -enable-self-update  -self-update-check-frequency=1h -restart-on-update=false&
fi

}
echo "HI"

while true
do
	endtime=$(date -ud "$runtime" +%s)
	while [[ $(date -u +%s) -le $endtime ]]
	do
		if ! $use_proxy 
		then
			if hotspotshield status | grep -q 'disconnected'
			then 
				if pgrep "$EXE" > /dev/null
				then
					tput setaf 3; echo "disconnected from hotspotshield server"; echo "killing db1000n to restart connection to hotspotshield"; tput setaf 6;\
					pgrep -f "$EXE" | xargs kill -9; sleep 2s;  \
				fi 	
				let "die1 = RANDOM % ${#location[*]}"
					tput setaf 3; echo "$(date +%T) connecting  ${location[$die1]} vpn"; hotspotshield connect ${location[$die1]}; sleep 10s; \
					echo "starting new instance $EXE"; tput setaf 6; \
					connect
			else
				if $connected
				then
					if pgrep "$EXE" > /dev/null
					then
						tput setaf 2;echo "$(date +%T) hotspotshield still active and $EXE running";tput setaf 6; sleep  $timing
					else
						echo "starting new instance $EXE"; tput setaf 6; \
						connect
					fi
				else	
					sleep $timing
				fi
			fi
		else
			if $connected
					then
							if pgrep "$EXE" > /dev/null
							then
									tput setaf 2;echo "$(date +%T) using proxy and $EXE running";tput setaf 6; sleep  $timing
							else
								 echo "starting new instance $EXE"; tput setaf 6; \
					connect
							fi
					else
							sleep $timing
					fi
		fi	
	done
	tput setaf 3; echo "$(date +%T) disconnecting from hotspotshield server"; hotspotshield disconnect
done
