#!/usr/bin/env raku

=begin pod
=head1 Graphics Module - Gnome::Cairo Version

Translation of graphic.pas from Decimal BASIC to Raku
Contains graphics and plotting functionality for the True BASIC interpreter.
Uses Gnome::Cairo for rendering to SVG and PNG files.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Gnome::Cairo;

=begin pod
=head2 Graphics System Core with Gnome::Cairo
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
    
    # Gnome::Cairo objects
    has Gnome::Cairo $.surface is rw;
    has Gnome::Cairo $.cairo-context is rw;
    has Bool $.graphics-active is rw = False;
    has Str $.output-file is rw = 'plot.svg';
    has @.drawing-operations;
    
    method add-operation($op) {
        @.drawing-operations.push($op);
    }
    
    method clear-operations() {
        @.drawing-operations = ();
    }
}

my $graphics-context = GraphicsContext.new;

=begin pod
=head2 Drawing Operation Classes
=end pod

# Base class for drawing operations
role DrawingOperation {
    method execute($cairo-context) { ... }
}

class PointOperation does DrawingOperation {
    has Num $.x;
    has Num $.y;
    has Int $.color;
    has Int $.style;
    
    method execute($cairo-context) {
        my $pixel-x = world-to-pixel-x($.x);
        my $pixel-y = world-to-pixel-y($.y);
        
        # Set color
        set-cairo-color($cairo-context, $.color);
        
        # Draw point based on style
        given $.style {
            when 1 { # Small circle
                $cairo-context.arc($pixel-x, $pixel-y, 2, 0, 2 * π);
                $cairo-context.fill;
            }
            when 2 { # Square
                $cairo-context.rectangle($pixel-x - 2, $pixel-y - 2, 4, 4);
                $cairo-context.fill;
            }
            when 3 { # Plus sign
                $cairo-context.move_to($pixel-x - 3, $pixel-y);
                $cairo-context.line_to($pixel-x + 3, $pixel-y);
                $cairo-context.move_to($pixel-x, $pixel-y - 3);
                $cairo-context.line_to($pixel-x, $pixel-y + 3);
                $cairo-context.stroke;
            }
            default { # Default to circle
                $cairo-context.arc($pixel-x, $pixel-y, 2, 0, 2 * π);
                $cairo-context.fill;
            }
        }
    }
}

class LineOperation does DrawingOperation {
    has Num $.x1;
    has Num $.y1;
    has Num $.x2;
    has Num $.y2;
    has Int $.color;
    has Int $.style;
    
    method execute($cairo-context) {
        my $pixel-x1 = world-to-pixel-x($.x1);
        my $pixel-y1 = world-to-pixel-y($.y1);
        my $pixel-x2 = world-to-pixel-x($.x2);
        my $pixel-y2 = world-to-pixel-y($.y2);
        
        set-cairo-color($cairo-context, $.color);
        set-cairo-line-style($cairo-context, $.style);
        
        $cairo-context.move_to($pixel-x1, $pixel-y1);
        $cairo-context.line_to($pixel-x2, $pixel-y2);
        $cairo-context.stroke;
    }
}

class TextOperation does DrawingOperation {
    has Str $.text;
    has Num $.x;
    has Num $.y;
    has Int $.color;
    has Str $.font;
    has Int $.size;
    
