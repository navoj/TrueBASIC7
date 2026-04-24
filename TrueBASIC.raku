#!/usr/bin/env raku

=begin pod
=head1 True BASIC Interpreter

A Raku implementation of a True BASIC interpreter with grammar-based parsing,
GTK/Cairo graphics, web/HTML5 fallback, SVG export, and ASCII terminal plots.

Created by Jovan Trujillo
Arizona State University — Advanced Electronics and Photonics Center
2025

Based on Decimal BASIC by SHIRAISHI Kazuo
=end pod

use v6.d;

# GTK/Cairo imports for graphics display
use Gnome::Gtk3::Main;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::DrawingArea;
use Gnome::Cairo;
use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

# ══════════════════════════════════════════════════════════════════════════════
# Grammar for True BASIC language
# ══════════════════════════════════════════════════════════════════════════════

grammar TrueBASICGrammar {
    token TOP { <program> }

    rule program { <line>+ %% \n }

    rule line {
        <line-number>? <statement> | <comment> | <blank-line>
    }

    token line-number { \d+ }
    token blank-line  { ^^ \s* $$ }
    token comment     { [ '!' | :i 'REM' ] \N* }

    proto rule statement {*}

    # Variable assignment
    rule statement:sym<let>       { :i 'LET' <assignment> }
    rule statement:sym<assign>    { <assignment> }

    # I/O
    rule statement:sym<print>     { :i 'PRINT' <print-list>? }
    rule statement:sym<input-prompt> { :i 'INPUT' 'PROMPT' <expression> ':' <identifier>+ % ',' }
    rule statement:sym<line-input> { :i 'LINE' 'INPUT' [ 'PROMPT' <expression> ':' ]? <identifier> }
    rule statement:sym<input>     { :i 'INPUT' [ <string-expr> ';' ]? <identifier>+ % ',' }
    rule statement:sym<mat-print> { :i 'MAT' 'PRINT' <identifier> [ ';' | ',' ]? }
    rule statement:sym<mat-read>  { :i 'MAT' 'READ' <identifier> }
    rule statement:sym<mat-redim> { :i 'MAT' 'REDIM' <mat-redim-item>+ % ',' }
    rule mat-redim-item           { <identifier> '(' <expression-list> ')' }
    rule statement:sym<mat-input> { :i 'MAT' 'INPUT' <identifier> }
    rule statement:sym<mat-assign> { :i 'MAT' <identifier> '=' <mat-rhs> }
    rule mat-rhs {
        :i 'ZER' [ '(' <expression-list> ')' ]?
        | 'CON' [ '(' <expression-list> ')' ]?
        | 'IDN' [ '(' <expression-list> ')' ]?
        | 'TRN' '(' <identifier> ')'
        | 'INV' '(' <identifier> ')'
        | '(' <expression> ')' '*' <identifier>
        | <identifier> <[*+\-]> <identifier>
        | <identifier>
        | <expression>
    }

    # Control flow
    rule statement:sym<if-block>  { :i 'IF' <condition> 'THEN' $$ }
    rule statement:sym<if>        { :i 'IF' <condition> 'THEN' <statement> [ 'ELSE' <else=statement> ]? }
    rule statement:sym<else>      { :i 'ELSE' }
    rule statement:sym<elseif>    { :i 'ELSEIF' <condition> 'THEN' }
    rule statement:sym<end-if>    { :i 'END' 'IF' }
    rule statement:sym<goto>      { :i 'GOTO' <line-number> }
    rule statement:sym<gosub>     { :i 'GOSUB' <line-number> }
    rule statement:sym<return>    { :i 'RETURN' }
    rule statement:sym<for>       { :i 'FOR' <identifier> '=' <expression> 'TO' <expression> [ 'STEP' <expression> ]? }
    rule statement:sym<next>      { :i 'NEXT' <identifier>? }
    rule statement:sym<do>        { :i 'DO' [ $<condition-type>=[ 'WHILE' | 'UNTIL' ] <condition> ]? }
    rule statement:sym<loop>      { :i 'LOOP' [ $<condition-type>=[ 'UNTIL' | 'WHILE' ] <condition> ]? }
    rule statement:sym<while>     { :i 'WHILE' <condition> }
    rule statement:sym<wend>      { :i 'WEND' }
    rule statement:sym<exit>      { :i 'EXIT' $<kind>=[ 'DO' | 'FOR' | 'SUB' | 'FUNCTION' ]? }

    # Data
    rule statement:sym<dim>       { :i 'DIM' <dim-item>+ % ',' }
    rule statement:sym<read>      { :i 'READ' <read-target>+ % ',' }
    rule statement:sym<data>      { :i 'DATA' <data-item>+ % ',' }
    rule statement:sym<restore>   { :i 'RESTORE' }

    # Options
    rule statement:sym<option>    { :i 'OPTION' [ 'NOLET' | 'BASE' <expression> | 'ANGLE' [ 'DEGREES' | 'RADIANS' ] ] }

    # Subroutines and functions
    rule statement:sym<sub>       { :i 'SUB' <identifier> [ '(' <sub-param-list> ')' ]? }
    rule statement:sym<end-sub>   { :i 'END' 'SUB' }
    rule statement:sym<call>      { :i 'CALL' <identifier> [ '(' <call-arg-list> ')' ]? }
    rule statement:sym<def>       { :i 'DEF' <identifier> [ '(' <sub-param-list> ')' ]? [ '=' <expression> ]? }
    rule statement:sym<declare>   { :i 'DECLARE' [ 'DEF' | 'SUB' ] <identifier> }
    rule statement:sym<local>     { :i 'LOCAL' <identifier>+ % ',' }
    rule statement:sym<end-function> { :i 'END' 'FUNCTION' }
    rule statement:sym<function>  { :i 'FUNCTION' <identifier> [ '(' <sub-param-list> ')' ]? }

    # SELECT CASE
    rule statement:sym<select>    { :i 'SELECT' 'CASE' <expression> }
    rule statement:sym<case>      { :i 'CASE' [ 'ELSE' | <case-test>+ % ',' ] }
    rule statement:sym<end-select> { :i 'END' 'SELECT' }

    # Graphics — True BASIC syntax
    rule statement:sym<set-window>   { :i 'SET' 'WINDOW' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<set-color>    { :i 'SET' 'COLOR' <color-spec> }
    rule statement:sym<set-back>     { :i 'SET' 'BACKGROUND' 'COLOR' <color-spec> }
    rule statement:sym<set-cursor>   { :i 'SET' 'CURSOR' <expression> ',' <expression> }
    rule statement:sym<set-text>     { :i 'SET' 'TEXT' 'JUSTIFY' <identifier> ',' <identifier> }
    rule statement:sym<plot-lines>   { :i 'PLOT' 'LINES' ':' <coord-pair>+ % ';' }
    rule statement:sym<plot-area>    { :i 'PLOT' 'AREA' ':' <coord-pair>+ % ';' }
    rule statement:sym<plot-text>    { :i 'PLOT' 'TEXT' ',' 'AT' <expression> ',' <expression> ':' <expression> }
    rule statement:sym<plot>         { :i 'PLOT' [ <expression> ',' <expression> $<continuation>=';'? ]? }

    # Simplified graphics keywords
    rule statement:sym<window>    { :i 'WINDOW' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<line>      { :i 'LINE' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<circle>    { :i 'CIRCLE' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<box>       { :i 'BOX' $<subtype>=[ 'LINES' | 'AREA' | 'CLEAR' | 'CIRCLE' ] <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<flood>     { :i 'FLOOD' <expression> ',' <expression> }
    rule statement:sym<ask>       { :i 'ASK' <identifier> <identifier> }

    # Display/output
    rule statement:sym<show>      { :i 'SHOW' 'PLOT' }
    rule statement:sym<save>      { :i 'SAVE' <expression>? }
    rule statement:sym<graphics>  { :i 'GRAPHICS' <identifier> }
    rule statement:sym<clear>     { :i 'CLEAR' }
    rule statement:sym<cls>       { :i 'CLS' }
    rule statement:sym<pause>     { :i 'PAUSE' <expression>? }
    rule statement:sym<get-key>   { :i 'GET' 'KEY' <identifier> }
    rule statement:sym<open-screen> { :i 'OPEN' '#' <expression> ':' 'SCREEN' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<window-select> { :i 'WINDOW' '#' <expression> }
    rule statement:sym<open>      { :i 'OPEN' <expression> ':' <identifier> ',' <identifier> [ ',' <identifier> ]* }
    rule statement:sym<close>     { :i 'CLOSE' '#' <expression> }
    rule statement:sym<print-file> { :i 'PRINT' '#' <expression> ':' <print-list>? }
    rule statement:sym<input-file> { :i 'INPUT' '#' <expression> ':' <identifier>+ % ',' }
    rule statement:sym<library>   { :i 'LIBRARY' <expression> }

    # Program structure
    rule statement:sym<program>   { :i 'PROGRAM' <identifier> }
    rule statement:sym<end>       { :i [ 'END' | 'STOP' ] }
    rule statement:sym<rem>       { :i 'REM' \N* }

    # Sub-rules
    rule dim-item                 { <identifier> '(' <expression-list> ')' }
    rule case-test                { <expression> [ :i 'TO' <expression> ]? }
    rule coord-pair               { <expression> ',' <expression> }
    rule param-list               { <identifier>+ % ',' }
    rule sub-param               { <identifier> [ '(' ','? ')' ]? }
    rule sub-param-list          { <sub-param>+ % ',' }
    rule call-arg                { <expression> | <identifier> '(' ','? ')' }
    rule call-arg-list           { <call-arg>+ % ',' }
    rule read-target             { <array-access> | <identifier> }

    rule assignment { [ <array-access> | <identifier> ] '=' <expression> }
    rule array-access { <identifier> '(' <expression-list> ')' }

    rule print-list { <print-item> [ <separator> <print-item> ]* <separator>? }
    rule print-item { <expression> }
    token separator { ';' | ',' }

    rule expression-list { <expression> [ ',' <expression> ]* }

    rule condition {
        '(' <expression> <comparison-op> <expression> [ :i <logical-op> <expression> <comparison-op> <expression> ]* ')'
        | <expression> <comparison-op> <expression> [ :i <logical-op> <expression> <comparison-op> <expression> ]*
        | <expression>
    }

    token comparison-op { '<=' | '>=' | '<>' | '!=' | '<' | '>' | '=' }
    token logical-op    { :i 'AND' | 'OR' }

    rule expression  { <term> [ <additive-op> <term> ]* }
    rule term        { <power> [ <multiplicative-op> <power> ]* }
    rule power       { <unary-factor> [ <exponentiation-op> <power> ]? }

    proto rule unary-factor { * }
    rule unary-factor:sym<neg>   { '-' <factor> }
    rule unary-factor:sym<pos>   { '+'? <factor> }
    rule unary-factor:sym<not>   { :i 'NOT' <factor> }

    proto rule factor { * }
    rule factor:sym<number>      { <number> }
    rule factor:sym<string>      { <string-literal> }
    rule factor:sym<function>    { <function-call> }
    rule factor:sym<array>       { <array-access> }
    rule factor:sym<identifier>  { <identifier> }
    rule factor:sym<paren>       { '(' <expression> ')' }

    rule function-call { <func-name> '(' <expression-list>? ')' }

    token additive-op        { '+' | '-' | '&' }
    token multiplicative-op  { '*' | '/' | :i 'MOD' }
    token exponentiation-op  { '^' }

    rule string-expr { <string-literal> | <identifier> }

    token color-spec { <number> | <string-literal> | <identifier> }

    token number {
        \d+ [ '.' \d* ]? [ <[eE]> <[+\-]>? \d+ ]?
        | '.' \d+ [ <[eE]> <[+\-]>? \d+ ]?
    }
    token string-literal { '"' <-["]>* '"' }
    token func-name      { <[A..Za..z]> <[A..Za..z0..9_]>* '$'? }
    token identifier     { <[A..Za..z]> <[A..Za..z0..9_]>* [ '$' | '%' ]? }

    # Data items can be numbers or strings
    token data-item      { <string-literal> | <[+\-]>? <number> | <-[,\n]>+ }
}

# ══════════════════════════════════════════════════════════════════════════════
# Actions class — builds hash-based AST
# ══════════════════════════════════════════════════════════════════════════════

class TrueBASICActions {

    method TOP($/)     { make $<program>.made }
    method program($/) { make $<line>>>.made.grep(*.defined) }

    method line($/) {
        if $<statement> {
            my %line = statement => $<statement>.made;
            %line<line-number> = +$<line-number> if $<line-number>;
            make %line;
        } elsif $<comment> {
            make Nil;
        } else {
            make Nil;
        }
    }

    # ── Statement actions ────────────────────────────────────────────────

    method statement:sym<let>($/)    { make { type => 'let', assignment => $<assignment>.made } }
    method statement:sym<assign>($/) { make { type => 'let', assignment => $<assignment>.made } }

    method statement:sym<print>($/) {
        make { type => 'print', items => $<print-list> ?? $<print-list>.made !! [] }
    }
    method statement:sym<input>($/) {
        make {
            type => 'input',
            prompt => $<string-expr> ?? $<string-expr>.made !! Nil,
            variable => ~$<identifier>
        }
    }

    method statement:sym<if>($/) {
        make {
            type => 'if',
            condition  => $<condition>.made,
            then-stmt  => $<statement>[0].made,
            else-stmt  => $<else> ?? $<else>.made !! Nil,
        }
    }
    method statement:sym<goto>($/)   { make { type => 'goto', target => +$<line-number> } }
    method statement:sym<gosub>($/)  { make { type => 'gosub', target => +$<line-number> } }
    method statement:sym<return>($/) { make { type => 'return' } }

    method statement:sym<for>($/) {
        make {
            type     => 'for',
            variable => ~$<identifier>,
            start    => $<expression>[0].made,
            end      => $<expression>[1].made,
            step     => $<expression>[2] ?? $<expression>[2].made !! { type => 'number', value => 1 },
        }
    }
    method statement:sym<next>($/) {
        make { type => 'next', variable => $<identifier> ?? ~$<identifier> !! Nil }
    }

    method statement:sym<do>($/) {
        make {
            type           => 'do',
            condition-type => $<condition-type> ?? ~$<condition-type> !! Nil,
            condition      => $<condition> ?? $<condition>.made !! Nil,
        }
    }
    method statement:sym<loop>($/) {
        make {
            type           => 'loop',
            condition-type => $<condition-type> ?? ~$<condition-type> !! Nil,
            condition      => $<condition> ?? $<condition>.made !! Nil,
        }
    }
    method statement:sym<while>($/) { make { type => 'while', condition => $<condition>.made } }
    method statement:sym<wend>($/)  { make { type => 'wend' } }
    method statement:sym<exit>($/)  { make { type => 'exit', kind => ($<kind> ?? (~$<kind>).uc !! 'DO') } }

    method statement:sym<dim>($/) {
        my @dims;
        for $<dim-item> -> $item {
            @dims.push({ name => ~$item<identifier>, dimensions => $item<expression-list>.made });
        }
        make { type => 'dim', items => @dims }
    }
    method statement:sym<restore>($/) { make { type => 'restore' } }
    method statement:sym<data>($/) {
        make { type => 'data', values => $<data-item>>>.made }
    }

    # Subroutines
    method statement:sym<end-sub>($/) { make { type => 'end-sub' } }
    method statement:sym<def>($/) {
        if $<expression> {
            make {
                type       => 'def',
                name       => ~$<identifier>,
                params     => $<sub-param-list> ?? $<sub-param-list>.made !! [],
                expression => $<expression>.made,
            }
        } else {
            # Multi-line DEF (like FUNCTION...END FUNCTION)
            make {
                type   => 'function-def',
                name   => ~$<identifier>,
                params => $<sub-param-list> ?? $<sub-param-list>.made !! [],
            }
        }
    }
    method statement:sym<declare>($/) { make { type => 'declare', name => ~$<identifier> } }
    method statement:sym<local>($/)   { make { type => 'local', variables => $<identifier>>>.Str } }

    # SELECT CASE
    method statement:sym<select>($/) {
        make { type => 'select', expression => $<expression>.made }
    }
    method statement:sym<case>($/) {
        if $<case-test> {
            make { type => 'case', tests => $<case-test>>>.made }
        } else {
            make { type => 'case-else' }
        }
    }
    method statement:sym<end-select>($/) { make { type => 'end-select' } }

    # Graphics
    method statement:sym<set-window>($/) {
        make {
            type => 'window',
            x1 => $<expression>[0].made, x2 => $<expression>[1].made,
            y1 => $<expression>[2].made, y2 => $<expression>[3].made,
        }
    }
    method statement:sym<set-color>($/) {
        make { type => 'set-color', color => ~$<color-spec> }
    }
    method statement:sym<set-cursor>($/) {
        make { type => 'set-cursor', row => $<expression>[0].made, col => $<expression>[1].made }
    }
    method statement:sym<set-text>($/) {
        make { type => 'set-text-justify' }
    }
    method statement:sym<plot-lines>($/) {
        make {
            type   => 'plot-lines',
            coords => $<coord-pair>>>.made,
        }
    }
    method statement:sym<plot-area>($/) {
        make {
            type   => 'plot-area',
            coords => $<coord-pair>>>.made,
        }
    }
    method statement:sym<plot-text>($/) {
        make {
            type => 'plot-text',
            x    => $<expression>[0].made,
            y    => $<expression>[1].made,
            text => $<expression>[2].made,
        }
    }
    method statement:sym<plot>($/) {
        if $<expression>.elems >= 2 {
            make {
                type => 'plot',
                x => $<expression>[0].made,
                y => $<expression>[1].made,
                continuation => $<continuation>.defined && ~$<continuation> eq ';',
            }
        } else {
            make { type => 'plot-end' }
        }
    }
    method statement:sym<window>($/) {
        make {
            type => 'window',
            x1 => $<expression>[0].made, x2 => $<expression>[1].made,
            y1 => $<expression>[2].made, y2 => $<expression>[3].made,
        }
    }
    method statement:sym<line>($/) {
        make {
            type => 'line',
            x1 => $<expression>[0].made, y1 => $<expression>[1].made,
            x2 => $<expression>[2].made, y2 => $<expression>[3].made,
        }
    }
    method statement:sym<circle>($/) {
        make {
            type => 'circle',
            x => $<expression>[0].made, y => $<expression>[1].made,
            radius => $<expression>[2].made,
        }
    }
    method statement:sym<box>($/) {
        make {
            type => 'box',
            subtype => (~$<subtype>).uc,
            x1 => $<expression>[0].made, y1 => $<expression>[1].made,
            x2 => $<expression>[2].made, y2 => $<expression>[3].made,
        }
    }
    method statement:sym<show>($/)     { make { type => 'show' } }
    method statement:sym<save>($/) {
        make { type => 'save', filename => $<expression> ?? $<expression>.made !! Nil }
    }
    method statement:sym<graphics>($/) { make { type => 'graphics', mode => ~$<identifier> } }
    method statement:sym<clear>($/)    { make { type => 'clear' } }
    method statement:sym<cls>($/)      { make { type => 'cls' } }
    method statement:sym<pause>($/) {
        make { type => 'pause', duration => $<expression> ?? $<expression>.made !! Nil }
    }
    method statement:sym<get-key>($/)  { make { type => 'get-key', variable => ~$<identifier> } }
    method statement:sym<program>($/)  { make { type => 'program', name => ~$<identifier> } }
    method statement:sym<end>($/)      { make { type => 'end' } }
    method statement:sym<rem>($/)      { make { type => 'rem' } }

    # ── Sub-rule actions ─────────────────────────────────────────────────

    method case-test($/) {
        if $<expression>.elems > 1 {
            make { from => $<expression>[0].made, to => $<expression>[1].made }
        } else {
            make { value => $<expression>[0].made }
        }
    }
    method coord-pair($/) {
        make { x => $<expression>[0].made, y => $<expression>[1].made }
    }
    method param-list($/) { make $<identifier>>>.Str }

    method assignment($/) {
        if $<array-access> {
            make {
                type       => 'array-assignment',
                array      => $<array-access>.made,
                expression => $<expression>.made,
            }
        } else {
            make { variable => ~$<identifier>, expression => $<expression>.made }
        }
    }

    method print-list($/) {
        my @items;
        for $<print-item>.kv -> $i, $item {
            my $sep = $i < $<separator>.elems ?? ~$<separator>[$i] !! '';
            @items.push({ expr => $item.made, separator => $sep });
        }
        make @items;
    }
    method print-item($/) { make $<expression>.made }

    # ── Expression actions ───────────────────────────────────────────────

    method expression($/) {
        my $result = $<term>[0].made;
        for $<additive-op>.kv -> $i, $op {
            $result = { type => 'binary', operator => ~$op, left => $result, right => $<term>[$i + 1].made }
        }
        make $result;
    }
    method power($/) {
        my $result = $<unary-factor>.made;
        if $<power> {
            $result = { type => 'binary', operator => '^', left => $result, right => $<power>.made }
        }
        make $result;
    }
    method unary-factor:sym<neg>($/) {
        make { type => 'unary', operator => '-', operand => $<factor>.made }
    }
    method unary-factor:sym<pos>($/) { make $<factor>.made }

    method factor:sym<number>($/)     { make { type => 'number', value => +$<number> } }
    method factor:sym<string>($/)     { make { type => 'string', value => ~$<string-literal>.substr(1, *-1) } }
    method factor:sym<identifier>($/) { make { type => 'variable', name => ~$<identifier> } }
    method factor:sym<array>($/)      { make $<array-access>.made }
    method factor:sym<function>($/)   { make $<function-call>.made }
    method factor:sym<paren>($/)      { make $<expression>.made }

    method function-call($/) {
        make {
            type => 'function',
            name => ~$<func-name>,
            args => $<expression-list> ?? $<expression-list>.made !! [],
        }
    }
    method expression-list($/) { make $<expression>>>.made }
    method array-access($/) {
        make { type => 'array-access', name => ~$<identifier>, indices => $<expression-list>.made }
    }
    method string-expr($/) {
        if $<string-literal> {
            make { type => 'string', value => ~$<string-literal>.substr(1, *-1) }
        } else {
            make { type => 'variable', name => ~$<identifier> }
        }
    }
    method data-item($/) { make ~$/ }

    # New actions for extended grammar
    method statement:sym<input-prompt>($/) {
        make {
            type => 'input-prompt',
            prompt => $<expression>.made,
            variables => $<identifier>>>.Str,
        }
    }
    method statement:sym<if-block>($/) {
        make { type => 'if-block', condition => $<condition>.made }
    }
    method statement:sym<else>($/)     { make { type => 'else' } }
    method statement:sym<elseif>($/)   { make { type => 'elseif', condition => $<condition>.made } }
    method statement:sym<end-if>($/)   { make { type => 'end-if' } }
    method statement:sym<option>($/)   { make { type => 'option', text => ~$/ } }
    method statement:sym<mat-print>($/) {
        make { type => 'mat-print', name => ~$<identifier> }
    }
    method statement:sym<mat-read>($/) {
        make { type => 'mat-read', name => ~$<identifier> }
    }
    method statement:sym<mat-redim>($/) {
        make %(
            type  => 'mat-redim',
            items => $<mat-redim-item>.map({
                %( name => ~$_<identifier>, dimensions => $_<expression-list>.made )
            }).Array,
        );
    }
    method statement:sym<mat-input>($/) {
        make { type => 'mat-input', name => ~$<identifier> }
    }
    method statement:sym<mat-assign>($/) {
        make %(
            type => 'mat-assign',
            name => ~$<identifier>,
            rhs  => ~$<mat-rhs>,
        );
    }
    method statement:sym<set-back>($/) {
        make { type => 'set-back-color', color => ~$<color-spec> }
    }
    method statement:sym<flood>($/)     { make { type => 'flood' } }
    method statement:sym<ask>($/)       { make { type => 'ask' } }
    method statement:sym<open-screen>($/) {
        make %(
            type => 'open-screen',
            channel => $<expression>[0].made,
            x1 => $<expression>[1].made, x2 => $<expression>[2].made,
            y1 => $<expression>[3].made, y2 => $<expression>[4].made,
        );
    }
    method statement:sym<window-select>($/) {
        make %( type => 'window-select', channel => $<expression>.made );
    }
    method statement:sym<open>($/)      { make { type => 'open' } }
    method statement:sym<close>($/)     { make { type => 'close' } }
    method statement:sym<print-file>($/) { make { type => 'print-file' } }
    method statement:sym<input-file>($/) { make { type => 'input-file' } }
    method statement:sym<line-input>($/) {
        make %(
            type => 'line-input',
            prompt => $<expression> ?? $<expression>.made !! Nil,
            variable => ~$<identifier>,
        );
    }
    method statement:sym<library>($/)   { make { type => 'library' } }
    method statement:sym<function>($/) {
        make { type => 'function-def', name => ~$<identifier>,
               params => $<sub-param-list> ?? $<sub-param-list>.made !! [] }
    }
    method statement:sym<end-function>($/) { make { type => 'end-function' } }

    method statement:sym<sub>($/) {
        make {
            type   => 'sub',
            name   => ~$<identifier>,
            params => $<sub-param-list> ?? $<sub-param-list>.made !! [],
        }
    }
    method statement:sym<call>($/) {
        make {
            type => 'call',
            name => ~$<identifier>,
            args => $<call-arg-list> ?? $<call-arg-list>.made !! [],
        }
    }

    method sub-param($/) {
        my $name = ~$<identifier>;
        my $suffix = $/.Str ~~ /\(\s*\,\s*\)/ ?? '(,)' !! ($/.Str ~~ /\(\s*\)/ ?? '()' !! '');
        make $name ~ $suffix;
    }
    method sub-param-list($/) { make $<sub-param>>>.made }

    method call-arg($/) {
        if $<expression> {
            make $<expression>.made;
        } else {
            my $dims = $/.Str ~~ /\(\s*\,\s*\)/ ?? 2 !! 1;
            make { type => 'array-ref', name => ~$<identifier>, dims => $dims };
        }
    }
    method call-arg-list($/) { make $<call-arg>>>.made }

    method read-target($/) {
        if $<array-access> {
            make $<array-access>.made;
        } else {
            make { type => 'variable', name => ~$<identifier> };
        }
    }
    method statement:sym<read>($/) {
        make { type => 'read', targets => $<read-target>>>.made }
    }

    method condition($/) {
        if $<comparison-op> {
            my $result = {
                type     => 'comparison',
                left     => $<expression>[0].made,
                operator => ~$<comparison-op>[0],
                right    => $<expression>[1].made,
            };
            # Handle chained conditions: a < b AND c > d
            if $<logical-op> {
                for $<logical-op>.kv -> $i, $lop {
                    $result = {
                        type     => 'logical',
                        operator => (~$lop).uc,
                        left     => $result,
                        right    => {
                            type     => 'comparison',
                            left     => $<expression>[$i * 2 + 2].made,
                            operator => ~$<comparison-op>[$i + 1],
                            right    => $<expression>[$i * 2 + 3].made,
                        },
                    };
                }
            }
            make $result;
        } else {
            make $<expression>[0].made;
        }
    }

    method unary-factor:sym<not>($/) {
        make { type => 'unary', operator => 'NOT', operand => $<factor>.made }
    }

    method term($/) {
        my $result = $<power>[0].made;
        for $<multiplicative-op>.kv -> $i, $op {
            my $oper = (~$op).uc eq 'MOD' ?? 'MOD' !! ~$op;
            $result = { type => 'binary', operator => $oper, left => $result, right => $<power>[$i + 1].made }
        }
        make $result;
    }
}
# ══════════════════════════════════════════════════════════════════════════════
# Color palette — True BASIC standard colors
# ══════════════════════════════════════════════════════════════════════════════

my @TB-COLORS = (
    (0, 0, 0),          # 0 = black (background on dark)
    (1, 1, 1),          # 1 = white
    (1, 0, 0),          # 2 = red
    (0, 0.8, 0),        # 3 = green
    (0, 0, 1),          # 4 = blue
    (0, 0.8, 0.8),      # 5 = cyan
    (1, 0, 1),          # 6 = magenta
    (1, 1, 0),          # 7 = yellow
    (1, 0.5, 0),        # 8 = orange (custom for charts)
    (0.5, 0.5, 0.5),    # 9 = gray
);

my %COLOR-NAMES = (
    'black' => 0, 'white' => 1, 'red' => 2, 'green' => 3,
    'blue' => 4, 'cyan' => 5, 'magenta' => 6, 'yellow' => 7,
    'orange' => 8, 'gray' => 9, 'grey' => 9,
);

sub resolve-color($spec) {
    given $spec {
        when /^ \d+ $/ { return +$spec min (@TB-COLORS.elems - 1) }
        when /^ '"' (.*) '"' $/ { return %COLOR-NAMES{$0.lc} // 4 }
        default { return %COLOR-NAMES{$spec.lc} // 4 }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# Interpreter Engine
# ══════════════════════════════════════════════════════════════════════════════

# Forward declaration for GTK renderer
class PlotRenderer { ... }

class TrueBASICInterpreter {
    has %.variables;
    has %.arrays;
    has %.functions;      # built-in functions
    has %.user-functions; # DEF-defined functions
    has %.subroutines;    # SUB name → line index
    has @.program;
    has Int $.current-line = 0;
    has @.call-stack;
    has @.for-stack;
    has @.do-stack;
    has @.while-stack;
    has @.select-stack;
    has @.data-values;
    has Int $.data-pointer = 0;
    has Bool $.running = False;
    has Bool $.debug = False;

    # Graphics state
    has @.plot-points;
    has @.plot-lines;
    has @.plot-circles;
    has @.plot-line-strips;    # PLOT LINES: connected segments
    has @.plot-areas;          # PLOT AREA: filled polygons
    has @.plot-texts;          # PLOT TEXT
    has @.plot-boxes;
    has @.current-strip;       # current polyline being built by PLOT x,y;
    has %.window = x-min => 0e0, x-max => 1e0, y-min => 0e0, y-max => 1e0;
    has Str $.graphics-mode is rw = 'auto';  # auto, gtk, web, svg, ascii
    has Str $.plot-file = 'plot.svg';
    has Int $.current-color = 4;      # default blue
    has Int $.bg-color = 0;           # background color
    has Bool $.graphics-used = False;
    has Bool $.graphics-shown = False;
    has Bool $.option-nolet = False;
    has Int $.option-base = 0;        # OPTION BASE 0 or 1
    has %.viewports;                  # OPEN #n: screen viewports
    has Int $.active-viewport = 0;    # current viewport channel

    method new(Bool :$debug = False) {
        my $obj = self.bless(:$debug);
        $obj.initialize-builtins();
        return $obj;
    }

    method initialize-builtins() {
        %!functions<ABS>   = -> $x { abs($x) };
        %!functions<ATN>   = -> $x { atan($x) };
        %!functions<ACOS>  = -> $x { acos($x) };
        %!functions<ASIN>  = -> $x { asin($x) };
        %!functions<COS>   = -> $x { cos($x) };
        %!functions<EXP>   = -> $x { exp($x) };
        %!functions<INT>   = -> $x { $x.floor };
        %!functions<IP>    = -> $x { $x.truncate };
        %!functions<FP>    = -> $x { $x - $x.truncate };
        %!functions<LOG>   = -> $x { log($x) };
        %!functions<LOG2>  = -> $x { log($x) / log(2) };
        %!functions<LOG10> = -> $x { log($x) / log(10) };
        %!functions<MAX>   = -> $x, $y { max($x, $y) };
        %!functions<MIN>   = -> $x, $y { min($x, $y) };
        %!functions<MOD>   = -> $x, $y { $x mod $y };
        %!functions<RND>   = -> $x? { rand };
        %!functions<ROUND> = -> $x, $d? { $d ?? $x.round(10 ** -$d) !! $x.round };
        %!functions<SGN>   = -> $x { $x <=> 0 };
        %!functions<SIN>   = -> $x { sin($x) };
        %!functions<SQR>   = -> $x { sqrt($x) };
        %!functions<SQRT>  = -> $x { sqrt($x) };
        %!functions<TAN>   = -> $x { tan($x) };
        %!functions<PI>    = -> { pi };
        # String functions
        %!functions<LEN>   = -> $s { $s.chars };
        %!functions<CHR$>  = -> $n { chr($n.Int) };
        %!functions<STR$>  = -> $n { ~$n };
        %!functions<VAL>   = -> $s { +$s };
        %!functions<UCASE$> = -> $s { $s.uc };
        %!functions<LCASE$> = -> $s { $s.lc };
        %!functions<LEFT$>  = -> $s, $n { $s.substr(0, $n.Int) };
        %!functions<RIGHT$> = -> $s, $n { $s.substr(*-$n.Int) };
        %!functions<MID$>   = -> $s, $p, $n? { $n ?? $s.substr($p.Int - 1, $n.Int) !! $s.substr($p.Int - 1) };
        %!functions<TAB>    = -> $n, $m? { ' ' x $n.Int };
        %!functions<USING$> = -> $fmt, $n { sprintf($fmt, $n) };
        %!functions<POS>    = -> $s, $t, $p? { my $idx = $s.index($t, ($p // 1).Int - 1); $idx.defined ?? $idx + 1 !! 0 };
        %!functions<ORD>    = -> $s { $s.ord };
        %!functions<REPEAT$> = -> $s, $n { $s x $n.Int };
        %!functions<TRIM$>  = -> $s { $s.trim };
        %!functions<LTRIM$> = -> $s { $s.trim-leading };
        %!functions<RTRIM$> = -> $s { $s.trim-trailing };
        %!functions<CPOS>   = -> $x, $y? { 0 };  # stub
        %!functions<CEIL>   = -> $x { $x.ceiling };
        %!functions<REMAINDER> = -> $x, $y { $x mod $y };
        %!functions<TRUNCATE> = -> $x, $d? { $d ?? ($x * 10 ** $d).truncate / (10 ** $d) !! $x.truncate };
    }

    # ── Program loading ──────────────────────────────────────────────────

    method load-program(Str $filename) {
        my $source = try { $filename.IO.slurp } // $filename.IO.slurp(:enc<latin1>);
        self.load-source($source);
    }

    method to-num($val) {
        return $val if $val ~~ Numeric;
        return +$val if $val ~~ Str && $val ~~ /^ <[0..9+\-.eE \t]>+ $/;
        return 0;
    }

    method strip-inline-comment(Str $line --> Str) {
        my $in-string = False;
        for $line.comb.kv -> $i, $ch {
            if $ch eq '"' { $in-string = !$in-string }
            elsif $ch eq '!' && !$in-string {
                return $line.substr(0, $i).trim-trailing;
            }
        }
        return $line;
    }

    method split-on-colon(Str $line --> List) {
        # Don't split lines containing special colon syntax (True BASIC uses : in many places)
        my $trimmed = $line.trim;
        # Strip leading line number
        my $check = $trimmed;
        $check = $check.subst(/^ \d+ \s+/, '');
        return ($line,) if $check ~~ /:i ^ [ 'OPEN' \s | 'PRINT' \s* '#' | 'INPUT' \s* '#'
                                           | 'PLOT' \s+ [ 'TEXT' | 'LINES' | 'AREA' | 'POINTS' ]
                                           | 'INPUT' \s+ 'PROMPT' | 'LINE' \s+ 'INPUT' ] /;
        my @parts;
        my $current = '';
        my $in-string = False;
        for $line.comb -> $ch {
            if $ch eq '"' { $in-string = !$in-string; $current ~= $ch }
            elsif $ch eq ':' && !$in-string { @parts.push($current); $current = '' }
            else { $current ~= $ch }
        }
        @parts.push($current) if $current.trim ne '';
        return @parts.elems > 0 ?? @parts.List !! ($line,);
    }

    method load-source(Str $source) {
        my $grammar = TrueBASICGrammar;
        my $actions = TrueBASICActions.new;

        # Try full parse with timeout to avoid hanging on complex files
        my $match;
        my $parsed = start { $grammar.parse($source, :$actions) };
        await Promise.anyof($parsed, Promise.in(3));
        if $parsed.status ~~ Kept {
            $match = $parsed.result;
        }

        if $match {
            @!program = $match.made;
            say "Parsed {+@!program} statements." if $!debug;
        } else {
            # Fallback: line-by-line parsing
            say "Full parse failed/timed out, trying line-by-line..." if $!debug;
            @!program = [];
            for $source.lines -> $raw-line {
                next if $raw-line.trim eq '' || $raw-line.trim.starts-with('!');
                # Strip inline ! comments (not inside strings)
                my $line = self.strip-inline-comment($raw-line);
                next if $line.trim eq '';
                # Split on colon multi-statement separator (but not inside strings or special syntax)
                my @stmts = self.split-on-colon($line);
                for @stmts -> $stmt {
                    next if $stmt.trim eq '';
                    my $m = $grammar.parse($stmt, :$actions, rule => 'line');
                    if $m && $m.made {
                        @!program.push($m.made);
                    } else {
                        say "⚠ Skipped: $stmt" if $!debug;
                    }
                }
            }
        }

        # Pre-scan for DATA statements and SUB definitions
        self.prescan-program();
    }

    method prescan-program() {
        for @!program.kv -> $idx, %stmt {
            next unless %stmt<statement>;
            given %stmt<statement><type> {
                when 'data' {
                    for %stmt<statement><values>.flat -> $val {
                        my $v = $val.trim;
                        $v = $v.substr(1, *-1) if $v.starts-with('"') && $v.ends-with('"');
                        @!data-values.push(+$v // $v);
                    }
                }
                when 'sub' {
                    %!subroutines{%stmt<statement><name>.uc} = $idx;
                }
                when 'function-def' {
                    %!subroutines{%stmt<statement><name>.uc} = $idx;
                }
            }
        }
    }

    # ── Main execution loop ──────────────────────────────────────────────

    method run() {
        $!running = True;
        $!current-line = 0;

        while $!running && $!current-line < @!program.elems {
            my %stmt = @!program[$!current-line];
            say "[$!current-line] {%stmt.raku}" if $!debug;

            my $ctrl = '';
            my $err = '';
            try {
                CATCH {
                    when X::AdHoc {
                        given .message {
                            when '__EXIT_DO__'       { $ctrl = 'exit-do' }
                            when '__EXIT_FOR__'      { $ctrl = 'exit-for' }
                            when '__EXIT_SUB__'      { $ctrl = 'exit-sub' }
                            when '__EXIT_FUNCTION__' { $ctrl = 'exit-function' }
                            default { $err = ~$_ }
                        }
                    }
                    default { $err = $_ ~~ Exception ?? .message !! ~$_ }
                }
                self.execute-statement(%stmt);
                $!current-line++;
            }

            given $ctrl {
                when 'exit-do'       { self.skip-to-after-loop() }
                when 'exit-for'      { self.skip-to-after-next() }
                when 'exit-sub'      { self.return-from-sub() }
                when 'exit-function' { self.skip-to-end-function() }
            }

            if $err {
                say "Runtime error at line $!current-line: $err";
                say "Statement: {%stmt.raku}" if $!debug;
                $!running = False;
            }
        }

        # Auto-show graphics if any were created and not already shown
        if $!graphics-used && !$!graphics-shown && (@!plot-points || @!plot-lines || @!plot-circles
                               || @!plot-line-strips || @!plot-areas || @!plot-texts || @!plot-boxes) {
            self.execute-show();
        }
    }

    # ── Statement dispatch ───────────────────────────────────────────────

    method execute-statement(%stmt) {
        return unless %stmt<statement>;
        my %s = %stmt<statement>;

        given %s<type> {
            when 'let'           { self.exec-let(%s<assignment>) }
            when 'print'         { self.exec-print(%s<items>) }
            when 'input'         { self.exec-input(%s<prompt>, %s<variable>) }
            when 'if'            { self.exec-if(%s) }
            when 'goto'          { self.exec-goto(%s<target>) }
            when 'gosub'         { self.exec-gosub(%s<target>) }
            when 'return'        { self.exec-return() }
            when 'for'           { self.exec-for(%s<variable>, %s<start>, %s<end>, %s<step>) }
            when 'next'          { self.exec-next(%s<variable>) }
            when 'do'            { self.exec-do(%s<condition-type>, %s<condition>) }
            when 'loop'          { self.exec-loop(%s<condition-type>, %s<condition>) }
            when 'while'         { self.exec-while(%s<condition>) }
            when 'wend'          { self.exec-wend() }
            when 'exit'          {
                my $kind = (%s<kind> // 'DO').uc;
                if    $kind eq 'FOR'      { die '__EXIT_FOR__' }
                elsif $kind eq 'SUB'      { die '__EXIT_SUB__' }
                elsif $kind eq 'FUNCTION' { die '__EXIT_FUNCTION__' }
                else                      { die '__EXIT_DO__' }
            }
            when 'dim'           { self.exec-dim(%s<items>) }
            when 'read'          { self.exec-read(%s<targets>) }
            when 'data'          { }  # handled in prescan
            when 'restore'       { $!data-pointer = 0 }
            when 'option'        { self.exec-option(%s<text>) }
            when 'sub'           { self.skip-to-end-sub() }
            when 'end-sub'       { self.exec-return() }
            when 'function-def'  { self.skip-to-end-function() }
            when 'end-function'  { self.exec-return() }
            when 'call'          { self.exec-call(%s<name>, %s<args>) }
            when 'def'           { self.exec-def(%s<name>, %s<params>, %s<expression>) }
            when 'declare'       { }  # no-op at runtime
            when 'local'         { }  # handled by sub frame
            when 'input-prompt'  { self.exec-input-prompt(%s<prompt>, %s<variables>) }
            when 'if-block'      { self.exec-if-block(%s<condition>) }
            when 'else'          { self.skip-to-end-if() }
            when 'elseif'        { self.skip-to-end-if() }
            when 'end-if'        { }  # no-op, just marks end
            when 'mat-print'     { self.exec-mat-print(%s<name>) }
            when 'mat-read'      { self.exec-mat-read(%s<name>) }
            when 'mat-redim'     { self.exec-mat-redim-multi(%s<items>) }
            when 'mat-input'     { self.exec-mat-input(%s<name>) }
            when 'mat-assign'    { self.exec-mat-assign(%s<name>, %s<rhs>) }
            when 'select'        { self.exec-select(%s<expression>) }
            when 'case'          { self.exec-case(%s<tests>) }
            when 'case-else'     { self.exec-case-else() }
            when 'end-select'    { self.exec-end-select() }
            # Graphics
            when 'window'        { self.exec-window(%s) }
            when 'set-color'     { $!current-color = resolve-color(%s<color>) }
            when 'set-cursor'    { }  # TODO
            when 'set-text-justify' { }  # TODO
            when 'set-back-color' { $!bg-color = resolve-color(%s<color>) }
            when 'flood'         { }  # TODO
            when 'ask'           { }  # TODO
            when 'plot'          { self.exec-plot(%s<x>, %s<y>, %s<continuation>) }
            when 'plot-end'      { self.exec-plot-end() }
            when 'plot-lines'    { self.exec-plot-lines(%s<coords>) }
            when 'plot-area'     { self.exec-plot-area(%s<coords>) }
            when 'plot-text'     { self.exec-plot-text(%s) }
            when 'line'          { self.exec-line-draw(%s) }
            when 'circle'        { self.exec-circle-draw(%s) }
            when 'box'           { self.exec-box(%s) }
            when 'show'          { self.execute-show() }
            when 'save'          { self.exec-save(%s<filename>) }
            when 'graphics'      { self.exec-set-graphics(%s<mode>) }
            when 'clear' | 'cls' { self.exec-clear() }
            when 'pause'         { self.exec-pause(%s<duration>) }
            when 'get-key'       { %!variables{%s<variable>.uc} = 0 }  # Non-blocking stub
            when 'program'       { }  # no-op, just a label
            when 'open-screen'   { self.exec-open-screen(%s) }
            when 'window-select' { self.exec-window-select(%s) }
            when 'open'          { }  # TODO: file I/O
            when 'close'         { }  # TODO: file I/O
            when 'print-file'    { }  # TODO: file I/O
            when 'input-file'    { }  # TODO: file I/O
            when 'line-input'    { self.exec-line-input(%s) }
            when 'library'       { }  # no-op
            when 'end'           { $!running = False }
            when 'rem'           { }
            default              { say "⚠ Unknown statement: {%s<type>}" if $!debug }
        }
    }

    # ── Expression evaluator ─────────────────────────────────────────────

    method eval(%expr) {
        given %expr<type> {
            when 'number'   { return +%expr<value> }
            when 'string'   { return %expr<value> }
            when 'variable' {
                my $name = %expr<name>;
                return %!variables{$name} if %!variables{$name}:exists;
                return %!variables{$name.uc} if %!variables{$name.uc}:exists;
                return 0;
            }
            when 'array-access' {
                my @idx = %expr<indices>.map({ self.eval($_).Int });
                return self.get-array(%expr<name>, @idx);
            }
            when 'binary' {
                my $l = self.eval(%expr<left>);
                my $r = self.eval(%expr<right>);
                given %expr<operator> {
                    when '+'   {
                        return ($l ~~ Str || $r ~~ Str) && !($l ~~ Numeric && $r ~~ Numeric)
                            ?? $l ~ $r !! self.to-num($l) + self.to-num($r)
                    }
                    when '-'   { return self.to-num($l) - self.to-num($r) }
                    when '*'   { return self.to-num($l) * self.to-num($r) }
                    when '/'   { my $rn = self.to-num($r); return $rn == 0 ?? Inf !! self.to-num($l) / $rn }
                    when '^'   { return self.to-num($l) ** self.to-num($r) }
                    when 'MOD' { return self.to-num($l) % self.to-num($r) }
                    when '&'   { return $l ~ $r }
                }
            }
            when 'unary' {
                my $val = self.eval(%expr<operand>);
                if %expr<operator> eq '-' { return -self.to-num($val) }
                if %expr<operator> eq 'NOT' { return ($val ?? 0 !! 1) }
                return $val;
            }
            when 'comparison' {
                my $l = self.eval(%expr<left>);
                my $r = self.eval(%expr<right>);
                my $is-string = ($l ~~ Str && $l !~~ /^ <[0..9+\-.eE]>+ $/) ||
                                ($r ~~ Str && $r !~~ /^ <[0..9+\-.eE]>+ $/);
                if $is-string {
                    given %expr<operator> {
                        when '=' | '==' { return ($l eq $r ?? 1 !! 0) }
                        when '<>' | '!=' { return ($l ne $r ?? 1 !! 0) }
                        when '<'  { return ($l lt $r ?? 1 !! 0) }
                        when '>'  { return ($l gt $r ?? 1 !! 0) }
                        when '<=' { return ($l le $r ?? 1 !! 0) }
                        when '>=' { return ($l ge $r ?? 1 !! 0) }
                    }
                } else {
                    my $ln = +$l; my $rn = +$r;
                    given %expr<operator> {
                        when '=' | '==' { return ($ln == $rn ?? 1 !! 0) }
                        when '<>' | '!=' { return ($ln != $rn ?? 1 !! 0) }
                        when '<'  { return ($ln <  $rn ?? 1 !! 0) }
                        when '>'  { return ($ln >  $rn ?? 1 !! 0) }
                        when '<=' { return ($ln <= $rn ?? 1 !! 0) }
                        when '>=' { return ($ln >= $rn ?? 1 !! 0) }
                    }
                }
            }
            when 'logical' {
                my $l = self.eval(%expr<left>);
                my $r = self.eval(%expr<right>);
                given %expr<operator> {
                    when 'AND' { return ($l && $r ?? 1 !! 0) }
                    when 'OR'  { return ($l || $r ?? 1 !! 0) }
                }
            }
            when 'function' {
                my $name = %expr<name>.uc;
                my @args = %expr<args>.map({ self.eval($_) });
                # Resolve ambiguity: array access or function call?
                if %!arrays{$name}:exists {
                    my @idx = @args.map(*.Int);
                    return self.get-array($name, @idx);
                }
                # Check user-defined functions first
                if %!user-functions{$name}:exists {
                    my %func = %!user-functions{$name};
                    my %saved;
                    for %func<params>.kv -> $i, $p {
                        %saved{$p} = %!variables{$p} if %!variables{$p}:exists;
                        %!variables{$p} = @args[$i] if $i < @args.elems;
                    }
                    my $result = self.eval(%func<expression>);
                    for %func<params> -> $p {
                        if %saved{$p}:exists { %!variables{$p} = %saved{$p} }
                        else { %!variables{$p}:delete }
                    }
                    return $result;
                }
                # Multi-line FUNCTION...END FUNCTION
                if %!subroutines{$name}:exists {
                    my $func-line = %!subroutines{$name};
                    my %func-stmt = @!program[$func-line]<statement>;
                    if (%func-stmt<type> // '') eq 'function-def' {
                        return self.exec-function-call($name, %func-stmt<params> // [], @args);
                    }
                }
                # Special functions that need interpreter state
                if $name eq 'SIZE' {
                    # SIZE(array-name, dim) — returns dimension size
                    my $arr-name = %expr<args>[0]<name>.uc // '';
                    my $dim = @args.elems > 1 ?? @args[1].Int !! 1;
                    if %!arrays{$arr-name}:exists {
                        my $a = %!arrays{$arr-name};
                        return $a.elems - 1;  # True BASIC arrays are 0-based internally
                    }
                    return 0;
                }
                if $name eq 'UBOUND' || $name eq 'LBOUND' {
                    my $arr-name = (%expr<args>[0]<name> // '').uc;
                    my $dim = @args.elems > 1 ?? @args[1].Int !! 1;
                    if $name eq 'LBOUND' {
                        return $!option-base;
                    }
                    if %!arrays{$arr-name}:exists {
                        my $a = %!arrays{$arr-name};
                        if $dim == 1 {
                            return $a.elems - 1;
                        } elsif $dim == 2 && $a[1] ~~ Array {
                            return $a[1].elems - 1;
                        }
                    }
                    return 0;
                }
                if $name eq 'NUM' || $name eq 'NUM$' {
                    return +@args[0] if @args;
                    return 0;
                }
                if $name eq 'DET' {
                    # Determinant of a 2D array
                    my $arr-name = (%expr<args>[0]<name> // '').uc;
                    if %!arrays{$arr-name}:exists {
                        return self.matrix-det($arr-name);
                    }
                    return 0;
                }
                if $name eq 'DOT' {
                    # Dot product of two arrays
                    my $a-name = (%expr<args>[0]<name> // '').uc;
                    my $b-name = (%expr<args>[1]<name> // '').uc;
                    if (%!arrays{$a-name}:exists) && (%!arrays{$b-name}:exists) {
                        my @a = %!arrays{$a-name}.flat;
                        my @b = %!arrays{$b-name}.flat;
                        return [+] (@a[1..*-1] Z* @b[1..*-1]);
                    }
                    return 0;
                }
                # Built-in
                if %!functions{$name}:exists {
                    return %!functions{$name}.(|@args);
                }
                die "Unknown function: {%expr<name>}";
            }
            when 'array-ref' {
                # Array reference — used in CALL args, just return the name
                return %expr<name>;
            }
            default { die "Unknown expression: {%expr<type>}" }
        }
    }

    # ── Statement implementations ────────────────────────────────────────

    method exec-let(%asgn) {
        my $val = self.eval(%asgn<expression>);
        if %asgn<type> && %asgn<type> eq 'array-assignment' {
            my @idx = %asgn<array><indices>.map({ self.eval($_).Int });
            self.set-array(%asgn<array><name>, @idx, $val);
        } else {
            %!variables{%asgn<variable>.uc} = $val;
        }
    }

    method exec-print(@items) {
        my $out = '';
        for @items -> %item {
            my $val = self.eval(%item<expr>);
            $out ~= $val;
            given %item<separator> {
                when ';' { $out ~= ' ' }
                when ',' { $out ~= "\t" }
            }
        }
        say $out;
    }

    method exec-input($prompt, $var) {
        if $prompt { print self.eval($prompt) }
        else       { print "? " }
        my $raw = ($*IN.get // '').trim;
        %!variables{$var.uc} = $raw ~~ /^ <[0..9+\-.eE]>+ $/ ?? +$raw !! ($raw eq '' ?? 0 !! $raw);
    }

    method exec-if(%s) {
        my $cond = self.eval(%s<condition>);
        if $cond {
            self.execute-statement({ statement => %s<then-stmt> });
        } elsif %s<else-stmt> {
            self.execute-statement({ statement => %s<else-stmt> });
        }
    }

    method exec-goto($target) {
        my $idx = @!program.first(-> %s { %s<line-number>.defined && %s<line-number> == $target }, :k);
        die "Line $target not found" unless $idx.defined;
        $!current-line = $idx - 1;
    }

    method exec-gosub($target) {
        @!call-stack.push($!current-line);
        self.exec-goto($target);
    }

    method exec-return() {
        self.return-from-sub();
    }

    method exec-for($var, %start, %end, %step) {
        my $v = $var.uc;
        my $start-val = self.eval(%start);
        my $end-val = self.eval(%end);
        my $step-val = self.eval(%step);
        %!variables{$v} = $start-val;
        # Check if loop should execute at all
        my $enter = $step-val > 0 ?? $start-val <= $end-val !! $start-val >= $end-val;
        if $enter {
            @!for-stack.push({ var => $v, end => $end-val, step => $step-val, line => $!current-line });
        } else {
            self.skip-to-after-next();
        }
    }

    method exec-next($var) {
        die "NEXT without FOR" unless @!for-stack;
        my %f = @!for-stack[*-1];
        %!variables{%f<var>} += %f<step>;
        my $eps = 1e-10;
        my $cont = %f<step> > 0
            ?? %!variables{%f<var>} <= %f<end> + $eps
            !! %!variables{%f<var>} >= %f<end> - $eps;
        if $cont { $!current-line = %f<line> }
        else     { @!for-stack.pop }
    }

    method exec-do($cond-type, $cond) {
        if $cond-type && $cond {
            my $val = self.eval($cond);
            my $enter = ($cond-type.trim.uc eq 'WHILE') ?? $val !! !$val;
            if $enter {
                # Only push if not re-entering from LOOP
                unless @!do-stack && @!do-stack[*-1] == $!current-line {
                    @!do-stack.push($!current-line);
                }
            } else {
                @!do-stack.pop if @!do-stack && @!do-stack[*-1] == $!current-line;
                self.skip-to-after-loop();
            }
        } else {
            # Plain DO — only push if not already on top
            unless @!do-stack && @!do-stack[*-1] == $!current-line {
                @!do-stack.push($!current-line);
            }
        }
    }

    method exec-loop($cond-type, $cond) {
        unless @!do-stack {
            # No matching DO — likely after EXIT DO, just continue past LOOP
            return;
        }
        my $do-line = @!do-stack[*-1];
        if $cond-type && $cond {
            my $val = self.eval($cond);
            my $repeat = ($cond-type.trim.uc eq 'UNTIL') ?? !$val !! $val;
            if $repeat { $!current-line = $do-line - 1 }  # -1 because main loop will ++
            else       { @!do-stack.pop }
        } else {
            # Plain LOOP — jump back to DO line for re-evaluation
            $!current-line = $do-line - 1;  # -1 because main loop will ++
        }
    }

    method exec-while($cond) {
        my $val = self.eval($cond);
        if $val {
            @!while-stack.push($!current-line);
        } else {
            self.skip-to-wend();
        }
    }

    method exec-wend() {
        die "WEND without WHILE" unless @!while-stack;
        $!current-line = @!while-stack[*-1] - 1;
        # The WHILE will re-evaluate the condition
    }

    method exec-dim(@items) {
        for @items -> %item {
            my @dims = %item<dimensions>.map({ self.eval($_).Int });
            my $is-string = %item<name>.ends-with('$');
            %!arrays{%item<name>.uc} = self.make-array(@dims, :string($is-string));
        }
    }

    method exec-read(@targets) {
        for @targets -> $target {
            die "Out of DATA" if $!data-pointer >= @!data-values.elems;
            my $val = @!data-values[$!data-pointer++];
            if $target ~~ Hash && $target<type> eq 'array-access' {
                my @indices = $target<indices>.map: { self.eval($_).Int };
                self.set-array($target<name>, @indices, $val);
            } elsif $target ~~ Hash && $target<type> eq 'variable' {
                %!variables{$target<name>.uc} = $val;
            } else {
                # Legacy format: plain string
                %!variables{$target.uc} = $val;
            }
        }
    }

    method exec-def($name, @params, %expr) {
        %!user-functions{$name.uc} = { params => @params.map(*.uc).Array, expression => %expr };
    }

    method exec-call($name, @arg-exprs) {
        my $sub-name = $name.uc;
        die "SUB $sub-name not found" unless %!subroutines{$sub-name}:exists;
        # Get SUB definition line to read params
        my $sub-line = %!subroutines{$sub-name};
        my %sub-stmt = @!program[$sub-line]<statement>;
        my @params = (%sub-stmt<params> // []).flat.grep(*.defined);
        # Evaluate arguments and bind params
        my %saved-vars;
        my %saved-arrays;
        for @params.kv -> $i, $raw-p {
            last if $i >= @arg-exprs.elems;
            my $p = ~$raw-p;
            my $is-array = $p ~~ /\(\s*\,?\s*\)\s*$/;
            $p = $p.subst(/\(\s*\,?\s*\)/, '') if $is-array;
            $p = $p.uc;
            my $arg = @arg-exprs[$i];
            if $is-array || ($arg ~~ Hash && ($arg<type> // '') eq 'array-ref') {
                # Array parameter — alias the array
                my $arr-name = ($arg ~~ Hash && $arg<name>) ?? $arg<name>.uc !! $p;
                %saved-arrays{$p} = %!arrays{$p} if %!arrays{$p}:exists;
                %!arrays{$p} = %!arrays{$arr-name} if %!arrays{$arr-name}:exists;
            } else {
                # Value parameter
                %saved-vars{$p} = %!variables{$p} if %!variables{$p}:exists;
                %!variables{$p} = self.eval($arg);
            }
        }
        @!call-stack.push({
            line          => $!current-line,
            saved-vars    => %saved-vars,
            saved-arrays  => %saved-arrays,
            params        => @params.map({ .subst(/\(\s*\,?\s*\)/, '').uc }).Array,
            array-params  => @params.grep(* ~~ /\(\s*\,?\s*\)\s*$/).map({ .subst(/\(\s*\,?\s*\)/, '').uc }).Array,
        });
        $!current-line = $sub-line;
    }

    method return-from-sub() {
        die "RETURN without CALL" unless @!call-stack;
        my $frame = @!call-stack.pop;
        if $frame ~~ Hash && ($frame<line>:exists) {
            # Restore value variables
            if $frame<saved-vars> {
                for $frame<params>.flat -> $p {
                    next if $frame<array-params> && $p ∈ $frame<array-params>.flat;
                    if $frame<saved-vars>{$p}:exists { %!variables{$p} = $frame<saved-vars>{$p} }
                    else { %!variables{$p}:delete }
                }
            } elsif $frame<saved> {
                # Legacy format
                for ($frame<params> // []).flat -> $p {
                    if $frame<saved>{$p}:exists { %!variables{$p} = $frame<saved>{$p} }
                    else { %!variables{$p}:delete }
                }
            }
            # Restore arrays
            if $frame<saved-arrays> {
                for $frame<saved-arrays>.kv -> $k, $v {
                    %!arrays{$k} = $v;
                }
            }
            $!current-line = $frame<line>;
            # Main loop will increment $!current-line
        } else {
            $!current-line = $frame;  # GOSUB style
        }
    }

    # Multi-line FUNCTION call (synchronous execution within eval)
    method exec-function-call($name, @param-defs, @args) {
        my @params = @param-defs.grep(*.defined).map(*.Str.uc);
        # Save caller state
        my $saved-line = $!current-line;
        my %saved-vars;
        for @params -> $p {
            %saved-vars{$p} = %!variables{$p} if %!variables{$p}:exists;
        }
        # Also save the function-name variable (return value holder)
        %saved-vars{$name} = %!variables{$name} if %!variables{$name}:exists;
        # Bind parameters
        for @params.kv -> $i, $p {
            %!variables{$p} = @args[$i] if $i < @args.elems;
        }
        # Initialize function return variable to 0
        %!variables{$name} = 0;
        # Execute function body starting after FUNCTION line
        my $func-line = %!subroutines{$name};
        $!current-line = $func-line + 1;
        while $!current-line < @!program.elems {
            my %stmt = @!program[$!current-line];
            my $type = %stmt<statement><type> // '';
            last if $type eq 'end-function';
            self.execute-statement(%stmt);
            $!current-line++;
        }
        # Get return value (the variable named after the function)
        my $result = %!variables{$name} // 0;
        # Restore caller state
        for @params -> $p {
            if %saved-vars{$p}:exists { %!variables{$p} = %saved-vars{$p} }
            else { %!variables{$p}:delete }
        }
        if %saved-vars{$name}:exists { %!variables{$name} = %saved-vars{$name} }
        else { %!variables{$name}:delete }
        $!current-line = $saved-line;
        return $result;
    }

    # SELECT CASE
    method exec-select(%expr) {
        my $val = self.eval(%expr);
        @!select-stack.push({ value => $val, matched => False });
    }

    method exec-case(@tests) {
        die "CASE without SELECT" unless @!select-stack;
        my %sel = @!select-stack[*-1];
        if %sel<matched> {
            self.skip-to-end-select();
            return;
        }
        my $val = %sel<value>;
        my $match = False;
        for @tests -> %test {
            if %test<to>:exists {
                $match = True if $val >= self.eval(%test<from>) && $val <= self.eval(%test<to>);
            } else {
                $match = True if $val == self.eval(%test<value>);
            }
        }
        if $match { @!select-stack[*-1]<matched> = True }
        else { self.skip-to-next-case() }
    }

    method exec-case-else() {
        die "CASE ELSE without SELECT" unless @!select-stack;
        if @!select-stack[*-1]<matched> {
            self.skip-to-end-select();
        }
    }

    method exec-end-select() {
        @!select-stack.pop if @!select-stack;
    }

    # ── Skip helpers ─────────────────────────────────────────────────────

    method skip-to-after-loop() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'do';
            $depth-- if $t eq 'loop';
            last if $depth == 0;
        }
        # Pop DO stack entry so LOOP doesn't re-enter
        @!do-stack.pop if @!do-stack;
    }

    method skip-to-after-next() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'for';
            $depth-- if $t eq 'next';
            last if $depth == 0;
        }
    }

    method skip-to-end-sub() {
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            last if (@!program[$!current-line]<statement><type> // '') eq 'end-sub';
        }
    }

    method skip-to-end-function() {
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            last if (@!program[$!current-line]<statement><type> // '') eq 'end-function';
        }
    }

    method skip-to-end-if() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'if-block';
            $depth-- if $t eq 'end-if';
            last if $depth == 0;
        }
    }

    method skip-to-else-or-end-if() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'if-block';
            if $depth == 1 && ($t eq 'else' || $t eq 'elseif' || $t eq 'end-if') {
                last;
            }
            $depth-- if $t eq 'end-if';
        }
    }

    method exec-option($text) {
        my $t = $text.uc;
        if $t ~~ /:i nolet/ { $!option-nolet = True }
        if $t ~~ /:i base \s+ 0/ { $!option-base = 0 }
        if $t ~~ /:i base \s+ 1/ { $!option-base = 1 }
        # OPTION ANGLE DEGREES / RADIANS handled later if needed
    }

    method exec-if-block(%cond) {
        my $result = self.eval(%cond);
        unless $result {
            self.skip-to-else-or-end-if();
        }
    }

    method exec-input-prompt($prompt-expr, @vars) {
        my $prompt = self.eval($prompt-expr);
        print $prompt;
        my $line = $*IN.get // '';
        my @vals = $line.split(',').map(*.trim);
        for @vars.kv -> $i, $var {
            my $raw = $i < @vals.elems ?? @vals[$i] !! '';
            %!variables{$var.uc} = $raw ~~ /^ <[0..9+\-.eE]>+ $/ ?? +$raw !! ($raw eq '' ?? 0 !! $raw);
        }
    }

    method exec-mat-print($name) {
        my $n = $name.uc;
        if %!arrays{$n}:exists {
            my $a = %!arrays{$n};
            my &fmt = -> $v { $v ~~ Str ?? $v !! ($v // 0).fmt('%g') };
            if $a[1] ~~ Array {
                for 1..^$a.elems -> $r {
                    say $a[$r][1..*-1].map(&fmt).join("\t");
                }
            } else {
                say $a[1..*-1].map(&fmt).join(' ');
            }
        } else {
            say "⚠ Array $n not defined";
        }
    }

    method exec-mat-read($name) {
        my $n = $name.uc;
        return unless %!arrays{$n}:exists;
        my @a = %!arrays{$n};
        self.mat-read-fill($n, @a);
    }

    method mat-read-fill($name, @arr) {
        # Fill array from DATA
        if @arr[0] ~~ Array {
            for @arr.kv -> $i, @sub {
                self.mat-read-fill($name, @sub);
            }
        } else {
            for @arr.keys -> $i {
                die "Out of DATA" if $!data-pointer >= @!data-values.elems;
                @arr[$i] = @!data-values[$!data-pointer++];
            }
        }
    }

    method exec-mat-redim($name, @dim-exprs) {
        my $n = $name.uc;
        my @dims = @dim-exprs.map: { self.eval($_).Int };
        if %!arrays{$n}:exists {
            my @old = %!arrays{$n}.Array;
            %!arrays{$n} = self.make-array(@dims);
            # Copy old values for 1D arrays
            if @dims.elems == 1 {
                for ^min(@old.elems, @dims[0] + 1) -> $i {
                    %!arrays{$n}[$i] = @old[$i];
                }
            }
        } else {
            %!arrays{$n} = self.make-array(@dims);
        }
    }

    method exec-mat-input($name) {
        my $n = $name.uc;
        return unless %!arrays{$n}:exists;
        say "? (enter values for $n)";
        my $line = $*IN.get // '';
        my @vals = $line.split(',').map(*.trim);
        my @a = %!arrays{$n};
        for @vals.kv -> $i, $v {
            @a[$i] = +$v if $i < @a.elems;
        }
    }

    method exec-mat-redim-multi(@items) {
        for @items -> $item {
            my $n = ($item ~~ Hash ?? $item<name> !! ~$item).uc;
            my @dim-exprs = $item ~~ Hash ?? $item<dimensions>.flat !! [];
            my @dims = @dim-exprs.map: { self.eval($_).Int };
            if %!arrays{$n}:exists {
                my @old = %!arrays{$n}.Array;
                %!arrays{$n} = self.make-array(@dims);
                # Copy old values for 1D
                if @dims.elems == 1 {
                    for ^min(@old.elems, @dims[0] + 1) -> $i {
                        %!arrays{$n}[$i] = @old[$i];
                    }
                }
            } else {
                %!arrays{$n} = self.make-array(@dims);
            }
        }
    }

    method exec-mat-assign($name, $rhs-text) {
        my $n = $name.uc;
        my $rhs = $rhs-text.trim;

        # MAT C = A * B  (matrix multiply)
        if $rhs ~~ /:i ^ (\w+) \s* '*' \s* (\w+) $ / {
            my $an = (~$0).uc;
            my $bn = (~$1).uc;
            return unless (%!arrays{$an}:exists) && (%!arrays{$bn}:exists);
            my $A = %!arrays{$an};
            my $B = %!arrays{$bn};
            my $ra = $A.elems - 1;  # rows of A (1-indexed)
            my $ca = ($A[1] ~~ Array ?? $A[1].elems - 1 !! 1);
            my $rb = $B.elems - 1;
            my $cb = ($B[1] ~~ Array ?? $B[1].elems - 1 !! 1);
            if $ca != $rb {
                say "Warning: MAT multiply dimension mismatch: A is {$ra}x{$ca}, B is {$rb}x{$cb}" if $!debug;
                return;
            }
            %!arrays{$n} = self.make-array([$ra, $cb]);
            for 1..$ra -> $i {
                for 1..$cb -> $j {
                    my $sum = 0;
                    for 1..$ca -> $k {
                        my $aval = ($A[$i] ~~ Array ?? $A[$i][$k] !! $A[$i]);
                        my $bval = ($B[$k] ~~ Array ?? $B[$k][$j] !! $B[$k]);
                        $sum += self.to-num($aval) * self.to-num($bval);
                    }
                    %!arrays{$n}[$i][$j] = $sum;
                }
            }
            return;
        }

        # MAT C = A + B or MAT C = A - B (element-wise add/subtract)
        if $rhs ~~ /:i ^ (\w+) \s* (<[+\-]>) \s* (\w+) $ / {
            my $an = (~$0).uc;
            my $op = ~$1;
            my $bn = (~$2).uc;
            return unless (%!arrays{$an}:exists) && (%!arrays{$bn}:exists);
            my $A = %!arrays{$an};
            my $B = %!arrays{$bn};
            my $rows = $A.elems - 1;
            my $cols = ($A[1] ~~ Array ?? $A[1].elems - 1 !! 1);
            %!arrays{$n} = self.make-array([$rows, $cols]);
            for 1..$rows -> $i {
                for 1..$cols -> $j {
                    my $av = self.to-num($A[$i] ~~ Array ?? $A[$i][$j] !! $A[$i]);
                    my $bv = self.to-num($B[$i] ~~ Array ?? $B[$i][$j] !! $B[$i]);
                    %!arrays{$n}[$i][$j] = $op eq '+' ?? $av + $bv !! $av - $bv;
                }
            }
            return;
        }

        # MAT A = TRN(B)  (transpose)
        if $rhs ~~ /:i ^ 'TRN' \s* '(' \s* (\w+) \s* ')' $ / {
            my $sn = (~$0).uc;
            return unless %!arrays{$sn}:exists;
            my $S = %!arrays{$sn};
            my $rows = $S.elems - 1;
            my $cols = ($S[1] ~~ Array ?? $S[1].elems - 1 !! 1);
            %!arrays{$n} = self.make-array([$cols, $rows]);
            for 1..$rows -> $i {
                for 1..$cols -> $j {
                    my $val = ($S[$i] ~~ Array ?? $S[$i][$j] !! $S[$i]);
                    %!arrays{$n}[$j][$i] = $val;
                }
            }
            return;
        }

        # MAT A = INV(B)  (matrix inverse via Gauss-Jordan)
        if $rhs ~~ /:i ^ 'INV' \s* '(' \s* (\w+) \s* ')' $ / {
            my $sn = (~$0).uc;
            return unless %!arrays{$sn}:exists;
            my $S = %!arrays{$sn};
            my $sz = $S.elems - 1;
            # Build augmented matrix [S | I]
            my @m;
            for 1..$sz -> $i {
                @m[$i] = [];
                for 1..$sz -> $j {
                    @m[$i][$j] = self.to-num($S[$i] ~~ Array ?? $S[$i][$j] !! $S[$i]);
                }
                for 1..$sz -> $j {
                    @m[$i][$sz + $j] = ($i == $j ?? 1 !! 0);
                }
            }
            # Gauss-Jordan elimination
            for 1..$sz -> $k {
                # Partial pivoting
                my $max-val = @m[$k][$k].abs;
                my $max-row = $k;
                for ($k+1)..$sz -> $i {
                    if @m[$i][$k].abs > $max-val { $max-val = @m[$i][$k].abs; $max-row = $i }
                }
                if $max-row != $k { (@m[$k], @m[$max-row]) = (@m[$max-row], @m[$k]) }
                my $pivot = @m[$k][$k];
                if $pivot.abs < 1e-15 {
                    say "Warning: near-singular matrix in INV" if $!debug;
                    return;  # leave result array unchanged
                }
                for 1..(2 * $sz) -> $j { @m[$k][$j] /= $pivot }
                for 1..$sz -> $i {
                    next if $i == $k;
                    my $f = @m[$i][$k];
                    for 1..(2 * $sz) -> $j { @m[$i][$j] -= $f * @m[$k][$j] }
                }
            }
            %!arrays{$n} = self.make-array([$sz, $sz]);
            for 1..$sz -> $i {
                for 1..$sz -> $j {
                    %!arrays{$n}[$i][$j] = @m[$i][$sz + $j];
                }
            }
            return;
        }

        # MAT A = IDN  or MAT A = IDN(n)  (identity matrix)
        if $rhs ~~ /:i ^ 'IDN' [ '(' (.+?) ')' ]? $ / {
            my $sz;
            if $0 {
                $sz = self.to-num(~$0).Int;
                %!arrays{$n} = self.make-array([$sz, $sz]);
            } else {
                return unless %!arrays{$n}:exists;
                $sz = %!arrays{$n}.elems - 1;
            }
            for 1..$sz -> $i {
                for 1..$sz -> $j {
                    %!arrays{$n}[$i][$j] = ($i == $j ?? 1 !! 0);
                }
            }
            return;
        }

        # MAT A = B (copy)
        my $src = $rhs.uc;
        if %!arrays{$src}:exists {
            %!arrays{$n} = %!arrays{$src}.deepmap(* + 0);
            return;
        }

        # MAT A = ZER / CON / scalar
        if $rhs ~~ /:i ^ 'ZER' [ '(' (.+?) ')' ]? $ / {
            if $0 {
                my @dims = (~$0).split(',').map({ self.to-num($_.trim).Int });
                %!arrays{$n} = self.make-array(@dims);
            } elsif %!arrays{$n}:exists {
                %!arrays{$n} = %!arrays{$n}.deepmap({ 0 });
            }
        }
        elsif $rhs ~~ /:i ^ 'CON' [ '(' (.+?) ')' ]? $ / {
            if $0 {
                my @dims = (~$0).split(',').map({ self.to-num($_.trim).Int });
                %!arrays{$n} = self.make-array(@dims);
                %!arrays{$n} = %!arrays{$n}.deepmap({ 1 });
            } elsif %!arrays{$n}:exists {
                %!arrays{$n} = %!arrays{$n}.deepmap({ 1 });
            }
        }
        elsif $rhs ~~ /^ <[\d.\-]>+ $/ {
            my $val = +$rhs;
            %!arrays{$n} = %!arrays{$n}.deepmap({ $val }) if %!arrays{$n}:exists;
        }
        # MAT A = (expression) * B  — scalar multiply
        elsif $rhs ~~ /:i ^ '(' (.+?) ')' \s* '*' \s* (\w+) $ / {
            my $scalar = self.to-num(~$0);
            my $sn = (~$1).uc;
            return unless %!arrays{$sn}:exists;
            %!arrays{$n} = %!arrays{$sn}.deepmap(-> $v { self.to-num($v) * $scalar });
        }
    }

    method skip-to-wend() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'while';
            $depth-- if $t eq 'wend';
            last if $depth == 0;
        }
    }

    method skip-to-next-case() {
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            return if $t eq 'case' || $t eq 'case-else' || $t eq 'end-select';
        }
    }

    method skip-to-end-select() {
        my $depth = 1;
        while $!current-line < @!program.elems - 1 {
            $!current-line++;
            my $t = @!program[$!current-line]<statement><type> // '';
            $depth++ if $t eq 'select';
            $depth-- if $t eq 'end-select';
            last if $depth == 0;
        }
    }

    # ── Array helpers ────────────────────────────────────────────────────

    method make-array(@dims, :$string = False) {
        my $default = $string ?? '' !! 0;
        if @dims.elems == 1 { return [$default xx (@dims[0] + 1)] }
        my @a;
        for 0..@dims[0] { @a.push(self.make-array(@dims[1..*], :$string)) }
        return @a;
    }

    method get-array($name, @idx) {
        my $n = $name.uc;
        return 0 unless %!arrays{$n}:exists;
        my $a = %!arrays{$n};
        for @idx -> $i { $a = $a[$i] // return 0 }
        return $a;
    }

    method set-array($name, @idx, $val) {
        my $n = $name.uc;
        unless %!arrays{$n}:exists {
            # Auto-DIM with default size 10 per dimension
            %!arrays{$n} = self.make-array(@idx.map({ max($_, 10) }));
        }
        my $a = %!arrays{$n};
        for @idx[0..*-2] -> $i { $a = $a[$i] }
        $a[@idx[*-1]] = $val;
    }

    method matrix-det($name) {
        my $m = %!arrays{$name.uc};
        return 0 unless $m;
        my $n = $m.elems - 1;  # rows 1..n
        # Copy to plain 2D array (1-indexed)
        my @a;
        for 1..$n -> $i {
            @a[$i] = [];
            for 1..$n -> $j {
                @a[$i][$j] = ($m[$i] ~~ Array ?? $m[$i][$j] !! $m[$i]) + 0;
            }
        }
        # LU decomposition in-place
        my $det = 1e0;
        for 1..$n -> $k {
            if @a[$k][$k] == 0 {
                # Pivot
                my $found = False;
                for ($k+1)..$n -> $i {
                    if @a[$i][$k] != 0 {
                        (@a[$k], @a[$i]) = (@a[$i], @a[$k]);
                        $det = -$det;
                        $found = True;
                        last;
                    }
                }
                return 0 unless $found;
            }
            $det *= @a[$k][$k];
            for ($k+1)..$n -> $i {
                my $factor = @a[$i][$k] / @a[$k][$k];
                for ($k+1)..$n -> $j {
                    @a[$i][$j] -= $factor * @a[$k][$j];
                }
            }
        }
        return $det;
    }

    # ── Graphics statement implementations ───────────────────────────────

    method exec-window(%s) {
        %!window = x-min => self.eval(%s<x1>).Num, x-max => self.eval(%s<x2>).Num,
                   y-min => self.eval(%s<y1>).Num, y-max => self.eval(%s<y2>).Num;
        $!graphics-used = True;
    }

    method exec-plot($xexpr, $yexpr, $continuation = False) {
        my $x = self.eval($xexpr).Num;
        my $y = self.eval($yexpr).Num;
        if $continuation {
            @!current-strip.push: %( x => $x, y => $y );
        } else {
            if @!current-strip.elems > 0 {
                @!current-strip.push: %( x => $x, y => $y );
                @!plot-line-strips.push: %( points => @!current-strip.Array, color => $!current-color );
                @!current-strip = ();
            } else {
                @!plot-points.push: %( x => $x, y => $y, color => $!current-color );
            }
        }
        $!graphics-used = True;
    }

    method exec-plot-end() {
        if @!current-strip.elems > 0 {
            @!plot-line-strips.push: %( points => @!current-strip.Array, color => $!current-color );
            @!current-strip = ();
        }
    }

    method exec-plot-lines(@coords) {
        my @pts = @coords.map({ %( x => self.eval($_<x>).Num, y => self.eval($_<y>).Num ) });
        @!plot-line-strips.push: %( points => @pts, color => $!current-color );
        $!graphics-used = True;
    }

    method exec-plot-area(@coords) {
        my @pts = @coords.map({ %( x => self.eval($_<x>).Num, y => self.eval($_<y>).Num ) });
        @!plot-areas.push: %( points => @pts, color => $!current-color );
        $!graphics-used = True;
    }

    method exec-plot-text(%s) {
        @!plot-texts.push: %(
            x => self.eval(%s<x>).Num, y => self.eval(%s<y>).Num,
            text => self.eval(%s<text>), color => $!current-color,
        );
        $!graphics-used = True;
    }

    method exec-line-draw(%s) {
        my ($x1, $y1) = self.eval(%s<x1>).Num, self.eval(%s<y1>).Num;
        my ($x2, $y2) = self.eval(%s<x2>).Num, self.eval(%s<y2>).Num;
        @!plot-lines.push: %( x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2, color => $!current-color );
        $!graphics-used = True;
    }

    method exec-circle-draw(%s) {
        my ($x, $y, $r) = self.eval(%s<x>).Num, self.eval(%s<y>).Num, self.eval(%s<radius>).Num;
        @!plot-circles.push: %( x => $x, y => $y, radius => $r, color => $!current-color );
        $!graphics-used = True;
    }

    method exec-box(%s) {
        my ($x1, $y1) = self.eval(%s<x1>).Num, self.eval(%s<y1>).Num;
        my ($x2, $y2) = self.eval(%s<x2>).Num, self.eval(%s<y2>).Num;
        my $sub = (%s<subtype> // 'LINES').uc;
        @!plot-boxes.push: %( x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2,
                              color => $!current-color, subtype => $sub,
                              fill => ($sub eq 'AREA' || $sub eq 'CLEAR') );
        $!graphics-used = True;
    }

    method exec-save($filename-expr) {
        $!plot-file = $filename-expr ?? self.eval($filename-expr) !! 'plot.svg';
        self.render-svg($!plot-file);
        say "Plot saved to $!plot-file";
    }

    method exec-set-graphics($mode) {
        my $m = $mode.lc;
        if $m eq any(<gtk web svg ascii popup>) {
            $!graphics-mode = $m;
            say "Graphics mode: $m" if $!debug;
        } else {
            say "Unknown graphics mode '$mode'. Use: gtk, web, svg, ascii";
        }
    }

    method exec-clear() {
        @!plot-points = []; @!plot-lines = []; @!plot-circles = [];
        @!plot-line-strips = []; @!plot-areas = []; @!plot-texts = [];
        @!plot-boxes = [];
    }

    method exec-pause($dur-expr) {
        my $secs = $dur-expr ?? self.eval($dur-expr) !! 0;
        if $secs > 0 { sleep $secs }
        elsif $*IN.t { print "Press Enter to continue..."; $*IN.get }
        # Skip pause when stdin is not a TTY (non-interactive)
    }

    method exec-open-screen(%s) {
        my $ch = self.eval(%s<channel>).Int;
        my ($x1, $x2) = self.eval(%s<x1>).Num, self.eval(%s<x2>).Num;
        my ($y1, $y2) = self.eval(%s<y1>).Num, self.eval(%s<y2>).Num;
        %!viewports{$ch} = %( x1 => $x1, x2 => $x2, y1 => $y1, y2 => $y2 );
        $!active-viewport = $ch;
        $!graphics-used = True;
    }

    method exec-window-select(%s) {
        my $ch = self.eval(%s<channel>).Int;
        $!active-viewport = $ch;
        $!graphics-used = True;
    }

    method exec-line-input(%s) {
        if %s<prompt> {
            my $p = self.eval(%s<prompt>);
            print $p;
        }
        my $line = ($*IN.get // '');
        %!variables{%s<variable>.uc} = $line;
    }

    # ── Graphics rendering dispatch ──────────────────────────────────────

    method execute-show() {
        unless @!plot-points || @!plot-lines || @!plot-circles ||
               @!plot-line-strips || @!plot-areas || @!plot-texts || @!plot-boxes {
            say "No graphics data. Use PLOT, LINE, CIRCLE, etc.";
            return;
        }

        $!graphics-shown = True;

        # Auto-detect: use GTK if DISPLAY available and stdin is a TTY, else SVG
        my $mode = $!graphics-mode;
        if $mode eq 'auto' {
            if %*ENV<DISPLAY> && $*IN.t {
                $mode = 'gtk';
            } else {
                $mode = 'svg';
            }
        }

        given $mode {
            when 'gtk'           { self.show-gtk() }
            when 'web' | 'popup' { self.show-web() }
            when 'svg'           { self.render-svg($!plot-file); say "Saved: $!plot-file" }
            when 'ascii'         { self.show-ascii() }
            default              { self.show-gtk() }
        }
    }

    # ── SVG rendering ────────────────────────────────────────────────────

    method render-svg(Str $file = 'plot.svg') {
        my $W = 600; my $H = 450; my $M = 50;

        my $xr = %!window<x-max> - %!window<x-min> || 1;
        my $yr = %!window<y-max> - %!window<y-min> || 1;
        my $xs = ($W - 2 * $M) / $xr;
        my $ys = ($H - 2 * $M) / $yr;

        sub tx($x) { $M + ($x - %!window<x-min>) * $xs }
        sub ty($y) { $H - $M - ($y - %!window<y-min>) * $ys }
        sub rgb($c) { my @c = @TB-COLORS[$c min (@TB-COLORS.elems - 1)].flat; "rgb({(@c[0]*255).Int},{(@c[1]*255).Int},{(@c[2]*255).Int})" }

        my @svg;
        @svg.push: '<?xml version="1.0" encoding="UTF-8"?>';
        @svg.push: qq[<svg width="$W" height="$H" xmlns="http://www.w3.org/2000/svg">];
        @svg.push: qq[<rect width="$W" height="$H" fill="white" stroke="#ccc"/>];

        # Axes
        my $plot-bottom = $H - $M;
        my $plot-right = $W - $M;
        if %!window<x-min> <= 0 <= %!window<x-max> {
            my $ax = tx(0);
            @svg.push: qq[<line x1="$ax" y1="$M" x2="$ax" y2="$plot-bottom" stroke="#999" stroke-width="0.5"/>];
        }
        if %!window<y-min> <= 0 <= %!window<y-max> {
            my $ay = ty(0);
            @svg.push: qq[<line x1="$M" y1="$ay" x2="$plot-right" y2="$ay" stroke="#999" stroke-width="0.5"/>];
        }

        # Tick marks and labels
        self.svg-axis-ticks(@svg, $W, $H, $M, &tx, &ty);

        # Filled areas
        for @!plot-areas -> %a {
            my @pts = %a<points>.map({ "{tx($_<x>)},{ty($_<y>)}" });
            @svg.push: qq[<polygon points="{@pts.join(' ')}" fill="{rgb(%a<color>)}" fill-opacity="0.3" stroke="{rgb(%a<color>)}" stroke-width="1"/>];
        }

        # Boxes
        for @!plot-boxes -> %b {
            my ($bx, $by, $bw, $bh) = tx(%b<x1>), ty(%b<y2>), tx(%b<x2>) - tx(%b<x1>), ty(%b<y1>) - ty(%b<y2>);
            my $fill = %b<fill> ?? rgb(%b<color>) !! 'none';
            my $opacity = %b<fill> ?? ' fill-opacity="0.5"' !! '';
            @svg.push: qq[<rect x="$bx" y="$by" width="$bw" height="$bh" fill="$fill"$opacity stroke="{rgb(%b<color>)}" stroke-width="1.5"/>];
        }

        # Lines
        for @!plot-lines -> %l {
            @svg.push: qq[<line x1="{tx(%l<x1>)}" y1="{ty(%l<y1>)}" x2="{tx(%l<x2>)}" y2="{ty(%l<y2>)}" stroke="{rgb(%l<color>)}" stroke-width="1.5"/>];
        }

        # Line strips
        for @!plot-line-strips -> %ls {
            my @pts = %ls<points>.map({ "{tx($_<x>)},{ty($_<y>)}" });
            @svg.push: qq[<polyline points="{@pts.join(' ')}" fill="none" stroke="{rgb(%ls<color>)}" stroke-width="1.5"/>];
        }

        # Circles
        for @!plot-circles -> %c {
            @svg.push: qq[<circle cx="{tx(%c<x>)}" cy="{ty(%c<y>)}" r="{%c<radius> * $xs}" fill="none" stroke="{rgb(%c<color>)}" stroke-width="1.5"/>];
        }

        # Points (rendered as small circles with connected lines for scatter-style)
        if @!plot-points.elems > 1 {
            # Draw connecting line for point series (same color groups)
            my @pts = @!plot-points.map({ "{tx($_<x>)},{ty($_<y>)}" });
            @svg.push: qq[<polyline points="{@pts.join(' ')}" fill="none" stroke="{rgb(@!plot-points[0]<color>)}" stroke-width="1"/>];
        }
        for @!plot-points -> %p {
            @svg.push: qq[<circle cx="{tx(%p<x>)}" cy="{ty(%p<y>)}" r="2.5" fill="{rgb(%p<color>)}"/>];
        }

        # Text
        for @!plot-texts -> %t {
            @svg.push: qq[<text x="{tx(%t<x>)}" y="{ty(%t<y>)}" fill="{rgb(%t<color>)}" font-size="12">{%t<text>}</text>];
        }

        @svg.push: '</svg>';
        $file.IO.spurt(@svg.join("\n"));
    }

    method svg-axis-ticks(@svg, $W, $H, $M, &tx, &ty) {
        sub nice-step($range) {
            my $rough = $range / 5;
            return 1 if $rough <= 0;
            my $mag = 10 ** $rough.log10.floor;
            my $norm = $rough / $mag;
            my $nice = $norm < 1.5 ?? 1 !! $norm < 3 ?? 2 !! $norm < 7 ?? 5 !! 10;
            return $nice * $mag;
        }

        my $xstep = nice-step(%!window<x-max> - %!window<x-min>);
        my $ystep = nice-step(%!window<y-max> - %!window<y-min>);

        my $tick-bottom = $H - $M;
        my $tick-bottom2 = $H - $M + 5;
        my $label-bottom = $H - $M + 18;
        my $tick-left = $M - 5;
        my $label-left = $M - 8;
        my $plot-right = $W - $M;

        # X ticks
        my $x = (%!window<x-min> / $xstep).ceiling * $xstep;
        while $x <= %!window<x-max> {
            my $px = tx($x);
            @svg.push: qq[<line x1="$px" y1="$tick-bottom" x2="$px" y2="$tick-bottom2" stroke="#666"/>];
            my $label = $x == $x.Int ?? $x.Int !! $x.round(0.001);
            @svg.push: qq[<text x="$px" y="$label-bottom" text-anchor="middle" font-size="10" fill="#333">{$label}\</text>];
            $x += $xstep;
        }

        # Y ticks
        my $y = (%!window<y-min> / $ystep).ceiling * $ystep;
        while $y <= %!window<y-max> {
            my $py = ty($y);
            my $label-y = $py + 4;
            @svg.push: qq[<line x1="$tick-left" y1="$py" x2="$M" y2="$py" stroke="#666"/>];
            my $label = $y == $y.Int ?? $y.Int !! $y.round(0.001);
            @svg.push: qq[<text x="$label-left" y="$label-y" text-anchor="end" font-size="10" fill="#333">{$label}\</text>];
            $y += $ystep;
        }
    }

    # ── GTK window display ───────────────────────────────────────────────

    method show-gtk() {
        say "Opening plot window..." if $!debug;

        # Also save SVG for reference
        self.render-svg('plot.svg');

        my $W = 800; my $H = 600; my $M = 60;
        my $renderer = PlotRenderer.new(interp => self, width => $W, height => $H, margin => $M);

        try {
            my Gnome::Gtk3::Main $main .= new;
            my Gnome::Gtk3::Window $win .= new;
            $win.set-title('TrueBASIC Plot');
            $win.set-default-size($W, $H);

            my Gnome::Gtk3::DrawingArea $da .= new;
            $da.register-signal($renderer, 'draw-cb', 'draw');
            $win.register-signal($renderer, 'quit-cb', 'destroy');
            $win.add($da);
            $win.show-all;

            say "Plot window open. Close window to continue.";
            $main.main;

            CATCH {
                default {
                    say "GTK failed ({.message}), opening SVG..." if $!debug;
                    self.open-file('plot.svg');
                }
            }
        }
    }

    # ── Web/HTML5 Canvas display ─────────────────────────────────────────

    method show-web() {
        my $html-file = 'plot.html';
        my $W = 800; my $H = 600; my $M = 60;

        my $xr = %!window<x-max> - %!window<x-min> || 1;
        my $yr = %!window<y-max> - %!window<y-min> || 1;

        my @js;
        @js.push: "var W=$W, H=$H, M=$M;";
        @js.push: "var xmin={%!window<x-min>}, xmax={%!window<x-max>}, ymin={%!window<y-min>}, ymax={%!window<y-max>};";
        @js.push: "function tx(x) \{ return M + (x-xmin)/(xmax-xmin)*(W-2*M); \}";
        @js.push: "function ty(y) \{ return H - M - (y-ymin)/(ymax-ymin)*(H-2*M); \}";

        my @colors = @TB-COLORS.map({ my @c = $_.flat; "\"rgb({(@c[0]*255).Int},{(@c[1]*255).Int},{(@c[2]*255).Int})\"" });
        @js.push: "var colors = [{@colors.join(',')}];";
        @js.push: "function setColor(ctx, c) \{ ctx.strokeStyle = ctx.fillStyle = colors[Math.min(c, colors.length-1)]; \}";

        @js.push: "var c = document.getElementById('plot');";
        @js.push: "var ctx = c.getContext('2d');";
        @js.push: "ctx.fillStyle = 'white'; ctx.fillRect(0,0,W,H);";

        # Axes
        @js.push: "ctx.strokeStyle='#999'; ctx.lineWidth=0.5;";
        if %!window<x-min> <= 0 <= %!window<x-max> {
            @js.push: "ctx.beginPath(); ctx.moveTo(tx(0),M); ctx.lineTo(tx(0),H-M); ctx.stroke();";
        }
        if %!window<y-min> <= 0 <= %!window<y-max> {
            @js.push: "ctx.beginPath(); ctx.moveTo(M,ty(0)); ctx.lineTo(W-M,ty(0)); ctx.stroke();";
        }

        # Areas
        for @!plot-areas -> %a {
            @js.push: "setColor(ctx,{%a<color>}); ctx.globalAlpha=0.3; ctx.beginPath();";
            my $first = True;
            for %a<points>.list -> %p {
                @js.push: ($first ?? "ctx.moveTo" !! "ctx.lineTo") ~ "(tx({%p<x>}),ty({%p<y>}));";
                $first = False;
            }
            @js.push: "ctx.closePath(); ctx.fill(); ctx.globalAlpha=1.0;";
        }

        # Boxes
        for @!plot-boxes -> %b {
            my $bx1 = %b<x1>; my $by1 = %b<y1>; my $bx2 = %b<x2>; my $by2 = %b<y2>;
            my $fill = %b<fill> ?? 'true' !! 'false';
            @js.push: "setColor(ctx,{%b<color>}); ctx.lineWidth=1.5;";
            @js.push: "ctx.beginPath(); ctx.rect(tx({$bx1}),ty({$by2}),tx({$bx2})-tx({$bx1}),ty({$by1})-ty({$by2}));";
            @js.push: ($fill eq 'true' ?? "ctx.globalAlpha=0.5; ctx.fill(); ctx.globalAlpha=1.0; ctx.stroke();" !! "ctx.stroke();");
        }

        # Lines
        @js.push: "ctx.lineWidth=1.5;";
        for @!plot-lines -> %l {
            @js.push: "setColor(ctx,{%l<color>}); ctx.beginPath(); ctx.moveTo(tx({%l<x1>}),ty({%l<y1>})); ctx.lineTo(tx({%l<x2>}),ty({%l<y2>})); ctx.stroke();";
        }

        # Line strips
        for @!plot-line-strips -> %ls {
            @js.push: "setColor(ctx,{%ls<color>}); ctx.beginPath();";
            my $first = True;
            for %ls<points>.list -> %p {
                @js.push: ($first ?? "ctx.moveTo" !! "ctx.lineTo") ~ "(tx({%p<x>}),ty({%p<y>}));";
                $first = False;
            }
            @js.push: "ctx.stroke();";
        }

        # Circles
        for @!plot-circles -> %c {
            @js.push: "setColor(ctx,{%c<color>}); ctx.beginPath(); ctx.arc(tx({%c<x>}),ty({%c<y>}),{%c<radius>}*{$W-2*$M}/{$xr},0,2*Math.PI); ctx.stroke();";
        }

        # Points
        if @!plot-points.elems > 1 {
            @js.push: "setColor(ctx,{@!plot-points[0]<color>}); ctx.lineWidth=1; ctx.beginPath();";
            my $first = True;
            for @!plot-points -> %p {
                @js.push: ($first ?? "ctx.moveTo" !! "ctx.lineTo") ~ "(tx({%p<x>}),ty({%p<y>}));";
                $first = False;
            }
            @js.push: "ctx.stroke();";
        }
        for @!plot-points -> %p {
            @js.push: "setColor(ctx,{%p<color>}); ctx.beginPath(); ctx.arc(tx({%p<x>}),ty({%p<y>}),3,0,2*Math.PI); ctx.fill();";
        }

        # Text
        for @!plot-texts -> %t {
            @js.push: "setColor(ctx,{%t<color>}); ctx.font='12px sans-serif'; ctx.fillText(\"{%t<text>}\",tx({%t<x>}),ty({%t<y>}));";
        }

        my $js-code = @js.join("\n");
        my $html = '<!DOCTYPE html>
<html><head><title>TrueBASIC Plot</title>
<style>body { margin:20px; background:#f0f0f0; font-family:sans-serif; }
canvas { border:1px solid #ccc; background:white; }</style></head>
<body><h3>TrueBASIC Plot</h3>
<canvas id="plot" width="' ~ $W ~ '" height="' ~ $H ~ '"></canvas>
<script>' ~ $js-code ~ '</script></body></html>';

        $html-file.IO.spurt($html);
        say "Plot saved to $html-file";
        self.open-file($html-file);
    }

    # ── ASCII plot ───────────────────────────────────────────────────────

    method show-ascii() {
        my $W = 72; my $H = 24;
        my @grid;
        for 0..^$H -> $r { @grid[$r] = [' ' xx $W] }

        my $xs = $W / (%!window<x-max> - %!window<x-min> || 1);
        my $ys = $H / (%!window<y-max> - %!window<y-min> || 1);
        sub ax($x) { max(0, min($W-1, (($x - %!window<x-min>) * $xs).round)) }
        sub ay($y) { max(0, min($H-1, $H - 1 - (($y - %!window<y-min>) * $ys).round)) }

        # Axes
        if %!window<x-min> <= 0 <= %!window<x-max> { for 0..^$H -> $r { @grid[$r][ax(0)] = '|' } }
        if %!window<y-min> <= 0 <= %!window<y-max> { for 0..^$W -> $c { @grid[ay(0)][$c] = '-' } }

        # Points
        for @!plot-points -> %p { @grid[ay(%p<y>)][ax(%p<x>)] = '*' }

        # Lines (endpoints only in ASCII)
        for @!plot-lines -> %l {
            self.ascii-bresenham(@grid, ax(%l<x1>), ay(%l<y1>), ax(%l<x2>), ay(%l<y2>));
        }

        # Line strips
        for @!plot-line-strips -> %ls {
            my @pts = %ls<points>;
            for 0..^@pts.elems-1 -> $i {
                self.ascii-bresenham(@grid, ax(@pts[$i]<x>), ay(@pts[$i]<y>), ax(@pts[$i+1]<x>), ay(@pts[$i+1]<y>));
            }
        }

        say "ASCII Plot ({%!window<x-min>},{%!window<y-min>}) to ({%!window<x-max>},{%!window<y-max>}):";
        for @grid -> @row { say @row.join('') }
    }

    method ascii-bresenham(@grid, Int $x0, Int $y0, Int $x1, Int $y1) {
        my ($dx, $dy) = ($x1 - $x0).abs, ($y1 - $y0).abs;
        my ($sx, $sy) = ($x0 < $x1 ?? 1 !! -1), ($y0 < $y1 ?? 1 !! -1);
        my $err = $dx - $dy;
        my ($x, $y) = $x0, $y0;
        loop {
            @grid[$y][$x] = '#' if 0 <= $y < @grid.elems && 0 <= $x < @grid[0].elems;
            last if $x == $x1 && $y == $y1;
            my $e2 = 2 * $err;
            if $e2 > -$dy { $err -= $dy; $x += $sx }
            if $e2 <  $dx { $err += $dx; $y += $sy }
        }
    }

    # ── File opener utility ──────────────────────────────────────────────

    method open-file(Str $path) {
        my $abs = $path.IO.absolute;
        for <xdg-open firefox chromium-browser eog> -> $cmd {
            try {
                my $proc = Proc::Async.new($cmd, $abs);
                my $promise = $proc.start;
                sleep 0.5;
                say "Opened with $cmd";
                return;
                CATCH { default { } }
            }
        }
        say "Open manually: $abs";
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# GTK Plot Renderer (Cairo-based drawing for GTK window)
# ══════════════════════════════════════════════════════════════════════════════

class PlotRenderer {
    has $.interp is required;
    has $.width  is required;
    has $.height is required;
    has $.margin is required;

    method draw-cb(cairo_t $cr-native) {
        my Gnome::Cairo $cr .= new(:native-object($cr-native));
        self.render($cr);
    }

    method quit-cb() {
        Gnome::Gtk3::Main.quit;
    }

    method render(Gnome::Cairo $cr) {
        my $W = $.width; my $H = $.height; my $M = $.margin;
        my %win = $.interp.window;
        my $xr = %win<x-max> - %win<x-min> || 1;
        my $yr = %win<y-max> - %win<y-min> || 1;
        my $xs = ($W - 2 * $M) / $xr;
        my $ys = ($H - 2 * $M) / $yr;

        sub tx($x) { $M + ($x - %win<x-min>) * $xs }
        sub ty($y) { $H - $M - ($y - %win<y-min>) * $ys }
        sub set-cr-color($cr, $c) {
            my @colors = (0,0,0), (1,1,1), (1,0,0), (0,0.8,0), (0,0,1),
                         (0,0.8,0.8), (1,0,1), (1,1,0), (1,0.5,0), (0.5,0.5,0.5);
            my @rgb = @colors[$c min (@colors.elems - 1)].flat;
            $cr.set-source-rgb(@rgb[0], @rgb[1], @rgb[2]);
        }

        # White background
        $cr.set-source-rgb(1, 1, 1);
        $cr.paint;

        # Draw border
        $cr.set-source-rgb(0.8, 0.8, 0.8);
        $cr.rectangle($M.Num, $M.Num, ($W - 2*$M).Num, ($H - 2*$M).Num);
        $cr.stroke;

        # Axes
        $cr.set-source-rgb(0.4, 0.4, 0.4);
        $cr.set-line-width(0.5);
        if %win<x-min> <= 0 <= %win<x-max> {
            $cr.move-to(tx(0).Num, $M.Num);
            $cr.line-to(tx(0).Num, ($H - $M).Num);
            $cr.stroke;
        }
        if %win<y-min> <= 0 <= %win<y-max> {
            $cr.move-to($M.Num, ty(0).Num);
            $cr.line-to(($W - $M).Num, ty(0).Num);
            $cr.stroke;
        }

        # Filled areas
        for $.interp.plot-areas -> %a {
            set-cr-color($cr, %a<color>);
            my @pts = %a<points>.flat;
            if @pts.elems > 0 {
                $cr.move-to(tx(@pts[0]<x>).Num, ty(@pts[0]<y>).Num);
                for @pts[1..*] -> %p { $cr.line-to(tx(%p<x>).Num, ty(%p<y>).Num) }
                $cr.close-path;
                $cr.fill;
            }
        }

        # Boxes
        $cr.set-line-width(1.5);
        for $.interp.plot-boxes -> %b {
            set-cr-color($cr, %b<color>);
            $cr.rectangle(tx(%b<x1>).Num, ty(%b<y2>).Num,
                          (tx(%b<x2>) - tx(%b<x1>)).Num, (ty(%b<y1>) - ty(%b<y2>)).Num);
            if %b<fill> { $cr.fill-preserve; }
            $cr.stroke;
        }

        # Lines
        for $.interp.plot-lines -> %l {
            set-cr-color($cr, %l<color>);
            $cr.set-line-width(1.5);
            $cr.move-to(tx(%l<x1>).Num, ty(%l<y1>).Num);
            $cr.line-to(tx(%l<x2>).Num, ty(%l<y2>).Num);
            $cr.stroke;
        }

        # Line strips
        for $.interp.plot-line-strips -> %ls {
            set-cr-color($cr, %ls<color>);
            $cr.set-line-width(1.5);
            my @pts = %ls<points>.flat;
            if @pts.elems > 0 {
                $cr.move-to(tx(@pts[0]<x>).Num, ty(@pts[0]<y>).Num);
                for @pts[1..*] -> %p { $cr.line-to(tx(%p<x>).Num, ty(%p<y>).Num) }
                $cr.stroke;
            }
        }

        # Circles
        for $.interp.plot-circles -> %c {
            set-cr-color($cr, %c<color>);
            $cr.set-line-width(1.5);
            $cr.arc(tx(%c<x>).Num, ty(%c<y>).Num, (%c<radius> * $xs).Num, 0e0, (2 * pi).Num);
            $cr.stroke;
        }

        # Points with connecting line
        my @points = $.interp.plot-points;
        if @points.elems > 1 {
            set-cr-color($cr, @points[0]<color>);
            $cr.set-line-width(1.0);
            $cr.move-to(tx(@points[0]<x>).Num, ty(@points[0]<y>).Num);
            for @points[1..*] -> %p { $cr.line-to(tx(%p<x>).Num, ty(%p<y>).Num) }
            $cr.stroke;
        }
        for @points -> %p {
            set-cr-color($cr, %p<color>);
            $cr.arc(tx(%p<x>).Num, ty(%p<y>).Num, 3e0, 0e0, (2 * pi).Num);
            $cr.fill;
        }

        # Text
        for $.interp.plot-texts -> %t {
            set-cr-color($cr, %t<color>);
            $cr.set-font-size(12e0);
            $cr.move-to(tx(%t<x>).Num, ty(%t<y>).Num);
            $cr.show-text(%t<text>.Str);
        }

        # Axis tick labels
        self.draw-ticks($cr, $W, $H, $M, &tx, &ty, %win);
    }

    method draw-ticks($cr, $W, $H, $M, &tx, &ty, %win) {
        sub nice-step($range) {
            my $rough = $range / 6;
            return 1 if $rough <= 0;
            my $mag = 10 ** $rough.log10.floor;
            my $norm = $rough / $mag;
            my $nice = $norm < 1.5 ?? 1 !! $norm < 3 ?? 2 !! $norm < 7 ?? 5 !! 10;
            return $nice * $mag;
        }

        $cr.set-source-rgb(0.2, 0.2, 0.2);
        $cr.set-font-size(10e0);
        $cr.set-line-width(0.5);

        my $xstep = nice-step(%win<x-max> - %win<x-min>);
        my $x = (%win<x-min> / $xstep).ceiling * $xstep;
        while $x <= %win<x-max> {
            my $px = tx($x);
            $cr.move-to($px.Num, ($H - $M + 5).Num);
            $cr.line-to($px.Num, ($H - $M).Num);
            $cr.stroke;
            my $label = $x == $x.Int ?? "{$x.Int}" !! "{$x.round(0.001)}";
            $cr.move-to(($px - 10).Num, ($H - $M + 18).Num);
            $cr.show-text($label);
            $x += $xstep;
        }

        my $ystep = nice-step(%win<y-max> - %win<y-min>);
        my $y = (%win<y-min> / $ystep).ceiling * $ystep;
        while $y <= %win<y-max> {
            my $py = ty($y);
            $cr.move-to(($M - 5).Num, $py.Num);
            $cr.line-to($M.Num, $py.Num);
            $cr.stroke;
            my $label = $y == $y.Int ?? "{$y.Int}" !! "{$y.round(0.001)}";
            $cr.move-to(($M - 45).Num, ($py + 4).Num);
            $cr.show-text($label);
            $y += $ystep;
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# REPL (Interactive Mode)
# ══════════════════════════════════════════════════════════════════════════════

sub run-repl(Bool :$debug = False) {
    say "True BASIC Interpreter — Interactive Mode";
    say "Type BASIC statements, or: RUN, LIST, NEW, LOAD file, SAVE file, HELP, EXIT";
    say "";

    my @program-lines;
    my $interp = TrueBASICInterpreter.new(:$debug);

    loop {
        print "BASIC> ";
        my $input = $*IN.get // last;
        $input = $input.trim;
        next if $input eq '';
        last if $input.uc eq 'EXIT' || $input.uc eq 'QUIT';

        given $input.uc {
            when 'HELP' {
                say q:to/END/;
  Commands: RUN, LIST, NEW, LOAD <file>, SAVE <file>, DEBUG, VARS, EXIT
  Statements: LET, PRINT, INPUT, IF/THEN, FOR/NEXT, DO/LOOP, WHILE/WEND
              DIM, GOTO, GOSUB/RETURN, SUB/END SUB, CALL, DEF
              PLOT, LINE, CIRCLE, WINDOW, SET WINDOW, SET COLOR
              PLOT LINES:, PLOT AREA:, PLOT TEXT
              SHOW PLOT, GRAPHICS <mode>, SAVE
  Modes: gtk (window), web (browser), svg (file), ascii (terminal)
END
            }
            when 'RUN' {
                my $src = @program-lines.grep(*.defined).sort({ $^a.key <=> $^b.key }).map(*.value).join("\n");
                if $src {
                    $interp = TrueBASICInterpreter.new(:$debug);
                    $interp.load-source($src);
                    $interp.run();
                } else { say "No program loaded." }
            }
            when 'LIST' {
                for @program-lines.grep(*.defined).sort({ $^a.key <=> $^b.key }) -> $p {
                    say "{$p.key} {$p.value}";
                }
            }
            when 'NEW'   { @program-lines = []; say "Program cleared." }
            when 'DEBUG' { $interp.debug = !$interp.debug; say "Debug: {$interp.debug ?? 'ON' !! 'OFF'}" }
            when 'VARS'  { for $interp.variables.sort -> $p { say "  {$p.key} = {$p.value}" } }
            when /^ 'LOAD' \s+ (.+) $/ {
                my $f = ~$0;
                if $f.IO.e {
                    @program-lines = [];
                    for $f.IO.lines.kv -> $i, $line {
                        if $line ~~ /^ \s* (\d+) \s+ (.+) / {
                            @program-lines[+$0] = +$0 => ~$1;
                        } else {
                            @program-lines[$i * 10 + 10] = ($i * 10 + 10) => $line unless $line.trim eq '';
                        }
                    }
                    say "Loaded $f";
                } else { say "File not found: $f" }
            }
            when /^ 'SAVE' \s+ (.+) $/ {
                my $f = ~$0;
                $f.IO.spurt(@program-lines.grep(*.defined).sort({ $^a.key <=> $^b.key }).map({ "{.key} {.value}" }).join("\n"));
                say "Saved to $f";
            }
            default {
                if $input ~~ /^ (\d+) \s+ (.+) / {
                    @program-lines[+$0] = +$0 => ~$1;
                } else {
                    # Immediate execution
                    my $temp = TrueBASICInterpreter.new(:$debug);
                    $temp.variables = $interp.variables;
                    $temp.load-source($input);
                    $temp.run();
                    $interp.variables = $temp.variables;
                }
            }
        }
    }
    say "Goodbye!";
}

# ══════════════════════════════════════════════════════════════════════════════
# CLI Entry Point
# ══════════════════════════════════════════════════════════════════════════════

sub MAIN(
    Str  $file?,                          #= BASIC program file to run
    Bool :$interactive = False,           #= Start interactive REPL
    Bool :$debug = False,                 #= Enable debug output
    Str  :$graphics = '',                 #= Graphics mode: gtk, web, svg, ascii
    Bool :$show = False,                  #= Auto-show plot after execution
) {
    if $file.defined {
        die "File not found: $file" unless $file.IO.e;
        my $interp = TrueBASICInterpreter.new(:$debug);
        $interp.graphics-mode = $graphics if $graphics;
        $interp.load-program($file);
        $interp.run();
    } elsif $interactive {
        run-repl(:$debug);
    } else {
        say "True BASIC Interpreter";
        say "Usage:";
        say "  raku TrueBASIC.raku <program.bas>     Run a BASIC program";
        say "  raku TrueBASIC.raku --interactive      Interactive REPL";
        say "  raku TrueBASIC.raku --graphics=gtk     GTK window (default)";
        say "  raku TrueBASIC.raku --graphics=web     Open in browser";
        say "  raku TrueBASIC.raku --graphics=svg     Save as SVG";
        say "  raku TrueBASIC.raku --graphics=ascii   Terminal ASCII plot";
        say "  raku TrueBASIC.raku --debug            Debug mode";
    }
}
