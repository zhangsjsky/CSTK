#!/bin/env bash

source $(dirname $0)/env.conf
thread=1
scriptName=$(basename $0)
pid=$$

usage(){
    cat <<EOF
Usage: $(basename $0) OPTIONS list1.lst [list2.lst [list3.lst]...] >result.tsv
Option:
  Output:
    -o|outDir      DIR    Output directory. If specified, venn figure will be generated under this directory.
  Efficiency:
    -t|thread      INT    The thread number[$thread]
  Other:
       listNames   STRs   Comma-separated list names
                          If not specified, will be infer from the names of list files
Note:
    The result can be used to plot heatmap by:
    (grep -v '^#' result.tsv | cut -f1,2,8; grep -v '^#' result.tsv | select.pl -i 2,1,8) | stack2matrix.pl --rect | pheatmap.R -header -rower -displayNum -p=heatmap.pdf >pheatmap.log 2>pheatmap.err
EOF
}

shortOptions="o:t:"
longOptions="outDir:,thread:,listNames:"
eval set -- $(getopt -n $(basename $0) -a -o $shortOptions -l $longOptions -- "$@")
while [ -n "$1" ];do
    case $1 in
        -o|--outDir)       outDir=$(readlink -mn $2);shift;;
        
        -t|--thread)       thread=$2;shift;;

           --listNames)    listNames=($(echo $2|tr ',' ' '));shift;;
           
        --)                shift; break;;
        *)                 usage; echo -e "\n[ERR] $(date) Unknown option: $1"; exit 1;;
    esac
    shift
done

(
 echo "[DEBUG] $(date) Check if the following variables are correct as expected:"
 echo -e "outDir\t$outDir"
 echo -e "thread\t$thread"
 echo -e "listNames\t${listNames[@]}"
) >&2

if [ $# -eq 0 ];then
    ( echo
      usage
      echo -e "\nNo list files"
    ) >&2
    exit 1
fi

echo -e "\n[INFO] $(date) Checking if all the needed tools are available..." >&2
checkTools filter.pl venn.R

lists=($@)
if [ -z "$listNames" ];then
    for list in ${lists[@]};do
        listName=$(basename $list .lst)
        listNames=(${listNames[@]} $listName)
    done
fi

listN=${#lists[@]}
lastIndex=$(($listN-1))
[ "$outDir" ] && mkdir -p $outDir
echo -e "#List A\tList B\tList A-specific\t%List A-specific\tList B-specific\t%List B-specific\tCommon\tCommon Index"
for A in $(seq 0 1 $lastIndex);do
    for B in $(seq 0 1 $lastIndex);do
        if [ $B -gt $A ];then
            listNameA=${listNames[$A]}
            listNameB=${listNames[$B]}
            listA=${lists[$A]}
            listB=${lists[$B]}
            aSpecific=$(filter.pl -o $listB $listA | wc -l)
            bSpecific=$(filter.pl -o $listA $listB | wc -l)
            common=$(filter.pl -o $listB --mode include $listA | wc -l)
            aCount=$(wc -l <$listA)
            bCount=$(wc -l <$listB)
            aSpecificPer=0
            [ $aCount -gt 0 ] && aSpecificPer=$(echo "scale=2;$aSpecific*100/$aCount" | bc)
            bSpecificPer=0
            [ $bCount -gt 0 ] && bSpecificPer=$(echo "scale=2;$bSpecific*100/$bCount" | bc)
            commonIndex=0
            [ $(($aSpecific+$common+$bSpecific)) -gt 0 ] && commonIndex=$(echo "scale=2;$common/($aSpecific+$common+$bSpecific)" | bc)
            echo -e "$listNameA\t$listNameB\t$aSpecific\t$aSpecificPer\t$bSpecific\t$bSpecificPer\t$common\t$commonIndex"
            [ "$outDir" ] && venn.R -m=$listNameA.vs.$listNameB -p=$outDir/$listNameA.vs.$listNameB.pdf $listA $listB >/dev/null 2>&1
        fi &
        while [ $(ps -ef | tr -s ' ' | awk -v pid=$pid '$3==pid' | cut -f8- -d ' ' | grep "^bash .*/$scriptName" | wc -l) -gt $thread ];do
            sleep 1
        done
    done
done
wait