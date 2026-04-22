#!/usr/bin/env raku

=begin pod
=head1 Supplied Functions Module

Translation of supplied.pas from Decimal BASIC to Raku
Contains built-in functions for the True BASIC interpreter.
Implements standard mathematical and utility functions.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;
use Variable;
use Expression;
use Math2;
use Math3;
use Float;
use Rational;

=begin pod
=head2 Built-in Mathematical Functions

Standard True BASIC functions available to all programs.
=end pod

# ABS function - absolute value
class ABSFunction does UnaryFunction is export {
    method name() { "ABS" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value.abs);
    }
}

# CEIL function - ceiling (smallest integer >= x)
class CEILFunction does UnaryFunction is export {
    method name() { "CEIL" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value.ceiling);
    }
}

# EPS function - machine epsilon  
class EPSFunction does UnaryFunction is export {
    method name() { "EPS" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        # Machine epsilon for floating point precision
        return TBNumber.new(value => 2.220446049250313e-16);
    }
}

# FP function - fractional part
class FPFunction does UnaryFunction is export {
    method name() { "FP" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value - $n.value.Int);
    }
}

# INT function - integer part (truncate towards zero)
class INTFunction does UnaryFunction is export {
    method name() { "INT" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value.truncate);
    }
}

# IP function - integer part (same as INT)
class IPFunction does UnaryFunction is export {
    method name() { "IP" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value.Int);
    }
}

# MAX function - maximum of two values
class MAXFunction does BinaryFunction is export {
    method name() { "MAX" }
    method precedence() { 1003 }
    
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        return TBNumber.new(value => max($a.value, $b.value));
    }
}

# MIN function - minimum of two values
class MINFunction does BinaryFunction is export {
    method name() { "MIN" }
    method precedence() { 1003 }
    
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        return TBNumber.new(value => min($a.value, $b.value));
    }
}

# MOD function - modulo operation
class MODFunction does BinaryFunction is export {
    method name() { "MOD" }
    method precedence() { 3006 }
    
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        if $b.value == 0 {
            die "MOD: Division by zero";
        }
        return TBNumber.new(value => $a.value % $b.value);
    }
}

# REMAINDER function - IEEE remainder
class REMAINDERFunction does BinaryFunction is export {
    method name() { "REMAINDER" }
    method precedence() { 3006 }
    
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        if $b.value == 0 {
            die "REMAINDER: Division by zero";
        }
        return TBNumber.new(value => $a.value - $b.value * ($a.value / $b.value).Int);
    }
}

# ROUND function - can be unary or binary
class ROUNDFunction is export {
    method name() { "ROUND" }
    method precedence() { 1002 }
    
    # Single argument version - round to nearest integer
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => $n.value.round);
    }
    
    # Two argument version - round to specified decimal places
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        my $places = $b.value.Int;
        my $factor = 10 ** $places;
        return TBNumber.new(value => ($a.value * $factor).round / $factor);
    }
}

# SGN function - sign of number  
class SGNFunction does UnaryFunction is export {
    method name() { "SGN" }
    method precedence() { 1002 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => ($n.value <=> 0).Int);
    }
}

# TRUNCATE function - truncate to specified decimal places
class TRUNCATEFunction does BinaryFunction is export {
    method name() { "TRUNCATE" }
    method precedence() { 1002 }
    
    method eval-numbers(TBNumber $a, TBNumber $b) returns TBNumber {
        my $places = $b.value.Int;
        my $factor = 10 ** $places;
        return TBNumber.new(value => ($a.value * $factor).Int / $factor);
    }
}

=begin pod
=head2 Extended Mathematical Functions
=end pod

# Permutation function P(n,r)
class PERMFunction does BinaryFunction is export {
    method name() { "PERM" }
    method precedence() { 1003 }
    
