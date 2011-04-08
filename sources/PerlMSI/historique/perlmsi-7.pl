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
# * by type : arrays index=line number, hash key in UPPER CASE starting
# with CALC_ = calculated value/sum, in lower case = as read
# * by suffix : _nbr for a total, _cur for the current value in a loop,
# FD for file descriptors, _read for the line currently being read
#
# On nesting, closing braces are always followed by a comment like #sub,
# #if, #while, etc.
#
################## MODULES : the least the faster!

#use DBI; # databases
#use Benchmark; # for optimisation with timethis (100, "somesub()");
use Devel::Size qw(total_size);    # To check memory use
use warnings;                      # warn about questionnable syntax
use strict;                        # because I'm new

## Common fonctions for all read files
{
    package FILEREAD;

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

    sub dumper {
        use Data::Dumper;
        Data::Dumper->new( [ $_[0] ] )->Useqq(1)->Terse(1)->Indent(1)->Deepcopy(1)->Dump;
    }    # sub dumper

    sub nbr {
print "toto!\n";
        my $E_self = shift;
        return $$E_self{CALC_NBR};
    } # sub nbr

    sub stripzero {
        my $scalar = shift;
        if ( $scalar =~ /^[+-]?\d+$/ ) {
            $scalar =~ s{^\([+-]?\)0+}{$1};
            $scalar = $scalar + 0;
        }    # if +-number
        return $scalar;
    }    # sub stripzero

# FIXME: a tester
    sub tosql {
        my %E_self   = shift;
        my $outfile  = shift;
        my $line_nbr = $E_self{CALC_NBR};
        my $line_cur = 0;

        print $E_self{CALC_NBR};
        print $outfile;

        my @sqlcolumns;    #=keys($E_self);
        my $sqlcolumns_nbr = scalar(@sqlcolumns);
        my $sqlcolumns_cur = 0;

        while ( $sqlcolumns_cur < $sqlcolumns_nbr ) {
            print $sqlcolumns[$sqlcolumns_cur];
        }                  # while sqlcolumns

    } # sub tosql


    sub tocsv {
        my $E_self = shift;
        my $line_nbr;
        my $line_cur;

        $line_nbr = $$E_self{CALC_NBR};
        $line_cur = 0;

        while ( $line_cur < $line_nbr ) {
            for my $variable ( keys %{$E_self} ) {
                # Exclude direct hash keys
                unless ( $variable =~ /^CALC_.*/) {
                    print "'" . $variable . "=',";
                    print $$E_self{$variable}[ $line_cur + 0 ] . ", ";
                }    # unless
            }    # for
            print "\n";
	$line_cur++;

        }    # while
    }    # tocsv

    sub list {
        my $E_self    = shift;
        my $requested = shift;
        my @requested_range;

        if ($requested) {
            @requested_range = @$requested;
        }
        else {
            @requested_range = ( 0 .. $$E_self{CALC_NBR} );
        }

        foreach my $line_cur (@requested_range) {
            print "#" . $line_cur;
            for my $variable ( keys %{$E_self} ) {

                # Exclude direct hash keys
               # # ATTENTION : read values are lowercase only
               # #if ( $variable =~ m{[a-z]} ) {
                unless ( $variable =~ /^CALC_.*/) {
                    print $variable . "="
                      . stripzero( $$E_self{$variable}[$line_cur] ) . ", ";
                }    # if
            }    # for
            print "\n";
        }    #foreach

    }    #sub

    sub ssclef {
        my $ss = shift;
        $ss =~ tr/[A-Z]/12345678912345678923456789/;
        my $clef = 97 - $ss % 97;
        return ($clef);
    }    # sub ssclef

    sub checkformat {
        my $formatreference = shift;

            my @rsa_variable = @{ $formatreference->{'rsa_variable'} };
my @rsa_variable_lenght = split (" ", $formatreference->{'rsa_format'});
my @rsa_variable_sql = split (" ", $formatreference->{'rsa_sql'});
for (my $i=0; $i < $#rsa_variable ; $i++) {
print $rsa_variable[$i] . " = " . $rsa_variable_lenght[$i] . " / " . $rsa_variable_sql[$i] . "\n";
}

   } # sub checkformat

    1;
} # Package FILEREAD

