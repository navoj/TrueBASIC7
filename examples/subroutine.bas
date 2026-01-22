! Example 4: Subroutines and functions
10 GOSUB 100
20 PRINT "Back in main program"
30 END
100 REM Subroutine starts here
110 PRINT "This is a subroutine"
120 LET X = 5
130 LET Y = X * 2
140 PRINT "X ="; X; ", Y ="; Y
150 RETURN