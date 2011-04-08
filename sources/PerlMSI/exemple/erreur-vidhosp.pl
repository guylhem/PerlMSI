#!/usr/bin/perl

## Perl Modules

#use DBI;			   # databases
#use Benchmark;			   # timethis (100, "somesub()");
use Data::Dumper;		   # For good old debugging
use Devel::Size qw(total_size);    # check memory use
use warnings;                      # warn about questionnable syntax
use strict;                        # because I'm new

## PerlMSI Modules

use lib qw{./lib};
use FILEREAD;
use FICHCOMP;
use VIDHOSP;
use RSS;
use RSA;

# Lecture du VIDHOSP
#
my $E_vidhosp=VIDHOSP::readfrom("vidhosp-2009.txt");
print "VIDHOSP : ". $E_vidhosp->nbr . " lignes lues : " . total_size(\$E_vidhosp) . " bytes\n";
print $E_vidhosp->distinct_iep . " iep uniques " . $E_vidhosp->distinct_ss . " ss uniques\n";

# Extraction des cas hors cpam
#
my @noncpam=$E_vidhosp->noncpam;
foreach my $erreur (@noncpam) {
print "IEP= " . $$erreur{IEP} . " SS= " .  $$erreur{SS} . " : " .  $$erreur{NOTE} . "\n";
} # foreach

