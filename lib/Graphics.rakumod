#!/usr/bin/env raku

=begin pod
=head1 Graphics Module - Web-Based Implementation

Web-based graphics system for the True BASIC interpreter.
Uses HTML5 Canvas and SVG for rendering, with optional HTTP server for live viewing.

Author: Translated from Pascal by AI Assistant
Based on work by SHIRAISHI Kazuo
=end pod

use v6.d;
use Statement;
use Expression; 
use Variable;

=begin pod
=head2 Graphics Operations Classes
=end pod

# Base graphics operation
role GraphicsOperation {
    method to-svg() { ... }
    method to-canvas-js() { ... }
}

# Text operation for graphics
class TextOperation does GraphicsOperation is export {
    has Str $.text is required;
    has Num $.x is required;
    has Num $.y is required;
    has Str $.color = "black";
    has Str $.font = "Arial";
    has Int $.size = 12;
    
    method to-svg() {
        qq[<text x="{$.x}" y="{$.y}" fill="{$.color}" font-family="{$.font}" font-size="{$.size}">{$.text}</text>]
    }
    
    method to-canvas-js() {
        qq[ctx.fillStyle = "{$.color}"; ctx.font = "{$.size}px {$.font}"; ctx.fillText("{$.text}", {$.x}, {$.y});]
    }
}

# Polygon operation for graphics
class PolygonOperation does GraphicsOperation is export {
    has @.points is required;
    has Str $.color = "black";
    has Bool $.filled = False;
    
    method to-svg() {
        my $points-str = @.points.map({ "{$_[0]},{$_[1]}" }).join(" ");
        my $style = $.filled ?? qq[fill="{$.color}"] !! qq[fill="none" stroke="{$.color}" stroke-width="1"];
        qq[<polygon points="{$points-str}" {$style} />]
    }
    
    method to-canvas-js() {
        my $js = "ctx.beginPath(); ";
        for @.points.kv -> $i, $point {
            if $i == 0 {
                $js ~= "ctx.moveTo({$point[0]}, {$point[1]}); ";
            } else {
                $js ~= "ctx.lineTo({$point[0]}, {$point[1]}); ";
            }
        }
        $js ~= "ctx.closePath(); ";
        if $.filled {
            $js ~= qq[ctx.fillStyle = "{$.color}"; ctx.fill();];
        } else {
            $js ~= qq[ctx.strokeStyle = "{$.color}"; ctx.stroke();];
        }
        return $js;
    }
}

# Line operation for graphics
class LineOperation does GraphicsOperation is export {
    has Num $.x1 is required;
    has Num $.y1 is required;
    has Num $.x2 is required;
    has Num $.y2 is required;
    has Str $.color = "black";
    has Int $.width = 1;
    
    method to-svg() {
        qq[<line x1="{$.x1}" y1="{$.y1}" x2="{$.x2}" y2="{$.y2}" stroke="{$.color}" stroke-width="{$.width}" />]
    }
    
    method to-canvas-js() {
        qq[ctx.beginPath(); ctx.moveTo({$.x1}, {$.y1}); ctx.lineTo({$.x2}, {$.y2}); ctx.strokeStyle = "{$.color}"; ctx.lineWidth = {$.width}; ctx.stroke();]
    }
}

# Circle operation for graphics
class CircleOperation does GraphicsOperation is export {
    has Num $.x is required;
    has Num $.y is required;
    has $.radius is required;
    has Str $.color = "black";
    has Bool $.filled = False;
    
    method to-svg() {
        my $style = $.filled ?? qq[fill="{$.color}"] !! qq[fill="none" stroke="{$.color}" stroke-width="1"];
        qq[<circle cx="{$.x}" cy="{$.y}" r="{$.radius}" {$style} />]
    }
    
    method to-canvas-js() {
        my $js = qq[ctx.beginPath(); ctx.arc({$.x}, {$.y}, {$.radius}, 0, 2 * Math.PI); ];
        if $.filled {
            $js ~= qq[ctx.fillStyle = "{$.color}"; ctx.fill();];
        } else {
            $js ~= qq[ctx.strokeStyle = "{$.color}"; ctx.stroke();];
        }
        return $js;
    }
}

# Simple number wrapper
class TBNumber is export {
    has Num $.value is required;
    
    method new(Num :$value) {
        self.bless: :$value;
    }
}

# Simple string wrapper
class TBString is export {
    has Str $.value is required;
    
    method new(Str :$value) {
        self.bless: :$value;
    }
}

# Graphics context and state
class GraphicsContext is export {
    has $.window-width is rw = 800;
    has $.window-height is rw = 600;
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
    
    # Graphics operations and output
    has @.operations;
    has Bool $.graphics-active is rw = False;
    has Str $.output-file is rw = "plot.html";
    
    method add-operation(GraphicsOperation $op) {
        @.operations.push($op);
    }
    
    method clear-operations() {
        @.operations = ();
    }
    
    # Coordinate transformations
    method world-to-pixel($x, $y) {
        my $px = (($x - $.world-left) / ($.world-right - $.world-left)) * 
                 ($.viewport-right - $.viewport-left) * $.window-width;
        my $py = (($.world-top - $y) / ($.world-top - $.world-bottom)) * 
                 ($.viewport-top - $.viewport-bottom) * $.window-height;
        return ($px.Num, $py.Num);
    }
    