{
    package FICHCOMP;
    use base qw(FILEREAD);

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

    my %formats_fichcomp = (
        92 + 2 => {
            format   => 'A9 A2 A20 A10 A8 A8 A15 A10 A10',
            variable => [qw( finess prestation iep rum date_debut date_fin code nombre montant_paye )],
	    pgsql => [qw( bigint smallint bigint bigint timestamp timestamp varchar bigint bigint)],
	    signification => [
        prestation  => { 01 => "medicament", 02 => "dispositif implantable", 03 => "prelevement", 04=> "prestation interetablissement", 99 => "enquete" },
		],
        },
        105 + 2 => {
            format   => 'A9 A2 A20 A8 A15 A10 A10 A1 x30',
            variable => [qw( finess prestation iep date_administration code nombre montant_paye validation)],
	    pgsql => [qw( bigint smallint bigint timestamp bigint varchar bigint bigint)],
	    signification => [
        prestation  => { 06 => "medicament onereux"},
	   ],
        },
    );


sub readfrom {
# Input file
 my $infile = shift;
# Counters
 my $line_cur;
 my %line_missing;
# Result : Hoa
 my %E_fichcomp;
# Result : object
 my %E_result;
# Calculations
 my %C_iep;
 my %C_ss;
 my $C_montant;

 open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

   while (my $line_read = <IFD>) {
   # ATTENTION : we need to start at 0 to fill the arrays but $. starts at 1
   $line_cur=$. - 1;

    my $format = $formats_fichcomp { length $line_read };
    unless ($format) {
# Keep a hash of line read per incompatible formats
        $line_missing{2- length $line_read}++;
        next;
    }

    my @variable = @{ $format->{'variable'} };
    # ATTENTION : can't unpack directly into E_fichcomp because can't
    # make an array of lvalues from an array of scalar refs, so here a
    # temporary vаriable must be used
    my %fichcomp_line;
    @fichcomp_line{ @variable } = unpack($format->{'format'}, $line_read);

    for my $variable (keys %fichcomp_line) {
     $E_fichcomp{$variable}[$line_cur]=$fichcomp_line{$variable};
    } # for
 
    # Use the file unrolling opportunity to count amounts
    if ($fichcomp_line{iep}) {
    $C_iep{$fichcomp_line{iep}}++;
    }
    if ($fichcomp_line{ss}) {
    $C_ss{$fichcomp_line{ss}}++;
    }
    if ($fichcomp_line{montant_paye}) {
    $C_montant+=$fichcomp_line{montant_paye};
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
  $E_fichcomp{CALC_NBR}=$line_cur;
  $E_fichcomp{CALC_VAL}=$C_montant;
  $E_fichcomp{CALC_DISTINCT_IEP}=scalar keys %C_iep;
  $E_fichcomp{CALC_DISTINCT_SS}=scalar keys %C_ss;

  my $E_result=\%E_fichcomp;
  bless ($E_result, "FICHCOMP");
  return ($E_result);
  }
# sub readfrom

################################################################################
    # In: FICHCOMP
    # Out: Financial value
sub value {
        my $E_self = shift;
 print $$E_self{VAL};
 } # value

sub distinct_iep  {
        my $E_self = shift;
 print $$E_self{CALC_DISTINCT_IEP};
 } # distinct_iep

sub distinct_ss {
        my $E_self = shift;
 print $$E_self{CALC_DISTINCT_SS};
 } # distinct_ss

} # FICHCOMP

{

    package VIDHOSP;
    use warnings;
    use strict;

    # Complain where ooperl routines are called from
    use Carp qw(croak);

    my %formats_vidhosp = (
        42 + 2 => {
            format   => 'A13 A8 A1 A13',
            variable => [qw( ss naissance sexe iep )],
        },

        85 + 2 => {
            format   => 'A13 A8 A1 A20 A1 A1 A2 A1 A1 A3 A10 A10 A10 A4',
            variable => [
                qw(ss naissance sexe iep exoneration_tm
                  prise_en_charge_fj nature_assurance facturable_cpam
                  facturation_18eur nbr_venues_facture tr_facturer_tm
                  tr_facturer_fj tr_remboursable_cpam tr_parcours_soin)
            ],
        },

        106 + 2 => {
            format =>
              'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A3 A10 A10 A10 A4 A10 A5',

            variable => [
                qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )
            ],
        },

        107 + 2 => {
            format =>
'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A1 A3 A10 A10 A10 A4 A10 A5',
            variable => [
                qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam non_facturation_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )
            ],
        }
    );

# FIXME:  deplacer dans variable generale
    my %signification_vidhosp = (
        sexe            => { 1 => "homme", 2 => "femme" },
        facturable_cpam => {
            0 => "non",
            1 => "oui",
            2 =>
              "attente de decision sur le taux de prise en charge du patient",
            3 => "attente de decision sur les droits du patient"
        },
# 5 introduit en 2010
        non_facturation_cpam => {
            1 => "aide medical etat",
            2 => "convention internationale",
            3 => "payant",
            4 => "soins urgents art L-254.1 CASF",
            5 => "hospitalise dans autre etablissement",
            9 => "autre situation"
        }
    );

    # NATURE_ASS : valeur illicite (i.e. pas à {10, 13, 30, 41, 90, XX})
    # PEC FJ : valeur illicite (i.e. pas  [A,L,R,X])
    # EXO TM : 1 : valeur illicite (i.e. pas [0,1,2,3,4,5,6,7,8,9,C,X])

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

        open( IFD, "<" . $infile )
          or croak( "Ne peut lire " . $infile . " !\n" );

        while ( my $line_read = <IFD> ) {

       # ATTENTION : we need to start at 0 to fill the arrays but $. starts at 1
            $line_cur = $. - 1;

            my $format = $formats_vidhosp{ length $line_read };
            unless ($format) {

                # Keep a hash of line read per incompatible formats
                $line_missing{ 2 - length $line_read }++;
                next;
            }

            my @variable = @{ $format->{'variable'} };

            # ATTENTION : can't unpack directly into E_vidhosp because can't
            # make an array of lvalues from an array of scalar refs, so here a
            # temporary vаriable must be used
            my %vidhosp_line;
            @vidhosp_line{@variable} =
              unpack( $format->{'format'}, $line_read );

            for my $variable ( keys %vidhosp_line ) {
                $E_vidhosp{$variable}[$line_cur] = $vidhosp_line{$variable};
            }    # for

        # Use the file unrolling opportunity to count unique patients in a hash,
        # key=unique id, value=amount.
        # Use the LCD, variables maintained through the formats but test !undef
            if ( $vidhosp_line{iep} ) {
                $C_iep{ $vidhosp_line{iep} }++;
            }
            if ( $vidhosp_line{ss} ) {
                $C_ss{ $vidhosp_line{ss} }++;
            }
            $line_cur++;
        }    # while

        my $line_missing_nbr = 0;
        foreach my $missing_nbr ( values %line_missing ) {
            $line_missing_nbr += $missing_nbr;
        }
        my $line_missing_formats;
        foreach my $missing_format ( values %line_missing ) {
            $line_missing_formats .= $missing_format;
        }

        if ( $line_missing_nbr > 0 ) {
            printf STDERR "ERREUR : "
              . $line_missing_nbr
              . " lignes non lues, car formats"
              . $line_missing_formats . "\n";
        }    # if lines_missing

        # Store metadata as direct hash keys
        $E_vidhosp{CALC_NBR}               = $line_cur;
        $E_vidhosp{CALC_DISTINCT_IEP} = scalar keys %C_iep;
        $E_vidhosp{CALC_DISTINCT_SS}  = scalar keys %C_ss;

        my $E_result = \%E_vidhosp;
        bless( $E_result, "VIDHOSP" );
        return ($E_result);
    }

    # sub readfrom

