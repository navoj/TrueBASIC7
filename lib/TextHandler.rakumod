#!/usr/bin/env raku

=begin pod
=head1 TextHandler Module

Translation of texthand.pas from Decimal BASIC to Raku
Contains text handling and tokenization for the True BASIC interpreter.
Handles program text parsing, tokenization, and line management.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Base;

=begin pod
=head2 Token Types and Specifications
=end pod

enum TokenSpecification is export <
    Nrep        # Numeric representation  
    Nidf        # Numeric identifier
    Scon        # String constant
    Sidf        # String identifier
    relational  # Relational operator
    tail        # End of line/statement
    another     # Other token type
>;

# Character sets for parsing
my $plain-char = set('0'..'9', 'A'..'Z', 'a'..'z', '.', '+', '-');
my $unquoted-char = set(' ', '(', ')', '+', '-'..'9', '@'..chr(0x7E), chr(0x80)..chr(0xFF));

=begin pod
=head2 Text Buffer Management
=end pod

class TextBuffer is export {
    has @.lines is rw;
    has $.current-line-number is rw = 0;
    has $.current-position is rw = 0;
    
    method get-line(Int $line-num) returns Str {
        return @.lines[$line-num] // '';
    }
    
    method set-line(Int $line-num, Str $text) {
        while @.lines.elems <= $line-num {
            @.lines.push('');
        }
        @.lines[$line-num] = $text;
    }
    
    method insert-line(Int $line-num, Str $text) {
        @.lines.splice($line-num, 0, $text);
    }
    
    method delete-line(Int $line-num) {
        if $line-num < @.lines.elems {
            @.lines.splice($line-num, 1);
        }
    }
    
    method line-count() returns Int {
        return @.lines.elems;
    }
    
    method reset() {
        @.lines = ();
        $.current-line-number = 0;
        $.current-position = 0;
    }
}

my $text-buffer = TextBuffer.new;

=begin pod
=head2 Token State Management
=end pod

class TokenState is export {
    has Str $.prev-token is rw = '';
    has TokenSpecification $.prev-token-spec is rw = another;
    has Str $.token is rw = '';
    has Str $.token-string is rw = '';
    has TBNumber $.token-value is rw;
    has TokenSpecification $.token-spec is rw = another;
    has Str $.next-token is rw = '';
    has Str $.next-token-string is rw = '';
    has TBNumber $.next-token-value is rw;
    has TokenSpecification $.next-token-spec is rw = another;
    
    has $.line-number is rw = 0;
    has $.position is rw = 0;
    has $.current-line is rw = '';
    
    method reset() {
        $.prev-token = '';
        $.token = '';
        $.next-token = '';
        $.line-number = 0;
        $.position = 0;
        $.current-line = '';
    }
}

my $token-state = TokenState.new;

# Token save/restore functionality
class TokenSave is export {
    has Str $.line;
    has Int $.line-number;
    has Int $.line-number-2;
    has Int $.line-number-3;
    has Int $.position;
    has Int $.position-2;
    has Int $.position-3;
    has Str $.prev-token;
    has Str $.token;
    has Str $.token-string;
    has TBNumber $.token-value;
    has TokenSpecification $.token-spec;
    has Str $.next-token;
    has Str $.next-token-string;
    has TBNumber $.next-token-value;
    has TokenSpecification $.next-token-spec;
    has Int $.insert-count;
}

=begin pod
=head2 Tokenization Functions
=end pod

# Initialize identifier character recognition
sub init-identifier-char() is export {
    # Set up character classification
    # Raku handles Unicode natively
}

# Check if character is valid for identifiers
sub is-identifier-char(Str $char) returns Bool is export {
    return $char ~~ /<[A..Za..z0..9_]>/;
}

# Check if character is a digit
sub is-digit(Str $char) returns Bool is export {
    return $char ~~ /<[0..9]>/;
}

# Check if character is whitespace
sub is-whitespace(Str $char) returns Bool is export {
    return $char ~~ /\s/;
}

# Get next character from input
sub peek-char(Int $offset = 0) returns Str {
    my $pos = $token-state.position + $offset;
    my $line = $token-state.current-line;
    
    return $pos < $line.chars ?? $line.substr($pos, 1) !! '';
}

# Advance position by one character
sub advance-position() {
    if $token-state.position < $token-state.current-line.chars {
        $token-state.position++;
    }
}

# Skip whitespace characters
sub skip-whitespace() {
    while is-whitespace(peek-char()) {
        advance-position();
    }
}

