#!/usr/bin/env raku

use v6.d;
use GTK::Simple;
use GTK::Simple::App;
use GTK::Simple::DrawingArea;

# Test GTK::Simple graphics functionality
sub MAIN() {
    say "Initializing GTK graphics test...";
    
    try {
        # Create GTK application
        my $app = GTK::Simple::App.new(title => "True BASIC Graphics Test");
        
        # Create drawing area
        my $canvas = GTK::Simple::DrawingArea.new;
        $canvas.size-request(640, 480);
        
        # Set up draw callback
        $canvas.on-draw = sub ($cairo-context) {
            say "Drawing...";
            
            # Clear background to white
            $cairo-context.set_source_rgb(1.0, 1.0, 1.0);
            $cairo-context.paint;
            
            # Draw a simple test pattern
            
            # Draw a red circle
            $cairo-context.set_source_rgb(1.0, 0.0, 0.0);
            $cairo-context.arc(100, 100, 50, 0, 2 * π);
            $cairo-context.fill;
            
            # Draw a blue line
            $cairo-context.set_source_rgb(0.0, 0.0, 1.0);
            $cairo-context.set_line_width(3);
            $cairo-context.move_to(200, 100);
            $cairo-context.line_to(400, 300);
            $cairo-context.stroke;
            
            # Draw some text
            $cairo-context.set_source_rgb(0.0, 0.0, 0.0);
            $cairo-context.select_font_face("Arial", 0, 0);
            $cairo-context.set_font_size(16);
            $cairo-context.move_to(50, 400);
            $cairo-context.show_text("True BASIC Graphics System Test");
            
            say "Drawing complete.";
        };
        
        # Add canvas to app
        $app.set-content($canvas);
        
        # Show window and run
        $app.show;
        say "Graphics window should be visible. Close window to exit.";
        $app.run;
        
        say "GTK graphics test completed successfully.";
        
    }
    
    CATCH {
        default {
            say "GTK graphics test failed: {.message}";
            say .backtrace;
        }
    }
}