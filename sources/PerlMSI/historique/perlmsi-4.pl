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
# The changing files format are read form the same functions, with
# format hash giving the position and the variable names - easy to adapt
#
# A minimal hungarian notation is used:
# * by prefix : I_=AoH, E=_HoA
# * by type : arrays index=line number, hash key in UPPER CASE= as
# calculated, in lower case = as read
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

{ package Vidhosp;
use warnings;
use strict;
# Complain where ooperl routines are called from
use Carp qw(croak);

my %formats_vidhosp= (
    42+2  =>  {
        format  =>  'A13 A8 A1 A13',
        variable    =>  [qw( ss naissance sexe iep )],
    },

    85+2  =>  {
        format  =>  'A13 A8 A1 A20 A1 A1 A2 A1 A1 A3 A10 A10 A10 A4',
	variable    => [qw(ss naissance sexe iep exoneration_tm
		prise_en_charge_fj nature_assurance facturable_cpam
		facturation_18eur nbr_venues_facture tr_facturer_tm
		tr_facturer_fj tr_remboursable_cpam tr_parcours_soin)],
    },

    106+2 => {
	format => 'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A3 A10 A10 A10 A4 A10 A5',

	variable   => [qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )],
    },

    107+2 => {
	format => 'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A1 A3 A10 A10 A10 A4 A10 A5',
	variable => [qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam non_facturation_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )],
    }
);

my %signification_vidhosp=(
 sexe => { 1=> "homme", 2=> "femme"},
 facturable_cpam => {0 => "non", 1 => "oui", 2 => "attente de decision sur le taux de prise en charge du patient", 3=> "attente de decision sur les droits du patient"},
 non_facturation_cpam=>{1 => "aide medical etat", 2 => "convention internationale", 3 => "payant", 4 => "soins urgents art L-254.1 CASF", 9 => "autre situation"}
);

# NATURE_ASS : valeur illicite (i.e. pas à {10, 13, 30, 41, 90, XX})
# PEC FJ : valeur illicite (i.e. pas  [A,L,R,X])
# EXO TM : 1 : valeur illicite (i.e. pas [0,1,2,3,4,5,6,7,8,9,C,X])

################################################################################
# For internal use - class method
#
sub dumper {
    use Data::Dumper;
    Data::Dumper->new([$_[0]])->Useqq(1)->Terse(1)->Indent(1)->Deepcopy(1)->Dump
} # sub dumper

sub ssclef {
	my $ss=shift;
	$ss=~tr/[A-Z]/12345678912345678923456789/;
	my $clef=97-$ss%97;
	return ($clef);
} # sub ssclef

sub stripzero {
  my $scalar=shift;
  if ($scalar =~ /^[+-]?\d+$/ ) {
  $scalar=~s{^\([+-]?\)0+}{$1};
  $scalar=$scalar+0;
  } # if +-number
  return $scalar;
} # sub stripzero

################################################################################
# For external use - object methods
#
# In : filename
# Out : E_vidhosp

