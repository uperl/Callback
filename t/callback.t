
use Callback;

print "1..5\n";

my $c0 = new Callback (\&pr0);
my $c1 = new Callback (\&pr1, 2);
my $c2 = new Callback (\&pr1, 3);
my $c3 = new Callback (\&pr1);
my $c4 = new Callback (\&pr2, 1);

$c0->call();
$c1->call();
$c2->call(5);
$c3->call(4);
$c4->call(4);

sub pr0 
{
	print "ok 1\n";
}

sub pr1
{
	my ($a) = @_;
	print "ok $a\n";
}

sub pr2
{
	my ($a, $b) = @_;
	my $s = $a + $b;
	print "ok $s\n";
}

