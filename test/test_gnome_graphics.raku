#!/usr/bin/env raku

use v6.d;
use lib 'lib';
use GnomeGraphics;

say "Testing Gnome::Cairo Graphics System...";

# Initialize graphics
if init-graphics("gnome_test_plot.svg") {
    say "✓ Graphics initialized";
    
    # Set coordinate system
    set-window(0, 10, 0, 10);
    say "✓ Window coordinates set";
    
    # Test point plotting
    set-point-color(2);  # Red
    plot-point(1.0, 1.0);
    plot-point(2.0, 2.0);
    plot-point(3.0, 3.0);
    say "✓ Points plotted";
    
    # Test line drawing
    set-point-color(4);  # Blue
    draw-line(0.0, 5.0, 10.0, 5.0);  # Horizontal line
    draw-line(5.0, 0.0, 5.0, 10.0);  # Vertical line
    say "✓ Lines drawn";
    
    # Test text
    set-text-color(1);  # Black
    plot-text("Gnome Graphics Test", 6.0, 8.0);
    say "✓ Text added";
    
    # Test move and draw operations
    move-to(1.0, 8.0);
    set-beam-mode("ON");
    draw-to(2.0, 9.0);
    draw-to(3.0, 8.0);
    draw-to(4.0, 9.0);
    say "✓ Connected lines drawn";
    
    # Test different point styles
    for 1..3 -> $style {
        set-point-style($style);
        plot-point(7.0 + $style, 2.0);
    }
    say "✓ Different point styles tested";
    
    # Finalize and save
    cleanup-graphics();
    say "✓ Graphics saved to gnome_test_plot.svg";
    
    # Check if file was created
    if 'gnome_test_plot.svg'.IO.e {
        my $size = 'gnome_test_plot.svg'.IO.s;
        say "✓ SVG file created successfully ({$size} bytes)";
        
        # Show file contents (first few lines)
        say "";
        say "First few lines of generated SVG:";
        say "-" x 40;
        my @lines = 'gnome_test_plot.svg'.IO.lines;
        for @lines[0..min(10, @lines.elems-1)] -> $line {
            say $line;
        }
        say "-" x 40;
        
        say "";
        say "✓ Gnome::Cairo graphics system test completed successfully!";
        say "  Open gnome_test_plot.svg in a web browser or SVG viewer to see the results.";
    } else {
        say "✗ SVG file was not created";
    }
} else {
    say "✗ Graphics initialization failed";
}