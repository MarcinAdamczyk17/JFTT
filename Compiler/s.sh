#!/bin/bash

bison -d --debug -t cppcalc.yy
flex cppcalc.l
g++ lex.yy.c cppcalc.tab.cc -lfl -lcln -std=c++11 -o kompilator.exe
cat test.txt | ./kompilator.exe -t
