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

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >deleterious.vcf 2>benign.vcf
    If input.vcf isn't specified, input from STDIN
Option:
    -h  --help              Print this help information
HELP
}

GetOptions(
            'h|help'    => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
while(<IN>){
    chomp;
    if(/^#/){
        say;
        say STDERR;
        next;
    }
    my @fields = split "\t";
    if($fields[3] =~ /^[ATCG]$/i && $fields[4] =~ /^[ATCG]$/i){
        my $info = $fields[7];
        my @info = split ";", $info;
        my ($damagingCount, $possiblyDamagingCount) = (0 ,0);
        for my $info(@info){
            my ($key, $value) = split "=", $info;
            if ($key eq "SIFT_pred" || $key eq "Polyphen2_HDIV_pred" || $key eq "Polyphen2_HVAR_pred") {
                # For SIFT, D: Deleterious (sift<=0.05); T: tolerated (sift>0.05)
                # For PolyPhen 2 HDIV, D: Probably damaging (>=0.957); P: possibly damaging (0.453<=pp2_hdiv<=0.956); B: benign (pp2_hdiv<=0.452)
                # For PolyPhen 2 HVAR, D: Probably damaging (>=0.909); P: possibly damaging (0.447<=pp2_hdiv<=0.909); B: benign (pp2_hdiv<=0.446)
                $damagingCount++ if $value eq "D";
                $possiblyDamagingCount++ if $value eq "P";
            }
            if($key eq "MutationTaster_pred"){
                # For MutationTaster, A" ("disease_causing_automatic"); "D" ("disease_causing"); "N" ("polymorphism"); "P" ("polymorphism_automatic")
                $damagingCount++ if $value eq "A" || $value eq "D";
            }
        }
        if($damagingCount >= 1 || $possiblyDamagingCount >= 2){
            say;
        }else{
            say STDERR;
        }
    }else{
        say;
    }
}
