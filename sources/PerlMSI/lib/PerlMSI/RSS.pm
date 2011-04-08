{
    package PerlMSI::RSS;
    use 5.008008;

    our @ISA = qw(Exporter FILEREAD);
    our @EXPORT = qw(readfrom distinct_iep distinct_rss nbr_distinct_iep nbr_distinct_iep);

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

	# Calc
	my %C_iep;
	my %C_rss;

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

# CALC 
if ($rss_value{'iep'}) {
    $C_iep{0+$rss_value{'iep'}}++;
}
if ($rss_value{'rss'}) {
    $C_rss{0+$rss_value{'rss'}}++;
}

# If you get a "Not an ARRAY reference" bug, check the format !
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
        $E_rss{CALC_DISTINCT_IEP} = [ keys %C_iep ];
	$E_rss{CALC_DISTINCT_RSS} = [ keys %C_rss ];
        $E_rss{CALC_NBR_DISTINCT_IEP} = scalar keys %C_iep;
	$E_rss{CALC_NBR_DISTINCT_RSS} = scalar keys %C_rss;

        my $E_result = \%E_rss;
        bless( $E_result, "RSS" );
        return ($E_result);
    }

    # sub readfrom
    
    sub nbr_distinct_iep {
        my $E_self = shift;
        return $$E_self{CALC_NBR_DISTINCT_IEP};
    }

    # sub nbr_distinct_iep

    sub nbr_distinct_rss {
        my $E_self = shift;
        return $$E_self{CALC_NBR_DISTINCT_RSS};
    }

    # sub nbr_distinct_rss

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

    # FIXME: a faire par uf, pole, total ou par autre critere (ex: ghm)
    # FIXME: pouvoir faire une intersection ou union entre criteres

    1;
}    # Package RSS
