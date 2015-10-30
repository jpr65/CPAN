use 5.006000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Perl5::Spartanic',
    VERSION_FROM      => 'lib/Perl5/Spartanic.pm',
    PREREQ_PM         => { },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Perl5/Spartanic.pm', # retrieve abstract from module
       AUTHOR         => 'Ralf Peine <ralf.peine@jupiter-programs.de>') : ()),
);
