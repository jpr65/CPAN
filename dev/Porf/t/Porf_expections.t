# Perl 5
#
# Test for Report::Porf::* - Calls causing exceptions
# in own test module, Test::Exception is no standard module
#
# Perl Open Report Framework (Porf)
#
# Ralf Peine, Sun Dec 13 14:29:06 2020
#
#------------------------------------------------------------------------------

$VERSION = "2.010";

use strict;
use warnings;

$|=1;

use Time::HiRes;
use Data::Dumper;

use Report::Porf qw(:all);

use Report::Porf::Framework;
use Report::Porf::Util;
use Report::Porf::Table::Simple;
use Report::Porf::Table::Simple::HtmlReportConfigurator;
use Report::Porf::Table::Simple::TextReportConfigurator;
use Report::Porf::Table::Simple::CsvReportConfigurator;

#--------------------------------------------------------------------------------
#
#  Run
#
#--------------------------------------------------------------------------------

use Test::More tests => 4;
use Test::Exception;

T001_simple_porf();

T010_create_instances();
T100_align();
T110_interprete_value_options();
T020_verbose();
T300_text_export();
T310_html_export();
T320_csv_export();
T400_auto_report();
T800_use_framework();

#--------------------------------------------------------------------------------
#
#  create Test Data
#
#--------------------------------------------------------------------------------

# --- create persons as array, first entry is constant, following not -----------
sub create_persons_as_array {
    my $max_entries = shift;

    my $start_time = hires_current_time();
    my @rows;
    
    foreach my $l (1..$max_entries) {
        my $time = hires_diff_time($start_time, hires_current_time());
        $time = '8e-06' if $l == 1;
        my @data = (
            $l,
            "Vorname $l",
            "Name $l",
            ($l/$max_entries)*100,
            $time,
            );

        push (@rows, \@data);   
    }

    return \@rows;
}

# --- create persons as hash, first entry is constant, following not -----------
sub create_persons_as_hash {
    my $max_entries = shift;

    my $start_time = hires_current_time();
    my @rows;
    
    foreach my $l (1..$max_entries) {
        my $time = hires_diff_time($start_time, hires_current_time());
        $time = '8e-06' if $l == 1;
        my %data = (
            id      => $l,
            prename => "Vorname $l",
            surname => "Name $l",
            number  => ($l/$max_entries)*100,
            time    => $time,
            );

        push (@rows, \%data);   
    }

    return \@rows;
}

#--------------------------------------------------------------------------------
#
#  Helper subs
#
#--------------------------------------------------------------------------------

# --- get hiresolution time, uses Time::HiRes ---
sub hires_current_time {
    return [Time::HiRes::gettimeofday];
}

# --- get difference from now to $start_time in hiresolution time, uses Time::HiRes ---
sub hires_diff_time {
    my $start_time = shift;
    my $end_time   = shift; # current time, if omitted
    return Time::HiRes::tv_interval ($start_time, $end_time); 
}

#--------------------------------------------------------------------------------
#
#  Configure tables
#
#--------------------------------------------------------------------------------

sub create_simple_test_table_columns_for_array_data {
    my $t_o = shift; # $test_object
    
    # --- Configure table ------------------------------------------------------------
    #
    # Order of calls gives order of columns in table
    $t_o->configure_column(-header => 'Count',      -align => 'Center', -value_indexed => 0 );
    $t_o->configure_column(-header => 'TimeStamp', -w => 10, -a => 'R', -val_idx       => 4 );
    $t_o->configure_column(-h      => 'Age',       -w =>  7, -a => 'C', -vi            => 3 );
    $t_o->configure_column(-h      => 'Prename',   -w => 11, -a => 'l', -value => sub { return $_[0]->[1]; } );
    $t_o->configure_column(-h      => 'Surname',   -width =>  8,        -v     =>             '$_[0]->[2]'   );
    
    # --- Configure table end --------------------------------------------------------

    $t_o->configure_complete();
}

sub create_simple_test_table_columns_for_hash_data {
    my $t_o = shift; # $test_object
    
    # --- Configure table ------------------------------------------------------------
    #
    # Order of calls gives order of columns in table
    $t_o->configure_column(-h      => 'Age',       -w =>  7, -a => 'C', -value_named => 'Age' );
    $t_o->configure_column(-h      => 'Prename',   -w => 11, -a => 'l', -val_nam     => 'Prename');
    $t_o->configure_column(-h      => 'Surname',   -width =>  8,        -vn          => 'Surname');
    
    # --- Configure table end --------------------------------------------------------

    $t_o->configure_complete();
}

