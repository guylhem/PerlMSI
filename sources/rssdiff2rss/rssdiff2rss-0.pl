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


sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = undef; }
    return $out;
}

unless ( scalar @ARGV == 2 ) {
    die "Usage:\n\t$0 diff.txt fichier.rss\n";
}

$difftxt = $ARGV[0];
$rssfichier = $ARGV[1];

open( DFD, "<$difftxt" ) or die( "Ne peut lire " . $difftxt . " !\n" );

$diff_nbr=0;
while ( $diff_line = <DFD> ) {
$diff_rss[$diff_nbr]      = mysubstr( $diff_line, 0, 7);
$diff_ghm_in[$diff_nbr]   = mysubstr( $diff_line, 7, 6);
$diff_code_in[$diff_nbr]  = mysubstr( $diff_line, 13, 3);
$diff_ghm_out[$diff_nbr]  = mysubstr( $diff_line, 16, 6);
$diff_code_out[$diff_nbr] = mysubstr( $diff_line, 22, 3);

# cast to int
$diff_rss[$diff_nbr]=$diff_rss[$diff_nbr]+0;
$diff_nbr++;
}
close (DFD);

open (RSS, "<$rssfichier" ) or die( "Ne peut lire " . $rssfichier  . " !\n" );
while ( $rss_line = <RSS> ) {
    $debut              = mysubstr( $rss_line, 0, 2 );
    $ghm              = mysubstr( $rss_line, 2, 6 );
    $rss              = mysubstr( $rss_line, 27,  7 );


# cast to int
$rss=$rss+0;

$matched=0;
$diff_cur=0;
while ($matched == 0 & ($diff_cur < $diff_nbr)) {
if ($diff_rss[$diff_cur]-$rss == 0) {
$fin_ligne=substr( $rss_line, 8);
print $debut . $diff_ghm_out[$diff_cur] . $fin_ligne;
$matched=1;
} # fi
$diff_cur++
} # while

if ($matched ==0) {
print $rss_line;
}

} # while line

