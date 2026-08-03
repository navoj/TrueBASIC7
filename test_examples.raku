#!/usr/bin/env raku

=begin pod
=head1 Test Chemistry Examples

Test the interpreter with chemistry example programs
=end pod

use v6.d;
use lib 'lib';

my %results;
my @passed;
my @failed;
my @errors;

# Get all example files
my @example-files = dir('examples').grep(*.ends-with('.TRU') || *.ends-with('.tru'));

say "Testing {+@example-files} TrueBASIC example programs...\n";

for @example-files.sort -> $file {
    my $filename = $file.basename;
    printf("%-30s ", $filename);
    
    # Try to compile with the interpreter
    my $output = run(['raku', 'TrueBASIC.raku', '--debug', $file.absolute],
                     :out, :err, :merge).out.slurp-rest;
    
    # Check if compilation succeeded
    if $output ~~ /Parsed \d+ statements/ || $output ~~ /Full parse failed\/timed out, trying line-by-line/ {
        # Check for errors or skipped lines
        my $has_error = False;
        for $output.split("\n") -> $line {
            if $line ~~ /Runtime error|⚠ Skipped|Error/ {
                $has_error = True;
                @errors.push("  $filename: $line");
            }
        }
        if $has_error {
            print "✗ Compilation failed\n";
            @failed.push($filename);
        } else {
            print "✓ Compilation successful\n";
            @passed.push($filename);
        }
    } else {
        print "? Unknown result\n";
        @errors.push("  $filename: No compilation status reported");
    }
}

say "\n" ~ ("=" x 70);
say "TEST SUMMARY";
say "=" x 70;
say "Passed:  {+@passed}";
say "Failed:  {+@failed}";
say "Total:   {+@example-files}";

if @passed {
    say "\n✓ Successful compilations:";
    for @passed -> $f {
        say "  • $f";
    }
}

if @failed {
    say "\n✗ Failed compilations:";
    for @failed.sort -> $f {
        say "  • $f";
    }
}

if @errors && @errors < 20 {
    say "\nError details (first 20):";
    for @errors.head(20) -> $e {
        say $e;
    }
}

say "\nPass rate: {(+@passed / +@example-files * 100).sprintf('%.1f')}%";
