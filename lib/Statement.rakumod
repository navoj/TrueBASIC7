#!/usr/bin/env raku

=begin pod
=head1 Statement Module  

Translation of struct.pas and statemen.pas from Decimal BASIC to Raku
Contains classes for representing and executing BASIC language statements
in the True BASIC interpreter.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use lib '.';
use Base;
use Variable;
use Expression;

# Forward declarations
class Statement { ... }
class Routine { ... }
class ProgramUnit { ... }
class Module { ... }
class WhenException { ... }

# Control exception classes
class ControlException is Exception is export {
    method new(Str $message = '') {
        self.bless: message => $message;
    }
}

class RetryException is ControlException is export { }
class ContinueException is ControlException is export { }
class ReturnException is ControlException is export { }
class StopException is ControlException is export { }
class ExitFunctionException is ControlException is export { }
class ExitSubException is ControlException is export { }
class ExitPictureException is ControlException is export { }

class ExitHandlerException is ControlException is export {
    has WhenException $.when;
    
    method new(WhenException $when1) {
        self.bless: when => $when1;
    }
}

class ExitDoException is ControlException is export {
    has Statement $.next-statement;
    
    method new(Statement $st) {
        self.bless: next-statement => $st;
    }
}

# Label number pair for GOTO/GOSUB handling
class LabelNumberPair is export {
    has Int $.label-number;
    has Statement $.statement;
    has Statement $.prefect;
    
    method new(Int $label, Statement $stmt, Statement $pref) {
        self.bless: label-number => $label, statement => $stmt, prefect => $pref;
    }
}

# Label number table for organizing line numbers
class LabelNumberTable is export {
    has @.labels;
    
    method add-item(Statement $stmt) {
        if $stmt.label-number > 0 {
            @!labels.push: LabelNumberPair.new(
                $stmt.label-number, 
                $stmt, 
                $stmt.previous
            );
        }
    }
    
    method find-statement(Int $label) returns Statement {
        for @!labels -> $pair {
            return $pair.statement if $pair.label-number == $label;
        }
        die "Label $label not found";
    }
}

# ID Table for managing identifiers
class IdTable is export {
    has @.identifiers;
    
    method add(IdRec $id) {
        @!identifiers.push: $id;
    }
    
    method search(Str $name) returns IdRec {
        for @!identifiers -> $id {
            return $id if $id.name eq $name;
        }
        return IdRec; # Undefined
    }
    
    method inquire(Str $name, Int $index is rw, Int $dim is rw) returns Bool {
        my $id = self.search($name);
        if $id.defined {
            $index = 0; # Would be actual index in implementation
            $dim = $id.dim;
            return True;
        }
        return False;
    }
}

# Base statement class (corresponding to TStatement)
class Statement is export {
    has Int $.line-number = 0;
    has Int $.label-number = 0;
    has Statement $.next;
    has Statement $.previous;
    has Statement $.eldest;
    has WhenException $.when-block;
    has Routine $.proc;
    has ProgramUnit $.punit;
    has $.stop-key-sense;
    
    method new(Statement $prev?, Statement $eld?) {
        self.bless: previous => $prev, eldest => $eld;
    }
    
    method collect-label-info(LabelNumberTable $table) {
        $table.add-item(self);
    }
    
    method sequentially-execute() {
        self.exec();
        if $!next.defined {
            $!next.sequentially-execute();
        }
    }
    
    method exec() {
        # Base implementation - override in subclasses
    }
    
    method inside-of-when() returns Bool {
        return $!when-block.defined;
    }
    
    method set-breakpoint(Int $line, Bool $enable) returns Bool {
        return $!line-number == $line;
    }
    
    method executive-next() returns Statement {
        return $!next;
    }
    
    method exception-handle() returns Bool {
        # Exception handling implementation
        return False;
    }
    
    method not-sub-statement() returns Bool {
        return True; # Default implementation
    }
}

# Terminal statement (marks end of statement sequence)
class Terminal is Statement is export {
    has Statement $.statement;
    
    method exec() {
        $!statement.exec() if $!statement.defined;
    }
}

# GOTO statement (corresponding to TGOTO)
class GotoStatement is Statement is export {
    has Int $.target-label;
    has Statement $.prefect;
    has Statement $.target-statement;
    
