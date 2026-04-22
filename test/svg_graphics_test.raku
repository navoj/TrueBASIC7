#!/usr/bin/env raku

use v6.d;

# SVG-based graphics system for True BASIC
class SVGGraphics is export {
    has $.width is rw = 640;
    has $.height is rw = 480;
    has $.viewport-left is rw = 0.0;
    has $.viewport-right is rw = 1.0;
    has $.viewport-bottom is rw = 0.0;
    has $.viewport-top is rw = 1.0;
    has $.world-left is rw = 0.0;
    has $.world-right is rw = 1.0;
    has $.world-bottom is rw = 0.0;
    has $.world-top is rw = 1.0;
    has @.elements;
    
    method clear() {
        @.elements = ();
    }
    
    method world-to-pixel-x($world-x) returns Num {
        my $viewport-width = $.viewport-right - $.viewport-left;
        my $world-width = $.world-right - $.world-left;
        
        my $normalized = ($world-x.Num - $.world-left) / $world-width;
        return $.viewport-left * $.width + $normalized * $viewport-width * $.width;
    }
    
    method world-to-pixel-y($world-y) returns Num {
        my $viewport-height = $.viewport-top - $.viewport-bottom;
        my $world-height = $.world-top - $.world-bottom;
        
        my $normalized = ($world-y.Num - $.world-bottom) / $world-height;
        # Flip Y coordinate for SVG coordinates
        return $.height - ($.viewport-bottom * $.height + $normalized * $viewport-height * $.height);
    }
    
    method plot-point($x, $y, Int $color = 1, Int $style = 1) {
        my $pixel-x = self.world-to-pixel-x($x.Num);
        my $pixel-y = self.world-to-pixel-y($y.Num);
        my $rgb = self.get-color($color);
        
        given $style {
            when 1 { # Circle
                @.elements.push(qq[<circle cx="{$pixel-x}" cy="{$pixel-y}" r="2" fill="{$rgb}" />]);
            }
            when 2 { # Square
                @.elements.push(qq[<rect x="{$pixel-x - 2}" y="{$pixel-y - 2}" width="4" height="4" fill="{$rgb}" />]);
            }
            default { # Default circle
                @.elements.push(qq[<circle cx="{$pixel-x}" cy="{$pixel-y}" r="2" fill="{$rgb}" />]);
            }
        }
    }
    
    method draw-line($x1, $y1, $x2, $y2, Int $color = 1) {
        my $pixel-x1 = self.world-to-pixel-x($x1.Num);
        my $pixel-y1 = self.world-to-pixel-y($y1.Num);
        my $pixel-x2 = self.world-to-pixel-x($x2.Num);
        my $pixel-y2 = self.world-to-pixel-y($y2.Num);
        my $rgb = self.get-color($color);
        
        @.elements.push(qq[<line x1="{$pixel-x1}" y1="{$pixel-y1}" x2="{$pixel-x2}" y2="{$pixel-y2}" stroke="{$rgb}" stroke-width="1" />]);
    }
    
    method draw-polygon(@points, Int $color = 1, Bool $filled = False) {
        return unless @points.elems >= 3;
        
        my @pixel-points = @points.map({
            (self.world-to-pixel-x($_[0]), self.world-to-pixel-y($_[1]))
        });
        
        my $points-str = @pixel-points.map({ "{$_[0]},{$_[1]}" }).join(" ");
        my $rgb = self.get-color($color);
        
        if $filled {
            @.elements.push(qq[<polygon points="{$points-str}" fill="{$rgb}" />]);
        } else {
            @.elements.push(qq[<polygon points="{$points-str}" fill="none" stroke="{$rgb}" stroke-width="1" />]);
        }
    }
    
    method draw-text(Str $text, $x, $y, Int $color = 1, Int $size = 12) {
        my $pixel-x = self.world-to-pixel-x($x.Num);
        my $pixel-y = self.world-to-pixel-y($y.Num);
        my $rgb = self.get-color($color);
        
        @.elements.push(qq[<text x="{$pixel-x}" y="{$pixel-y}" fill="{$rgb}" font-size="{$size}">{$text}</text>]);
    }
    
    method get-color(Int $color-index) returns Str {
        given $color-index {
            when 0 { return "white"; }
            when 1 { return "black"; }
            when 2 { return "red"; }
            when 3 { return "green"; }
            when 4 { return "blue"; }
            when 5 { return "yellow"; }
            when 6 { return "magenta"; }
            when 7 { return "cyan"; }
            when 8 { return "gray"; }
            default { return "black"; }
        }
    }
    
    method to-svg() returns Str {
        my $svg = qq:to/END/;
        <?xml version="1.0" encoding="UTF-8"?>
        <svg width="{$.width}" height="{$.height}" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="white"/>
        {@.elements.join("\n")}
        </svg>
        END
        
        return $svg;
    }
    
    method save-to-file(Str $filename) {
        spurt $filename, self.to-svg();
    }
}

# Test the SVG graphics system
sub MAIN() {
    say "Testing SVG Graphics System...";
    
    my $graphics = SVGGraphics.new;
    
    # Set up coordinate system
    $graphics.world-left = 0;
    $graphics.world-right = 10;
    $graphics.world-bottom = 0;
    $graphics.world-top = 10;
    
    # Test basic shapes
    $graphics.plot-point(1, 1, 2);  # Red point
    $graphics.plot-point(2, 2, 3);  # Green point
    $graphics.plot-point(3, 3, 4);  # Blue point
    
    # Draw a line
    $graphics.draw-line(0, 0, 10, 10, 1);  # Black diagonal line
    
    # Draw a rectangle
    $graphics.draw-line(2, 2, 8, 2, 2);  # Top - red
    $graphics.draw-line(8, 2, 8, 8, 2);  # Right - red
    $graphics.draw-line(8, 8, 2, 8, 2);  # Bottom - red
    $graphics.draw-line(2, 8, 2, 2, 2);  # Left - red
    
    # Draw a triangle
    my @triangle = ((4, 6), (6, 6), (5, 8));
    $graphics.draw-polygon(@triangle, 3, False);  # Green triangle outline
    
    # Add some text
    $graphics.draw-text("SVG Graphics Test", 1, 9, 1, 16);
    
    # Save to file
    $graphics.save-to-file("plot.svg");
    
    say "SVG graphics test complete. Output saved to plot.svg";
    say "SVG content:";
    say $graphics.to-svg();
}