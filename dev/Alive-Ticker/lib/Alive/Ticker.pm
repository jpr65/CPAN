#==============================================================================
#
#  Alive::Ticker - Tick-Tack (German baby-word for clock)
#
#  to show perl is still alive and working during long time runnings
#  prints out chars every n-th call 
#
#  Ralf Peine, Wed May 26 18:10:35 2015
#
#==============================================================================

package Alive::Ticker;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION ='0.200';

use Perl5::Spartanic;
use Time::HiRes qw(time);

use base qw(Exporter);

our @EXPORT    = qw();
our @EXPORT_OK = qw(tick ticks get_tick_counter reset_tick_counter
                    tack tacks get_tack_counter reset_tack_counter);
our %EXPORT_TAGS = (
    all => [@EXPORT_OK]
);

use Scalar::Validation qw(:all);

# === run state ==========================================

# do nothing if off > 0
my $off = 0;

# --- count and print ---------
sub on {
    $off = 0;
}

# --- count, but do not print ---------
sub silent {
    $off = 1;
}

# --- silent for existing instances,            -------
#     new created do nothing, also not counting -------
sub all_off {
    $off = 2;
}

# --- create a new tick tack ---------------------------------------------------
sub create {
    my $trouble_level = p_start;
    my %pars          = convert_to_named_params \@_;
    
    my $smaller         = npar -smaller         => -Default =>   1  => Int    => \%pars;
    my $bigger          = npar -bigger          => -Default =>  10  => Int    => \%pars;
    my $newline         = npar -newline         => -Default =>  50  => Int    => \%pars;
    my $factor          = npar -factor          => -Default =>  10  => Int    => \%pars;
    my $smaller_char    = npar -smaller_char    => -Default => '.'  => Scalar => \%pars;
    my $bigger_char     = npar -bigger_char     => -Default => ','  => Scalar => \%pars;
    my $name            = npar -name            => -Default => ''   => Scalar => \%pars;
    
    my $counter         = 0;
    my $counter_ref     = npar -counter_ref     => -Default => \$counter => Ref     => \%pars;
    
    my $action          = npar -action          => -Optional             => CodeRef => \%pars;
    my $auto_regulation = npar -auto_regulation => -Default => 0
                                                => -Range   => [0,10]    => Float   => \%pars;
        
    p_end \%pars;
 
    return undef if validation_trouble($trouble_level);
    
    # --- run sub ----------------------------------------
 
    $name .= ' ' if $name =~ /\S$/;
    
    return sub { } if $off > 1;
    
    $smaller *= $factor;
    $bigger  *= $factor;
    $newline *= $factor;

    my $next_tick_grenze = $newline;

    my $last_counter_reconfig_time = 0;

    return sub {
        return if $off > 1;
        
        $$counter_ref++;
        
        if ($action) {
            local $_ = $$counter_ref;
            $action->();
        }
        
        return if $off;

        if ($auto_regulation && $$counter_ref > $next_tick_grenze) {
            my $current_time_diff = 0;
            $current_time_diff = time() - $last_counter_reconfig_time if $last_counter_reconfig_time;
            # print "current_time_diff = $current_time_diff\n";

            if ($current_time_diff < $auto_regulation) {
                $last_counter_reconfig_time = time();
                $smaller *= 10;
                $bigger  *= 10;
                $newline *= 10;
            }
            $next_tick_grenze *= 10;
        }
        
        unless ($$counter_ref % $newline) {
            print "\n$name$$counter_ref ";
            return;
        }
        
        unless ($$counter_ref % $bigger) {
            print $bigger_char;
            return;
        }
        
        unless ($$counter_ref % $smaller) {
            print $smaller_char;
            return;
        }
    }    
}

# --- default tick ----------------------------------
my $tick;
my $tick_counter = 0;

# --- setup default tick ----------------------------
sub setup_tick {
    $tick_counter = 0;
    $tick         = create(@_, -counter_ref => \$tick_counter); 
}

