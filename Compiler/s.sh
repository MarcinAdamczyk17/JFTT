#!/bin/bash

bison cppcalc.yy -d
flex cppcalc.l
g++ lex.yy.c cppcalc.tab.cc -lfl -lcln -std=c++11
cat test.txt | ./a.out -t
