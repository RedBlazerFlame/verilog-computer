LDI r1 1
LDI r2 1
LDI r4 64
.loop ADD r1 r2 r3
MOV r2 r1
MOV r3 r2
STR r0 r3 0
SBI r4 1
CMP r4 r0
BRH notzero .loop
MUL r1 r2 r5
ADI r5 1
STR r0 r5 0
HLT