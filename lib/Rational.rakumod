#!/usr/bin/env raku

=begin pod
=head1 Rational Module

Translation of rational.pas from Decimal BASIC to Raku
Contains rational number arithmetic operations for exact arithmetic
in the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;

=begin pod
=head2 Rational Number System

Implements exact rational arithmetic using Raku's built-in Rat type.
=end pod

# Rational number container class
class RationalNumber is export {
    has Rat $.value is rw;
    
    method new(Int $numerator = 0, Int $denominator = 1) {
        if $denominator == 0 {
            die "Rational number denominator cannot be zero";
        }
        self.bless(value => Rat.new($numerator, $denominator));
    }
    
    method from-rat(Rat $r) {
        return self.bless(value => $r);
    }
    
    method from-int(Int $i) {
        return self.bless(value => $i.Rat);
    }
    
    method from-num(Num $n) {
        return self.bless(value => $n.Rat);
    }
    
    method numerator() returns Int {
        return $.value.numerator;
    }
    
    method denominator() returns Int {
        return $.value.denominator;
    }
    
    method to-rat() returns Rat {
        return $.value;
    }
    
    method to-num() returns Num {
        return $.value.Num;
    }
    
    method to-str(Int $precision = 10) returns Str {
        if $.value.denominator == 1 {
            return ~$.value.numerator;
        } elsif $precision > 0 {
            return sprintf("%.{$precision}f", $.value.Num);
        } else {
            return "{$.value.numerator}/{$.value.denominator}";
        }
    }
}

# Initialize rational arithmetic system
sub InitRational() is export {
    # Any initialization needed for rational arithmetic
    # Raku handles rational arithmetic natively
}

# Create rational from integer
sub newRationalLongint(Int $a) returns RationalNumber is export {
    return RationalNumber.from-int($a);
}

# Create rational from Number
sub NewRationalFromNumber($n) returns RationalNumber is export {
    given $n {
        when Int { return RationalNumber.from-int($n); }
        when Num { return RationalNumber.from-num($n); }
        when Rat { return RationalNumber.from-rat($n); }
        default { return RationalNumber.from-num($n.Num); }
    }
}

# Dispose rational (no-op in Raku due to GC)
sub DisposeRational(RationalNumber $r is rw) is export {
    $r = RationalNumber;
}

# Arithmetic operations
sub add(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    return RationalNumber.from-rat($a.value + $b.value);
}

sub sbt(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    return RationalNumber.from-rat($a.value - $b.value);
}

sub mlt(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    return RationalNumber.from-rat($a.value * $b.value);
}

sub qtt(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    if $b.value == 0 {
        die "Division by zero in rational arithmetic";
    }
    return RationalNumber.from-rat($a.value / $b.value);
}

sub power(RationalNumber $a, Int $exponent) returns RationalNumber is export {
    if $exponent == 0 {
        return RationalNumber.from-int(1);
    } elsif $exponent > 0 {
        return RationalNumber.from-rat($a.value ** $exponent);
    } else {
        if $a.value == 0 {
            die "Cannot raise zero to negative power";
        }
        return RationalNumber.from-rat(1 / ($a.value ** (-$exponent)));
    }
}

# Unary operations
sub opposite(RationalNumber $a) returns RationalNumber is export {
    return RationalNumber.from-rat(-$a.value);
}

sub absolute(RationalNumber $a) returns RationalNumber is export {
    return RationalNumber.from-rat($a.value.abs);
}

sub sgn(RationalNumber $a) returns Int is export {
    return $a.value <=> 0;
}

# Floor and ceiling operations  
sub BasicInt(RationalNumber $a) returns RationalNumber is export {
    # True BASIC INT function (truncate towards zero)
    return RationalNumber.from-int($a.value.truncate);
}

sub ceil(RationalNumber $a) returns RationalNumber is export {
    return RationalNumber.from-int($a.value.ceiling);
}

sub floor(RationalNumber $a) returns RationalNumber is export {
    return RationalNumber.from-int($a.value.floor);
}

# Comparison operations
sub equal(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value == $b.value;
}

