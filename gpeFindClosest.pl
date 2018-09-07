#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($bin, $sizeFile);
my ($direction) = ('d');
GetOptions(
            'b|bin'         => \$bin,
            'd|direction=s' => \$direction,
            's|size=s'      => \$sizeFile,
            'h|help'        => sub{usage()}
        ) || usage();

die "Please specify correct direction (u for upstream, d for downstream)\n" if $direction ne 'u' && $direction ne 'd';
$ARGV[0] = '-' unless defined $ARGV[0];
open GPE, "$ARGV[0]" or die "Can't open $ARGV[0]: $!\n";

my %chrSizeHash;
if(defined $sizeFile){
    open chrSize, "$sizeFile" or die "Can't open $sizeFile: $!\n";
    while(<chrSize>){
        chomp;
        my ($chr, $size) = split "\t";
        $chrSizeHash{$chr} = $size;
    }
}

my %gpeHash;
while(<GPE>){   # build hash
    chomp;
    my @fields = split "\t";
    shift @fields if defined $bin;
    my ($chr, $strand, $start, $end) = @fields[1..4];
    if(defined $gpeHash{$chr}{$strand}{unsorted}){
        push @{$gpeHash{$chr}{$strand}{unsorted}}, [$start, $end, $_];
    }else{
        $gpeHash{$chr}{$strand}{unsorted} = [[$start, $end, $_]];
    }
}
for my $chr (keys %gpeHash){    # sort hash by TSS
    my $chrV = $gpeHash{$chr};
    for my $strand (keys %$chrV){
        my $strandV = $chrV->{$strand}{unsorted};
        my @sortedByStart = sort{$a->[0]<=>$b->[0]}(@$strandV);
        my @sortedByEnd = sort{$a->[1]<=>$b->[1]}(@$strandV);
        $gpeHash{$chr}{$strand}{sortedByStart} = \@sortedByStart;
        $gpeHash{$chr}{$strand}{sortedByEnd} = \@sortedByEnd;
    }
}
for my $chr (keys %gpeHash){
    my $chrV = $gpeHash{$chr};
    for my $strand (keys %$chrV){
        my $strandV = $chrV->{$strand}{unsorted};
        for my $trans(@$strandV){
            my ($start, $end, $line) = @$trans;
            my ($distance, $closestTrans);
            if($strand eq '+' && $direction eq 'd' || $strand eq '-' && $direction eq 'u'){
                for my $trans2 (@{$gpeHash{$chr}{$strand}{sortedByStart}}){
                    if($trans2->[0] >= $end){
                        $distance  = $trans2->[0] - $end;
                        $closestTrans = $trans2->[2];
                        last;
                    }
                }
                if(defined $distance){
                    say join "\t", ($line, $distance, $closestTrans);
                }else{
                    $distance = defined $sizeFile ? $chrSizeHash{$chr} - $end : -1;
                    say join "\t", ($line, $distance);
                }
            }else{
                my @trans2 = @{$gpeHash{$chr}{$strand}{sortedByEnd}};
                for(my $i = $#trans2; $i >= 0; $i--){
                    if($trans2[$i]->[1] <= $start){
                        $distance  = $start - $trans2[$i]->[1];
                        $closestTrans = $trans2[$i]->[2];
                        last;
                    }
                }
                if(defined $distance){
                    say join "\t", ($line, $distance, $closestTrans);
                }else{
                    $distance = defined $sizeFile ? $start : -1;
                    say join "\t", ($line, $distance);
                }
            }            
        }
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Description: 
    This tool finds the closest transcript of each transcript, gives their distance and gpe line.
    For transcript on chromosome end, the gpe line isn't given (no upstream or downstream transcript).
    For these transcripts, when -s option isn't specified, the distance is -1, otherwise distacne = chromosome size - transcript end.

Usage: perl $scriptName INPUT.gpe >OUTPUT.gpe+
    If INPUT.gpe isn't specified, input from STDIN
    Output to STDOUT, which is a gpe file with distacne between it and its closet transcript
    and the closet transcript (if any) gpe line as additional columns

Option:
    -b --bin                With bin column
    -d --direction  STR     u for upstream, d for downstream[d]
    -s --size       FILE    The chromosome size file with 2 columns: chr and size
    -h --help               Print this help information
HELP
    exit(-1);
}
