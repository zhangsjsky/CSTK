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

my ($freqLe, $info, $infoValue);
my ($GT);
my $indexes = 1;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >modified.vcf
    If input.vcf isn't specified, input from STDIN
Option:
  Condition
        --freqLe          DOU     The frequency (range in 0-1) less or equal than DOU
  Opertaion
    -g  --GT              STR     Modifiy GT as <STR>
        --info            STR     The INFO tag
        --infoValue       STR     Set info tag (specified by --info) as STR
    -i  --sampleIndex     INTs    The comma-separated index numbers (1-start) of samples to be applied[1]
    -h  --help                    Print this help information
HELP
}

GetOptions(
            'freqLe=s'          => \$freqLe,
                            
            'info=s'            => \$info,
            'infoValue=s'       => \$infoValue,
            'g|GT=s'            => \$GT,
            'i|sampleIndex=s'   => \$indexes,
            'h|help'            => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";


while(<IN>){
    chomp;
    if(/^#/){
        say;
        next;
    }
    
    my @fields = split "\t";
    my @formatKeys = split ':', $fields[8];
    my $toModified = 'Y';
    my $INFOs = $fields[7];
    my @INFOs = split ';', $INFOs;
    my (%INFOs, @infoKeys);
    for my $INFO(@INFOs){
        my ($key, $value) = split '=', $INFO;
        $INFOs{$key} = $value;
        push @infoKeys, $key;
    }
    
    my @indexes = split ',', $indexes;
    for my $index(@indexes){
        my @values = split ':', $fields[8+$index];
        my %key2value;
        $key2value{$formatKeys[$_]} = $values[$_] for (0..$#formatKeys);
        my $freq = $key2value{FREQ};
        if($freq =~ /%$/){
            $freq =~ s/%$//;
            $freq /= 100;
        }

        if(defined $freqLe && $freq > $freqLe){
            $toModified = 'N';
        }
    }
    
    if($toModified eq 'Y'){
        if(defined $info){
            if(defined $infoValue){
                $INFOs{"$info"} = $infoValue;
            }
        }
        my @newINFOs;
        for my $key(@infoKeys){
            if(defined $INFOs{$key}){
                push @newINFOs, "$key=$INFOs{$key}";
            }else{
                push @newINFOs, "$key";
            }
        }
        $fields[7] = join ";", @newINFOs;
        
        for my $index(@indexes){
            my @values = split ':', $fields[8+$index];
            my %key2value;
            $key2value{$formatKeys[$_]} = $values[$_] for (0..$#formatKeys);

            if(defined $GT){
                $key2value{GT} = $GT;
            }
            
            my @newValues;
            for my $formatKey(@formatKeys){
                push @newValues, $key2value{$formatKey};
            }
            $fields[8+$index] = join ":", @newValues;
        }
    }
    say join "\t", @fields;
    say STDERR join "\t", @fields if $toModified eq 'Y';
}
