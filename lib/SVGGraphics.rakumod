#!/usr/bin/env raku

=begin pod
=head1 Graphics Module - SVG Based

Translation of graphic.pas from Decimal BASIC to Raku
Contains graphics and plotting functionality for the True BASIC interpreter.
Uses SVG for reliable cross-platform graphics output.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;

=begin pod
=head2 Graphics System Core with SVG Output
=end pod

# Graphics context and state
class GraphicsContext is export {
    has $.window-width is rw = 640;
    has $.window-height is rw = 480;
    has $.viewport-left is rw = 0.0;
    has $.viewport-right is rw = 1.0;
    has $.viewport-bottom is rw = 0.0;
    has $.viewport-top is rw = 1.0;
    has $.world-left is rw = 0.0;
    has $.world-right is rw = 1.0;
    has $.world-bottom is rw = 0.0;
    has $.world-top is rw = 1.0;
    
    # Current graphics state
    has $.current-x is rw = 0.0;
    has $.current-y is rw = 0.0;
    has $.beam-mode is rw = "ON";
    has $.point-style is rw = 1;
    has $.point-color is rw = 1;
    has $.text-color is rw = 1;
    has $.line-style is rw = 1;
    has $.line-color is rw = 1;
    
    # SVG output
    has Str $.output-file is rw = 'plot.svg';
    has Bool $.graphics-active is rw = False;
    has @.svg-elements;
    
    method add-element($element) {
        @.svg-elements.push($element);
    }
    
    method clear-elements() {
        @.svg-elements = ();
    }
}

my $graphics-context = GraphicsContext.new;

=begin pod
=head2 Color Management
=end pod

sub get-color-hex(Int $color-index) returns Str {
    # True BASIC color palette
    given $color-index {
        when 0 { return "#FFFFFF"; }  # White
        when 1 { return "#000000"; }  # Black
        when 2 { return "#FF0000"; }  # Red
        when 3 { return "#00FF00"; }  # Green
        when 4 { return "#0000FF"; }  # Blue
        when 5 { return "#FFFF00"; }  # Yellow
        when 6 { return "#FF00FF"; }  # Magenta
        when 7 { return "#00FFFF"; }  # Cyan
        when 8 { return "#808080"; }  # Gray
        default { return "#000000"; } # Default to black
    }
}

=begin pod
=head2 Coordinate Transformation Functions
=end pod

# Convert world coordinates to pixel coordinates
sub world-to-pixel-x($world-x) returns Num is export {
    my $viewport-width = $graphics-context.viewport-right - $graphics-context.viewport-left;
    my $world-width = $graphics-context.world-right - $graphics-context.world-left;
    
    my $normalized = ($world-x - $graphics-context.world-left) / $world-width;
    my $pixel-x = $graphics-context.viewport-left * $graphics-context.window-width + 
                  $normalized * $viewport-width * $graphics-context.window-width;
    
    return $pixel-x;
}

sub world-to-pixel-y($world-y) returns Num is export {
    my $viewport-height = $graphics-context.viewport-top - $graphics-context.viewport-bottom;
    my $world-height = $graphics-context.world-top - $graphics-context.world-bottom;
    
    my $normalized = ($world-y - $graphics-context.world-bottom) / $world-height;
    # Flip Y coordinate for screen coordinates
    my $pixel-y = $graphics-context.window-height - 
                  ($graphics-context.viewport-bottom * $graphics-context.window-height + 
                   $normalized * $viewport-height * $graphics-context.window-height);
    
    return $pixel-y;
}

=begin pod
=head2 Graphics Primitives
=end pod

# Set window coordinates
sub set-window($left, $right, $bottom, $top) is export {
    if $left == $right || $bottom == $top {
        die "SET WINDOW: Invalid window dimensions (zero width or height)";
    }
    
    $graphics-context.world-left = $left.Num;
    $graphics-context.world-right = $right.Num;
    $graphics-context.world-bottom = $bottom.Num;
    $graphics-context.world-top = $top.Num;
}

# Set viewport coordinates  
sub set-viewport($left, $right, $bottom, $top) is export {
    # Validate viewport coordinates (must be between 0 and 1)
    if $left < 0 || $right > 1 || $bottom < 0 || $top > 1 ||
       $left >= $right || $bottom >= $top {
        die "SET VIEWPORT: Invalid viewport coordinates (must be 0-1 and left<right, bottom<top)";
    }
    
    $graphics-context.viewport-left = $left.Num;
    $graphics-context.viewport-right = $right.Num;
    $graphics-context.viewport-bottom = $bottom.Num;
    $graphics-context.viewport-top = $top.Num;
}

