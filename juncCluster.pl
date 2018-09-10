#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: cat *.junction.bed | perl $scriptName >clustered.bed
Option:
    -h  --help       Print this help information
HELP
}

GetOptions(
            'h|help' => sub{usage(); exit}
) || usage();

my %junction;
while(<>){
    chomp;
    my @fields = split "\t";
    my ($chr, $start, $end, $score, $strand) = @fields[0, 1, 2, 4, 5];
    my @blockSizes = split ",", $fields[10];
    my $junctionStart = $start + $blockSizes[0];
    my $junctionEnd = $end - $blockSizes[1];
    if(exists $junction{"$chr:$strand:$junctionStart:$junctionEnd"}){
        $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{score} += $score;
        if ($start < $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{leftBoundary}){
            $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{leftBoundary} = $start
        }
        if ($end > $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{rightBoundary}){
            $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{rightBoundary} = $end
        }
    }else{
        $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{score} = $score;
        $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{leftBoundary} = $start;
        $junction{"$chr:$strand:$junctionStart:$junctionEnd"}{rightBoundary} = $end;
    }
}

while(my ($key, $value) = each %junction){
    my ($chr, $strand, $junctionStart, $junctionEnd) = split ':', $key;
    my $start = $value->{leftBoundary};
    my $end = $value->{rightBoundary};
    my $score = $value->{score};
    my $blockSizes = ($junctionStart - $start) . ',' . ($end - $junctionEnd);
    my $blockStarts = '0,'.($junctionEnd - $start);
    say join "\t",($chr,
                   $start,
                   $end,
                   "$chr:$junctionStart-$junctionEnd:$score",
                   $score,
                   $strand,
                   $start,
                   $end,
                   '0,0,0',
                   2,
                   $blockSizes,
                   $blockStarts
    );
}