sub readfrom {
# Input file
 my $infile = shift;
# Counters
 my $line_cur;
 my %line_missing;
# Result : Hoa
 my %E_vidhosp;
# Result : object
 my %E_result;
# Calculations
 my %C_iep;
 my %C_ss;

 open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

   while (my $line_read = <IFD>) {
   # ATTENTION : we need to start at 0 to fill the arrays but $. starts at 1
   $line_cur=$. - 1;

    my $format = $formats_vidhosp { length $line_read };
    unless ($format) {
# Keep a hash of line read per incompatible formats
        $line_missing{2- length $line_read}++;
        next;
    }

    my @variable = @{ $format->{'variable'} };
    # ATTENTION : can't unpack directly into E_vidhosp because can't
    # make an array of lvalues from an array of scalar refs, so here a
    # temporary vаriable must be used
    my %vidhosp_line;
    @vidhosp_line{ @variable } = unpack($format->{'format'}, $line_read);

    for my $variable (keys %vidhosp_line) {
     $E_vidhosp{$variable}[$line_cur]=$vidhosp_line{$variable};
    } # for
 
    # Use the file unrolling opportunity to count unique patients in a hash,
    # key=unique id, value=amount.
    # Use the LCD, variables maintained through the formats but test !undef
    if ($vidhosp_line{iep}) {
    $C_iep{$vidhosp_line{iep}}++;
    }
    if ($vidhosp_line{ss}) {
    $C_ss{$vidhosp_line{ss}}++;
    }
    $line_cur++;
 } # while

 my $line_missing_nbr=0;
 foreach my $missing_nbr (values %line_missing) {
 $line_missing_nbr+=$missing_nbr;
 }
 my $line_missing_formats;
 foreach my $missing_format (values %line_missing) {
 $line_missing_formats .= $missing_format;
 }

 if ($line_missing_nbr > 0) {
 printf STDERR "ERREUR : " . $line_missing_nbr . " lignes non lues, car formats" . $line_missing_formats .  "\n"
 } # if lines_missing

# Store metadata as direct hash keys
  $E_vidhosp{NBR}=$line_cur;
  $E_vidhosp{CALC_DISTINCT_IEP}=scalar keys %C_iep;
  $E_vidhosp{CALC_DISTINCT_SS}=scalar keys %C_ss;

  my $E_result=\%E_vidhosp;
  bless ($E_result, "Vidhosp");
  return ($E_result);
  }
# sub readfrom

################################################################################
# In: Vidhosp
# Out: Array of hashes : [{IEP, SS, CODE, NOTE}]
sub noncpam {
  my $E_self = shift;
  my @I_result;
  my $line_nbr;
  my $line_cur;

  my $adderror = sub {
        my $reason=shift;
	my $note=shift;
        push (@I_result, { IEP=> $$E_self{iep}[$line_cur], SS=> $$E_self{ss}[$line_cur], CODE=> $reason, NOTE => $note} );
  }; #subref

  # Imbriqued subs tests

  my $test_ss = sub {
       if ($$E_self{ss}[$line_cur] =~ m /^[3,4,9,0]/ ) {
	  &$adderror('-1', " ne commence pas par 1 2 5 6 7 8");
       } # if ss
  }; # subref

  my $test_clef_ss = sub {
	  my $clef=ssclef($$E_self{ss}[$line_cur]);

	  if ($$E_self{clef_ss}[$line_cur]!=$clef) {
	   &$adderror('-4', " clef incorrecte");
           } # if CLEF_SS != ssclef(ss)
  };

  my $test_42 = sub {
         &$test_ss;
  }; # subref

  my $test_85 = sub {
      if ($$E_self{facturable_cpam}[$line_cur] == 1) {
         &$test_ss;
      } elsif ($$E_self{facturable_cpam}[$line_cur] == 2) {
	&$adderror('-2', " attente de decision sur taux");
      } elsif ($$E_self{facturable_cpam}[$line_cur] == 3) {
	&$adderror('-3', " attente de decision sur droits");
      } else {
	&$adderror('0', " bug: non facturable sans savoir pourquoi");
      }
  }; # subref

# ATTENTION : can't just redefine test_ss. Must redo the former sub
 my $test_106 = sub {
      if ($$E_self{facturable_cpam}[$line_cur] == 1) {
       if ($$E_self{ss}[$line_cur] =~ m /^[3,4,9,0]/ ) {
	  &$adderror('-1', " ne commence pas par 1 2 5 6 7 8");
       } elsif ($$E_self{ss}[$line_cur] =~ m/\d+/) {
	   &$test_clef_ss;
       } # if ss
    } elsif ($$E_self{facturable_cpam}[$line_cur] == 2) {
	&$adderror('-2', " attente de decision sur taux");
    } elsif ($$E_self{facturable_cpam}[$line_cur] == 3) {
	&$adderror('-3', " attente de decision sur droits");
    } else {
	&$adderror('0', " bug: non facturable sans savoir pourquoi");
    }
 }; #subref

 my $test_107 = sub {
   if ($$E_self{facturable_cpam}[$line_cur] == 0) {
	# get the reason
	my $reason=$$E_self{non_facturation_cpam}[$line_cur];
        my $note=" bug: code erreur non renseigne";
	if ($reason) {
	 $note=$signification_vidhosp{non_facturation_cpam}{$reason};
	} # reason
         &$adderror($reason, $note);
        } else {
 	  # if FACTURABLE_CPAM
 	  &$test_clef_ss;
       } # facturable_cpam
  }; # subref


# FIXME: replace this loop by a for on a range
 $line_nbr=$$E_self{NBR};
 $line_cur=0;

  while ($line_cur < $line_nbr) {

    # non_facturation > clef_ss > facturable_cpam > ss
    # but empty values are possibles in a consistent format
    # and inconsistent formats are also possible

    if (0 == 1) {
#defined $$E_self{non_facturation_cpam}[$line_cur]) {
    # the whole trip
     &$test_107;
    } elsif (0 == 2) {
#defined $$E_self{clef_ss}[$line_cur]) {
    # without non_facturation = 106 format. clef_ss+ss+facturable_cpam exist
     &$test_106;
    } elsif (defined $$E_self{facturable_cpam}[$line_cur]) {
    # without clef_ss = 85 format. ss+facturable_cpam exist
     &$test_85;
    } else {
    # without facturable_cpam = 42 format. ss only
     &$test_42;
    }

    $line_cur++;

  } # while
 return @I_result;
} # sub noncpam

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
  my $requested = shift;
  my @requested_range;

  if ($requested) {
    @requested_range = @$requested;
  } else {
    @requested_range=(0 .. $$E_self{NBR});
  }

  foreach my $line_cur (@requested_range) {
   print "#" . $line_cur;
   for my $variable (keys %{ $E_self} ) {
   # ATTENTION : read values are lowercase only
   if ($variable=~m{[a-z]}) {
    print $variable . "=" . stripzero($$E_self{$variable}[$line_cur]) . ", ";
   } # if
   } # for
   print "\n";
  } #foreach

} #sub


