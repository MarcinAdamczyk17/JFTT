#!/bin/bash

bison -d rpcalc.y -o rpcalc.c
flex -o scan.c scan.l
gcc scan.c rpcalc.c -lm -lfl -o parse.exe
cat test.txt | ./parse.exe -t
