#!/bin/env perl

use 5.010;
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq::Quality;
use Getopt::Long;
use File::Basename;

my $scriptName = (fileparse($0))[0];
my ($source, $target)=('fastq-illumina','fastq');
GetOptions(
             's|source=s' => \$source,
             't|target=s' => \$target,
             'h|help'     => sub{usage()}
            );

$ARGV[0]='/dev/stdin' unless defined $ARGV[0];

my $in = Bio::SeqIO->new(-format => $source, -file =>  "$ARGV[0]");
my $out= Bio::SeqIO->new(-format => $target, -file => ">/dev/stdout");


while(my $data = $in->next_dataset){
    $out->write_seq(Bio::Seq::Quality->new(%$data));
}

sub usage{
print <<HELP;
Usage:perl $scriptName input.fq >output.fq
    If INPUT isn't specified, input from STDIN
    -s  --source  STR   The quality format of your source fastq file ([fastq-illumina], fastq-solexa, fastq)
    -t  --target  STR   The quality format of your target fastq file (fastq-illumina, fastq-solexa, [fastq])
    -h  --help          This help information screen
HELP
    exit(-1);
}
