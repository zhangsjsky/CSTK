#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my ($seqID, %primerHash);
say join "\t", ('#SEQUENCE_ID', qw/PRIMER_ID START LENGTH SEQUENCE PENALTY TM GC_PERCENT SELF_ANY_TH SELF_END_TH HAIRPIN_TH END_STABILITY/);
while(<IN>){
    chomp;
    if($_ eq '='){
        for my $primerID(sort {$a<=>$b}keys %primerHash){
            say join "\t", ($seqID, $primerID,
                            (split ',', $primerHash{$primerID}{REGION}),
                            $primerHash{$primerID}{SEQUENCE},
                            $primerHash{$primerID}{PENALTY},
                            exists $primerHash{$primerID}{TM} ? $primerHash{$primerID}{TM} : 'NA',
                            exists $primerHash{$primerID}{GC_PERCENT} ? $primerHash{$primerID}{GC_PERCENT} : 'NA',
                            exists $primerHash{$primerID}{SELF_ANY_TH} ? $primerHash{$primerID}{SELF_ANY_TH} : 'NA',
                            exists $primerHash{$primerID}{SELF_END_TH} ? $primerHash{$primerID}{SELF_END_TH} : 'NA',
                            exists $primerHash{$primerID}{HAIRPIN_TH} ? $primerHash{$primerID}{HAIRPIN_TH} : 'NA',
                            exists $primerHash{$primerID}{END_STABILITY} ? $primerHash{$primerID}{END_STABILITY} : 'NA',);
        }
        %primerHash = ();
    }else{
        my ($key, $value) = split "=";
        given($key){
            when("SEQUENCE_ID"){$seqID = $value}
            when(/^PRIMER_LEFT_(\d+)_PENALTY/){$primerHash{$1}{PENALTY} = $value}
            when(/^PRIMER_LEFT_(\d+)_SEQUENCE/){$primerHash{$1}{SEQUENCE} = $value}
            when(/^PRIMER_LEFT_(\d+)$/){$primerHash{$1}{REGION} = $value}
            when(/^PRIMER_LEFT_(\d+)_TM$/){$primerHash{$1}{TM} = $value}
            when(/^PRIMER_LEFT_(\d+)_GC_PERCENT$/){$primerHash{$1}{GC_PERCENT} = $value}
            when(/^PRIMER_LEFT_(\d+)_SELF_ANY_TH$/){$primerHash{$1}{SELF_ANY_TH} = $value}
            when(/^PRIMER_LEFT_(\d+)_SELF_END_TH$/){$primerHash{$1}{SELF_END_TH} = $value}
            when(/^PRIMER_LEFT_(\d+)_HAIRPIN_TH$/){$primerHash{$1}{HAIRPIN_TH} = $value}
            when(/^PRIMER_LEFT_(\d+)_END_STABILITY$/){$primerHash{$1}{END_STABILITY} = $value}
        }
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -h --help       Print this help information
HELP
    exit(-1);
}
