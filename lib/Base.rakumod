#!/usr/bin/env raku

=begin pod
=head1 Base Module

Translation of base.pas from Decimal BASIC to Raku
Contains fundamental classes, enums, and utility functions
for the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;

# Precision modes corresponding to Pascal tpPrecision
enum Precision is export <PrecisionNormal PrecisionHigh PrecisionNative PrecisionComplex PrecisionRational>;

# IO Options corresponding to Pascal IOOption
enum IOOption is export <ioReadWrite ioCharacterByte ioSkipRest ioWhenInside ioClear ioNoWait>;

# Record setter types
enum RecordSetter is export <rsNone rsBEGIN rsEND rsNEXT rsSAME>;

# Access modes for file operations
enum AccessMode is export <amOUTIN amINPUT amOUTPUT>;

# Record types for file operations
enum RecordType is export <rcDISPLAY rcINTERNAL rcCSV>;

# Organization types for file operations
enum OrganizationType is export <orgSEQ orgSTREAM>;

# Option appearance levels for OPTION statements
enum OptionAppearance is export <ApNone ApUnit ApModule>;

# Break directives corresponding to Pascal constants
constant $bkCancel = 0;
constant $bkStep = 1;
constant $bkStepRestricted = 2;
constant $bkContinue = 3;

# Global state variables
our $pass is export = 0;
our $exline is export = 0;
our $expos is export = 0;
our $exinsertcount is export = 0;
our $helpContext is export = 0;
our $bkDirective is export = $bkCancel;

# Interpreter configuration flags
our $GraphMode is export = False;
our $TextMode is export = False;
our $KeepGraphic is export = False;
our $KeepText is export = False;
our $UseCharInput is export = False;
our $InitialPrecisionMode is export = PrecisionNormal;
our $PrecisionMode is export = PrecisionNormal;
our $initialOptionBase is export = 1;
our $initialAngleDegrees is export = False;
our $initialCharacterByte is export = False;
our $JISFormat is export = False;
our $JISDim is export = False;
our $JISDef is export = False;
our $NoSizeZeroArray is export = False;
our $ForNextBroadOwn is export = False;
our $ForceFunctionDeclare is export = False;
our $ForceSubPictDeclare is export = False;
our $UseTranscendentalFunction is export = False;
our $DisableAbbreviatedPLOT is export = False;
our $signiwidthMore is export = False;
our $MinimalBasic is export = False;
our $PermitMicrosoft is export = False;
our $InsertDIMst is export = False;
our $OptionExplicit is export = False;
our $AutoIndent is export = True;
our $GreekIdf is export = False;
our $KanjiIdf is export = False;

# Auto-correct feature flags
our @AutoCorrect is export = True, True, True, True, True, True, False, False, False, False;

# Function key shortcuts
our $shift_F5 is export = 'LET ';
our $shift_F6 is export = 'PRINT ';
our $shift_F7 is export = 'OPTION ANGLE DEGREES';

# Execution state
our $ExecutingNow is export = False;
our $NoInitialize is export = False;
our $NoRun is export = False;
our $OpenAndRun is export = False;
our $NoBackUp is export = True;
our $TestRegisterID is export = False;

# Error codes (negative integers as in Pascal)
constant $outofmemory = -100;
constant $StackOverflow = -101;
constant $VirtualStackOverflow = -102;
constant $ArraySizeOverflow = -103;
constant $TooBigRational = -104;
constant $TextOverFlow = -108;
constant $SystemErr = -109;

# Complex number type
class Complex is export {
    has Num $.x;
    has Num $.y;
    
    method new(Num $x = 0e0, Num $y = 0e0) {
        self.bless: :$x, :$y;
    }
    
    method Str() {
        return "$.x + $.y i" if $.y >= 0;
        return "$.x - {abs $.y} i";
    }
    
    method add(Complex $other) {
        Complex.new($.x + $other.x, $.y + $other.y);
    }
    