################################################################################
    # In: VIDHOSP
    # Out: Array of hashes : [{IEP, SS, CODE, NOTE}]
    sub noncpam {
        my $E_self = shift;
        my @I_result;
        my $line_nbr;
        my $line_cur;

        my $adderror = sub {
            my $reason = shift;
            my $note   = shift;
            push(
                @I_result,
                {
                    IEP  => $$E_self{iep}[$line_cur],
                    SS   => $$E_self{ss}[$line_cur],
                    CODE => $reason,
                    NOTE => $note
                }
            );
        };    #subref

        # Imbriqued subs tests

        my $test_ss = sub {
            if ( $$E_self{ss}[$line_cur] =~ m /^[3,4,9,0]/ ) {
                &$adderror( '-1', " ne commence pas par 1 2 5 6 7 8" );
            }    # if ss
        };    # subref

        my $test_clef_ss = sub {
            my $clef = ssclef( $$E_self{ss}[$line_cur] );

            if ( $$E_self{clef_ss}[$line_cur] != $clef ) {
                &$adderror( '-4', " clef incorrecte" );
            }    # if CLEF_SS != ssclef(ss)
        };

        my $test_42 = sub {
            &$test_ss;
        };    # subref

        my $test_85 = sub {
            if ( $$E_self{facturable_cpam}[$line_cur] == 1 ) {
                &$test_ss;
            }
            elsif ( $$E_self{facturable_cpam}[$line_cur] == 2 ) {
                &$adderror( '-2', " attente de decision sur taux" );
            }
            elsif ( $$E_self{facturable_cpam}[$line_cur] == 3 ) {
                &$adderror( '-3', " attente de decision sur droits" );
            }
            else {
                &$adderror( '0', " bug: non facturable sans savoir pourquoi" );
            }
        };    # subref

        # ATTENTION : can't just redefine test_ss. Must redo the former sub
        my $test_106 = sub {
            if ( $$E_self{facturable_cpam}[$line_cur] == 1 ) {
                if ( $$E_self{ss}[$line_cur] =~ m /^[3,4,9,0]/ ) {
                    &$adderror( '-1', " ne commence pas par 1 2 5 6 7 8" );
                }
                elsif ( $$E_self{ss}[$line_cur] =~ m/\d+/ ) {
                    &$test_clef_ss;
                }    # if ss
            }
            elsif ( $$E_self{facturable_cpam}[$line_cur] == 2 ) {
                &$adderror( '-2', " attente de decision sur taux" );
            }
            elsif ( $$E_self{facturable_cpam}[$line_cur] == 3 ) {
                &$adderror( '-3', " attente de decision sur droits" );
            }
            else {
                &$adderror( '0', " bug: non facturable sans savoir pourquoi" );
            }
        };    #subref

        my $test_107 = sub {
            if ( $$E_self{facturable_cpam}[$line_cur] == 0 ) {

                # get the reason
                my $reason = $$E_self{non_facturation_cpam}[$line_cur];
                my $note   = " bug: code erreur non renseigne";
                if ($reason) {
                    $note =
                      $signification_vidhosp{non_facturation_cpam}{$reason};
                }    # reason
                &$adderror( $reason, $note );
            }
            else {

                # if FACTURABLE_CPAM
                &$test_clef_ss;
            }    # facturable_cpam
        };    # subref

        # FIXME: replace this loop by a for on a range
        $line_nbr = $$E_self{CALC_NBR};
        $line_cur = 0;

        while ( $line_cur < $line_nbr ) {

            # non_facturation > clef_ss > facturable_cpam > ss
            # but empty values are possibles in a consistent format
            # and inconsistent formats are also possible

            if ( 0 == 1 ) {

                #defined $$E_self{non_facturation_cpam}[$line_cur]) {
                # the whole trip
                &$test_107;
            }
            elsif ( 0 == 2 ) {

        #defined $$E_self{clef_ss}[$line_cur]) {
        # without non_facturation = 106 format. clef_ss+ss+facturable_cpam exist
                &$test_106;
            }
            elsif ( defined $$E_self{facturable_cpam}[$line_cur] ) {

                # without clef_ss = 85 format. ss+facturable_cpam exist
                &$test_85;
            }
            else {

                # without facturable_cpam = 42 format. ss only
                &$test_42;
            }

            $line_cur++;

        }    # while
        return @I_result;
    }    # sub noncpam

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

    1;
}    # Package VIDHOSP

