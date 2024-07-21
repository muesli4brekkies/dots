#!/bin/bash 
last=$(cat /tmp/cpulast)
last_sum=$(cat /tmp/cpulastsum)
now=($(head -n1 /proc/stat)) 
now="${now[@]:1}" 
sum=$((${now// /+})) 
delta=$((sum - last_sum)) 
idle=$((now[4]- last)) 
used=$((delta - idle)) 
usage=$((100 * used / delta)) 
echo $((now[4])) > "/tmp/cpulast"
echo $sum > "/tmp/cpulastsum"
max=0
for f in $(ls -I "cooling*" /sys/class/thermal | grep thermal)
	do 
	this=$(cat /sys/class/thermal/$f/temp)
	if [[ $max -lt $this ]]
		then max=$this
	fi
done     
temp=$(($max / 1000))
echo -n $usage $temp
