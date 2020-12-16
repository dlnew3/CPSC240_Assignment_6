/**********************************************************************************************************************************
Program name: "Harmonic Sum". This program calculates the Harmonic Sum of a given integer, as well as output the elapsed time of 
    calculation via the CPU's clock tics converted to seconds. Copyright (C) 2020 Dennis Newman

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License  *
version 3 as published by the Free Software Foundation.                                                                    *
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied         *
Warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.     *
A copy of the GNU General Public License v3 is available here:  <https://www.gnu.org/licenses/>.

Author Information
    Author Name: Dennis Newman
    Author email: dlnew3@csu.fullerton.edu

Program Information
   Program Name: Harmonic Sum
   Program Languages: One module in C++, two modules in x86
   Date Program began: Dec. 8, 2020
   Date Program completed:
   Files in this program: main.cpp, manager.asm, read_clock.asm, r.sh
   Status: In Progress

References for this program
   Jorgensen, X86-64 Assembly Language Programming with Ubuntu, Version 1.1.40.

This File
   File Name: main.cpp
   Language: C++
   Compile this file: g++ -c -m64 -Wall -o main.o main.cpp -fno-pie -no-pie -std=c++17
   Link this program: g++ -m64 -o hsum.out main.o manager.o read_clock.o -fno-pie -no-pie -std=c++17
**********************************************************************************************************************************/
//*******************************************************Beginning of Code*********************************************************

#include <stdio.h>
#include <stdlib.h>
//#include <iostream>

using namespace std;

extern "C" double hsum();

int main(){
    printf("Welcome to the Harmonic Sum Calculator\n");
    printf("By Dennis Newman\n");
    double output = -1.000000;
    //Initializing output with -1, as a negative value would easily indicate an error during computation
    output = hsum();
    printf("\nThe driver received the value: %lf", output);
    printf("\nReturning 0 to the Operating System. This program will now close.");
    return 0;
}//End of main