1;

#TODO: Add output using param2=format
} # Package Vidhosp

{ package RSA;
# Complain where ooperl routines are called from
use Carp qw(croak);
use warnings;
use strict;

my %formats_rsa = (
    common => {
	format => 'A9 A3',
        variable =>  [qw( finess version_rsa )],
	sql => [qw/varchar(9) smallint/],
    },
    210  =>  {
        rsa_format  =>  'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A3 A5 A4 A2 A3 A4 A3 A3 A1 A2 A2 A2 A2 A1 A6 A6 A2 A2',
        rsa_variable    =>  [qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree sceances_nbr igs2 ghs duree_rea depassement_bornehaute inferieur_bornebasse nbr_actes_dialyse nbr_actes_ghm_24Z05Z nbr_actes_ghm_24Z06Z nbr_actes_ghm_24Z07Z prelevement_organe dp dr da_nbr actes_nbr )],
	rsa_pgsql	=>  [qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint int smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /],
	rsa_offset => 123,
	das_variable => [qw( das )],
	das_format => 'A6',
	das_pgsql => [qw/ varchar(8) /],
	dad_variable => [qw( dad )],
	dad_format => 'A8',
	dad_pgsql => [qw/ varchar(8) /],
	actes_format => 'A7 A1 A2',
	actes_variable => 'code phase iteration',
	actes_pgsql => 'varchar(7) smallint smallint',
	actes_offset => 10,
	}
	);

################################################################################
# For internal use - class method
#
sub dumper {
    use Data::Dumper;
    Data::Dumper->new([$_[0]])->Useqq(1)->Terse(1)->Indent(1)->Deepcopy(1)->Dump
} # sub dumper

sub stripzero {
  my $scalar=shift;
  if ($scalar =~ /^[+-]?\d+$/ ) {
  $scalar=~s{^\([+-]?\)0+}{$1};
  $scalar=$scalar+0;
  } # if +-number
  return $scalar;
} # sub stripzero

################################################################################
# For external use - object methods
#
# In : filename
# Out : E_rsa

