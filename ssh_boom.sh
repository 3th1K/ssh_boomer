#!/usr/bin/bash

#########################INSTALLATION OF REQUIREMENTS########################################

apt install expect nmap sshpass xterm openssh-client -y
echo

#########################CHOICE OF MAKIG OR SELECTING IP LIST################################

read -p "Have you made the ip list? y/n : " y_n
echo

#########################SCAN & MAKE IP LIST OR SELECT ONE###################################

if [ $y_n == "y" ]
then
	read -p 'Enter The ip-list File : ' file_name
	echo
elif [ $y_n == "n" ]
then
	read -p "How Many Ip Ranges You Want (IP_ranges=>192.168.0.*) : " ip_range
	echo
	for i in `seq 1 $ip_range`
	do
		echo -e "Enter The " $i "no. Ip Range : \c"
		read singe_ip
		echo
		echo "Please Wait, Scan In Progress"
		echo
		xxx=`nmap -Pn -oG raw_ip_addr -p 22 $singe_ip`
		cat raw_ip_addr | grep open | cut -d ' ' -f 2 >> ip_list
	done
	file_name=ip_list
else
	echo "Wrong Choice, Exitting "
	echo
	exit
fi

#####################COUNTING NO. OF VULNARABLE IP'S########################################

count=0
while read ip
do
	count=$((count+1))
done < $file_name
echo "Found $count Vulnarable IP's"
echo

###############################INPUT USERNAME AND PASSWORD####################################

read -p 'Enter The User-Name : ' user_name
echo
read -sp 'Enter The Password : ' pass
echo

#################################SIMPLE SSH LOGIN#############################################

function ssh_login()
{
	while read ip
	do
		xterm -e sshpass -p $pass ssh -o StrictHostKeyChecking=No ${user_name}@$ip &
	done < $file_name
}

##############SSH LOGIN WITH DIRECT COMMAND EXECUTION USING EXPECT CODE########################

function ssh_command()
{
	read -p "Give The Commands To Execute : " commands
	echo
	while read ip
        do
        	xterm -e expect -f ssh_boom_expect.exp ${user_name} $ip $pass "$commands" &
	done < $file_name
}

#############CHOOSING OPTIONS FOR LOGIN TYPE AND CHECKING FILE EXISTENCY#######################

if [ -e $file_name ]
then
	if [ -s $file_name ]
	then
		read -p "Choose <1>Simple Login or <2>Direct Command Execution : " choice
		echo
		if ((choice == 1))
		then
			ssh_login
		elif ((choice == 2))
		then
			ssh_command
		fi
	else
		echo "IP LIST Is Empty"
		rm ip_list raw_ip_addr
		exit
	fi
else
	echo "File Containing IP LIST Not Found"
	rm ip_list raw_ip_addr
exit
fi
rm ip_list raw_ip_addr
