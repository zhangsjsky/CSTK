#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;

my ($tag, $equal, $contain, $less, $greater, $notLess, $notGreater, $warn);
GetOptions(
            't|tag=s'       => \$tag,
            'e|equal=s'     => \$equal,
            'c|contain=s'   => \$contain,
            'l|less=i'      => \$less,
            'g|greater=i'   => \$greater,
            'notLess=i'     => \$notLess,
            'notGreater=i'  => \$notGreater,
            'w|warn'        => \$warn,
            'h|help'        => sub{usage()}
        ) || usage();

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open SAM, "samtools view -h $ARGV[0]|" or die "Can't open $ARGV[0]: $!";
    }else{
        open SAM, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open SAM, "-";
}
while(<SAM>){
    chomp;
    if(/^@/){
        say;
        next;
    }
    my @fields = split "\t";
    my $tags = join "\t", @fields[11..$#fields];
    my $tagValue = &samParser::getTagValue($_, $tag);
    if(defined $tagValue){
        next if defined $equal && $tagValue ne $equal;
        next if defined $contain && $tagValue !~ /$contain/;
        next if defined $less && $tagValue >= $less;
        next if defined $greater && $tagValue <= $greater;
        next if defined $notLess && $tagValue < $notLess;
        next if defined $notGreater && $tagValue > $notGreater;
        say;
    }elsif(defined $warn){
        say STDERR "Warning: no tag $tag in reads $fields[0]";
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.SAM/BAM >OUTPUT.SAM
    If INPUT isn't specified, input as SAM from STDIN
Option:
    -t|tag          STR Which tag to perform the filter on
    -e|equal        STR Only read with tag value equal to STR is passed
    -c|contain      STR Only read with tag value containing to STR is passed
    -l|less         INT Only read with tag value less than INT is passed
    -g|greater      INT Only read with tag value greater than INT is passed
    --notLess       INT Only read with tag value greater than or equal to INT is passed
    --notGreater    INT Only read with tag value less than or equal to INT is passed
    -h|--help       Print this help information
HELP
    exit(-1);
}