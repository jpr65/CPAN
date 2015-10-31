#==============================================================================
#
# build_release.pl
#
#      Build release tar file for cpan upload
#
# Ralf Peine, 31.10.2015, 08:00
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

my $manifest_file = par manifest_file => ExistingFile => "$source_dir/MANIFEST";

$dest_dir .= "/$module";
mkdir $dest_dir;

say "# ===========================================================================";
say "# Build release $version of $module and store in $dest_dir";

my $release_file = "$dest_dir/$module-$version.tar";

msg "read manifest ...";

my @files = map { "$source_dir/$_" } read_file($manifest_file);

msg "packing files ...";

say join("\n", @files);

msg "build release file ...";

my $tar = Archive::Tar->new;
$tar->add_files(@files);

$tar->write($release_file);

msg "write dest file as $release_file.gz";

$tar->write($release_file);

system ("gzip $release_file");
    
msg "Done."