    method new(Statement $prev?, Statement $eld?, Int :$target-label) {
        self.bless: previous => $prev, eldest => $eld, :$target-label;
    }
    
    method fill-info(LabelNumberTable $table) {
        $!target-statement = $table.find-statement($!target-label);
    }
    
    method exec() {
        # Jump to target statement
        if $!target-statement.defined {
            our $NextStatement = $!target-statement;
        } else {
            die "GOTO target $!target-label not found";
        }
    }
}

# EXIT statement (corresponding to TEXIT)
class ExitStatement is Statement is export {
    has $.exception-type;
    
    method new(Statement $prev?, Statement $eld?, $exception-type) {
        self.bless: previous => $prev, eldest => $eld, :$exception-type;
    }
    
    method exec() {
        given $!exception-type {
            when 'DO' { die ExitDoException.new(self) }
            when 'FUNCTION' { die ExitFunctionException.new() }
            when 'SUB' { die ExitSubException.new() }
            when 'PICTURE' { die ExitPictureException.new() }
            default { die ControlException.new("Unknown exit type: $!exception-type") }
        }
    }
}

# DIM statement (corresponding to TDIM)
class DimStatement is Statement is export {
    has Matrix $.matrix;
    has Principal @.lower-bounds[4];
    has Principal @.upper-bounds[4];
    has Int $.option-base;
    has Bool $.imperative = False;
    has DimStatement $.another;
    
    method new(Statement $prev?, Statement $eld?) {
        self.bless: previous => $prev, eldest => $eld;
    }
    
    method exec() {
        if $!imperative {
            # Handle imperative DIM (runtime dimensioning)
            my @lbound;
            my @ubound;
            
            for 0..3 -> $i {
                if @!lower-bounds[$i].defined {
                    @lbound[$i] = @!lower-bounds[$i].evalLongint();
                } else {
                    @lbound[$i] = $!option-base;
                }
                @ubound[$i] = @!upper-bounds[$i].evalLongint();
            }
            
            # Would redimension the array here
            # TArray(mat.point).redim0(lbound,ubound);
        }
        
        if $!another.defined {
            $!another.exec();
        }
    }
}

# LET statement (assignment)
class LetStatement is Statement is export {
    has Variable $.variable;
    has Principal $.expression;
    
    method new(Statement $prev?, Statement $eld?, Variable :$variable, Principal :$expression) {
        self.bless: previous => $prev, eldest => $eld, :$variable, :$expression;
    }
    
    method exec() {
        $!variable.assign($!expression);
    }
}

# PRINT statement
class PrintStatement is Statement is export {
    has @.print-list;
    
    method new(Statement $prev?, Statement $eld?, :@print-list) {
        self.bless: previous => $prev, eldest => $eld, :@print-list;
    }
    
    method exec() {
        for @!print-list -> $item {
            given $item {
                when Principal { print $item.evalS() }
                when Str { print $item }
                default { print $item.Str() }
            }
        }
        print "\n";
    }
}

# INPUT statement
class InputStatement is Statement is export {
    has Str $.prompt;
    has Variable $.variable;
    
    method new(Statement $prev?, Statement $eld?, Str :$prompt = '', Variable :$variable) {
        self.bless: previous => $prev, eldest => $eld, :$prompt, :$variable;
    }
    
    method exec() {
        if $!prompt {
            print $!prompt;
        }
        my $input = get();
        
        given $!variable.kind() {
            when 'n' | 'f' | 'c' | 'r' {
                my $num = $input.Numeric;
                $!variable.assignX($num);
            }
            when 's' {
                $!variable.substS($input);
            }
            default {
                die "Unknown variable type for INPUT: {$!variable.kind()}";
            }
        }
    }
}

# IF statement
class IfStatement is Statement is export {
    has Principal $.condition;
    has Statement $.then-statement;
    has Statement $.else-statement;
    
    method new(Statement $prev?, Statement $eld?, Principal :$condition, Statement :$then-statement, Statement :$else-statement?) {
        self.bless: previous => $prev, eldest => $eld, :$condition, :$then-statement, :$else-statement;
    }
    
    method exec() {
        if $!condition.evalBool() {
            $!then-statement.exec();
        } elsif $!else-statement.defined {
            $!else-statement.exec();
        }
    }
}

