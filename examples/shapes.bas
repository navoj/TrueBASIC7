! Example: Simple line plot
10 REM Draw some lines and shapes
20 WINDOW 0, 0, 10, 10
30 LINE 1, 1, 9, 9
40 LINE 1, 9, 9, 1
50 CIRCLE 5, 5, 2
60 FOR I = 0 TO 10
70   PLOT I, I * I / 10
80 NEXT I
90 SHOW PLOT
100 END