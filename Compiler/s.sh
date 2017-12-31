#!/bin/bash

bison -d --debug -t cppcalc.yy
flex cppcalc.l
g++ lex.yy.c cppcalc.tab.cc -lfl -std=c++14 -o kompilator.exe
cat $1 | ./kompilator.exe -t
