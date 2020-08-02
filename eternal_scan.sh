# Change IP or PORT. Ranges also work

ip=""
port="445 3389"

ALL=`nmap -A --script=smb-vuln* -p $port $ip | tr " " "\n" | egrep -o -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}$" -e "CVE-2017-014[3-8]" -e ^"[0-9]{1,5}/"`

# If you want to save the entire scan result.
# Comment out line 6 and uncomment lines 11 13

#nmap -A --script=smb-vuln* -p $port $ip > result.txt

#ALL=`cat result.txt | tr " " "\n" | egrep -o -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}$" -e "CVE-2017-014[3-8]" -e ^"[0-9]{1,5}/"`

if [[ $? -eq 0 ]]
then
	CURRENT_CVE=" "
	for ARG in $ALL
	do
		TEMP=`echo $ARG | egrep "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
		if [[ $? -eq 0 ]]				# IP
		then
			IP=$TEMP
			if [[ $IP != $CURRENT_IP ]]
			then
				if [[ "$CURRENT_CVE" == "" ]]
				then
					echo "|	$CURRENT_IP		|	Nothing		|"
				fi
				echo " ------------------------------------------------------- "
				CURRENT_IP=$IP
				CURRENT_CVE=""
			fi
		else
			TEMP=`echo $ARG | egrep ^"[0-9]{1,5}/"`
			if [[ $? -eq 0 ]]			# PORT
			then
				PORT=`echo $TEMP | tr '/' ' '`
				if [[ $PORT != $CURRENT_PORT ]]
				then
					CURRENT_CVE=""
					CURRENT_PORT=$PORT
				fi
			else
				TEMP=`echo $ARG | egrep "CVE-2017-014[3-8]"`
				if [[ $? -eq 0 ]]		# CVE
				then
					CVE=$TEMP
					echo $CURRENT_CVE | grep -o $CVE &>/dev/null
					if [[ $? -eq 1 ]]
					then
						echo "|	$IP:$PORT	|	$CVE	|"	
					fi
					CURRENT_CVE+=$CVE" "
				fi
			fi
		fi
	done
	if [[ "$CURRENT_CVE" == "" ]]
	then
		echo "|	$CURRENT_IP		|	Nothing		|"
	fi
	echo " ------------------------------------------------------- "
fi
