#!/usr/bin/env raku

=begin pod
=head1 Math2 Module

Translation of math2.pas from Decimal BASIC to Raku
Contains mathematical functions for the True BASIC interpreter.
Implements transcendental functions, trigonometry, logarithms, etc.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;
use Float;
use Rational;

=begin pod
=head2 Mathematical Constants
=end pod

constant E is export = e;                    # Euler's number
constant PI is export = pi;                  # π
constant LOG10E is export = log10(e);        # log₁₀(e)
constant LOG2E is export = log(e, 2);        # log₂(e)  
constant LN10 is export = log(10);           # ln(10)
constant LN2 is export = log(2);             # ln(2)
constant SQRT2 is export = sqrt(2);          # √2
constant SQRT1_2 is export = sqrt(0.5);      # √(1/2)

=begin pod
=head2 Trigonometric Functions
=end pod

# Sine function with error handling
sub BasicSin(Num $x) returns Num is export {
    return sin($x);
}

# Cosine function with error handling  
sub BasicCos(Num $x) returns Num is export {
    return cos($x);
}

# Tangent function with error handling
sub BasicTan(Num $x) returns Num is export {
    # Check for values where tan is undefined (π/2 + nπ)
    my $normalized = $x % PI;
    if abs($normalized - PI/2) < 1e-15 || abs($normalized + PI/2) < 1e-15 {
        die "Tangent undefined at x = $x";
    }
    return tan($x);
}

# Cotangent function
sub BasicCot(Num $x) returns Num is export {
    # Check for values where cot is undefined (nπ)
    if abs($x % PI) < 1e-15 {
        die "Cotangent undefined at x = $x";
    }
    return 1 / tan($x);
}

# Secant function
sub BasicSec(Num $x) returns Num is export {
    my $cos-val = cos($x);
    if abs($cos-val) < 1e-15 {
        die "Secant undefined at x = $x";
    }
    return 1 / $cos-val;
}

# Cosecant function
sub BasicCsc(Num $x) returns Num is export {
    my $sin-val = sin($x);
    if abs($sin-val) < 1e-15 {
        die "Cosecant undefined at x = $x";
    }
    return 1 / $sin-val;
}

=begin pod
=head2 Inverse Trigonometric Functions
=end pod

# Arcsine function with domain checking
sub BasicArcsin(Num $x) returns Num is export {
    if abs($x) > 1.0 {
        die "Arcsine domain error: |x| must be <= 1, got $x";
    }
    return asin($x);
}

# Arccosine function with domain checking
sub BasicArccos(Num $x) returns Num is export {
    if abs($x) > 1.0 {
        die "Arccosine domain error: |x| must be <= 1, got $x";
    }
    return acos($x);
}

# Arctangent function
sub BasicArctan(Num $x) returns Num is export {
    return atan($x);
}

# Two-argument arctangent function
sub BasicArctan2(Num $y, Num $x) returns Num is export {
    if $x == 0 && $y == 0 {
        die "Arctan2 undefined for (0, 0)";
    }
    return atan2($y, $x);
}

=begin pod
=head2 Hyperbolic Functions
=end pod

# Hyperbolic sine
sub BasicSinh(Num $x) returns Num is export {
    return sinh($x);
}

# Hyperbolic cosine
sub BasicCosh(Num $x) returns Num is export {
    return cosh($x);
}

# Hyperbolic tangent
sub BasicTanh(Num $x) returns Num is export {
    return tanh($x);
}

# Hyperbolic cotangent
sub BasicCoth(Num $x) returns Num is export {
    if abs($x) < 1e-15 {
        die "Hyperbolic cotangent undefined at x = 0";
    }
    return 1 / tanh($x);
}

# Hyperbolic secant
sub BasicSech(Num $x) returns Num is export {
    return 1 / cosh($x);
}

# Hyperbolic cosecant
sub BasicCsch(Num $x) returns Num is export {
    if abs($x) < 1e-15 {
        die "Hyperbolic cosecant undefined at x = 0";
    }
    return 1 / sinh($x);
}

