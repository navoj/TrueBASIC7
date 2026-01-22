! Example 6: DO/LOOP with conditions
10 LET COUNT = 0
20 DO
30   LET COUNT = COUNT + 1
40   PRINT "Count is"; COUNT
50   IF COUNT = 3 THEN PRINT "Halfway there!"
60 LOOP UNTIL COUNT = 5
70 PRINT "Loop finished!"
80 END