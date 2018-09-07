#!/bin/env perl
package mafParser;

use strict;
use 5.010;
require Exporter;

1;

####    Argument        Type    Description
#       seq             string  sequence to be trimed
#       baseLength      int     base length to be trimed

####    Return          Type    Description
#       stringLength    int     length of string needed trimed                          
sub getLeftBaseTrimLength(){#debugged
    my ($seq, $baseLength)=@_;
    my $originBaseLength = $baseLength;
    my $stringLength=0;
    while($baseLength >0){
        die "sequence ($seq) hasn't $originBaseLength bases" if ($stringLength >= length $seq);
        if( substr ($seq, $stringLength, 1) =~/[ATCGNatcgn]/ ){            
            $baseLength--;
        }
        $stringLength++;
    }
    return $stringLength;
}

####    Argument        Type    Description
#       seq             string  sequence to be trimed
#       baseLength      int     base length to be trimed

####    Return          Type    Description
#       stringLength    int     length of string needed trimed  
sub getRightBaseTrimLength(){#debugged
    my ($seq, $baseLength)=@_;
    $seq = join "", (reverse (split "", $seq));
    return &getLeftBaseTrimLength($seq, $baseLength);
}

####    Argument        Type    Description
#       seq1            string  the 1st sequence to be compared
#       seq2            int     the 2nd sequence to be compared

####    Return          Type    Description
#       matchNo         int     number of match base
sub calMatchNumber(){#debugged
    my ($seq1, $seq2)=@_;
    my $matchNo = 0;
    for (my $i=0; $i < length $seq1; $i++){
        my $char1 = substr $seq1, $i, 1;
        my $char2 = substr $seq2, $i, 1;
        $matchNo++ if(  $char1 =~/[GTACgtac]/ && "\u$char1" eq "\u$char2"  );
    }
    return $matchNo;
}

####    Argument        Type    Description
#       seq1            string  the 1st sequence to be compared
#       seq2            int     the 2nd sequence to be compared

####    Return          Type    Description
#       theta           double  number of match base
sub calTheta(){#debugged
    my ($targetSeq, $querySeq, $targetRegionLen) = @_;
    my ($matchNo, $insertLenInQuery) = (0, 0);
    for (my $i=0; $i < length $targetSeq; $i++){
        my $targetChar = substr $targetSeq, $i, 1;
        my $queryChar = substr $querySeq, $i, 1;
        next if $targetChar eq '-' && $queryChar eq '-';
        $insertLenInQuery++ if $targetChar eq '-';
        $matchNo++ if(  $targetChar =~/[GTACgtac]/ && "\u$targetChar" eq "\u$queryChar"  );
    }
    my $realLen= $targetRegionLen + $insertLenInQuery;
    return ( $realLen - $matchNo) / $realLen;
}



