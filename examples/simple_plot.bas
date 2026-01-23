! Simple test without negative numbers
10 WINDOW 0, 0, 10, 25
20 FOR X = 0 TO 5 STEP 0.5
30   LET Y = X * X
40   PLOT X, Y
50 NEXT X
60 GRAPHICS ASCII
70 SHOW PLOT
80 END