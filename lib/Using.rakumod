#!/usr/bin/env raku

=begin pod
=head1 Using Module

Translation of using.pas from Decimal BASIC to Raku
Contains USING statement formatting functions for numeric output formatting
in the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;

=begin pod
=head2 Using Statement Format Implementation

Implements True BASIC's USING statement formatting capabilities.
=end pod

# Format character classification
enum FormatChar is export <
    FormatDigit      # # - digit position
    FormatDecimal    # . - decimal point
    FormatComma      # , - thousands separator  
    FormatPlus       # + - show sign always
    FormatMinus      # - - show negative sign only
    FormatDollar     # $ - currency symbol
    FormatPercent    # % - percentage
    FormatExponent   # ^^^^ - scientific notation
    FormatLiteral    # literal character
>;

# Using format descriptor
class UsingFormat is export {
    has Str $.pattern is rw;
    has Int $.total-width is rw = 0;
    has Int $.decimal-places is rw = 0;
    has Bool $.show-sign is rw = False;
    has Bool $.show-plus is rw = False;
    has Bool $.use-commas is rw = False;
    has Bool $.use-dollar is rw = False;
    has Bool $.use-percent is rw = False;
    has Bool $.use-exponential is rw = False;
    has Int $.exponent-width is rw = 0;
    has Str @.prefix;
    has Str @.suffix;
}

# Parse USING format string
sub parseUsingFormat(Str $format) returns UsingFormat is export {
    my $using = UsingFormat.new(pattern => $format);
    
    my @chars = $format.comb;
    my $in-numeric = False;
    my $decimal-seen = False;
    my $i = 0;
    
    while $i < @chars.elems {
        my $char = @chars[$i];
        
        given $char {
            when '#' {
                $in-numeric = True;
                if $decimal-seen {
                    $using.decimal-places++;
                }
                $using.total-width++;
            }
            
            when '.' {
                if $in-numeric && !$decimal-seen {
                    $decimal-seen = True;
                    $using.total-width++;
                } else {
                    if !$in-numeric {
                        $using.prefix.push($char);
                    } else {
                        $using.suffix.push($char);
                    }
                }
            }
            
            when ',' {
                if $in-numeric && !$decimal-seen {
                    $using.use-commas = True;
                    $using.total-width++;
                } else {
                    if !$in-numeric {
                        $using.prefix.push($char);
                    } else {
                        $using.suffix.push($char);
                    }
                }
            }
            
            when '+' {
                if $in-numeric {
                    $using.show-sign = True;
                    $using.show-plus = True;
                    $using.total-width++;
                } else {
                    $using.prefix.push($char);
                }
            }
            
            when '-' {
                if $in-numeric {
                    $using.show-sign = True;
                    $using.total-width++;
                } else {
                    $using.prefix.push($char);
                }
            }
            
            when '$' {
                if $in-numeric || ($i + 1 < @chars.elems && @chars[$i + 1] eq '#') {
                    $using.use-dollar = True;
                    $using.total-width++;
                } else {
                    $using.prefix.push($char);
                }
            }
            
            when '%' {
                if $in-numeric {
                    $using.use-percent = True;
                    $using.total-width++;
                } else {
                    $using.suffix.push($char);
                }
            }
            
            when '^' {
                if $in-numeric && $i + 3 < @chars.elems && 
                   @chars[$i + 1] eq '^' && @chars[$i + 2] eq '^' && @chars[$i + 3] eq '^' {
                    $using.use-exponential = True;
                    $using.exponent-width = 4;
                    $using.total-width += 4;
                    $i += 3;  # Skip the next 3 '^' characters
                } else {
                    if !$in-numeric {
                        $using.prefix.push($char);
                    } else {
                        $using.suffix.push($char);
                    }
                }
            }
            
            default {
                if !$in-numeric {
                    $using.prefix.push($char);
                } else {
                    $using.suffix.push($char);
                }
            }
        }
        
        $i++;
    }
    
    return $using;
}

# Format number using USING specification
sub formatNumberUsing(Num $number, UsingFormat $format) returns Str is export {
    my $result = "";
    my $work-number = $number;
    
    # Handle percentage
    if $format.use-percent {
        $work-number *= 100;
    }
    
    # Handle exponential notation
    if $format.use-exponential {
        return formatExponential($work-number, $format);
    }
    
    # Handle regular formatting
    return formatFixed($work-number, $format);
}

