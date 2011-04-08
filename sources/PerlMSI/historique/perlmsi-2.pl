#!/usr/bin/perl -w

################## CONVENTIONS : you may not like them but show unicity!
#
# Bastard OOP syntax is used: OO is only used to bind subs to data classes.
# That means instances are not built as $obj->methodnew; but $obj=Obj::method;
#
# Likewise, hashes are used to hard code field names:
#
# - To read files which formats may change every year, hashes of arrays
# are used for an easier read by class functions : each field name is
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
# The changing files format are read form the same functions, with a if,
# to ease maintenance and inclusion of new formats. That means no subs,
# because subs may be too complicated for the casual coder who might
# however copy/paste a working example.
#
# A list of all possible arrays for every version of the changing format
# has to be given before the function. This is a tradeoff between
# simplicity and proper design
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
  my @I_self  = shift;
# Allow the creation of new objects from existing ones, inheriting methods
  my $nonfacturable_cur=0;

  for $sef (@I_self) {
  print "IEP= " . $sef{IEP} . " SS= " .  $sef{SS} . " : " .  $sef{NOTE} . "\n";
  } # foreach
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

# The future result
  my $E_result  = {};
# The unread lines of unkown formats
my $lines_missing;

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

# Calculations
my %C_iep;
my %C_ss;

open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

my $line_cur = 0;
while ( my $line_read = <IFD> ) {
 if (length($line_read)==107 + 2) {
   # 107=format D, Vidhosp 2009, 2 : \r\n
   ($SS[$line_cur],$CLEF_SS[$line_cur],$CODE_GRAND_REGIME[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$TYPE_COMPLEMENTAIRE[$line_cur],$FACTURABLE_CPAM[$line_cur],$NON_FACTURATION_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur],$TR_BASE_REMBOURSEMENT[$line_cur],$TX_REMBOURSEMENT[$line_cur])=unpack("A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A1 A3 A10 A10 A10 A4 A10 A5", $line_read);
  } elsif (length($line_read)==106 + 2) {
   # 106=format C, Vidhosp 2007, 2 : \r\n
   ($SS[$line_cur],$CLEF_SS[$line_cur],$CODE_GRAND_REGIME[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$TYPE_COMPLEMENTAIRE[$line_cur],$FACTURABLE_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur],$TR_BASE_REMBOURSEMENT[$line_cur],$TX_REMBOURSEMENT[$line_cur])=unpack("A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A3 A10 A10 A10 A4 A10 A5", $line_read);
  } elsif (length($line_read)==85 + 2) {
   # 85=format B, Vidhosp 2007, 2 : \r\n
   ($SS[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur],$EXONERATION_TM[$line_cur],$PRISE_EN_CHARGE_FJ[$line_cur],$NATURE_ASSURANCE[$line_cur],$FACTURABLE_CPAM[$line_cur],$FACTURATION_18EUR[$line_cur],$NBR_VENUES_FACTURE[$line_cur],$TR_FACTURER_TM[$line_cur],$TR_FACTURER_FJ[$line_cur],$TR_REMBOURSABLE_CPAM[$line_cur],$TR_PARCOURS_SOIN[$line_cur])=unpack("A13 A8 A1 A20 A1 A1 A2 A1 A1 A3 A10 A10 A10 A4", $line_read);
  } elsif (length($line_read)==42 + 2) {
   # 42=format A, Vidhosp 2006, 2 : \r\n
   ($SS[$line_cur],$NAISSANCE[$line_cur],$SEXE[$line_cur],$IEP[$line_cur]) =unpack("A13 A8 A1 A20", $line_read);
  } else {
  $lines_missing++;
 }

# Calculations

# Count unique patients
if ($IEP[$line_cur]) {
$C_iep{$IEP[$line_cur]}++;
}
if ($SS[$line_cur]) {
$C_ss{$SS[$line_cur]}++;
}
    $line_cur++;

# if length
 }
  # while close (IFD);

 if ($lines_missing) {
 printf STDERR "ERREUR : " . $lines_missing . " lignes non lues\n"
 } # if lines_missing

# Store metadata as direct hash keys
  $$E_result{NBR}=$line_cur;