{

    package RSA;
    use base qw(FILEREAD);

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

    my %formats_rsa = (
        common => {
            format   => 'A9 A3',
            variable => [qw( finess version_rsa )],
            sql      => [qw/varchar(9) smallint/],
	    offset   => 12,
        },
        210 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A3 A5 A4 A2 A3 A4 A3 A3 A1 A2 A2 A2 A2 A1 A6 A6 A2 A2',
            rsa_variable => [
                qw(rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree sceances_nbr igs2 ghs duree_rea depassement_bornehaute inferieur_bornebasse nbr_actes_dialyse nbr_actes_ghm_24Z05Z nbr_actes_ghm_24Z06Z nbr_actes_ghm_24Z07Z prelevement_organe dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /
            ],
            rsa_offset     => 123,
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length	   => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A7 A1 A2',
	    actes_length   => 10,
            actes_variable => [qw( code phase iteration )],
            actes_pgsql    => [qw/ varchar(7) smallint smallint /],
        },
        211 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A4 A5 A4 A2 A3 A4 A4 A1 A4 A3 A3 A3 A1 A3 A3 A3 A3 A3 A3 A3 A1 A6 A6 A2 A4',
            rsa_variable => [
                qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree sceances_nbr igs2 ghs depassement_bornehaute inferieur_bornebasse nbr_actes_dialyse nbr_actes_ghm_24Z05Z nbr_actes_ghm_24Z06Z nbr_actes_ghm_24Z07Z prelevement_organe dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /
            ],
            rsa_offset     => 150,
            rum_variable   => [qw( type duree_uf valorisation_rea
apres_date_effet type_force position_dp )],
            rum_format     => 'A2 A3 A1 A1 A1 A2',
	    rum_length     => 10,
            rum_pgsql      => [qw/ smallint smallint smallint smallint smallint smallint /],
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length     => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A3 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length   => 21,
            actes_variable => [qw( delai code phase activite extension_documentaire modificateur remboursement_exceptionnel association_nonprevue iteration )],
            actes_pgsql    => [qw/ smallint varchar(7) smallint smallint  smallint varchar(4)  smallint varchar(1) smallint smallint /],
        },
        213 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A4 A5 A4 A2 A3 A4 A4 A1 A4 A3 A3 A3 A3 A2 A3 A3 A3 A3 A1 A3 A3 A3 A3 A3 A3 A3 A3 A3 A1 A6 A6 A2 A4',
            rsa_variable => [
                qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree sceances_nbr igs2 ghs depassement_bornehaute inferieur_bornebasse ghs_forfait_dialyse supplement_hemodialyse_hs supplement_entraitement_dialyseperit_auto_hs supplement_entraitement_dialyseperit_ambu_hs supplement_entraitement_hemodialyse_hs sceances_avant_sros nbr_actes_ghm_24Z05Z_ou_28Z11Z nbr_actes_ghm_24Z06Z_ou_28Z12Z nbr_actes_ghm_24Z07Z_ou_28Z13Z supplement_caisson_hyperbare type_prelevement_organe supplement_sra supplement_rea supplement_si_de_rea supplement_stf supplement_ssc supplement_src supplement_nn1 supplement_nn2 supplement_nn3 lit_dedie_palliatif dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /
            ],
            rsa_offset     => 174,
            rum_variable   => [qw( type duree_uf valorisation_rea
valorisation_partielle position_dp )],
            rum_format     => 'A2 A3 A1 A1 A2',
	    rum_length     => 9,
            rum_pgsql      => [qw/ smallint smallint smallint smallint smallint smallint /],
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length     => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A3 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length   => 21,
            actes_variable => [qw( delai code phase activite extension_documentaire modificateur remboursement_exceptionnel association_nonprevue iteration )],
            actes_pgsql    => [qw/ smallint varchar(7) smallint smallint  smallint varchar(4)  smallint varchar(1) smallint smallint /],
        },
        214 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A4 A5 A4 A2 A3 A4 A4 A1 A4 A3 A3 A3 A3 A2 A3 A3 A3 A3 A1 A3 A3 A3 A3 A3 A3 A3 A3 A3 A3 A1 A6 A6 A2 A4',
            rsa_variable => [
                qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree sceances_nbr igs2 ghs depassement_bornehaute inferieur_bornebasse ghs_forfait_dialyse supplement_hemodialyse_hs supplement_entraitement_dialyseperit_auto_hs supplement_entraitement_dialyseperit_ambu_hs supplement_entraitement_hemodialyse_hs sceances_avant_sros nbr_actes_ghm_24Z05Z_ou_28Z11Z nbr_actes_ghm_24Z06Z_ou_28Z12Z nbr_actes_ghm_24Z07Z_ou_28Z13Z supplement_caisson_hyperbare type_prelevement_organe supplement_sra supplement_rea supplement_si_de_rea supplement_stf supplement_ssc supplement_src supplement_nn1 supplement_nn2 supplement_nn3 supplement_rep lit_dedie_palliatif dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /
            ],
            rsa_offset     => 177,
            rum_variable   => [qw( type duree_uf valorisation_rea
valorisation_partielle position_dp )],
            rum_format     => 'A2 A3 A1 A1 A2',
	    rum_length     => 9,
            rum_pgsql      => [qw/ smallint smallint smallint smallint smallint smallint /],
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length     => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A3 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length   => 21,
            actes_variable => [qw( delai code phase activite extension_documentaire modificateur remboursement_exceptionnel association_nonprevue iteration )],
            actes_pgsql    => [qw/ smallint varchar(7) smallint smallint  smallint varchar(4)  smallint varchar(1) smallint smallint /],
        },
        215 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A4 A5 A4 A2 A2 A3 A4 A4 A1 A4 A3 A3 A3 A3 A2 A3 A3 A3 A3 A3 A3 A1 A3 A3 A3 A3 A3 A3 A3 A3 A3 A3 A1 A2 A6 A6 A2 A4',
            rsa_variable => [
                qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree age_gestationnel sceances_nbr igs2 ghs depassement_bornehaute inferieur_bornebasse ghs_forfait_dialyse supplement_hemodialyse_hs supplement_entraitement_dialyseperit_auto_hs supplement_entraitement_dialyseperit_ambu_hs supplement_entraitement_hemodialyse_hs sceances_avant_sros nbr_actes_ghs_9510 nbr_actes_ghs_9511 nbr_actes_ghs_9512 nbr_actes_ghs_9515 nbr_actes_ghs_9524 supplement_caisson_hyperbare type_prelevement_organe supplement_sra supplement_rea supplement_si_de_rea supplement_stf supplement_ssc supplement_src supplement_nn1 supplement_nn2 supplement_nn3 supplement_rep lit_dedie_palliatif quel_rum_donne_dp dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint smallint /
            ],
            rsa_offset     => 187,
            rum_variable   => [qw( type duree_uf valorisation_rea
valorisation_partielle dp dr )],
            rum_format     => 'A2 A3 A1 A1 A6 A6',
	    rum_length     => 19,
            rum_pgsql      => [qw/ smallint smallint smallint smallint smallint varchar(6) varchar(6) /],
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length     => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A2 A3 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length   => 23,
            actes_variable => [qw( rum_origine delai code phase activite extension_documentaire modificateur remboursement_exceptionnel association_nonprevue iteration )],
            actes_pgsql    => [qw/ smallint smallint varchar(7) smallint smallint  smallint varchar(4)  smallint varchar(1) smallint smallint /],
        },
        216 => {
            rsa_format =>
'A10 A3 A3 A2 A6 A3 A2 A6 A3 A2 A3 A3 A1 A1 A1 A2 A4 A1 A1 A1 A4 A5 A4 A2 A2 A3 A4 A4 A1 A3 A4 A1 A1 A3 A3 A3 A3 A3 A3 A3 A3 A3 A3 A3 A3 x23 A3 A1 A3 A3 A3 A3 A3 A3 A3 A3 A1 A1 A1 A2 A6 A6 A2 A5',
            rsa_variable => [
                qw( rsa version_rss version_genrsa version_lu ghm_lu retour_lu version_mis ghm_mis retour_mis nb_rum age_annee age_jour sexe entree provenance mois_sortie annee_sortie sortie destination type duree cp_residence poids_nne_entree age_gestationnel sceances_nbr igs2 ghs depassement_bornehaute type_inferieur_bornebasse inferieur_bornebasse ghs_forfait_dialyse uhcd confirmation_sejour supplement_hemodialyse_hs supplement_entraitement_dialyseperit_auto_hs supplement_entraitement_dialyseperit_ambu_hs supplement_entraitement_hemodialyse_hs nbr_actes_ghs_9610 nbr_actes_ghs_9611 nbr_actes_ghs_9612 nbr_actes_ghs_9619 nbr_actes_ghs_9620 nbr_actes_ghs_9623 nbr_actes_ghs_9621 nbr_actes_ghs_9615 supplement_caisson_hyperbare type_prelevement_organe supplement_sra supplement_rea supplement_si_de_rea supplement_stf supplement_src supplement_nn1 supplement_nn2 supplement_nn3 supplement_rep lit_dedie_palliatif type_radiotherapie type_dosimetrie quel_rum_donne_dp dp dr das_nbr actes_nbr )
            ],
            rsa_pgsql => [
                qw/ bigint smallint smallint smallint varchar(6) smallint smallint varchar(6) smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint int varchar(5) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(1) smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) smallint int /
            ],
            rsa_offset     => 219,
            rum_variable   => [qw( type duree_uf valorisation_rea
indicateur_src valorisation_partielle dp dr )],
            rum_format     => 'A2 A3 A1 A1 A6 A6',
	    rum_length     => 20,
            rum_pgsql      => [qw/ smallint smallint smallint smallint smallint smallint varchar(6) varchar(6) /],
            das_variable   => [qw( das )],
            das_format     => 'A6',
	    das_length     => 6,
            das_pgsql      => [qw/ varchar(6) /],
            actes_format   => 'A2 A3 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length   => 23,
            actes_variable => [qw( rum_origine delai code phase activite extension_documentaire modificateur remboursement_exceptionnel association_nonprevue iteration )],
            actes_pgsql    => [qw/ smallint smallint varchar(7) smallint smallint  smallint varchar(4)  smallint varchar(1) smallint smallint /],
        }
    );

    sub checkallformats {
	my @formats = qw /210 211 213 214 215 216/;

	for (my $i=0; $i < $#formats ; $i++ ) {
	print "RSA " . $formats[$i] . ":\n";
	my $format = $formats_rsa{$formats[$i]};
	checkformat($format);
	print "\n";
	}
} # sub checkallformats

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

        open( IFD, "<" . $infile )
          or croak( "Ne peut lire " . $infile . " !\n" );

        while ( my $line_read = <IFD> ) {
            # ATTENTION : we need to start at 0 to fill the arrays but $. starts
            # at 1
            $line_cur = $. - 1;

            # Do a first read with the common format to find the relevant format
            my $commonformat   = $formats_rsa{common};
            my @commonvariable = @{ $commonformat->{'variable'} };
            my %commonvalue;
            @commonvalue{@commonvariable} =
              unpack( $commonformat->{'format'}, $line_read );

            my $formatreference = $formats_rsa{ $commonvalue{version_rsa} };
            unless ($formatreference) {
                $line_missing{ $commonvalue{version_rsa} }++;
                next;
            }

            # Use the version read to decide which format to use, and
            # prepare a jump because the pointer is reinitialised after
            # the first read

            my $rsa_format= 'x' . $commonformat->{'offset'} . ' ' . $formatreference->{'rsa_format'};

            # ATTENTION : can't unpack directly into E_rsa because can't
            # make an array of lvalues from an array of scalar refs, so here a
            # temporary vаriable must be used.
	    # Moreover there are multiple different regexps and this push/pop
	    # syntax is not supported: das_format => '@125 A2 @165/(A8)',

            my @rsa_variable = @{ $formatreference->{'rsa_variable'} };

            my %rsa_value;
            @rsa_value{@rsa_variable} = unpack( $rsa_format, $line_read );


my $cumulative_jump=$formatreference->{'rsa_offset'};

if ($formatreference->{'rum_format'}) {
 if ($rsa_value{'rum_nbr'}) {
my $rum_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'rum_format'};
            my @rum_variable = @{ $formatreference->{'rum_variable'} };
            my %rum_value;
            @rum_value{@rum_variable} = unpack( $rum_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'rum_length'}*$rsa_value{'rum_nbr'});
 } # rum_nbr
} # rum_format