# Format number in fixed-point notation
sub formatFixed(Num $number, UsingFormat $format) returns Str is export {
    my $result = "";
    my $work-number = $number;
    my $is-negative = $work-number < 0;
    $work-number = $work-number.abs;
    
    # Add prefix
    $result ~= $format.prefix.join("");
    
    # Determine field widths
    my $integer-places = $format.total-width - $format.decimal-places;
    if $format.decimal-places > 0 {
        $integer-places--;  # Account for decimal point
    }
    if $format.show-sign {
        $integer-places--;  # Account for sign
    }
    if $format.use-dollar {
        $integer-places--;  # Account for dollar sign
    }
    
    # Round to specified decimal places
    my $rounded = $format.decimal-places > 0 ?? 
                  ($work-number * (10 ** $format.decimal-places)).round / (10 ** $format.decimal-places) !!
                  $work-number.round;
    
    # Split into integer and fractional parts
    my $integer-part = $rounded.Int;
    my $fractional-part = $rounded - $integer-part;
    
    # Format integer part with commas if requested
    my $integer-str = formatIntegerPart($integer-part, $integer-places, $format.use-commas);
    
    # Handle field overflow
    if $integer-str.chars > $integer-places {
        return "*" x $format.total-width;  # Overflow indicator
    }
    
    # Add dollar sign
    if $format.use-dollar {
        if $integer-str.chars < $integer-places {
            $integer-str = '$' ~ ' ' x ($integer-places - $integer-str.chars - 1) ~ $integer-str;
        } else {
            $integer-str = '$' ~ $integer-str;
        }
    } else {
        $integer-str = ' ' x ($integer-places - $integer-str.chars) ~ $integer-str;
    }
    
    # Add sign
    if $format.show-sign {
        if $is-negative {
            $result ~= '-';
        } elsif $format.show-plus {
            $result ~= '+';
        } else {
            $result ~= ' ';
        }
    } elsif $is-negative && !$format.use-dollar {
        # Insert negative sign before the number
        $result ~= '-';
    }
    
    # Add integer part
    $result ~= $integer-str;
    
    # Add decimal point and fractional part
    if $format.decimal-places > 0 {
        $result ~= '.';
        my $frac-str = formatFractionalPart($fractional-part, $format.decimal-places);
        $result ~= $frac-str;
    }
    
    # Add percentage sign
    if $format.use-percent {
        $result ~= '%';
    }
    
    # Add suffix
    $result ~= $format.suffix.join("");
    
    return $result;
}

# Format number in exponential notation
sub formatExponential(Num $number, UsingFormat $format) returns Str is export {
    my $result = "";
    my $work-number = $number;
    my $is-negative = $work-number < 0;
    $work-number = $work-number.abs;
    
    # Handle zero specially
    if $work-number == 0 {
        return formatFixed(0, $format) ~ "E+00";
    }
    
    # Calculate exponent
    my $exponent = $work-number.log10.floor.Int;
    my $mantissa = $work-number / (10 ** $exponent);
    
    # Adjust mantissa to be between 1 and 10
    if $mantissa >= 10 {
        $mantissa /= 10;
        $exponent++;
    } elsif $mantissa < 1 {
        $mantissa *= 10;
        $exponent--;
    }
    
    # Format mantissa using modified format
    my $mantissa-format = UsingFormat.new(
        total-width => $format.total-width - $format.exponent-width,
        decimal-places => $format.decimal-places,
        show-sign => $format.show-sign,
        show-plus => $format.show-plus,
        use-commas => False,  # No commas in exponential notation
        use-dollar => $format.use-dollar,
        use-percent => False,  # No percent in exponential notation
        prefix => $format.prefix,
        suffix => []
    );
    
    $result ~= formatFixed($is-negative ?? -$mantissa !! $mantissa, $mantissa-format);
    
    # Format exponent
    my $exp-sign = $exponent >= 0 ?? '+' !! '-';
    my $exp-value = $exponent.abs;
    $result ~= "E{$exp-sign}{sprintf('%02d', $exp-value)}";
    
    # Add suffix
    $result ~= $format.suffix.join("");
    
    return $result;
}

