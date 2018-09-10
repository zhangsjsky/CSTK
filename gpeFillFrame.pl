#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::gpeParser;

my($bin,$help);
GetOptions(
                'b|bin'		=>	\$bin,
                'h|help'	=>	\$help
                )||usage(); 
usage () if defined $help;
$ARGV[0]='-' unless defined $ARGV[0];
open IN,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";


while(<IN>){
	chomp;
	my @data_input=split "\t",$_;
	my $bin_input=shift @data_input if defined $bin;
	my $cds_s=$data_input[5];
	my $cds_e=$data_input[6];
	my $strand=$data_input[2];
	my $exonSs=$data_input[8];
	my $exonEs=$data_input[9];
	my @exon_Frames=@{&gpeParser::getExonFrames($cds_s, $cds_e, $strand, $exonSs, $exonEs)};
	my $exon_Frames=join ",",@exon_Frames;
	$data_input[14]=$exon_Frames;
	if(defined $bin){
		say STDOUT join "\t",($bin_input,@data_input);
	}
	else{
		say STDOUT join "\t",@data_input;
	}
}



sub usage{
    my $scriptName=basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    if INPUT not specified, input from STDIN
    output from STDOUT

    -b --bin		Have bin column
    -h --help           print this help information screen
HELP
    exit(-1);
}
