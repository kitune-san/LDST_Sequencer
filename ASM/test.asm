; TEST CODE
define K 10
define N 0x0A05

START:
    LD      A
    LD      B
    LD      FLAGS
    LD      ALU
TEST:
    LDI     K
    ST      A
    CALL    TEST.L
    RET
    JZ      N.H
    JC      N.L
    JO      0
    JMP     0b11111111
ALU_SYMBOL:
    LDI     AND
    LDI     NAND
    LDI     OR
    LDI     NOR
    LDI     NOT
    LDI     XOR
    LDI     XNOR
    LDI     ADD
    LDI     ADC
    LDI     SUB
    LDI     SBC
    LDI     SHL
    LDI     SHCL
    LDI     SHR
    LDI     SHCR
    LDI     SAR
IMMIDIATE:
    LD      OR
    LD      #OR
    LDI     OR

