# Perl 
#
# Class Report::Porf::Table::Simple::AutoColumnConfigurator
#
# Perl Open Report Framework (Porf)
#
# Configure Report columns automatically
#
# Ralf Peine, Sun Dec 13 09:51:14 2020
#
# More documentation at the end of file
#------------------------------------------------------------------------------

$VERSION = "2.010";

use strict;
use warnings;

#--------------------------------------------------------------------------------
#
#  Report::Porf::Table::Simple::AutoColumnConfigurator
#
#--------------------------------------------------------------------------------

package Report::Porf::Table::Simple::AutoColumnConfigurator;

use Carp;

# use Data::Dumper;

use Report::Porf::Util;

# --- new Instance, Do NOT call direct!!! -----------------
sub new
{
    my $caller = $_[0];
    my $class  = ref($caller) || $caller;
    
    # let the class go
    my $self = {};
    bless $self, $class;

    $self->{Configurators} = {};
    $self->{max_column_width} = 60;

    return $self;
}

# --- create_report_configuration as string list ---
sub report_configuration_as_string {
    my ($self,
	$list_ref,
	$max_rows_to_inspect,
	$columns_ref
	) = @_;

	my $config_list = $self->create_report_configuration($list_ref, $max_rows_to_inspect, $columns_ref);
	my @result;
	
	foreach my $config (@$config_list) {
		my $line = '$report->cc( ';
		foreach my $key (sort(keys(%$config))) {
			$line .= " $key => ". $config->{$key}.', ';
		}
		$line .= ");";
		push (@result, $line);
	}
	return \@result;
}

# --- create_report_configuration ---
sub create_report_configuration {
    my ($self,
	$list_ref,
	$max_rows_to_inspect,
	$columns_ref
	) = @_;

    return [] unless $list_ref && scalar @$list_ref;

    my $ref_info = ref($list_ref->[0]);
    
    return $self->create_hash_report_configuration($list_ref, $max_rows_to_inspect, $columns_ref)
		if uc($ref_info) eq 'HASH';

	return $self->create_array_report_configuration($list_ref, $max_rows_to_inspect, $columns_ref)
		if uc($ref_info) eq 'ARRAY';
	
    croak "cannot create auto configuration for '$ref_info' elements.";
}

# --- crate the default report configuration for a list of hashes --------
sub create_hash_report_configuration {
    my ($self,
	$list_ref,
	$max_rows_to_inspect,
	$columns_ref
	) = @_;

    return [] unless $list_ref && scalar @$list_ref;
    
    my @config_list;
    my @columns;

    my %hash_key_store   = ();
    $max_rows_to_inspect = 10 unless defined $max_rows_to_inspect;
    $max_rows_to_inspect = $#$list_ref if $max_rows_to_inspect == -1;
    
    my $row_count = 0;
    foreach my $data (@$list_ref) {
		foreach my $key (sort(keys(%$data))) {
			next unless defined $key;
			$hash_key_store{$key} = length ($key) unless $hash_key_store{$key};
			my $text_length = length ($data->{$key} || '0');
			$hash_key_store{$key} = max($text_length, $hash_key_store{$key});
		}
		last if $row_count++ >= $max_rows_to_inspect;
    }

    if ($columns_ref && scalar @$columns_ref) {
	my @columns_missing;
	foreach my $column (@$columns_ref) {
	    push (@columns, $column);
	    push (@columns_missing, $column) unless $hash_key_store{$column};
	}
	
	if (scalar @columns_missing) {
	    die "auto config report(): columns not found in data: ('"
		. join ("', '", @columns_missing)
		. "')";
	}
    }
    else {
	@columns = sort(keys(%hash_key_store));
    }
    
    foreach my $key (@columns) {
	my $width = min ($hash_key_store{$key}, $self->{max_column_width});
	push (@config_list, {-h => $key, -vn => $key, -w => $width, -a => 'l'});
    }
    
    return \@config_list;
}

# --- crate the default report configuration for a list of arrays --------
sub create_array_report_configuration {
    my ($self,
	$list_ref,
	$max_rows_to_inspect,
	$columns_ref
	) = @_;

    return [] unless $list_ref && scalar @$list_ref;
    
    my @config_list;
    
    $max_rows_to_inspect = 10 unless defined $max_rows_to_inspect;
    $max_rows_to_inspect = $#$list_ref if $max_rows_to_inspect == -1;
    
    my $row_count = 0;
    my $max_columns = 0;
    my @column_lengths;
    foreach my $data (@$list_ref) {
	my $columns = scalar @$data;
	$max_columns = $columns if $columns > $max_columns;
	foreach my $idx (0..($columns-1)) {
	    $column_lengths[$idx] = $column_lengths[$idx] || '0';
	    my $text_length = length ($data->[$idx] || '0');
	    $column_lengths[$idx] = max ($text_length, $column_lengths[$idx]);
	}
	
	last if $row_count++ >= $max_rows_to_inspect;
    }

    $columns_ref = [] unless defined $columns_ref;
    
    foreach my $idx (0..($max_columns-1)) {
	my $width       = $column_lengths[$idx];
	my $column_name = '';

	if (defined $columns_ref->[$idx]) {
	    $column_name = $columns_ref->[$idx];
	    $width = max($column_lengths[$idx], length($column_name));
	}
	else {
	    $column_name = (($idx + 1).'. Column');
	}

	next if $column_name eq '-undef';

	$width    = min($width, $self->{max_column_width});

	push (@config_list, {-h => $column_name, -vi => $idx, -w => $width, -a => 'l'});
    }
    
    return \@config_list;
}

# --- create report with automatic configured columns ------------------
sub create_report {
    my ($self,
	$list_ref,
	$report_framework,
	$format,
	$columns_ref
	) = @_;

    return undef unless $list_ref && scalar @$list_ref;

    my $first_element = $list_ref->[0];

    $report_framework = Report::Porf::Framework::get() unless $report_framework;
    my $report        = $report_framework->create_report($format);

    $report->set_default_cell_value('');
    
    foreach my $config_option (@{$self->create_report_configuration($list_ref, undef, $columns_ref)}) {
		$report->cc (%$config_option);
    }

    $report->configure_complete();

    return $report;
}

=head1 NAME

C<Report::Porf::Table::Simple::AutoColumnConfigurator>

Configure Report columns automatically

Part of Perl Open Report Framework (Porf).

=head1 Documentation

Use C<Configurator> or C<Framework> of namespace C<Report::Porf::*> to
create Instances, that export data as text, html, csv, LaTeX, for
wikis or Excel.

See Porf.pm for documentation of features and usage.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 by Ralf Peine, Germany.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.0 or,
at your option, any later version of Perl 5 you may have available.

=head1 DISCLAIMER OF WARRANTY

This library is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut
