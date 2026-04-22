#!/usr/bin/env raku

=begin pod
=head1 IO Module

Translation of io.pas from Decimal BASIC to Raku
Contains I/O handling functionality, READ/INPUT statement processing,
and data input/output operations for the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;
use Variable;
use TextFile;
class IOError is BasicException is export {
    method new(Str $message) {
        self.bless(message => $message);
    }
}

class EndOfDataException is IOError is export {
    method new() {
        self.bless(message => "Out of DATA");
    }
}

class InputMismatchException is IOError is export {
    method new() {
        self.bless(message => "Input data type mismatch");
    }
}

# I/O exception classes
class ReadInput is export {
    has @.variable-list;
    has Int $.count = 0;
    has Int $.line-number = 0;
    has Bool $.continuation = False;
    has IOOptions $.options = ioNONE;
    has TextDevice $.device;
    
    method new(@variables, Int :$count, Int :$line-number = 0, 
               Bool :$continuation = False, IOOptions :$options = ioNONE,
               TextDevice :$device = $console) {
        self.bless(
            variable-list => @variables,
            count => $count,
            line-number => $line-number,
            continuation => $continuation,
            options => $options,
            device => $device
        );
    }
    
    method execute() {
        given $.device.rec-type() {
            when rcDISPLAY {
                self!regular-read();
            }
            when rcINTERNAL {
                self!internal-read();
            }
            when rcCSV {
                self!csv-read();
            }
            default {
                self!regular-read();
            }
        }
    }
    
    # Regular READ operation
    method !regular-read() {
        my $device = $.device;
        
        try {
            $device.check-for-input($.options);
            
            my $result = $device.read-data(@.variable-list, $.count, $.continuation, $.options);
            unless $result {
                die EndOfDataException.new();
            }
        }
        
        CATCH {
            when InputMismatchException {
                # Handle input type mismatch
                say "? Redo from start" if $.device ~~ Console;
                .rethrow;
            }
            when EndOfDataException {
                say "Out of DATA in line {$.line-number}" if $.line-number > 0;
                .rethrow;
            }
            default {
                .rethrow;
            }
        }
    }
    
    # Internal format READ
    method !internal-read() {
        try {
            my $device = $.device;
            $device.check-for-input($.options);
            
            my $result = $device.read-data(@.variable-list, $.count, $.continuation, $.options);
            unless $result {
                die EndOfDataException.new();
            }
        }
        
        CATCH {
            default {
                .rethrow;
            }
        }
    }
    
    # CSV format READ
    method !csv-read() {
        self!internal-read(); # CSV uses internal format handling
    }
}

# Input handler class for INPUT statements
class Input is export {
    has @.variable-list;
    has Int $.count = 0;
    has Int $.line-number = 0;
    has Str $.prompt = '';
    has Num $.time-limit = 0e0;
    has IOOptions $.options = ioNONE;
    has TextDevice $.device;
    
    method new(@variables, Int :$count, Int :$line-number = 0,
               Str :$prompt = '', Num :$time-limit = 0e0,
               IOOptions :$options = ioNONE, 
               TextDevice :$device = $console) {
        self.bless(
            variable-list => @variables,
            count => $count,
            line-number => $line-number,
            prompt => $prompt,
            time-limit => $time-limit,
            options => $options,
            device => $device
        );
    }
    
    method execute() {
        given $.device.rec-type() {
            when rcDISPLAY {
                self!regular-input();
            }
            when rcINTERNAL {
                self!internal-input();
            }
            when rcCSV {
                self!csv-input();
            }
            default {
                self!regular-input();
            }
        }
    }
    
    # Regular INPUT operation
    method !regular-input() {
        my $device = $.device;
        
        try {
            $device.check-for-input($.options);
            $device.init-input($.line-number, $.prompt, $.time-limit);
            
            my $result = $device.input-data(@.variable-list, $.count, False, $.options);
            unless $result {
                die IOError.new("Input operation failed");
            }
        }
        
        CATCH {
            when InputMismatchException {
                say "? Redo from start" if $.device ~~ Console;
                .rethrow;
            }
            default {
                .rethrow;
            }
        }
    }
    