# FIXME: should store results as references to hashes
  $$E_result{CALC_DISTINCT_IEP}=scalar keys %C_iep;
  $$E_result{CALC_DISTINCT_SS}=scalar keys %C_ss;

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

sub distinct_iep {
  my $E_self = shift;
  return $$E_self{CALC_DISTINCT_IEP};
 }
# sub distinct_iep

sub distinct_ss {
  my $E_self = shift;
  return $$E_self{CALC_DISTINCT_SS};
 }
# sub distinct_ss

sub list {
  my $E_self=shift;
  my $line_nbr=$$E_self{NBR};
  my $line_cur=0;
  while ($line_cur < $line_nbr) {
   print "Line " . $line_cur;
   print " SS=" . $$E_self{SS}[$line_cur];
# FIXME: Incomplet
   print "\n";
   $line_cur++;
  } #while
} #sub

1;

#TODO: Add output using param2=format
} # Package Vidhosp

{ package RSS;
# Complain where ooperl routines are called from
use Carp qw(croak);
use warnings;
use strict;

sub dasdadacte_read {
  my $dasdadacte=shift;
  my $das_nbr=shift;
  my $dad_nbr=shift;
  my $acte_nbr=shift;
  my $rum_format=shift;

my @DAS;
my @DAD;
# Temporary
my @acteraw;
# Used to build
my %ACTE;
# which is a HoA containing:
my @DATE;
my @CCAM; 
my @PHASE;
my @ACTIVITE;
my @EXTENSION;
my @MODIFICATEUR;
my @REMB_EXCEPTIONNEL;
my @ASSOC_NONPREVUE;
my @ITERATION;

@DAS = unpack('(A8)[' .  $das_nbr . ']', $dasdadacte);
my $jump;
my $discard;

$jump=$das_nbr;
($discard, @DAD) = unpack('A' . $jump . ' (A8)[' .  $dad_nbr . ']', $dasdadacte);
$jump=$das_nbr*8+$dad_nbr*8;

# FIXME: !26 if rum_format<112

# Each line is a block of 26 char to be converted into a proper hash
($discard, @acteraw) = unpack('A' . $jump . ' (A26)[' .  $acte_nbr . ']', $dasdadacte);

my $acte_cur=0;
while ($acte_cur < $acte_nbr) {
 ($DATE[$acte_cur],
 $CCAM[$acte_cur],
 $PHASE[$acte_cur],
 $ACTIVITE[$acte_cur],
 $EXTENSION[$acte_cur],
 $MODIFICATEUR[$acte_cur],
 $REMB_EXCEPTIONNEL[$acte_cur],
 $ASSOC_NONPREVUE[$acte_cur],
 $ITERATION[$acte_cur])=unpack('A8 A7 A1 A1 A1 A4 A1 A1 A2',
$acteraw[$acte_cur]);
 $acte_cur++
} # while

$ACTE{DATE}=\@DATE;
$ACTE{CCAM}=\@CCAM;
$ACTE{PHASE}=\@PHASE;
$ACTE{ACTIVITE}=\@ACTIVITE;
$ACTE{EXTENSION}=\@EXTENSION;
$ACTE{MODIFICATEUR}=\@MODIFICATEUR;
$ACTE{REMB_EXCEPTIONNEL}=\@REMB_EXCEPTIONNEL;
$ACTE{ASSOC_NONPREVUE}=\@ASSOC_NONPREVUE;
$ACTE{ITERATION}=\@ITERATION;

return (@DAS, @DAD, %ACTE);
} # sub


sub readfrom {
  my $infile = shift;

# The future result
  my $E_result  = {};
# The unread lines/unsupported format;
my $lines_missing;

# Arrays going into E_result will be filled with values to be read
my @VERSION_GROUPAGE;
my @CMD;
my @GHM;
my @FILLER;
my @VERSION_RSS;
my @CODE_RETOUR;
my @FINESS;
my @VERSION_RUM;
my @RSS;
my @IEP; # 110 -> ...
my @RUM; # 114 -> ...
my @NAISSANCE;
my @SEXE;
my @UF;
my @UF_AUTORISATION; #  110 -> 113i
my @LIT_AUTORISATION; # 114 ->
my @RESERVE1; # 110 ... -> 113i
my @DATE_ENTREE_UF;
my @ENTREE;
my @PROVENANCE;
my @DATE_SORTIE_UF;
my @SORTIE;
my @DESTINATION;
my @CP_RESIDENCE;
my @POIDS_NNE_ENTREE;
my @AGE_GESTATIONNEL; # 114 -> ...
my @SCEANCES_NBR;
my @DAS_NBR;
my @DAD_NBR;
my @ACTES_NBR;
my @DP;
my @DR;
my @IGS2;
my @CONFIRMATION_CODAGE; # 114 -> ...
my @TYPE_RADIOTHERAPIE; # 114 -> ...
my @TYPE_DOSIMETRIE; # 114 -> ...
my @RESERVE2;

# Declare new variables here if future formats introduce them
# my @NEWVAR1;
# my @OTHERNEW;

# The variable parts are not just arrays:

# Arrays of arrays
my @DAS;
my @DAD;
# Hash of arrays:
my %ACTE;

# For calculations
my %C_iep;
my %C_rss;
my %C_sceances;

open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

my $line_cur = 0;
while ( my $line_read = <IFD> ) {
 # Can't use line lengh. Must do partial read to access the format

# If new variables are introduced, they must also be declared: cf my @NEWVAR;
my ($format_read) = unpack('x9 A3', $line_read);

# The / template character allows packing and unpacking of a sequence of
# items where the packed structure contains a packed item count followed
# by the packed items themselves.
# For unpack an internal stack of integer arguments unpacked so far is
# used. You write /sequence-item and the repeat count is obtained by
# popping off the last element from the stack. The sequence-item must not
# have a repeat count.
# unpack @2 A1 / (A3) : the 2nd char gives the repetition of triplets
#
# Here we use @125 A2 @165/(A8) to get the DAS in an array
#
# SUGGESTION: integrate in the above unpack with template repetitions
# BUG:  @125 A2 @129 A2 /(x8) x36 /(A26) or @125 A2 @129 A2 @165 /(x8) /(A26)
# don't work. Sucessives / are not allowed because there is no real
# stack from which values pushed by @ are popped


if ($format_read == '114') {
# DAS+DAD+ACTES have no fixed width
my $dasdadactes;

($VERSION_GROUPAGE[$line_cur], 
$CMD[$line_cur], 
$GHM[$line_cur], 
$FILLER[$line_cur], 
$VERSION_RSS[$line_cur], 
$CODE_RETOUR[$line_cur], 
$FINESS[$line_cur], 
$VERSION_RUM[$line_cur], 
$RSS[$line_cur], 
$IEP[$line_cur], 
$RUM[$line_cur], 
$NAISSANCE[$line_cur], 
$SEXE[$line_cur], 
$UF[$line_cur], 
$LIT_AUTORISATION[$line_cur], 
$DATE_ENTREE_UF[$line_cur], 
$ENTREE[$line_cur], 
$PROVENANCE[$line_cur], 
$DATE_SORTIE_UF[$line_cur], 
$SORTIE[$line_cur], 
$DESTINATION[$line_cur], 
$CP_RESIDENCE[$line_cur], 
$POIDS_NNE_ENTREE[$line_cur], 
$AGE_GESTATIONNEL[$line_cur], 
$SCEANCES_NBR[$line_cur], 
$DAS_NBR[$line_cur], 
$DAD_NBR[$line_cur], 
$ACTES_NBR[$line_cur], 
$DP[$line_cur], 
$DR[$line_cur], 
$IGS2[$line_cur], 
$CONFIRMATION_CODAGE[$line_cur], 
$TYPE_RADIOTHERAPIE[$line_cur], 
$TYPE_DOSIMETRIE[$line_cur], 
$RESERVE2[$line_cur],
$dasdadactes
) =
unpack('A2 A2 A4 A1 A3 A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A3 A8 A8 A3 A1 A1 A1 A11 A*', $line_read);

(@DAS, @DAD, %ACTE)=dasdadacte_read($dasdadactes,
$DAS_NBR[$line_cur], $DAD_NBR[$line_cur], $ACTES_NBR[$line_cur], $format_read);

} else { # if format 
$lines_missing++;
} # if format inconnu

# Now perform some calculations!

# Basic calculations are done in this file reading loop to take advantage of
# disk latency while accessing files : simple calculus should take far
# less time than disk access, even when being optimised by an unpack,
# and will be available 100% of the time. More precise calculus, less
# often needed, is handled is a separate sub 

# Only perform calculations when the actual column exists

# Count unique patients
if ($IEP[$line_cur]) {
$C_iep{$IEP[$line_cur]}++;
}
# Count unique RSS
if ($RSS[$line_cur]) {
$C_rss{$RSS[$line_cur]}++;
}

# Count sceances
   if ($SCEANCES_NBR[$line_cur]) {
    if ($SCEANCES_NBR[$line_cur]>0) {
    # SCEANCES_NBR not always 1. Can be >1. So don't ++
    $C_sceances{$UF[$line_cur]}+=$SCEANCES_NBR[$line_cur];
    } # if
   }

$line_cur=$line_cur+1;
} # while

if ($lines_missing) {
printf STDERR "ERREUR : " . $lines_missing . " lignes non lues\n"
} # if lines_missing

### Store metadata as direct hash keys
  $$E_result{NBR}=$line_cur;
## FIXME: should store results as references to hashes
 $$E_result{CALC_DISTINCT_IEP}=scalar keys %C_iep;
 $$E_result{CALC_DISTINCT_RSS}=scalar keys %C_rss;


## FIXME: replace by regression tests to make sure all das have been read
#$das_nbr_114[2] !=  @{$das_114[2]}
#printf STDERR "DAS2,2 114: " . $das_114[2][2] . "\n";
#$das_cur=0;
#while ($das_cur < @{$das_114[2]}) {
#print $das_114[2][$das_cur] . " ; ";
#$das_cur++;
#}

$$E_result{VERSION_GROUPAGE}=\@VERSION_GROUPAGE;
$$E_result{CMD}=\@CMD;
$$E_result{GHM}=\@GHM;
$$E_result{FILLER}=\@FILLER;
$$E_result{VERSION_RSS}=\@VERSION_RSS;
$$E_result{CODE_RETOUR}=\@CODE_RETOUR;
$$E_result{FINESS}=\@FINESS;
$$E_result{VERSION_RUM}=\@VERSION_RUM;
$$E_result{RSS}=\@RSS;
$$E_result{IEP}=\@IEP ;
$$E_result{RUM}=\@RUM ;
$$E_result{NAISSANCE}=\@NAISSANCE;
$$E_result{SEXE}=\@SEXE;
$$E_result{UF}=\@UF;
$$E_result{UF_AUTORISATION}=\@UF_AUTORISATION ;
$$E_result{LIT_AUTORISATION}=\@LIT_AUTORISATION ;
$$E_result{RESERVE1}=\@RESERVE1 ;
$$E_result{DATE_ENTREE_UF}=\@DATE_ENTREE_UF;
$$E_result{ENTREE}=\@ENTREE;
$$E_result{PROVENANCE}=\@PROVENANCE;
$$E_result{DATE_SORTIE_UF}=\@DATE_SORTIE_UF;
$$E_result{SORTIE}=\@SORTIE;
$$E_result{DESTINATION}=\@DESTINATION;
$$E_result{CP_RESIDENCE}=\@CP_RESIDENCE;
$$E_result{POIDS_NNE_ENTREE}=\@POIDS_NNE_ENTREE;
$$E_result{AGE_GESTATIONNEL}=\@AGE_GESTATIONNEL ;
$$E_result{SCEANCES_NBR}=\@SCEANCES_NBR;
$$E_result{DAS_NBR}=\@DAS_NBR;
$$E_result{DAD_NBR}=\@DAD_NBR;
$$E_result{ACTES_NBR}=\@ACTES_NBR;
$$E_result{DP}=\@DP;
$$E_result{DR}=\@DR;
$$E_result{IGS2}=\@IGS2;
$$E_result{CONFIRMATION_CODAGE}=\@CONFIRMATION_CODAGE ;
$$E_result{TYPE_RADIOTHERAPIE}=\@TYPE_RADIOTHERAPIE ;
$$E_result{TYPE_DOSIMETRIE}=\@TYPE_DOSIMETRIE ;
$$E_result{RESERVE2}=\@RESERVE2;
$$E_result{DAS}=\@DAS;
$$E_result{DAD}=\@DAD;

$$E_result{ACTE}=\%ACTE;


  bless ($E_result, "RSS");
  return ($E_result);

}

sub sql {
  my %E_self = shift;
  my $outfile = shift;
  my $line_nbr = $E_self{NBR};
  my $line_cur = 0;

  print $E_self{NBR};
  print $outfile;

  my @sqlcolumns; #=keys($E_self);
  my $sqlcolumns_nbr=scalar (@sqlcolumns);
  my $sqlcolumns_cur=0;

  while ($sqlcolumns_cur<$sqlcolumns_nbr) {
    print $sqlcolumns[$sqlcolumns_cur];
  } # while sqlcolumns

}
# sub sql

sub nbr {
  my $E_self = shift;
  return $$E_self{NBR};
 }
# sub nbr

sub distinct_iep {
  my $E_self = shift;
  return $$E_self{CALC_DISTINCT_IEP};
 }
# sub distinct_iep

sub distinct_rss {
  my $E_self = shift;
  return $$E_self{CALC_DISTINCT_RSS};
 }
# sub distinct_rss

sub list {
# FIXME : marche meme sans le shift !! Global ???
  my $E_self = shift;
  my $line_requested = shift;
  my $line_nbr;
  my $line_cur;
  my $requested_cur;

  # if a subset is requested
  if ($line_requested) {
  # can be an array or a scalar
   if (ref $line_requested eq 'ARRAY') {
    $line_nbr=$$line_requested;
    $line_cur=$$line_requested[0];
    } else {
  # only one line is requested
    $line_cur=$line_requested;
    $line_nbr=1+$line_cur;
    }
  } else {
  # if no subset is given, get everything
  $line_nbr=$$E_self{NBR};
  $line_cur=0;
  } # if line_requested

  while ($line_cur < $line_nbr) {
   print "Line " . $line_cur;
   print " RSS=" . $$E_self{RSS}[$line_cur];
   print " IEP=" . $$E_self{IEP}[$line_cur];
# FIXME: Incomplet
   print "\n";

   if ($line_requested) {
    if (ref $line_requested eq 'ARRAY') {
    $requested_cur++;
    $line_cur=$$line_requested[$requested_cur];
    } else {
    # if it wasn't an array, the requested line was already given, ++ to stop
    $line_cur++;
    }
   } else {
   $line_cur++;
   } # if line_requested

  } #while
} #sub

# FIXME: a faire par uf, pole, total ou par autre critere (ex: ghm)
# FIXME: pouvoir faire une intersection ou union entre criteres
# sub calculs

# TODO : Add output to given format using printf %02d :2 digit left pad by 0

1;
} # Package RSS

# TODO : rajouter import de tuple IPP,IEP fils
# TODO : rajouter fonction rss1_extrapole=extrapolatedas(rss1, rss2)

use Data::Dumper;

my $E_vidhosp2009=Vidhosp::readfrom("vidhosp-2009d-m7.txt");
print "Vidhosp : ". $E_vidhosp2009->nbr . " lignes lues : " . total_size(\$E_vidhosp2009) . " bytes\n";
print $E_vidhosp2009->distinct_iep . " iep uniques " . $E_vidhosp2009->distinct_ss . " ss uniques\n";
##$E_vidhosp2009->list;
my $I_nonfacturables2009=$E_vidhosp2009->nonfacturables;
$I_nonfacturables2009->list;

my $E_rss2009=RSS::readfrom("rssgrp-2009-M8-2e.txt");
print "rss : ". $E_rss2009->nbr . " lignes lues : " . total_size(\$E_rss2009) . " bytes\n";
print $E_rss2009->distinct_iep . " iep uniques " . $E_rss2009->distinct_rss . " rss uniques\n";
#$E_rss2009->list;

#$E_rss2009->sql("2009-114out.sql");
