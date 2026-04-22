#!/usr/bin/env raku

=begin pod
=head1 Simple Graphics Module

A standalone SVG-based graphics system for True BASIC plotting.
=end pod

use v6.d;

# Graphics context for SVG output
class SVGGraphics is export {
    has $.width is rw = 640;
    has $.height is rw = 480;
    has $.world-left is rw = 0.0;
    has $.world-right is rw = 1.0; 
    has $.world-bottom is rw = 0.0;
    has $.world-top is rw = 1.0;
    has @.elements is rw = ();
    has $.current-color is rw = "black";
    
    method world-to-pixel($x, $y) {
        my $px = ($x - $!world-left) * $!width / ($!world-right - $!world-left);
        my $py = $!height - ($y - $!world-bottom) * $!height / ($!world-top - $!world-bottom);
        return ($px, $py);
    }
    
    method plot-point($x, $y) {
        my ($px, $py) = self.world-to-pixel($x, $y);
        @!elements.push: qq{<circle cx="$px" cy="$py" r="2" fill="{$!current-color}" />};
    }
    
    method draw-line($x1, $y1, $x2, $y2) {
        my ($px1, $py1) = self.world-to-pixel($x1, $y1);
        my ($px2, $py2) = self.world-to-pixel($x2, $y2);
        @!elements.push: qq{<line x1="$px1" y1="$py1" x2="$px2" y2="$py2" stroke="{$!current-color}" stroke-width="1" />};
    }
    
    method plot-text($text, $x, $y) {
        my ($px, $py) = self.world-to-pixel($x, $y);
        @!elements.push: qq{<text x="$px" y="$py" font-family="Arial" font-size="12" fill="{$!current-color}">$text</text>};
    }
    
    method draw-polygon(@points) {
        my @svg-points = ();
        for @points -> ($x, $y) {
            my ($px, $py) = self.world-to-pixel($x, $y);
            @svg-points.push: "$px,$py";
        }
        my $points-str = @svg-points.join(' ');
        @!elements.push: qq{<polygon points="$points-str" fill="none" stroke="{$!current-color}" stroke-width="1" />};
    }
    
    method to-svg() {
        my $header = qq{<?xml version="1.0" encoding="UTF-8"?>
<svg width="$!width" height="$!height" xmlns="http://www.w3.org/2000/svg">};
        my $footer = "</svg>";
        return $header ~ "\n" ~ @!elements.join("\n") ~ "\n" ~ $footer;
    }
    
    method clear() {
        @!elements = ();
    }
}

# Global graphics context
our $graphics is export = SVGGraphics.new;

# Graphics functions
sub init-graphics() is export {
    $graphics = SVGGraphics.new;
    return True;
}

sub set-window($left, $right, $bottom, $top) is export {
    $graphics.world-left = $left;
    $graphics.world-right = $right;
    $graphics.world-bottom = $bottom;
    $graphics.world-top = $top;
}

sub plot-point($x, $y) is export {
    $graphics.plot-point($x, $y);
}

sub draw-line($x1, $y1, $x2, $y2) is export {
    $graphics.draw-line($x1, $y1, $x2, $y2);
}

sub plot-text($text, $x, $y) is export {
    $graphics.plot-text($text, $x, $y);
}

sub draw-polygon(@points) is export {
    $graphics.draw-polygon(@points);
}

sub set-color($color) is export {
    $graphics.current-color = $color;
}

sub export-graphics($filename) is export {
    spurt $filename, $graphics.to-svg();
    say "Graphics exported to $filename";
}

sub cleanup-graphics() is export {
    $graphics.clear();
}