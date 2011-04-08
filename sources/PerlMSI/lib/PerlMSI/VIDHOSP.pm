{
    package PerlMSI::VIDHOSP;
    use 5.008008;

    our @ISA = qw(Exporter);
    our @EXPORT = qw(readfrom noncpam distinct_iep distinct_ss);
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
