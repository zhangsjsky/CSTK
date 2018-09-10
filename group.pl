#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use List::Util qw/sum/;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -g --group  INT The column to do the group to
    -v --value  INT The column to do the group from
    -b --by     STR Group by ['join'], 'sum' or 'count'
    -h --help       Print this help information
HELP
    exit(-1);
}

my ($groupCol, $valueCol, $by);
GetOptions(
            'g|group=i' => \$groupCol,
            'v|value=i' => \$valueCol,
            'b|by=s'    => \$by,
            'h|help'    => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
my %groupHash;
while(<IN>){
    chomp;
    my @fields = split "\t";
    my $groupID = $fields[$groupCol-1];
    my $value = $fields[$valueCol-1];
    push @{$groupHash{$groupID}{value}}, $value;
    $groupHash{$groupID}{line} = $_;
}
for my $groupID(keys %groupHash){
    my @fields = split "\t", $groupHash{$groupID}{line};
    my $groupedResult;
    given($by){
        when($by eq 'sum'){$groupedResult = &sum(@{$groupHash{$groupID}{value}})}
        when($by eq 'count'){$groupedResult = scalar @{$groupHash{$groupID}{value}}}
        when($by eq 'join'){$groupedResult = join ',', @{$groupHash{$groupID}{value}}}
    }
    $fields[$valueCol-1] = join ',', $groupedResult;
    say join "\t", @fields;
}

