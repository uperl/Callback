
package Callback;

require Exporter;

$VERSION = $VERSION = 1.01;
@ISA = (Exporter);
@EXPORT_OK = qw(@callbackTrace);

use strict;

sub new
{
	my ($package,$func,@args) = @_;
	my ($p, $file, $line) = caller(0);
	my $x = { FUNC => $func, ARGS => [@args], CALLER => "$file:$line"};
	return bless $x;
}

sub call
{
	my ($this, @args) = @_;
	my ($ret, @ret);

	unshift(@Callback::callbackTrace, $this->{CALLER});
	if (wantarray) {
		@ret = eval {&{$this->{FUNC}}(@{$this->{ARGS}},@args)};
	} else {
		$ret = eval {&{$this->{FUNC}}(@{$this->{ARGS}},@args)};
	}
	shift(@Callback::callbackTrace);
	die $@ if $@;
	return @ret if wantarray;
	return $ret;
}

sub DELETE
{
}

1;
