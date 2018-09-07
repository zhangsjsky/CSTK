#!/bin/env perl
use strict;
use warnings;
use 5.010;
use Getopt::Long;
use File::Basename;
my $scriptName=(fileparse($0))[0];
#my ($source,$target)=('fastq-illumina','fastq-illumina');
my ($adaptor,$adaptor2)=('ACACTCTTTCCCTACACGACGCTCTTCCGATCT','CTCGGCATTCCTGCTGAACCGCTCTTCCGATCT');
my ($input,$output,$input2,$output2,$report,$help);
my $opt=GetOptions(
                        'a=s'=>\$adaptor,
                        'i=s' => \$input,
                        'o=s' => \$output,
                        'a2=s'=>\$adaptor2,
                        'i2=s' => \$input2,
                        'o2=s' => \$output2,
                        'r|report'=>\$report,
                        'h|help'=> \$help
                        );
usage() if(defined $help);
if(defined $input){
   open STDIN,"<$input" or die "$input:$!";
}
unless( (defined $input2 && defined $output2) || (!defined $input2 && !defined $output2) ){
    say "Please specify all the argument values of --i2 and --o2"
}
if(defined $output){
   open OUT,">$output" or die "$output:$!";
   select OUT;
}
my ($id,$seq,$plus,$quality);
my ($counterOfDiscard,$counterOfAll)=(0,0);
if (!defined $input2){
   while($id=<STDIN>){
       $seq=<STDIN>;
       $plus=<STDIN>;
       $quality=<STDIN>;
       if($seq!~/^$adaptor/){
            print $id,$seq,$plus,$quality;
       }
       else{
            $counterOfDiscard++;
       }
       $counterOfAll++;
   }
}
else{
    my ($id2,$seq2,$plus2,$quality2);
    open IN2,"<$input2" or die "$input2:$!";
    open OUT2,">$output2" or die "$output2:$!";
    while($id=<STDIN>){
       $seq=<STDIN>;
       $plus=<STDIN>;
       $quality=<STDIN>;
       $id2=<IN2>;
       $seq2=<IN2>;
       $plus2=<IN2>;
       $quality2=<IN2>;
       if($seq!~/^$adaptor/ && $seq2!~/^$adaptor2/){
          print $id,$seq,$plus,$quality;
          print OUT2 $id2,$seq2,$plus2,$quality2;
       }
       else{
            $counterOfDiscard++;
       }
       $counterOfAll++;
    }

}
if(defined $report){
    select STDOUT;
    say "No.Reads of All=\t$counterOfAll";
    say "No.Reads discarded by $scriptName=\t$counterOfDiscard";
}
open REPORT,">report.txt" or die $!;
say REPORT "No.Reads of All=\t$counterOfAll";
say REPORT "No.Reads discarded by $scriptName=\t$counterOfDiscard";
sub usage{
print <<HELP;
Usage:perl $scriptName [-a ACACTCTTTCCCTACACGACGCTCTTCCGATCT] [-i input.fq] [-o output.fq] [--i2 input2.fq --o2 output2.fq]

    -a         adapter sequence,default is ACACTCTTTCCCTACACGACGCTCTTCCGATCT(Illumina Paired End Adapter 1)
    -i         input file,default is STDIN
    -o         output file,default is STDOUT
    --a2       adaptor2 sequence,default is CTCGGCATTCCTGCTGAACCGCTCTTCCGATCT(Illumina Paired End Adapter 2)
    --i2       (optional)input file 2 if the reads are pair
    --o2       (optional)output file 2 if the reads are pair
    -r --report Print result report
    -h --help   This help information screen
HELP
    exit(-1);
}
