#!/usr/bin/env raku

# Test the simple graphics module
use v6.d;
use lib 'lib';
use SimpleGraphics;

sub MAIN() {
    say "Testing SimpleGraphics module...";
    
    # Initialize graphics
    init-graphics();
    say "Graphics initialization: SUCCESS";
    
    # Test coordinate system setup
    set-window(0, 10, 0, 10);
    
    # Test basic drawing operations
    say "Drawing test pattern...";
    
    # Plot some points
    plot-point(1, 1);
    plot-point(2, 2);
    plot-point(3, 3);
    
    # Draw some lines
    draw-line(0, 0, 10, 10);
    draw-line(0, 10, 10, 0);
    
    # Draw a rectangle
    draw-line(2, 2, 8, 2);
    draw-line(8, 2, 8, 8);
    draw-line(8, 8, 2, 8);
    draw-line(2, 8, 2, 2);
    
    # Add text
    plot-text("Graphics Test", 1, 9);
    
    # Test polygon
    my @triangle = ((4, 6), (6, 6), (5, 8));
    draw-polygon(@triangle);
    
    # Change color for some elements
    set-color("red");
    plot-point(5, 5);
    draw-line(1, 8, 9, 8);
    
    # Export graphics
    export-graphics("test_graphics.svg");
    
    say "Graphics test complete.";
    say "Elements created: {$graphics.elements.elems}";
    
    # Show SVG content
    say "SVG Output preview (first 500 characters):";
    my $svg = $graphics.to-svg();
    say $svg.substr(0, 500) ~ "...";
    
    # Cleanup
    cleanup-graphics();
}