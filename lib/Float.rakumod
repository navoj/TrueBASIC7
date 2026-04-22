#!/usr/bin/env raku

=begin pod
=head1 Float Module

Translation of float.pas from Decimal BASIC to Raku
Contains floating-point arithmetic operations and utility functions
for the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;

=begin pod
=head2 Floating Point Operations

Basic floating point arithmetic operations with extended precision support.
=end pod

# Extended precision floating point operations
sub abs(Num $x) returns Num is export {
    return $x.abs;
}

sub int(Num $x) returns Num is export {
    return $x.Int.Num;
}

sub floor(Num $x) returns Int is export {
    return $x.floor;
}

sub LongIntRound(Num $x) returns Int is export {
    return $x.round;
}

multi sub LongIntRound(Rat $x) returns Int is export {
    return $x.round;
}

sub opposite($x is rw) is export {
    $x = -$x;
}

sub add($x is rw, $y) is export {
    $x += $y;
}

sub sbt($x is rw, $y) is export {
    $x -= $y;
}

sub mlt($x is rw, $y) is export {
    $x *= $y;
}

sub qtt($x is rw, $y) is export {
    if $y == 0 {
        die "Division by zero";
    }
    $x /= $y;
}

sub power($x is rw, $y) is export {
    if $x == 0 && $y <= 0 {
        die "Invalid power operation: 0^($y)";
    }
    $x = $x ** $y;
}

=begin pod
=head2 Extended Math Functions

Additional mathematical functions for floating point operations.
=end pod

sub mod-operation($x is rw, $y) is export {
    if $y == 0 {
        die "Modulo by zero";
    }
    $x = $x % $y;
}

sub max-float($a, $b) returns Num is export {
    return max($a, $b);
}

sub min-float($a, $b) returns Num is export {
    return min($a, $b);
}

sub sgn(Num $x) returns Int is export {
    return $x <=> 0;
}

# IEEE floating point special values handling
sub is-nan(Num $x) returns Bool is export {
    return $x.isNaN;
}

sub is-infinite(Num $x) returns Bool is export {
    return $x.abs == Inf;
}

sub is-finite(Num $x) returns Bool is export {
    return $x.isFinite;
}

# Rounding and truncation
sub truncate(Num $x) returns Int is export {
    return $x.truncate;
}

sub round-to-nearest(Num $x) returns Num is export {
    return $x.round;
}

sub round-towards-zero(Num $x) returns Num is export {
    return $x.truncate.Num;
}

sub round-towards-positive(Num $x) returns Num is export {
    return $x.ceiling.Num;
}

sub round-towards-negative(Num $x) returns Num is export {
    return $x.floor.Num;
}

# Convert between different numeric types
sub to-extended(Int $x) returns Num is export {
    return $x.Num;
}

sub to-extended(Rat $x) returns Num is export {
    return $x.Num;
}

sub to-double(Num $x) returns Num is export {
    return $x;  # Raku handles precision automatically
}

sub from-string(Str $s) returns Num is export {
    try {
        return $s.Num;
        CATCH {
            default {
                die "Invalid numeric string: '$s'";
            }
        }
    }
}

sub to-string(Num $x, Int $precision = 6) returns Str is export {
    if is-nan($x) {
        return "NaN";
    } elsif is-infinite($x) {
        return $x > 0 ?? "Infinity" !! "-Infinity";
    } else {
        return sprintf("%.{$precision}g", $x);
    }
}

# Comparison operations with tolerance for floating point
sub float-equal(Num $a, Num $b, Num $epsilon = 1e-15) returns Bool is export {
    return abs($a - $b) < $epsilon;
}

sub float-less(Num $a, Num $b, Num $epsilon = 1e-15) returns Bool is export {
    return $a < $b && !float-equal($a, $b, $epsilon);
}

sub float-greater(Num $a, Num $b, Num $epsilon = 1e-15) returns Bool is export {
    return $a > $b && !float-equal($a, $b, $epsilon);
}

sub float-less-equal(Num $a, Num $b, Num $epsilon = 1e-15) returns Bool is export {
    return $a < $b || float-equal($a, $b, $epsilon);
}

sub float-greater-equal(Num $a, Num $b, Num $epsilon = 1e-15) returns Bool is export {
    return $a > $b || float-equal($a, $b, $epsilon);
}

=begin pod
=head1 EXPORTS

All floating point arithmetic functions are exported for use in mathematical expressions.

=head1 USAGE

    use Float;
    
    my $x = 3.14159;
    my $y = 2.71828;
    
    add($x, $y);       # $x = $x + $y
    mlt($x, 2.0);      # $x = $x * 2.0
    power($x, 0.5);    # $x = sqrt($x)
    
    say to-string($x, 4);  # Format with 4 decimal places

=end pod