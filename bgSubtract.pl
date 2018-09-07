#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::common;

my ($infoKeys, $myFormatKeys);
my $indexes = 1;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -s subtractRegion.bg raw.bg >substracted.bg
    If raw.bg isn't specified, input from STDIN
Option:
    -s  --subtract  BG  The region to be substract from input
    -h  --help          Print this help information
HELP
}

my $subtract;
GetOptions(
            's|subtract=s'  => \$subtract,
            'h|help'        => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
open SUB, "$subtract" or die "Can't read file ($subtract): $!";

my %subtract;
while(<SUB>){
    chomp;
    my ($chr, $start, $end, $value) = split "\t";
    if(exists $subtract{$chr}){
        push @{$subtract{$chr}}, [$start, $end, $value];
    }else{
        $subtract{$chr} = [[$start, $end, $value]];
    }
}

for my $chr(keys %subtract){
    my @sortedRegions = sort{$a->[0]<=>$b->[0]}@{$subtract{$chr}};
    $subtract{$chr} = \@sortedRegions;
}

while(<IN>){
    chomp;
    my ($chr, $start, $end, $value) = split "\t";
    my @ovlRegions = &common::getOvlRegs($start, $end, $subtract{$chr});
    if(@ovlRegions == 0){
        say join "\t", ($chr, $start, $end, $value);
    }else{
        for my $ovlRegion(@ovlRegions){
            my ($ovlRegionStart, $ovlRegionEnd, $ovlRegionValue) = @{$ovlRegion->[0]};
            if($ovlRegionValue == $value){
                if($ovlRegionStart > $start){
                    say join "\t", ($chr, $start, $ovlRegionStart, $value);
                }
                if($ovlRegionEnd < $end){
                    $start = $ovlRegionEnd;
                }else{
                    $start = $end;
                }
            }
        }
        if($start != $end){
            say join "\t", ($chr, $start, $end, $value);
        }
    }
}