    method eval-numbers(TBNumber $n, TBNumber $r) returns TBNumber {
        my $n-val = $n.value.Int;
        my $r-val = $r.value.Int;
        
        if $r-val < 0 || $r-val > $n-val {
            die "PERM: Invalid arguments (r must be 0 <= r <= n)";
        }
        
        if $n-val != $n.value || $r-val != $r.value {
            die "PERM: Arguments must be integers";
        }
        
        return TBNumber.new(value => BasicPermutation($n-val, $r-val));
    }
}

# Combination function C(n,r)
class COMBFunction does BinaryFunction is export {
    method name() { "COMB" }
    method precedence() { 1003 }
    
    method eval-numbers(TBNumber $n, TBNumber $r) returns TBNumber {
        my $n-val = $n.value.Int;
        my $r-val = $r.value.Int;
        
        if $r-val < 0 || $r-val > $n-val {
            die "COMB: Invalid arguments (r must be 0 <= r <= n)";
        }
        
        if $n-val != $n.value || $r-val != $r.value {
            die "COMB: Arguments must be integers";
        }
        
        return TBNumber.new(value => BasicCombination($n-val, $r-val));
    }
}

# Factorial function
class FACTFunction does UnaryFunction is export {
    method name() { "FACT" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        my $n-val = $n.value.Int;
        
        if $n-val != $n.value || $n-val < 0 {
            die "FACT: Argument must be a non-negative integer";
        }
        
        return TBNumber.new(value => BasicFactorial($n-val));
    }
}

=begin pod
=head2 Trigonometric Functions
=end pod

# SIN function
class SINFunction does UnaryFunction is export {
    method name() { "SIN" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicSin($n.value));
    }
}

# COS function
class COSFunction does UnaryFunction is export {
    method name() { "COS" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicCos($n.value));
    }
}

# TAN function
class TANFunction does UnaryFunction is export {
    method name() { "TAN" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicTan($n.value));
    }
}

# ATN function (arctangent)
class ATNFunction does UnaryFunction is export {
    method name() { "ATN" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicArctan($n.value));
    }
}

# ASIN function (arcsine)
class ASINFunction does UnaryFunction is export {
    method name() { "ASIN" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicArcsin($n.value));
    }
}

# ACOS function (arccosine)
class ACOSFunction does UnaryFunction is export {
    method name() { "ACOS" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicArccos($n.value));
    }
}

=begin pod
=head2 Exponential and Logarithmic Functions
=end pod

# EXP function
class EXPFunction does UnaryFunction is export {
    method name() { "EXP" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicExp($n.value));
    }
}

# LOG function (natural logarithm)
class LOGFunction does UnaryFunction is export {
    method name() { "LOG" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicLn($n.value));
    }
}

# LOG10 function
class LOG10Function does UnaryFunction is export {
    method name() { "LOG10" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicLog($n.value));
    }
}

# SQR function (square root)
class SQRFunction does UnaryFunction is export {
    method name() { "SQR" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => BasicSqr($n.value));
    }
}

=begin pod
=head2 Random Number Functions
=end pod

# RND function - random number between 0 and 1
class RNDFunction is export {
    method name() { "RND" }
    method precedence() { 1003 }
    
    method eval() returns TBNumber {
        return TBNumber.new(value => BasicRnd());
    }
}

# RANDOMIZE procedure - seed random number generator
class RANDOMIZEProcedure is export {
    method name() { "RANDOMIZE" }
    
    method execute($seed = 0) {
        BasicRandomize($seed.Int);
    }
}

=begin pod
=head2 Character and String Functions (Character codes)
=end pod

# ORD function - ASCII code of character
class ORDFunction does UnaryFunction is export {
    method name() { "ORD" }
    method precedence() { 1003 }
    
    method eval-string(TBString $s) returns TBNumber {
        if $s.value.chars == 0 {
            die "ORD: Empty string";
        }
        return TBNumber.new(value => $s.value.substr(0, 1).ord);
    }
}

