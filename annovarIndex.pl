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

my ($binSize, $withID, $withChr) = (1000);
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.idx
Option:
    -b  --binSize   The size of bin[$binSize]
    -i  --id        With ID column as the first column
    -c  --chr       With chr prefix in chr column
    -h  --help      Print this help information
HELP
}

GetOptions(
            'b|binSize=i'   => \$binSize,
            'i|id'          => \$withID,
            'c|chr'         => \$withChr,
            'h|help'        => sub{usage(); exit}
) || usage();

my $inputFile = $ARGV[0];
my $fileSize = -s $inputFile;

my %index;
open IN, $inputFile or die "Couldn't open $inputFile for indexing\n";

my $previousFilePosition = tell IN;

while (<IN>) {
    next if /^#/;
    my @fields = split "\t";
    my $id = shift @fields if defined $withID;
    my ($chr, $start) = @fields;
    my $binStart = int($start/$binSize) * $binSize;
    my $currentFilePosition = tell IN;
    
    if (!exists $index{$chr}->{$binStart}) {
        $index{$chr}->{$binStart} = [$previousFilePosition, $currentFilePosition];
    }
    else{
        $index{$chr}->{$binStart}->[1] = $currentFilePosition;
    }
    
    $previousFilePosition = $currentFilePosition;
}

say join "\t", ("#BIN", $binSize, $fileSize);
for my $chr (1, 10..19, 2, 20, 21, 22, 3..9, "MT", "X", "Y"){
    my $chr2 = defined $withChr ? "chr$chr" : $chr;
    for my $indexRegion (sort keys %{$index{$chr2}}){
        my ($start, $stop) = @{$index{$chr2}->{$indexRegion}};
        say join "\t", ($chr2, $indexRegion, $start, $stop);
    }
}

