#!/usr/bin/env raku

=begin pod
=head1 True BASIC Interpreter v2

A Raku implementation of a True BASIC interpreter using Raku grammars, supporting:
- Variables (numeric and string)
- Control flow (IF/THEN/ELSE, FOR/NEXT, DO/LOOP)
- Subroutines and functions
- Arrays
- Built-in functions
- Input/Output operations
- Graphics and plotting

Created by Jovan Trujillo
Arizona State University
Advanced Electronics and Photonics Center
1/23/2025

=end pod

use v6.d;

# Grammar for True BASIC language
grammar TrueBASICGrammar {
    token TOP { <program> }
    
    rule program { <line>+ %% \n }
    
    rule line {
        <line-number>? <statement> | <comment> | <blank-line>
    }
    
    token line-number { \d+ }
    token blank-line { ^^ \s* $$ }
    token comment { [ '!' | 'REM' ] \N* }
    
    proto rule statement {*}
    rule statement:sym<let>      { 'LET'? <assignment> }
    rule statement:sym<print>    { 'PRINT' <print-list>? }
    rule statement:sym<input>    { 'INPUT' [ <string-expr> ';' ]? <identifier> }
    rule statement:sym<if>       { 'IF' <condition> 'THEN' <statement> }
    rule statement:sym<goto>     { 'GOTO' <line-number> }
    rule statement:sym<gosub>    { 'GOSUB' <line-number> }
    rule statement:sym<return>   { 'RETURN' }
    rule statement:sym<for>      { 'FOR' <identifier> '=' <expression> 'TO' <expression> [ 'STEP' <expression> ]? }
    rule statement:sym<next>     { 'NEXT' <identifier>? }
    rule statement:sym<do>       { 'DO' }
    rule statement:sym<loop>     { 'LOOP' [ $<condition-type>=[ 'UNTIL' | 'WHILE' ] <condition> ]? }
    rule statement:sym<while>    { 'WHILE' <condition> }
    rule statement:sym<wend>     { 'WEND' }
    rule statement:sym<dim>      { 'DIM' <identifier> '(' <expression-list> ')' }
    rule statement:sym<end>      { 'END' | 'STOP' }
    rule statement:sym<cls>      { 'CLS' }
    rule statement:sym<plot>     { 'PLOT' <expression> ',' <expression> }
    rule statement:sym<line>     { 'LINE' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<circle>   { 'CIRCLE' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<window>   { 'WINDOW' <expression> ',' <expression> ',' <expression> ',' <expression> }
    rule statement:sym<show>     { 'SHOW' 'PLOT' }
    rule statement:sym<save>     { 'SAVE' <expression>? }
    rule statement:sym<graphics> { 'GRAPHICS' <identifier> }
    rule statement:sym<rem>      { 'REM' \N* }
    rule statement:sym<assign>   { <assignment> }
    
    rule assignment { [ <identifier> | <array-access> ] '=' <expression> }
    rule array-access { <identifier> '(' <expression-list> ')' }
    
    rule print-list { <print-item> [ <separator> <print-item> ]* <separator>? }
    rule print-item { <expression> }
    token separator { ';' | ',' }
    
    rule expression-list { <expression> [ ',' <expression> ]* }
    
    rule condition {
        <expression> <comparison-op> <expression> |
        <expression>
    }
    
    token comparison-op { '=' | '<>' | '!=' | '<' | '>' | '<=' | '>=' }
    
    rule expression { <term> [ <additive-op> <term> ]* }
    rule term { <power> [ <multiplicative-op> <power> ]* }
    rule power { <factor> [ <exponentiation-op> <power> ]? }
    proto rule factor { * }
    rule factor:sym<number> { <number> }
    rule factor:sym<string> { <string-literal> }
    rule factor:sym<function> { <function-call> }
    rule factor:sym<array> { <array-access> }
    rule factor:sym<identifier> { <identifier> }
    rule factor:sym<unary> { <unary-minus> }
    rule factor:sym<paren> { '(' <expression> ')' }
    
    rule unary-minus { '-' <factor> }
    rule function-call { <identifier> '(' <expression-list>? ')' }
    
    token additive-op { '+' | '-' }
    token multiplicative-op { '*' | '/' }
    token exponentiation-op { '^' }
    
    rule string-expr { <string-literal> | <identifier> }
    
    token number { '-'? \d+ [ '.' \d+ ]? [ <[eE]> '-'? \d+ ]? }
    token string-literal { '"' <-["]>* '"' }
    token identifier { <[A..Za..z]> <[A..Za..z0..9_]>* '$'? }
}

# Actions class for building AST
class TrueBASICActions {
    method TOP($/) { 
        make $<program>.made 
    }
    
    method program($/) {
        make $<line>>>.made.grep(*.defined)
    }
    
    method line($/) {
        if $<statement> {
            my %line = statement => $<statement>.made;
            %line<line-number> = +$<line-number> if $<line-number>;
            make %line;
        } elsif $<comment> {
            my %line = comment => ~$<comment>;
            %line<line-number> = +$<line-number> if $<line-number>;
            make %line;
        } else {
            make Nil;  # blank line
        }
    }
    
    method statement:sym<let>($/) { make { type => 'let', assignment => $<assignment>.made } }
    method statement:sym<assign>($/) { make { type => 'let', assignment => $<assignment>.made } }
    method statement:sym<print>($/) { 
        make { 
            type => 'print', 
            items => $<print-list> ?? $<print-list>.made !! [] 
        }
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
            condition => $<condition>.made,
            then-stmt => $<statement>.made
        }
    }
    method statement:sym<goto>($/) { make { type => 'goto', target => +$<line-number> } }
    method statement:sym<gosub>($/) { make { type => 'gosub', target => +$<line-number> } }
    method statement:sym<return>($/) { make { type => 'return' } }
    method statement:sym<for>($/) {
        make {
            type => 'for',
            variable => ~$<identifier>,
            start => $<expression>[0].made,
            end => $<expression>[1].made,
            step => $<expression>[2] ?? $<expression>[2].made !! { type => 'number', value => 1 }
        }
    }
    method statement:sym<next>($/) {
        make {
            type => 'next',
            variable => $<identifier> ?? ~$<identifier> !! Nil
        }
    }
    method statement:sym<do>($/) { make { type => 'do' } }
    method statement:sym<loop>($/) {
        make {
            type => 'loop',
            condition-type => $<condition-type> ?? ~$<condition-type> !! Nil,
            condition => $<condition> ?? $<condition>.made !! Nil
        }
    }
    method statement:sym<end>($/) { make { type => 'end' } }
    method statement:sym<cls>($/) { make { type => 'cls' } }
    method statement:sym<dim>($/) {
        make {
            type => 'dim',
            array => ~$<identifier>,
            dimensions => $<expression-list>.made
        }
    }
    method statement:sym<plot>($/) {
        make {
            type => 'plot',
            x => $<expression>[0].made,
            y => $<expression>[1].made
        }
    }
    method statement:sym<line>($/) {
        make {
            type => 'line',
            x1 => $<expression>[0].made,
            y1 => $<expression>[1].made,
            x2 => $<expression>[2].made,
            y2 => $<expression>[3].made
        }
    }
    method statement:sym<circle>($/) {
        make {
            type => 'circle',
            x => $<expression>[0].made,
            y => $<expression>[1].made,
            radius => $<expression>[2].made
        }
    }
    method statement:sym<window>($/) {
        make {
            type => 'window',
            x1 => $<expression>[0].made,
            x2 => $<expression>[1].made,
            y1 => $<expression>[2].made,
            y2 => $<expression>[3].made
        }
    }
    method statement:sym<show>($/) { make { type => 'show' } }
    method statement:sym<save>($/) {
        make {
            type => 'save',
            filename => $<expression> ?? $<expression>.made !! Nil
        }
    }
    method statement:sym<graphics>($/) {
        make {
            type => 'graphics',
            mode => ~$<identifier>
        }
    }
    method statement:sym<rem>($/) { make { type => 'rem', comment => ~$/ } }
    
    method assignment($/) {
        if $<array-access> {
            make {
                type => 'array-assignment',
                array => $<array-access>.made,
                expression => $<expression>.made
            }
        } else {
            make {
                variable => ~$<identifier>,
                expression => $<expression>.made
            }
        }
    }
    
    method print-list($/) {
        my @items;
        for $<print-item> -> $item {
            @items.push({ expr => $item.made, separator => '' });
        }
        
        # Add separators
        for $<separator>.kv -> $i, $sep {
            if $i < @items.elems {
                @items[$i]<separator> = ~$sep;
            }
        }
        
        make @items;
    }
    
    method print-item($/) { make $<expression>.made }
    
    method condition($/) {
        if $<comparison-op> {
            make {
                type => 'comparison',
                left => $<expression>[0].made,
                operator => ~$<comparison-op>,
                right => $<expression>[1].made
            }
        } else {
            make $<expression>[0].made;
        }
    }
    
    method expression($/) {
        my $result = $<term>[0].made;
        
        for $<additive-op>.kv -> $i, $op {
            $result = {
                type => 'binary',
                operator => ~$op,
                left => $result,
                right => $<term>[$i + 1].made
            }
        }
        
        make $result;
    }
    
    method term($/) {
        my $result = $<power>[0].made;
        
        for $<multiplicative-op>.kv -> $i, $op {
            $result = {
                type => 'binary',
                operator => ~$op,
                left => $result,
                right => $<power>[$i + 1].made
            }
        }
        
        make $result;
    }
    
    method power($/) {
        my $result = $<factor>.made;
        
        if $<exponentiation-op> {
            $result = {
                type => 'binary',
                operator => '^',
                left => $result,
                right => $<power>.made
            }
        }
        
        make $result;
    }
    
    method factor:sym<number>($/) { make { type => 'number', value => +$<number> } }
    method factor:sym<string>($/) { 
        my $str = ~$<string-literal>;
        make { type => 'string', value => $str.substr(1, *-1) }
    }
    method factor:sym<identifier>($/) { make { type => 'variable', name => ~$<identifier> } }
    method factor:sym<array>($/) { make $<array-access>.made }
    method factor:sym<function>($/) { make $<function-call>.made }
    method factor:sym<unary>($/) { make $<unary-minus>.made }
    method factor:sym<paren>($/) { make $<expression>.made }
    
    method unary-minus($/) {
        make {
            type => 'unary',
            operator => '-',
            operand => $<factor>.made
        }
    }
    
    method function-call($/) {
        make {
            type => 'function',
            name => ~$<identifier>,
            args => $<expression-list> ?? $<expression-list>.made !! []
        }
    }
    
    method expression-list($/) {
        make $<expression>>>.made
    }
    
    method array-access($/) {
        make {
            type => 'array-access',
            name => ~$<identifier>,
            indices => $<expression-list>.made
        }
    }
    
    method string-expr($/) {
        if $<string-literal> {
            my $str = ~$<string-literal>;
            make { type => 'string', value => $str.substr(1, *-1) }
        } else {
            make { type => 'variable', name => ~$<identifier> }
        }
    }
}

# Grammar-based True BASIC Interpreter
class TrueBASICInterpreter2 {
    has %.variables;
    has %.arrays;
    has %.functions;
    has @.program;
    has Int $.current-line = 0;
    has @.call-stack;
    has @.for-stack;
    has @.do-stack;
    has Bool $.running = False;
    has Bool $.debug = False;
    
    # Graphics attributes
    has @.plot-points = [];
    has @.plot-lines = [];
    has @.plot-circles = [];
    has %.window = x-min => 0, x-max => 100, y-min => 0, y-max => 100;
    has Str $.graphics-mode = 'svg';
    has Str $.plot-file = 'plot.svg';

    method initialize-builtins() {
        %!functions<ABS> = -> $x { abs($x) };
        %!functions<ATN> = -> $x { atan($x) };
        %!functions<COS> = -> $x { cos($x) };
        %!functions<EXP> = -> $x { exp($x) };
        %!functions<INT> = -> $x { int($x) };
        %!functions<LOG> = -> $x { log($x) };
        %!functions<RND> = -> $x? { $x ?? rand * $x !! rand };
        %!functions<SIN> = -> $x { sin($x) };
        %!functions<SQR> = -> $x { sqrt($x) };
        %!functions<TAN> = -> $x { tan($x) };
        %!functions<LEN> = -> $s { $s.chars };
        %!functions<CHR\$> = -> $n { chr($n) };
        %!functions<STR\$> = -> $n { ~$n };
        %!functions<VAL> = -> $s { +$s };
    }

    method new() {
        my $obj = self.bless();
        $obj.initialize-builtins();
        return $obj;
    }

    method load-program(Str $filename) {
        try {
            my $source = $filename.IO.slurp;
            say "Source code:\n$source" if $!debug;
            my $grammar = TrueBASICGrammar;
            my $actions = TrueBASICActions.new;
            
            my $match = $grammar.parse($source, :$actions);
            
            if $match {
                @!program = $match.made;
                say "Program parsed successfully with {+@!program} statements." if $!debug;
                say "Parsed program: {@!program.raku}" if $!debug;
            } else {
                say "Falling back to line-by-line parsing..." if $!debug;
                @!program = [];
                for $source.lines -> $line {
                    say "Parsing line: '$line'" if $!debug;
                    my $line-match = $grammar.parse($line, :$actions, rule => 'line');
                    if $line-match {
                        say "Line parsed: {$line-match.made.raku}" if $!debug;
                        @!program.push($line-match.made) if $line-match.made;
                    } else {
                        say "Failed to parse line: '$line'" if $!debug;
                    }
                }
            }
        }
        CATCH {
            default {
                die "Error loading program: {.message}";
            }
        }
    }

    method run() {
        $!running = True;
        $!current-line = 0;
        
        while $!running && $!current-line < @!program.elems {
            my $stmt = @!program[$!current-line];
            
            say "Executing line $!current-line: {$stmt.raku}" if $!debug;
            
            try {
                say "DEBUG: About to execute statement" if $!debug;
                self.execute-statement($stmt);
                say "DEBUG: Statement executed successfully, incrementing line" if $!debug;
                $!current-line++;
                say "DEBUG: Line incremented to $!current-line" if $!debug;
            }
            CATCH {
                default {
                    say "Runtime error at line $!current-line: {.message}";
                    say "Exception type: {.^name}";
                    say "Exception backtrace: {.backtrace}";
                    $!running = False;
                }
            }
        }
    }

    method execute-statement(%stmt) {
        return unless %stmt<statement>;  # Skip comments and empty lines
        
        my %s = %stmt<statement>;
        
        given %s<type> {
            when 'let' { self.execute-let(%s<assignment>) }
            when 'dim' { self.execute-dim(%s<array>, %s<dimensions>) }
            when 'print' { self.execute-print(%s<items>) }
            when 'input' { self.execute-input(%s<prompt>, %s<variable>) }
            when 'if' { self.execute-if(%s<condition>, %s<then-stmt>) }
            when 'goto' { self.execute-goto(%s<target>) }
            when 'gosub' { self.execute-gosub(%s<target>) }
            when 'return' { self.execute-return() }
            when 'for' { self.execute-for(%s<variable>, %s<start>, %s<end>, %s<step>) }
            when 'next' { self.execute-next(%s<variable>) }
            when 'do' { self.execute-do() }
            when 'loop' { self.execute-loop(%s<condition-type>, %s<condition>) }
            when 'end' { $!running = False }
            when 'cls' { self.execute-cls() }
            when 'plot' { self.execute-plot(%s<x>, %s<y>) }
            when 'line' { self.execute-line-plot(%s<x1>, %s<y1>, %s<x2>, %s<y2>) }
            when 'circle' { self.execute-circle(%s<x>, %s<y>, %s<radius>) }
            when 'window' { self.execute-window(%s<x1>, %s<y1>, %s<x2>, %s<y2>) }
            when 'show' { self.execute-show() }
            when 'save' { self.execute-save(%s<filename>) }
            when 'graphics' { self.execute-graphics(%s<mode>) }
            when 'rem' { } # No-op for comments
            default { die "Unknown statement type: {%s<type>}" }
        }
    }

    method evaluate-expression(%expr) {
        given %expr<type> {
            when 'number' { return %expr<value> }
            when 'string' { return %expr<value> }
            when 'variable' { return %!variables{%expr<name>} // 0 }
            when 'array-access' {
                my @indices = %expr<indices>.map({ self.evaluate-expression($_) });
                return self.get-array-element(%expr<name>, @indices);
            }
            when 'binary' {
                my $left = self.evaluate-expression(%expr<left>);
                my $right = self.evaluate-expression(%expr<right>);
                given %expr<operator> {
                    when '+' { return $left + $right }
                    when '-' { return $left - $right }
                    when '*' { return $left * $right }
                    when '/' { return $left / $right }
                    when '^' { return $left ** $right }
                }
            }
            when 'unary' {
                my $operand = self.evaluate-expression(%expr<operand>);
                given %expr<operator> {
                    when '-' { return -$operand }
                }
            }
            when 'function' {
                my $name = %expr<name>.uc;
                my @args = %expr<args>.map({ self.evaluate-expression($_) });
                if %!functions{$name}:exists {
                    return %!functions{$name}.(|@args);
                } else {
                    die "Unknown function: $name";
                }
            }
            when 'comparison' {
                my $left = self.evaluate-expression(%expr<left>);
                my $right = self.evaluate-expression(%expr<right>);
                given %expr<operator> {
                    when '=' | '==' { return $left == $right }
                    when '<>' | '!=' { return $left != $right }
                    when '<' { return $left < $right }
                    when '>' { return $left > $right }
                    when '<=' { return $left <= $right }
                    when '>=' { return $left >= $right }
                }
            }
            default { 
                die "Unknown expression type: {%expr<type>}" 
            }
        }
    }

    method execute-let(%assignment) {
        my $value = self.evaluate-expression(%assignment<expression>);
        if %assignment<type> && %assignment<type> eq 'array-assignment' {
            my @indices = %assignment<array><indices>.map({ self.evaluate-expression($_) });
            self.set-array-element(%assignment<array><name>, @indices, $value);
        } else {
            %!variables{%assignment<variable>} = $value;
        }
    }

    method execute-print(@items) {
        my $output = '';
        
        for @items -> %item {
            $output ~= self.evaluate-expression(%item<expr>);
            given %item<separator> {
                when ';' { $output ~= ' ' }
                when ',' { $output ~= "\t" }
            }
        }
        
        say $output;
    }

    method execute-input($prompt, $variable) {
        if $prompt {
            print self.evaluate-expression($prompt);
        } else {
            print "? ";
        }
        
        my $input = $*IN.get;
        my $value = $input ~~ /^ \s* <[0..9+\-.e]>+ \s* $/ ?? +$input !! $input;
        %!variables{$variable} = $value;
    }

    method execute-if(%condition, %then-stmt) {
        my $result = self.evaluate-expression(%condition);
        if $result {
            self.execute-statement({ statement => %then-stmt });
        }
    }

    method execute-goto($target) {
        my $found-index = @!program.first(
            -> %stmt { %stmt<line-number> && %stmt<line-number> == $target }, :k
        );
        
        if defined $found-index {
            $!current-line = $found-index - 1;
        } else {
            die "Line number $target not found";
        }
    }

    method execute-gosub($target) {
        @!call-stack.push($!current-line);
        self.execute-goto($target);
    }

    method execute-return() {
        die "RETURN without GOSUB" unless @!call-stack;
        $!current-line = @!call-stack.pop;
    }

    method execute-for($variable, %start-expr, %end-expr, %step-expr) {
        my $start = self.evaluate-expression(%start-expr);
        my $end = self.evaluate-expression(%end-expr);
        my $step = self.evaluate-expression(%step-expr);
        
        %!variables{$variable} = $start;
        
        @!for-stack.push({
            var => $variable,
            end => $end,
            step => $step,
            line => $!current-line
        });
    }

    method execute-next($variable) {
        die "NEXT without FOR" unless @!for-stack;
        
        my $for-info = @!for-stack[*-1];
        my $var = $for-info<var>;
        
        %!variables{$var} += $for-info<step>;
        
        my $epsilon = 1e-10;
        my $continue;
        
        if $for-info<step> > 0 {
            $continue = %!variables{$var} <= ($for-info<end> + $epsilon);
        } else {
            $continue = %!variables{$var} >= ($for-info<end> - $epsilon);
        }
            
        if $continue {
            $!current-line = $for-info<line>;
        } else {
            @!for-stack.pop;
        }
    }

    method execute-do() {
        @!do-stack.push($!current-line);
    }

    method execute-loop($condition-type, %condition?) {
        die "LOOP without DO" unless @!do-stack;
        
        my $do-line = @!do-stack[*-1];
        
        if $condition-type && %condition {
            my $result = self.evaluate-expression(%condition);
            if ($condition-type.trim eq 'UNTIL' && !$result) || 
               ($condition-type.trim eq 'WHILE' && $result) {
                $!current-line = $do-line;
            } else {
                @!do-stack.pop;
            }
        } else {
            $!current-line = $do-line;  # Infinite loop
        }
    }

    method execute-cls() {
        run 'clear';
        if @!plot-points || @!plot-lines || @!plot-circles {
            self.clear-graphics();
            say "Graphics cleared." if $!debug;
        }
    }

    # Array management methods
    method execute-dim($array-name, @dimensions) {
        my @dims = @dimensions.map({ self.evaluate-expression($_) });
        %!arrays{$array-name} = self.create-array(@dims);
        say "Created array $array-name with dimensions: {@dims.join('x')}" if $!debug;
    }
    
    method create-array(@dimensions) {
        if @dimensions.elems == 1 {
            return [0 xx (@dimensions[0] + 1)];  # 1-based indexing
        } else {
            my @array;
            for 0..@dimensions[0] -> $i {
                @array[$i] = self.create-array(@dimensions[1..*]);
            }
            return @array;
        }
    }
    
    method get-array-element($name, @indices) {
        return 0 unless %!arrays{$name}:exists;
        my $array = %!arrays{$name};
        for @indices -> $index {
            my $i = $index.Int;
            return 0 unless $array && $array.isa(Array) && $i < $array.elems;
            $array = $array[$i];
        }
        return $array // 0;
    }
    
    method set-array-element($name, @indices, $value) {
        return unless %!arrays{$name}:exists;
        my $array = %!arrays{$name};
        my $last-index = @indices.pop;
        
        # Navigate to the correct sub-array
        for @indices -> $index {
            my $i = $index.Int;
            return unless $array && $array.isa(Array) && $i < $array.elems;
            $array = $array[$i];
        }
        
        # Set the value
        if $array && $array.isa(Array) && $last-index < $array.elems {
            $array[$last-index.Int] = $value;
        }
    }

    # Graphics methods
    method execute-plot(%x-expr, %y-expr) {
        my $x = self.evaluate-expression(%x-expr);
        my $y = self.evaluate-expression(%y-expr);
        
        @!plot-points.push({ x => $x, y => $y });
        say "Plotted point at ($x, $y)" if $!debug;
    }

    method execute-line-plot(%x1-expr, %y1-expr, %x2-expr, %y2-expr) {
        my $x1 = self.evaluate-expression(%x1-expr);
        my $y1 = self.evaluate-expression(%y1-expr);
        my $x2 = self.evaluate-expression(%x2-expr);
        my $y2 = self.evaluate-expression(%y2-expr);
        
        @!plot-lines.push({ x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2 });
        say "Drew line from ($x1, $y1) to ($x2, $y2)" if $!debug;
    }

    method execute-circle(%x-expr, %y-expr, %r-expr) {
        my $x = self.evaluate-expression(%x-expr);
        my $y = self.evaluate-expression(%y-expr);
        my $r = self.evaluate-expression(%r-expr);
        
        @!plot-circles.push({ x => $x, y => $y, radius => $r });
        say "Drew circle at ($x, $y) with radius $r" if $!debug;
    }

    method execute-window(%x1-expr, %y1-expr, %x2-expr, %y2-expr) {
        my $x1 = self.evaluate-expression(%x1-expr);
        my $y1 = self.evaluate-expression(%y1-expr);
        my $x2 = self.evaluate-expression(%x2-expr);
        my $y2 = self.evaluate-expression(%y2-expr);
        
        %!window = x-min => $x1, y-min => $y1, x-max => $x2, y-max => $y2;
        say "Set window to ($x1, $y1) - ($x2, $y2)" if $!debug;
    }

    method execute-show() {
        if @!plot-points || @!plot-lines || @!plot-circles {
            if $!graphics-mode eq 'ascii' {
                self.show-ascii-plot();
            } elsif $!graphics-mode eq 'popup' {
                self.generate-svg();
                self.show-popup();
            } else {
                self.generate-svg();
                say "Plot saved to $!plot-file";
            }
        } else {
            say "No plot data to show. Use PLOT, LINE, or CIRCLE commands first.";
        }
    }

    method execute-save(%filename-expr?) {
        my $filename = %filename-expr ?? self.evaluate-expression(%filename-expr) !! 'plot.svg';
        $!plot-file = $filename;
        self.generate-svg();
        say "Plot saved to $filename";
    }

    method execute-graphics($mode) {
        my $graphics-mode = $mode.lc;
        if $graphics-mode eq 'svg' || $graphics-mode eq 'ascii' || $graphics-mode eq 'popup' {
            $!graphics-mode = $graphics-mode;
            say "Graphics mode set to $graphics-mode";
        } else {
            say "Invalid graphics mode. Use 'svg', 'ascii', or 'popup'";
        }
    }

    method clear-graphics() {
        @!plot-points = [];
        @!plot-lines = [];
        @!plot-circles = [];
    }

    method generate-svg() {
        say "DEBUG: Starting generate-svg" if $!debug;
        say "DEBUG: Window settings: {%!window.raku}" if $!debug;
        
        my $width = 400;
        my $height = 300;
        my $margin = 20;
        
        say "DEBUG: Calculating scales..." if $!debug;
        say "DEBUG: x-range = {%!window<x-max> - %!window<x-min>}" if $!debug;
        say "DEBUG: y-range = {%!window<y-max> - %!window<y-min>}" if $!debug;
        
        my $x-scale = ($width - 2 * $margin) / (%!window<x-max> - %!window<x-min>);
        my $y-scale = ($height - 2 * $margin) / (%!window<y-max> - %!window<y-min>);
        
        say "DEBUG: x-scale = $x-scale, y-scale = $y-scale" if $!debug;
        
        sub transform-x($x) {
            return $margin + ($x - %!window<x-min>) * $x-scale;
        }
        
        sub transform-y($y) {
            return $height - $margin - ($y - %!window<y-min>) * $y-scale;
        }
        
        say "DEBUG: Building SVG content" if $!debug;
        my @svg-content = [
            qq[<?xml version="1.0" encoding="UTF-8"?>],
            qq[<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">],
            qq[<rect width="$width" height="$height" fill="white" stroke="black" stroke-width="1"/>],
        ];
        
        # Draw coordinate axes
        if %!window<x-min> <= 0 <= %!window<x-max> {
            my $x-axis = transform-x(0);
            @svg-content.push(qq[<line x1="$x-axis" y1="$margin" x2="$x-axis" y2="{$height - $margin}" stroke="gray" stroke-width="1"/>]);
        }
        
        if %!window<y-min> <= 0 <= %!window<y-max> {
            my $y-axis = transform-y(0);
            @svg-content.push(qq[<line x1="$margin" y1="$y-axis" x2="{$width - $margin}" y2="$y-axis" stroke="gray" stroke-width="1"/>]);
        }
        
        # Draw points
        for @!plot-points -> $point {
            my $x = transform-x($point<x>);
            my $y = transform-y($point<y>);
            @svg-content.push(qq[<circle cx="$x" cy="$y" r="2" fill="blue"/>]);
        }
        
        say "DEBUG: Drawing {+@!plot-lines} lines" if $!debug;
        # Draw lines
        for @!plot-lines -> $line {
            my $x1 = transform-x($line<x1>);
            my $y1 = transform-y($line<y1>);
            my $x2 = transform-x($line<x2>);
            my $y2 = transform-y($line<y2>);
            @svg-content.push(qq[<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="blue" stroke-width="2"/>]);
        }
        
        # Draw circles
        for @!plot-circles -> $circle {
            my $cx = transform-x($circle<x>);
            my $cy = transform-y($circle<y>);
            my $r = $circle<radius> * $x-scale;
            @svg-content.push(qq[<circle cx="$cx" cy="$cy" r="$r" fill="none" stroke="blue" stroke-width="2"/>]);
        }
        
        @svg-content.push("</svg>");
        
        say "DEBUG: Writing to file: $!plot-file" if $!debug;
        $!plot-file.IO.spurt(@svg-content.join("\n"));
        say "DEBUG: File written successfully" if $!debug;
    }

    method show-ascii-plot() {
        my $width = 60;
        my $height = 20;
        my @grid;
        
        for 0..^$height -> $y {
            @grid[$y] = [' ' xx $width];
        }
        
        my $x-scale = $width / (%!window<x-max> - %!window<x-min>);
        my $y-scale = $height / (%!window<y-max> - %!window<y-min>);
        
        sub ascii-x($x) {
            my $pos = (($x - %!window<x-min>) * $x-scale).round;
            return max(0, min($width - 1, $pos));
        }
        
        sub ascii-y($y) {
            my $pos = $height - 1 - (($y - %!window<y-min>) * $y-scale).round;
            return max(0, min($height - 1, $pos));
        }
        
        # Draw coordinate axes
        if %!window<x-min> <= 0 <= %!window<x-max> {
            my $x-axis = ascii-x(0);
            for 0..^$height -> $y {
                @grid[$y][$x-axis] = '|';
            }
        }
        
        if %!window<y-min> <= 0 <= %!window<y-max> {
            my $y-axis = ascii-y(0);
            for 0..^$width -> $x {
                @grid[$y-axis][$x] = '-';
            }
        }
        
        # Plot points
        for @!plot-points -> $point {
            my $x = ascii-x($point<x>);
            my $y = ascii-y($point<y>);
            @grid[$y][$x] = '*';
        }
        
        # Draw lines (simplified - just endpoints)
        for @!plot-lines -> $line {
            my $x1 = ascii-x($line<x1>);
            my $y1 = ascii-y($line<y1>);
            my $x2 = ascii-x($line<x2>);
            my $y2 = ascii-y($line<y2>);
            @grid[$y1][$x1] = '+';
            @grid[$y2][$x2] = '+';
        }
        
        say "ASCII Plot (Window: {%!window<x-min>},{%!window<y-min>} to {%!window<x-max>},{%!window<y-max>}):";
        for @grid -> $row {
            say $row.join('');
        }
    }

    method show-popup() {
        say "Opening plot in browser window...";
        
        # Try to open in browser - check for common browsers
        my $svg-path = $!plot-file.IO.absolute;
        my $opened = False;
        
        say "Debug: SVG path is $svg-path" if $!debug;
        
        # Try different browsers in order of preference
        for <firefox chromium-browser google-chrome chrome> -> $browser {
            say "Debug: Trying browser $browser" if $!debug;
            try {
                # Use Proc::Async for non-blocking process execution
                my $proc = Proc::Async.new($browser, $svg-path);
                $proc.start;
                $opened = True;
                say "Plot opened in $browser";
                last;
            }
            CATCH { 
                default { 
                    say "Debug: Browser $browser failed: {.message}" if $!debug;
                } 
            }
        }
        
        if !$opened {
            # Fallback: try generic xdg-open (Linux) or open (macOS)
            try {
                if $*KERNEL.name eq 'linux' {
                    my $proc = Proc::Async.new('xdg-open', $svg-path);
                    $proc.start;
                    say "Plot opened with default application";
                } elsif $*KERNEL.name eq 'darwin' {
                    my $proc = Proc::Async.new('open', $svg-path);
                    $proc.start;
                    say "Plot opened with default application"; 
                } else {
                    say "Could not automatically open plot. View manually: $svg-path";
                }
                CATCH { 
                    default { 
                        say "Could not automatically open plot. View manually: $svg-path";
                    }
                }
            }
        }
    }

    method debug-mode(Bool $enable = True) {
        $!debug = $enable;
    }

    method list-variables() {
        say "Variables:";
        for %!variables.sort -> $pair {
            say "  {$pair.key} = {$pair.value}";
        }
    }
}

# Main program
sub MAIN($program-file?, :$debug = False) {
    my $interpreter = TrueBASICInterpreter2.new();
    $interpreter.debug-mode($debug);
    
    if $program-file {
        if $program-file.IO.e {
            $interpreter.load-program($program-file);
            $interpreter.run();
        } else {
            say "Error: Program file '$program-file' not found.";
            exit 1;
        }
    } else {
        # Interactive mode
        say "True BASIC Interpreter v2.0 (Grammar-based)";
        say "Type 'help' for commands or enter BASIC code:";
        
        loop {
            print "READY> ";
            my $input = $*IN.get.trim;
            
            last if $input eq 'quit' || $input eq 'exit';
            
            given $input {
                when 'help' {
                    say "Commands:";
                    say "  list     - Show variables";
                    say "  clear    - Clear all variables";
                    say "  debug    - Toggle debug mode";
                    say "  quit     - Exit interpreter";
                    say "";
                    say "Graphics Commands:";
                    say "  PLOT x,y      - Plot a point";
                    say "  LINE x1,y1,x2,y2 - Draw a line";
                    say "  CIRCLE x,y,r  - Draw a circle";
                    say "  WINDOW x1,y1,x2,y2 - Set coordinate window";
                    say "  SHOW PLOT     - Display/save current plot";
                    say "  GRAPHICS mode - Set graphics mode (svg/ascii)";
                    say "  CLS           - Clear screen and graphics";
                }
                when 'list' { $interpreter.list-variables() }
                when 'clear' { 
                    $interpreter = TrueBASICInterpreter2.new();
                    say "Variables cleared.";
                }
                when 'debug' {
                    $debug = !$debug;
                    $interpreter.debug-mode($debug);
                    say "Debug mode: " ~ ($debug ?? "ON" !! "OFF");
                }
                default {
                    try {
                        my $grammar = TrueBASICGrammar;
                        my $actions = TrueBASICActions.new;
                        my $match = $grammar.parse($input, :$actions);
                        
                        if $match {
                            my @program = $match.made;
                            for @program -> $stmt {
                                $interpreter.execute-statement($stmt) if $stmt;
                            }
                        } else {
                            say "Parse error in: $input";
                        }
                        
                        CATCH {
                            default {
                                say "Error: {.message}";
                            }
                        }
                    }
                }
            }
        }
    }
}