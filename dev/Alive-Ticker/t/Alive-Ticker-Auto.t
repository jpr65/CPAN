# Perl 5
#
# Test for Alive::Ticker
#
# Config tick and tack automaticly. Therefore an own test is needed.
#
# Ralf Peine, Sun Dec 20 16:45:29 2020
#
#------------------------------------------------------------------------------

# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Alive-Ticker-Auto.t'

use strict;
use warnings;

use v5.10;

use Test::More tests => 14;
use Alive::Ticker qw(:all);

sub _note_err { note join (' ', @_) . "\n"; }

note " config tick and tack automaticly.";

foreach my $i (1..10000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
} _note_err;

is (ticks, 10000, "10000 ticks");
is (tacks,   136, "  136 tacks");

note "next run cumulative";

foreach my $i (1..10000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
} _note_err;

is (ticks, 20000, "20000 ticks");
is (tacks,   272, "  272 tacks");

Alive::Ticker::reset_tick();

is (ticks, 0, "0 ticks after reset");

foreach my $i (1..1000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
} _note_err;

is (ticks, 1000, "1000 ticks");
is (tacks,  285, " 285 tacks");

Alive::Ticker::reset_tack();

is (tacks, 0, "0 tacks after reset");

foreach my $i (1..1000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
} _note_err;

is (ticks, 2000, "2000 ticks");
is (tacks,   13, "  13 tacks");

Alive::Ticker::reset();

is (ticks, 0, "0 ticks after reset");
is (tacks, 0, "0 tacks after reset");

foreach my $i (1..1000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
} _note_err;

is (ticks, 1000, "1000 ticks");
is (tacks,   13, "  13 tacks");
