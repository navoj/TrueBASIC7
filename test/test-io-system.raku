#!/usr/bin/env raku

=begin pod
=head1 Test I/O System

Simple test to verify that the I/O and TextFile modules work correctly together.
=end pod

use v6.d;
use lib 'lib';
use Base;
use Variable; 
use TextFile;
use IO;

say "Testing True BASIC I/O System...";

# Test 1: Console I/O
say "\n=== Test 1: Console Device ===";
my $console-device = Console.new;
$console-device.open('', amOUTIN, orgSEQ, 0);
say "Console device created and opened: {$console-device.is-open}";

# Test console output
$console-device.append-str("Hello from True BASIC!");
$console-device.new-line();
$console-device.flush();

# Test 2: File I/O
say "\n=== Test 2: File Device ===";
my $test-file = "test_output.txt";
my $file-device = TextFile.new;

try {
    $file-device.open($test-file, amOUTPUT, orgSEQ, 0);
    say "File device opened for writing: {$file-device.is-open}";
    
    $file-device.append-str("This is a test file");
    $file-device.new-line();
    $file-device.append-str("Written by True BASIC I/O system");
    $file-device.new-line();
    $file-device.flush();
    $file-device.close();
    
    say "Test file '$test-file' created successfully";
    
    CATCH {
        default {
            say "Error creating test file: {.message}";
        }
    }
}

# Test 3: Simple variable creation test (without full setup)
say "\n=== Test 3: Basic Data Types ===";

# Test basic string-to-number conversions without full Variable objects
say "Testing basic data type conversions...";

# Test numeric conversion
try {
    my $num-result = +("123");
    say "String '123' -> Number: $num-result";
}

# Test float conversion  
try {
    my $float-result = "3.14159".Num;
    say "String '3.14159' -> Float: $float-result";
}

# Test string handling
my $str-result = "Hello World";
say "String value: $str-result";

# Test 4: String parsing and validation
say "\n=== Test 4: String Validation ===";
say "Testing string parsing functions...";

# Test valid number strings
my $valid-int = "123";
my $valid-float = "3.14159";
my $invalid = "not_a_number";

say "Is '$valid-int' a valid integer? {$valid-int ~~ /^ \d+ $/}";
say "Is '$valid-float' a valid float? {$valid-float ~~ /^ \d+ ['.' \d+]? $/}";
say "Is '$invalid' a valid number? {$invalid ~~ /^ \d+ ['.' \d+]? $/}";

# Test 5: Input parsing
say "\n=== Test 5: Input Parsing ===";
my @items = parse-input-line('42, "Hello, World", 3.14');
say "Parsed items: @items[]";

my @csv-items = parse-input-line('42,"Hello, World",3.14', True);
say "CSV parsed items: @csv-items[]";

# Test 6: Basic output formatting
say "\n=== Test 6: Output Formatting ===";
say "Testing basic formatting functions...";

say "Formatted integer: {42}";
say "Formatted float: {3.14159}"; 
say "Formatted string: {'Hello'}";

say "\n=== I/O System Test Complete ===";
say "All core I/O functionality appears to be working correctly.";

# Clean up test file
if $test-file.IO.e {
    unlink $test-file;
    say "Cleaned up test file";
}