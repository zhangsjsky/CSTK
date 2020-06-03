#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my ($maxRefHomFreq, $minAltHomFreq) = (0.1, 0.75);
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName multianno.vcf >flt.vcf
    If multianno.vcf isn't specified, input from STDIN
Option:
        --maxRefHomFreq    DOU Maximal variant frequency to call a reference homozygote[0.10]
        --minAltHomFreq    DOU Minimal variant frequency to call a altered homozygote[0.75]
    -h  --help                 Print this help information
HELP
}

GetOptions(
            'maxRefHomFreq=s'  => \$maxRefHomFreq,
            'minAltHomFreq=s'  => \$minAltHomFreq,
            'h|help'           => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";


my $line;
while($line = <IN>){
    chomp $line;
   
    if($line =~ /^#CHROM/){
        last;
    }elsif($line =~ /^#/){
        say $line;
    }else{
        last;
    }
}

print <<HEAD;
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=RD,Number=1,Type=Integer,Description="Reads strongly supporting reference allele for tier 1">
##FORMAT=<ID=AD,Number=1,Type=Integer,Description="Reads strongly supporting alternative allele for tier 1">
##FORMAT=<ID=AF,Number=1,Type=Float,Description="Alternative allele frequency (%) for tier 1">
##FORMAT=<ID=RD2,Number=1,Type=Integer,Description="Reads strongly supporting reference allele for tier 2">
##FORMAT=<ID=AD2,Number=1,Type=Integer,Description="Reads strongly supporting alternative allele for tier 2">
##FORMAT=<ID=AF2,Number=1,Type=Float,Description="Alternative allele frequency (%) for tier 2">
HEAD
if($line =~ /^#CHROM/){
    say $line;
    $line = <IN>;
}

while(defined $line){
    chomp $line;
    
    my @fields = split "\t", $line;
    my ($ref, $alt) = @fields[3, 4];
    my @keys = split ':', $fields[8];
    my @formats = @fields[9..$#fields];
    for my $i(0..$#formats){
        my $format = $formats[$i];
        my @values = split ':', $format;
        my %values;
        $values{$keys[$_]} = $values[$_] for (0..$#keys);
        
        my ($RD, $RD2, $AD, $AD2);
        if(length($ref) == 1 && length($alt) == 1){
            ($RD, $RD2) = split ',', $values{$ref."U"};
            ($AD, $AD2) = split ',', $values{$alt."U"};
        }else{
            ($RD, $RD2) = split ',', $values{TAR};
            ($AD, $AD2) = split ',', $values{TIR};
        }
        my ($GT, $AF);
        if($AD+$RD > 0){
            $AF = sprintf "%.2f", $AD/($AD+$RD)*100;
            if($AF <= $maxRefHomFreq*100){
                $GT = '0/0';
            }elsif($maxRefHomFreq*100 < $AF && $AF < $minAltHomFreq*100){
                $GT = '0/1';
            }else{
                $GT = '1/1';
            }
        }else{
            $AF = '.';
            $GT = '.';
        }
        my $AF2;
        if($AD2+$RD2 > 0){
            $AF2 = sprintf "%.2f", $AD2/($AD2+$RD2)*100;
        }else{
            $AF2 = '.';
        }
        $fields[9+$i] = "$GT:$format:$RD:$AD:$AF:$RD2:$AD2:$AF2";
    }
    $fields[8] = "GT:$fields[8]";
    $fields[8] .= ":RD:AD:AF:RD2:AD2:AF2";
    say join "\t", @fields;
    
    $line = <IN>;
}