sub get_tick_counter {
    return \$tick_counter;
}

sub reset_tick_counter {
    $tick_counter = 0;
}

sub ticks {
    return $tick_counter;
}

# --- default tack ----------------------------------
my $tack;
my $tack_counter = 0;

# --- setup default tick tack ----------------------------
sub setup_tack {
    $tack_counter = 0;
    $tack         = create(@_, -counter_ref => \$tack_counter); 
}

sub get_tack_counter {
    return \$tack_counter;
}

sub reset_tack_counter {
    $tack_counter = 0;
}

sub tacks {
    return $tack_counter;
}

# === setup ticker ======================================

sub setup {
    return setup_tick(@_);
}

# === the working function ===============================

# --- count and print ------------------
sub tick {
    setup_tick() unless $tick;
    $tick->();
    return $tick;
}

# --- count and print ------------------
sub tack {
    setup_tack() unless $tack;
    $tack->();
    return $tack;
}

1;

__END__

=head1 NAME

Alive::Ticker - to show perl is still alive and working during long time runnings

=head1 VERSION

This documentation refers to version 0.200 of Alive::Ticker

=head1 SYNOPSIS

Shortest

  use Alive::Ticker qw(tack);
  
  foreach my $i (1..10000) {
      tack;
  }

or use "tick"

  use Alive::Ticker qw(tack);
  
  foreach my $i (1..10000) {
      tack;
  }

or fastest

  use Alive::Ticker qw(tack);

  my $tick = tack;
  
  foreach my $i (1..10000) {
      $tick->();
  }

or individual

  my $tick = Alive::Ticker::create(
      -smaller      => 10,
      -bigger       => 100,
      -newline      => 500,
      -smaller_char => '+',
      -bigger_char  => '#',
      -name         => 'M ##',
  );

  foreach my $i (1..100000) {
      $tick->();
  }

or use both interal counters "tick" and "tack", tick for every loop and tack for every match:

  Alive::Ticker::setup_tick(
      -factor       => 100
  );

  Alive::Ticker::setup_tack(
      -name         => '#M',
      -smaller_char => '*',
      -bigger_char  => '&',
      -factor       => 1
  );

  foreach my $i (1..10000) {
      tick;
      if ($i % 73 == 0) {
          tack;
      }
  }

=head1 DESCRIPTION

Alive::Ticker does inform the user that perl job or script is still running by printing to console.

There are two internal tickers, "tick" and "tack".

The following script

  $| = 1;
  use Alive::Ticker qw(:all);
  
  foreach my $i (1..2000) {
      tick;
  }

prints out this

  .........,.........,.........,.........,.........
  500 .........,.........,.........,.........,.........
  1000 .........,.........,.........,.........,.........
  1500 .........,.........,.........,.........,.........
  2000 

=head2 Methods

=head3 new() does not exist

There is no new(), use create() instead. Reason is, that there are no instances of Alive::Ticker
that could be created.

=head3 create()

Alive::Ticker::create() creates a tick closure (a reference to a anonymous sub) for comfort
and fast calling without method name search and without args. The counter is inside.

Using instances is much more work to implement (without any class-support like Moo),
slower and not so flexible.

=head4 Parameters

  # name           # default: description
  -smaller         #  1: print every $smaller * $factor call $smaller_char 
  -bigger          # 10: print every $bigger  * $factor call $bigger_char 
  -newline         # 50: print every $newline * $factor call "\n$name$$counter_ref"
  -factor          # 10:
  -smaller_char    # '.'
  -bigger_char     # ','
  -name            # '': prepend every new line with it
  -auto_regulation # 0 : [0.0..10.0] If > 0, regulate -factor by time to print one dot
  -counter_ref     # reference to counter that should be used
  -action          # action will be called by every call of tack; tick; or $tick->();

=head3 Parameter -auto_regulation

  $tick_auto = Alive::Ticker::create(-name            => 'Dyn',
                                     -auto_regulation => 1);

  foreach my $i (1..2000000) {
      $tick_auto->();
  }

