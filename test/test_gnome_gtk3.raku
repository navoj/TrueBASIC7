#!/usr/bin/env raku

use v6.d;

# Test Gnome::Gtk3 installation and basic functionality
BEGIN {
    try {
        require Gnome::Gtk3;
        say "✓ Gnome::Gtk3 module found";
    }
    CATCH {
        default {
            say "✗ Failed to load Gnome::Gtk3: {.message}";
            exit 1;
        }
    }
}

use Gnome::Gtk3::Main;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::DrawingArea;
use Gnome::Cairo;

say "Testing Gnome::Gtk3 Graphics System...";

# Initialize GTK
Gnome::Gtk3::Main.new.init;

# Create a test window
my Gnome::Gtk3::Window $window .= new;
$window.title('Raku Gnome::Gtk3 Test');
$window.window-position(1);  # GTK_WIN_POS_CENTER
$window.set-default-size(640, 480);

# Create drawing area
my Gnome::Gtk3::DrawingArea $drawing-area .= new;
$window.add($drawing-area);

# Set up drawing callback
$drawing-area.register-signal(
    sub (
        Gnome::Gtk3::DrawingArea $widget,
        Gnome::Cairo $cairo-context
    ) {
        say "Drawing callback triggered";
        
        # Clear background to white
        $cairo-context.set_source_rgb(1.0, 1.0, 1.0);
        $cairo-context.paint;
        
        # Draw a simple test pattern
        # Red circle
        $cairo-context.set_source_rgb(1.0, 0.0, 0.0);
        $cairo-context.arc(100, 100, 50, 0, 2 * π);
        $cairo-context.fill;
        
        # Blue rectangle
        $cairo-context.set_source_rgb(0.0, 0.0, 1.0);
        $cairo-context.rectangle(200, 50, 100, 80);
        $cairo-context.fill;
        
        # Green line
        $cairo-context.set_source_rgb(0.0, 1.0, 0.0);
        $cairo-context.move_to(50, 200);
        $cairo-context.line_to(350, 250);
        $cairo-context.set_line_width(3);
        $cairo-context.stroke;
        
        # Black text
        $cairo-context.set_source_rgb(0.0, 0.0, 0.0);
        $cairo-context.move_to(50, 300);
        $cairo-context.select_font_face("Arial", 0, 0);
        $cairo-context.set_font_size(16);
        $cairo-context.show_text("Gnome::Gtk3 Test Graphics");
        
        say "✓ Drawing operations completed successfully";
    },
    'draw'
);

# Handle window close
$window.register-signal(
    sub {
        say "Window closing, stopping GTK main loop";
        Gnome::Gtk3::Main.new.quit;
    },
    'destroy'
);

# Show window
$window.show-all;

say "✓ Window created and displayed";
say "✓ Gnome::Gtk3 graphics system is working!";
say "";
say "Instructions:";
say "- You should see a window with test graphics (circle, rectangle, line, text)";
say "- Close the window to exit";

# Start the GTK main loop
Gnome::Gtk3::Main.new.main;

say "✓ GTK main loop finished";
say "✓ Gnome::Gtk3 test completed successfully!";