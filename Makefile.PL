#! /usr/local/bin/perl

use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile being created.
WriteMakefile(
	'NAME' => 'Callback',
	'DISTNAME' => 'Callback',
	'VERSION_FROM' => 'Callback.pm',
	'dist'   => {COMPRESS=>'gzip', SUFFIX=>'gz'}
);

package MY;

sub postamble {
    <<"END_OF_POSTAMBLE";

pm_to_blib: README

README: Callback.pod
\tpod2text Callback.pod >README

END_OF_POSTAMBLE
}
