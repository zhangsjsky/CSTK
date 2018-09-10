#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my $chrSizeFile;
GetOptions(
            's|size=s'  => \$chrSizeFile,
            'h|help'    => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

open SIZE, "$chrSizeFile" or die "Cann't open file $chrSizeFile: $!";

my %chrSizes;
while(<SIZE>){
    chomp;
    my ($chr, $size) = split "\t";
    $chrSizes{$chr} = $size;
}

while(<IN>){
    next if /^track/;
    chomp;
    my @fields = split "\t";
    my ($chr, $start, $end) = @fields;
    if($start < $chrSizes{$chr}){
        $fields[2]  = $chrSizes{$chr} if $end > $chrSizes{$chr};
        say join "\t", @fields;
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -s --size   FILE    Chromosome size file
    -h --help           Print this help information
HELP
    exit(-1);
}