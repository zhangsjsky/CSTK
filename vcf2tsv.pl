#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my ($infoKeys, $myFormatKeys);
my $indexes = 1;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >output.tsv
    If input.vcf isn't specified, input from STDIN
Option:
    -i  --infoKey       STRs    The comma-separated INFO keys to output
    -f  --formatKey     STRs    The comma-separated FORMAT keys to output
    -s  --sampleIndex   INT     The comma-separated index number (1-start) of sample to be applied with key select[1]
                                'all' can be used specifically to specify all the samples
    -h  --help                  Print this help information
HELP
}

GetOptions(
            'i|infoKey=s'       => \$infoKeys,
            'f|formatKey=s'     => \$myFormatKeys,
            's|sampleIndex=s'   => \$indexes,
            'h|help'            => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my @infoKeys = split ',', $infoKeys if defined $infoKeys;
my @myFormatKeys = split ',', $myFormatKeys if defined $myFormatKeys;
print join "\t", ("#CHROM", qw/POS ID REF ALT QUAL FILTER/);
print join "\t", ("", @infoKeys) if defined $infoKeys;
print join "\t", ("", @myFormatKeys) if defined $myFormatKeys;
print "\n";

my @samples;

while(<IN>){
    chomp;
    if(/^#/){
        if(/^#CHROM/){
            my @fields = split "\t";
            @samples = @fields[9..$#fields];
        }
        next;
    }
    my @fields = split "\t";
    print join "\t", @fields[0..6];
    
    if(defined $infoKeys){
        my @INFOs = split ';', $fields[7];
        my %INFOs;
        for my $INFO(@INFOs){
            my ($key, $value) = split '=', $INFO;
            $INFOs{$key} = $value;
        }
        for my $infoKey(@infoKeys){
            my $value = exists $INFOs{$infoKey} ? $INFOs{$infoKey} : "NA";
            $value =~ s/\\x3b/;/g;
            $value =~ s/\\x3d/=/g;
            print "\t$value";
        }
    }
    
    if (defined $myFormatKeys) {
        my @formatKeys = split ':', $fields[8];
        $indexes = join ',', (1..@samples) if $indexes =~ /all/i;
        for my $index(split ',', $indexes){
            my @formatValues = split ':', $fields[8+$index];
            my %FORMATs;
            $FORMATs{$formatKeys[$_]} = $formatValues[$_] for (0..$#formatKeys);
            for my $myFormatKey(@myFormatKeys){
                my $value = exists $FORMATs{$myFormatKey} ? $FORMATs{$myFormatKey} : "NA";
                $value =~ s/\\x3b/;/g;
                $value =~ s/\\x3d/=/g;
                print "\t$value";
            }
        }
    }
    print "\n";
}