sub readfrom {
# Input file
 my $infile = shift;
# Counters
 my $line_cur;
 my %line_missing;
# Result : Hoa
 my %E_rsa;
# Result : object
 my %E_result;

 open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n");

   while (my $line_read = <IFD>) {
   # ATTENTION : we need to start at 0 to fill the arrays but $. starts
   # at 1
   $line_cur=$. - 1;

    # Do a first read with the common format to find the relevant format
    my $commonformat = $formats_rsa {common};
    my @commonvariable = @{ $commonformat->{'variable'} };
    my %commonvalue;
    @commonvalue{@commonvariable}=unpack($commonformat->{'format'}, $line_read);

    my $givenformat = $formats_rsa{$commonvalue{version_rsa} };
    unless ($givenformat) {
        $line_missing{$commonvalue{version_rsa}}++;
        next;
    }

    # Use the version read to decide which format to use
    # ATTENTION : can't unpack directly into E_rsa because can't
    # make an array of lvalues from an array of scalar refs, so here a
    # temporary vаriable must be used
    my @givenvariable = @{ $givenformat->{'rsa_variable'} };
    my %givenvalue;
    @givenvalue{ @givenvariable } = unpack($givenformat->{'rsa_format'}, $line_read);

    # Finally, add the common part to the format dependant part
    for my $commonpart (keys %commonvalue) {
     $E_rsa{$commonpart}[$line_cur]=$commonvalue{$commonpart};
    } # for
    for my $givenpart (keys %givenvalue) {
     $E_rsa{$givenpart}[$line_cur]=$givenvalue{$givenpart};
    } # for
    $line_cur++;
 } # while

 my $line_missing_nbr=0;
 foreach my $missing_nbr (values %line_missing) {
 $line_missing_nbr+=$missing_nbr;
 }
 my $line_missing_formats;
 foreach my $missing_format (values %line_missing) {
 $line_missing_formats .= $missing_format;
 }

 if ($line_missing_nbr > 0) {
 printf STDERR "ERREUR : " . $line_missing_nbr . " lignes non lues, car
formats" . $line_missing_formats .  "\n"
 } # if lines_missing

# Store metadata as direct hash keys
  $E_rsa{NBR}=$line_cur;

  my $E_result=\%E_rsa;
  bless ($E_result, "Rsa");
  return ($E_result);
}
# sub readfrom


################################################################################
# In: RSA
# Out: File to be exported to excel

sub tocsv {
  my $E_self = shift;
  my $line_nbr;
  my $line_cur;

 $line_nbr=$$E_self{NBR};
 $line_cur=0;

# FIXME: probleme pour les actes et das, et découpage incorrect
  while ($line_cur < $line_nbr) {
  for my $variable (keys % { $E_self} ) {
# Exclude direct hash keys
    unless ($variable eq 'NBR') {
     print "'" . $variable . "=',";
     print $$E_self{$variable}[$line_cur+0] . ", ";
    } # unless
    } # for
  print "\n";
  } # while

#    my $commonformat = $formats_rsa {common};
#    my @commonvariable = @{ $commonformat->{'variable'} };
#    my $givenformat = $formats_rsa { $commonvalue{version_rsa} };
#    my @givenvariable = @{ $format->{'variable'} };
}  # tocsv

# FIXME : add directcalc : return an array of value per finess

} # Package RSA

