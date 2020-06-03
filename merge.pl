#!/mnt/share/share/local/bin/perl -w
use strict;
use Getopt::Long;

my $outdir;
GetOptions("outdir=s"=>\$outdir);
$outdir ||=".";
$outdir = &abs_path ($outdir);
@ARGV==2 || die"Usage:perl $0 --outdir test <input.list> <out.merge.tab>\n";
my ($infile,$outfile)=@ARGV;
my (%gene_sam);
my @samp;
for(`less $infile`){
    chomp;
    my @l=split;
    my ($sample,$file)=@l;
    push @samp,$sample;
    for(`less $file`){
        chomp;
        $gene_sam{$_}->{$sample}=1;
    }
}

open OUT,">$outfile" || die$!;
print OUT join("\t","Gene",@samp,"Sample")."\n";
my %type_num;
my %type_gene;
for my $gene (sort keys %gene_sam){
    print OUT "$gene";
    my @check_sam;
#    my %type_num;
    for my $sample(@samp){
        $gene_sam{$gene}->{$sample} ||= 0;
        if($gene_sam{$gene}->{$sample}==1){
            push @check_sam,$sample;
        }
        print OUT "\t$gene_sam{$gene}->{$sample}";
    }
    my $type = join("+",@check_sam);
    $type_num{$type}++;
    push @{$type_gene{$type}},$gene;
    print OUT "\t$type\n";
}
close OUT;

#for my $Type (sort keys %type_num){
#    open OUTLOG,">>$outdir/coregene.log";
#    print OUTLOG "$Type\t$type_num{$Type}\n";
#    close OUTLOG;
#    open OUT1,">$outdir/$Type.gene.list" || die$!;
#    print OUT1 join("\n",@{$type_gene{$Type}})."\n";
#    close OUT1;
#}
sub abs_path {
        chomp(my $temdir = `pwd`);
            ($_[0] =~ /^\//) ? $_[0] : "$temdir/$_[0]";
}