# Read string constant (quoted string)
sub read-string-constant() returns Str {
    my $result = '';
    my $quote-char = peek-char();
    advance-position(); # Skip opening quote
    
    while peek-char() && peek-char() ne $quote-char {
        my $char = peek-char();
        if $char eq '\\' {
            # Handle escape sequences
            advance-position();
            my $escaped = peek-char();
            given $escaped {
                when 'n' { $result ~= "\n"; }
                when 't' { $result ~= "\t"; }
                when 'r' { $result ~= "\r"; }
                when '\\' { $result ~= "\\"; }
                when '"' { $result ~= '"'; }
                when "'" { $result ~= "'"; }
                default { $result ~= $escaped; }
            }
        } else {
            $result ~= $char;
        }
        advance-position();
    }
    
    if peek-char() eq $quote-char {
        advance-position(); # Skip closing quote
    } else {
        die "Unterminated string constant";
    }
    
    return $result;
}

# Read numeric constant
sub read-number() returns TBNumber {
    my $number-str = '';
    
    # Read integer part
    while is-digit(peek-char()) {
        $number-str ~= peek-char();
        advance-position();
    }
    
    # Read decimal part if present
    if peek-char() eq '.' && is-digit(peek-char(1)) {
        $number-str ~= peek-char();
        advance-position();
        
        while is-digit(peek-char()) {
            $number-str ~= peek-char();
            advance-position();
        }
    }
    
    # Read exponent part if present
    if peek-char().uc eq 'E' {
        $number-str ~= peek-char();
        advance-position();
        
        if peek-char() ∈ ('+', '-') {
            $number-str ~= peek-char();
            advance-position();
        }
        
        while is-digit(peek-char()) {
            $number-str ~= peek-char();
            advance-position();
        }
    }
    
    return TBNumber.new(value => +$number-str);
}

# Read identifier
sub read-identifier() returns Str {
    my $identifier = '';
    
    # First character must be letter or underscore
    if peek-char() ~~ /<[A..Za..z_]>/ {
        $identifier ~= peek-char();
        advance-position();
        
        # Subsequent characters can be letters, digits, or underscores
        while is-identifier-char(peek-char()) {
            $identifier ~= peek-char();
            advance-position();
        }
    }
    
    return $identifier;
}

# Read operator or special character
sub read-operator() returns Str {
    my $char = peek-char();
    my $next-char = peek-char(1);
    
    # Check for two-character operators
    given $char ~ $next-char {
        when '<=', '>=', '<>', '==', '!=' {
            advance-position();
            advance-position();
            return $char ~ $next-char;
        }
    }
    
    # Single character operator
    advance-position();
    return $char;
}

# Get the next token from input
sub get-token() is export {
    skip-whitespace();
    
    my $char = peek-char();
    
    if !$char {
        # End of line/input
        $token-state.token = '';
        $token-state.token-spec = tail;
        return;
    }
    
    # String constants
    if $char ∈ ('"', "'") {
        $token-state.token-string = read-string-constant();
        $token-state.token = $token-state.token-string;
        $token-state.token-spec = Scon;
        return;
    }
    
    # Numeric constants
    if is-digit($char) || ($char eq '.' && is-digit(peek-char(1))) {
        $token-state.token-value = read-number();
        $token-state.token = ~$token-state.token-value.value;
        $token-state.token-spec = Nrep;
        return;
    }
    
    # Identifiers
    if $char ~~ /<[A..Za..z_]>/ {
        $token-state.token = read-identifier();
        $token-state.token-spec = Nidf;  # May be changed to Sidf later if followed by $
        
        # Check for string identifier suffix
        if peek-char() eq '$' {
            $token-state.token ~= '$';
            advance-position();
            $token-state.token-spec = Sidf;
        }
        
        return;
    }
    
    # Relational operators
    if $char ∈ ('<', '>', '=', '!') {
        $token-state.token = read-operator();
        $token-state.token-spec = relational;
        return;
    }
    
    # Other operators and symbols
    $token-state.token = read-operator();
    $token-state.token-spec = another;
}

# Look ahead to next token without consuming it
sub peek-next-token() returns Str {
    my $save = save-token-state();
    get-token();
    my $next = $token-state.token;
    restore-token-state($save);
    return $next;
}

# Get the token after the next token
sub next-next-token() returns Str is export {
    my $save = save-token-state();
    get-token(); # Skip current
    get-token(); # Get next
    my $next-next = $token-state.token;
    restore-token-state($save);
    return $next-next;
}

=begin pod
=head2 Line Management Functions
=end pod

# Initialize line parsing
sub init-line() is export {
    $token-state.position = 0;
    $token-state.current-line = $text-buffer.get-line($token-state.line-number);
    $token-state.prev-token = '';
    $token-state.token = '';
    $token-state.next-token = '';
}

