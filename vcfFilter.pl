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

my ($fExclusions);
my ($minDP, $infoKey, $maxValueOfKey, $minValueOfKey, $equalToValueOfKey, $valueList);
my ($GT, $fMinDP, $fMinAltDepth, $fMaxAltDepth, $fMinFreq, $fMaxFreq, $minGQ, $minFR);
my $indexes = 1;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >flt.vcf 2>discarded.vcf
    If input.vcf isn't specified, input from STDIN
Option:
  FILTER
    -F  --fExclusion        STRs    Discard if any the listed FILTER string presented
                                    (e.g. germline_risk,t_lod_fstar,alt_allele_in_normal)
  INFO
    -d  --minDP             INT     The minimal INFO/DP for a record to be kept
    -k  --infoKey           STR     Specify the key in INFO to applied filter
        --maxValueOfKey     DOU     The maximal value of the key specified by --infoKey
        --minValueOfKey     DOU     The minimal value of the key specified by --infoKey
        --equalToValueOfKey DOU     Keep record with value of the key (specified by --infoKey) equal to --equalToValueOfKey
    -l  --valueList         TSV     Keep record with value of the key (specified by --infoKey) listed in this file
                                    Column: value. Extra column is supported but only the first column used as value.
  FORMAT
    -g  --GT                REP     The FORMAT/GT for a record to be kept
                                    E.g.: 0[/|]1
        --fMinDP            INT     The minimal FORMAT/DP for a record to be kept.
                                    Also works when DP isn't presented but AD is presented (for MuTect2).
        --fMinAltDepth      INT     The minimal alt allele depth (according to FORMAT/AD or FORMAT/DP4)
        --fMaxAltDepth      INT     The maximal alt allele depth (according to FORMAT/AD or FORMAT/DP4)
        --fMinFreq          DOU     The minimal alt allele frequency (according to FORMAT/FREQ, FORMAT/AF, FORMAT/RD, FORMAT/AD or FORMAT/DP4)
        --fMaxFreq          DOU     The maximal alt allele frequency (according to FORMAT/FREQ, FORMAT/AF, FORMAT/RD, FORMAT/AD or FORMAT/DP4)
    -q  --minGQ             INT     The minima FORMAT/GQ for a record to be kept
    -i  --sampleIndex       INTs    The comma-separated index numbers (1-start) of samples to be applied with FORMAT-related filter[1]
        --minFR             [0,1]   The min ratio of tumor freq/normal freq. Tumor and normal index are specified by --sampleIdex in order of tumor and normal
    -h  --help                      Print this help information
HELP
}

