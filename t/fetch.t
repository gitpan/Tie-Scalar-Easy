BEGIN { $| = 1; print "1..4\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Scalar::Easy;
$loaded = 1;
print "ok 1\n";

$scalar = new Tie::Scalar::Easy { 'scalar' => 'hello' };
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    tied $$scalar;
print "ok 2\n";

print "not " unless $$scalar eq 'hello';
print "ok 3\n";

undef $scalar;

$scalar = new Tie::Scalar::Easy
    { FETCH => sub { return ++${$_[0]}{'scalar'} } };
print "not " unless $$scalar == 1 && $$scalar == 2 && $$scalar == 3;
print "ok 4\n";
