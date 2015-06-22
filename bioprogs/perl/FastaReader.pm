#!/usr/bin/perl -w

# Class for reading fasta files conveniently
# Author:	Angermueller Christof
# Date:		10-04-19

package FastaReader;

use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);

sub new {
	my ($pkg, $file) = @_;
	open my $fh, "< $file" or die $!;
	my $self = {
		FH => $fh,
		TAG => ""
	};
	bless($self, $pkg);
	$self->next;
	return $self;
}

sub next {
	(my $self) = @_;
	my $fh = $self->{FH};
	my $tag = $self->{TAG};
	$self->{TAG} = "";
	my $seq = "";
	while (<$fh>) { 
		if (/^>(.+)\s*$/) {
			$self->{TAG} = $1;
			if ($tag && $seq) { last; }
			$tag = $1;
		} elsif ($tag) {
			chomp;
			s/\s+$//;
			$seq .= $_;
		}
	}
	my $next = $self->{NEXT};
	if ($tag && $seq) { $self->{NEXT} = [$tag, $seq]; }
	else { $self->{NEXT} = undef; }
	if ($next) { return $next; }
	else { return undef; }
}

sub has_next {
	(my $self) = @_;
	return defined($self->{NEXT});
}

sub close {
	(my $self) = @_;
	close $self->{FH};
}

return 1;

