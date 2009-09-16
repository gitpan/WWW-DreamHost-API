# $Id: Makefile.PL 5 2009-09-16 15:15:27Z stro $

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  'NAME'          => 'WWW::DreamHost::API',
  'ABSTRACT'      => 'DreamHost Web Panel API',
  'AUTHOR'        => 'Serguei Trouchelle <stro@cpan.org>',
  'VERSION_FROM'  => 'API.pm',
  'LICENSE'       => 'perl',
  'PREREQ_PM'     => {
                         'LWP::UserAgent' => 0,
                         'Crypt::SSLeay'  => 0,
                         'Data::UUID'     => 0,
                     },
);
