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
$debut_ss	= mysubstr( $vdhsp_line, 0, 1);
$fin_ss		= mysubstr( $vdhsp_line, 1, 12);
$vdhsp_ss       = mysubstr( $vdhsp_line, 0, 13);
$vdhsp_ddn      = mysubstr( $vdhsp_line, 13, 8);
$vdhsp_sexe     = mysubstr( $vdhsp_line, 21, 1);
$vdhsp_reste1   = mysubstr( $vdhsp_line, 22, 22);
$vdhsp_nata     = mysubstr( $vdhsp_line, 44, 2);
$vdhsp_reste2   = mysubstr( $vdhsp_line, 46, 39);

# Si erreur sur le numéro de sécurité sociale évidente (ex: premier
# chiffre 0, 3, 4 ou 9), corriger son premier chiffre par le sexe et le
# remettre facturable !

if ($debut_ss != "X" && ($debut_ss == 0 || $debut_ss == "0" || $debut_ss == "O" || $debut_ss == "I" || $debut_ss=="3" || $debut_ss=="4" || $debut_ss=="9")) {
$vdhsp_sfam="1";
if ($vdhsp_nata == "XX") { $vdhsp_nata="10" };
print $vdhsp_sexe . $fin_ss . $vdhsp_ddn . $vdhsp_sexe . $vdhsp_reste1 . $vdhsp_nata . $vdhsp_reste2 . "\r\n";
 } else {
print $vdhsp_ss . $vdhsp_ddn . $vdhsp_sexe . $vdhsp_reste1 . $vdhsp_nata . $vdhsp_reste2 . "\r\n";
}

$vdhsp_nbr++;
}
close (DFD);

