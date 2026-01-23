#!/usr/bin/env raku

use v6.d;

# Include the grammar from TrueBASIC2.raku
grammar TrueBASICGrammar {
    token TOP { <program> }
    
    rule program { <line>* }
    
    rule line {
        [ <line-number>? <statement> | <comment> | <blank-line> ]
    }
    
    token line-number { \d+ }
    token blank-line { \s* }
    token comment { [ '!' | 'REM' ] .* }
    
    proto rule statement {*}
    rule statement:sym<print>    { 'PRINT' <print-list>? }
    rule statement:sym<end>      { 'END' | 'STOP' }
    
    rule print-list { <print-item> [ <separator> <print-item> ]* <separator>? }
    rule print-item { <expression> }
    token separator { ';' | ',' }
    
    rule expression { <term> [ <additive-op> <term> ]* }
    rule term { <factor> [ <multiplicative-op> <factor> ]* }
    rule factor {
        | <number>
        | <string-literal>
        | '(' <expression> ')'
    }
    
    token additive-op { '+' | '-' }
    token multiplicative-op { '*' | '/' }
    
    token number { '-'? \d+ [ '.' \d+ ]? [ 'e' '-'? \d+ ]? }
    token string-literal { '"' <-["]>* '"' }
}

# Test the grammar
my $test = '10 PRINT "Hello"';
say "Testing: $test";

my $match = TrueBASICGrammar.parse($test);
if $match {
    say "Parse successful!";
    say $match.raku;
} else {
    say "Parse failed!";
}