=begin pod
=head2 Inverse Hyperbolic Functions
=end pod

# Inverse hyperbolic sine
sub BasicArcsinh(Num $x) returns Num is export {
    return asinh($x);
}

# Inverse hyperbolic cosine
sub BasicArccosh(Num $x) returns Num is export {
    if $x < 1.0 {
        die "Inverse hyperbolic cosine domain error: x must be >= 1, got $x";
    }
    return acosh($x);
}

# Inverse hyperbolic tangent
sub BasicArctanh(Num $x) returns Num is export {
    if abs($x) >= 1.0 {
        die "Inverse hyperbolic tangent domain error: |x| must be < 1, got $x";
    }
    return atanh($x);
}

=begin pod
=head2 Exponential and Logarithmic Functions
=end pod

# Natural exponential function
sub BasicExp(Num $x) returns Num is export {
    # Check for overflow
    if $x > 700 {
        die "Exponential overflow: x = $x too large";
    }
    if $x < -700 {
        return 0.0;  # Underflow to zero
    }
    return exp($x);
}

# Base-10 exponential function  
sub BasicExp10(Num $x) returns Num is export {
    return 10 ** $x;
}

# Base-2 exponential function
sub BasicExp2(Num $x) returns Num is export {
    return 2 ** $x;
}

# Natural logarithm
sub BasicLn(Num $x) returns Num is export {
    if $x <= 0 {
        die "Natural logarithm domain error: x must be > 0, got $x";
    }
    return log($x);
}

# Base-10 logarithm
sub BasicLog(Num $x) returns Num is export {
    if $x <= 0 {
        die "Logarithm domain error: x must be > 0, got $x";
    }
    return log10($x);
}

# Base-2 logarithm  
sub BasicLog2(Num $x) returns Num is export {
    if $x <= 0 {
        die "Base-2 logarithm domain error: x must be > 0, got $x";
    }
    return log($x, 2);
}

# Logarithm with arbitrary base
sub BasicLogBase(Num $x, Num $base) returns Num is export {
    if $x <= 0 {
        die "Logarithm domain error: x must be > 0, got $x";
    }
    if $base <= 0 || $base == 1 {
        die "Logarithm base error: base must be > 0 and ≠ 1, got $base";
    }
    return log($x) / log($base);
}

=begin pod
=head2 Power and Root Functions
=end pod

# Power function with special case handling
sub BasicPwr(Num $base, Num $exponent) returns Num is export {
    # Handle special cases
    if $base == 0 {
        if $exponent == 0 {
            die "0^0 is undefined";
        }
        if $exponent < 0 {
            die "0 raised to negative power is undefined";
        }
        return 0.0;
    }
    
    if $base < 0 && $exponent != $exponent.Int {
        die "Negative base with non-integer exponent is undefined in real arithmetic";
    }
    
    return $base ** $exponent;
}

# Square root with domain checking
sub BasicSqr(Num $x) returns Num is export {
    if $x < 0 {
        die "Square root domain error: x must be >= 0, got $x";
    }
    return sqrt($x);
}

# Cube root
sub BasicCbrt(Num $x) returns Num is export {
    if $x < 0 {
        return -((-$x) ** (1/3));
    } else {
        return $x ** (1/3);
    }
}

# nth root
sub BasicRoot(Num $x, Num $n) returns Num is export {
    if $n == 0 {
        die "Root index cannot be zero";
    }
    
    if $x == 0 {
        return 0.0;
    }
    
    if $x < 0 && $n.Int == $n && $n.Int %% 2 == 0 {
        die "Even root of negative number is undefined in real arithmetic";
    }
    
    if $x < 0 && $n.Int == $n && $n.Int %% 2 == 1 {
        return -((-$x) ** (1/$n));
    }
    
    return $x ** (1/$n);
}

=begin pod
=head2 Rounding and Truncation Functions
=end pod

# Round to nearest integer
sub BasicRound(Num $x) returns Int is export {
    return $x.round;
}

