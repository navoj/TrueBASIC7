! Simple Hilbert Space-Filling Curve Pattern
10 PRINT "Hilbert Curve Pattern Generator"
20 PRINT "Drawing a basic Hilbert curve..."

30 ! Set up the drawing window  
40 WINDOW 0, 20, 0, 20

50 ! Draw just a few lines to test
60 LINE 3, 3, 3, 7
70 LINE 3, 7, 7, 7  
80 LINE 7, 7, 7, 3

90 PRINT "Lines drawn"

100 ! Set graphics mode to popup and show
110 GRAPHICS popup
120 PRINT "Graphics mode set"  
130 SHOW PLOT
140 PRINT "Hilbert curve displayed in popup window!"
150 END