if ($formatreference->{'das_format'}) {
 if ($rsa_value{'das_nbr'}) {
my $das_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'das_format'};
            my @das_variable = @{ $formatreference->{'das_variable'} };
            my %das_value;
            @das_value{@das_variable} = unpack( $das_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'das_length'}*$rsa_value{'das_nbr'});
 } # das_nbr
} # das_format

if ($formatreference->{'dad_format'}) {
 if ($rsa_value{'dad_nbr'}) {
my $dad_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'dad_format'};
            my @dad_variable = @{ $formatreference->{'dad_variable'} };
            my %dad_value;
            @dad_value{@dad_variable} = unpack( $dad_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'dad_length'}*$rsa_value{'dad_nbr'});
 } # dad_nbr
} # dad_format

if ($formatreference->{'actes_format'}) {
 if ($rsa_value{'actes_nbr'}) {
my $actes_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'actes_format'};
            my @actes_variable = @{ $formatreference->{'actes_variable'} };
            my %actes_value;
            @actes_value{@actes_variable} = unpack( $actes_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'actes_length'}*$rsa_value{'actes_nbr'});
 } # actes_nbr
} # actes_format

            # Finally, add the common part to the format dependant part
            for my $commonpart ( keys %commonvalue ) {
                $E_rsa{$commonpart}[$line_cur] = $commonvalue{$commonpart};
            }    # for
            for my $rsa_part ( keys %rsa_value ) {
                unless ( $rsa_part =~ /^CALC_.*/) {
                 $E_rsa{$rsa_part}[$line_cur] = $rsa_value{$rsa_part};
		}
            }    # for
