#!/usr/bin/env raku

use v6.d;
use lib '.';

# Test GTK::Simple installation and basic functionality
# This test avoids snap conflicts by running outside of snap environment

say "Testing GTK::Simple installation...";

try {
    require GTK::Simple;
    say "✓ GTK::Simple module loaded successfully";
    
    # Test basic widget creation (this should work even without display)
    try {
        my $app = GTK::Simple.new(title => "Test App");
        say "✓ GTK::Simple::App created successfully";
        
        CATCH {
            default {
                say "⚠ GTK::Simple::App creation failed (expected if no display): {.message}";
            }
        }
    }
    
    CATCH {
        default {
            say "✗ Failed to load GTK::Simple: {.message}";
        }
    }
}

say "GTK::Simple installation test complete.";

# Test environment variables that might help with snap conflicts
say "\nEnvironment troubleshooting info:";
say "LD_LIBRARY_PATH: {%*ENV<LD_LIBRARY_PATH> // 'not set'}";
say "XDG_DATA_DIRS: {%*ENV<XDG_DATA_DIRS> // 'not set'}";
say "SNAP: {%*ENV<SNAP> // 'not set'}";