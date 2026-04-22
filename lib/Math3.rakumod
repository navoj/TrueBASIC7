#!/usr/bin/env raku

=begin pod
=head1 Math3 Module

Translation of math3.pas from Decimal BASIC to Raku
Contains advanced mathematical functions including statistical functions,
number theory functions, and specialized mathematical operations for True BASIC.

Author: Translated from Pascal by AI Assistant  
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;
use Math2;

=begin pod
=head2 Factorial and Combinatorial Functions
=end pod

# Factorial function
sub BasicFactorial(Int $n where $n >= 0) returns Int is export {
    if $n > 170 {
        die "Factorial overflow: $n! is too large";
    }
    
    return [*] 1..$n || 1;
}

# Double factorial (n!!)
sub BasicDoubleFactorial(Int $n where $n >= -1) returns Int is export {
    if $n <= 1 {
        return 1;
    }
    
    my $result = 1;
    my $i = $n;
    while $i > 0 {
        $result *= $i;
        $i -= 2;
    }
    return $result;
}

# Binomial coefficient C(n,k)
sub BasicCombination(Int $n, Int $k) returns Int is export {
    if $k < 0 || $k > $n {
        return 0;
    }
    
    if $k > $n - $k {
        $k = $n - $k;  # Take advantage of symmetry
    }
    
    my $result = 1;
    for 1..$k -> $i {
        $result = $result * ($n - $i + 1) div $i;
    }
    
    return $result;
}

# Permutation P(n,k)
sub BasicPermutation(Int $n, Int $k) returns Int is export {
    if $k < 0 || $k > $n {
        return 0;
    }
    
    my $result = 1;
    for ($n - $k + 1)..$n -> $i {
        $result *= $i;
    }
    
    return $result;
}

=begin pod
=head2 Statistical Functions
=end pod

# Arithmetic mean of array
sub BasicMean(@values) returns Num is export {
    return 0 if @values.elems == 0;
    return @values.sum / @values.elems;
}

# Geometric mean of array
sub BasicGeometricMean(@values where { all(@values) > 0 }) returns Num is export {
    return 0 if @values.elems == 0;
    return (@values.map(*.log).sum / @values.elems).exp;
}

# Harmonic mean of array
sub BasicHarmonicMean(@values where { all(@values) > 0 }) returns Num is export {
    return 0 if @values.elems == 0;
    return @values.elems / @values.map({ 1 / $_ }).sum;
}

# Standard deviation (population)
sub BasicStandardDeviation(@values) returns Num is export {
    return 0 if @values.elems <= 1;
    
    my $mean = BasicMean(@values);
    my $variance = @values.map({ ($_ - $mean) ** 2 }).sum / @values.elems;
    return $variance.sqrt;
}

# Standard deviation (sample)
sub BasicSampleStandardDeviation(@values) returns Num is export {
    return 0 if @values.elems <= 1;
    
    my $mean = BasicMean(@values);
    my $variance = @values.map({ ($_ - $mean) ** 2 }).sum / (@values.elems - 1);
    return $variance.sqrt;
}

# Variance (population)
sub BasicVariance(@values) returns Num is export {
    return 0 if @values.elems <= 1;
    
    my $mean = BasicMean(@values);
    return @values.map({ ($_ - $mean) ** 2 }).sum / @values.elems;
}

# Variance (sample)
sub BasicSampleVariance(@values) returns Num is export {
    return 0 if @values.elems <= 1;
    
    my $mean = BasicMean(@values);
    return @values.map({ ($_ - $mean) ** 2 }).sum / (@values.elems - 1);
}

