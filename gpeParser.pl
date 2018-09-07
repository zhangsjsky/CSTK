#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
my $scriptName=(fileparse($0))[0];
use lib (fileparse($0))[1];
use pm::gpeParser;
my ($bin,$CDSLength,$help);
GetOptions(
            'b|bin'         => \$bin,
            'c|CDSLength'   => \$CDSLength,
            'h|help'        => \$help
        )||usage();
usage() if defined $help;
$ARGV[0]='-' unless defined $ARGV[0];
open GPE,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";
while(<GPE>){
    chomp;
    my @fields=split "\t";
    shift @fields if defined $bin;
    my ($ID,$CDSS,$CDSE) = @fields[0,5,6];
    my @exonStarts=split ",", $fields[8];
    my @exonEnds=split ",", $fields[9];
    if(defined $CDSLength){
        my $CDSLen=&gPEParser::getCDSLength($CDSS,$CDSE,\@exonStarts,\@exonEnds);
        say join "\t",($ID,$CDSLen);
    }    
}

sub usage{
print <<HELP;
Usage: perl $scriptName INPUT.gpe >OUTPUT.gpe
    if INPUT.gpe not specified, input from STDIN
    output to STDOUT
    -b --bin        With bin column
    -c --CDSLength  Get a list of transcript ID with its total CDS length
    -h --help       Print this help information screen
HELP
    exit(-1);
}