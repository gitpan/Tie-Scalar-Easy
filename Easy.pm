# Copyright (C) 1997 Ashley Winters <jql@accessone.com>. All rights reserved.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

package Tie::Scalar::Easy;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';

sub new {
    my $class = shift;
    my $tmp;
    my $scalar = ref $_[0] eq "SCALAR" ? shift : \$tmp;
    my $funcs = ref $_[0] eq "HASH" ? shift : {};

    tie($$scalar, $class, $funcs, @_);

    return $scalar;
}

sub TIESCALAR {
    my $class = shift;
    my $self = shift;

    $self = bless $self, $class;
    $$self{'scalar'} = 0 unless exists $$self{'scalar'};
    &{$$self{'TIESCALAR'}}($self, @_) if $self->validfunc('TIESCALAR');

    return $self;
}

sub FETCH {
    my $self = shift;

    return &{$$self{'FETCH'}}($self) if $self->validfunc('FETCH');
    return exists $$self{'scalar'} ? $$self{'scalar'} : undef;
}

sub STORE {
    my $self = shift;
    my $value = shift;

    if($self->validfunc('STORE')) { &{$$self{'STORE'}}($self, $value) }
    else { $$self{'scalar'} = $value }
}

sub DESTROY {
    my $self = shift;

    &{$$self{'DESTROY'}}($self) if $self->validfunc('DESTROY');
    delete $$self{'scalar'};
}

sub validfunc {
    my $self = shift;
    my $func = shift;

    return (exists $$self{$func} && ref $$self{$func} eq 'CODE');
}

1;
__END__

=head1 NAME

Tie::Scalar::Easy - Perl module for the simple creation of tied scalars

=head1 SYNOPSIS

  use Tie::Scalar::Easy;

  $scalar_ref = new Tie::Scalar::Easy([\$scalar] [, $funcs]);

=head1 DESCRIPTION

Tie::Scalar::Easy is meant to provide a simple way to create a tied
scalar without needing to create a new class, and to be able to override
the various access functions at runtime, as needed. This class is very
simple and single-minded. It has a purpose, and does it very well.

The new() function is a wrapper for tie(), it can be bypassed if you know
what you're doing. If it has no arguments, it just returns a reference to a
tied scalar that acts identically to any other scalar. If the first argument
is a scalar reference, the scalar that the reference points to is tied. That's
to allow the programmer to tie a hash value, or a non-reference variable.
Otherwise, a newly created tied scalar is returned. If you pass the $funcs
argument, which should be a hash reference containing keys with the names of
the functions of a tied scalar, with the values being a reference to a sub
that will be called when it would have been called if it were a member of a
tied class.

=head1 GUTS

Well, it does a bit of good for the programmer to know just what is I<really>
going on inside of Tie::Scalar::Easy.

The new() function basically has only one useful statement, a tie().
Any arguments not recognized are passed intact to TIEHASH().

The TIEHASH() function blesses it's HASH ref argument, if there is one.
It does no checking whatsoever as to the keys of it's argument. That means
that any hash keys are valid. Remember that the hash is not copied before it
becomes the object. That means you could create multiple scalars that always
have the same value. That can be done without this class by doing
C<*copy1 = \$orig; *copy2 = \$orig;> but it's something to keep in mind.

If you want to change the functions at run-time, just run
C<${&tied($scalar)}{$function} = $subref;>.

The default key for the referenced scalar is 'scalar'. If you pass a hash
to be blessed and don't define it, it doesn't exist. Everything should still
work, though.

If you have a good reason, you can pass non-sub-refs as the values
of the subroutine-name keys. The internal validfunc() member-function does
minimal checking to ensure that the key's value both exists and is a CODE
ref before it is executed.

The arguments to the sub refs in the object are very similar to the argument
for normal tied scalars. You should definitly read and understand 
L<perltie>.

=over 4

=item TIEHASH this, LIST

Unlike the original TIEHASH, the object has been created before this is
called. Any arguments passed to Tie::Scalar::Easy::TIEHASH() which
are not used by it, are passed as LIST. This function's return-value is
discarded.

=item FETCH this

You must return whatever value you want the scalar to represent from this
function.

=item STORE this, value

Whenever an attempt to store a value in the tied scalar is made, this function
is called and passed that value.

=item DESTROY this

If you want to do anything when the tied scalar is garbage-collected, this
would be the place to do it.

=back

=head1 EXAMPLES

Can't hurt to give an example of how you would actually use this class.
The following example shows how you can create a scalar that gives a
random integer between 0 and 100 each time it's accessed.

	use Tie::Scalar::Easy;

	srand(time ^ $$);        # needed before perl-5.004
	new Tie::Scalar::Easy(\$random, {
	    FETCH => sub { return int(rand(100) + .5) } });
	print "$random, $random, $random, $random\n";

=head1 AUTHOR

Ashley Winters <jql@accessone.com>

=head1 SEE ALSO

perl(1), perlref(1), perlsub(1), perltie(1).

=cut
