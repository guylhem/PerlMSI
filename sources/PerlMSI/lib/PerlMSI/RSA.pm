{
    package PerlMSI::RSA;
    use 5.008008;
 
    our @ISA = qw(Exporter FILEREAD);
    our @EXPORT = qw(checkallformat readfrom);
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
