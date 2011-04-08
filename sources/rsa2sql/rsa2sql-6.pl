#!/usr/bin/perl
#
#    Copyright (C) 2008,2009,2010 Guylhem
#
#    This program is free software: you can redistribute it and/or
#    modify it under the terms of the GNU Affero General Public License
#    as published by the Free Software Foundation, either version 3 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public
#    License along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.

use DBI;

#use warnings;
#use strict;
#use Data::Dumper; #uncomment for debugging

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = "DEFAULT"; }
    return $out;
}

unless ( scalar @ARGV == 3 ) {
    die "Usage:\n\t$0 RSA.grp annee prefixesql\n";
}

$infile = $ARGV[0];
$annee  = $ARGV[1];
$prefixesql = $ARGV[2];

open( IFD, "<$infile" ) or die( "Can't read input file " . $infile . " !\n" );

$line_cur = 0;
while ( $rsa_line = <IFD> ) {

    # commencer par lire la version de RSS pour parser différemment

    $finess      = mysubstr( $rsa_line, 0, 9 );
    $version_rsa = mysubstr( $rsa_line, 9, 3 );

    if ( $version_rsa == 216 ) {

        if ( $schema_sql != 1 ) {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;
drop table " . $prefixesql . "_rum_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . "  (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 sequence_tarif smallint,
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 age_gestationnel smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 depassement_bornehaute smallint,
 type_inferieur_bornebasse smallint,
 inferieur_bornebasse smallint,
 ghs_forfait_dialyse char(9),
 uhcd smallint,
 confirmation_sejour smallint,
 supplement_hemodialyse_hs smallint,
 supplement_entraitement_dialyseperit_auto_hs smallint,
 supplement_entraitement_dialyseperit_ambu_hs smallint,
 supplement_entraitement_hemodialyse_hs smallint,
 sceances_avant_sros smallint,
 nbr_actes_ghs_9610 smallint,
 nbr_actes_ghs_9611 smallint,
 nbr_actes_ghs_9612 smallint,
 nbr_actes_ghs_9619 smallint,
 nbr_actes_ghs_9620 smallint,
 nbr_actes_ghs_6523 smallint,
 nbr_actes_ghs_9621 smallint,
 nbr_actes_ghs_9615 smallint,
 filler_ex_sceances_avant_sros char(9),
 filler_ex_supplement_sra char(9),
 filler_ex_supplement_ssc char (9),
 filler char(16),
 supplement_caisson_hyperbare smallint,
 type_prelevement_organe smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 supplement_rep smallint,
 lit_dedie_palliatif smallint,
 type_radiotherapie smallint,
 type_dosimetrie smallint,
 quel_rum_donne_dp smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_rum_" . $annee . "  (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint,
 indicateur_src smallint, 
 valorisation_partielle smallint,
 dp_rum char(9),
 dr_rum char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 quel_rum_donne_acte smallint,
 delai smallint,
 code_ccam char(8),
 phase char(9),
 activite smallint,
 ext_doc char(9),
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                       = mysubstr( $rsa_line, 12,  10 );
        $version_rss               = mysubstr( $rsa_line, 22,  3 );
        $sequence_tarif            = mysubstr( $rsa_line, 25,  3 );
        $version_lu                = mysubstr( $rsa_line, 28,  2 );
        $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
        $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
        $version_mis               = mysubstr( $rsa_line, 39,  2 );
        $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
        $retour_mis                = mysubstr( $rsa_line, 47,  3 );
        $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
        $age_annee                 = mysubstr( $rsa_line, 52,  3 );
        $age_jour                  = mysubstr( $rsa_line, 55,  3 );
        $sexe                      = mysubstr( $rsa_line, 58,  1 );
        $entree                    = mysubstr( $rsa_line, 59,  1 );
        $provenance                = mysubstr( $rsa_line, 60,  1 );
        $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
        $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
        $sortie                    = mysubstr( $rsa_line, 67,  1 );
        $destination               = mysubstr( $rsa_line, 68,  1 );
        $type                      = mysubstr( $rsa_line, 69,  1 );
# 0 si scÃ©ances
        $duree                     = mysubstr( $rsa_line, 70,  4 );
        $cp_residence              = mysubstr( $rsa_line, 74,  5 );
        $poids_nne_entree          = mysubstr( $rsa_line, 79,  4 );
        $age_gestationnel          = mysubstr( $rsa_line, 83,  2 );
        $nbr_sceances              = mysubstr( $rsa_line, 85,  2 );
        $igs2                      = mysubstr( $rsa_line, 87,  3 );
        $ghs                       = mysubstr( $rsa_line, 90,  4 );
        $depassement_bornehaute    = mysubstr( $rsa_line, 94,  4 );
        $type_inferieur_bornebasse = mysubstr( $rsa_line, 98,  1 );
        $inferieur_bornebasse      = mysubstr( $rsa_line, 99,  3 );
        $ghs_forfait_dialyse       = mysubstr( $rsa_line, 102, 4 );
        $uhcd			   = mysubstr( $rsa_line, 106, 1 );
	$confirmation_sejour	   = mysubstr( $rsa_line, 107, 1 );
        $supplement_hemodialyse_hs = mysubstr( $rsa_line, 108, 3 );
        $supplement_entraitement_dialyseperit_auto_hs =
          mysubstr( $rsa_line, 111, 3 );
        $supplement_entraitement_dialyseperit_ambu_hs =
          mysubstr( $rsa_line, 114, 3 );
        $supplement_entraitement_hemodialyse_hs = mysubstr( $rsa_line, 117, 3 );
	$nbr_actes_ghs_9610			= mysubstr( $rsa_line, 120, 3 );
        $nbr_actes_ghs_9611			= mysubstr( $rsa_line, 123, 3 );
        $nbr_actes_ghs_9612			= mysubstr( $rsa_line, 126, 3 );
        $nbr_actes_ghs_9619			= mysubstr( $rsa_line, 129, 3 );
        $nbr_actes_ghs_9620			= mysubstr( $rsa_line, 132, 3 );
        $nbr_actes_ghs_6523			= mysubstr( $rsa_line, 135, 3 );
        $nbr_actes_ghs_9621			= mysubstr( $rsa_line, 138, 3 );
        $nbr_actes_ghs_9615			= mysubstr( $rsa_line, 141, 3 );
	$filler_ex_sceances_avant_sros		= mysubstr( $rsa_line, 144, 2 );
	$filler_ex_supplement_sra		= mysubstr( $rsa_line, 146, 3 );
	$filler_ex_supplement_ssc		= mysubstr( $rsa_line, 149, 3 );
	$filler					= mysubstr( $rsa_line, 152, 15 );
        $supplement_caisson_hyperbare           = mysubstr( $rsa_line, 167, 3 );
        $type_prelevement_organe                = mysubstr( $rsa_line, 170, 1 );
        $supplement_rea                         = mysubstr( $rsa_line, 171, 3 );
        $supplement_si_de_rea                   = mysubstr( $rsa_line, 174, 3 );
        $supplement_stf                         = mysubstr( $rsa_line, 177, 3 );
        $supplement_src                         = mysubstr( $rsa_line, 180, 3 );
        $supplement_nn1                         = mysubstr( $rsa_line, 183, 3 );
        $supplement_nn2                         = mysubstr( $rsa_line, 186, 3 );
        $supplement_nn3                         = mysubstr( $rsa_line, 189, 3 );
        $supplement_rep                         = mysubstr( $rsa_line, 192, 3 );
        $lit_dedie_palliatif                    = mysubstr( $rsa_line, 195, 1 );
        $type_radiotherapie			= mysubstr( $rsa_line, 196, 1 );
        $type_dosimetrie			= mysubstr( $rsa_line, 197, 1 );
        $quel_rum_donne_dp                      = mysubstr( $rsa_line, 198, 2 );
        $dp                                     = mysubstr( $rsa_line, 200, 6 );
        $dr                                     = mysubstr( $rsa_line, 206, 6 );
        $nb_diags                               = mysubstr( $rsa_line, 212, 2 );
        $nb_actes                               = mysubstr( $rsa_line, 214, 5 );

        # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
        $offset    = 219;
        $rum_nbr   = $nb_rum;
        $das_nbr   = $nb_diags;
        $actes_nbr = $nb_actes;

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $rum_type_rum[$rum_cur] = mysubstr( $rsa_line, $offset, 2 );
                $rum_duree_uf[$rum_cur] = mysubstr( $rsa_line, $offset + 2, 3 );
                $rum_valorisation_rea[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 1 );
                $rum_indicateur_src[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1, 1);
                $rum_valorisation_partielle[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1 , 1 );
                $rum_dp[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1 + 1 , 6 );
                $rum_dr[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1 + 1 + 6, 6 );
                $offset = $offset + 2 + 3 + 1 + 1 + 1 + 6 + 6;
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr
        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_rum_origine[$actes_cur] = mysubstr( $rsa_line, $offset, 2 );
                $acte_delai[$actes_cur] = mysubstr( $rsa_line, $offset, 2 + 3 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

    } elsif ( $version_rsa == 215 ) {
        if ( $schema_sql != 1 ) {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;
drop table " . $prefixesql . "_rum_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . "  (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 sequence_tarif smallint,
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 age_gestationnel smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 ghs_forfait_dialyse char(9),
 supplement_hemodialyse_hs smallint,
 supplement_entraitement_dialyseperit_auto_hs smallint,
 supplement_entraitement_dialyseperit_ambu_hs smallint,
 supplement_entraitement_hemodialyse_hs smallint,
 sceances_avant_sros smallint,
 nbr_actes_ghs_9510 smallint,
 nbr_actes_ghs_9511 smallint,
 nbr_actes_ghs_9512 smallint,
 nbr_actes_ghs_9515 smallint,
 nbr_actes_ghs_9524 smallint,
 supplement_caisson_hyperbare smallint,
 type_prelevement_organe smallint,
 supplement_sra smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_ssc smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 supplement_rep smallint,
 lit_dedie_palliatif smallint,
 quel_rum_donne_dp smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_rum_" . $annee . "  (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint, 
 valorisation_partielle smallint,
 dp_rum char(9),
 dr_rum char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 quel_rum_donne_acte smallint,
 delai smallint,
 code_ccam char(8),
 phase char(9),
 activite smallint,
 ext_doc char(9),
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                       = mysubstr( $rsa_line, 12,  10 );
        $version_rss               = mysubstr( $rsa_line, 22,  3 );
        $sequence_tarif            = mysubstr( $rsa_line, 25,  3 );
        $version_lu                = mysubstr( $rsa_line, 28,  2 );
        $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
        $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
        $version_mis               = mysubstr( $rsa_line, 39,  2 );
        $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
        $retour_mis                = mysubstr( $rsa_line, 47,  3 );
        $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
        $age_annee                 = mysubstr( $rsa_line, 52,  3 );
        $age_jour                  = mysubstr( $rsa_line, 55,  3 );
        $sexe                      = mysubstr( $rsa_line, 58,  1 );
        $entree                    = mysubstr( $rsa_line, 59,  1 );
        $provenance                = mysubstr( $rsa_line, 60,  1 );
        $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
        $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
        $sortie                    = mysubstr( $rsa_line, 67,  1 );
        $destination               = mysubstr( $rsa_line, 68,  1 );
        $type                      = mysubstr( $rsa_line, 69,  1 );
        $duree                     = mysubstr( $rsa_line, 70,  4 );
        $cp_residence              = mysubstr( $rsa_line, 74,  5 );
        $poids_nne_entree          = mysubstr( $rsa_line, 79,  4 );
        $age_gestationnel          = mysubstr( $rsa_line, 83,  2 );
        $nbr_sceances              = mysubstr( $rsa_line, 85,  2 );
        $igs2                      = mysubstr( $rsa_line, 87,  3 );
        $ghs                       = mysubstr( $rsa_line, 90,  4 );
        $depassement_bornehaute    = mysubstr( $rsa_line, 94,  4 );
        $inferieur_bornebasse      = mysubstr( $rsa_line, 98,  1 );
        $ghs_forfait_dialyse       = mysubstr( $rsa_line, 99,  4 );
        $supplement_hemodialyse_hs = mysubstr( $rsa_line, 103, 3 );
        $supplement_entraitement_dialyseperit_auto_hs =
          mysubstr( $rsa_line, 106, 3 );
        $supplement_entraitement_dialyseperit_ambu_hs =
          mysubstr( $rsa_line, 109, 3 );
        $supplement_entraitement_hemodialyse_hs = mysubstr( $rsa_line, 112, 3 );
        $sceances_avant_sros                    = mysubstr( $rsa_line, 115, 2 );
        $nbr_actes_ghs_9510			= mysubstr( $rsa_line, 117, 3 );
        $nbr_actes_ghs_9511			= mysubstr( $rsa_line, 120, 3 );
        $nbr_actes_ghs_9512			= mysubstr( $rsa_line, 123, 3 );
        $nbr_actes_ghs_9515			= mysubstr( $rsa_line, 126, 3 );
        $nbr_actes_ghs_9524			= mysubstr( $rsa_line, 129, 3 );
        $supplement_caisson_hyperbare           = mysubstr( $rsa_line, 132, 3 );
        $type_prelevement_organe                = mysubstr( $rsa_line, 135, 1 );
        $supplement_sra                         = mysubstr( $rsa_line, 136, 3 );
        $supplement_rea                         = mysubstr( $rsa_line, 139, 3 );
        $supplement_si_de_rea                   = mysubstr( $rsa_line, 142, 3 );
        $supplement_stf                         = mysubstr( $rsa_line, 145, 3 );
        $supplement_ssc                         = mysubstr( $rsa_line, 148, 3 );
        $supplement_src                         = mysubstr( $rsa_line, 151, 3 );
        $supplement_nn1                         = mysubstr( $rsa_line, 154, 3 );
        $supplement_nn2                         = mysubstr( $rsa_line, 157, 3 );
        $supplement_nn3                         = mysubstr( $rsa_line, 160, 3 );
        $supplement_rep                         = mysubstr( $rsa_line, 163, 3 );
        $lit_dedie_palliatif                    = mysubstr( $rsa_line, 166, 1 );
        $quel_rum_donne_dp                      = mysubstr( $rsa_line, 167, 2 );
        $dp                                     = mysubstr( $rsa_line, 169, 6 );
        $dr                                     = mysubstr( $rsa_line, 175, 6 );
        $nb_diags                               = mysubstr( $rsa_line, 181, 2 );
        $nb_actes                               = mysubstr( $rsa_line, 183, 4 );

        # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
        $offset    = 187;
        $rum_nbr   = $nb_rum;
        $das_nbr   = $nb_diags;
        $actes_nbr = $nb_actes;

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $rum_type_rum[$rum_cur] = mysubstr( $rsa_line, $offset, 2 );
                $rum_duree_uf[$rum_cur] = mysubstr( $rsa_line, $offset + 2, 3 );
                $rum_valorisation_rea[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 1 );
                $rum_valorisation_partielle[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1, 1 );
                $rum_dp[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1, 6 );
                $rum_dr[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1 + 6, 6 );
                $offset = $offset + 2 + 3 + 1 + 1 + 6 + 6;
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr
        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_rum_origine[$actes_cur] = mysubstr( $rsa_line, $offset, 2 );
                $acte_delai[$actes_cur] = mysubstr( $rsa_line, $offset, 2 + 3 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 2 + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

    } elsif ( $version_rsa == 214 ) {
        if ( $schema_sql != 1 ) {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;
drop table " . $prefixesql . "_rum_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . "  (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 sequence_tarif smallint,
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 ghs_forfait_dialyse char(9),
 supplement_hemodialyse_hs smallint,
 supplement_entraitement_dialyseperit_auto_hs smallint,
 supplement_entraitement_dialyseperit_ambu_hs smallint,
 supplement_entraitement_hemodialyse_hs smallint,
 sceances_avant_sros smallint,
 nbr_actes_ghm_24Z05Z_ou_28Z11Z smallint,
 nbr_actes_ghm_24Z06Z_ou_28Z12Z smallint,
 nbr_actes_ghm_24Z07Z_ou_28Z13Z smallint,
 supplement_caisson_hyperbare smallint,
 type_prelevement_organe smallint,
 supplement_sra smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_ssc smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 supplement_rep smallint,
 lit_dedie_palliatif smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_rum_" . $annee . "  (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint, 
 valorisation_partielle smallint,
 position_dp char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 delai smallint,
 code_ccam char(8),
 phase char(9),
 activite smallint,
 ext_doc char(9),
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                       = mysubstr( $rsa_line, 12,  10 );
        $version_rss               = mysubstr( $rsa_line, 22,  3 );
        $sequence_tarif            = mysubstr( $rsa_line, 25,  3 );
        $version_lu                = mysubstr( $rsa_line, 28,  2 );
        $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
        $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
        $version_mis               = mysubstr( $rsa_line, 39,  2 );
        $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
        $retour_mis                = mysubstr( $rsa_line, 47,  3 );
        $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
        $age_annee                 = mysubstr( $rsa_line, 52,  3 );
        $age_jour                  = mysubstr( $rsa_line, 55,  3 );
        $sexe                      = mysubstr( $rsa_line, 58,  1 );
        $entree                    = mysubstr( $rsa_line, 59,  1 );
        $provenance                = mysubstr( $rsa_line, 60,  1 );
        $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
        $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
        $sortie                    = mysubstr( $rsa_line, 67,  1 );
        $destination               = mysubstr( $rsa_line, 68,  1 );
        $type                      = mysubstr( $rsa_line, 69,  1 );
        $duree                     = mysubstr( $rsa_line, 70,  4 );
        $cp_residence              = mysubstr( $rsa_line, 74,  5 );
        $poids_nne_entree          = mysubstr( $rsa_line, 79,  4 );
        $nbr_sceances              = mysubstr( $rsa_line, 83,  2 );
        $igs2                      = mysubstr( $rsa_line, 85,  3 );
        $ghs                       = mysubstr( $rsa_line, 88,  4 );
        $depassement_bornehaute    = mysubstr( $rsa_line, 92,  4 );
        $inferieur_bornebasse      = mysubstr( $rsa_line, 96,  1 );
        $ghs_forfait_dialyse       = mysubstr( $rsa_line, 97,  4 );
        $supplement_hemodialyse_hs = mysubstr( $rsa_line, 101, 3 );
        $supplement_entraitement_dialyseperit_auto_hs =
          mysubstr( $rsa_line, 104, 3 );
        $supplement_entraitement_dialyseperit_ambu_hs =
          mysubstr( $rsa_line, 107, 3 );
        $supplement_entraitement_hemodialyse_hs = mysubstr( $rsa_line, 110, 3 );
        $sceances_avant_sros                    = mysubstr( $rsa_line, 113, 2 );
        $nbr_actes_ghm_24Z05Z_ou_28Z11Z         = mysubstr( $rsa_line, 115, 3 );
        $nbr_actes_ghm_24Z06Z_ou_28Z12Z         = mysubstr( $rsa_line, 118, 3 );
        $nbr_actes_ghm_24Z07Z_ou_28Z13Z         = mysubstr( $rsa_line, 121, 3 );
        $supplement_caisson_hyperbare           = mysubstr( $rsa_line, 124, 3 );
        $type_prelevement_organe                = mysubstr( $rsa_line, 127, 1 );
        $supplement_sra                         = mysubstr( $rsa_line, 128, 3 );
        $supplement_rea                         = mysubstr( $rsa_line, 131, 3 );
        $supplement_si_de_rea                   = mysubstr( $rsa_line, 134, 3 );
        $supplement_stf                         = mysubstr( $rsa_line, 137, 3 );
        $supplement_ssc                         = mysubstr( $rsa_line, 140, 3 );
        $supplement_src                         = mysubstr( $rsa_line, 143, 3 );
        $supplement_nn1                         = mysubstr( $rsa_line, 146, 3 );
        $supplement_nn2                         = mysubstr( $rsa_line, 149, 3 );
        $supplement_nn3                         = mysubstr( $rsa_line, 152, 3 );
        $supplement_rep                         = mysubstr( $rsa_line, 155, 3 );
        $lit_dedie_palliatif                    = mysubstr( $rsa_line, 158, 1 );
        $dp                                     = mysubstr( $rsa_line, 159, 6 );
        $dr                                     = mysubstr( $rsa_line, 165, 6 );
        $nb_diags                               = mysubstr( $rsa_line, 171, 2 );
        $nb_actes                               = mysubstr( $rsa_line, 173, 4 );

        # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
        $offset    = 177;
        $rum_nbr   = $nb_rum;
        $das_nbr   = $nb_diags;
        $actes_nbr = $nb_actes;

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $rum_type_rum[$rum_cur] = mysubstr( $rsa_line, $offset, 2 );
                $rum_duree_uf[$rum_cur] = mysubstr( $rsa_line, $offset + 2, 3 );
                $rum_valorisation_rea[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 1 );
                $rum_valorisation_partielle[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1, 1 );
                $rum_position_dp[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1, 2 );
                $offset = $offset + 2 + 3 + 1 + 1 + 2;
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr
        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_delai[$actes_cur] = mysubstr( $rsa_line, $offset, 3 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

    } elsif( $version_rsa == 213 ) {
        if ( $schema_sql != 1 )
        {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;
drop table " . $prefixesql . "_rum_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . " (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 version_genrsa char(9),
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 ghs_forfait_dialyse char(9),
 supplement_hemodialyse_hs smallint,
 supplement_entraitement_dialyseperit_auto_hs smallint,
 supplement_entraitement_dialyseperit_ambu_hs smallint,
 supplement_entraitement_hemodialyse_hs smallint,
 sceances_avant_sros smallint,
 nbr_actes_ghm_24Z05Z_ou_28Z11Z smallint,
 nbr_actes_ghm_24Z06Z_ou_28Z12Z smallint,
 nbr_actes_ghm_24Z07Z_ou_28Z13Z smallint,
 supplement_caisson_hyperbare smallint,
 type_prelevement_organe smallint,
 supplement_sra smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_ssc smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 lit_dedie_palliatif smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_rum_" . $annee . "  (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint, 
 valorisation_partielle smallint,
 position_dp char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 delai smallint,
 code_ccam char(8),
 phase char(9),
 activite smallint,
 ext_doc char(9),
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                         = mysubstr( $rsa_line, 12,  10 );
          $version_rss               = mysubstr( $rsa_line, 22,  3 );
          $version_genrsa            = mysubstr( $rsa_line, 25,  3 );
          $version_lu                = mysubstr( $rsa_line, 28,  2 );
          $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
          $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
          $version_mis               = mysubstr( $rsa_line, 39,  2 );
          $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
          $retour_mis                = mysubstr( $rsa_line, 47,  3 );
          $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
          $age_annee                 = mysubstr( $rsa_line, 52,  3 );
          $age_jour                  = mysubstr( $rsa_line, 55,  3 );
          $sexe                      = mysubstr( $rsa_line, 58,  1 );
          $entree                    = mysubstr( $rsa_line, 59,  1 );
          $provenance                = mysubstr( $rsa_line, 60,  1 );
          $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
          $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
          $sortie                    = mysubstr( $rsa_line, 67,  1 );
          $destination               = mysubstr( $rsa_line, 68,  1 );
          $type                      = mysubstr( $rsa_line, 69,  1 );
          $duree                     = mysubstr( $rsa_line, 70,  4 );
          $cp_residence              = mysubstr( $rsa_line, 74,  5 );
          $poids_nne_entree          = mysubstr( $rsa_line, 79,  4 );
          $nbr_sceances              = mysubstr( $rsa_line, 83,  2 );
          $igs2                      = mysubstr( $rsa_line, 85,  3 );
          $ghs                       = mysubstr( $rsa_line, 88,  4 );
          $depassement_bornehaute    = mysubstr( $rsa_line, 92,  4 );
          $inferieur_bornebasse      = mysubstr( $rsa_line, 96,  1 );
          $ghs_forfait_dialyse       = mysubstr( $rsa_line, 97,  4 );
          $supplement_hemodialyse_hs = mysubstr( $rsa_line, 101, 3 );
          $supplement_entraitement_dialyseperit_auto_hs =
          mysubstr( $rsa_line, 104, 3 );
          $supplement_entraitement_dialyseperit_ambu_hs =
          mysubstr( $rsa_line, 107, 3 );
          $supplement_entraitement_hemodialyse_hs =
          mysubstr( $rsa_line, 110, 3 );
          $sceances_avant_sros            = mysubstr( $rsa_line, 113, 2 );
          $nbr_actes_ghm_24Z05Z_ou_28Z11Z = mysubstr( $rsa_line, 115, 3 );
          $nbr_actes_ghm_24Z06Z_ou_28Z12Z = mysubstr( $rsa_line, 118, 3 );
          $nbr_actes_ghm_24Z07Z_ou_28Z13Z = mysubstr( $rsa_line, 121, 3 );
          $supplement_caisson_hyperbare   = mysubstr( $rsa_line, 124, 3 );
          $type_prelevement_organe        = mysubstr( $rsa_line, 127, 1 );
          $supplement_sra                 = mysubstr( $rsa_line, 128, 3 );
          $supplement_rea                 = mysubstr( $rsa_line, 131, 3 );
          $supplement_si_de_rea           = mysubstr( $rsa_line, 134, 3 );
          $supplement_stf                 = mysubstr( $rsa_line, 137, 3 );
          $supplement_ssc                 = mysubstr( $rsa_line, 140, 3 );
          $supplement_src                 = mysubstr( $rsa_line, 143, 3 );
          $supplement_nn1                 = mysubstr( $rsa_line, 146, 3 );
          $supplement_nn2                 = mysubstr( $rsa_line, 149, 3 );
          $supplement_nn3                 = mysubstr( $rsa_line, 152, 3 );
          $lit_dedie_palliatif            = mysubstr( $rsa_line, 155, 1 );
          $dp                             = mysubstr( $rsa_line, 156, 6 );
          $dr                             = mysubstr( $rsa_line, 162, 6 );
          $nb_diags                       = mysubstr( $rsa_line, 168, 2 );
          $nb_actes                       = mysubstr( $rsa_line, 170, 4 );

          # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
          $offset    = 174;
          $rum_nbr   = $nb_rum;
          $das_nbr   = $nb_diags;
          $actes_nbr = $nb_actes;

          if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $rum_type_rum[$rum_cur] = mysubstr( $rsa_line, $offset, 2 );
                $rum_duree_uf[$rum_cur] = mysubstr( $rsa_line, $offset + 2, 3 );
                $rum_valorisation_rea[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 1 );
                $rum_valorisation_partielle[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1, 1 );
                $rum_position_dp[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1, 2 );
                $offset = $offset + 2 + 3 + 1 + 1 + 2;
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr
        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_delai[$actes_cur] = mysubstr( $rsa_line, $offset, 3 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

      } elsif( $version_rsa == 211 ) {
        if ( $schema_sql != 1 )
        {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;
drop table " . $prefixesql . "_rum_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . " (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 version_genrsa char(9),
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 nbr_actes_dialyse char(9),
 nbr_actes_ghm_24Z05Z smallint,
 nbr_actes_ghm_24Z06Z smallint,
 nbr_actes_ghm_24Z07Z smallint,
 type_prelevement_organe smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 lit_dedie_palliatif smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_rum_" . $annee . "  (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint, 
 apres_date_effet smallint,
 type_rum_force smallint,
 position_dp char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 delai smallint,
 code_ccam char(8),
 phase char(9),
 activite smallint,
 ext_doc char(9),
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                         = mysubstr( $rsa_line, 12,  10 );
          $version_rss               = mysubstr( $rsa_line, 22,  3 );
          $version_genrsa            = mysubstr( $rsa_line, 25,  3 );
          $version_lu                = mysubstr( $rsa_line, 28,  2 );
          $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
          $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
          $version_mis               = mysubstr( $rsa_line, 39,  2 );
          $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
          $retour_mis                = mysubstr( $rsa_line, 47,  3 );
          $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
          $age_annee                 = mysubstr( $rsa_line, 52,  3 );
          $age_jour                  = mysubstr( $rsa_line, 55,  3 );
          $sexe                      = mysubstr( $rsa_line, 58,  1 );
          $entree                    = mysubstr( $rsa_line, 59,  1 );
          $provenance                = mysubstr( $rsa_line, 60,  1 );
          $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
          $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
          $sortie                    = mysubstr( $rsa_line, 67,  1 );
          $destination               = mysubstr( $rsa_line, 68,  1 );
          $type                      = mysubstr( $rsa_line, 69,  1 );
          $duree                     = mysubstr( $rsa_line, 70,  4 );
          $cp_residence              = mysubstr( $rsa_line, 74,  5 );
          $poids_nne_entree          = mysubstr( $rsa_line, 79,  4 );
          $nbr_sceances              = mysubstr( $rsa_line, 83,  2 );
          $igs2                      = mysubstr( $rsa_line, 85,  3 );
          $ghs                       = mysubstr( $rsa_line, 88,  4 );
          $depassement_bornehaute    = mysubstr( $rsa_line, 92,  4 );
          $inferieur_bornebasse      = mysubstr( $rsa_line, 96,  1 );
          $nbr_actes_dialyse         = mysubstr( $rsa_line, 97,  4 );
          $nbr_actes_ghm_24Z05Z      = mysubstr( $rsa_line, 100, 3 );
          $nbr_actes_ghm_24Z06Z	     = mysubstr( $rsa_line, 103, 3 );
          $nbr_actes_ghm_24Z07Z      = mysubstr( $rsa_line, 106, 3 );
          $type_prelevement_organe        = mysubstr( $rsa_line, 109, 1 );
          $supplement_rea                 = mysubstr( $rsa_line, 110, 3 );
          $supplement_si_de_rea           = mysubstr( $rsa_line, 113, 3 );
          $supplement_stf                 = mysubstr( $rsa_line, 116, 3 );
          $supplement_src                 = mysubstr( $rsa_line, 119, 3 );
          $supplement_nn1                 = mysubstr( $rsa_line, 122, 3 );
          $supplement_nn2                 = mysubstr( $rsa_line, 125, 3 );
          $supplement_nn3                 = mysubstr( $rsa_line, 128, 3 );
          $lit_dedie_palliatif            = mysubstr( $rsa_line, 131, 1 );
          $dp                             = mysubstr( $rsa_line, 132, 6 );
          $dr                             = mysubstr( $rsa_line, 138, 6 );
          $nb_diags                       = mysubstr( $rsa_line, 144, 2 );
          $nb_actes                       = mysubstr( $rsa_line, 146, 4 );

          # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
          $offset    = 150;
          $rum_nbr   = $nb_rum;
          $das_nbr   = $nb_diags;
          $actes_nbr = $nb_actes;

          if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $rum_type_rum[$rum_cur] = mysubstr( $rsa_line, $offset, 2 );
                $rum_duree_uf[$rum_cur] = mysubstr( $rsa_line, $offset + 2, 3 );
                $rum_valorisation_rea[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3, 1 );
                $rum_apres_date_effet[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1, 1 );
                $rum_type_rum_force[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1, 1 );
                $rum_position_dp[$rum_cur] =
                  mysubstr( $rsa_line, $offset + 2 + 3 + 1 + 1 + 1, 2 );
                $offset = $offset + 2 + 3 + 1 + 1 + 1 + 2;
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr
        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_delai[$actes_cur] = mysubstr( $rsa_line, $offset, 3 );
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7, 1 );
                $acte_activite[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1, 1 );
                $acte_ext_doc[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1, 1 );
                $acte_modificateur[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1, 4 );
                $acte_remb_exceptionnel[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4, 1 );
                $acte_assoc_nonprevue[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1,
                    2 );

                $offset = $offset + 3 + 7 + 1 + 1 + 1 + 4 + 1 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

     } elsif( $version_rsa == 210 ) {
        if ( $schema_sql != 1 )
        {
            print "drop table " . $prefixesql . "_" . $annee . " cascade;
drop table " . $prefixesql . "_diags_" . $annee . " cascade;
drop table " . $prefixesql . "_actes_" . $annee . " cascade;

create table " . $prefixesql . "_" . $annee . " (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 version_genrsa char(9),
 version_lu char(9),
 ghm_lu char(9),
 retour_lu char(9),
 version_mis char(9),
 ghm_mis char(9),
 retour_mis char(9),
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe char(9),
 entree char(9),
 provenance char(9),
 annee_sortie smallint,
 mois_sortie smallint,
 sortie char(9),
 destination char(9),
 type char(9),
 duree smallint,
 cp_residence char(9),
 poids_nne_entree smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs char(9),
 duree_rea smallint,
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 nbr_actes_dialyse char(9),
 nbr_actes_ghm_24Z05Z smallint,
 nbr_actes_ghm_24Z06Z smallint,
 nbr_actes_ghm_24Z07Z smallint,
 prelevement_organe smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table " . $prefixesql . "_diags_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table " . $prefixesql . "_actes_" . $annee . " (
 code_sq_fk INT,
 rsa_f bigint,
 code_ccam char(9),
 phase char(9),
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES " . $prefixesql . "_" . $annee . " (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
select setval('" . $prefixesql . "_" . $annee . "_code_sq_pk_seq', 1);
";
            $schema_sql = 1;
        }
        $rsa                         = mysubstr( $rsa_line, 12,  10 );
          $version_rss               = mysubstr( $rsa_line, 22,  3 );
          $version_genrsa            = mysubstr( $rsa_line, 25,  3 );
          $version_lu                = mysubstr( $rsa_line, 28,  2 );
          $ghm_lu                    = mysubstr( $rsa_line, 30,  6 );
          $retour_lu                 = mysubstr( $rsa_line, 36,  3 );
          $version_mis               = mysubstr( $rsa_line, 39,  2 );
          $ghm_mis                   = mysubstr( $rsa_line, 41,  6 );
          $retour_mis                = mysubstr( $rsa_line, 47,  3 );
          $nb_rum                    = mysubstr( $rsa_line, 50,  2 );
          $age_annee                 = mysubstr( $rsa_line, 52,  3 );
          $age_jour                  = mysubstr( $rsa_line, 55,  3 );
          $sexe                      = mysubstr( $rsa_line, 58,  1 );
          $entree                    = mysubstr( $rsa_line, 59,  1 );
          $provenance                = mysubstr( $rsa_line, 60,  1 );
          $mois_sortie               = mysubstr( $rsa_line, 61,  2 );
          $annee_sortie              = mysubstr( $rsa_line, 63,  4 );
          $sortie                    = mysubstr( $rsa_line, 67,  1 );
          $destination               = mysubstr( $rsa_line, 68,  1 );
          $type                      = mysubstr( $rsa_line, 69,  1 );
          $duree                     = mysubstr( $rsa_line, 70,  3 );
          $cp_residence              = mysubstr( $rsa_line, 73,  5 );
          $poids_nne_entree          = mysubstr( $rsa_line, 78,  4 );
          $nbr_sceances              = mysubstr( $rsa_line, 82,  2 );
          $igs2                      = mysubstr( $rsa_line, 84,  3 );
          $ghs                       = mysubstr( $rsa_line, 87,  4 );
	  $duree_rea		     = mysubstr( $rsa_line, 91,  3 );
          $depassement_bornehaute    = mysubstr( $rsa_line, 94,  3 );
          $inferieur_bornebasse      = mysubstr( $rsa_line, 97,  1 );
          $nbr_actes_dialyse         = mysubstr( $rsa_line, 98,  2 );
          $nbr_actes_ghm_24Z05Z      = mysubstr( $rsa_line, 100, 2 );
          $nbr_actes_ghm_24Z06Z	     = mysubstr( $rsa_line, 102, 2 );
          $nbr_actes_ghm_24Z07Z      = mysubstr( $rsa_line, 104, 2 );
          $prelevement_organe        = mysubstr( $rsa_line, 106, 1 );
          $dp                        = mysubstr( $rsa_line, 107, 6 );
          $dr                        = mysubstr( $rsa_line, 113, 6 );
          $nb_diags                  = mysubstr( $rsa_line, 119, 2 );
          $nb_actes                  = mysubstr( $rsa_line, 121, 2 );

          # Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
          $offset    = 123;
          $das_nbr   = $nb_diags;
          $actes_nbr = $nb_actes;

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $das[$das_cur] = mysubstr( $rsa_line, $offset, 6 );
                $offset = $offset + 6;
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {
                $acte_code_ccam[$actes_cur] =
                  mysubstr( $rsa_line, $offset, 7 );
                $acte_phase[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 7, 1 );
                $acte_iteration[$actes_cur] =
                  mysubstr( $rsa_line, $offset + 7 + 1, 2 );

                $offset = $offset + 7 + 1 + 2;
                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # on est normalement à la fin de la ligne

    }  else {
        print "Version de RSA " . $version_rsa . " non gérée !";
        exit(-1);
    }

# maintenant que la ligne est lue, faut l'insérrer dans la base
#  	$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

    if ( $version_rsa == 216 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, sequence_tarif, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, age_gestationnel, nbr_sceances, igs2, ghs, depassement_bornehaute, type_inferieur_bornebasse, inferieur_bornebasse, ghs_forfait_dialyse, uhcd, confirmation_sejour, supplement_hemodialyse_hs, supplement_entraitement_dialyseperit_auto_hs, supplement_entraitement_dialyseperit_ambu_hs, supplement_entraitement_hemodialyse_hs, nbr_actes_ghs_9610, nbr_actes_ghs_9611, nbr_actes_ghs_9612, nbr_actes_ghs_9619, nbr_actes_ghs_9620, nbr_actes_ghs_6523, nbr_actes_ghs_9621, nbr_actes_ghs_9615, filler_ex_sceances_avant_sros, filler_ex_supplement_sra, filler_ex_supplement_ssc, filler, supplement_caisson_hyperbare, type_prelevement_organe, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, supplement_rep, lit_dedie_palliatif, type_radiotherapie, type_dosimetrie, quel_rum_donne_dp, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, $sequence_tarif, '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $rum_nbr, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $age_gestationnel, $nbr_sceances, $igs2, '$ghs', $depassement_bornehaute, $type_inferieur_bornebasse, $inferieur_bornebasse, '$ghs_forfait_dialyse', $uhcd, $confirmation_sejour, $supplement_hemodialyse_hs, $supplement_entraitement_dialyseperit_auto_hs, $supplement_entraitement_dialyseperit_ambu_hs, $supplement_entraitement_hemodialyse_hs, $nbr_actes_ghs_9610, $nbr_actes_ghs_9611, $nbr_actes_ghs_9612, $nbr_actes_ghs_9619, $nbr_actes_ghs_9620, $nbr_actes_ghs_6523, $nbr_actes_ghs_9621, $nbr_actes_ghs_9615, '$filler_ex_sceances_avant_sros', '$filler_ex_supplement_sra', '$filler_ex_supplement_ssc', '$filler', $supplement_caisson_hyperbare, $type_prelevement_organe, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $supplement_rep, $lit_dedie_palliatif, $type_radiotherapie, $type_dosimetrie, $quel_rum_donne_dp, '$dp', '$dr', $nb_diags, $nb_actes);";
        print $sql . "\n";

        $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
        print $sql . "\n";

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_rum_" . $annee . " (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, indicateur_src, valorisation_partielle, dp_rum, dr_rum) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_indicateur_src[$rum_cur], $rum_valorisation_partielle[$rum_cur], '$rum_dp[$rum_cur]', '$rum_dr[$rum_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_rum;";
                print $sql . "\n";
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, quel_rum_donne_acte, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $acte_rum_origine[$actes_cur], $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', '$acte_phase[$actes_cur]', $acte_activite[$actes_cur], '$acte_ext_doc[$actes_cur]', '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', '$acte_assoc_nonprevue[$actes_cur]', $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

# to count lines
        $line_cur++;
    } elsif ( $version_rsa == 215 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, sequence_tarif, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, age_gestationnel, nbr_sceances, igs2, ghs, depassement_bornehaute, inferieur_bornebasse, ghs_forfait_dialyse, supplement_hemodialyse_hs, supplement_entraitement_dialyseperit_auto_hs, supplement_entraitement_dialyseperit_ambu_hs, supplement_entraitement_hemodialyse_hs, sceances_avant_sros, nbr_actes_ghs_9510, nbr_actes_ghs_9511, nbr_actes_ghs_9512, nbr_actes_ghs_9515, nbr_actes_ghs_9524, supplement_caisson_hyperbare, type_prelevement_organe, supplement_sra, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_ssc, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, supplement_rep, lit_dedie_palliatif, quel_rum_donne_dp, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, $sequence_tarif, '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $rum_nbr, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $age_gestationnel, $nbr_sceances, $igs2, '$ghs', $depassement_bornehaute, $inferieur_bornebasse, '$ghs_forfait_dialyse', $supplement_hemodialyse_hs, $supplement_entraitement_dialyseperit_auto_hs, $supplement_entraitement_dialyseperit_ambu_hs, $supplement_entraitement_hemodialyse_hs, $sceances_avant_sros, $nbr_actes_ghs_9510, $nbr_actes_ghs_9511, $nbr_actes_ghs_9512, $nbr_actes_ghs_9514, $nbr_actes_ghs_9524, $supplement_caisson_hyperbare, $type_prelevement_organe, $supplement_sra, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_ssc, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $supplement_rep, $lit_dedie_palliatif, $quel_rum_donne_dp, '$dp', '$dr', $nb_diags, $nb_actes);";
        print $sql . "\n";

        $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
        print $sql . "\n";

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_rum_" . $annee . " (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, valorisation_partielle, dp_rum, dr_rum) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_valorisation_partielle[$rum_cur], '$rum_dp[$rum_cur]', '$rum_dr[$rum_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_rum;";
                print $sql . "\n";
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, quel_rum_donne_acte, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $acte_rum_origine[$actes_cur], $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', '$acte_phase[$actes_cur]', $acte_activite[$actes_cur], '$acte_ext_doc[$actes_cur]', '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', '$acte_assoc_nonprevue[$actes_cur]', $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

# to count lines
        $line_cur++;
    } elsif ( $version_rsa == 214 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, sequence_tarif, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, nbr_sceances, igs2, ghs, depassement_bornehaute, inferieur_bornebasse, ghs_forfait_dialyse, supplement_hemodialyse_hs, supplement_entraitement_dialyseperit_auto_hs, supplement_entraitement_dialyseperit_ambu_hs, supplement_entraitement_hemodialyse_hs, sceances_avant_sros, nbr_actes_ghm_24Z05Z_ou_28Z11Z, nbr_actes_ghm_24Z06Z_ou_28Z12Z, nbr_actes_ghm_24Z07Z_ou_28Z13Z, supplement_caisson_hyperbare, type_prelevement_organe, supplement_sra, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_ssc, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, supplement_rep, lit_dedie_palliatif, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, $sequence_tarif, '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $rum_nbr, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $nbr_sceances, $igs2, '$ghs', $depassement_bornehaute, $inferieur_bornebasse, '$ghs_forfait_dialyse', $supplement_hemodialyse_hs, $supplement_entraitement_dialyseperit_auto_hs, $supplement_entraitement_dialyseperit_ambu_hs, $supplement_entraitement_hemodialyse_hs, $sceances_avant_sros, $nbr_actes_ghm_24Z05Z_ou_28Z11Z, $nbr_actes_ghm_24Z06Z_ou_28Z12Z, $nbr_actes_ghm_24Z07Z_ou_28Z13Z, $supplement_caisson_hyperbare, $type_prelevement_organe, $supplement_sra, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_ssc, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $supplement_rep, $lit_dedie_palliatif, '$dp', '$dr', $nb_diags, $nb_actes);";
        print $sql . "\n";

        $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
        print $sql . "\n";

        if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_rum_" . $annee . " (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, valorisation_partielle, position_dp) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_valorisation_partielle[$rum_cur], '$rum_position_dp[$rum_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_rum;";
                print $sql . "\n";
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', '$acte_phase[$actes_cur]', $acte_activite[$actes_cur], '$acte_ext_doc[$actes_cur]', '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', '$acte_assoc_nonprevue[$actes_cur]', $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

# to count lines
        $line_cur++;
    } elsif( $version_rsa == 213 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, version_genrsa, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, nbr_sceances, igs2, ghs, depassement_bornehaute, inferieur_bornebasse, ghs_forfait_dialyse, supplement_hemodialyse_hs, supplement_entraitement_dialyseperit_auto_hs, supplement_entraitement_dialyseperit_ambu_hs, supplement_entraitement_hemodialyse_hs, sceances_avant_sros, nbr_actes_ghm_24Z05Z_ou_28Z11Z, nbr_actes_ghm_24Z06Z_ou_28Z12Z, nbr_actes_ghm_24Z07Z_ou_28Z13Z, supplement_caisson_hyperbare, type_prelevement_organe, supplement_sra, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_ssc, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, lit_dedie_palliatif, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, '$version_genrsa', '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $rum_nbr, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $nbr_sceances, $igs2, '$ghs', $depassement_bornehaute, $inferieur_bornebasse, '$ghs_forfait_dialyse', $supplement_hemodialyse_hs, $supplement_entraitement_dialyseperit_auto_hs, $supplement_entraitement_dialyseperit_ambu_hs, $supplement_entraitement_hemodialyse_hs, $sceances_avant_sros, $nbr_actes_ghm_24Z05Z_ou_28Z11Z, $nbr_actes_ghm_24Z06Z_ou_28Z12Z, $nbr_actes_ghm_24Z07Z_ou_28Z13Z, $supplement_caisson_hyperbare, $type_prelevement_organe, $supplement_sra, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_ssc, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $lit_dedie_palliatif, '$dp', '$dr', $nb_diags, $nb_actes);";
          print $sql . "\n";

          $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
          print $sql . "\n";

          if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_rum_" . $annee . " (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, valorisation_partielle, position_dp) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_valorisation_partielle[$rum_cur], '$rum_position_dp[$rum_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql  . "_rum;";
                print $sql . "\n";
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_activite[$actes_cur], '$acte_ext_doc[$actes_cur]', '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', '$acte_assoc_nonprevue[$actes_cur]', $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # to count lines
        $line_cur++;
    } elsif( $version_rsa == 210 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, version_genrsa, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, nbr_sceances, igs2, ghs, duree_rea, depassement_bornehaute, inferieur_bornebasse, nbr_actes_dialyse, nbr_actes_ghm_24Z05Z, nbr_actes_ghm_24Z06Z, nbr_actes_ghm_24Z07Z, prelevement_organe, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, '$version_genrsa', '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $nb_rum, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $nbr_sceances, $igs2, '$ghs', $duree_rea, $depassement_bornehaute, $inferieur_bornebasse, $nbr_actes_dialyse, $nbr_actes_ghm_24Z05Z, $nbr_actes_ghm_24Z06Z, $nbr_actes_ghm_24Z07Z, $prelevement_organe, '$dp', '$dr', $nb_diags, $nb_actes);";
          print $sql . "\n";

          $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
          print $sql . "\n";

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, code_ccam, phase, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # to count lines
        $line_cur++;
    } elsif( $version_rsa == 211 ) {

# prepare and execute query
# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
        $sql =
"INSERT into " . $prefixesql . "_" . $annee . " (annee, version_rsa, rsa, version_rss, version_genrsa, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, nbr_sceances, igs2, ghs, depassement_bornehaute, inferieur_bornebasse, nbr_actes_dialyse, nbr_actes_ghm_24Z05Z, nbr_actes_ghm_24Z06Z, nbr_actes_ghm_24Z07Z, type_prelevement_organe, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, lit_dedie_palliatif, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, '$version_genrsa', '$version_lu', '$ghm_lu', '$retour_lu', '$version_mis', '$ghm_mis', '$retour_mis', $rum_nbr, $age_annee, $age_jour, '$sexe', '$entree', '$provenance', $annee_sortie, $mois_sortie, '$sortie', '$destination', '$type', $duree, '$cp_residence', $poids_nne_entree, $nbr_sceances, $igs2, '$ghs', $depassement_bornehaute, $inferieur_bornebasse, $nbr_actes_dialyse, $nbr_actes_ghm_24Z05Z, $nbr_actes_ghm_24Z06Z, $nbr_actes_ghm_24Z07Z, $type_prelevement_organe, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $lit_dedie_palliatif, '$dp', '$dr', $nb_diags, $nb_actes);";
          print $sql . "\n";

          $sql =
            "select currval('" . $prefixesql . "_" . $annee
          . "_code_sq_pk_seq') as " . $prefixesql . ";";
          print $sql . "\n";

          if ( $rum_nbr > 0 ) {
            $rum_cur = 0;
            while ( $rum_cur < $rum_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_rum_" . $annee . " (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, apres_date_effet, type_rum_force, position_dp) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_apres_date_effet[$rum_cur], $rum_type_rum_force[$rum_cur], '$rum_position_dp[$rum_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql  . "_rum;";
                print $sql . "\n";
                $rum_cur++;
            }    # while rum_cur
        }    # rum_nbr

        if ( $das_nbr > 0 ) {
            $das_cur = 0;
            while ( $das_cur < $das_nbr ) {
                $sql =
"INSERT INTO " . $prefixesql . "_diags_" . $annee . " (code_sq_fk, rsa_f, das) VALUES (currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_diags;";
                print $sql . "\n";
                $das_cur++;
            }    # while das_cur
        }    # das_nbr

        # Maintenant les actes
        if ( $actes_nbr > 0 ) {
            $actes_cur = 0;
            while ( $actes_cur < $actes_nbr ) {

                # On rearrange sa date aussi
                $sql =
"INSERT INTO " . $prefixesql . "_actes_" . $annee . " ( code_sq_fk, rsa_f, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('" . $prefixesql . "_"
                  . $annee
                  . "_code_sq_pk_seq'), $rsa, $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_activite[$actes_cur], '$acte_ext_doc[$actes_cur]', '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', '$acte_assoc_nonprevue[$actes_cur]', $acte_iteration[$actes_cur]);";
                print $sql . "\n";
                $sql =
                    "select currval('" . $prefixesql . "_" . $annee
                  . "_code_sq_pk_seq') as " . $prefixesql . "_acte;";
                print $sql . "\n";

                $actes_cur++;
            }    # while actes_cur
        }    # actes_nbr

        # to count lines
        $line_cur++;
      } # if format 21x

} # while line_rsa=IFD

#$sth->finish();

print $line_cur . " lignes lues\n";
close(IFD);
