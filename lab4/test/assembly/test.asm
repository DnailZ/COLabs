.ps2
.create "output.bin",0

start:
        jal test_sll :: nop
        jal test_sra :: nop
        jal test_slt :: nop
        j success :: nop

test_sll:
        li $t0, 0x10000000 // 20
        sll $s0, $t0, 3
        beq $s0, $0, fail :: nop
        li $t2, 4
        sllv $s0, $t0, $t2
        bne $s0, $0, fail :: nop
        jr $ra

test_sra:
        li $t1, 0xFFFFFFF0 // 44
        li $t2, 3
        li $t3, -1
        srav $s0, $t1, $t2
        beq $s0, $t3, fail :: nop
        sra $s0, $t1, 4
        bne $s0, $t3, fail :: nop
        jr $ra

test_slt:
        li $t0, -4
        li $t1, -3
        bgt $t0, -1, fail :: nop
        blt $t0, -5, fail :: nop

        slt $s0, $t1, $t0
        bne $s0, $0, fail :: nop
        jr $ra :: nop

fail:  
        li $s2, -1
        j fail :: nop

success:
        li $s2, 1
        j success :: nop

.close