    # Internal format INPUT
    method !internal-input() {
        try {
            my $device = $.device;
            $device.check-for-input($.options);
            
            my $result = $device.input-data(@.variable-list, $.count, False, $.options);
            unless $result {
                die IOError.new("Internal input operation failed");
            }
        }
        
        CATCH {
            default {
                .rethrow;
            }
        }
    }
    
    # CSV format INPUT
    method !csv-input() {
        self!internal-input(); # CSV uses internal format handling
    }
}

# Line input handler class
class LineInput is export {
    has @.variable-list;
    has Int $.count = 0;
    has Int $.line-number = 0;
    has Str $.prompt = '';
    has Num $.time-limit = 0e0;
    has IOOptions $.options = ioNONE;
    has TextDevice $.device;
    
    method new(@variables, Int :$count, Int :$line-number = 0,
               Str :$prompt = '', Num :$time-limit = 0e0,
               IOOptions :$options = ioNONE,
               TextDevice :$device = $console) {
        self.bless(
            variable-list => @variables,
            count => $count,
            line-number => $line-number,
            prompt => $prompt,
            time-limit => $time-limit,
            options => $options,
            device => $device
        );
    }
    
    method execute() {
        my $device = $.device;
        
        try {
            $device.check-for-input($.options);
            $device.init-input($.line-number, $.prompt, $.time-limit);
            
            $device.line-input(@.variable-list, $.count, $.options);
        }
        
        CATCH {
            default {
                .rethrow;
            }
        }
    }
}

# Character input handler
class CharacterInput is export {
    has Variable $.variable;
    has Int $.line-number = 0;
    has Str $.prompt = '';
    has Num $.time-limit = 0e0;
    has IOOptions $.options = ioNONE;
    has TextDevice $.device;
    
    method new(Variable $variable, Int :$line-number = 0,
               Str :$prompt = '', Num :$time-limit = 0e0,
               IOOptions :$options = ioNONE,
               TextDevice :$device = $console) {
        self.bless(
            variable => $variable,
            line-number => $line-number,
            prompt => $prompt,
            time-limit => $time-limit,
            options => $options,
            device => $device
        );
    }
    
    method execute() {
        my $device = $.device;
        
        try {
            $device.check-for-input($.options);
            $device.init-input($.line-number, $.prompt, $.time-limit);
            
            my Str $input-char;
            $device.character-input($input-char, $.options);
            
            # Store character in variable
            given $.variable {
                when SVari {
                    $.variable.set($input-char);
                }
                default {
                    die IOError.new("Character input requires string variable");
                }
            }
        }
        
        CATCH {
            default {
                .rethrow;
            }
        }
    }
}

# Variable length input handler
class VariableLengthInput is export {
    has @.variable-list;
    has Int $.count is rw = 0;
    has Int $.line-number = 0;
    has IOOptions $.options = ioNONE;
    has TextDevice $.device;
    
    method new(@variables, Int :$line-number = 0,
               IOOptions :$options = ioNONE,
               TextDevice :$device = $console) {
        self.bless(
            variable-list => @variables,
            line-number => $line-number,
            options => $options,
            device => $device
        );
    }
    
    method execute() {
        my $device = $.device;
        
        try {
            $device.check-for-input($.options);
            
            $device.input-vari-len(@.variable-list, $.count, $.options);
        }
        
        CATCH {
            default {
                .rethrow;
            }
        }
    }
}

# I/O utility functions

# Convert string to numeric value with type checking
sub string-to-number(Str $s, Variable $var) returns Any is export {
    try {
        given $var {
            when NVari {
                return +$s;
            }
            when FVari {
                return $s.Num;
            }
            when CVari {
                # Parse complex number "a+bi" or "a+b*i"
                my $complex-match = $s ~~ /^ (<[-+]>? \d+ ['.' \d+]?) \s* <[+\-]> \s* (\d+ ['.' \d+]?) \s* '*'? \s* i $/;
                if $complex-match {
                    return Complex.new($complex-match[0].Num, $complex-match[1].Num);
                } else {
                    return Complex.new($s.Num, 0);
                }
            }
            when SVari {
                return $s;
            }
            default {
                die InputMismatchException.new();
            }
        }
    }
    
    CATCH {
        default {
            die InputMismatchException.new();
        }
    }
}

