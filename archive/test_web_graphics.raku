#!/usr/bin/env raku

use lib 'lib';
use Graphics;

# Test the web graphics system directly
init-graphics(800, 600);
set-window(0, 10, 0, 10);

# Add some graphics operations
draw-line(1, 1, 9, 9);
draw-circle(5, 5, 2);
draw-text(2, 8, "Hello TrueBASIC!");

# Save the graphics
save-graphics("test_output.html");

say "Web graphics test complete. Check test_output.html";