{ package RSS;
# Complain where ooperl routines are called from
use Carp qw(croak);
use warnings;
use strict;


my %formats_rss= (
    # das_format => '@125 A2 @165/(A8)',
    common => {
	format => 'A2 A2 A4 x1 A3',
	variable => 'version_groupage cmd ghm version_rss',
	sql => [qw/smallint varchar(2) varchar(4) smallint/],
    },
    110  =>  {
        rum_format  =>  'A3 A9 A3 A7 A8 A1 A4 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2
A2 A2 A8 A8 A3 x15',
        rum_variable    =>  [qw( code_retour finess version_rum rss naissance sexe uf date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )],
	rum_pgsql	=>  [qw/ smallint varchar(9) smallint int timestamp varchar(1) smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint varchar(8) varchar(8) smallint/],
	rum_offset => 118,
	das_variable => [qw( das )],
	das_format => 'A8',
	das_pgsql => [qw/ varchar(8) /],
	dad_variable => [qw( dad )],
	dad_format => 'A8',
	dad_pgsql => [qw/ varchar(8) /],
	actes_format => 'A7 A1 A2',
	actes_variable => 'code phase iteration',
	actes_pgsql => 'varchar(7) smallint smallint',
	actes_offset => 10,
    },
    111  =>  {
        rum_format  =>  'A3 A9 A3 A7 A20 A8 A1 A4 A2 A2 x1 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A8 A8 A3 x15',
        rum_variable    =>  [qw( code_retour finess version_rum rss iep naissance sexe uf uf_autorisation lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )],
	rum_pgsql	=>  [qw/ smallint varchar(9) smallint int int timestamp varchar(1) smallint smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint varchar(8) varchar(8) smallint/],
	rum_offset => 143,
	das_variable => [qw( das )],
	das_format => 'A8',
	das_pgsql => [qw/ varchar(8) /],
	dad_variable => [qw( dad )],
	dad_format => 'A8',
	dad_pgsql => [qw/ varchar(8) /],
	actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	actes_variable => 'date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration',
	actes_pgsql => 'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
	actes_offset => 26,
	},

    113  =>  {
        rum_format  =>  'A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A2 A8 A8 A3 x15',
        rum_variable    =>  [qw( code_retour finess version_rum rss iep rum naissance sexe uf lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree age_gestationnel sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )],
	rum_pgsql	=>  [qw/ smallint varchar(9) smallint int int int timestamp varchar(1) smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint smallint varchar(8) varchar(8) smallint/],
	rum_offset => 165,
	das_variable => [qw( das )],
	das_format => 'A8',
	das_pgsql => [qw/ varchar(8) /],
	dad_variable => [qw( dad )],
	dad_format => 'A8',
	dad_pgsql => [qw/ varchar(8) /],
	actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	actes_variable => 'date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration',
	actes_pgsql => 'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
	actes_offset => 26,
	},

    114  =>  {
        rum_format  =>  'A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A3 A8 A8 A3 A1 A1 A1 x11',
        rum_variable    =>  [qw( code_retour finess version_rum rss iep rum naissance sexe uf lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree age_gestationnel sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 confirmation_codage type_radiotherapie type_dosimetrie )],
	rum_pgsql	=>  [qw/ smallint varchar(9) smallint int int int timestamp varchar(1) smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint smallint varchar(8) varchar(8) smallint smallint smallint smallint /],
	rum_offset => 165,
	das_variable => [qw( das )],
	das_format => 'A8',
	das_pgsql => [qw/ varchar(8) /],
	dad_variable => [qw( dad )],
	dad_format => 'A8',
	dad_pgsql => [qw/ varchar(8) /],
	actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	actes_variable => 'date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration',
	actes_pgsql => 'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
	actes_offset => 26,
	},

  );


# FIXME : probleme pour generateur SQL : valeurs vides, guillemets
# FIXME : generer aussi un CSV ou list


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

#my $E_vidhosp2009=Vidhosp::readfrom("vidhosp-2009d-m7.txt");
#print "Vidhosp : ". $E_vidhosp2009->nbr . " lignes lues : " . total_size(\$E_vidhosp2009) . " bytes\n";
#print $E_vidhosp2009->distinct_iep . " iep uniques " . $E_vidhosp2009->distinct_ss . " ss uniques\n";
#
#my @noncpam2009=$E_vidhosp2009->noncpam;
#foreach my $erreur (@noncpam2009) {
#print "IEP= " . $$erreur{IEP} . " SS= " .  $$erreur{SS} . " : " .  $$erreur{NOTE} . "\n";
#} # foreach

#my $E_rss2009=RSS::readfrom("rssgrp-2009-M8-2e.txt");
#print "rss : ". $E_rss2009->nbr . " lignes lues : " . total_size(\$E_rss2009) . " bytes\n";
#print $E_rss2009->distinct_iep . " iep uniques " . $E_rss2009->distinct_rss . " rss uniques\n";
##$E_rss2009->list;

# FIXME : TODO
##$E_rss2009->sql("2009-114out.sql");

my $E_rsa_2004=RSA::readfrom("rsa-2004.txt");

$E_rsa_2004->RSA::tocsv;

