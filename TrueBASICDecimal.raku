#!/usr/bin/env raku

=begin pod
=head1 TrueBASIC Decimal Interpreter

A comprehensive True BASIC interpreter translated from Decimal BASIC Pascal source code.
This interpreter supports the full True BASIC language including:

- Variables (numeric, string, complex, rational)  
- Arrays and matrices
- Control structures (IF, FOR, WHILE, DO-LOOP)
- Subroutines and functions
- Mathematical operations
- Built-in functions
- File I/O operations
- Graphics and plotting

Based on the Decimal BASIC implementation by SHIRAISHI Kazuo
Translated to Raku by AI Assistant for Jovan Trujillo
Arizona State University - Advanced Electronics and Photonics Center
January 2025

=end pod

use v6.d;
use lib 'lib';
use Base;
use Variable;
use Expression;
use Compiler;
use Statement;

# Main TrueBASIC interpreter class
class TrueBASICDecimalInterpreter is export {
    has BasicCompiler $.compiler .= new;
    has Bool $.debug = False;
    has Bool $.interactive = False;
    has Str $.current-file = '';
    has %.options = (
        precision => PrecisionNormal,
        angle-degrees => False,
        array-base => 1,
        character-byte => False
    );
    
    method new(Bool :$debug = False, Bool :$interactive = False) {
        my $self = self.bless: :$debug, :$interactive;
        $self.initialize-environment();
        return $self;
    }
    
    method initialize-environment() {
        # Set up global environment variables
        $PrecisionMode = %!options<precision>;
        $initialAngleDegrees = %!options<angle-degrees>;
        $initialOptionBase = %!options<array-base>;
        $initialCharacterByte = %!options<character-byte>;
        
        say "TrueBASIC Decimal Interpreter v1.0" if $!debug;
        say "Translated from Decimal BASIC Pascal source" if $!debug;
        say "Precision Mode: {%PrecisionText{%!options<precision>}}" if $!debug;
    }
    
    # Main entry point for file execution
    method run-file(Str $filename) {
        unless $filename.IO.e {
            say "Error: File '$filename' not found.";
            return False;
        }
        
        $!current-file = $filename;
        say "Loading program: $filename" if $!debug;
        
        try {
            # Load and compile the program
            $!compiler.load-program($filename);
            
            if $!compiler.compile() {
                say "Compilation successful." if $!debug;
                say "Running program..." if $!debug;
                
                # Execute the program
                $!compiler.run();
                return True;
            } else {
                say "Compilation failed.";
                return False;
            }
        }
        
        CATCH {
            when BasicException {
                say "BASIC Error: {$_.message}";
                say "Help Context: {$_.help-context}" if $_.help-context;
                return False;
            }
            when X::IO {
                say "I/O Error: {$_.message}";
                return False;
            }
            default {
                say "Unexpected error: {$_.message}";
                say $_.backtrace if $!debug;
                return False;
            }
        }
    }
    
    # Interactive REPL mode
    method repl() {
        say "TrueBASIC Decimal Interpreter - Interactive Mode";
        say "Type 'EXIT' to quit, 'HELP' for help";
        
        my $line-number = 10;
        my @program-lines;
        
        loop {
            print "BASIC> ";
            my $input = get().trim;
            
            last if $input.uc eq 'EXIT' || $input.uc eq 'QUIT';
            
            if $input.uc eq 'HELP' {
                self.show-help();
                next;
            }
            
            if $input.uc eq 'RUN' {
                self.run-interactive-program(@program-lines);
                next;
            }
            
            if $input.uc eq 'LIST' {
                self.list-program(@program-lines);
                next;
            }
            
            if $input.uc eq 'NEW' {
                @program-lines = ();
                say "Program cleared.";
                next;
            }
            
            if $input.uc.starts-with('LOAD ') {
                my $filename = $input.substr(5).trim;
                if self.load-interactive-program($filename, @program-lines) {
                    say "Program loaded from $filename";
                }
                next;
            }
            
            if $input.uc.starts-with('SAVE ') {
                my $filename = $input.substr(5).trim;
                if self.save-interactive-program($filename, @program-lines) {
                    say "Program saved to $filename";
                }
                next;
            }
            
            # Check if line starts with number (program line)
            if $input ~~ /^ \s* (\d+) \s+ (.*)/ {
                my $num = $0.Int;
                my $code = ~$1;
                @program-lines[$num] = $code;
                say "Line $num entered." if $!debug;
            }
            # Immediate execution
            elsif $input ne '' {
                self.execute-immediate($input);
            }
        }
        
        say "Goodbye!";
    }
    
