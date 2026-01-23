! Example: ASCII plotting for terminal display
10 REM Simple parabola in ASCII
20 WINDOW -5, 0, 5, 25
30 FOR X = -5 TO 5 STEP 0.5
40   LET Y = X * X
50   PLOT X, Y
60 NEXT X
70 GRAPHICS ASCII
80 SHOW PLOT
90 END