#FIXME: add for loops for rum, das, actes

            $line_cur++;
        }    # while

        my $line_missing_nbr = 0;
        foreach my $missing_nbr ( values %line_missing ) {
            $line_missing_nbr += $missing_nbr;
        }
        my $line_missing_formats;
        foreach my $missing_format ( values %line_missing ) {
            $line_missing_formats .= $missing_format;
        }

        if ( $line_missing_nbr > 0 ) {
            printf STDERR "ERREUR : "
              . $line_missing_nbr
              . " lignes non lues, car formats" . $line_missing_formats . "\n";
        }    # if lines_missing

        # Store metadata as direct hash keys
        $E_rsa{CALC_NBR} = $line_cur;

        my $E_result = \%E_rsa;
        bless( $E_result, "RSA" );
        return ($E_result);
    }

    # sub readfrom

    1;
}    # Package RSA

{
    package RSS;
    use base qw(FILEREAD);

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

    my %formats_rss = (

        common => {
            format   => 'A2 A2 A4 x1 A3',
            variable => [qw(version_groupage cmd ghm version_rss )],
            sql      => [qw/smallint varchar(2) varchar(4) smallint/],
	    offset   => 12,
        },
        110 => {
            rum_format => 'A3 A9 A3 A7 A8 A1 A4 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2
A2 A2 A8 A8 A3 x15',
            rum_variable => [
                qw( code_retour finess version_rum rss naissance sexe uf date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )
            ],
            rum_pgsql => [
                qw/ smallint varchar(9) smallint int timestamp varchar(1) smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint varchar(8) varchar(8) smallint/
            ],
            rum_offset     => 118,
            das_variable   => [qw( das )],
            das_format     => 'A8',
	    das_length	=> 8,
            das_pgsql      => [qw/ varchar(8) /],
            dad_variable   => [qw( dad )],
            dad_format     => 'A8',
	    dad_length	=> 8,
            dad_pgsql      => [qw/ varchar(8) /],
            actes_format   => 'A7 A1 A2',
	    actes_length	=> 10,
            actes_variable => [qw(code phase iteration)],
            actes_pgsql    => 'varchar(7) smallint smallint',
        },
        111 => {
            rum_format =>
'A3 A9 A3 A7 A20 A8 A1 A4 A2 A2 x1 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A8 A8 A3 x15',
            rum_variable => [
                qw( code_retour finess version_rum rss iep naissance sexe uf uf_autorisation lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )
            ],
            rum_pgsql => [
                qw/ smallint varchar(9) smallint int int timestamp varchar(1) smallint smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint varchar(8) varchar(8) smallint/
            ],
            rum_offset   => 143,
            das_variable => [qw( das )],
            das_format   => 'A8',
	    das_length	=> 8,
            das_pgsql    => [qw/ varchar(8) /],
            dad_variable => [qw( dad )],
            dad_format   => 'A8',
	    dad_length	=> 8,
            dad_pgsql    => [qw/ varchar(8) /],
            actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length => 26,
            actes_variable => [qw(date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration)],
            actes_pgsql =>
'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
        },

        113 => {
            rum_format =>
'A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A2 A8 A8 A3 x15',
            rum_variable => [
                qw( code_retour finess version_rum rss iep rum naissance sexe uf lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree age_gestationnel sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 )
            ],
            rum_pgsql => [
                qw/ smallint varchar(9) smallint int int int timestamp varchar(1) smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint smallint varchar(8) varchar(8) smallint/
            ],
            rum_offset   => 165,
            das_variable => [qw( das )],
            das_format   => 'A8',
	    das_length	=> 8,
            das_pgsql    => [qw/ varchar(8) /],
            dad_variable => [qw( dad )],
            dad_format   => 'A8',
	    dad_length	=> 8,
            dad_pgsql    => [qw/ varchar(8) /],
            actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length	=> 26,
            actes_variable => [qw(date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration)],
            actes_pgsql =>
'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
        },

        114 => {
            rum_format =>
'A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A3 A8 A8 A3 A1 A1 A1 x11',
            rum_variable => [
                qw( code_retour finess version_rum rss iep rum naissance sexe uf lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree age_gestationnel sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 confirmation_codage type_radiotherapie type_dosimetrie )
            ],
            rum_pgsql => [
                qw/ smallint varchar(9) smallint int int int timestamp varchar(1) smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint smallint varchar(8) varchar(8) smallint smallint smallint smallint /
            ],
            rum_offset   => 165,
            das_variable => [qw( das )],
            das_format   => 'A8',
	    das_length	=> 8,
            das_pgsql    => [qw/ varchar(8) /],
            dad_variable => [qw( dad )],
            dad_format   => 'A8',
	    dad_length	=> 8,
            dad_pgsql    => [qw/ varchar(8) /],
            actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length	=> 26,
            actes_variable => [qw(date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration)],
            actes_pgsql =>
'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
        },

        115 => {
            rum_format =>
'A3 A9 A3 A20 A20 A10 A8 A1 A4 A2 A8 A1 A1 A8 A1 A1 A5 A4 A2 A2 A2 A2 A3 A8 A8 A3 A1 A1 A1 A1 x10',
            rum_variable => [ 
                qw( code_retour finess version_rum rss iep rum naissance sexe uf lit_autorisation date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree age_gestationnel sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 confirmation_codage type_radiotherapie type_dosimetrie nombre_faisceaux )
            ],
            rum_pgsql => [
                qw/ smallint varchar(9) smallint int int int timestamp varchar(1) smallint smallint timestamp smallint smallint timestamp smallint smallint int int smallint smallint smallint smallint smallint varchar(8) varchar(8) smallint smallint smallint smallint smallint /
            ],
	    rum_signification => [
		type_radiotherapie => { 1 => "machine dediee", 2=> "machine avec repositionnement du malade a distance", 3 => "machine sans repositionnement du malade a distance", 4 => "machine sans imagerie portale, collimateur multilame, ou systeme enregistrement et controle" },
		type_dosimetrie => { 1 => "RCMI", 2 => "3d avec HDV", 3 => "3d sans HDV", 4 => "autre" },
	    ],
            rum_offset   => 165,
            das_variable => [qw( das )],
            das_format   => 'A8',
	    das_length	=> 8,
            das_pgsql    => [qw/ varchar(8) /],
            dad_variable => [qw( dad )],
            dad_format   => 'A8',
	    dad_length	=> 8,
            dad_pgsql    => [qw/ varchar(8) /],
            actes_format => 'A8 A7 A1 A1 A1 A4 A1 A1 A2',
	    actes_length	=> 26,
            actes_variable => [qw(date_acte code phase activite ext_doc modificateur remb_exceptionnel assoc_nonprevue iteration)],
            actes_pgsql =>
'timestamp varchar(7) smallint smallint smallint varchar(4) varchar(1) smallint smallint',
	},
    );

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
        my %E_rss;

        # Result : object
        my %E_result;

        open( IFD, "<" . $infile )
          or croak( "Ne peut lire " . $infile . " !\n" );

        while ( my $line_read = <IFD> ) {
            # ATTENTION : we need to start at 0 to fill the arrays but $. starts
            # at 1
            $line_cur = $. - 1;

            # Do a first read with the common format to find the relevant format
            my $commonformat   = $formats_rss{common};
            my @commonvariable = @{ $commonformat->{'variable'} };
            my %commonvalue;
            @commonvalue{@commonvariable} =
              unpack( $commonformat->{'format'}, $line_read );

            my $formatreference = $formats_rss{ $commonvalue{version_rss} };
            unless ($formatreference) {
                $line_missing{ $commonvalue{version_rss} }++;
                next;
            }

            # Use the version read to decide which format to use, and
            # prepare a jump because the pointer is reinitialised after
            # the first read

            my $rum_format= 'x' . $commonformat->{'offset'} . ' ' . $formatreference->{'rum_format'};

            # ATTENTION : can't unpack directly into E_rss because can't
            # make an array of lvalues from an array of scalar refs, so here a
            # temporary vаriable must be used.
	    # Moreover there are multiple different regexps and this push/pop
	    # syntax is not supported: das_format => '@125 A2 @165/(A8)',

            my @rum_variable = @{ $formatreference->{'rum_variable'} };

            my %rss_value;
            @rss_value{@rum_variable} = unpack( $rum_format, $line_read );


my $cumulative_jump=$formatreference->{'rum_offset'};

if ($formatreference->{'rum_format'}) {
 if ($rss_value{'rum_nbr'}) {
my $rum_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'rum_format'};
            my @rum_variable = @{ $formatreference->{'rum_variable'} };
            my %rum_value;
            @rum_value{@rum_variable} = unpack( $rum_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'rum_length'}*$rss_value{'rum_nbr'});
 } # rum_nbr
} # rum_format

