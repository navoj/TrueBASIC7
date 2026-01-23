! Example: Sine wave plotting
10 REM Plot a sine wave
20 WINDOW -6.28, -1.2, 6.28, 1.2
30 FOR X = -6.28 TO 6.28 STEP 0.1
40   LET Y = SIN(X)
50   PLOT X, Y
60 NEXT X
70 SHOW PLOT
80 END