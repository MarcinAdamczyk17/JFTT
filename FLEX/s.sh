#!/bin/bash

flex -o scan.c zad2.l
gcc -O3 -o scan.exe scan.c
./scan.exe < test.cpp

