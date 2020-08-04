
ip=""
port="445"

if [[ $1 == "-h" ]]
then
	echo "  -ip     sets scanned ip addresses"
	echo "  -p      sets ports for scanning by default 445"
	echo -e "\n  PS:     You can specify ranges, just like nmap\n"

	echo "  EXAMPLES:"
	echo "          ./eternal_scan.sh -ip 127.0.0.1"
	echo "          ./eternal_scan.sh -ip 127.0.*.* -p 445,666"
	echo "          ./eternal_scan.sh -ip 127.0.0.1 127.0.0.445-500"
	exit 1
fi

function print_line()
{
	len=24
	echo -n "|      $1:$2"
	n=`echo -n $1:$2 | wc -m`
	while (( len-- > n ))
	do
		echo -n " "
	done

	len=17
	echo -n "|       $3"
	n=`echo -n $3 | wc -m`
	while (( len-- > n ))
	do
		echo -n " "
	done
	echo "|"
}

shift
while [[ $1 != '-p' ]] && [ $1 ]
do
	ip+=$1" "
	shift
done

if [[ $1 == "-p" ]]
then
	port=""
	while [ $2 ]
	do
		port+=$2" "
		shift
	done
fi

RESULT=`nmap -A --script=smb-vuln-ms17-010.nse -p $port $ip | egrep -o -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}$" -e "CVE:CVE-2017-0143" -e ^"[0-9]{1,5}/" -e "microsoft-ds"`
RESULT+=" 1.1.1.1"

CVE=" "
for ALL in $RESULT
do
    TEMP=`echo $ALL | egrep -o -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
	if [[ $? -eq 0 ]]
	then
		if [[ "$CVE" == "" ]]
		then
			echo " ------------------------------------------------------- "
			for VAL in $PORT
			do
				VAL=`echo $VAL | egrep -o ^"[0-9]{1,5}"`
				if [[ "$VAL" != "" ]]
				then
					print_line $IP $VAL "Nothing"
				fi
            done
		fi
		IP=$TEMP
		CVE=""
		PORT=""
	else
		TEMP=`echo $ALL | egrep -o ^"[0-9]{1,5}/"`
		if [[ $? -eq 0 ]] 
		then
			PORT+=" "`echo $TEMP`
        elif [[ "$ALL" == "microsoft-ds" ]]
        then
            PORT+="microsoft-ds "
		else
			CVE=`echo $ALL | egrep -o "CVE-2017-0143"`
			echo " ------------------------------------------------------- "
            for VAL in $PORT
            do
                if [[ `echo $VAL | egrep -o ^"[0-9]{1,5}/"` != "" ]] && [[ `echo $VAL | egrep "microsoft-ds"` != "" ]]
                then
					print_line $IP `echo $VAL | egrep -o ^"[0-9]{1,5}"` $CVE
                elif [[ `echo $VAL | egrep "microsoft-ds"` != "microsoft-ds" ]]
				then
					print_line $IP  `echo $VAL | tr "/" " "` "Nothing"
                fi
            done
		fi
	fi
done
echo " ------------------------------------------------------- "
