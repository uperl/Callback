use strict;
use warnings;
use Callback;

print "1..7\n";

package TEST;

sub make { bless {}, shift }

sub pr6 {
  my $self = shift;
  my ($d) = @_;
  print "ok $d\n";
}

package main;

my $c0 = Callback->new(\&pr0);
my $c1 = Callback->new(\&pr1, 2);
my $c2 = Callback->new(\&pr1, 3);
my $c3 = Callback->new(\&pr1);
my $c4 = Callback->new(\&pr2, 1);

my $obj = TEST->make;
my $c5 = Callback->new($obj, 'pr6', 6);
my $c6 = Callback->new($obj, 'pr6');

$c0->call();
$c1->call();
$c2->call(5);
$c3->call(4);
$c4->call(4);
$c5->call();
$c6->call(7);

sub pr0
{
  print "ok 1\n";
}

sub pr1
{
  my ($arg) = @_;
  print "ok $arg\n";
}

sub pr2
{
  my ($arg1, $arg2) = @_;
  my $s = $arg1 + $arg2;
  print "ok $s\n";
}

