
package Callback;

use strict;
use warnings;
use base qw( Exporter );

our $VERSION = $VERSION = 1.07;
our @EXPORT_OK = qw(@callbackTrace);

sub new
{
  my ($package,$func,@args) = @_;
  my ($p, $file, $line) = caller(0);
  my @method;
  if (ref $func ne 'CODE' && UNIVERSAL::isa($func, "UNIVERSAL")) {
    if ($func->isa('Callback')) {
      return $func unless @args;
      my $new = bless { %$func }, $package;
      push(@{$new->{ARGS}}, @args);
      return $new;
    } else {
      my $method = shift @args;
      my $obj = $func;
      $func = $obj->can($method);
      unless (defined $func) {
        require Carp;
        Carp::croak("Can't locate method '$method' for object $obj");
      }
      unshift(@args, $obj);
      @method = (METHOD => $method);  # For Storable hooks
    }
  }
  my $x = {
    FUNC   => $func,
    ARGS   => [@args],
    CALLER => "$file:$line",
    @method
  };
  return bless $x, $package;
}

sub call
{
  my ($this, @args) = @_;
  my ($ret, @ret);

  unshift(@Callback::callbackTrace, $this->{CALLER});
  if (wantarray) {  ## no critic (Policy::Community::Wantarray)
    @ret = eval {&{$this->{FUNC}}(@{$this->{ARGS}},@args)};
  } else {
    $ret = eval {&{$this->{FUNC}}(@{$this->{ARGS}},@args)};
  }
  shift(@Callback::callbackTrace);
  die $@ if $@;
  return @ret if wantarray;  ## no critic (Policy::Community::Wantarray)
  return $ret;
}

sub DELETE
{
}

#
# Storable hooks
#
# We cannot serialize something containing a pure CODE ref, which is the
# case if there's no METHOD attribute in the object.
#
# However, when Callback is a method call, we can remove the FUNC attribute
# and serialize the object: the function address will be recomputed at
# retrieve time.
#

sub STORABLE_freeze {
  my ($self, $cloning) = @_;
  return if $cloning;

  my %copy = %$self;
  die "cannot store $self since it contains CODE references\n"
    unless exists $copy{METHOD};

  delete $copy{FUNC};
  return ("", \%copy);
}

sub STORABLE_thaw {
  my ($self, $cloning, $x, $copy) = @_;

  %$self = %$copy;

  my $method = $self->{METHOD};
  my $obj = $self->{ARGS}->[0];
  my $func = $obj->can($method);
  die("cannot restore $self: can't locate method '$method' on object $obj")
    unless defined $func;

  $self->{FUNC} = $func;
  return;
}

1;

=head1 NAME

Callback - object interface for function callbacks

=head1 SYNOPSIS

 use Callback;
 
 my $callback = new Callback (\&myfunc, @myargs);
 my $callback = new Callback ($myobj, $mymethod, @myargs);
 my $callback = new Callback ($old_callback, @myargs);

 $callback->call(@some_more_args);

=head1 DESCRIPTION

Callback provides a standard interface to register callbacks.  Those
callbacks can be either purely functional (i.e. a function call with
arguments) or object-oriented (a method call on an object).

When a callback is constructed, a base set of arguments can be 
provided.  These function arguments will preceed any arguments added
at the time the call is made.

There are two forms for the callback constructor, depending on whether the
call is a pure functional call or a method call.  The rule is that if the
first argument is an object, then the second argument is a method name to
be called on that object.  Method resolution happens at the time the Callback
object is built: an error will be raised if it cannot be found.

Callback objects built for object-oriented calls also have the property
of being serializable via Storable.  Purely functional callabacks cannot
be serialized because CODE references are not supported by Storable.

Callback objects can be created from existing Callback objects.  Any
arguments will be appended onto the original list of arguments.

=head1 TRACING

 use Callback qw(@callbackTrace);

If you're writing a debugging routine that provides a stack-dump
(for example, Carp::confess) it is useful to know where a callback
was registered.  

 my $ct = 0;
   while (($package, $file, $line, $subname, $hasargs, $wantarray) = caller($i++)) {
     ...

     if ($subname eq 'Callback::call') {
       print "callback registered $Callback::callbackTrace[$ct]\n";
       $ct++;
     }
 }

Without such code, it becomes very hard to know what's going on.

=head1 COPYRIGHT

Copyright (C) 1994, 2000, 2002 David Muir Sharnoff.   All rights reserved.
This module may be licensed on the same terms as Perl itself.

=head1 AUTHORS

David Muir Sharnoff F<E<lt>muir@idiom.comE<gt>>
and
Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

=over 4

=item L<Storable>

=back

=cut