# Move to next line
sub next-line() is export {
    $token-state.line-number++;
    init-line();
}

# Move to next logical line (handling continuation)
sub next-line-global() is export {
    next-line();
    
    # Handle line continuation (if needed)
    while $token-state.current-line.ends-with('\\') {
        $token-state.current-line = $token-state.current-line.substr(0, *-1) ~
                                  $text-buffer.get-line($token-state.line-number + 1);
        $token-state.line-number++;
    }
}

# Skip to end of current line
sub skip-logical() is export {
    $token-state.position = $token-state.current-line.chars;
}

# Check if at end of input
sub out-of-text() returns Bool is export {
    return $token-state.line-number >= $text-buffer.line-count() &&
           $token-state.position >= $token-state.current-line.chars;
}

# Reset tokenizer state
sub reset-token1() is export {
    $token-state.reset();
}

# Get current data as string
sub datum() returns Str is export {
    return $token-state.current-line.substr($token-state.position);
}

=begin pod
=head2 Token State Save/Restore
=end pod

# Save current token state
sub save-token-state() returns TokenSave is export {
    return TokenSave.new(
        line => $token-state.current-line,
        line-number => $token-state.line-number,
        position => $token-state.position,
        prev-token => $token-state.prev-token,
        token => $token-state.token,
        token-string => $token-state.token-string,
        token-value => $token-state.token-value,
        token-spec => $token-state.token-spec,
        next-token => $token-state.next-token,
        next-token-string => $token-state.next-token-string,
        next-token-value => $token-state.next-token-value,
        next-token-spec => $token-state.next-token-spec,
    );
}

# Restore token state
sub restore-token-state(TokenSave $save) is export {
    $token-state.current-line = $save.line;
    $token-state.line-number = $save.line-number;
    $token-state.position = $save.position;
    $token-state.prev-token = $save.prev-token;
    $token-state.token = $save.token;
    $token-state.token-string = $save.token-string;
    $token-state.token-value = $save.token-value;
    $token-state.token-spec = $save.token-spec;
    $token-state.next-token = $save.next-token;
    $token-state.next-token-string = $save.next-token-string;
    $token-state.next-token-value = $save.next-token-value;
    $token-state.next-token-spec = $save.next-token-spec;
}

=begin pod
=head2 Text Buffer Access Functions
=end pod

# Get line from text buffer
sub get-memo-line(Int $line-num) returns Str is export {
    return $text-buffer.get-line($line-num);
}

# Set line in text buffer
sub set-memo-line(Int $line-num, Str $text) is export {
    $text-buffer.set-line($line-num, $text);
}

# Insert line in text buffer
sub insert-memo-line(Int $line-num, Str $text) is export {
    $text-buffer.insert-line($line-num, $text);
}

# Delete line from text buffer
sub delete-memo-line(Int $line-num) is export {
    $text-buffer.delete-line($line-num);
}

# Get number of lines in text buffer
sub memo-line-count() returns Int is export {
    return $text-buffer.line-count();
}

=begin pod
=head2 Utility Functions
=end pod

# Apply modifier to string (case conversion, etc.)
sub modifier(Str $s) returns Str is export {
    # Basic modifiers - can be extended
    return $s;
}

# Clean identifier name
sub identifier(Str $s) returns Str is export {
    return $s.trim;
}

# Check end of statement/line
sub check-tail() is export {
    skip-whitespace();
    if peek-char() eq '' {
        $token-state.token-spec = tail;
    }
}

# Skip current token
sub skip() is export {
    get-token();
}

=begin pod
=head2 Error Handling
=end pod

class SyntaxError is Exception is export {
    has Str $.message;
    has Int $.line-number;
    has Int $.position;
    
    method new(Str $message, Int $line-number = 0, Int $position = 0) {
        return self.bless(
            message => $message,
            line-number => $line-number,
            position => $position
        );
    }
}

# Set error on specific line
sub set-err-on-line(Int $line-num, Str $message, Int $help-code) is export {
    die SyntaxError.new($message, $line-num);
}

# Set error at current position
sub set-err(Str $message, Int $help-code) is export {
    die SyntaxError.new($message, $token-state.line-number, $token-state.position);
}

# Set general error
sub set-error(Str $message, Int $help-code) is export {
    die SyntaxError.new($message);
}

=begin pod
=head1 EXPORTS

All text handling functions and types are exported.

=head1 USAGE

    use TextHandler;
    
    # Set up text buffer
    set-memo-line(0, "PRINT 'Hello World'");
    
    # Initialize tokenization
    init-line();
    
    # Get tokens
    get-token();
    say $token-state.token;  # "PRINT"

=end pod