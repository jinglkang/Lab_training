#!/usr/bin/perl
use strict;
use warnings;
use Parallel::ForkManager;

# java -jar trimmomatic-0.39.jar PE DaruB10_R1.fq.gz DaruB10_R2.fq.gz 
# Trimmomatic/paired/DaruB10_R1.paired.fq.gz Trimmomatic/unpaired/DaruB10_R1.unpaired.fq.gz 
# Trimmomatic/paired/DaruB10_R2.paired.fq.gz Trimmomatic/unpaired/DaruB10_R2.unpaired.fq.gz 
# ILLUMINACLIP:TruSeq2-PE.fa:2:30:10 LEADING:4 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:40 -threads 10

my @fqs=<*_R1.fq.gz>;
my @cmds;

foreach my $fq (@fqs) {
	(my $name)=$fq=~/(.*)_R1\.fq\.gz/;
	my $forward=$fq;
	my $for_pair=$name."_R1.paired.fq.gz";
	my $for_unpa=$name."_R1.unpaired.fq.gz";

	my $reverse=$name."_R2.fq.gz";
	my $rev_pair=$name."_R2.paired.fq.gz";
	my $rev_unpa=$name."_R2.unpaired.fq.gz";

	my $cmd="java -jar trimmomatic-0.39.jar PE $forward $reverse ";
	$cmd.="Trimmomatic/paired/$for_pair Trimmomatic/unpaired/$for_unpa ";
	$cmd.="Trimmomatic/paired/$rev_pair Trimmomatic/unpaired/$rev_unpa ";
	$cmd.="ILLUMINACLIP:TruSeq2-PE.fa:2:30:10 LEADING:4 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:40 -threads 10";
	#print "$cmd\n";
	push @cmds, $cmd;
}

my $manager = new Parallel::ForkManager(4);
foreach my $cmd (@cmds) {
	$manager->start and next;
	system($cmd);
	$manager->finish;
}
$manager -> wait_all_children;
