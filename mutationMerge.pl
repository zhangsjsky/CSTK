#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION sample1/knownDriverGene/deleterious.vcf.gz [sample2/knownDriverGene/deleterious.vcf.gz [sample3/knownDriverGene/deleterious.vcf.gz ...] >deleterious.all.tsv
    If INPUT.vcf isn't specified, input from STDIN
Option:
    -s  --sampleName    STRs    The comma-separated sample names.
    -m  --mark          STR     The mark of freq column, eg AF for Mutect and FREQ for Varscan, default(FREQ).
    -h  --help                  Print this help information
HELP
    exit;
}

@ARGV<1 && usage();
my $sampleNames;
my $mark;
GetOptions(
            's|sampleName=s'    => \$sampleNames,
            'm|mark=s'          => \$mark,
            'h|help'            => sub{usage(); exit}
) || usage();

my @sampleNames;
$mark ||= "FREQ";
if(defined $sampleNames){
    @sampleNames = split/,/, $sampleNames ;
}else{
    die "Please specify the sample names\n";
}

my (%mut_sample,%mut_gene);
for(my $i = 0; $i <=$#ARGV; $i++){
    my $file = $ARGV[$i];
    ($file =~/\.gz$/) ? (open(IN,"gzip -dc $file|") || die$! ) : (open IN,$file || die$!);
    while(<IN>){
        /^#/ && next;
        chomp $_;
        my @l=split/\t/;
        my ($chr,$pos,$ref,$alt,$info,$format,$tumor)=@l[0,1,3,4,7,8,9];
        my $locus = "$chr:$pos:$ref-\>$alt";
        my $mark_num;
        my @format_tmp = split/:/,$format;
        for my $num (0 .. scalar(@format_tmp)-1){
            if($format_tmp[$num] eq $mark){
                $mark_num =$num;
            }else{
                next;
            }
        }
        my @tumor_arr = split/:/,$tumor;
        my $freq = $tumor_arr[$mark_num];
        my $gene = $1 if($info=~/Gene.refGene=(\S+)\;/);
        $gene ||= "None";
        $gene =~ s/\\x3b/,/;
        my @tmp = split/;/,$gene;
        $gene = $tmp[0];
        $mut_sample{$locus}->{$sampleNames[$i]}=$freq;
        $mut_gene{$locus} ||=$gene;
    }
    close IN;
}

print join("\t","Mutation","Gene.refGene",@sampleNames)."\n";
for my $locus (sort keys %mut_sample){
    print "$locus\t$mut_gene{$locus}";
    for my $sample (@sampleNames){
        $mut_sample{$locus}->{$sample} ||=0;
        print "\t$mut_sample{$locus}->{$sample}";
    }
    print "\n";
}

