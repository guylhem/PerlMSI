#!/usr/bin/perl -w

################## CONVENTIONS : you may not like them but show unicity!
#
# Bastard OOP syntax is used: OO is only used to bind subs to data classes.
# That means instances are not built as $obj->methodnew; but $obj=Obj::method;
#
# Likewise, hashes are used to hard code field names:
#
# - To read files which formats may change every year, hashes of arrays
# are used for an easier read by class functions : each a field name is
# a hash key, the hash value being an array where the original line
# number is the index. Empty range are kept if necessary, but the
# total number of lines read should be accessed through class method E->nbr; 
#
# - To generate internal structures, arrays of hashes are used instead but
# for the same reasons : each array entry is a generated record stored
# as a hash whose key is the variable name and whole value is the
# variable content.  Thus, the total number of lines read is the
# size of the I array
#
# For dereferencing, -> and {} are not used to avoid confusion with
# subs and hashes. $$ is prefered instead.
#
# Anonymous hashes are created for I arrays of hashes because there are
# usually very little values. Temporary arrays are used for E hashes of
# arrays because of the frequent format changes depending on year/versions
#
# A minimal hungarian notation is used:
# * by prefix : I=AoH, E=HoA
# * by type : hash keys=CAPS, arrays index=line number
# * by suffix : _nbr for a total, _cur for the current value in a loop,
# FD for file descriptors, _read for the line currently being read
#
# On nesting, closing braces are always followed by a comment like #sub,
# #if, #while, etc.
#
################## MODULES : the least the faster!

#use DBI; # databases
#use Benchmark; # for optimisation with timethis (100, "somesub()"); 
use Devel::Size qw(total_size); # To check memory use
use warnings; # warn about questionnable syntax
use strict; # because I'm new

{ package CasErreur;
# Complain where ooperl routines are called from
use Carp qw(croak);
use warnings;
use strict;

sub list {
  my $I_self  = shift;
# Allow the creation of new objects from existing ones, inheriting methods
  my $nonfacturables_nbr=@$I_self;
  my $nonfacturable_cur=0;

  while ($nonfacturable_cur<$nonfacturables_nbr) {
  print "IEP= " . $$I_self[$nonfacturable_cur]{IEP} . " SS= " .
  $$I_self[$nonfacturable_cur]{SS} . " : " .
  $$I_self[$nonfacturable_cur]{NOTE} . "\n";
  $nonfacturable_cur++;
  } # while
} # sub liste

1;
} # Package CasErreur 

