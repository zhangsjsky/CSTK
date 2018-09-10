#!/bin/env perl
use strict;
my %junction;
use 5.010;
while(<>){
    chomp;
    my @fields=split "\t";
    my ($chr,$start,$end,$strand)=@fields[0,1,2,5];
    my @blockSizes=split ",",$fields[10];
    my $junctionStart=$start+$blockSizes[0];
    my $junctionEnd=$end-$blockSizes[1];
    if(exists $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}){
        $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{NO}++;
        if ($start<$junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{leftBoundary}){
            $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{leftBoundary}=$start;
        }
        if ($start<$junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{rightBoundary}){
            $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{rightBoundary}=$end;
        }
    }else{
        $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{NO}=1;
        $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{leftBoundary}=$start;
        $junction{$chr}{$strand}{$junctionStart}{$junctionEnd}{rightBoundary}=$end;
    }
}
my $counter=1;
while( my ($chr,$iStrand)=each %junction){
    while( my ($strand,$iJunctionStart)=each %$iStrand){
        while( my ($junctionStart,$iJunctionEnd)=each %$iJunctionStart){
            while( my ($junctionEnd,$junction)=each %{$iJunctionEnd}){
                my $start=$junction->{leftBoundary};
                my $end=$junction->{rightBoundary};
                my $blockSizes=($junctionStart-$start).','.($end-$junctionEnd);
                my $blockStarts='0,'.($junctionEnd-$start);
                say join "\t",($chr,
                               $start,
                               $end,
                               "Junction".$counter++,#name
                               $junction->{NO},#read Cover No.
                               $strand,
                               $start,#thickStart
                               $end,#thickEnd
                               '255,0,0',#itemRgb
                               2,#blockCount
                               $blockSizes,
                               $blockStarts
                               );
            }
        }
    }
}
