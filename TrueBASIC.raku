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
            # Skip comment lines that start with ! or REM
            next if $line.trim.starts-with('!') || $line.trim.starts-with('REM') || $line.trim.starts-with("'");
            
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
        
        my $continue = $for-info<step> > 0 ?? 
            %!variables{$var} <= $for-info<end> !!
            %!variables{$var} >= $for-info<end>;
            
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
            
            # Number
            return +$token if $token ~~ /^ \s* <[0..9+\-.e]>+ \s* $/;
            
            # Variable
            return %!variables{$token} // 0;
        }
        
        # Handle simple arithmetic expressions
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
                    if $token ~~ /^ \s* <[0..9+\-.e]>+ \s* $/ {
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