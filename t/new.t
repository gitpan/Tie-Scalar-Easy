BEGIN { $| = 1; print "1..4\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Scalar::Easy;
$loaded = 1;
print "ok 1\n";

$scalar = new Tie::Scalar::Easy;
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    tied $$scalar;
print "ok 2\n";

undef $scalar;

$scalar = new Tie::Scalar::Easy { TIESCALAR => sub { ${$_[0]}{ran} = 3 } };
print "not " unless defined $scalar && ref $scalar eq "SCALAR" &&
    (tied $$scalar || {})->{ran} == 3;
print "ok 3\n";

undef $scalar;

new Tie::Scalar::Easy \$scalar,
    { TIESCALAR => sub { ${$_[0]}{ran} = $_[1] } }, 3;
print "not " unless (tied $scalar || {})->{ran} == 3;
print "ok 4\n";