# Correlation coefficient
sub BasicCorrelation(@x, @y) returns Num is export {
    if @x.elems != @y.elems || @x.elems < 2 {
        die "Correlation requires equal-length arrays with at least 2 elements";
    }
    
    my $mean-x = BasicMean(@x);
    my $mean-y = BasicMean(@y);
    
    my $sum-xy = 0;
    my $sum-x2 = 0;
    my $sum-y2 = 0;
    
    for 0..^@x.elems -> $i {
        my $dx = @x[$i] - $mean-x;
        my $dy = @y[$i] - $mean-y;
        $sum-xy += $dx * $dy;
        $sum-x2 += $dx * $dx;
        $sum-y2 += $dy * $dy;
    }
    
    my $denom = ($sum-x2 * $sum-y2).sqrt;
    return $denom == 0 ?? 0 !! $sum-xy / $denom;
}

=begin pod
=head2 Special Mathematical Functions
=end pod

# Gamma function (approximation using Stirling's formula)
sub BasicGamma(Num $x where $x > 0) returns Num is export {
    # Use built-in implementation if available, otherwise approximation
    if $x.Int == $x && $x <= 20 {
        return BasicFactorial($x.Int - 1);
    }
    
    # Stirling's approximation for large values
    return (2 * PI / $x).sqrt * (($x / e) ** $x);
}

# Beta function B(x,y) = Γ(x)Γ(y)/Γ(x+y)
sub BasicBeta(Num $x where $x > 0, Num $y where $y > 0) returns Num is export {
    return BasicGamma($x) * BasicGamma($y) / BasicGamma($x + $y);
}

# Error function (approximation)
sub BasicErf(Num $x) returns Num is export {
    # Abramowitz and Stegun approximation
    my $a1 =  0.254829592;
    my $a2 = -0.284496736;
    my $a3 =  1.421413741;
    my $a4 = -1.453152027;
    my $a5 =  1.061405429;
    my $p  =  0.3275911;
    
    my $sign = $x < 0 ?? -1 !! 1;
    $x = $x.abs;
    
    my $t = 1.0 / (1.0 + $p * $x);
    my $y = 1.0 - (((($a5 * $t + $a4) * $t) + $a3) * $t + $a2) * $t + $a1) * $t * exp(-$x * $x);
    
    return $sign * $y;
}

# Complementary error function
sub BasicErfc(Num $x) returns Num is export {
    return 1.0 - BasicErf($x);
}

=begin pod
=head2 Number Theory Functions
=end pod

# Greatest Common Divisor
sub BasicGCD(Int $a, Int $b) returns Int is export {
    return gcd($a, $b);
}

# Least Common Multiple  
sub BasicLCM(Int $a, Int $b) returns Int is export {
    return lcm($a, $b);
}

# Test if number is prime
sub BasicIsPrime(Int $n where $n >= 2) returns Bool is export {
    return $n.is-prime;
}

# Next prime after n
sub BasicNextPrime(Int $n) returns Int is export {
    my $candidate = $n + 1;
    while !$candidate.is-prime {
        $candidate++;
    }
    return $candidate;
}

# Prime factorization
sub BasicPrimeFactors(Int $n where $n > 1) returns Array[Int] is export {
    my @factors;
    my $remaining = $n;
    my $divisor = 2;
    
    while $divisor * $divisor <= $remaining {
        while $remaining %% $divisor {
            @factors.push($divisor);
            $remaining div= $divisor;
        }
        $divisor = $divisor == 2 ?? 3 !! $divisor + 2;
    }
    
    if $remaining > 1 {
        @factors.push($remaining);
    }
    
    return @factors;
}

# Euler's totient function φ(n)
sub BasicEulerPhi(Int $n where $n > 0) returns Int is export {
    my @factors = BasicPrimeFactors($n);
    my %unique-factors = @factors.unique.map({ $_ => True });
    
    my $result = $n;
    for %unique-factors.keys -> $p {
        $result = $result * ($p - 1) div $p;
    }
    
    return $result;
}

=begin pod
=head2 Interpolation and Numerical Methods
=end pod

# Linear interpolation
sub BasicLinearInterpolate(Num $x0, Num $y0, Num $x1, Num $y1, Num $x) returns Num is export {
    if $x1 == $x0 {
        return $y0;
    }
    return $y0 + ($y1 - $y0) * ($x - $x0) / ($x1 - $x0);
}

