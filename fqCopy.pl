#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($times,$help)=(2);
GetOptions(
            'c|copyTimes=i' => \$times,
            'h|help'    => \$help
        )||usage();
usage() if defined $help;
$ARGV[0]='-' unless defined $ARGV[0];
open IN,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";
while(<IN>){
    chomp;
    my $title=$_;
    chomp(my $seq=<IN>);
    chomp(my $sep=<IN>);
    chomp(my $qual=<IN>);
    say $title;
    say $seq x $times;
    say $sep;
    say $qual x $times;
}

sub usage{
    my $scriptName=(fileparse($0))[0];
print <<HELP;
Usage: perl $scriptName INPUT OUTPUT
    if INPUT isn't specified, input from STDIN
    output to STDOUT
    
    -c --copyTimes  The copy times[2]
    -h --help       Print this help information screen
HELP
    exit(-1);
}