#!/bin/bash
java Evil -dumpSPARC benchmarks/$1/$1.ev > $1.s
gcc -mcpu=v9 -g $1.s
a.out < benchmarks/$1/input > $1.out
diff benchmarks/$1/output $1.out
