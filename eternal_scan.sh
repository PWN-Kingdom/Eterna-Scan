# Change IP or PORT. Range is not working now.

ip=""
port="445 3389"

for IP in $ip
do
	echo " ------------------------------------------------------- "
	for PORT in $port
	do
		CVE=`nmap -A --script=smb-vuln-ms17-010.nse -p $PORT $IP | egrep -o "CVE-2017-0143"`
		if [[ $? -eq 0 ]]
		then
			echo "|	$IP:$PORT 	|	`echo $CVE | tr " " "\n" | sort -u`	|"
		else
			echo "|	$IP:$PORT 	|	Nothing		|"
		fi
	done
done
echo " ------------------------------------------------------- "
