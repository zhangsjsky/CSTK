#!/bin/env bash

usage(){
  cat << EOF
Usage: $(basename $0) PID
Example: $(basename $0) 12345
Option:
    -h  Show this help information
EOF
  exit 0
}

while getopts "hi:a:" OPTION
do
  case $OPTION in
    h) usage;;
    ?) usage;;
  esac
done
shift $((OPTIND - 1))

[ -z "$1" ] && usage

pid=$1

while [ $(ps -ef -o pid | grep -w $pid | wc -l) -eq 1 ];do
  sleep 2
done