GetOptions(
            'F|fExclusion=s'        => \$fExclusions,
                                    
            'd|minDP=i'             => \$minDP,
            'k|infoKey=s'           => \$infoKey,
            'maxValueOfKey=s'       => \$maxValueOfKey,
            'minValueOfKey=s'       => \$minValueOfKey,
            'equalToValueOfKey=s'   => \$equalToValueOfKey,
            'l|valueList=s'         => \$valueList,
                                    
            'g|GT=s'                => \$GT,
            'fMinDP=i'              => \$fMinDP,
            'fMinAltDepth=i'        => \$fMinAltDepth,
            'fMaxAltDepth=i'        => \$fMaxAltDepth,
            'fMinFreq=s'            => \$fMinFreq,
            'fMaxFreq=s'            => \$fMaxFreq,
            'q|minGQ=i'             => \$minGQ,
            'i|sampleIndex=s'       => \$indexes,
            'minFR=s'               => \$minFR,
            'h|help'                => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
my %values;
if(defined $valueList){
    open LIST, $valueList or die "Can't read file ($valueList): $!";
    while(<LIST>){
        chomp;
        my $value = (split "\t")[0];
        $values{$value} = '';
    }
}

RECORD:
while(<IN>){
    chomp;
    if(/^#/){
        say;
        say STDERR;
        next;
    }
    
    my @fields = split "\t";
    
    if(defined $fExclusions){
        my @filters = split ';', $fields[6];
        my %filters = map{($_, '')}@filters;
        my @fExclusions = split ',', $fExclusions;
        for my $fExclusion (@fExclusions){
            if(exists $filters{$fExclusion}){
                say STDERR;
                next RECORD;
            }
        }
        say;
        next;
    }
    
    if(defined $minDP || defined $infoKey){
        my $INFOs = $fields[7];
        my @INFOs = split ';', $INFOs;
        my %INFOs;
        for my $INFO(@INFOs){
            my ($key, $value) = split '=', $INFO;
            $INFOs{$key} = $value;
        }
        
        if(defined $minDP && $INFOs{DP} >= $minDP){
            say;
            next;
        }
        
        if(defined $equalToValueOfKey && $equalToValueOfKey eq $INFOs{$infoKey}){
            say;
            next;
        }
        
        if(defined $maxValueOfKey){
            if($INFOs{$infoKey} eq '.' || $INFOs{$infoKey} <= $maxValueOfKey){
                say;
                next;
            }
        }
        
        if(defined $minValueOfKey){
            if($INFOs{$infoKey} eq '.' || $INFOs{$infoKey} >= $minValueOfKey){
                say;
                next;
            }
        }
        
        if(defined $valueList){
            my $infoValue = $INFOs{$infoKey};
            if(exists $values{$infoValue}){
                say;
                next;
            }
        }
    }
    if (defined $GT || defined $fMinDP || defined $fMinAltDepth || defined $fMaxAltDepth || defined $fMinFreq || defined $fMaxFreq || defined $minGQ) {
        my @indexes = split ',', $indexes;
        for my $index(@indexes){
            my @keys = split ':', $fields[8];
            my @values = split ':', $fields[8+$index];
            my %FORMATs;
            $FORMATs{$keys[$_]} = $values[$_] for (0..$#keys);
            
            if(defined $GT && $FORMATs{GT} =~ /$GT/){
                say;
                next RECORD;
            }
            
            if(defined $fMinDP){
                if(defined $FORMATs{DP}){ # For VarScan2/GATK
                    next RECORD if $FORMATs{DP} eq '.';
                    if($FORMATs{DP} >= $fMinDP) {
                        say;
                        next RECORD;
                    }
                }elsif(defined $FORMATs{AD}){ # For MuTect2
                    my ($RD, $AD) = split ',', $FORMATs{AD};
                    my $DP = $RD + $AD;
                    if($DP >= $fMinDP) {
                        say;
                        next RECORD;
                    }
                }else{
                    say;
                    next RECORD;
                }
            }
            
            if(defined $fMinAltDepth){
                if(defined $FORMATs{AD}){
                    my @ADs = split ',', $FORMATs{AD};
                    my $altDepth = @ADs == 1 ? $ADs[0]:$ADs[1];
                    if($altDepth >= $fMinAltDepth) {
                        say;
                        next RECORD;
                    }
                }elsif(defined $FORMATs{DP4}){
                    my @DP4 = split ',', $FORMATs{DP4};
                    if($DP4[2] + $DP4[3] >= $fMinAltDepth) {
                        say;
                        next RECORD;
                    }
                }else{
                    say;
                    next RECORD;
                }
            }
            
            if(defined $fMaxAltDepth){
                if(defined $FORMATs{AD}){
                    my @ADs = split ',', $FORMATs{AD};
                    my $altDepth = @ADs == 1 ? $ADs[0]:$ADs[1];
                    if($altDepth <= $fMaxAltDepth) {
                        say;
                        next RECORD;
                    }
                }elsif(defined $FORMATs{DP4}){
                    my @DP4 = split ',', $FORMATs{DP4};
                    if($DP4[2] + $DP4[3] <= $fMaxAltDepth) {
                        say;
                        next RECORD;
                    }
                }else{
                    say;
                    next RECORD;
                }
            }
            
            if(defined $fMinFreq){
                my $freq = &getFreq(\%FORMATs);
                if(!defined $freq || $freq >= $fMinFreq){
                    say;
                    next RECORD;
                }
            }
            
            if(defined $fMaxFreq){
                my $freq = &getFreq(\%FORMATs);
                if(!defined $freq || $freq <= $fMaxFreq){
                    say;
                    next RECORD;
                }
            }
            
            if (defined $minGQ && $FORMATs{GQ} >= $minGQ) {
                say;
                next RECORD;
            }
        }
    }
    if(defined $minFR){
        my @keys = split ':', $fields[8];
        my @indexes = split ',', $indexes;
        
        my @values = split ':', $fields[8+$indexes[0]];
        my %FORMATs;
        $FORMATs{$keys[$_]} = $values[$_] for (0..$#keys);
        my $tumorFreq = &getFreq(\%FORMATs);
        
        @values = split ':', $fields[8+$indexes[1]];
        $FORMATs{$keys[$_]} = $values[$_] for (0..$#keys);
        my $normalFreq = &getFreq(\%FORMATs);
        if($normalFreq == 0 || $tumorFreq/$normalFreq >= $minFR){
            say;
            next;
        }
    }
    say STDERR;
}

sub getFreq{
    my ($FORMATs) = @_;
    my %FORMATs = %$FORMATs;
    my $freq;
    if(defined $FORMATs{FREQ}){
        $freq = $FORMATs{FREQ};
        if($freq =~ /%/){
            $freq =~ s/%//;
            $freq /= 100;
        }
    }elsif(defined $FORMATs{AF}){
        my @AFs = split ',', $FORMATs{AF};
        if(@AFs == 1){
            $freq = $AFs[0];
        }else{
            $freq = $AFs[1];
        }
    }elsif(defined $FORMATs{AD}){
        my @ADs = split ',', $FORMATs{AD};
        my ($refDepth, $altDepth);
        if(@ADs == 1){
            $altDepth = $ADs[0];
            $refDepth = $FORMATs{RD};
        }else{
            ($refDepth, $altDepth) = @ADs;
        }
        $freq = $altDepth/($refDepth+$altDepth) if $refDepth+$altDepth >0;
    }elsif(defined $FORMATs{DP4}){
        my @DP4 = split ',', $FORMATs{DP4};
        $freq = ($DP4[2] + $DP4[3])/($DP4[0] + $DP4[1] + $DP4[2] + $DP4[3]);
    }
    return $freq;
}