# Format integer part with optional commas
sub formatIntegerPart(Int $integer, Int $width, Bool $use-commas) returns Str {
    my $str = ~$integer;
    
    if $use-commas && $str.chars > 3 {
        my @digits = $str.comb.reverse;
        my $formatted = "";
        
        for 0..^@digits.elems -> $i {
            if $i > 0 && $i %% 3 {
                $formatted = "," ~ $formatted;
            }
            $formatted = @digits[$i] ~ $formatted;
        }
        
        return $formatted;
    }
    
    return $str;
}

# Format fractional part to specified number of places
sub formatFractionalPart(Num $fraction, Int $places) returns Str {
    my $rounded = ($fraction * (10 ** $places)).round.Int;
    my $str = sprintf("%0{$places}d", $rounded);
    return $str;
}

# Format string using USING specification
sub formatStringUsing(Str $string, Str $format-spec) returns Str is export {
    # String format: \n\ where n is field width (optional)
    if $format-spec ~~ /^ '\\' (\d*) '\\' $/ {
        my $width = $0 ?? +$0 !! $string.chars;
        
        if $string.chars > $width {
            return $string.substr(0, $width);
        } else {
            return $string ~ ' ' x ($width - $string.chars);
        }
    }
    
    # Left-align format: < followed by field specifier
    if $format-spec.starts-with('<') {
        my $rest = $format-spec.substr(1);
        if $rest ~~ /^ (\d+) $/ {
            my $width = +$0;
            return $string.substr(0, $width).fmt("%-{$width}s");
        }
    }
    
    # Right-align format: > followed by field specifier  
    if $format-spec.starts-with('>') {
        my $rest = $format-spec.substr(1);
        if $rest ~~ /^ (\d+) $/ {
            my $width = +$0;
            return $string.substr(0, $width).fmt("%{$width}s");
        }
    }
    
    # Default: return string as-is
    return $string;
}

# Main USING formatting function
sub BasicUsing(Str $format-string, *@values) returns Str is export {
    my @format-specs = parseUsingFormatString($format-string);
    my $result = "";
    my $value-index = 0;
    
    for @format-specs -> $spec {
        if $spec<type> eq 'literal' {
            $result ~= $spec<value>;
        } elsif $spec<type> eq 'numeric' {
            if $value-index < @values.elems {
                my $format = parseUsingFormat($spec<format>);
                $result ~= formatNumberUsing(@values[$value-index], $format);
                $value-index++;
            }
        } elsif $spec<type> eq 'string' {
            if $value-index < @values.elems {
                $result ~= formatStringUsing(~@values[$value-index], $spec<format>);
                $value-index++;
            }
        }
    }
    
    return $result;
}

# Parse complete USING format string into components
sub parseUsingFormatString(Str $format-string) {
    my @specs;
    my $i = 0;
    my @chars = $format-string.comb;
    
    while $i < @chars.elems {
        my $char = @chars[$i];
        
        if $char eq '"' {
            # String literal
            $i++; # Skip opening quote
            my $literal = "";
            while $i < @chars.elems && @chars[$i] ne '"' {
                $literal ~= @chars[$i];
                $i++;
            }
            $i++; # Skip closing quote
            @specs.push({ type => 'literal', value => $literal });
        } elsif $char eq '\\' {
            # String format
            my $format = "\\";
            $i++; # Skip opening backslash
            while $i < @chars.elems && @chars[$i] ne '\\' {
                $format ~= @chars[$i];
                $i++;
            }
            if $i < @chars.elems {
                $format ~= @chars[$i]; # Add closing backslash
                $i++;
            }
            @specs.push({ type => 'string', format => $format });
        } elsif $char eq '#' || $char eq '$' || $char eq '+' || $char eq '-' {
            # Numeric format
            my $format = "";
            while $i < @chars.elems && (@chars[$i] ~~ /<[#.,+\-$%^]>/) {
                $format ~= @chars[$i];
                $i++;
            }
            @specs.push({ type => 'numeric', format => $format });
        } else {
            # Other literal character
            @specs.push({ type => 'literal', value => $char });
            $i++;
        }
    }
    
    return @specs;
}

=begin pod
=head1 EXPORTS

All USING statement formatting functions are exported.

=head1 USAGE

    use Using;
    
    # Format numbers with USING
    my $formatted = BasicUsing("$###.##", 123.456);     # "$123.46"
    my $formatted2 = BasicUsing("+####.####", -12.5);   # " -12.5000"
    
    # Format strings
    my $formatted3 = BasicUsing("\\10\\", "Hello");     # "Hello     "

=end pod