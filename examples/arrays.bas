! Example 5: Arrays and data processing
10 DIM NUMBERS(5)
20 PRINT "Enter 5 numbers:"
30 FOR I = 1 TO 5
40   PRINT "Number"; I; ": ";
50   INPUT N
60   LET NUMBERS(I) = N
70 NEXT I
80 PRINT "You entered:"
90 FOR I = 1 TO 5
100   PRINT "NUMBERS("; I; ") ="; NUMBERS(I)
110 NEXT I
120 END