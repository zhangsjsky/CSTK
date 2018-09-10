#!/bin/env perl
use strict;
use 5.010;
use strict;
use File::Basename;
use Getopt::Long;
use lib dirname $0;
use pm::common;

my ($delimiter, $columnN, $help) = ("\t");
my $opt=GetOptions(
                        'd|delimiter=s'   => \$delimiter,
                        'c|column=s'      => \$columnN,
                        'h|help'          => sub{usage()}
                  ) || usage();
$ARGV[0]='-' if !defined $ARGV[0];
open IN, $ARGV[0] or die "Can't open $ARGV[0]: $!";

my $maxColumnNO = 0;
if(!defined $columnN){
     $maxColumnNO = &common::getColumnNumber(\*IN);
     close IN;
     open IN,$ARGV[0];
}else{
     $maxColumnNO = $columnN;
}
while(<IN>){
       chomp;
       my @fields=split "$delimiter";
       if (@fields < $maxColumnNO){
            for(my $i = @fields; $i < $maxColumnNO; $i++){
                push @fields, '';
            }
       }
       say join "$delimiter", @fields;
}
sub usage{
     my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.tsv
    if INPUT.tsv isn't specified, input from STDIN
    output to STDOUT
    
    -d --delimiter  STRING    Delimter to split line[tab]
    -c --column     INT       Column number upto which line is appended. Force when INPUT from STDIN
    -h --help                 Print this help information
HELP
    exit(-1);
}
