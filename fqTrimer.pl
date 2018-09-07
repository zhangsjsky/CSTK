#!/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::fqParser;
my ($lRegExp, $rRegExp, $input2, $output2);
GetOptions(
           'l|lRegExp=s'   => \$lRegExp,
           'r|rRegExp=s'   => \$rRegExp,
           'i2=s'          => \$input2,
           'o2=s'          => \$output2,
           'h|help'        => sub{usage()}
         ) || usage();
die "Please specify --regExp\n" if !defined $lRegExp && !defined $rRegExp;
$ARGV[0]='-' unless defined $ARGV[0];
open IN,"$ARGV[0]" or die "Can't open $ARGV[0]: $!";

if (!defined $input2){
   while(<IN>){
      chomp;
      chomp(my $seq = <IN>);
      chomp(my $plus = <IN>);
      chomp(my $qual = <IN>);
      
      ($seq, $qual) = &fqParser::trimByRegExp($seq, $qual, $lRegExp, 5) if defined $lRegExp;
      ($seq, $qual) = &fqParser::trimByRegExp($seq, $qual, $rRegExp, 3) if defined $rRegExp;
      
      say "$_\n$seq\n$plus\n$qual";
   }
}
else{
   die "Please specify the output file of read 2 by --o2" unless defined $output2;
   open IN2,"$input2" or die "Can't open $input2: $!";
   open OUT2,">$output2" or die "Can't wirte to $output2: $!";
   while(<IN>){
      chomp;
      chomp(my $seq = <IN>);
      chomp(my $plus = <IN>);
      chomp(my $qual = <IN>);
      ($seq, $qual) = &fqParser::trimByRegExp($seq, $qual, $lRegExp, 5) if defined $lRegExp;
      ($seq, $qual) = &fqParser::trimByRegExp($seq, $qual, $rRegExp, 3) if defined $rRegExp;
      
      chomp(my $name2 = <IN2>);
      chomp(my $seq2 = <IN2>);
      chomp(my $plus2 = <IN2>);
      chomp(my $qual2 = <IN2>);
      ($seq2, $qual2) = &fqParser::trimByRegExp($seq2, $qual2, $lRegExp, 5) if defined $lRegExp;
      ($seq2, $qual2) = &fqParser::trimByRegExp($seq2, $qual2, $rRegExp, 3) if defined $rRegExp;
      
      say "$_\n$seq\n$plus\n$qual";
      say OUT2 "$name2\n$seq2\n$plus2\n$qual2";
   }
}

sub usage{
   my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -l G{4} [--i2 input2.fq --o2 output2.fq] input1.fq >output1.fq
      If input1.fq isn't specified, input from STDIN
      Output to STDOUT
      
      -l --lRegExp   STR   The regular expression to trim 5' end. For example:
                           G{4} means to trim the heading 4 Gs
                           [ATCG]{4} means to trim the heading 4 normal bases(A, T, C, G)
                           G+ means to trim all heading Gs
      -r --rRegExp   STR   The regular expression to trim 3' end
         --i2        FILE  (Optional) input for read 2 if the reads are paired
         --o2        FILE  (Optional) output for read 2 if the reads are paired
      -h --help            This help information
HELP
    exit(-1);
}
