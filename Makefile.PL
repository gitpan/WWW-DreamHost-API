# $Id: Makefile.PL 8 2009-10-18 11:43:13Z stro $

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
