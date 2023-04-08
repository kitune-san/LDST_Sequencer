#!/bin/sh

python ../ASM/ldstasm.py program.asm -o a.v
iverilog -o tb.vvp DEBUG_LDST_SYSTEM.sv ../HDL/LDST_SEQUENCER.v ../HDL/template.v a.v -g2012 -DIVERILOG -DLDST_DEBUG
vvp tb.vvp
gtkwave tb.vcd