{ package Vidhosp;
use warnings;
use strict;
# Complain where ooperl routines are called from
use Carp qw(croak);

################################################################################
# In : filename
# Out : E_vidhosp

sub readfrom {
  my $infile = shift;
# Allow the creation of new objects from existing ones, inheriting methods

# The future result
  my $E_result  = {};

# Arrays going into E_result will  be filled with values to be read
my @SS;
my @CLEF_SS;
my @CODE_GRAND_REGIME;
my @NAISSANCE;
my @SEXE;
my @IEP;
my @EXONERATION_TM;
my @PRISE_EN_CHARGE_FJ;
my @NATURE_ASSURANCE;
my @TYPE_COMPLEMENTAIRE;
my @FACTURABLE_CPAM;
my @NON_FACTURATION_CPAM;
my @FACTURATION_18EUR;
my @NBR_VENUES_FACTURE;
my @TR_FACTURER_TM;
my @TR_FACTURER_FJ;
my @TR_REMBOURSABLE_CPAM;
my @TR_PARCOURS_SOIN;
my @TR_BASE_REMBOURSEMENT;
my @TX_REMBOURSEMENT;

open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

my $line_cur = 0;
while ( my $line_read = <IFD> ) {
 if (length($line_read)==107 + 2) {
   # 107=format C, Vidhosp 2009, 2 : \r\n
   ($SS[$line_cur],$CLEF_SS[$line_cur],$CODE_GRAND_REGIME[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$TYPE_COMPLEMENTAIRE[$line_cur],$FACTURABLE_CPAM[$line_cur],$NON_FACTURATION_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur],$TR_BASE_REMBOURSEMENT[$line_cur],$TX_REMBOURSEMENT[$line_cur])=unpack("A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A1 A3 A10 A10 A10 A4 A10 A5", $line_read);
    $line_cur++;
  } elsif (length($line_read)==106 + 2) {
   # 106=format B, Vidhosp 2007, 2 : \r\n
   ($SS[$line_cur],$CLEF_SS[$line_cur],$CODE_GRAND_REGIME[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$TYPE_COMPLEMENTAIRE[$line_cur],$FACTURABLE_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur],$TR_BASE_REMBOURSEMENT[$line_cur],$TX_REMBOURSEMENT[$line_cur])=unpack("A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A3 A10 A10 A10 A4 A10 A5", $line_read);
    $line_cur++;
  } elsif (length($line_read)==85 + 2) {
   # 85=Vidhosp 2007, 2 : \r\n
   ($SS[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$FACTURABLE_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur])=unpack("A13 A8 A1 A20 A1 A1 A2 A1 A1 A3 A10 A10 A10 A4", $line_read);
    $line_cur++;
  } elsif (length($line_read)==42 + 2) {
   # 42=format A, Vidhosp 2006, 2 : \r\n
   ($SS[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur]) =unpack("A13 A8 A1 A20", $line_read);
    $line_cur++;
  }
# if length
 }
  # while close (IFD);
# Store metadata as direct hash keys
  $$E_result{NBR}=$line_cur;
# Store decoding information for the above arrays as hashes of hashes
  $$E_result{NOTE_SEXE}= { 1=> "homme", 2=> "femme"};
  $$E_result{NOTE_FACTURABLE_CPAM}={0 => "non", 1 => "oui", 2 => "attente de
decision sur le taux de prise en charge du patient", 3=> "attente de decision sur les droits du patient"};
  $$E_result{NOTE_NON_FACTURATION_CPAM}={1 => "aide medical etat", 2 => "convention internationale", 3 => "payant", 4 => "soins urgents art L-254.1 CASF", 9 => "autre situation"};
# NATURE_ASS : valeur illicite (i.e. pas à {10, 13, 30, 41, 90, XX})
# PEC FJ : valeur illicite (i.e. pas  [A,L,R,X])
# EXO TM : 1 : valeur illicite (i.e. pas [0,1,2,3,4,5,6,7,8,9,C,X])

# Add a reference to the arrays where content was read
$$E_result{SS}=\@SS;
$$E_result{CLEF_SS}=\@CLEF_SS;
$$E_result{CODE_GRAND_REGIME}=\@CODE_GRAND_REGIME;
$$E_result{NAISSANCE}=\@NAISSANCE;
$$E_result{SEXE}=\@SEXE;
$$E_result{IEP}=\@IEP;
$$E_result{EXONERATION_TM}=\@EXONERATION_TM;
$$E_result{PRISE_EN_CHARGE_FJ}=\@PRISE_EN_CHARGE_FJ;
$$E_result{NATURE_ASSURANCE}=\@NATURE_ASSURANCE;
$$E_result{TYPE_COMPLEMENTAIRE}=\@TYPE_COMPLEMENTAIRE;
$$E_result{FACTURABLE_CPAM}=\@FACTURABLE_CPAM;
$$E_result{NON_FACTURATION_CPAM}=\@NON_FACTURATION_CPAM;
$$E_result{FACTURATION_18EUR}=\@FACTURATION_18EUR;
$$E_result{NBR_VENUES_FACTURE}=\@NBR_VENUES_FACTURE;
$$E_result{TR_FACTURER_TM}=\@TR_FACTURER_TM;
$$E_result{TR_FACTURER_FJ}=\@TR_FACTURER_FJ;
$$E_result{TR_REMBOURSABLE_CPAM}=\@TR_REMBOURSABLE_CPAM;
$$E_result{TR_PARCOURS_SOIN}=\@TR_PARCOURS_SOIN;
$$E_result{TR_BASE_REMBOURSEMENT}=\@TR_BASE_REMBOURSEMENT;
$$E_result{TX_REMBOURSEMENT}=\@TX_REMBOURSEMENT;

  bless ($E_result, "Vidhosp");
  return ($E_result);
  }
# sub readfrom

################################################################################
# In: Vidhosp
# Out: Array of hashes : [{IEP, SS, CODE, NOTE}]
sub nonfacturables {
  my $E_self = shift;
  my $line_nbr=$$E_self{NBR};
  my $line_cur=0;
  my @I_result;
  while ($line_cur < $line_nbr) {
    if ($$E_self{FACTURABLE_CPAM}[$line_cur] == "1") {
        # it is supposed to be valid but must ^1 2 5 6 7 8
         if ($$E_self{SS}[$line_cur] =~ m /^[3,4,9,0]/ ) {
          my $reason='-1';
          my $note=" ne commence pas par 1 2 5 6 7 8";
          push (@I_result, { IEP=> $$E_self{IEP}[$line_cur], SS=> $$E_self{SS}[$line_cur], CODE=> $reason, NOTE => $note} );
         } else {
         if ($$E_self{CLEF_SS}[$line_cur] =~ m/\d+/ && $$E_self{SS}[$line_cur] =~ m/\d+/) {
	  my $ss=$$E_self{SS}[$line_cur];
          # corse, etc
	  $ss=~s/A/1/;
	  $ss=~s/J/1/;
	  $ss=~s/B/2/;
	  $ss=~s/K/2/;
	  $ss=~s/S/2/;
	  $ss=~s/C/3/;
	  $ss=~s/L/3/;
	  $ss=~s/T/3/;
	  $ss=~s/D/4/;
	  $ss=~s/M/4/;
	  $ss=~s/U/4/;
	  $ss=~s/E/5/;
	  $ss=~s/N/5/;
	  $ss=~s/V/5/;
	  $ss=~s/F/6/;
	  $ss=~s/O/6/;
	  $ss=~s/W/6/;
	  $ss=~s/G/7/;
	  $ss=~s/P/7/;
	  $ss=~s/X/7/;
	  $ss=~s/H/8/;
	  $ss=~s/Q/8/;
	  $ss=~s/Y/8/;
	  $ss=~s/I/9/;
	  $ss=~s/R/9/;
	  $ss=~s/Z/9/;
	  my $calculclef=97-$ss%97;
	  if ($$E_self{CLEF_SS}[$line_cur]!=$calculclef) {
          my $reason='-2';
          my $note=" clef incorrecte";
          push (@I_result, { IEP=> $$E_self{IEP}[$line_cur], SS=> $$E_self{SS}[$line_cur], CODE=> $reason, NOTE => $note} );
           } # if CLEF_SS != modulo
	  } # if CLEF_SS
	 } # if SS
	} else {
	# get the reason
	my $reason=$$E_self{NON_FACTURATION_CPAM}[$line_cur];
        my $note=" bug: sais pas";
	if ($reason) {
	 $note=$$E_self{NOTE_NON_FACTURATION_CPAM}{$reason};
	} # reason
        push (@I_result, { IEP=> $$E_self{IEP}[$line_cur], SS=> $$E_self{SS}[$line_cur], CODE=> $reason, NOTE => $note} );
        } # if FACTURABLE_CPAM
    $line_cur++;
  } # while
 bless (\@I_result, "CasErreur");
 return \@I_result;
} # sub nonfacturables

sub nbr {
  my $E_self = shift;
  return $$E_self{NBR};
 }
# sub nbr

sub list {
  my $E_self=shift;
  my $line_nbr=$$E_self{NBR};
  my $line_cur=0;
  while ($line_cur < $line_nbr) {
   print "Line " . $line_cur;
   print " SS=" . $$E_self{SS}[$line_cur];
   print "\n";
   $line_cur++;
  } #while
} #sub

1;
} # Vidhosp


my $E_vidhosp2009=Vidhosp::readfrom("vidhosp09");
print STDERR $E_vidhosp2009->nbr . " lignes lues : " . total_size(\$E_vidhosp2009) . " bytes\n";

#$E_vidhosp2009->list;

my $I_nonfacturables09=$E_vidhosp2009->nonfacturables;
#$I_nonfacturables09->list;