#------------------------------------------------------------------------------
#
#  Tests
#
#------------------------------------------------------------------------------

# --- Test Creation --------------------------------------------------------
sub T001_simple_porf
{
    # is (auto_report(create_persons_as_hash(10)),
    #    10, 'auto_report(\@data_hashed) prints to STDOUT and returns 10');
}

# --- Test Creation --------------------------------------------------------
sub T010_create_instances {

    my $test_object;
    
    # ok ($test_object = Report::Porf::Table::Simple->new(),
    #    'create instance');

    # is ($test_object->get_max_col_width(),   0, 'initial MaxColWidth');
}

# --- Test verbose --------------------------------------------------------
sub T020_verbose {

    # my $test_object = Report::Porf::Table::Simple->new();

    # $test_object->set_verbose(0);
    # is (verbose($test_object,  ), 0, 'verbose( ) 0 0');
}

# --- Test Align --------------------------------------------------------
sub T100_align {
    # --- bla => dies -----------------------------------------------------
    throws_ok {
        interprete_alignment(' bla     ');
    }
      qr/cannot interprete alignment/i,
              "configure align by unallowed value 'bla'";
}

# --- Test the interpreter for value options ----------------------------
sub T110_interprete_value_options {

    # is (interprete_value_options ({ -value => '$bla;'}), '$bla;', '-value => $bla;');
}

# --- Test text export --------------------------------------------------------
sub T300_text_export {

    my $text_report_configurator = Report::Porf::Table::Simple::TextReportConfigurator->new();
    my $test_object = Report::Porf::Table::Simple->new();
    # $test_object->set_verbose(3);
    # $test_object->set_verbose(2);
    
    # --- Test -------------------------------------------------------  
    # ok ($text_report_configurator->configure_report($test_object), 'configure text report');
}

# --- Test Html export --------------------------------------------------------
sub T310_html_export {

    my $html_report_configurator = Report::Porf::Table::Simple::HtmlReportConfigurator->new();
    my $test_object = Report::Porf::Table::Simple->new();
    # $test_object->set_verbose(3);
    # $test_object->set_verbose(2);
    # $html_report_configurator->set_verbose(3);
    
    # --- Test -------------------------------------------------------  
    # ok ($html_report_configurator->configure_report($test_object), 'configure text report');

}

# --- Test csv export --------------------------------------------------------
sub T320_csv_export {

    my $csv_report_configurator = Report::Porf::Table::Simple::CsvReportConfigurator->new();
    my $test_object = Report::Porf::Table::Simple->new();
    # $test_object->set_verbose(3);
    # $test_object->set_verbose(2);
    
    # --- Test -------------------------------------------------------  
    # ok ($csv_report_configurator->configure_report($test_object), 'configure csv report');
}

# --- Auto Report ----------------------------------------------

sub T400_auto_report {
    my $sfh = new FileHandle('>/dev/null');
    # my $sfh; # print out results for debug and development
    
    my $data_href_rows = [{Vorname    => 'Ralf',
                           Nachname   => 'Peine',
                           Geburtstag => '29.12.1965',
                           Wohnort    => 'Bocholt'
                          },
        ];
    
    my $data_arref_many_cols = [
        [qw(1 a b c d e f g)],
        [qw(2 a1 b c d e1 f1 g)],
        [qw(3 a2 b c d e2 f2 g)],
        ];

    # --- Test -------------------------------------------------------  
    throws_ok {
        Report::Porf::Framework::auto_report(
            $data_href_rows,
            -columns  => [qw(Geburtstag blabla blubber)],
	    -file => $sfh
            ); }
    qr/columns not found in data:.*'blabla'.*'blubber'/, 'Auto Report dies by unknown columns';
    
    # --- Test -------------------------------------------------------  
    throws_ok {
        Report::Porf::Framework::auto_report(
            $data_href_rows,
            -bla      => 1,
            -max_rows => 4,
            '?'       => 2,
            ); }
    qr/unknown arguments.*'-bla'.*'\?'/, 'Auto Report dies by unknown arguments';
    
    # --- Test -------------------------------------------------------  
    throws_ok {
        Report::Porf::Framework::auto_report(
            $data_href_rows,
            -bla      => 1,
            'a'); }
    qr/incomplete named arguments:/, 'Auto Report dies by incomplete named arguments';
    
}

# --- Test framework class -------------------------------------------
sub T800_use_framework {

    my $test_object;

    # --- Test Text -------------------------------------------------------     

    # --- Test: prepare ---
    $test_object = Report::Porf::Framework::get();
    my $person_rows = create_persons_as_array(10);

    # --- Test: call ---
    my $text_report = $test_object->create_report('text');

}

