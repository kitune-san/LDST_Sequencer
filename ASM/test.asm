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
    LD      AND
    LD      NAND
    LD      OR
    LD      NOR
    LD      NOT
    LD      XOR
    LD      XNOR
    LD      ADD
    LD      ADC
    LD      SUB
    LD      SBC
    LD      SHL
    LD      SHCL
    LD      SHR
    LD      SHCR
    LD      SAR
