BEGIN { $| = 1; print "1..4\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Scalar::Easy;
$loaded = 1;
print "ok 1\n";

$scalar = new Tie::Scalar::Easy { 'DESTROY' => sub { print "ok 3\n" } };
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    tied $$scalar;
print "ok 2\n";
$scalar = new Tie::Scalar::Easy { 'DESTROY' => sub { print "ok 4\n" } };
undef $scalar;
