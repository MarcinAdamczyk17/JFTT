#!/bin/bash

flex -o scan.c zad3.l
gcc -O2 -o scan.exe scan.c -lm
./scan.exe < test.cpp
