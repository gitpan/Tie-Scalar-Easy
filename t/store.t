BEGIN { $| = 1; print "1..6\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Scalar::Easy;
$loaded = 1;
print "ok 1\n";

$scalar = new Tie::Scalar::Easy;
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    tied $$scalar;
print "ok 2\n";

$$scalar = 'foo';

print "not " unless ($object = tied $$scalar) && exists $$object{'scalar'} &&
    $$object{'scalar'} eq 'foo';
print "ok 3\n";

undef $scalar;

$scalar = new Tie::Scalar::Easy { 'STORE' => sub { $value = $_[1] } };
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    tied $$scalar;
print "ok 4\n";

$$scalar = 10;
print "not " unless $value == 10;
print "ok 5\n";

$$scalar = 'blah';
print "not " unless $value eq 'blah';
print "ok 6\n";