# FOR statement
class ForStatement is Statement is export {
    has Variable $.control-variable;
    has Principal $.start-value;
    has Principal $.end-value;
    has Principal $.step-value;
    has Statement $.body;
    
    method new(Statement $prev?, Statement $eld?, Variable :$control-variable, Principal :$start-value, Principal :$end-value, Principal :$step-value?, Statement :$body) {
        self.bless: 
            previous => $prev, 
            eldest => $eld, 
            :$control-variable, 
            :$start-value, 
            :$end-value, 
            step-value => $step-value // NConst(1),
            :$body;
    }
    
    method exec() {
        my $start = $!start-value.evalX();
        my $end = $!end-value.evalX();
        my $step = $!step-value.evalX();
        
        $!control-variable.assignX($start);
        
        while ($step > 0 && $!control-variable.evalX() <= $end) ||
              ($step < 0 && $!control-variable.evalX() >= $end) {
            
            $!body.exec();
            
            my $current = $!control-variable.evalX();
            $!control-variable.assignX($current + $step);
        }
    }
}

# WHILE statement
class WhileStatement is Statement is export {
    has Principal $.condition;
    has Statement $.body;
    
    method new(Statement $prev?, Statement $eld?, Principal :$condition, Statement :$body) {
        self.bless: previous => $prev, eldest => $eld, :$condition, :$body;
    }
    
    method exec() {
        while $!condition.evalBool() {
            $!body.exec();
        }
    }
}

# DO-LOOP statement
class DoLoopStatement is Statement is export {
    has Statement $.body;
    has Principal $.condition;
    has Str $.condition-type; # 'WHILE', 'UNTIL', or empty
    has Bool $.test-at-end = True; # True for DO...LOOP, False for WHILE
    
    method new(Statement $prev?, Statement $eld?, Statement :$body, Principal :$condition?, Str :$condition-type = '', Bool :$test-at-end = True) {
        self.bless: previous => $prev, eldest => $eld, :$body, :$condition, :$condition-type, :$test-at-end;
    }
    
    method exec() {
        if $!test-at-end {
            # DO...LOOP WHILE/UNTIL - test at end
            loop {
                $!body.exec();
                
                last unless $!condition.defined;
                
                given $!condition-type {
                    when 'WHILE' { last unless $!condition.evalBool() }
                    when 'UNTIL' { last if $!condition.evalBool() }
                    default { last } # Plain DO...LOOP (infinite loop)
                }
            }
        } else {
            # WHILE...WEND - test at beginning
            while $!condition.evalBool() {
                $!body.exec();
            }
        }
    }
}

# Global variables for execution state
our $CurrentStatement is export;
our $NextStatement is export;
our $CurrentOperation is export;

# Execution control functions
sub run-block(Statement $statement) returns Statement is export {
    try {
        $statement.exec() if $statement.defined;
        return Statement; # Undefined - normal completion
    }
    
    CATCH {
        when ExitDoException {
            return $_.next-statement;
        }
        when ControlException {
            # Re-throw control exceptions
            $_.rethrow();
        }
        default {
            # Handle other exceptions
            die $_;
        }
    }
}

sub propagate-exception() is export {
    # Implementation for exception propagation
}

=begin pod
=head1 CLASSES

=head2 Statement Classes
=item Statement - Base class for all BASIC statements
=item LetStatement - Variable assignment (LET)
=item PrintStatement - Output statements (PRINT)
=item InputStatement - Input statements (INPUT)
=item IfStatement - Conditional execution (IF...THEN...ELSE)
=item ForStatement - FOR...NEXT loops
=item WhileStatement - WHILE...WEND loops
=item DoLoopStatement - DO...LOOP constructs
=item GotoStatement - Unconditional jumps (GOTO)
=item DimStatement - Array dimensioning (DIM)
=item ExitStatement - Loop/routine exits (EXIT)

=head2 Support Classes
=item LabelNumberTable - Manages line numbers for GOTO/GOSUB
=item IdTable - Identifier lookup table
=item Various control exceptions for flow control

=head2 Global Functions
=item run-block - Execute a statement block with exception handling
=item propagate-exception - Handle exception propagation

=end pod