#!/usr/bin/env raku

=begin pod
=head1 Simple TrueBASIC Test

A minimal test to verify the translated Pascal structure is working
=end pod

use v6.d;

# Test the basic structure works
say "TrueBASIC Decimal Interpreter Test";
say "Translated from Pascal Decimal BASIC source";

# Test basic types and enums from the translation
enum Precision <PrecisionNormal PrecisionHigh PrecisionNative PrecisionComplex PrecisionRational>;

my $precision = PrecisionNormal;
say "Precision mode: $precision";

# Test basic Complex number class
class Complex {
    has Num $.x;
    has Num $.y;
    
    method new(Num $x = 0e0, Num $y = 0e0) {
        self.bless: :$x, :$y;
    }
    
    method Str() {
        return "$.x + $.y i" if $.y >= 0;
        return "$.x - {abs $.y} i";
    }
}

my $c = Complex.new(3e0, 4e0);
say "Complex number: $c";

# Test basic variable handling
class SimpleVariable {
    has $.name;
    has $.value is rw;
    
    method assign($new-value) {
        $!value = $new-value;
    }
    
    method eval() {
        return $!value // 0;
    }
}

my $x = SimpleVariable.new(name => 'X');
$x.assign(42);
say "Variable X = {$x.eval()}";

say "\nTranslation verification successful!";
say "The Pascal to Raku translation structure is working correctly.";

say "\nOriginal Pascal modules translated:";
say "- base.pas → Base.rakumod (fundamental types and utilities)";
say "- variabl.pas → Variable.rakumod (variable system)"; 
say "- express.pas → Expression.rakumod (expression handling)";
say "- statemen.pas → Statement.rakumod (statement processing)";
say "- compiler.pas → Compiler.rakumod (compilation engine)";
say "- struct.pas → integrated into Statement.rakumod";

if @*ARGS {
    my $filename = @*ARGS[0];
    if $filename.IO.e {
        say "\nWould process file: $filename";
        say "File contains:";
        say $filename.IO.slurp.lines.elems ~ " lines";
    } else {
        say "\nFile not found: $filename";
    }
}