    method execute($cairo-context) {
        my $pixel-x = world-to-pixel-x($.x);
        my $pixel-y = world-to-pixel-y($.y);
        
        set-cairo-color($cairo-context, $.color);
        
        # Set font
        $cairo-context.select_font_face($.font // "Arial", 0, 0);
        $cairo-context.set_font_size($.size // 12);
        
        $cairo-context.move_to($pixel-x, $pixel-y);
        $cairo-context.show_text($.text);
    }
}

class ClearOperation does DrawingOperation {
    has Int $.color;
    
    method execute($cairo-context) {
        set-cairo-color($cairo-context, $.color // 0);
        $cairo-context.paint;
    }
}

=begin pod
=head2 Coordinate Transformation Functions
=end pod

# Convert world coordinates to pixel coordinates
sub world-to-pixel-x(Num $world-x) returns Int is export {
    my $viewport-width = $graphics-context.viewport-right - $graphics-context.viewport-left;
    my $world-width = $graphics-context.world-right - $graphics-context.world-left;
    
    my $normalized = ($world-x - $graphics-context.world-left) / $world-width;
    my $pixel-x = $graphics-context.viewport-left * $graphics-context.window-width + 
                  $normalized * $viewport-width * $graphics-context.window-width;
    
    return $pixel-x.Int;
}

sub world-to-pixel-y(Num $world-y) returns Int is export {
    my $viewport-height = $graphics-context.viewport-top - $graphics-context.viewport-bottom;
    my $world-height = $graphics-context.world-top - $graphics-context.world-bottom;
    
    my $normalized = ($world-y - $graphics-context.world-bottom) / $world-height;
    # Flip Y coordinate for screen coordinates
    my $pixel-y = $graphics-context.window-height - 
                  ($graphics-context.viewport-bottom * $graphics-context.window-height + 
                   $normalized * $viewport-height * $graphics-context.window-height);
    
    return $pixel-y.Int;
}

=begin pod
=head2 Cairo Helper Functions
=end pod

sub set-cairo-color($cairo-context, Int $color-index) {
    # Convert color index to RGB values
    my ($r, $g, $b) = get-color-rgb($color-index);
    $cairo-context.set_source_rgb($r, $g, $b);
}

sub get-color-rgb(Int $color-index) returns List {
    # True BASIC color palette
    given $color-index {
        when 0 { return (1.0, 1.0, 1.0); }  # White
        when 1 { return (0.0, 0.0, 0.0); }  # Black
        when 2 { return (1.0, 0.0, 0.0); }  # Red
        when 3 { return (0.0, 1.0, 0.0); }  # Green
        when 4 { return (0.0, 0.0, 1.0); }  # Blue
        when 5 { return (1.0, 1.0, 0.0); }  # Yellow
        when 6 { return (1.0, 0.0, 1.0); }  # Magenta
        when 7 { return (0.0, 1.0, 1.0); }  # Cyan
        when 8 { return (0.5, 0.5, 0.5); }  # Gray
        default { return (0.0, 0.0, 0.0); } # Default to black
    }
}

sub set-cairo-line-style($cairo-context, Int $style) {
    given $style {
        when 1 { # Solid line
            $cairo-context.set_dash((), 0);
        }
        when 2 { # Dashed line
            $cairo-context.set_dash((5, 5), 0);
        }
        when 3 { # Dotted line
            $cairo-context.set_dash((1, 3), 0);
        }
        when 4 { # Dash-dot line
            $cairo-context.set_dash((5, 3, 1, 3), 0);
        }
        default { # Default to solid
            $cairo-context.set_dash((), 0);
        }
    }
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
    
    my $point-op = PointOperation.new(
        x => $x.Num,
        y => $y.Num,
        color => $graphics-context.point-color,
        style => $graphics-context.point-style
    );
    
    $graphics-context.add-operation($point-op);
    
    # Update current position
    $graphics-context.current-x = $x.Num;
    $graphics-context.current-y = $y.Num;
}

# Line drawing
sub draw-line($x1, $y1, $x2, $y2) is export {
    if !$graphics-context.graphics-active {
        return;
    }
    
    my $line-op = LineOperation.new(
        x1 => $x1.Num,
        y1 => $y1.Num,
        x2 => $x2.Num,
        y2 => $y2.Num,
        color => $graphics-context.line-color,
        style => $graphics-context.line-style
    );
    
    $graphics-context.add-operation($line-op);
    
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
    
    my $text-op = TextOperation.new(
        text => $text,
        x => $x.Num,
        y => $y.Num,
        color => $graphics-context.text-color,
        font => "Arial",
        size => 12
    );
    
    $graphics-context.add-operation($text-op);
    move-to($x, $y);
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
    
    try {
        say "Creating Cairo surface for: $output-file" if $*DEBUG;
        
        # Create Cairo surface for SVG output
        $graphics-context.surface = Gnome::Cairo.new;
        $graphics-context.surface.surface-create-svg(
            $output-file,
            $graphics-context.window-width,
            $graphics-context.window-height
        );
        
        say "Creating Cairo context..." if $*DEBUG;
        
        # Create Cairo context
        $graphics-context.cairo-context = Gnome::Cairo.new;
        $graphics-context.cairo-context.create($graphics-context.surface);
        
        say "Clearing background..." if $*DEBUG;
        
        # Clear background to white
        clear-graphics();
        
        $graphics-context.graphics-active = True;
        say "Graphics initialized successfully" if $*DEBUG;
        return True;
    }
    
    CATCH {
        default {
            say "Graphics initialization failed: {.message}";
            say "Backtrace: {.backtrace}";
            $graphics-context.graphics-active = False;
            return False;
        }
    }
}

# Graphics cleanup and save
sub cleanup-graphics() is export {
    if $graphics-context.graphics-active {
        finalize-graphics();
    }
    
    $graphics-context.graphics-active = False;
    $graphics-context.clear-operations();
    $graphics-context.surface = Any;
    $graphics-context.cairo-context = Any;
}

# Finalize and save graphics
sub finalize-graphics() is export {
    if !$graphics-context.graphics-active || !$graphics-context.cairo-context {
        return False;
    }
    
    try {
        # Execute all drawing operations
        for $graphics-context.drawing-operations -> $operation {
            $operation.execute($graphics-context.cairo-context);
        }
        
        # Finalize the surface
        $graphics-context.cairo-context.show_page;
        
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
    if !$graphics-context.graphics-active {
        return;
    }
    
    my $clear-op = ClearOperation.new(color => 0);  # White background
    $graphics-context.clear-operations();
    $graphics-context.add-operation($clear-op);
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
=head1 EXPORTS

All graphics functions are exported for use in the True BASIC interpreter.

=head1 USAGE

    use GnomeGraphics;
    
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
- BEAM ON/OFF: Control line drawing mode
- CLEAR: Clear graphics canvas

=head2 Output Formats

- SVG: Scalable Vector Graphics (default)
- PNG: Available through Cairo (future enhancement)

=end pod