sub less-than(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value < $b.value;
}

sub greater-than(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value > $b.value;
}

sub less-equal(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value <= $b.value;
}

sub greater-equal(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value >= $b.value;
}

sub not-equal(RationalNumber $a, RationalNumber $b) returns Bool is export {
    return $a.value != $b.value;
}

# Special rational values
sub rational-zero() returns RationalNumber is export {
    return RationalNumber.from-int(0);
}

sub rational-one() returns RationalNumber is export {
    return RationalNumber.from-int(1);
}

sub rational-minus-one() returns RationalNumber is export {
    return RationalNumber.from-int(-1);
}

# Rational number validation
sub is-zero(RationalNumber $a) returns Bool is export {
    return $a.value == 0;
}

sub is-one(RationalNumber $a) returns Bool is export {
    return $a.value == 1;
}

sub is-integer(RationalNumber $a) returns Bool is export {
    return $a.value.denominator == 1;
}

sub is-positive(RationalNumber $a) returns Bool is export {
    return $a.value > 0;
}

sub is-negative(RationalNumber $a) returns Bool is export {
    return $a.value < 0;
}

# Rational number utilities
sub reduce(RationalNumber $a) returns RationalNumber is export {
    # Raku automatically reduces rationals
    return $a;
}

sub gcd-rational(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    # Greatest common divisor for rationals
    if !is-integer($a) || !is-integer($b) {
        die "GCD only defined for integer rationals";
    }
    
    my $gcd-value = gcd($a.numerator, $b.numerator);
    return RationalNumber.from-int($gcd-value);
}

sub lcm-rational(RationalNumber $a, RationalNumber $b) returns RationalNumber is export {
    # Least common multiple for rationals
    if !is-integer($a) || !is-integer($b) {
        die "LCM only defined for integer rationals";
    }
    
    my $lcm-value = lcm($a.numerator, $b.numerator);
    return RationalNumber.from-int($lcm-value);
}

# Mathematical functions for rationals
sub sqrt-rational(RationalNumber $a) returns RationalNumber is export {
    if is-negative($a) {
        die "Square root of negative rational number";
    }
    
    # For exact arithmetic, only return rational if result is rational
    my $num-sqrt = sqrt($a.numerator);
    my $den-sqrt = sqrt($a.denominator);
    
    if $num-sqrt == $num-sqrt.Int && $den-sqrt == $den-sqrt.Int {
        return RationalNumber.from-rat(Rat.new($num-sqrt.Int, $den-sqrt.Int));
    } else {
        # Return floating point approximation as rational
        return RationalNumber.from-num($a.value.sqrt);
    }
}

sub reciprocal(RationalNumber $a) returns RationalNumber is export {
    if is-zero($a) {
        die "Reciprocal of zero is undefined";
    }
    return RationalNumber.from-rat(1 / $a.value);
}

# Convert to different number types
sub to-integer(RationalNumber $a) returns Int is export {
    return $a.value.Int;
}

sub to-float(RationalNumber $a) returns Num is export {
    return $a.value.Num;
}

# Parse rational from string
sub parse-rational(Str $s) returns RationalNumber is export {
    try {
        # Try to parse as fraction first
        if $s ~~ /^ (\-?\d+) '/' (\d+) $/ {
            my $num = +$0;
            my $den = +$1;
            if $den == 0 {
                die "Zero denominator in fraction";
            }
            return RationalNumber.new($num, $den);
        }
        # Otherwise parse as decimal
        else {
            return RationalNumber.from-rat($s.Rat);
        }
    }
    
    CATCH {
        default {
            die "Invalid rational number format: '$s'";
        }
    }
}

=begin pod
=head1 EXPORTS

All rational arithmetic functions and the RationalNumber class are exported.

=head1 USAGE

    use Rational;
    
    my $a = newRationalLongint(3);      # 3/1
    my $b = RationalNumber.new(1, 4);   # 1/4
    
    my $sum = add($a, $b);              # 13/4
    my $product = mlt($a, $b);          # 3/4
    
    say $sum.to-str();                  # "13/4" or "3.25"

=end pod