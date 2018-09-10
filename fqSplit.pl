#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($twoFiles,$help);
GetOptions(
            'f|twoFiles'        => \$twoFiles,
            'h|help'            => \$help
        )||usage();
usage() if defined $help;
$ARGV[0]='-' unless defined $ARGV[0];
open IN,"$ARGV[0]" or die "Can't open $ARGV[0]: $!";
if(defined $twoFiles){
    open OUT1,">read1.fq" or die "Can't create read1.fq: $!";
    open OUT2,">read2.fq" or die "Can't create read2.fq: $!";
    while(<IN>){
        chomp;
        my $title1="$_/1";
        chomp(my $seq=<IN>);
        chomp(my $sep=<IN>);
        my ($sep1,$sep2);
        if($sep eq '+'){
            ($sep1,$sep2)=('+','+');
        }else{
            ($sep1,$sep2)=("$sep/1","$sep/2");
        }
        chomp(my $qual=<IN>);
        say OUT1 $title1;
        say OUT1 substr $seq,0,(length $seq)/2;
        say OUT1 $sep1;
        say OUT1 substr $qual,0,(length $qual)/2;
        my $title2="$_/2";
        say OUT2 $title2;
        say OUT2 substr $seq,(length $seq)/2;
        say OUT2 $sep2;
        say OUT2 substr $qual,(length $qual)/2;
    }
}else{
    while(<IN>){
        chomp;
        my $title1="$_/1";
        chomp(my $seq=<IN>);
        chomp(my $sep=<IN>);
        my ($sep1,$sep2);
        if($sep eq '+'){
            ($sep1,$sep2)=('+','+');
        }else{
            ($sep1,$sep2)=("$sep/1","$sep/2");
        }
        chomp(my $qual=<IN>);
        say $title1;
        say substr $seq,0,(length $seq)/2;
        say $sep1;
        say substr $qual,0,(length $qual)/2;
        my $title2="$_/2";
        say $title2;
        say substr $seq,(length $seq)/2;
        say $sep2;
        say substr $qual,(length $qual)/2;
    }
}


sub usage{
    my $scriptName=(fileparse($0))[0];
print <<HELP;
Usage: perl $scriptName INPUT
    if INPUT isn't specified, input from STDIN
    
    -f --twoFiles   Whether output splited reads into two separated files (read1.fq and read2.fq).
                    If not specified, both two reads will be output to STDOUT 
    -h --help       Print this help information screen
HELP
    exit(-1);
}