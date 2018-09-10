#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::common;

my ($motif, $rExp, $rc);
GetOptions(
            'm|motif=s'     => \$motif,
            'r|rExp=s'      => \$rExp,
            'rc'            => \$rc,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

my %IUPAC = (   A => 'A', T => 'T', C => 'C', G => 'G',
                R => 'AG', Y => 'CT', S => 'GC', W => 'AT', K => 'GT', M => 'AC',
                B => 'CGT', D => 'AGT', H => 'ACT', V => 'ACG', X => 'ATCG');

chomp(my $title = <IN>);
my $seq = '';
while(<IN>){
    chomp;
    if(/^>/){
        &outputByMotif($seq, $motif, $title) if defined $motif;
        &outputByRegExp($seq, $rExp, $title) if defined $rExp;
        $title = $_;
        $seq = '';
    }else{
        $seq .= $_;
    }
}
&outputByMotif($seq, $motif, $title) if defined $motif;
&outputByRegExp($seq, $rExp, $title) if defined $rExp;

sub outputByRegExp{
    my ($seq, $rExp, $title) = @_;
    my $rcSeq = common::reverseComplement($seq);
    $title =~ s/^>//;
    my $start = 0;
    while($seq =~ /$rExp/i){
        say join "\t", ($title, $start + $-[0], $start + $+[0], $&, 0, '+');
        $seq = $';
        $start += $+[0];
    }
    
    if(defined $rc){
    my $seqLen = length $rcSeq;
        while($rcSeq =~ /$rExp/i){
            say join "\t", ($title, $seqLen - $+[0], $seqLen - $-[0], $&, 0, '-');
            $rcSeq = $';
            $seqLen -= $+[0];
        }
    }
}

sub outputByMotif{
    my ($seq, $motif, $title) = @_;
    $title =~ s/^>//;
    my $motifLen = length $motif;
SUBSEQ:for(my $i = 0; $i <= length($seq) - $motifLen; $i++){
        my $subSeq = substr $seq, $i, $motifLen;
        if(&isMatch($subSeq, $motif) == 1){
            say join "\t", ($title, $i, $i+$motifLen, $subSeq, 0, '+');
        }
        $subSeq = common::reverseComplement($subSeq);
        if(&isMatch($subSeq, $motif) == 1){
            say join "\t", ($title, $i, $i+$motifLen, $subSeq, 0, '-');
        }
    }
}

sub isMatch{
    my ($seq, $motif) = @_;
    my $motifLen = length $motif;
    for(my $i = 0; $i < $motifLen; $i++){
        my $base = substr $seq, $i, 1;
        return 0 if $IUPAC{substr $motif, $i, 1} !~ /$base/i;
    }
    return 1;
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.fa >OUTPUT.bed6
    If INPUT.fa isn't specified, input from STDIN
Option:
    -m --motif  STR The motif sequence. IUPAC characters are supported, with an additional X=ATCG
    -r --rExp   STR The sequence in regular expression
       --rc         Find motif on the reverse complement of the original sequence
    -h --help       Print this help information
HELP
    exit(-1);
}