# CHR$ function - character from ASCII code
class CHRFunction does UnaryFunction is export {
    method name() { "CHR\$" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBString {
        my $code = $n.value.Int;
        if $code < 0 || $code > 255 {
            die "CHR\$: ASCII code out of range (0-255)";
        }
        return TBString.new(value => chr($code));
    }
}

=begin pod
=head2 Angle Conversion Functions
=end pod

# DEG function - convert radians to degrees
class DEGFunction does UnaryFunction is export {
    method name() { "DEG" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => RadToDeg($n.value));
    }
}

# RAD function - convert degrees to radians
class RADFunction does UnaryFunction is export {
    method name() { "RAD" }
    method precedence() { 1003 }
    
    method eval-number(TBNumber $n) returns TBNumber {
        return TBNumber.new(value => DegToRad($n.value));
    }
}

=begin pod
=head2 Function Registration System
=end pod

# Create function registry for built-in functions
my %builtin-functions is export = (
    # Basic math functions
    'ABS' => ABSFunction.new,
    'CEIL' => CEILFunction.new,
    'EPS' => EPSFunction.new,
    'FP' => FPFunction.new,
    'INT' => INTFunction.new,
    'IP' => IPFunction.new,
    'MAX' => MAXFunction.new,
    'MIN' => MINFunction.new,
    'MOD' => MODFunction.new,
    'REMAINDER' => REMAINDERFunction.new,
    'ROUND' => ROUNDFunction.new,
    'SGN' => SGNFunction.new,
    'TRUNCATE' => TRUNCATEFunction.new,
    
    # Extended math functions
    'PERM' => PERMFunction.new,
    'COMB' => COMBFunction.new,
    'FACT' => FACTFunction.new,
    
    # Trigonometric functions
    'SIN' => SINFunction.new,
    'COS' => COSFunction.new,
    'TAN' => TANFunction.new,
    'ATN' => ATNFunction.new,
    'ASIN' => ASINFunction.new,
    'ACOS' => ACOSFunction.new,
    
    # Exponential and logarithmic functions
    'EXP' => EXPFunction.new,
    'LOG' => LOGFunction.new,
    'LOG10' => LOG10Function.new,
    'SQR' => SQRFunction.new,
    
    # Random functions
    'RND' => RNDFunction.new,
    
    # Character functions
    'ORD' => ORDFunction.new,
    'CHR$' => CHRFunction.new,
    
    # Angle conversion functions
    'DEG' => DEGFunction.new,
    'RAD' => RADFunction.new,
);

# Get built-in function by name
sub get-builtin-function(Str $name) is export {
    return %builtin-functions{$name.uc};
}

# Check if function is built-in
sub is-builtin-function(Str $name) returns Bool is export {
    return %builtin-functions{$name.uc}:exists;
}

# Get list of all built-in function names
sub builtin-function-names() returns Array[Str] is export {
    return %builtin-functions.keys.sort;
}

# Function definition helper
sub define-function(Str $name, $function-obj) is export {
    %builtin-functions{$name.uc} = $function-obj;
}

=begin pod
=head2 Mathematical Constants

Standard mathematical constants available in expressions.
=end pod

my %builtin-constants is export = (
    'PI' => TBNumber.new(value => PI),
    'E' => TBNumber.new(value => E),
);

# Get built-in constant by name
sub get-builtin-constant(Str $name) is export {
    return %builtin-constants{$name.uc};
}

# Check if constant is built-in
sub is-builtin-constant(Str $name) returns Bool is export {
    return %builtin-constants{$name.uc}:exists;
}

=begin pod
=head1 EXPORTS

All built-in function classes and utility functions are exported.

=head1 USAGE

    use SuppliedFunctions;
    
    # Get a function
    my $abs-func = get-builtin-function('ABS');
    
    # Check if function exists
    if is-builtin-function('SIN') {
        say "SIN function is available";
    }
    
    # Evaluate function
    my $result = $abs-func.eval-number(TBNumber.new(value => -5)); # 5

=end pod