# Point plotting
sub plot-point($x, $y) is export {
    if !$graphics-context.graphics-active {
        return;
    }
    
    my $pixel-x = world-to-pixel-x($x);
    my $pixel-y = world-to-pixel-y($y);
    my $color = get-color-hex($graphics-context.point-color);
    
    my $svg-element = given $graphics-context.point-style {
        when 1 { # Small circle
            "<circle cx=\"$pixel-x\" cy=\"$pixel-y\" r=\"2\" fill=\"$color\" />";
        }
        when 2 { # Square
            my $x1 = $pixel-x - 2;
            my $y1 = $pixel-y - 2;
            "<rect x=\"$x1\" y=\"$y1\" width=\"4\" height=\"4\" fill=\"$color\" />";
        }
        when 3 { # Plus sign
            my $x1 = $pixel-x - 3;
            my $x2 = $pixel-x + 3;
            my $y1 = $pixel-y - 3;
            my $y2 = $pixel-y + 3;
            "<g stroke=\"$color\" stroke-width=\"1\">" ~
            "<line x1=\"$x1\" y1=\"$pixel-y\" x2=\"$x2\" y2=\"$pixel-y\" />" ~
            "<line x1=\"$pixel-x\" y1=\"$y1\" x2=\"$pixel-x\" y2=\"$y2\" />" ~
            "</g>";
        }
        default { # Default to circle
            "<circle cx=\"$pixel-x\" cy=\"$pixel-y\" r=\"2\" fill=\"$color\" />";
        }
    };
    
    $graphics-context.add-element($svg-element);
    
    # Update current position
    $graphics-context.current-x = $x.Num;
    $graphics-context.current-y = $y.Num;
}

# Line drawing
sub draw-line($x1, $y1, $x2, $y2) is export {
    if !$graphics-context.graphics-active {
        return;
    }
    
    my $pixel-x1 = world-to-pixel-x($x1);
    my $pixel-y1 = world-to-pixel-y($y1);
    my $pixel-x2 = world-to-pixel-x($x2);
    my $pixel-y2 = world-to-pixel-y($y2);
    my $color = get-color-hex($graphics-context.line-color);
    
    my $stroke-dasharray = given $graphics-context.line-style {
        when 1 { ""; }  # Solid line
        when 2 { " stroke-dasharray=\"5,5\""; }  # Dashed line
        when 3 { " stroke-dasharray=\"1,3\""; }  # Dotted line
        when 4 { " stroke-dasharray=\"5,3,1,3\""; }  # Dash-dot line
        default { ""; }  # Default to solid
    };
    
    my $svg-element = "<line x1=\"$pixel-x1\" y1=\"$pixel-y1\" x2=\"$pixel-x2\" y2=\"$pixel-y2\" " ~
                      "stroke=\"$color\" stroke-width=\"1\"$stroke-dasharray />";
    
    $graphics-context.add-element($svg-element);
    
    # Update current position to end point
    $graphics-context.current-x = $x2.Num;
    $graphics-context.current-y = $y2.Num;
}

# Move current position without drawing
sub move-to($x, $y) is export {
    $graphics-context.current-x = $x.Num;
    $graphics-context.current-y = $y.Num;
}

# Draw to position from current position
sub draw-to($x, $y) is export {
    if $graphics-context.beam-mode eq "ON" {
        draw-line($graphics-context.current-x, $graphics-context.current-y, $x, $y);
    }
    move-to($x, $y);
}

# Draw text at position
sub plot-text(Str $text, $x, $y) is export {
    if !$graphics-context.graphics-active {
        return;
    }
    
    my $pixel-x = world-to-pixel-x($x);
    my $pixel-y = world-to-pixel-y($y);
    my $color = get-color-hex($graphics-context.text-color);
    
    my $svg-element = "<text x=\"$pixel-x\" y=\"$pixel-y\" fill=\"$color\" " ~
                      "font-family=\"Arial\" font-size=\"12\">$text</text>";
    
    $graphics-context.add-element($svg-element);
    move-to($x, $y);
}

# Draw filled polygon
sub draw-filled-polygon(@points) is export {
    if !$graphics-context.graphics-active || @points.elems < 3 {
        return;
    }
    
    my @pixel-points = @points.map({
        my $px = world-to-pixel-x($_[0]);
        my $py = world-to-pixel-y($_[1]);
        "$px,$py";
    });
    
    my $points-str = @pixel-points.join(" ");
    my $color = get-color-hex($graphics-context.line-color);
    
    my $svg-element = "<polygon points=\"$points-str\" fill=\"$color\" />";
    $graphics-context.add-element($svg-element);
}

=begin pod
=head2 Graphics State Management
=end pod

# Set point style
sub set-point-style(Int $style) is export {
    $graphics-context.point-style = $style;
}

sub get-point-style() returns Int is export {
    return $graphics-context.point-style;
}

# Set point color
sub set-point-color(Int $color) is export {
    $graphics-context.point-color = $color;
}