if ($formatreference->{'das_format'}) {
 if ($rss_value{'das_nbr'}) {
my $das_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'das_format'};
            my @das_variable = @{ $formatreference->{'das_variable'} };
            my %das_value;
            @das_value{@das_variable} = unpack( $das_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'das_length'}*$rss_value{'das_nbr'});
 } # das_nbr
} # das_format

if ($formatreference->{'dad_format'}) {
 if ($rss_value{'dad_nbr'}) {
my $dad_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'dad_format'};
            my @dad_variable = @{ $formatreference->{'dad_variable'} };
            my %dad_value;
            @dad_value{@dad_variable} = unpack( $dad_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'dad_length'}*$rss_value{'dad_nbr'});
 } # dad_nbr
} # dad_format

if ($formatreference->{'actes_format'}) {
 if ($rss_value{'actes_nbr'}) {
my $actes_format = 'x' . $cumulative_jump . ' ' . $formatreference->{'actes_format'};
            my @actes_variable = @{ $formatreference->{'actes_variable'} };
            my %actes_value;
            @actes_value{@actes_variable} = unpack( $actes_format, $line_read );
# increment cumulative_jump for next step
$cumulative_jump=$cumulative_jump+($formatreference->{'actes_length'}*$rss_value{'actes_nbr'});
 } # actes_nbr
} # actes_format

