#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;

my ($read1, $read2, $rev);
GetOptions(
            '1'         => \$read1,
            '2'         => \$read2,
            'rev'       => \$rev,
            'h|help'    => sub{usage()}
        ) || usage();

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open IN, "samtools view -h $ARGV[0] |" or die "Can't open $ARGV[0]: $!";
    }else{
        open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open IN, "-";
}

chomp(my $line = <IN>);
while(defined $line){
    chomp $line;
    if($line =~ /^@/){
        say $line;
        $line = <IN>;
    }else{
        last;
    }
}

while(defined $line){
    chomp $line;
    my @fields = split "\t", $line;
    my $flag = $fields[1];
    if(defined $rev){
        if(defined $read1){
            if(samParser::isFirstMate($flag)){
                $flag = samParser::reverseStrand($flag);
            }else{
                $flag = samParser::reverseMateStrand($flag);
            }
        }
        if(defined $read2){
            if(samParser::isFirstMate($flag)){
                $flag = samParser::reverseMateStrand($flag);
            }else{
                $flag = samParser::reverseStrand($flag);
            }
        }
    }
    $fields[1] = $flag;
    say join "\t", @fields;
    $line = <IN>;
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -1              Perform on read1
    -2              Perform on read2
       --rev        Reverse the strand
    -h --help       Print this help information
HELP
    exit(-1);
}
