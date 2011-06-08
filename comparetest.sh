#!/bin/bash
java Evil -dumpSPARC benchmarks/$1/$1.ev > $1.s
gcc -o evil_$1 -mcpu=v9 $1.s
gcc -o c_$1 benchmarks/$1/$1.c
gcc -o c_o1_$1 -O1 benchmarks/$1/$1.c
gcc -o c_o2_$1 -O2 benchmarks/$1/$1.c
gcc -o c_o3_$1 -O3 benchmarks/$1/$1.c
gcc -o c_o4_$1 -O4 benchmarks/$1/$1.c
echo "Evil Runtime"
time evil_$1 < benchmarks/$1/input > evil_$1.out
echo -e "\nC Runtime (unoptimized)"
time c_$1 < benchmarks/$1/input > c_$1.out
echo -e "\nC Runtime (o1 optimized)"
time c_o1_$1 < benchmarks/$1/input > c_o1_$1.out
echo -e "\nC Runtime (o2 optimized)"
time c_o2_$1 < benchmarks/$1/input > c_o2_$1.out
echo -e "\nC Runtime (o3 optimized)"
time c_o3_$1 < benchmarks/$1/input > c_o3_$1.out
echo -e "\nC Runtime (o4 unoptimized)"
time c_o4_$1 < benchmarks/$1/input > c_o4_$1.out
