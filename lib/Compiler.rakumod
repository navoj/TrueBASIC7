#!/usr/bin/env raku

=begin pod
=head1 True BASIC Compiler and Interpreter

Translation of the Decimal BASIC compiler.pas to Raku
Creates the main compilation and execution engine for True BASIC programs.

Author: Translated from Pascal by AI Assistant  
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use lib 'lib';
use Base;
use Variable;
use Expression;
use Statement;

# Program unit types
enum ProgramKind is export <MainProgram Module DefFunction SubProgram PictureProgram Handler>;

# Routine class (corresponding to TRoutine)
class Routine is export {
    has IdRec $.result-var;
    has Str $.name;
    has IdTable $.var-table .= new;
    has Int $.param-count = 0;
    has Statement $.block;
    has $.run-procedure;
    has $.do-before;
    has @.goto-list;
    has Str $.kind = ''; # #0:MainProgram, M:module, D:def, F:function, S:sub, P:picture, H:Handler
    has Bool $.by-val = False;
    has Bool $.no-beam-off = False;
    
    method new(Str $name, Str $kind, Int $maxlen = 0) {
        self.bless: :$name, :$kind;
    }
    
    method set-result-var(Precision $arith) {
        # Implementation depends on arithmetic precision mode
        given $arith {
            when PrecisionNormal { # Create appropriate variable }
            when PrecisionComplex { # Create complex variable }
            # etc.
        }
    }
    
    method make-parameter() {
        # Set up parameters for routine
    }
    
    method routine-body() {
        # Execute the routine body
        $!block.exec() if $!block.defined;
    }
    
    method delete-statements() {
        # Clean up statements
    }
    
    method var-tables-rebuild() { ... } # Abstract method
    
    method label-complete() {
        # Complete label processing
    }
    
    method is-function() returns Bool {
        return $!kind eq 'F' || $!kind eq 'D';
    }
    
    method set-breakpoint(Int $line, Bool $enable) returns Bool {
        return $!block.set-breakpoint($line, $enable) if $!block.defined;
        return False;
    }
}

# Program unit class (corresponding to TProgramUnit)
class ProgramUnit is Routine is export {
    has Int $.line-number = 0;
    has Module $.parent;
    has IdTable $.external-var-table .= new;
    has IdTable $.external-sub-table .= new;
    has @.data-sequence;
    has @.image-list;
    has @.trace-list;
    has Precision $.arithmetic = PrecisionNormal;
    has Int $.array-base = 1;
    has Bool $.angle-degrees = False;
    has Bool $.character-byte = False;
    has Bool $.debug = False;
    has OptionAppearance $.option-arithmetic = ApNone;
    has OptionAppearance $.option-angle = ApNone;
    has OptionAppearance $.option-base = ApNone;
    has OptionAppearance $.option-collate = ApNone;
    has Bool $.dim-appeared = False;
    
    method new(Str $name, Str $kind, Int $maxlen = 0, Module $parent?) {
        self.bless: :$name, :$kind, :$parent;
    }
    
    method channel-sub(Int $ch, Bool $can-insert) {
        # Return text device for channel
    }
    
    method channel(Int $ch) {
        # Return text device for channel
    }
    
    method open-printer(Int $ch) {
        # Open printer on channel
    }
    
    method open(Int $ch, Str $filename, AccessMode $am, RecordType $rc, OrganizationType $og, Int $len) {
        # Open file
    }
    
    method close(Int $ch) {
        # Close channel
    }
    
    method routine-body() {
        # Execute program unit body
        $!block.exec() if $!block.defined;
    }
    
    method var-tables-rebuild() {
        # Rebuild variable tables
        $!var-table = IdTable.new;
        $!external-var-table = IdTable.new;
        $!external-sub-table = IdTable.new;
    }
}

# Module class (corresponding to TModule)
class Module is ProgramUnit is export {
    has IdTable $.share-var-table .= new;
    has IdTable $.share-sub-table .= new;
    
    method new(Str $name, Str $kind = 'M') {
        self.bless: :$name, :$kind;
    }
    
    method run-module() {
        self.routine-body();
    }
    
    method run-main() {
        self.routine-body();
    }
    
    method var-tables-rebuild() {
        callsame();
        $!share-var-table = IdTable.new;
        $!share-sub-table = IdTable.new;
    }
}

# Procedure table for managing routines
class ProcedureTable is export {
    has @.procedures;
    
    method inquire(Str $name) {
        for @!procedures -> $proc {
            return $proc if $proc.name eq $name;
        }
        return Routine; # Undefined
    }
    
    method add(Routine $routine) {
        @!procedures.push: $routine;
    }
    
    method delete-statements() {
        for @!procedures -> $proc {
            $proc.delete-statements();
        }
    }
    
    method var-tables-rebuild() {
        for @!procedures -> $proc {
            $proc.var-tables-rebuild();
        }
    }
    
    method set-breakpoint(Int $line, Bool $enable) returns Bool {
        for @!procedures -> $proc {
            return True if $proc.set-breakpoint($line, $enable);
        }
        return False;
    }
    
    method run-modules() {
        for @!procedures -> $proc {
            if $proc ~~ Module {
                $proc.run-module();
            }
        }
    }
}

# Main compiler class
class BasicCompiler is export {
    has ProcedureTable $.current-program .= new;
    has Module $.main-program;
    has ProgramUnit $.program-unit;
    has Module $.current-module;
    has @.source-lines;
    has Int $.current-line = 0;
    has Bool $.recompile = False;
    
    method new() {
        self.bless;
    }
    
    method load-program(Str $filename) {
        @!source-lines = $filename.IO.lines;
        $!current-line = 0;
    }
    
    method compile() returns Bool {
        try {
            self.compile-program();
            return True;
        }
        
        CATCH {
            when BasicException {
                say "Compilation error: {$_.message}";
                return False;
            }
            default {
                say "Internal error during compilation: {$_.message}";
                return False;
            }
        }
    }
    
    method compile-program() {
        # Initialize main program
        $!main-program = Module.new('MAIN', 'M');
        $!program-unit = $!main-program;
        $!current-program.add($!main-program);
        
        # First pass - parse structure
        $pass = 1;
        self.parse-lines();
        
        # Second pass - resolve references
        $pass = 2;
        self.resolve-references();
        
        # Complete compilation
        self.complete-compilation();
    }
    
    method parse-lines() {
        for @!source-lines.kv -> $index, $line {
            $!current-line = $index + 1;
            self.parse-line($line);
        }
    }
    
    method parse-line(Str $line) {
        # Remove comments and whitespace
        my $clean-line = $line.trim;
        return if $clean-line eq '' || $clean-line.starts-with('!') || $clean-line.starts-with('REM');
        
        # Parse line number if present
        my $line-number = 0;
        if $clean-line ~~ /^ (\d+) \s* (.*)/ {
            $line-number = $0.Int;
            $clean-line = ~$1;
        }
        
        # Parse the statement
        my $statement = self.parse-statement($clean-line);
        if $statement.defined {
            $statement.line-number = $line-number;
            self.add-statement($statement);
        }
    }
    
    method parse-statement(Str $line) returns Statement {
        # Basic statement parsing
        given $line.uc {
            when /^ 'LET' \s+ (.+)/ {
                return self.parse-let-statement(~$0);
            }
            when /^ 'PRINT' \s* (.*)/ {
                return self.parse-print-statement(~$0);
            }
            when /^ 'INPUT' \s+ (.+)/ {
                return self.parse-input-statement(~$0);
            }
            when /^ 'IF' \s+ (.+) \s+ 'THEN' \s+ (.+)/ {
                return self.parse-if-statement(~$0, ~$1);
            }
            when /^ 'FOR' \s+ (.+)/ {
                return self.parse-for-statement(~$0);
            }
            when /^ 'WHILE' \s+ (.+)/ {
                return self.parse-while-statement(~$0);
            }
            when /^ 'DO' \s* $/ {
                return self.parse-do-statement();
            }
            when /^ 'LOOP' \s* (.*)/ {
                return self.parse-loop-statement(~$0);
            }
            when /^ 'GOTO' \s+ (\d+)/ {
                return GotoStatement.new(target-label => $0.Int);
            }
            when /^ 'DIM' \s+ (.+)/ {
                return self.parse-dim-statement(~$0);
            }
            when /^ 'END' \s* $/ {
                return self.parse-end-statement();
            }
            when /^ (\w+) \s* '=' \s* (.+)/ {
                # Assignment without LET keyword
                return self.parse-assignment(~$0, ~$1);
            }
            default {
                say "Unknown statement: $line";
                return Statement;
            }
        }
    }
    
    method parse-let-statement(Str $assignment) returns LetStatement {
        # Parse LET statement: variable = expression
        if $assignment ~~ /^ (\w+) \s* '=' \s* (.+)/ {
            return self.parse-assignment(~$0, ~$1);
        }
        die "Invalid LET statement: $assignment";
    }
    
    method parse-assignment(Str $var-name, Str $expr) returns LetStatement {
        # Create variable and expression objects
        my $variable = self.get-or-create-variable($var-name);
        my $expression = self.parse-expression($expr);
        
        return LetStatement.new(variable => $variable, expression => $expression);
    }
    
    method parse-print-statement(Str $print-args) returns PrintStatement {
        my @print-list;
        
        if $print-args eq '' {
            # Empty PRINT - just print newline
            return PrintStatement.new(print-list => @print-list);
        }
        
        # Simple parsing - just treat as expression for now
        my $expr = self.parse-expression($print-args);
        @print-list.push: $expr;
        
        return PrintStatement.new(print-list => @print-list);
    }
    
    method parse-input-statement(Str $input-args) returns InputStatement {
        # Parse INPUT statement
        if $input-args ~~ /^ '"' (.*?) '"' \s* ';' \s* (\w+)/ {
            # INPUT "prompt"; variable
            return InputStatement.new(
                prompt => ~$0,
                variable => self.get-or-create-variable(~$1)
            );
        } elsif $input-args ~~ /^ (\w+) $/ {
            # INPUT variable
            return InputStatement.new(
                variable => self.get-or-create-variable(~$0)
            );
        }
        
        die "Invalid INPUT statement: $input-args";
    }
    
    method parse-if-statement(Str $condition, Str $then-part) returns IfStatement {
        my $cond-expr = self.parse-logical-expression($condition);
        my $then-stmt = self.parse-statement($then-part);
        
        return IfStatement.new(
            condition => $cond-expr,
            then-statement => $then-stmt
        );
    }
    
    method parse-for-statement(Str $for-args) returns ForStatement {
        # Parse FOR variable = start TO end [STEP step]
        if $for-args ~~ /^ (\w+) \s* '=' \s* (.+) \s+ 'TO' \s+ (.+) (\s+ 'STEP' \s+ (.+))?/ {
            my $var = self.get-or-create-variable(~$0);
            my $start = self.parse-expression(~$1);
            my $end = self.parse-expression(~$2);
            my $step = $3 ?? self.parse-expression(~$4) !! Principal; # Default step = 1
            
            return ForStatement.new(
                control-variable => $var,
                start-value => $start,
                end-value => $end,
                step-value => $step
            );
        }
        
        die "Invalid FOR statement: $for-args";
    }
    
    method parse-while-statement(Str $condition) returns WhileStatement {
        my $cond-expr = self.parse-logical-expression($condition);
        
        return WhileStatement.new(
            condition => $cond-expr
        );
    }
    
    method parse-do-statement() returns DoLoopStatement {
        return DoLoopStatement.new();
    }
    
    method parse-loop-statement(Str $loop-args) returns DoLoopStatement {
        if $loop-args eq '' {
            # Plain LOOP
            return DoLoopStatement.new();
        } elsif $loop-args ~~ /^ 'WHILE' \s+ (.+)/ {
            # LOOP WHILE condition
            my $condition = self.parse-logical-expression(~$0);
            return DoLoopStatement.new(
                condition => $condition,
                condition-type => 'WHILE'
            );
        } elsif $loop-args ~~ /^ 'UNTIL' \s+ (.+)/ {
            # LOOP UNTIL condition  
            my $condition = self.parse-logical-expression(~$0);
            return DoLoopStatement.new(
                condition => $condition,
                condition-type => 'UNTIL'
            );
        }
        
        die "Invalid LOOP statement: $loop-args";
    }
    
    method parse-dim-statement(Str $dim-args) returns DimStatement {
        # Parse DIM array(bounds) - simplified version
        return DimStatement.new();
    }
    
    method parse-end-statement() returns Statement {
        # END statement - terminate program
        return ExitStatement.new('PROGRAM');
    }
    
    method parse-expression(Str $expr) returns Principal {
        # Simplified expression parsing - would need full expression parser
        $expr = $expr.trim;
        
        # Try to parse as number
        if $expr ~~ /^ \d+ ['.' \d*]? $/ {
            # Numeric constant
            return self.create-numeric-constant($expr.Numeric);
        }
        
        # Try to parse as string literal
        if $expr ~~ /^ '"' (.*) '"' $/ {
            return self.create-string-constant(~$0);
        }
        
        # Try to parse as variable
        if $expr ~~ /^ (\w+) $/ {
            return self.get-or-create-variable(~$0);
        }
        
        # For now, return a dummy constant
        return self.create-numeric-constant(0);
    }
    
    method parse-logical-expression(Str $expr) returns Principal {
        # Parse logical expression - simplified
        return self.parse-expression($expr);
    }
    
    method create-numeric-constant(Numeric $value) returns Principal {
        # Create a numeric constant
        # Implementation depends on precision mode
        return NVari.new(IdRec.new('const'), 'n', 0, False);
    }
    
    method create-string-constant(Str $value) returns Principal {
        # Create a string constant
        return SVari.new(IdRec.new('const'), 's', 0, False);
    }
    
    method get-or-create-variable(Str $name) returns Variable {
        # Look up or create variable
        my $id = $!program-unit.var-table.search($name);
        unless $id.defined {
            $id = IdRec.InitSimple($name, intern, 0);
            $!program-unit.var-table.add($id);
        }
        
        # Return appropriate variable type based on name/context
        given $!program-unit.arithmetic {
            when PrecisionNormal { return NVari.new($id, 'n', 0, False) }
            when PrecisionNative { return FVari.new($id, 'f', 0, False) }
            when PrecisionComplex { return CVari.new($id, 'c', 0, False) }
            default { return NVari.new($id, 'n', 0, False) }
        }
    }
    
    method add-statement(Statement $statement) {
        # Add statement to current program unit
        if $!program-unit.block.defined {
            # Link to existing statement chain
            my $last = $!program-unit.block;
            while $last.next.defined {
                $last = $last.next;
            }
            $last.next = $statement;
            $statement.previous = $last;
        } else {
            # First statement
            $!program-unit.block = $statement;
        }
    }
    
    method resolve-references() {
        # Resolve GOTO targets, function calls, etc.
        my $label-table = LabelNumberTable.new;
        
        # Collect all labels
        my $stmt = $!program-unit.block;
        while $stmt.defined {
            $stmt.collect-label-info($label-table);
            $stmt = $stmt.next;
        }
        
        # Resolve GOTO statements
        $stmt = $!program-unit.block;
        while $stmt.defined {
            if $stmt ~~ GotoStatement {
                $stmt.fill-info($label-table);
            }
            $stmt = $stmt.next;
        }
    }
    
    method complete-compilation() {
        # Final compilation steps
        $!current-program.var-tables-rebuild();
    }
    
    method run() {
        if $!main-program.defined {
            try {
                $!main-program.run-main();
            }
            
            CATCH {
                when StopException {
                    say "Program stopped.";
                }
                when ControlException {
                    say "Control exception: {$_.message}";
                }
                default {
                    say "Runtime error: {$_.message}";
                }
            }
        } else {
            say "No program to run.";
        }
    }
}

=begin pod
=head1 CLASSES

=head2 BasicCompiler
Main compiler class that parses True BASIC source code and creates an executable program structure.

Key methods:
=item load-program - Load source code from file
=item compile - Compile the loaded program  
=item run - Execute the compiled program
=item parse-statement - Parse individual BASIC statements
=item parse-expression - Parse mathematical expressions

=head2 Routine, ProgramUnit, Module
Classes representing different levels of program organization from individual routines to complete modules.

=head2 ProcedureTable
Manages collection of procedures and modules within a program.

=end pod