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

# Lecture des RSA
my $E_rsa_2009 = RSA::readfrom("rsa-2009.txt");
$E_rsa_2009 ->RSA::tocsv;

# FIXME: Use of uninitialized value in concatenation (.) or string at
# lib/FILEREAD.pm line 71, <IFD> line 63688.

