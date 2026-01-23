#!/usr/bin/env raku

=begin pod
=head1 True BASIC Interpreter

A Raku implementation of a True BASIC interpreter supporting:
- Variables (numeric and string)
- Control flow (IF/THEN/ELSE, FOR/NEXT, DO/LOOP)
- Subroutines and functions
- Arrays
- Built-in functions
- Input/Output operations

=end pod

use v6.d;

class TrueBASICInterpreter {
    has %.variables;
    has %.arrays;
    has %.functions;
    has %.subroutines;
    has @.program-lines;
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
    has Str $.graphics-mode = 'svg'; # 'svg' or 'ascii'
    has Str $.plot-file = 'plot.svg';

    # Built-in functions
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
            my @lines = $filename.IO.lines;
            self.parse-program(@lines);
        }
        CATCH {
            default {
                die "Error loading program: {.message}";
            }
        }
    }

    method parse-program(@lines) {
        @!program-lines = [];
        
        for @lines.kv -> $index, $line {
            next if $line.trim eq '';
            # Skip comment lines that start with ! but NOT REM lines that might have line numbers
            next if $line.trim.starts-with('!') || $line.trim.starts-with("'");
            
            my $parsed-line = self.parse-line($line.trim, $index + 1);
            @!program-lines.push($parsed-line);
        }
    }

    method parse-line(Str $line, Int $line-num) {
        my @tokens = self.tokenize($line);
        my $basic-line-num = $line-num;
        
        # Check if line starts with a number (BASIC line number)
        if @tokens && @tokens[0] ~~ /^\d+$/ {
            $basic-line-num = +@tokens[0];
        }
        
        return {
            line-num => $basic-line-num,
            file-line => $line-num,
            original => $line,
            tokens => @tokens
        };
    }

    method tokenize(Str $line) {
        my @tokens = [];
        my $current-token = '';
        my $in-string = False;
        my $in-comment = False;

        for $line.comb -> $char {
            if $in-comment {
                last;
            }
            
            if $char eq '"' {
                $in-string = !$in-string;
                $current-token ~= $char;
            } elsif $in-string {
                $current-token ~= $char;
            } elsif $char eq "'" || ($current-token eq 'REM' && $char eq ' ') {
                $in-comment = True;
                last;
            } elsif $char ~~ /\s/ {
                if $current-token {
                    @tokens.push($current-token);
                    $current-token = '';
                }
            } elsif $char ~~ /<[()=<>+\-*\/,;:]>/ {
                if $current-token {
                    @tokens.push($current-token);
                    $current-token = '';
                }
                @tokens.push($char);
            } else {
                $current-token ~= $char;
            }
        }
        
        if $current-token {
            @tokens.push($current-token);
        }
        
        return @tokens;
    }

    method run() {
        $!running = True;
        $!current-line = 0;
        
        while $!running && $!current-line < @!program-lines.elems {
            my $line = @!program-lines[$!current-line];
            
            say "Executing line {$line<line-num>}: {$line<original>}" if $!debug;
            
            try {
                self.execute-line($line);
                $!current-line++;
            }
            CATCH {
                default {
                    say "Runtime error at line {$line<line-num>}: {.message}";
                    $!running = False;
                }
            }
        }
    }

    method execute-line(%line) {
        my @tokens = |%line<tokens>; # Flatten the array properly
        return unless @tokens;

        # Skip line number if present  
        my $start-index = 0;
        if @tokens[0] ~~ /^\d+$/ {
            $start-index = 1;
        }
        
        return unless $start-index < @tokens.elems;
        my $command = @tokens[$start-index].uc;

        given $command {
            when 'LET' { self.execute-let(@tokens[$start-index + 1..*]) }
            when 'PRINT' { self.execute-print(@tokens[$start-index + 1..*]) }
            when 'INPUT' { self.execute-input(@tokens[$start-index + 1..*]) }
            when 'IF' { self.execute-if(@tokens[$start-index + 1..*]) }
            when 'GOTO' { self.execute-goto(@tokens[$start-index + 1..*]) }
            when 'GOSUB' { self.execute-gosub(@tokens[$start-index + 1..*]) }
            when 'RETURN' { self.execute-return() }
            when 'FOR' { self.execute-for(@tokens[$start-index + 1..*]) }
            when 'NEXT' { self.execute-next(@tokens[$start-index + 1..*]) }
            when 'DO' { self.execute-do(@tokens[$start-index + 1..*]) }
            when 'LOOP' { self.execute-loop(@tokens[$start-index + 1..*]) }
            when 'WHILE' { self.execute-while(@tokens[$start-index + 1..*]) }
            when 'WEND' { self.execute-wend() }
            when 'DIM' { self.execute-dim(@tokens[$start-index + 1..*]) }
            when 'DEF' { self.execute-def(@tokens[$start-index + 1..*]) }
            when 'END' { $!running = False }
            when 'STOP' { $!running = False }
            when 'CLS' { self.execute-cls() }
            when 'PLOT' { self.execute-plot(@tokens[$start-index + 1..*]) }
            when 'LINE' { self.execute-line-plot(@tokens[$start-index + 1..*]) }
            when 'CIRCLE' { self.execute-circle(@tokens[$start-index + 1..*]) }
            when 'WINDOW' { self.execute-window(@tokens[$start-index + 1..*]) }
            when 'SHOW' { self.execute-show(@tokens[$start-index + 1..*]) }
            when 'SAVE' { self.execute-save-plot(@tokens[$start-index + 1..*]) }
            when 'GRAPHICS' { self.execute-graphics(@tokens[$start-index + 1..*]) }
            when 'REM' { } # Comment - no operation needed
            default {
                # Check if it's an assignment without LET
                if @tokens.elems >= ($start-index + 3) && @tokens[$start-index + 1] eq '=' {
                    self.execute-assignment(@tokens[$start-index..*]);
                } else {
                    die "Unknown command: $command";
                }
            }
        }
    }

    method execute-let(@tokens) {
        if @tokens.elems < 3 || @tokens[1] ne '=' {
            die "Syntax error in LET statement";
        }
        
        my $var-name = @tokens[0];
        my $value = self.evaluate-expression(@tokens[2..*]);
        
        %!variables{$var-name} = $value;
    }

    method execute-assignment(@tokens) {
        if @tokens.elems < 3 || @tokens[1] ne '=' {
            die "Syntax error in assignment";
        }
        
        my $var-name = @tokens[0];
        my $value = self.evaluate-expression(@tokens[2..*]);
        
        %!variables{$var-name} = $value;
    }

    method execute-print(@tokens) {
        if !@tokens {
            say '';
            return;
        }

        my $output = '';
        my $i = 0;
        
        while $i < @tokens.elems {
            my @expr-tokens = [];
            
            # Collect tokens until we hit a semicolon or comma
            while $i < @tokens.elems && @tokens[$i] ne ';' && @tokens[$i] ne ',' {
                @expr-tokens.push(@tokens[$i]);
                $i++;
            }
            
            if @expr-tokens {
                my $value = self.evaluate-expression(@expr-tokens);
                $output ~= $value;
            }
            
            # Handle separator
            if $i < @tokens.elems {
                given @tokens[$i] {
                    when ';' { $output ~= ' ' } # Space for semicolon
                    when ',' { $output ~= "\t" } # Tab for comma
                }
                $i++;
            }
        }
        
        say $output;
    }

    method execute-input(@tokens) {
        my $prompt = "";
        my $var-name;
        
        if @tokens.elems >= 3 && @tokens[1] eq ';' {
            # INPUT "prompt"; variable
            $prompt = self.evaluate-expression([@tokens[0]]);
            $var-name = @tokens[2];
        } elsif @tokens.elems >= 1 {
            # INPUT variable
            $var-name = @tokens[0];
        } else {
            die "Syntax error in INPUT statement";
        }
        
        print $prompt if $prompt;
        print "? " unless $prompt;
        
        my $input = $*IN.get;
        
        # Try to convert to number if possible
        my $value = $input ~~ /^ \s* <[0..9+\-.e]>+ \s* $/ ?? +$input !! $input;
        %!variables{$var-name} = $value;
    }

    method execute-if(@tokens) {
        my $then-index = @tokens.first(* eq 'THEN', :k);
        die "Missing THEN in IF statement" unless defined $then-index;
        
        my @condition-tokens = @tokens[0..^$then-index];
        my $condition = self.evaluate-condition(@condition-tokens);
        
        if $condition {
            my @then-tokens = @tokens[$then-index + 1..*];
            if @then-tokens && @then-tokens[0] ~~ /^\d+$/ {
                # GOTO line number
                self.execute-goto(@then-tokens);
            } else {
                # Execute statement
                self.execute-statement(@then-tokens);
            }
        }
    }

    method execute-goto(@tokens) {
        die "GOTO requires a line number" unless @tokens && @tokens[0] ~~ /^\d+$/;
        
        my $target-line = +@tokens[0];
        my $found-index = @!program-lines.first(
            -> %line { %line<line-num> == $target-line }, :k
        );
        
        if defined $found-index {
            $!current-line = $found-index - 1; # -1 because it will be incremented
        } else {
            die "Line number $target-line not found";
        }
    }

    method execute-gosub(@tokens) {
        die "GOSUB requires a line number" unless @tokens && @tokens[0] ~~ /^\d+$/;
        
        @!call-stack.push($!current-line);
        self.execute-goto(@tokens);
    }

    method execute-return() {
        die "RETURN without GOSUB" unless @!call-stack;
        $!current-line = @!call-stack.pop;
    }

    method execute-for(@tokens) {
        # FOR variable = start TO end [STEP step]
        die "Invalid FOR statement" unless @tokens.elems >= 5;
        
        my $var = @tokens[0];
        die "Missing = in FOR statement" unless @tokens[1] eq '=';
        
        my $to-index = @tokens.first(* eq 'TO', :k);
        die "Missing TO in FOR statement" unless defined $to-index;
        
        my $start = self.evaluate-expression(@tokens[2..^$to-index]);
        
        my $step-index = @tokens.first(* eq 'STEP', :k);
        my ($end, $step);
        
        if defined $step-index {
            $end = self.evaluate-expression(@tokens[$to-index + 1..^$step-index]);
            $step = self.evaluate-expression(@tokens[$step-index + 1..*]);
        } else {
            $end = self.evaluate-expression(@tokens[$to-index + 1..*]);
            $step = 1;
        }
        
        %!variables{$var} = $start;
        
        @!for-stack.push({
            var => $var,
            end => $end,
            step => $step,
            line => $!current-line
        });
    }

    method execute-next(@tokens) {
        die "NEXT without FOR" unless @!for-stack;
        
        my $for-info = @!for-stack[*-1];
        my $var = $for-info<var>;
        
        %!variables{$var} += $for-info<step>;
        
        # Use a small epsilon for floating point comparison to avoid infinite loops
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

    method execute-do(@tokens) {
        @!do-stack.push($!current-line);
    }

    method execute-loop(@tokens) {
        die "LOOP without DO" unless @!do-stack;
        
        my $do-line = @!do-stack[*-1];
        
        if @tokens && @tokens[0].uc eq 'UNTIL' {
            my $condition = self.evaluate-condition(@tokens[1..*]);
            if !$condition {
                $!current-line = $do-line;
            } else {
                @!do-stack.pop;
            }
        } elsif @tokens && @tokens[0].uc eq 'WHILE' {
            my $condition = self.evaluate-condition(@tokens[1..*]);
            if $condition {
                $!current-line = $do-line;
            } else {
                @!do-stack.pop;
            }
        } else {
            # Infinite loop, go back to DO
            $!current-line = $do-line;
        }
    }

    method execute-dim(@tokens) {
        # DIM array(size1, size2, ...)
        my $var-name = @tokens[0];
        my $paren-start = @tokens.first(* eq '(', :k);
        my $paren-end = @tokens.first(* eq ')', :k);
        
        die "Invalid DIM statement" unless defined($paren-start) && defined($paren-end);
        
        my @size-tokens = @tokens[$paren-start + 1..^$paren-end];
        my @dimensions = [];
        
        my @current-expr = [];
        for @size-tokens -> $token {
            if $token eq ',' {
                @dimensions.push(self.evaluate-expression(@current-expr));
                @current-expr = [];
            } else {
                @current-expr.push($token);
            }
        }
        if @current-expr {
            @dimensions.push(self.evaluate-expression(@current-expr));
        }
        
        %!arrays{$var-name} = self.create-array(@dimensions);
    }

    method execute-cls() {
        # Clear screen (simplified)
        run 'clear';
        # Also clear graphics if any plotting has been done
        if @!plot-points || @!plot-lines || @!plot-circles {
            self.clear-graphics();
            say "Graphics cleared." if $!debug;
        }
    }

    method create-array(@dimensions) {
        if @dimensions.elems == 1 {
            return Array.new(0 xx (@dimensions[0] + 1));
        } else {
            my @array = [];
            for 0..@dimensions[0] {
                @array.push(self.create-array(@dimensions[1..*]));
            }
            return @array;
        }
    }

    method evaluate-expression(@tokens) {
        return 0 unless @tokens;
        
        # Handle string literals
        if @tokens.elems == 1 && @tokens[0].starts-with('"') && @tokens[0].ends-with('"') {
            return @tokens[0].substr(1, *-1);
        }
        
        # Handle single variable or number
        if @tokens.elems == 1 {
            my $token = @tokens[0];
            
            # Number (including negative)
            if $token ~~ /^ \s* <[+\-]>? <[0..9.]>+ \s* $/ {
                return +$token;
            }
            
            # Variable
            return %!variables{$token} // 0;
        }
        
        # Handle unary minus: -5 becomes two tokens "-" and "5"
        if @tokens.elems == 2 && @tokens[0] eq '-' && @tokens[1] ~~ /^ \s* <[0..9.]>+ \s* $/ {
            return -@tokens[1];
        }
        
        # Handle unary minus with variable: -X
        if @tokens.elems == 2 && @tokens[0] eq '-' {
            return -self.evaluate-expression([@tokens[1]]);
        }
        
        # Handle simple binary expressions: A + B, A - B, etc.
        if @tokens.elems == 3 {
            my $left = self.evaluate-expression([@tokens[0]]);
            my $op = @tokens[1];
            my $right = self.evaluate-expression([@tokens[2]]);
            
            given $op {
                when '+' { return $left + $right }
                when '-' { return $left - $right }
                when '*' { return $left * $right }
                when '/' { return $left / $right }
                default { return $left }
            }
        }
        
        # Handle more complex arithmetic expressions
        return self.evaluate-arithmetic(@tokens);
    }

    method evaluate-arithmetic(@tokens) {
        my @postfix = self.infix-to-postfix(@tokens);
        my @stack = [];
        
        for @postfix -> $token {
            given $token {
                when /^<[+\-*\/]>$/ {
                    die "Invalid expression" unless @stack >= 2;
                    my $b = @stack.pop;
                    my $a = @stack.pop;
                    
                    given $token {
                        when '+' { @stack.push($a + $b) }
                        when '-' { @stack.push($a - $b) }
                        when '*' { @stack.push($a * $b) }
                        when '/' { @stack.push($a / $b) }
                    }
                }
                default {
                    # Number or variable
                    if $token ~~ /^ \s* <[+\-]>? <[0..9.]>+ \s* $/ {
                        @stack.push(+$token);
                    } else {
                        @stack.push(%!variables{$token} // 0);
                    }
                }
            }
        }
        
        die "Invalid expression" unless @stack.elems == 1;
        return @stack[0];
    }

    method infix-to-postfix(@tokens) {
        my @output = [];
        my @operators = [];
        my %precedence = '+' => 1, '-' => 1, '*' => 2, '/' => 2;
        
        for @tokens -> $token {
            given $token {
                when /^<[0..9+\-.e]>/ || /^<[A..Za..z]>/ {
                    @output.push($token);
                }
                when '(' {
                    @operators.push($token);
                }
                when ')' {
                    while @operators && @operators[*-1] ne '(' {
                        @output.push(@operators.pop);
                    }
                    @operators.pop if @operators; # Remove '('
                }
                when /^<[+\-*\/]>$/ {
                    while @operators && @operators[*-1] ne '(' &&
                          (%precedence{@operators[*-1]} // 0) >= %precedence{$token} {
                        @output.push(@operators.pop);
                    }
                    @operators.push($token);
                }
            }
        }
        
        while @operators {
            @output.push(@operators.pop);
        }
        
        return @output;
    }

    method evaluate-condition(@tokens) {
        # Handle simple comparisons: a op b
        my @operators = @tokens.grep(* ~~ /^(<[<>=!]>+)$/);
        
        if @operators.elems == 1 {
            my $op = @operators[0];
            my $op-index = @tokens.first(* eq $op, :k);
            
            my $left = self.evaluate-expression(@tokens[0..^$op-index]);
            my $right = self.evaluate-expression(@tokens[$op-index + 1..*]);
            
            given $op {
                when '=' | '==' { return $left == $right }
                when '<>' | '!=' { return $left != $right }
                when '<' { return $left < $right }
                when '>' { return $left > $right }
                when '<=' { return $left <= $right }
                when '>=' { return $left >= $right }
            }
        }
        
        # Default: treat as expression, true if non-zero
        return self.evaluate-expression(@tokens) != 0;
    }

    method execute-statement(@tokens) {
        # Execute a statement (used by IF...THEN)
        my $command = @tokens[0].uc;
        
        given $command {
            when 'PRINT' { self.execute-print(@tokens[1..*]) }
            when 'LET' { self.execute-let(@tokens[1..*]) }
            default {
                if @tokens.elems >= 3 && @tokens[1] eq '=' {
                    self.execute-assignment(@tokens);
                } else {
                    die "Invalid statement: $command";
                }
            }
        }
    }

    method execute-while(@tokens) {
        # WHILE condition is handled at the WEND
        # For now, just add to do-stack like DO
        @!do-stack.push($!current-line);
    }

    method execute-wend() {
        die "WEND without WHILE" unless @!do-stack;
        # For simplicity, treat like LOOP - go back to WHILE
        $!current-line = @!do-stack.pop;
    }

    method execute-def(@tokens) {
        # DEF function definition - simplified implementation
        # Format: DEF FNname(params) = expression
        die "DEF not fully implemented yet";
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
    
    # Graphics and plotting methods
    method execute-plot(@tokens) {
        die "PLOT requires X, Y coordinates" unless @tokens.elems >= 3;
        
        my $x = self.evaluate-expression([@tokens[0]]);
        die "Missing comma in PLOT statement" unless @tokens[1] eq ',';
        my $y = self.evaluate-expression([@tokens[2]]);
        
        @!plot-points.push({ x => $x, y => $y });
        say "Plotted point at ($x, $y)" if $!debug;
    }
    
    method execute-line-plot(@tokens) {
        die "LINE requires X1, Y1, X2, Y2 coordinates" unless @tokens.elems >= 7;
        
        my $x1 = self.evaluate-expression([@tokens[0]]);
        die "Missing comma in LINE statement" unless @tokens[1] eq ',';
        my $y1 = self.evaluate-expression([@tokens[2]]);
        die "Missing comma in LINE statement" unless @tokens[3] eq ',';
        my $x2 = self.evaluate-expression([@tokens[4]]);
        die "Missing comma in LINE statement" unless @tokens[5] eq ',';
        my $y2 = self.evaluate-expression([@tokens[6]]);
        
        @!plot-lines.push({ x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2 });
        say "Drew line from ($x1, $y1) to ($x2, $y2)" if $!debug;
    }
    
    method execute-circle(@tokens) {
        die "CIRCLE requires X, Y, RADIUS" unless @tokens.elems >= 5;
        
        my $x = self.evaluate-expression([@tokens[0]]);
        die "Missing comma in CIRCLE statement" unless @tokens[1] eq ',';
        my $y = self.evaluate-expression([@tokens[2]]);
        die "Missing comma in CIRCLE statement" unless @tokens[3] eq ',';
        my $r = self.evaluate-expression([@tokens[4]]);
        
        @!plot-circles.push({ x => $x, y => $y, radius => $r });
        say "Drew circle at ($x, $y) with radius $r" if $!debug;
    }
    
    method execute-window(@tokens) {
        die "WINDOW requires X1, Y1, X2, Y2" unless @tokens.elems >= 7;
        
        my $x1 = self.evaluate-expression([@tokens[0]]);
        die "Missing comma in WINDOW statement" unless @tokens[1] eq ',';
        my $y1 = self.evaluate-expression([@tokens[2]]);
        die "Missing comma in WINDOW statement" unless @tokens[3] eq ',';
        my $x2 = self.evaluate-expression([@tokens[4]]);
        die "Missing comma in WINDOW statement" unless @tokens[5] eq ',';
        my $y2 = self.evaluate-expression([@tokens[6]]);
        
        # Handle potential negative numbers by ensuring we have numeric values
        try {
            $x1 = +$x1;
            $y1 = +$y1;
            $x2 = +$x2;
            $y2 = +$y2;
        }
        CATCH {
            default {
                die "Invalid numeric values in WINDOW statement: {.message}";
            }
        }
        
        %!window = x-min => $x1, y-min => $y1, x-max => $x2, y-max => $y2;
        say "Set window to ($x1, $y1) - ($x2, $y2)" if $!debug;
    }
    
    method execute-show(@tokens) {
        if @tokens && @tokens[0].uc eq 'PLOT' {
            if @!plot-points || @!plot-lines || @!plot-circles {
                if $!graphics-mode eq 'ascii' {
                    self.show-ascii-plot();
                } else {
                    self.generate-svg();
                    say "Plot saved to $!plot-file";
                }
            } else {
                say "No plot data to show. Use PLOT, LINE, or CIRCLE commands first.";
            }
        } else {
            say "SHOW PLOT - displays the current plot";
        }
    }
    
    method execute-save-plot(@tokens) {
        my $filename = @tokens ?? self.evaluate-expression(@tokens) !! 'plot.svg';
        $!plot-file = $filename;
        self.generate-svg();
        say "Plot saved to $filename";
    }
    
    method execute-graphics(@tokens) {
        if @tokens {
            my $mode = @tokens[0].lc;
            if $mode eq 'svg' || $mode eq 'ascii' {
                $!graphics-mode = $mode;
                say "Graphics mode set to $mode";
            } else {
                say "Invalid graphics mode. Use 'svg' or 'ascii'";
            }
        } else {
            say "Current graphics mode: $!graphics-mode";
        }
    }
    
    method clear-graphics() {
        @!plot-points = [];
        @!plot-lines = [];
        @!plot-circles = [];
    }
    
    method generate-svg() {
        my $width = 400;
        my $height = 300;
        my $margin = 20;
        
        my $x-scale = ($width - 2 * $margin) / (%!window<x-max> - %!window<x-min>);
        my $y-scale = ($height - 2 * $margin) / (%!window<y-max> - %!window<y-min>);
        
        sub transform-x($x) {
            return $margin + ($x - %!window<x-min>) * $x-scale;
        }
        
        sub transform-y($y) {
            return $height - $margin - ($y - %!window<y-min>) * $y-scale;
        }
        
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
            my $r = $circle<radius> * $x-scale; # Scale radius
            @svg-content.push(qq[<circle cx="$cx" cy="$cy" r="$r" fill="none" stroke="blue" stroke-width="2"/>]);
        }
        
        @svg-content.push("</svg>");
        
        $!plot-file.IO.spurt(@svg-content.join("\n"));
    }
    
    method show-ascii-plot() {
        my $width = 60;
        my $height = 20;
        my @grid;
        
        # Initialize grid
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
        
        # Print the grid
        say "ASCII Plot (Window: {%!window<x-min>},{%!window<y-min>} to {%!window<x-max>},{%!window<y-max>}):";
        for @grid -> $row {
            say $row.join('');
        }
    }
}

# Main program
sub MAIN(Str $program-file?, Bool :$debug = False) {
    my $interpreter = TrueBASICInterpreter.new();
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
        say "True BASIC Interpreter v1.0";
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
                    say "  run      - Run loaded program";
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
                    $interpreter = TrueBASICInterpreter.new();
                    say "Variables cleared.";
                }
                when 'debug' {
                    $debug = !$debug;
                    $interpreter.debug-mode($debug);
                    say "Debug mode: " ~ ($debug ?? "ON" !! "OFF");
                }
                default {
                    try {
                        my @lines = [$input];
                        $interpreter.parse-program(@lines);
                        $interpreter.run();
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