#!/bin/env bash

export LC_COLLATE=C

field1=1
field2=1
fieldSeparater="-"
inputDelimiter="\t"
joinDelimiter="|"
outputDelimiter="\t"

usage(){
    cat <<EOF
Usage: $(basename $0) OPTIONS [-1 field1] [-2 fields2] input1.tsv [input2.tsv]
Note: input2.tsv can be omitted or be a "-" to input the data from STDIN.
      when input1.tsv is a "-" (i.e. from STDIN), input2.tsv must be specified.
Option:
    -1|field1           STR  The field in input1.tsv used when joining[$field1]
                             Refer to the -1 option of linux join command
    -2 field2           STR  The field in input2.tsv used when joining[$field2]
    -i|inputDelimiter   STR  The delimiter of your input file[\t]
    -j|joinDelimiter    STR  The delimiter used by linux join commond (i.e. the -t option of join command)[|]
    -o|outputDelimiter  STR  The delimiter of the output[\t]
    -a|unpairedFile     INT  Also print unpairable lines from file INT (1, 2)
EOF
}



shortOptions="1:2:i:j:o:a:"
longOptions="field1:,field2::,inputDelimiter:,joinDelimiter:,outputDelimiter:,unpairedFile:"
eval set -- $(getopt -n $(basename $0) -a -o $shortOptions -l $longOptions -- "$@")
while [ -n "$1" ];do
    case $1 in
        -1|--field1)           field1=$2;shift;;
        -2|--field2)           field2=$2;shift;;
        -i|--inputDelimiter)   inputDelimiter=$2;shift;;
        -j|--joinDelimiter)    joinDelimiter=$2;shift;;
        -o|--outputDelimiter)  outputDelimiter=$2;shift;;
        -a|--unpairedFile)     unpairedFile=$2;shift;;
        --)                    shift; break;;
        *)                     usage; echo -e "\n[ERR] $(date) Unkonwn option: $1"; exit 1;;
    esac
    shift
done

if [ $# -eq 0 ];then
    usage
    echo
    echo "Please specify at least one file" >&2
    exit 1
fi

if [ "X$1" == "X-" ];then
    file1=/dev/stdin
else
    file1=$1
fi
if [ "X$2" == "X-" ] || [ -z "$2" ];then
    file2=/dev/stdin
else
    file2=$2
fi

( echo "[DEBUG] $(date) Check if the following variables are correct as expected:"
  echo -e "field1\t$field1"
  echo -e "field2\t$field2"
  echo -e "inputDelimiter\t$inputDelimiter"
  echo -e "joinDelimiter\t$joinDelimiter"
  echo -e "outputDelimiter\t$outputDelimiter"
  echo -e "file1\t$file1"
  echo -e "file2\t$file2"
) >&2

if [ "$unpairedFile" ];then
    join -a $unpairedFile -e NA -1 $field1 -2 $field2 -t $joinDelimiter --ignore-case \
      <(tr "$inputDelimiter" "$joinDelimiter" <$file1 | sort --ignore-case -k$field1,$field1 -t "$joinDelimiter") \
      <(tr "$inputDelimiter" "$joinDelimiter" <$file2 | sort --ignore-case -k$field2,$field2 -t "$joinDelimiter")
else
    join -1 $field1 -2 $field2 -t $joinDelimiter --ignore-case \
      <(tr "$inputDelimiter" "$joinDelimiter" <$file1 | sort --ignore-case -k$field1,$field1 -t "$joinDelimiter") \
      <(tr "$inputDelimiter" "$joinDelimiter" <$file2 | sort --ignore-case -k$field2,$field2 -t "$joinDelimiter")
fi | tr $joinDelimiter $outputDelimiter
