#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::common;
use pm::gpeParser;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.bed6 >OUTPUT.bed6+
    If INPUT isn't specified, input from STDIN
Option:
    -g --gpe    FILE    GPE file
    -b --bin            With bin column
    -h --help           Print this help information
HELP
    exit(-1);
}

my ($gpeFile, $bin);
GetOptions(
            'g|gpe=s'   => \$gpeFile,
            'b|bin'     => \$bin,
            'h|help'    => sub{usage()}
        ) || usage();

my $GPE;
open $GPE, "$gpeFile" or die "Can't read file ($gpeFile): $!";
my %gpeHash = &gpeParser::buildHash4($GPE, $bin);

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
while(<IN>){
    chomp;
    my ($chr, $start, $end, $strand) = (split "\t")[0..2, 5];
    my @ovlRegions = &common::getOvlRegs($start, $end, $gpeHash{$chr}{$strand});;
    print "$_\t";
    if(@ovlRegions == 0){
        say "Intergenic";
    }else{
        my @regionTypes;
        for my $iso(@ovlRegions){
            my ($isoStart, $isoEnd, $fields) = @{$iso->[0]};
            my ($strand, $cdsStart, $cdsEnd, $exonStarts, $exonEnds) = @$fields[2, 5, 6, 8, 9];
            my @exonStarts = split ',', $exonStarts;
            my @exonEnds = split ',', $exonEnds;
            my $regionType = &gpeParser::regionFeaturing($start, $end, $cdsStart, $cdsEnd, \@exonStarts, \@exonEnds, $strand);
            push @regionTypes, $regionType;
        }
        say join ',', @regionTypes;
    }
}

