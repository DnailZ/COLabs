.ps2
.create "output.bin",0
    lw $v1, data
    nop
    addi $v1, $v1, 8
forever:
    nop :: nop :: nop :: nop
    beqz $1, forever
    nop :: nop :: nop :: nop
data:
    .word 23333
.close