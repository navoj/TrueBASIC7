#!/usr/bin/env raku

use v6.d;

# Test Gnome modules without GUI
say "Testing Gnome module availability...";

# Test basic module loading
my @modules-to-test = <
    Gnome::N
    Gnome::Glib
    Gnome::GObject
    Gnome::Cairo
    Gnome::Gdk3
    Gnome::Gtk3
>;

my $all-good = True;

for @modules-to-test -> $module {
    print "Testing $module... ";
    try {
        require ::($module);
        say "✓ Available";
    }
    CATCH {
        default {
            say "✗ Failed: {.message}";
            $all-good = False;
        }
    }
}

if $all-good {
    say "";
    say "✓ All Gnome modules are available!";
    
    # Test Cairo without GUI
    say "";
    say "Testing Cairo surface creation...";
    try {
        use Gnome::Cairo;
        
        # Create an SVG surface for testing
        my Gnome::Cairo $surface .= new;
        $surface.surface-create-svg('/tmp/test.svg', 200, 200);
        
        my Gnome::Cairo $context .= new;
        $context.create($surface);
        
        # Draw simple test pattern
        $context.set_source_rgb(1.0, 0.0, 0.0);
        $context.arc(100, 100, 50, 0, 2 * π);
        $context.fill;
        
        $context.show_page;
        
        say "✓ Cairo SVG rendering works!";
        say "✓ Test SVG created at /tmp/test.svg";
        
        # Check if file was created
        if '/tmp/test.svg'.IO.e {
            say "✓ SVG file exists and has size: {'/tmp/test.svg'.IO.s} bytes";
        } else {
            say "✗ SVG file was not created";
        }
        
    }
    CATCH {
        default {
            say "✗ Cairo test failed: {.message}";
            $all-good = False;
        }
    }
} else {
    say "";
    say "✗ Some Gnome modules are not working properly";
}

say "";
say $all-good ?? "✓ Gnome::Gtk3 system is ready for use!" !! "✗ Gnome::Gtk3 system has issues";