define reg1 4
define reg2 5
define end  0xFFFF

START:
    LDI 10
    ST  reg1
    LDI 200
    ST  reg2
    LD  reg1
    ST  A
    LD  reg2
    ST  B
    LDI ADD
    ST  ALU
    LD  ALU
    ST  reg1
    ; END
    LDI end.L
    JMP end.h
