#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::bedParser;
my $splicedSite;
GetOptions(
            's|spliceSite' => \$splicedSite,
            'h|help'         => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
while(<IN>){
    chomp;
    my ($chr, $start, $end, $name, $score, $strand, $blockSizes, $blockRelStarts) = (split "\t")[0..5, 10, 11];
    my @blockSizes = split "\t", $blockSizes;
    my @blockRelStarts = split "\t", $blockRelStarts;
    my ($blockStarts, $blockEnds) = &bedParser::getAbsLoc($start, \@blockSizes, \@blockRelStarts);
    if(defined $splicedSite){
        if($strand eq '+'){
            say join "\t", ($chr, $blockEnds->[0], $blockEnds->[0] + 2, "${name}_Donor1", 0, $strand, 'Donor', 1);
            for(my $i = 1; $i < @$blockStarts - 1; $i++){
                my ($blockStart, $blockEnd) = ($blockStarts->[$i], $blockEnds->[$i]);
                my $rank = $i;
                say join "\t", ($chr, $blockStart - 2, $blockStart, "${name}_Acceptor$rank", 0, $strand, 'Acceptor', $rank);
                $rank++;
                say join "\t", ($chr, $blockEnd, $blockEnd + 2, "${name}_Donor$rank", 0, $strand, 'Donor', $rank);
            }
            my $rank = @$blockStarts - 1;
            say join "\t", ($chr, $blockStarts->[-1] - 2, $blockStarts->[-1], "${name}_Acceptor$rank", 0, $strand, 'Acceptor', $rank);
        }elsif($strand eq '-'){
            my $rank = @$blockStarts - 1;
            say join "\t", ($chr, $blockEnds->[0], $blockEnds->[0] + 2, "${name}_Acceptor$rank", 0, $strand, 'Acceptor', $rank);
            for(my $i = 1; $i < @$blockStarts - 1; $i++){
                my ($blockStart, $blockEnd) = ($blockStarts->[$i], $blockEnds->[$i]);
                my $rank = @$blockStarts - $i;
                say join "\t", ($chr, $blockStart - 2, $blockStart, "${name}_Donor$rank", 0, $strand, 'Donor', $rank);
                $rank--;
                say join "\t", ($chr, $blockEnd, $blockEnd + 2, "${name}_Acceptor$rank", 0, $strand, 'Acceptor', $rank);
            }
            say join "\t", ($chr, $blockStarts->[-1] - 2, $blockStarts->[-1], "${name}_Donor1", 0, $strand, 'Donor', 1);
        }
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -s --spliceSite Fetch spliced sites in each transcript, one site per line in the format of
                    chr, start, end, id, 0, strand, Donor/Acceptor, site rank
    -h --help       Print this help information
HELP
    exit(-1);
}