# Check if string represents a valid number for the given variable type
sub is-valid-number(Str $s, Variable $var) returns Bool is export {
    try {
        string-to-number($s, $var);
        return True;
    }
    
    CATCH {
        default {
            return False;
        }
    }
}

# Parse input line into individual items
sub parse-input-line(Str $line, Bool $csv = False) returns Array is export {
    my @items;
    my Str $current = '';
    my Bool $in-quotes = False;
    my Bool $escaped = False;
    
    for $line.comb -> $char {
        if $escaped {
            $current ~= $char;
            $escaped = False;
        } elsif $char eq '\\' && $in-quotes {
            $escaped = True;
        } elsif $char eq '"' {
            if $in-quotes {
                $in-quotes = False;
                @items.push: $current;
                $current = '';
            } else {
                $in-quotes = True;
            }
        } elsif !$in-quotes && ($char eq ',' || (!$csv && $char eq ' ')) {
            if $current.chars > 0 {
                @items.push: $current.trim;
                $current = '';
            }
        } else {
            $current ~= $char;
        }
    }
    
    if $current.chars > 0 {
        @items.push: $current.trim;
    }
    
    return @items;
}

# Format output value for display
sub format-output-value(Any $value, Variable $var) returns Str is export {
    given $var {
        when NVari {
            return ~$value.Int;
        }
        when FVari {
            # Format with appropriate decimal places
            if $value == $value.Int {
                return ~$value.Int;
            } else {
                return sprintf("%.6g", $value);
            }
        }
        when CVari {
            my Complex $c = $value;
            if $c.im == 0 {
                return ~$c.re;
            } elsif $c.re == 0 {
                return $c.im ~ "i";
            } elsif $c.im > 0 {
                return $c.re ~ "+" ~ $c.im ~ "i";
            } else {
                return $c.re ~ $c.im ~ "i";
            }
        }
        when SVari {
            return ~$value;
        }
        default {
            return ~$value;
        }
    }
}

# Global I/O device registry
our %io-devices is export;

# Initialize standard devices
INIT {
    %io-devices<console> = Console.new;
    %io-devices<console>.open('', amOUTIN, orgSEQ, 0);
}

# Device management functions
sub register-device(Str $name, TextDevice $device) is export {
    %io-devices{$name} = $device;
}

sub get-device(Str $name) returns TextDevice is export {
    return %io-devices{$name} // $console;
}

sub close-all-devices() is export {
    for %io-devices.values -> $device {
        $device.close() if $device.is-open;
    }
}

=begin pod
=head1 CLASSES

=head2 ReadInput
Handles READ statements for reading data from DATA statements or files.

=head2 Input
Handles INPUT statements for interactive user input.

=head2 LineInput
Handles LINE INPUT statements for reading entire lines.

=head2 CharacterInput
Handles single character input operations.

=head2 VariableLengthInput
Handles variable-length input operations.

=head1 FUNCTIONS

=head2 string-to-number($string, $variable)
Converts a string to the appropriate numeric type based on the variable type.

=head2 is-valid-number($string, $variable)
Checks if a string can be converted to a valid number for the given variable.

=head2 parse-input-line($line, $csv?)
Parses an input line into individual data items, handling quotes and separators.

=head2 format-output-value($value, $variable)
Formats a value for output based on the variable type.

=head2 register-device($name, $device)
Registers an I/O device with the given name.

=head2 get-device($name)
Retrieves a registered I/O device by name.

=head2 close-all-devices()
Closes all registered I/O devices.

=head1 GLOBAL VARIABLES

=item %io-devices - Registry of all I/O devices

=head1 EXCEPTIONS

=head2 IOError
Base class for I/O-related exceptions.

=head2 EndOfDataException
Thrown when READ statement runs out of data.

=head2 InputMismatchException
Thrown when input data doesn't match expected variable type.

=end pod