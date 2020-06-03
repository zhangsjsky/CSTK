#!/bin/env perl
package bedgraphParser;

use strict;
use 5.010;
require Exporter;
use List::Util qw/sum/;

#our @ISA = qw(Exporter);
#our @EXPORT = qw/getCDSLength/;
1;

####    Argument    Type    Description
#       bedFiles    array   array values are bedgraph files

####    Return      Type    Description
#       pileBG      hash    with chr as key and array ref as value
#                           index and value of array are coordinate (1-based) and coverage, respectively
sub pileUp{#debugged
    my (@files) = @_;
    my %piledBG;
    for my $file(@files){
        open BG, $file or die "Can't open $file: $!";
        say STDERR "Loading '$file' file...";
        while(<BG>){
            chomp;
            next if /^track/;
            next if /^$/;
            my ($chr, $start, $end, $score) = split "\t";
            $start++;   # 0-based to 1-based
            for my $pos ($start..$end){
                $piledBG{$chr}->[$pos] += $score;
            }
        }
        say STDERR "Finish loading of '$file'";
    }
    say STDERR "Finish loading of all files";
    return \%piledBG;
}

####    Argument    Type    Description
#       bedgraph    hash    with chr as key and array ref as value
#                           index and value of array are coordinate (1-based) and coverage, respectively
####    No return
sub outputBedGraph{#debugged
    my ($bgHash, $outputNullRegion, $FH) = @_;
    $FH = \*STDOUT unless defined $FH;
    for my $chr (sort keys %$bgHash){
        my $chrV = $bgHash->{$chr};
        my ($leftIndex, $rightIndex) = (1, 1);
            for (; $rightIndex < @$chrV; $rightIndex++){
                if(defined $chrV->[$rightIndex]){
                    if(defined $chrV->[$leftIndex]){
                        if ($chrV->[$rightIndex] != $chrV->[$leftIndex]){
                            say $FH join "\t", ($chr, $leftIndex - 1, $rightIndex -1, $chrV->[$leftIndex]);
                            $leftIndex = $rightIndex;
                        }
                    }else{
                        say $FH join "\t", ($chr, $leftIndex - 1, $rightIndex -1, -1) if defined $outputNullRegion;
                        $leftIndex = $rightIndex;
                    }                    
                }else{
                    if(defined $chrV->[$leftIndex]){
                        say $FH join "\t", ($chr, $leftIndex - 1, $rightIndex -1, $chrV->[$leftIndex]);
                        $leftIndex = $rightIndex;
                    }
                }
            }
            say $FH join "\t",($chr, $leftIndex - 1, $rightIndex -1, $chrV->[$leftIndex]) if defined $chrV->[$leftIndex];
        say STDERR "Finish output of chromosome '$chr'";
    }
}