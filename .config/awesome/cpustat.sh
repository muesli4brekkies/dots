#!/bin/bash
read last last_sum </tmp/cpustat
now=($(head -n1 /proc/stat))
arr=${now[@]:1}
sum=$((${arr// /+}))
delta=$((sum - last_sum))
idle=$((now[4] - last))
used=$((delta - idle))
usage=$((100 * used / delta))
temp=$(($(cat $(find /sys/class/thermal -printf "/sys/class/thermal/%f/temp ") | sort -n | tail -n 1) / 1000))
echo $((now[4])) $sum >"/tmp/cpustat"
echo -n $usage $temp
