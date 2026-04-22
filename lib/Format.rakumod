#!/usr/bin/env raku

=begin pod
=head1 Format Module

Translation of format.pas from Decimal BASIC to Raku
Contains number formatting functions for output formatting
in the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;
use Using;

=begin pod
=head2 Number Format Components

Numeric formatting system for True BASIC output.
=end pod

# Components of a number for formatting
class NumericComponents is export {
    has Str $.sign is rw = '+';
    has Int $.exponent is rw = 0;
    has Str $.digits is rw = '';
    
    method new-from-number(TBNumber $n) {
        my $value = $n.value.abs;
        my $sign = $n.value >= 0 ?? '+' !! '-';
        
        if $value == 0 {
            return self.new(sign => $sign, exponent => 0, digits => '0');
        }
        
        # Convert to scientific notation
        my $exp = $value.log10.floor.Int;
        my $mantissa = $value / (10 ** $exp);
        
        # Extract digits
        my $digits = '';
        my $work = $mantissa;
        
        # Generate enough digits for precision
        for 1..15 -> $i {
            my $digit = $work.Int;
            $digits ~= $digit;
            $work = ($work - $digit) * 10;
            last if $work < 1e-15;
        }
        
        return self.new(sign => $sign, exponent => $exp, digits => $digits);
    }
}

# Check if character is a literal (not a format specifier)
sub is-literal(Str $char) returns Bool is export {
    my @format-chars = <# $ % * + - . < > ^>;
    return $char ∉ @format-chars;
}

# Test if format string is valid
sub test-format-string(Str $format) returns Bool is export {
    try {
        parse-format-string($format);
        return True;
    }
    
    CATCH {
        default { return False; }
    }
}

# Parse format string into components
sub parse-format-string(Str $format) returns Hash is export {
    my $i = 0;
    my @chars = $format.comb;
    my %result = (
        floating-char1 => '',
        floating-char2 => '',
        digit-place => '#',
        int-places => 0,
        min-int-places => 0,
        fract-places => 0,
        exp-places => 0,
        use-comma => False,
        f-format => False,
        e-format => False,
    );
    
    if $format eq '' {
        die "Empty format string";
    }
    
    # Handle alignment characters
    if $i < @chars.elems && @chars[$i] ∈ ('<', '>') {
        if $i + 1 < @chars.elems && @chars[$i + 1] ∈ ('$', '+', '-', '#', '*', '%') {
            @chars[$i] = @chars[$i + 1];
        } else {
            @chars[$i] = '#';
        }
    }
    
    # Get floating characters
    if $i < @chars.elems && @chars[$i] ∈ ('+', '-', '$') {
        %result<floating-char1> = @chars[$i];
        $i++;
        
        # Skip repeated floating characters
        while $i < @chars.elems && @chars[$i] eq %result<floating-char1> {
            $i++;
        }
        
        # Check for second floating character
        if %result<floating-char1> eq '$' && $i < @chars.elems && @chars[$i] ∈ ('+', '-') ||
           $i < @chars.elems && @chars[$i] eq '$' {
            %result<floating-char2> = @chars[$i];
            $i++;
        }
    }
    
    # Get digit places for integer part
    if $i < @chars.elems && @chars[$i] ∈ ('#', '%', '*') {
        %result<digit-place> = @chars[$i];
        
        while $i < @chars.elems && @chars[$i] eq %result<digit-place> {
            %result<int-places>++;
            if %result<digit-place> ∈ ('%', '*') {
                %result<min-int-places>++;
            }
            $i++;
            
            # Check for comma separator
            if $i < @chars.elems && @chars[$i] eq ',' {
                $i++;
                %result<use-comma> = True;
            }
        }
    }
    
    # Check for decimal point and fractional part
    if $i < @chars.elems && @chars[$i] eq '.' {
        %result<f-format> = True;
        $i++;
        
        while $i < @chars.elems && @chars[$i] eq '#' {
            %result<fract-places>++;
            $i++;
        }
    }
    
    # Check for exponent part
    while $i < @chars.elems && @chars[$i] eq '^' {
        %result<e-format> = True;
        %result<exp-places>++;
        $i++;
    }
    
    return %result;
}

# Format a number using specified format string
sub format-number(TBNumber $number, Str $format) returns Str is export {
    my $components = NumericComponents.new-from-number($number);
    my %format-spec = parse-format-string($format);
    
    return format-numeric-components($components, %format-spec);
}

# Format numeric components according to format specification
sub format-numeric-components(NumericComponents $components, %format) returns Str is export {
    my $result = '';
    my $sign = $components.sign;
    my $exp = $components.exponent;
    my $digits = $components.digits;
    
    # Handle exponential format
    if %format<e-format> {
        return format-exponential($components, %format);
    }
    
    # Handle fixed-point format
    return format-fixed-point($components, %format);
}