prints something like:

  .........,.........,.........,.........,.........
  Dyn 500 ....,.........,.........,.........,.........
  Dyn 5000 ....,.........,.........,.........,.........
  Dyn 50000 ....,.........,.........,.........,.........
  Dyn 500000 ....,.........,

=head3 setup()

Setup create the default ticker tick with same arguments as in create, except that

  # -counter_ref => ignored
  
will be ignored.

=head3 tack, tick or $tick->()

$tick->() prints out a '.' every 10th call (default), a ',' every 100th call (default) and
starts a new line with number of calls done printed every 500th call (default).

=head3 tacks() or ticks()

returns the value of the counter used by tack.

=head3 get_tack_counter() or get_tick_counter()

returns a reference to the counter variable used by tack or tick for fast access.

=head2 Running Modes

There are 3 running modes that can be selected:

  Alive::Ticker::on();        # default
  Alive::Ticker::silent();
  Alive::Ticker::all_off();

=head3 on()

Call of

  $tick->(); or tack;
  
prints out what is configured. This is the default.

=head3 silent()

Call of 

  $tick->(); tack;
  
prints out nothing, but does the counting.

=head3 all_off()

If you need speed up, use

  Alive::Ticker::all_off();

Now nothing is printed or counted by all ticks.
Selecting this mode gives you maximum speed without removing $tick->() calls.
  
  my $tick = Alive::Ticker::create();
  
  Alive::Ticker::all_off();

  my $tick_never = Alive::Ticker::create();
  
call of $tick->(); prints out nothing and does not count.

$tick_never has an empty sub which is same as

  my $tick_never = sub {};

This $tick_never will also not print out anything, if

  Alive::Ticker::on();
  
is called to enable ticking.

=head2 Using multiple ticks same time

You can use multiple ticks same time, like in the following example.
tick1 ticks all fetched rows and tick2 only those, which are selected by
given filter. So you can see, if database select is still running or halted.
But start ticking not before more than 40000 rows processed. So don't
log out for small selections.

  use Alive::Ticker;
  
  # Ticks all fetched rows
  my $tick1 = Alive::Ticker::create(
      -factor => 100,
      -name   => '   S',
  );

  my $matches = 0;

  # To tick rows selected by filter
  my $tick2 = Alive::Ticker::create(
      -factor       => 10,
      -smaller_char => '+',
      -bigger_char  => '#',
      -name         => 'M ##',
      -counter_ref  => \$matches,
  );

  Alive::Ticker::silent();

  my @filtered_rows;

  foreach my $i (1..100000) {
      my $row = $sql->fetch_row();
      $tick1->();
      
      if ($filter->($row)) {
          push (@filtered_rows, $row);
          $tick2->();
      }
      
      Alive::Ticker::on() if $i == 40000;
  }
  
  say qq();
  say "$matches rows matched to filter.";
  
It will print out something like:

  .....#....,.........,........+.,.......+..,.........+
     S 45000 .........+,......+...,.....+....,.......+..,.....+....
     S 50000 .....+....,........
  M ## 500 .,......+...,...+......,.....+....
     S 55000 +.........,..+.......,.........,+.........,+.........
     S 60000 .+........,+.........,#.......+..,......+...,..+.......
     S 65000 .........,+.......+..,........+.,....+.....,.+........
     S 70000 .......+..,......#...,........+.,........+.,.........
     S 75000 ..+.......,......+...,....+.....,..+.......,.....+....
     S 80000 ....+.....,.........+,.........,........#.,.......+..
     S 85000 ..+.......,+........+.,.........+,........+.,.........
     S 90000 .......+..,......+...,......+...,...#......,....+.....
     S 95000 +.........,..+.....+..,.........,+.........,.+........+
     S 100000 
  987 rows matched to filter.

=head1 SEE ALSO 

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2015 by Ralf Peine, Germany. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.0 or,
at your option, any later version of Perl 5 you may have available.

=head1 DISCLAIMER OF WARRANTY

This library is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut
