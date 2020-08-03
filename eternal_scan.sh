# Change IP or PORT. Range is not working now.

ip=""
port="445 3389"

for IP in $ip
do
	echo " ------------------------------------------------------- "
	CURRENT_CVE=" "
	for PORT in $port
	do
		CURRENT_CVE=" "
		ALL=`nmap -A --script=smb-vuln-ms17-010.nse -p $PORT $IP | tr " " "\n" | egrep -o "CVE-2017-0143"`
		if [[ $? -eq 0 ]]
		then
			for ARG in $ALL
			do
				CVE=`echo $ARG | egrep "CVE-2017-0143"`
				echo $CURRENT_CVE | grep -o $CVE &>/dev/null
				if [[ $? -eq 1 ]]
				then
					echo "|	$IP:$PORT	|	$CVE	|"	
				fi
				CURRENT_CVE+=$CVE" "
			done
		else
			echo "|	$IP:$PORT	|	Nothing		|"
		fi
	done
done
echo " ------------------------------------------------------- "
