#!/usr/bin/env bash

usage(){
    cat << EOF
usage: $(basename $0) -f 1,2 OPTIONS INFILE COMMAND
opthins:
    -f  STR Fields to partition the input into the jobs
    -c  INT The concurrency jobs number[5]
    -h      Show this message
EOF
}

if [ "X$1" == "X" ];then
    usage
    exit
fi

SEP=@
CONC=5
while getopts "hf:s:c:" OPTION
do
    case $OPTION in
        h)  usage; exit 1;;
        f)  FIELDS=$OPTARG;;
        s)  SEP=$OPTARG;;
        c)  CONC=$OPTARG;;
        ?)  usage; exit;;
    esac
done
shift $((OPTIND - 1))

i=1
`mkdir -p concurrency`

for values in $(cut -f $FIELDS $1 | tr "\t" $SEP | sort -u);do
    select.pl -f $FIELDS -s $SEP -v $values $1 >concurrency/prefix.$values.input
done
ls -Sr concurrency/prefix.*.tsv | while read file;do
    baseName=$(basename $file .input)
    if [ $(($i%$CONC)) -eq 0 ];then
      $2 $file >concurrency/$baseName.out 2>concurrency/$baseName.err
    else
      $2 $file >concurrency/$basename.out 2>concurrency/$baseName.err &
    fi
    i=$(($i+1))
done
