#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my $bedFile;
GetOptions(
            'b|bedFile=s'   => \$bedFile,
            'h|help'        => sub{usage()}
        ) || usage();

open BED, "$bedFile" or die "Can't open $bedFile: $!";
my %regionHash;
while(<BED>){
    chomp;
    my ($chr, $start, $end) = split "\t";
    if(defined $regionHash{$chr}){
        push @{$regionHash{$chr}}, [$start, $end];
    }else{
        $regionHash{$chr} = [[$start, $end]];
    }
}
for my $chrStrand (keys %regionHash){
    my @sorted = sort{$a->[0]<=>$b->[0]}(@{$regionHash{$chrStrand}});
    $regionHash{$chrStrand} = \@sorted;
}

$ARGV[0] = '-' unless defined $ARGV[0];
open BG, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
while(<BG>){
    chomp;
    my ($chr, $start, $end) = split "\t";
    for my $region(@{$regionHash{$chr}}){
        my ($regionStart, $regionEnd) = @$region;
        say if $end > $regionStart && $start < $regionEnd;
        last if $regionStart > $end;
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT
    if INPUT isn't specified, input from STDIN
    output to STDOUT

    -h --help       Print this help information
HELP
    exit(-1);
}