    method pixel-to-world($px, $py) {
        my $x = ($px / $.window-width / ($.viewport-right - $.viewport-left)) * 
                ($.world-right - $.world-left) + $.world-left;
        my $y = $.world-top - ($py / $.window-height / ($.viewport-top - $.viewport-bottom)) * 
                ($.world-top - $.world-bottom);
        return ($x.Num, $y.Num);
    }
    
    method to-html() {
        my $html = '<!DOCTYPE html><html><head><title>TrueBASIC Graphics</title>';
        $html ~= '<style>body{margin:20px;font-family:Arial}canvas{border:1px solid black}</style>';
        $html ~= '</head><body><h2>TrueBASIC Graphics</h2>';
        $html ~= "<canvas id=\"canvas\" width=\"{$.window-width}\" height=\"{$.window-height}\"></canvas>";
        $html ~= '<div><svg width="' ~ $.window-width ~ '" height="' ~ $.window-height ~ '" xmlns="http://www.w3.org/2000/svg">';
        
        # Add SVG operations
        for @.operations -> $op {
            $html ~= $op.to-svg();
        }
        
        $html ~= '</svg></div>';
        $html ~= '<script>const canvas = document.getElementById("canvas");';
        $html ~= 'const ctx = canvas.getContext("2d");';
        $html ~= 'ctx.clearRect(0, 0, canvas.width, canvas.height);';
        
        # Add Canvas JavaScript operations
        for @.operations -> $op {
            $html ~= $op.to-canvas-js();
        }
        
        $html ~= '</script></body></html>';
        
        return $html;
    }
    
    method save-to-file() {
        my $html = self.to-html();
        spurt $.output-file, $html;
        say "Graphics saved to {$.output-file}";
    }
}

# Global graphics context
our $graphics-context = GraphicsContext.new();

# Utility functions for coordinate systems
sub init-graphics($width = 800, $height = 600) is export {
    $graphics-context.window-width = $width;
    $graphics-context.window-height = $height;
    $graphics-context.graphics-active = True;
}

sub set-viewport($left, $right, $bottom, $top) is export {
    $graphics-context.viewport-left = $left;
    $graphics-context.viewport-right = $right;
    $graphics-context.viewport-bottom = $bottom;
    $graphics-context.viewport-top = $top;
}

sub set-window($left, $right, $bottom, $top) is export {
    $graphics-context.world-left = $left;
    $graphics-context.world-right = $right;
    $graphics-context.world-bottom = $bottom;
    $graphics-context.world-top = $top;
}


# TrueBASIC graphics command functions
sub plot($x, $y) is export {
    my ($px, $py) = $graphics-context.world-to-pixel($x, $y);
    if $graphics-context.beam-mode eq "ON" && 
       ($graphics-context.current-x != 0.0 || $graphics-context.current-y != 0.0) {
        my $line = LineOperation.new(
            x1 => $graphics-context.current-x,
            y1 => $graphics-context.current-y,
            x2 => $px,
            y2 => $py,
            color => "black"
        );
        $graphics-context.add-operation($line);
    }
    $graphics-context.current-x = $px;
    $graphics-context.current-y = $py;
}

sub move($x, $y) is export {
    my ($px, $py) = $graphics-context.world-to-pixel($x, $y);
    $graphics-context.current-x = $px;
    $graphics-context.current-y = $py;
}

sub draw-line($x1, $y1, $x2, $y2) is export {
    my ($px1, $py1) = $graphics-context.world-to-pixel($x1, $y1);
    my ($px2, $py2) = $graphics-context.world-to-pixel($x2, $y2);
    my $line = LineOperation.new(
        x1 => $px1, y1 => $py1,
        x2 => $px2, y2 => $py2,
        color => "black"
    );
    $graphics-context.add-operation($line);
}

sub draw-circle($x, $y, $radius) is export {
    my ($px, $py) = $graphics-context.world-to-pixel($x, $y);
    my $circle = CircleOperation.new(
        x => $px, y => $py,
        radius => $radius,
        color => "black"
    );
    $graphics-context.add-operation($circle);
}

sub draw-text($x, $y, $text) is export {
    my ($px, $py) = $graphics-context.world-to-pixel($x, $y);
    my $text-op = TextOperation.new(
        x => $px, y => $py,
        text => $text,
        color => "black",
        font-size => 12
    );
    $graphics-context.add-operation($text-op);
}

sub draw-polygon(@points) is export {
    my @pixel-points = @points.map: -> ($x, $y) {
        $graphics-context.world-to-pixel($x, $y);
    };
    my $polygon = PolygonOperation.new(
        points => @pixel-points,
        color => "black",
        filled => False
    );
    $graphics-context.add-operation($polygon);
}

# Control functions
sub beam-on() is export {
    $graphics-context.beam-mode = "ON";
}

sub beam-off() is export {
    $graphics-context.beam-mode = "OFF";
}

sub clear-graphics() is export {
    $graphics-context.clear-operations();
}

sub save-graphics($filename = "plot.html") is export {
    $graphics-context.output-file = $filename;
    $graphics-context.save-to-file();
}

# Refresh canvas function
sub refresh-canvas() is export {
    $graphics-context.save-to-file();
    say "Graphics refreshed and saved to {$graphics-context.output-file}";
}

# Canvas clearing function for graphics examples
sub clear-canvas() is export {
    clear-graphics();
}

# Compatibility functions for existing TrueBASIC graphics commands
sub clear() is export { clear-graphics(); }
sub open-graph() is export { init-graphics(); }
sub close-graph() is export { save-graphics(); }

