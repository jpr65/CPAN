#==============================================================================
#
# build_release.pl
#
#      Build release tar file for cpan upload
#
# Ralf Peine, 30.10.2015, 07:00
#
#==============================================================================
#  /^\s*sub\s+(\w+)/

use strict;
use warnings;

$| = 1;

use vars qw($VERSION);
$VERSION ='0.010';

use v5.10;

use Perl5::Spartanic;

use FileHandle;
use Archive::Tar;
# use Alive qw(:all);
# use Log::Trace;

use Scalar::Validation qw(:all);

# --- handle options ---------------------------

my $trouble_level = p_start;

my %arg_opts = convert_to_named_params \@ARGV;

my $module   = npar -module  => Filled      => \%arg_opts;
my $version  = npar -version => Filled      => \%arg_opts;
my $dest_dir = npar -dest    => ExistingDir => \%arg_opts;

p_end \%arg_opts;

my $source_dir    = par source_dir    => ExistingDir  => $module;
my $manifest_file = par manifest_file => ExistingFile => "$source_dir/MANIFEST";

return undef if validation_trouble($trouble_level);
    
# --- SUBS -----------------------------------------------
sub msg { say "# " . join ("\n# ", @_); } 

sub read_file {
    my $file = shift;

    my $fh = new FileHandle;

    $fh->open($file) or die "can't read file $file: $!";

    my @lines;

    while (<$fh>) {
        chomp;
        next if /^\s*#/;
        push @lines, $_;
    }

    return @lines;
}

# --- MAIN -----------------------------------------------

$dest_dir .= "/$module";
mkdir $dest_dir;

my $release_file = "$dest_dir/$module-$version.tgz";

msg "read manifest ...";

my @files = read_file($manifest_file);

msg "packing files ...";

say join("\n", @files);

my $tar = Archive::Tar->new;
$tar->add_files(@files);

msg "write dest file as $release_file";

$tar->write($release_file);

msg "Done."