    method subtract(Complex $other) {
        Complex.new($.x - $other.x, $.y - $other.y);
    }
    
    method multiply(Complex $other) {
        my $real = $.x * $other.x - $.y * $other.y;
        my $imag = $.x * $other.y + $.y * $other.x;
        Complex.new($real, $imag);
    }
    
    method abs() {
        sqrt($.x² + $.y²);
    }
}

# Base exception class corresponding to Pascal EExtype
class BasicException is Exception is export {
    has Int $.error-type;
    has Str $.help-context;
    
    method new(Str $message, Int :$error-type = 0, Str :$help-context = '') {
        self.bless: message => $message, :$error-type, :$help-context;
    }
}

# Utility functions corresponding to Pascal functions

sub max(Int $a, Int $b --> Int) is export {
    return $a > $b ?? $a !! $b;
}

sub min(Int $a, Int $b --> Int) is export {
    return $a < $b ?? $a !! $b;
}

sub upper(Str $s is rw) is export {
    $s = $s.uc;
}

sub lower(Str $s is rw) is export {
    $s = $s.lc;
}

sub imod(Int $a, Int $b --> Int) is export {
    return $a mod $b;
}

sub spaces(Int $n --> Str) is export {
    return ' ' x $n;
}

# Exception setting functions
sub setexception(Int $t) is export {
    our $extype = $t;
}

sub setexceptionwith(Str $s, Int $t) is export {
    our $extype = $t;
    die BasicException.new($s, error-type => $t);
}

# Array type for compatibility with Pascal Array4
class Array4 is export {
    has Int @.values[4];
    
    method AT-POS(Int $index) {
        fail "Array index out of bounds" unless 1 ≤ $index ≤ 4;
        @!values[$index - 1];  # Convert to 0-based indexing
    }
    
    method ASSIGN-POS(Int $index, Int $value) {
        fail "Array index out of bounds" unless 1 ≤ $index ≤ 4;
        @!values[$index - 1] = $value;
    }
}

# Precision mode mappings
our %PrecisionText is export = (
    PrecisionNormal    => 'decimal',
    PrecisionHigh      => '1000digits', 
    PrecisionNative    => 'Binary',
    PrecisionComplex   => 'complex',
    PrecisionRational  => 'rational'
);

our %PrecisionLiteral is export = (
    PrecisionNormal    => 'DECIMAL',
    PrecisionHigh      => 'DECIMAL_HIGH',
    PrecisionNative    => 'NATIVE', 
    PrecisionComplex   => 'COMPLEX',
    PrecisionRational  => 'RATIONAL'
);

# Literal mappings for other enums
our %AccessModeLiteral is export = (
    amOUTIN  => 'OUTIN',
    amINPUT  => 'INPUT',
    amOUTPUT => 'OUTPUT'
);

our %RecordTypeLiteral is export = (
    rcDISPLAY  => 'DISPLAY',
    rcINTERNAL => 'INTERNAL',
    rcCSV      => 'CSV'
);

our %OrganizationTypeLiteral is export = (
    orgSEQ    => 'SEQUENTIAL',
    orgSTREAM => 'STREAM'
);

our %YesNoLiteral is export = (
    False => 'NO',
    True  => 'YES'
);

=begin pod
=head1 FUNCTIONS

=head2 max(Int $a, Int $b --> Int)
Returns the maximum of two integers.

=head2 min(Int $a, Int $b --> Int) 
Returns the minimum of two integers.

=head2 upper(Str $s is rw)
Converts string to uppercase in-place.

=head2 lower(Str $s is rw)
Converts string to lowercase in-place.

=head2 spaces(Int $n --> Str)
Returns a string of $n spaces.

=head2 setexception(Int $t)
Sets the global exception type.

=head2 setexceptionwith(Str $s, Int $t)
Sets exception type and throws exception with message.

=end pod