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


use Data::Dumper;
use warnings;
use strict;


my %formats_vidhosp= (
    42+2  =>  {
        format  =>  'A13 A8 A1 A13',
        keys    =>  [qw( ss naissance sexe iep )],
    },

    85+2  =>  {
        format  =>  'A13 A8 A1 A20 A1 A1 A2 A1 A1 A3 A10 A10 A10 A4',
	keys    => [qw(ss naissance sexe iep exoneration_tm
		prise_en_charge_fj nature_assurance facturable_cpam
		facturation_18eur nbr_venues_facture tr_facturer_tm
		tr_facturer_fj tr_remboursable_cpam tr_parcours_soin)],
    },

    106+2 => {
	format => 'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A3 A10 A10 A10 A4 A10 A5',

	keys   => [qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )],
    },

    107+2 => {
	format => 'A13 A2 A2 A8 A1 A20 A1 A1 A2 A2 A1 A1 A1 A3 A10 A10 A10 A4 A10 A5',
	keys   => [qw( ss clef_ss code_grand_regime naissance sexe iep exoneration_tm prise_en_charge_fj nature_assurance type_complementaire facturable_cpam non_facturation_cpam facturation_18eur nbr_venues_facture tr_facturer_tm tr_facturer_fj tr_remboursable_cpam tr_parcours_soin tr_base_remboursement tx_remboursement )],
    }
);


my %vidhosp_line;
my %vidhosp_column;
while (my $line = <>) {
    chomp $line;
    my $format_vidhosp = $formats_vidhosp { length $line };
    unless ($format_vidhosp) {
        print "Unable to handle line of length ", length $line, "\n";
        next;
    }
    print "Reading $.\n";

    my @keys = @{ $format_vidhosp->{'keys'} };
    @vidhosp_line{ @keys } = unpack($format_vidhosp->{'format'}, $line);

    for my  $key (keys %vidhosp_line) {
     $vidhosp_column{$key}[$.]=$vidhosp_line{$key};

    } # for 
}

print Dumper(\%vidhosp_column);

#sub dumper {
#    Data::Dumper->new([$_[0]])->Useqq(1)->Terse(1)->Indent(1)->Deepcopy(1)->Dump
#}

