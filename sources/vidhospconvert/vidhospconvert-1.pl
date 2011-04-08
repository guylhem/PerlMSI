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

# Convertisseur de format vidhosp 2008 en 2007

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    if ( length($out) == 0 ) { $out = "ERROR"; }
    return $out;
}

unless ( scalar @ARGV == 1 ) {
    die "Usage:\n\t$0 vidhosp.txt \n";
}

$vidhosp = $ARGV[0];

open( DFD, "<$vidhosp" ) or die( "Ne peut lire " . $vidhosp . " !\n" );

$vdhsp_nbr=0;
while ( $vdhsp_line = <DFD> ) {
$vdhsp_ss       = mysubstr( $vdhsp_line, 0, 13);
$debut_ss	= mysubstr( $vdhsp_line, 0, 1);
$fin_ss		= mysubstr( $vdhsp_line, 1, 12);
$nir_clef	= mysubstr( $vdhsp_line, 13, 2);
$vdhsp_ddn      = mysubstr( $vdhsp_line, 17, 8);
$vdhsp_sexe     = mysubstr( $vdhsp_line, 25, 1);
$vdhsp_iep      = mysubstr( $vdhsp_line, 26, 20);
$vdhsp_extm     = mysubstr( $vdhsp_line, 46, 1);
$vdhsp_pcfj     = mysubstr( $vdhsp_line, 47, 1);
$vdhsp_nata     = mysubstr( $vdhsp_line, 48, 2);
$vdhsp_sfam     = mysubstr( $vdhsp_line, 52, 1);
$vdhsp_f18e     = mysubstr( $vdhsp_line, 53, 1);
$vdhsp_nbrv     = mysubstr( $vdhsp_line, 54, 3);
$vdhsp_mftm     = mysubstr( $vdhsp_line, 57, 10);
$vdhsp_mffj     = mysubstr( $vdhsp_line, 67, 10);
$vdhsp_mtsr     = mysubstr( $vdhsp_line, 77, 10);
$vdhsp_mmps     = mysubstr( $vdhsp_line, 87, 4);

# Vérification de la validité du numéro de Sécurité Sociale
# Cast to int
$nir_clef=$nir_clef+0;
$nir= $vdhsp_ss+0;
$nir_clef_valid=97 - $nir % 97;

if ($nir_clef != $nir_clef_valid) {
#printf STDERR "Numero de securite sociale invalide : $nir $nir_clef / $nir_clef_valid\n";
}

$debut_ss=substr($vdhsp_ss, 0, 1);

# Si erreur sur le numéro de sécurité sociale évidente (ex: premier
# chiffre 0, 3, 4 ou 9), corriger son premier chiffre par le sexe et le
# remettre facturable !

# FIXME : ne trouve pas les ^0
if ($debut_ss != "X" && ($debut_ss == 0 || $debut_ss == "0" || $debut_ss == "O" || $debut_ss == "I" || $debut_ss=="3" || $debut_ss=="4" || $debut_ss=="9")) {
$vdhsp_sfam="1";
if ($vdhsp_nata == "XX") { $vdhsp_nata="10" };

print $vdhsp_sexe . $fin_ss . $vdhsp_ddn . $vdhsp_sexe . $vdhsp_iep . $vdhsp_extm . $vdhsp_pcfj .  $vdhsp_nata . $vdhsp_sfam . $vdhsp_f18e . $vdhsp_nbrv . $vdhsp_mftm .  $vdhsp_mffj . $vdhsp_mtsr . $vdhsp_mmps . "\r\n";
 } else {
print $vdhsp_ss . $vdhsp_ddn . $vdhsp_sexe . $vdhsp_iep . $vdhsp_extm . $vdhsp_pcfj .  $vdhsp_nata . $vdhsp_sfam . $vdhsp_f18e . $vdhsp_nbrv . $vdhsp_mftm .  $vdhsp_mffj . $vdhsp_mtsr . $vdhsp_mmps . "\r\n";
}

$vdhsp_nbr++;
}
close (DFD);

