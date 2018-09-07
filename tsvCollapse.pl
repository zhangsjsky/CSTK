#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use List::Util;


my ($fieldToCollapse, $method, $joinChar) = (2, 'join', ',');
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.tsv
    If INPUT.tsv isn't specified, input from STDIN
Option:
    -f --field  INT     Which field to collapse[$fieldToCollapse]
    -m --method STR     The collapsing method([join],count,mean)
    -j --join   STR     The char to join the fields[,]
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            'f|field=i'     => \$fieldToCollapse,
            'm|method=s'    => \$method,
            'j|join=s'      => \$joinChar,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

$fieldToCollapse--;
my (%TSV, @TSV);
while(<IN>){
    chomp;
    my @fields = split "\t";
    my $valueToBeCollaped = $fields[$fieldToCollapse];
    
    $fields[$fieldToCollapse] = 'NA';
    my $fields = join "\t", @fields;
    
    push @{$TSV{"$fields"}}, $valueToBeCollaped;
    push @TSV, "$fields";
}

for my $replacedFields(@TSV){
    next if ! exists $TSV{$replacedFields};
    my @values = @{$TSV{$replacedFields}};
    my $collapsedValue;
    if($method eq "join"){
        $collapsedValue = join $joinChar, @values;
    }elsif($method eq "mean"){
        $collapsedValue = &List::Util::sum(@values)/@values;
    }elsif($method eq "count"){
        $collapsedValue = scalar @values;
    }
    my @fields = split "\t", $replacedFields;
    $fields[$fieldToCollapse] = $collapsedValue;
    
    say join "\t", @fields;
    
    delete $TSV{$replacedFields};
}

