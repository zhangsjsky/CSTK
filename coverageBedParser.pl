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

my $bedFormat = 3;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName coverageBedOutput.tsv >OUTPUT.tsv
    If coverageBedOutput.tsv isn't specified, input from STDIN
Option:
    -b  -bedFormat  INT Bed format ([$bedFormat], 6)
    -h  --help          Print this help information
HELP
}

GetOptions(
            'b|bedFormat=s' => \$bedFormat,
            'h|help'        => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my %regions;
while(<IN>){
    chomp;
    next if /^all/;
    my @fields = split "\t";
    my ($key, $depth, $siteCount, $regionSize, $fraction);
    if($bedFormat == 3){
        $key = join "\t", @fields[0..2];
    }elsif($bedFormat == 6){
        $key = join "\t", @fields[0..5];
    }
    ($depth, $siteCount, $regionSize, $fraction) = @fields[($#fields-3)..$#fields];
    $regions{$key}{depth} += $depth * $siteCount;
    $regions{$key}{size} = $regionSize;
    $regions{$key}{coveredSize} += $siteCount if $depth > 0;
}

for my $region(keys %regions){
    my $meanDepth = $regions{$region}{depth}/$regions{$region}{size};
    my $coveredSite = exists $regions{$region}{coveredSize} ? $regions{$region}{coveredSize} : 0;
    my $coveredFraction = $coveredSite / $regions{$region}{size};
    say join "\t", ($region, $meanDepth, $coveredFraction);
}
