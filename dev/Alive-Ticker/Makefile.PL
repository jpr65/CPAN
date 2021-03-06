use 5.006000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Alive::Ticker',
    VERSION_FROM      => 'lib/Alive/Ticker.pm', # finds $VERSION
    PREREQ_PM         => {'Test::More'         => 0,
                          'Perl5::Spartanic'   => 0,
                          'Scalar::Validation' => 0,
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Alive/Ticker.pm', # retrieve abstract from module
       AUTHOR         => 'Ralf Peine <ralf.peine@jupiter-programs.de>') : ()),
);
