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
use lib dirname $0;
use pm::common;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION read.fq(.gz) >OUTPUT.tsv
    If read.fq(.gz) isn't specified, input from STDIN
Option:
    -2  --read2     FQ      The read2 file
    -h  --help              Print this help information
HELP
}

my $read2;
GetOptions(
            '2|read2=s'     => \$read2,
            'h|help'        => sub{usage(); exit}
) || usage();


if(defined $ARGV[0]){
    if(`file -L $ARGV[0]` =~ /gzip/){
        open IN,"gzip -dc $ARGV[0]|" or die "Can't read file ($ARGV[0]): $!";
    }else{
        open IN,"$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
    }
}else{
    open IN, "-" or die "Can't read file ($ARGV[0]): $!";
}
if(defined $read2){
    if(`file -L $read2` =~ /gzip/){
        open READ2,"gzip -dc $read2|" or die "Can't read file ($read2): $!";
    }else{
        open READ2,"$read2" or die "Can't read file ($read2): $!";
    }
}

my ($baseCount1, $totalQual1, $baseCount2, $totalQual2);
my (%profile1, %profile2);
while(<IN>){
    <IN>;
    <IN>;
    my $qualLine = <IN>;
    chomp $qualLine;
    for my $base(split '', $qualLine){
        my $qual = ord($base) - 32;
        $totalQual1 += $qual;
        my $tile = int($qual/10) * 10;
        $profile1{$tile}++;
    }
    $baseCount1 += length $qualLine;
}
my $maxTile = (sort{$b<=>$a}keys %profile1)[0];

if(defined $read2){
    while(<READ2>){
        <READ2>;
        <READ2>;
        my $qualLine = <READ2>;
        chomp $qualLine;
        for my $base(split '', $qualLine){
            my $qual = ord($base) - 32;
            $totalQual2 += $qual;
            my $tile = int($qual/10) * 10;
            $profile2{$tile}++;
        }
        $baseCount2 += length $qualLine;
    }
    my $tmp = (sort{$b<=>$a}keys %profile2)[0];
    $maxTile = $tmp if $tmp > $maxTile;
}


print "Base\t$baseCount1";
if(defined $read2){
    say "\t$baseCount2"
}else{
    print "\n";
}

my ($cumPercent1, $cumPercent2) = (0, 0);
for(my $tile = $maxTile; $tile >= 0; $tile-=10){
    $cumPercent1 += $profile1{$tile}/$baseCount1*100 if defined $profile1{$tile};
    print join "\t", ("Q$tile", sprintf "%.2f", $cumPercent1);
    if(defined $read2){
        $cumPercent2 += $profile2{$tile}/$baseCount2*100 if defined $profile2{$tile};
        say join "\t", ("", sprintf "%.2f", $cumPercent2);
    }else{
        print "\n";
    }
}

print join "\t", ("Mean", sprintf "%.2f", $totalQual1/$baseCount1);
if(defined $read2){
    say "\t" . sprintf "%.2f", $totalQual2/$baseCount2;
}else{
    print "\n";
}