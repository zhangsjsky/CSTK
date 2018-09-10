#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
#use strict; is turned on auto by use 5.012
use Getopt::Long;
use File::Basename;

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

while(<IN>){
    $_ =~ s/^@/>/;
    print $_;
    my $seq = <IN>;
    print $seq;
    <IN>;
    my $qual = <IN>;
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.fq >OUTPUT.fa
    If INPUT isn't specified, input from STDIN
Option:
    -h --help       Print this help information
HELP
    exit(-1);
}