    method execute-immediate(Str $command) {
        try {
            # Create a temporary compiler for immediate execution
            my $temp-compiler = BasicCompiler.new;
            my @temp-lines = ($command);
            
            # Write to temp file and compile
            my $temp-file = "temp_immediate.bas";
            spurt $temp-file, $command;
            
            $temp-compiler.load-program($temp-file);
            
            if $temp-compiler.compile() {
                $temp-compiler.run();
            }
            
            # Clean up
            unlink $temp-file if $temp-file.IO.e;
        }
        
        CATCH {
            when BasicException {
                say "Error: {$_.message}";
            }
            default {
                say "Error executing command: {$_.message}";
            }
        }
    }
    
    method run-interactive-program(@program-lines) {
        try {
            # Build program text from line numbers
            my $program-text = '';
            for @program-lines.kv -> $line-num, $code {
                next unless $code.defined;
                $program-text ~= "$line-num $code\n";
            }
            
            # Write to temp file and run
            my $temp-file = "temp_program.bas";
            spurt $temp-file, $program-text;
            
            my $temp-compiler = BasicCompiler.new;
            $temp-compiler.load-program($temp-file);
            
            if $temp-compiler.compile() {
                $temp-compiler.run();
            } else {
                say "Program contains errors.";
            }
            
            # Clean up
            unlink $temp-file if $temp-file.IO.e;
        }
        
        CATCH {
            default {
                say "Error running program: {$_.message}";
            }
        }
    }
    
    method list-program(@program-lines) {
        say "Current program:";
        for @program-lines.kv -> $line-num, $code {
            next unless $code.defined;
            say "$line-num $code";
        }
    }
    
    method load-interactive-program(Str $filename, @program-lines is rw) returns Bool {
        return False unless $filename.IO.e;
        
        try {
            @program-lines = ();
            for $filename.IO.lines -> $line {
                next if $line.trim eq '';
                
                if $line ~~ /^ \s* (\d+) \s+ (.*)/ {
                    my $num = $0.Int;
                    my $code = ~$1;
                    @program-lines[$num] = $code;
                }
            }
            return True;
        }
        
        CATCH {
            say "Error loading file: {$_.message}";
            return False;
        }
    }
    
    method save-interactive-program(Str $filename, @program-lines) returns Bool {
        try {
            my $fh = open $filename, :w;
            for @program-lines.kv -> $line-num, $code {
                next unless $code.defined;
                $fh.say: "$line-num $code";
            }
            $fh.close;
            return True;
        }
        
        CATCH {
            say "Error saving file: {$_.message}";
            return False;
        }
    }
    
    method show-help() {
        say q:to/EOF/;
        TrueBASIC Decimal Interpreter Commands:
        
        Program Entry:
          <number> <statement>  - Enter a program line
          
        Program Control:
          RUN     - Execute the current program
          LIST    - Display the current program
          NEW     - Clear the current program
          
        File Operations:
          LOAD filename - Load a program file
          SAVE filename - Save the current program
          
        Immediate Execution:
          <statement> - Execute a statement immediately
          
        System Commands:
          HELP    - Show this help
          EXIT    - Exit the interpreter
          
        Supported Statements:
          LET var = expression
          PRINT expression [, expression ...]
          INPUT variable
          INPUT "prompt"; variable  
          IF condition THEN statement
          FOR var = start TO end [STEP step]
          WHILE condition
          DO ... LOOP [WHILE/UNTIL condition]
          GOTO line_number
          DIM array_name(size)
          END
        
        Examples:
          10 LET X = 5
          20 PRINT "X ="; X
          30 END
          RUN
        EOF
    }
    
