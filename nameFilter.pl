#!/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $scriptName=(fileparse($0))[0];
my ($list,$exclude,$input2,$output2,$report,$help);
my $format='fastq';
my $opt=GetOptions(
                        'f|format=s' => \$format,
                        'l|list=s' => \$list,
                        'i|exclude' => \$exclude,
                        'i2=s' => \$input2,
                        'o2=s' => \$output2,
                        'r|report'=>\$report,
                        'h|help' => \$help
                  );
usage() if defined $help;
die "Please specify the list file\n" if !defined $list;

$ARGV[0]='-' unless defined $ARGV[0];
$ARGV[1]='-' unless defined $ARGV[1];
open IN,$ARGV[0] or die "$ARGV[0]:$!";
open OUT,">$ARGV[1]" or die "$ARGV[1]:$!";
die "Please specify both of input2 and output2\n" if (defined $input2 != defined $output2);
my %readName;
open LIST,"$list" or die "$list:$!";
while(<LIST>){#build up the refrence name indxe
    chomp;
    s/^@(.+)/$1/;
    $readName{$_}='';#make mark
}
my ($id,$seq,$quality,$plus);
my ($counterKept,$counterAll)=(0,0);
if($format eq 'fastq'){
    if(!defined $input2){
       while($id=<IN>){
           $id=~m#@(.+)/.*#;
           $seq=<IN>;
           $plus=<IN>;
           $quality=<IN>;
           #die "Error line of '$id' in $ARGV[0]:Are you sure to have input the correct fastq file?\n" unless defined $1;
           if(!defined $exclude == defined $readName{$1}){
                print OUT $id,$seq,$plus,$quality;
                $counterKept++;
           }
           $counterAll++;
       }

    }
    else{
       my ($id2,$seq2,$quality2,$plus2);
       open IN2,"$input2" or die "$input2:$!";
       open OUT2,">$output2" or die "$output2:$!";
       while($id=<IN>){
           $id=~m#@(.+)/.*#;
           $seq=<IN>;
           $plus=<IN>;
           $quality=<IN>;
           $id2=<IN2>;
           $seq2=<IN2>;
           $plus2=<IN2>;
           $quality2=<IN2>;
           if(!defined $exclude == defined $readName{$1}){
                print OUT $id,$seq,$plus,$quality;
                print OUT2 $id2,$seq2,$plus2,$quality2;
                $counterKept++;
           }
           $counterAll++;
       }
    }
}
elsif($format eq 'sam'){
    while(<IN>){
            my @samRead=split "\t",$_;
            if(/^@/){
                print OUT;
            }
            else{
                #die "Error line of '$_' in $ARGV[0]:Are you sure to have input the correct sam file?\n" if ($#samRead<10 ||$samRead[9]!~/[atcgn*=]/i);
                print OUT if (!defined $exclude==defined $readName{$samRead[0]});
            }
        }
}
else{
    my $bedName;
    while(<IN>){
        $bedName=(split "\t",$_)[3];
        #die "Error line of '$_' in $ARGV[0]:Are you to have input the correct bed file?\n" unless defined $bedName;
        print OUT if (!defined $exclude==defined $readName{$bedName});
    }
}
if (defined $report){
    say STDOUT "Read(s):\t$counterAll";
    say STDOUT "Read(s) kept:\t$counterKept";
}
sub usage{
print <<HELP;
Usage:perl $scriptName INPUT.FILE OUTPUT.FILE [-f fastq|sam|beg] -l readName.txt [-e] [--i2 input2.fq --o2 output2.fq] [-r]
    if INPUT.FILE not specified,input from STDIN
    if OUTPUT.FILE not specified,output to STDOUT
    -f --format     format of INPUT.FILE,Default is fastq
    -l --list       the name list file,one name per line
    -e --exclude    (optional)if specified,reads in --list will be discarded otherwise be kept
    --i2            (optional)input file 2 if the format of INPUT.FILE is fastq and reads are pair-end
    --o2            (optional)output file 2 if the format of INPUT.FILE is fastq and reads are pair-end
    -r --report     (optional)Print result report to STDOUT
    -h --help       Print this help information screen
HELP
    exit(-1);
}
