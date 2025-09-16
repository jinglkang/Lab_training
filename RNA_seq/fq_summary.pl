#!/usr/bin/perl
use strict;
use warnings;

my @txts=<fastqc1/*fastqc/summary.txt>;
my %hash;
foreach my $txt (@txts) {
	open TXT, $txt or die "can not open $txt\n";
	while (<TXT>) {
		my @a=split /\t/;
		if (/FAIL/i || /WARN/i) {
			my $name=$a[0]."\t".$a[1];
			$hash{$name}++;
		}
	}
}

foreach my $key (sort keys %hash) {
	my $nub=$hash{$key};
	print "$key\t$nub\n";
}