    # Set interpreter options
    method set-option(Str $option, $value) {
        given $option.lc {
            when 'precision' {
                %!options<precision> = $value;
                $PrecisionMode = $value;
            }
            when 'angle-degrees' {
                %!options<angle-degrees> = $value;
                $initialAngleDegrees = $value;
            }
            when 'array-base' {
                %!options<array-base> = $value;
                $initialOptionBase = $value;
            }
            when 'character-byte' {
                %!options<character-byte> = $value;
                $initialCharacterByte = $value;
            }
            when 'debug' {
                $!debug = $value;
            }
            default {
                say "Unknown option: $option";
            }
        }
    }
    
    # Get interpreter status
    method status() {
        say "TrueBASIC Decimal Interpreter Status:";
        say "  Current File: {$!current-file || 'None'}";
        say "  Debug Mode: {$!debug ?? 'On' !! 'Off'}";
        say "  Interactive Mode: {$!interactive ?? 'On' !! 'Off'}";
        say "  Precision: {%PrecisionText{%!options<precision>}}";
        say "  Angle Mode: {%!options<angle-degrees> ?? 'Degrees' !! 'Radians'}";
        say "  Array Base: %!options<array-base>";
        say "  Character Byte: {%!options<character-byte> ?? 'On' !! 'Off'}";
    }
}

# Main entry point
sub MAIN(
    Str $file?,                    #= BASIC program file to run
    Bool :$interactive = False,    #= Start in interactive mode
    Bool :$debug = False,          #= Enable debug output
    Str :$precision = 'normal',    #= Precision mode (normal, high, native, complex, rational)
    Bool :$degrees = False,        #= Use degrees for angles (default: radians)
    Int :$base = 1                #= Array base (0 or 1)
) {
    # Create interpreter instance
    my $interpreter = TrueBASICDecimalInterpreter.new(:$debug, :$interactive);
    
    # Set options
    my $prec = do given $precision.lc {
        when 'normal' { PrecisionNormal }
        when 'high' { PrecisionHigh }
        when 'native' { PrecisionNative }
        when 'complex' { PrecisionComplex }
        when 'rational' { PrecisionRational }
        default { PrecisionNormal }
    };
    
    $interpreter.set-option('precision', $prec);
    $interpreter.set-option('angle-degrees', $degrees);
    $interpreter.set-option('array-base', $base);
    
    # Run file or enter interactive mode
    if $file.defined {
        $interpreter.run-file($file);
    } elsif $interactive {
        $interpreter.repl();
    } else {
        say "TrueBASIC Decimal Interpreter";
        say "Usage:";
        say "  raku TrueBASICDecimal.raku <file.bas>     # Run a BASIC program";
        say "  raku TrueBASICDecimal.raku --interactive  # Interactive mode";
        say "  raku TrueBASICDecimal.raku --help         # Show help";
    }
}

=begin pod
=head1 NAME

TrueBASICDecimal - A True BASIC interpreter translated from Decimal BASIC

=head1 SYNOPSIS

    # Run a BASIC program file
    raku TrueBASICDecimal.raku examples/simple.bas
    
    # Interactive mode  
    raku TrueBASICDecimal.raku --interactive
    
    # Debug mode
    raku TrueBASICDecimal.raku --debug examples/test.bas
    
    # Different precision modes
    raku TrueBASICDecimal.raku --precision=complex program.bas

=head1 DESCRIPTION

This is a comprehensive True BASIC interpreter translated from the Decimal BASIC Pascal source code. It provides full compatibility with True BASIC programs including:

=item Variables and arrays
=item Control structures  
=item Mathematical functions
=item String operations
=item File I/O
=item Graphics capabilities
=item Subroutines and functions

=head1 OPTIONS

=item --interactive     Start in interactive REPL mode
=item --debug          Enable debug output
=item --precision=MODE Set precision mode (normal, high, native, complex, rational)  
=item --degrees        Use degrees for angle functions (default: radians)
=item --base=N         Set array base to 0 or 1 (default: 1)

=head1 AUTHOR

Translated from Pascal to Raku by AI Assistant
Based on Decimal BASIC by SHIRAISHI Kazuo
For Jovan Trujillo, Arizona State University

=end pod