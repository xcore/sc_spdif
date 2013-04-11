#!/bin/sh

echo ',0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15'
echo ',"0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"'

cd states
for pat in "L*[01a]" "L*S" "L*T" "L*U"
do
 > /tmp/xxx
for i in $pat
do
awk < $i '
/BRU/{
  lookup[0] = 0;
  lookup[1] = 8;
  lookup[2] = 4;
  lookup[3] = 12;
  lookup[4] = 2;
  lookup[5] = 10;
  lookup[6] = 6;
  lookup[7] = 14;
  lookup[8] = 1;
  lookup[9] = 9;
  lookup[10] = 5;
  lookup[11] = 13;
  lookup[12] = 3;
  lookup[13] = 11;
  lookup[14] = 7;
  lookup[15] = 15;
  for(i = 0; i < 16; i++) {
    lookupi[i] = 15 - lookup[i];
  }
  capture = 1;
  pattern = 0;
  next;
}
(capture == 1) {
  if ($2 == "ERROR") {
    patterns[pattern++] = "-";
  } else {
    patterns[pattern++] = $2;
  }
  if (pattern == 16) {
    printf("'$i',");
    for(i = 0; i < 16; i++) {
      printf ("\"%s\",", patterns[lookup[i]]);
    } 
    printf("\n");
    z="'$i'";
    zi = "";
    for(j = 1; j <= length(z); j++) {
      if (substr(z,j,1) == "0") {
        zi = zi "1";
      } else if (substr(z,j,1) == "1") {
        zi = zi "0";
      } else {
        zi = zi substr(z, j, 1);
      }
    }
    printf("%s,", zi);
    for(i = 0; i < 16; i++) {
      zi = "";
      z = patterns[lookupi[i]];
      conv = 1;
      for(j = 1; j <= length(z); j++) {
        if (conv && substr(z,j,1) == "0") {
          zi = zi "1";
        } else if (conv && substr(z,j,1) == "1") {
          zi = zi "0";
        } else {
          if (substr(z, j, 1) == "_") {
            conv = 0;
          }
          zi = zi substr(z, j, 1);
        }
      } 
      printf ("\"%s\",", zi);
    } 
    printf("\n");
  }
}
' > /tmp/xx
head -1 /tmp/xx
tail -1 /tmp/xx >> /tmp/xxx
done
cat /tmp/xxx
rm -f /tmp/xxx /tmp/xx
done