#!/usr/bin/env raku

use v6.d;
use Gnome::Cairo;

say "Testing Gnome::Cairo basic functionality...";

try {
    say "Creating Gnome::Cairo object...";
    my Gnome::Cairo $surface .= new;
    say "✓ Gnome::Cairo object created";
    
    say "Attempting to create SVG surface...";
    my $result = $surface.surface-create-svg('test_basic.svg', 200, 200);
    say "✓ SVG surface created: $result";
    
    say "Creating context...";
    my Gnome::Cairo $context .= new;
    $context.create($surface);
    say "✓ Context created";
    
    say "Drawing simple shapes...";
    
    # Set white background
    $context.set_source_rgb(1.0, 1.0, 1.0);
    $context.paint;
    
    # Draw red circle
    $context.set_source_rgb(1.0, 0.0, 0.0);
    $context.arc(100, 100, 50, 0, 2 * π);
    $context.fill;
    
    say "Finalizing...";
    $context.show_page;
    
    say "✓ Basic Cairo test completed successfully!";
    
    if 'test_basic.svg'.IO.e {
        say "✓ SVG file created: {('test_basic.svg'.IO.s)} bytes";
    }
}
CATCH {
    default {
        say "✗ Error: {.message}";
        say "Backtrace: {.backtrace}";
    }
}