# If you get a "Not an ARRAY reference" bug, check the format !
#
#my @rum_variable_lenght = split (" ", $formatreference->{'rum_format'});
#my $test=0;
#my $total= @rum_variable;
#while ($test < $total ) {
#print $rum_variable[$test] . " = " . $rum_variable_lenght[$test] . "\n";
#$test++;
#}
            # Finally, add the common part to the format dependant part
            for my $commonpart ( keys %commonvalue ) {
                $E_rss{$commonpart}[$line_cur] = $commonvalue{$commonpart};
            }    # for
            for my $rss_part ( keys %rss_value ) {
                unless ( $rss_part =~ /^CALC_.*/) {
                 $E_rss{$rss_part}[$line_cur] = $rss_value{$rss_part};
		}
            }    # for
#FIXME: add for loops for rum, das, actes

            $line_cur++;
        }    # while

        my $line_missing_nbr = 0;
        foreach my $missing_nbr ( values %line_missing ) {
            $line_missing_nbr += $missing_nbr;
        }
        my $line_missing_formats;
        foreach my $missing_format ( values %line_missing ) {
            $line_missing_formats .= $missing_format;
        }

        if ( $line_missing_nbr > 0 ) {
            printf STDERR "ERREUR : "
              . $line_missing_nbr
              . " lignes non lues, car formats" . $line_missing_formats . "\n";
        }    # if lines_missing

        # Store metadata as direct hash keys
        $E_rss{CALC_NBR} = $line_cur;

        my $E_result = \%E_rss;
        bless( $E_result, "RSS" );
        return ($E_result);
    }

    # sub readfrom

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

    # sub calculs
    # FIXME: a faire par uf, pole, total ou par autre critere (ex: ghm)
    # FIXME: pouvoir faire une intersection ou union entre criteres

    1;
}    # Package RSS

# TODO : rajouter import de tuple IPP,IEP fils
# TODO : rajouter fonction rss1_extrapole=extrapolatedas(rss1, rss2)

use Data::Dumper;

## Lecture du VIDHOSP
#
#my $E_vidhosp_2009=VIDHOSP::readfrom("vidhosp-2009d-m7.txt");
#print "VIDHOSP : ". $E_vidhosp_2009->nbr . " lignes lues : " . total_size(\$E_vidhosp_2009) . " bytes\n";
#print $E_vidhosp_2009->distinct_iep . " iep uniques " . $E_vidhosp_2009->distinct_ss . " ss uniques\n";
#
## Extraction des erreurs
#
#my @noncpam_2009=$E_vidhosp_2009->noncpam;
#foreach my $erreur (@noncpam_2009) {
#print "IEP= " . $$erreur{IEP} . " SS= " .  $$erreur{SS} . " : " .  $$erreur{NOTE} . "\n";
#} # foreach

# Lecture des RSS

my $E_rss_2009=RSS::readfrom("rss-2009.txt");
print "rss : ". $E_rss_2009->nbr . " lignes lues : " . total_size(\$E_rss_2009) . " bytes\n";
print $E_rss_2009->distinct_iep . " iep uniques " . $E_rss_2009->distinct_rss . " rss uniques\n";
$E_rss_2009->list;

# Lecture des RSA

my $E_rsa_2009 = RSA::readfrom("rsa-2009.txt");
$E_rsa_2009 ->RSA::tocsv;

# Lecture des MON

my $E_fichcomp_mon_2009 = FICHCOMP::readfrom("fichcompmon-2009.txt");
print "Fichcomp MON : " . $E_fichcomp_mon_2009->nbr . " lignes lues : " .  total_size(\$E_fichcomp_mon_2009) . " bytes\n";
$E_fichcomp_mon_2009->FICHCOMP::tocsv;
$E_fichcomp_mon_2009->FICHCOMP::value;

# Comparaison IEP des MON et RSS

my @E_rss_2009_distinct_iep=$E_rss_2009->distinct_iep;
my @E_fichcomp_mon_2009_distinct_iep=$E_fichcomp_mon_2009->distinct_iep;
my @mon_iep_non_rss=@E_fichcomp_mon_2009_distinct_iep;

for(my $i=0; $i<=$#E_fichcomp_mon_2009_distinct_iep; $i++){
  foreach my $element (@E_rss_2009_distinct_iep){
    if ($E_fichcomp_mon_2009_distinct_iep[$i] =~ m/$element/i){
      delete $mon_iep_non_rss[$i];
    } # if
  } # foreach
} # for
