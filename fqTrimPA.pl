#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::faParser;

my ($polyASize, $windowSize, $fraction) = (10, 50, 0.65);
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.fq >OUTPUT.fq
    If INPUT isn't specified, input from STDIN
    Read is preliminarily trimmed when there are >= -a consecutive A bases in tail.
    Then read is trimmed in a sliding window in which A base fraction > -f.
    Finally consecutive A bases in tail of read are trimmed in any length.
Option:
    -a --polyA      INT The minimal polyA length of preliminary trimming[10]
    -w --window     INT Sliding window size[$windowSize]
    -f --fraction   DOU Minimal fraction of A base to continue trimming[$fraction]
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            'a|polyA=i'     => \$polyASize,
            'w|window=i'    => \$windowSize,
            'f|fraction=s'  => \$fraction,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

while(<IN>){
    chomp;
    my $name = $_;
    chomp(my $seq = <IN>);
    <IN>;
    chomp(my $qual = <IN>);
    
    my $originLength = length $seq;
    my $currentLength = $originLength;
    
    # preliminary trimming
    if($seq =~ s/(A{$polyASize,})$//i){
        $qual = substr $qual, 0, ((length $qual) - (length $1));
        $currentLength -= length $1;
    }
    
    # trim with sliding windows
    for(my $i = $currentLength; $i >= $windowSize; $i--){
        if(&getAFraction(substr $seq, $i - $windowSize, $windowSize) < $fraction){
            $seq = substr $seq, 0, $i;
            $qual = substr $qual, 0, $i;
            $currentLength = $i;
            last;
        }
    }
    
    # final trimming
    if($seq =~ s/(A+)$//i){
        $qual = substr $qual, 0, ((length $qual) - (length $1));
        $currentLength -= length $1;
    }
    say $_, "\n$seq\n+\n", $qual if $currentLength > 0;
    say STDERR join "\t", ($name, $originLength, $currentLength);
}

sub getAFraction(){
    my ($seq) = @_;
    my $seqLen = length $seq;
    my @As = ($seq =~ /(A)/gi);
    @As / $seqLen;
}

