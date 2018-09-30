#!/bin/env bash

usage(){
  cat << EOF
Usage: $(basename $0) -i minLoadAve -a maxLoadAve PID
Example: $(basename $0) -i 15 -a 48 12345
Option:
    -i  INT The minimal load average below which the COMMAND will be continued[5]
    -a  INT The maximal load average above which the COMMAND will be paused[11]
    -h      Show this help information
EOF
  exit 0
}

maxLoadAve=11
minLoadAve=5

while getopts "hi:a:" OPTION
do
  case $OPTION in
    h) usage;;
    i) minLoadAve=$OPTARG;;
    a) maxLoadAve=$OPTARG;;
    ?) usage;;
  esac
done
shift $((OPTIND - 1))

[ -z "$1" ] && usage

pid=$1
isStop=0

while [ $(ps -ef -o pid | grep -w $pid | wc -l) -eq 1 ];do
  load=$(uptime | grep -oP "load average:.+" | cut -d ' ' -f4 | cut -d ',' -f1)
  if [ $(echo "$load>$maxLoadAve" | bc) -eq 1 ];then
    if [ $isStop -eq 0 ];then
      kill -SIGSTOP $pid && isStop=1
    fi
  fi
  if [ $(echo "$load<$minLoadAve" | bc) -eq 1 ];then
    if [ $isStop -eq 1 ];then
      kill -SIGCONT $pid && isStop=0
    fi
  fi
  sleep 2
done