sub get-point-color() returns Int is export {
    return $graphics-context.point-color;
}

# Set text color
sub set-text-color(Int $color) is export {
    $graphics-context.text-color = $color;
}

sub get-text-color() returns Int is export {
    return $graphics-context.text-color;
}

# Set line color
sub set-line-color(Int $color) is export {
    $graphics-context.line-color = $color;
}

sub get-line-color() returns Int is export {
    return $graphics-context.line-color;
}

# Set beam mode
sub set-beam-mode(Str $mode) returns Bool is export {
    my $upper-mode = $mode.uc;
    if $upper-mode eq "ON" || $upper-mode eq "OFF" {
        $graphics-context.beam-mode = $upper-mode;
        return True;
    }
    return False;
}

sub ask-beam-mode() returns Str is export {
    return $graphics-context.beam-mode;
}

# Get current position
sub ask-current-position() returns Array is export {
    return [$graphics-context.current-x, $graphics-context.current-y];
}

=begin pod
=head2 Graphics Initialization and Export
=end pod

# Graphics initialization
sub init-graphics(Str $output-file = 'plot.svg') is export {
    $graphics-context.output-file = $output-file;
    $graphics-context.graphics-active = True;
    clear-graphics();
    return True;
}

# Graphics cleanup and save
sub cleanup-graphics() is export {
    if $graphics-context.graphics-active {
        finalize-graphics();
    }
    
    $graphics-context.graphics-active = False;
    $graphics-context.clear-elements();
}

# Finalize and save graphics
sub finalize-graphics() is export {
    if !$graphics-context.graphics-active {
        return False;
    }
    
    try {
        # Generate SVG content
        my $svg-content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $svg-content ~= "<svg xmlns=\"http://www.w3.org/2000/svg\" ";
        $svg-content ~= "width=\"{$graphics-context.window-width}\" ";
        $svg-content ~= "height=\"{$graphics-context.window-height}\" ";
        $svg-content ~= "viewBox=\"0 0 {$graphics-context.window-width} {$graphics-context.window-height}\">\n";
        
        # Add white background
        $svg-content ~= "<rect width=\"100%\" height=\"100%\" fill=\"white\" />\n";
        
        # Add all graphics elements
        for $graphics-context.svg-elements -> $element {
            $svg-content ~= "  $element\n";
        }
        
        $svg-content ~= "</svg>\n";
        
        # Write to file
        $graphics-context.output-file.IO.spurt($svg-content);
        
        say "Graphics saved to: {$graphics-context.output-file}";
        return True;
    }
    
    CATCH {
        default {
            warn "Graphics finalization failed: {.message}";
            return False;
        }
    }
}

# Clear the graphics canvas
sub clear-graphics() is export {
    $graphics-context.clear-elements();
}

# Set output file
sub set-output-file(Str $filename) is export {
    $graphics-context.output-file = $filename;
}

# Export graphics to file (same as finalize)
sub export-graphics(Str $filename = $graphics-context.output-file) is export {
    $graphics-context.output-file = $filename;
    return finalize-graphics();
}

=begin pod
=head2 High-level Drawing Functions
=end pod

# Draw connected line segments
sub plot-lines(@coordinates) is export {
    return unless @coordinates.elems >= 2;
    
    my $first = True;
    for @coordinates.rotor(2) -> ($x, $y) {
        if $first {
            move-to($x, $y);
            $first = False;
        } else {
            draw-to($x, $y);
        }
    }
}

# Draw filled area (polygon)
sub plot-area(@coordinates) is export {
    return unless @coordinates.elems >= 6;  # At least 3 points (6 coordinates)
    
    my @points;
    for @coordinates.rotor(2) -> ($x, $y) {
        @points.push([$x, $y]);
    }
    
    draw-filled-polygon(@points);
}

=begin pod
=head1 EXPORTS

All graphics functions are exported for use in the True BASIC interpreter.

=head1 USAGE

    use Graphics;
    
    # Initialize graphics system
    init-graphics("my_plot.svg");
    
    # Set coordinate system
    set-window(0, 10, 0, 10);
    
    # Draw graphics
    plot-point(5.0, 5.0);
    draw-line(0.0, 0.0, 10.0, 10.0);
    plot-text("Hello", 5.0, 8.0);
    
    # Save and cleanup
    cleanup-graphics();

=head2 True BASIC Graphics Commands Supported

- SET WINDOW: Define world coordinate system
- SET VIEWPORT: Define screen coordinate viewport
- PLOT: Plot points and lines
- PLOT LINES: Draw connected line segments
- PLOT AREA: Draw filled polygons
- BEAM ON/OFF: Control line drawing mode
- CLEAR: Clear graphics canvas

=head2 Output Format

- SVG: Scalable Vector Graphics (universal browser support)

=end pod