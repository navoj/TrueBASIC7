! Sine wave plot with web graphics
GRAPHICS WEB
WINDOW 0, 0, 6.28, 1.2

! Plot sine wave
FOR X = 0 TO 6.28 STEP 0.1
    PLOT X, SIN(X) + 0.6
NEXT X

SHOW PLOT
PRINT "Sine wave plot saved to web_plot.html"
END