#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -h  --help       Print this help information
HELP
    exit(-1);
}

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
chomp(my $title = <IN>);
my ($seq, $length) = ('', 0);
my $zmwID = 1;
while(<IN>){
    chomp;
    if(/^>/){
        say ">m/$zmwID/0_$length";
        print $seq;
        $title = $_;
        $zmwID++;
        $length = 0;
        $seq = '';
    }else{
        $seq .= "$_\n";
        $length += length $_;
    }
}
say ">m/$zmwID/0_$length";
print $seq;