# Format number in fixed-point notation
sub format-fixed-point(NumericComponents $components, %format) returns Str {
    my $result = '';
    my $digits = $components.digits;
    my $exp = $components.exponent;
    my $sign = $components.sign;
    
    # Calculate integer and fractional parts
    my $total-digits = $digits.chars;
    my $int-digits = $exp + 1;
    my $fract-digits = $total-digits - $int-digits;
    
    # Adjust for decimal places in format
    my $required-fract = %format<fract-places>;
    
    # Pad or truncate digits as needed
    my $int-part = '';
    my $fract-part = '';
    
    if $int-digits > 0 {
        $int-part = $digits.substr(0, min($int-digits, $total-digits));
        if $int-digits > $total-digits {
            $int-part ~= '0' x ($int-digits - $total-digits);
        }
        if $total-digits > $int-digits {
            $fract-part = $digits.substr($int-digits);
        }
    } else {
        $int-part = '0';
        $fract-part = '0' x (-$int-digits) ~ $digits;
    }
    
    # Format integer part with commas if needed
    $int-part = format-integer-with-commas($int-part, %format<use-comma>);
    
    # Handle field width
    my $field-width = %format<int-places>;
    if $field-width > 0 && $int-part.chars > $field-width {
        # Overflow - fill with asterisks
        return '*' x $field-width;
    }
    
    # Add floating characters and sign
    if %format<floating-char1> {
        $result ~= %format<floating-char1>;
    }
    if %format<floating-char2> {
        $result ~= %format<floating-char2>;
    }
    if $sign eq '-' || %format<floating-char1> eq '+' {
        $result ~= $sign eq '-' ?? '-' !! '+';
    }
    
    # Add padding for field width
    if $field-width > 0 {
        my $padding = $field-width - $int-part.chars;
        if $padding > 0 {
            $result ~= ' ' x $padding;
        }
    }
    
    $result ~= $int-part;
    
    # Add fractional part if needed
    if %format<f-format> {
        $result ~= '.';
        if $required-fract > 0 {
            # Pad or truncate fractional part
            if $fract-part.chars > $required-fract {
                $fract-part = $fract-part.substr(0, $required-fract);
            } else {
                $fract-part ~= '0' x ($required-fract - $fract-part.chars);
            }
            $result ~= $fract-part;
        }
    }
    
    return $result;
}

# Format number in exponential notation
sub format-exponential(NumericComponents $components, %format) returns Str {
    my $result = '';
    my $digits = $components.digits;
    my $exp = $components.exponent;
    my $sign = $components.sign;
    
    # Format mantissa
    my $mantissa = $digits.substr(0, 1);
    if %format<fract-places> > 0 {
        $mantissa ~= '.';
        my $fract = $digits.substr(1);
        if $fract.chars > %format<fract-places> {
            $fract = $fract.substr(0, %format<fract-places>);
        } else {
            $fract ~= '0' x (%format<fract-places> - $fract.chars);
        }
        $mantissa ~= $fract;
    }
    
    # Add sign
    if $sign eq '-' || %format<floating-char1> eq '+' {
        $result ~= $sign eq '-' ?? '-' !! '+';
    }
    
    $result ~= $mantissa;
    
    # Add exponent
    my $exp-char = %format<exp-places> >= 4 ?? 'E' !! '^';
    $result ~= $exp-char;
    $result ~= $exp >= 0 ?? '+' !! '-';
    $result ~= sprintf('%0*d', max(2, %format<exp-places> - 1), $exp.abs);
    
    return $result;
}

# Format integer part with comma separators
sub format-integer-with-commas(Str $int-str, Bool $use-commas) returns Str {
    return $int-str unless $use-commas;
    
    my @digits = $int-str.comb.reverse;
    my $result = '';
    
    for 0..^@digits.elems -> $i {
        if $i > 0 && $i %% 3 {
            $result = ',' ~ $result;
        }
        $result = @digits[$i] ~ $result;
    }
    
    return $result;
}

# Format string using format specification
sub format-string(Str $string, Str $format) returns Str is export {
    # String format parsing
    if $format ~~ /^ '<' (\d*) $/ {
        # Left align
        my $width = $0 ?? +$0 !! $string.chars;
        return $string.substr(0, $width).fmt("%-{$width}s");
    } elsif $format ~~ /^ '>' (\d*) $/ {
        # Right align  
        my $width = $0 ?? +$0 !! $string.chars;
        return $string.substr(0, $width).fmt("%{$width}s");
    } elsif $format ~~ /^ '\\' (\d*) '\\' $/ {
        # Field width
        my $width = $0 ?? +$0 !! $string.chars;
        return $string.substr(0, $width) ~ (' ' x max(0, $width - $string.chars));
    }
    
    return $string;
}

# Test format item validity
sub test-format-item(Str $format) is export {
    try {
        parse-format-string($format);
    }
    
    CATCH {
        default {
            die "Invalid format: $format";
        }
    }
}

=begin pod
=head2 Standard Format Patterns

Common format patterns used in True BASIC.
=end pod

# Standard number formats
my %standard-formats is export = (
    'integer' => '####',
    'decimal' => '####.##',
    'scientific' => '#.######^^^^',
    'currency' => '$####.##',
    'percentage' => '###.#%',
);

# Get standard format
sub get-standard-format(Str $name) returns Str is export {
    return %standard-formats{$name} // '####.####';
}

=begin pod
=head1 EXPORTS

All formatting functions and utilities are exported.

=head1 USAGE

    use Format;
    
    my $num = TBNumber.new(value => 123.456);
    
    # Format with specific pattern
    my $formatted = format-number($num, '####.##');  # "123.46"
    
    # Format with currency
    my $currency = format-number($num, '$###.##');   # "$123.46"
    
    # Format string
    my $str-formatted = format-string("Hello", ">10"); # "     Hello"

=end pod