
use Callback;

eval "require Storable qw(1.0); require 5.6";
if ($@) {
	print "1..0\n";
	exit 0;
}

print "1..5\n";

Storable->import(qw(freeze thaw));

package TEST;

sub make { bless {}, shift }

sub print {
	my $self = shift;
	my ($d) = @_;
	print "ok $d\n";
}

package main;

my $obj = TEST->make;
my $c = new Callback ($obj, 'print');
$c->call(1);

my $x = freeze($c);
print "not " unless defined $x;
print "ok 2\n";

my $c2 = thaw($x);
print "not " unless defined $c2;
print "ok 3\n";

$c2->call(4);

my $c3 = new Callback (\&TEST::print);
eval { $x = freeze($c3) };
print "not " unless $@ =~ /since it contains/;
print "ok 5\n";