# Round to specified decimal places
sub BasicRoundTo(Num $x, Int $places) returns Num is export {
    my $factor = 10 ** $places;
    return ($x * $factor).round / $factor;
}

# Truncate towards zero
sub BasicTrunc(Num $x) returns Int is export {
    return $x.truncate;
}

# Floor function (largest integer ≤ x)
sub BasicFloor(Num $x) returns Int is export {
    return $x.floor;
}

# Ceiling function (smallest integer ≥ x)
sub BasicCeil(Num $x) returns Int is export {
    return $x.ceiling;
}

# Fractional part
sub BasicFrac(Num $x) returns Num is export {
    return $x - $x.truncate;
}

=begin pod
=head2 Sign and Absolute Value Functions
=end pod

# Sign function
sub BasicSign(Num $x) returns Int is export {
    return $x <=> 0;
}

# Absolute value
sub BasicAbs(Num $x) returns Num is export {
    return $x.abs;
}

=begin pod
=head2 Comparison and Utility Functions
=end pod

# Maximum of two numbers
sub BasicMax(Num $a, Num $b) returns Num is export {
    return max($a, $b);
}

# Minimum of two numbers  
sub BasicMin(Num $a, Num $b) returns Num is export {
    return min($a, $b);
}

# Remainder function (x mod y)
sub BasicMod(Num $x, Num $y) returns Num is export {
    if $y == 0 {
        die "Modulo by zero is undefined";
    }
    return $x % $y;
}

# Integer remainder
sub BasicRem(Int $x, Int $y) returns Int is export {
    if $y == 0 {
        die "Remainder by zero is undefined";
    }
    return $x % $y;
}

=begin pod
=head2 Random Number Functions
=end pod

# Random number generator state
my $rng-seed = 1;

# Set random seed
sub BasicRandomize(Int $seed = 0) is export {
    if $seed == 0 {
        $rng-seed = now.Int;
    } else {
        $rng-seed = $seed;
    }
    srand($rng-seed);
}

# Random number between 0 and 1
sub BasicRnd() returns Num is export {
    return rand;
}

# Random integer between min and max (inclusive)
sub BasicRandom(Int $min, Int $max) returns Int is export {
    if $min > $max {
        die "Random range error: min ($min) > max ($max)";
    }
    return $min + Int(rand * ($max - $min + 1));
}

=begin pod
=head2 Number Classification Functions
=end pod

# Check if number is infinite
sub isInfinite(Num $x) returns Bool is export {
    return $x.is-infinite;
}

# Check if number is NaN
sub isNaN(Num $x) returns Bool is export {
    return $x.is-nan;
}

# Check if number is finite
sub isFinite(Num $x) returns Bool is export {
    return $x.is-finite;
}

# Check if number is an integer
sub isInteger(Num $x) returns Bool is export {
    return $x == $x.Int;
}

=begin pod
=head2 Angle Conversion Functions
=end pod

# Convert degrees to radians
sub DegToRad(Num $degrees) returns Num is export {
    return $degrees * PI / 180;
}

# Convert radians to degrees
sub RadToDeg(Num $radians) returns Num is export {
    return $radians * 180 / PI;
}

=begin pod
=head2 Complex Number Support Functions
=end pod

# Calculate magnitude of complex number represented as (real, imaginary)
sub ComplexMagnitude(Num $real, Num $imag) returns Num is export {
    return sqrt($real * $real + $imag * $imag);
}

# Calculate phase angle of complex number
sub ComplexPhase(Num $real, Num $imag) returns Num is export {
    return atan2($imag, $real);
}

=begin pod
=head1 EXPORTS

All mathematical functions are exported for use in the True BASIC interpreter.

=head1 USAGE

    use Math2;
    
    my $sine = BasicSin(PI/2);           # 1.0
    my $log = BasicLn(E);                # 1.0  
    my $power = BasicPwr(2, 3);          # 8.0
    my $rounded = BasicRound(3.14159);   # 3

=end pod