# Polynomial evaluation using Horner's method
sub BasicEvaluatePolynomial(@coefficients, Num $x) returns Num is export {
    my $result = 0;
    for @coefficients.reverse -> $coeff {
        $result = $result * $x + $coeff;
    }
    return $result;
}

# Newton's method for finding roots
sub BasicNewtonsMethod(&f, &df, Num $initial-guess, 
                      Num $tolerance = 1e-10, Int $max-iterations = 100) returns Num is export {
    my $x = $initial-guess;
    
    for 1..$max-iterations -> $iteration {
        my $fx = f($x);
        my $dfx = df($x);
        
        if $dfx.abs < $tolerance {
            die "Newton's method: derivative too small at x = $x";
        }
        
        my $new-x = $x - $fx / $dfx;
        
        if ($new-x - $x).abs < $tolerance {
            return $new-x;
        }
        
        $x = $new-x;
    }
    
    die "Newton's method failed to converge in $max-iterations iterations";
}

=begin pod
=head2 Matrix Operations (Basic)
=end pod

# Matrix determinant (2x2)
sub BasicDeterminant2x2(@matrix where @matrix.elems == 2 && @matrix.all.elems == 2) returns Num is export {
    return @matrix[0][0] * @matrix[1][1] - @matrix[0][1] * @matrix[1][0];
}

# Matrix determinant (3x3)
sub BasicDeterminant3x3(@matrix where @matrix.elems == 3 && @matrix.all.elems == 3) returns Num is export {
    return @matrix[0][0] * (@matrix[1][1] * @matrix[2][2] - @matrix[1][2] * @matrix[2][1]) -
           @matrix[0][1] * (@matrix[1][0] * @matrix[2][2] - @matrix[1][2] * @matrix[2][0]) +
           @matrix[0][2] * (@matrix[1][0] * @matrix[2][1] - @matrix[1][1] * @matrix[2][0]);
}

=begin pod
=head2 Financial Mathematics
=end pod

# Present value calculation
sub BasicPresentValue(Num $future-value, Num $interest-rate, Int $periods) returns Num is export {
    if $interest-rate == 0 {
        return $future-value;
    }
    return $future-value / ((1 + $interest-rate) ** $periods);
}

# Future value calculation
sub BasicFutureValue(Num $present-value, Num $interest-rate, Int $periods) returns Num is export {
    return $present-value * ((1 + $interest-rate) ** $periods);
}

# Compound interest calculation
sub BasicCompoundInterest(Num $principal, Num $rate, Int $periods, Int $compounds-per-period = 1) returns Num is export {
    my $effective-rate = $rate / $compounds-per-period;
    my $total-compounds = $periods * $compounds-per-period;
    return $principal * ((1 + $effective-rate) ** $total-compounds);
}

=begin pod
=head2 Unit Conversions
=end pod

# Temperature conversions
sub CelsiusToFahrenheit(Num $celsius) returns Num is export {
    return $celsius * 9/5 + 32;
}

sub FahrenheitToCelsius(Num $fahrenheit) returns Num is export {
    return ($fahrenheit - 32) * 5/9;
}

sub CelsiusToKelvin(Num $celsius) returns Num is export {
    return $celsius + 273.15;
}

sub KelvinToCelsius(Num $kelvin) returns Num is export {
    return $kelvin - 273.15;
}

=begin pod
=head1 EXPORTS

All advanced mathematical functions are exported for use in the True BASIC interpreter.

=head1 USAGE

    use Math3;
    
    my $fact = BasicFactorial(5);                    # 120
    my $comb = BasicCombination(10, 3);             # 120
    my @data = (1, 2, 3, 4, 5);
    my $mean = BasicMean(@data);                     # 3.0
    my $std = BasicStandardDeviation(@data);         # ~1.58

=end pod