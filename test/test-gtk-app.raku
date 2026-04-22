#!/usr/bin/env raku

use v6.d;
use GTK::Simple;

# Simple GTK::Simple test application
# This creates a basic window with a button

say "Creating GTK::Simple application...";

# Check if we have a display available
unless %*ENV<DISPLAY> {
    say "⚠ No DISPLAY environment variable found. GUI applications may not work.";
    say "This is normal when running in a terminal or SSH session.";
    exit 0;
}

try {
    # Create a new application using the proper API
    my $app = GTK::Simple::App.new(title => "True BASIC GTK Test");
    
    # Create a simple button
    my $button = GTK::Simple::Button.new(text => "Click Me!");
    
    # Set up button click event
    $button.clicked.tap({
        say "Button clicked!";
        $app.exit;
    });
    
    # Add button to app window
    $app.set-content($button);
    
    # Set window size
    $app.size-request(300, 100);
    
    # Show the application (this will block until window is closed)
    say "Showing GTK application window...";
    $app.run;
    
    CATCH {
        default {
            say "Error creating GTK application: {.message}";
            say "This might be due to no graphical environment or display issues.";
        }
    }
}

say "GTK test completed.";