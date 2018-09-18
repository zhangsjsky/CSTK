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
Usage: $(basename $0) OPTIONS [-1 fields1] [-2 fields2] input1.tsv [input2.tsv]
Note: input.tsv and input2.tsv must be file rather than /dev/stdin or -.
Options:
    -1|field1           STR  The fields in input1.tsv used when joining[$field1]
                             Refer to the -f option of linux cut command
    -2 field2           STR  The fields in input2.tsv used when joining[$field2]
    -f|fieldDelmiter    STR  The separater used to join the fileds used in linux join command[$fieldSeparater]
    -i|inputDelimiter   STR  The delimiter of your input file[\t]
    -j|joinDelimiter    STR  The delimiter used by linux join commond (i.e. the -t option of join command)[$joinDelimiter]
    -o|outputDelimiter  STR  The delimiter of the output[\t]
    -a|unpairedFile     INT  Also print unpairable lines from file INT (1, 2)
    -t|tempDir          DIR  Temporary direction
EOF
}


shortOptions="1:2:f:i:j:o:a:t"
longOptions="field1:,field2:,fieldSeparater:,inputDelimiter:,joinDelimiter:,outputDelimiter:,unpairedFile,tempDir:"
eval set -- $(getopt -n $(basename $0) -a -o $shortOptions -l $longOptions -- "$@")
while [ -n "$1" ];do
    case $1 in
        -1|--field1)           field1=$2;shift;;
        -2|--field2)           field2=$2;shift;;
        -f|--fieldSeparater)   fieldSeparater=$2;shift;;
        -i|--inputDelimiter)   inputDelimiter=$2;shift;;
        -j|--joinDelimiter)    joinDelimiter=$2;shift;;
        -o|--outputDelimiter)  outputDelimiter=$2;shift;;
        -a|--unpairedFile)     unpairedFile=$2;shift;;
        -t|--tempDir)          tempDir=$2;shift;;
        
        --)                    shift; break;;
        *)                     usage; echo -e "\n[ERR] $(date) Unkonwn option: $1"; exit 1;;
    esac
    shift
done

if [ $# -lt 2 ];then
    usage
    echo
    echo "Please specify two files" >&2
    exit 1
fi

file1=$1
file2=$2

( echo "[DEBUG] $(date) Check if the following variables are correct as expected:"
  echo -e "field1\t$field1"
  echo -e "field2\t$field2"
  echo -e "fieldSeparater\t$fieldSeparater"
  echo -e "inputDelimiter\t$inputDelimiter"
  echo -e "joinDelimiter\t$joinDelimiter"
  echo -e "outputDelimiter\t$outputDelimiter"
  echo -e "file1\t$file1"
  echo -e "file2\t$file2"
  echo -e "tempDir\t$tempDir"
) >&2

sortParams="--ignore-case -k1,1"
[ $tempDir ] && sortParams=$sortParams" --temporary-directory=$tempDir"
joinParams="-1 1 -2 1 --ignore-case -t "$joinDelimiter""
[ "$unpairedFile" ] && joinParams="$joinParams -a $unpairedFile -e NA"
join $joinParams \
    <( paste <(tr $inputDelimiter $joinDelimiter <$file1 | cut -d "$joinDelimiter" -f$field1 | tr $joinDelimiter $fieldSeparater) $file1 \
        | tr $inputDelimiter $joinDelimiter | sort $sortParams -t "$joinDelimiter" \
      ) \
    <( paste <(tr $inputDelimiter $joinDelimiter <$file2 | cut -d "$joinDelimiter" -f$field2 | tr $joinDelimiter $fieldSeparater) $file2 \
         | tr $inputDelimiter $joinDelimiter | sort $sortParams -t "$joinDelimiter" \
      ) \
    | cut -f2- -d "$joinDelimiter" | tr $joinDelimiter $outputDelimiter