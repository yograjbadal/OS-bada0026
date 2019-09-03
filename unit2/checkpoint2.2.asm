  .file [name="checkpoint2.2.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  // Some definitions of address and special values that this program uses
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  .const JMP = $4c
  .const NOP = $ea
.segment Code
main: {
    .label sc = 4
    .label msg = 2
    lda #$14
    sta VIC_MEMORY
    ldx #' '
    lda #<SCREEN
    sta.z memset.str
    lda #>SCREEN
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    ldx #WHITE
    lda #<COLS
    sta.z memset.str
    lda #>COLS
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    lda #<SCREEN+$28
    sta.z sc
    lda #>SCREEN+$28
    sta.z sc+1
    lda #<MASSAGE
    sta.z msg
    lda #>MASSAGE
    sta.z msg+1
  b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne b2
  b3:
    lda #$36
    cmp RASTER
    beq b4
    lda #$42
    cmp RASTER
    beq b4
    lda #BLACK
    sta BGCOL
    jmp b3
  b4:
    lda #WHITE
    sta BGCOL
    jmp b3
  b2:
    ldy #0
    lda (msg),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z msg
    bne !+
    inc.z msg+1
  !:
    jmp b1
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage(4) str, byte register(X) c, word zeropage(2) num)
memset: {
    .label end = 2
    .label dst = 4
    .label num = 2
    .label str = 4
    lda.z num
    bne !+
    lda.z num+1
    beq breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  b2:
    lda.z dst+1
    cmp.z end+1
    bne b3
    lda.z dst
    cmp.z end
    bne b3
  breturn:
    rts
  b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp b2
}
syscall64: {
    rts
}
syscall63: {
    rts
}
syscall62: {
    rts
}
syscall61: {
    rts
}
syscall60: {
    rts
}
syscall59: {
    rts
}
syscall58: {
    rts
}
syscall57: {
    rts
}
syscall56: {
    rts
}
syscall55: {
    rts
}
syscall54: {
    rts
}
syscall53: {
    rts
}
syscall52: {
    rts
}
syscall51: {
    rts
}
syscall50: {
    rts
}
syscall49: {
    rts
}
syscall48: {
    rts
}
syscall47: {
    rts
}
syscall46: {
    rts
}
syscall45: {
    rts
}
syscall44: {
    rts
}
syscall43: {
    rts
}
syscall42: {
    rts
}
syscall41: {
    rts
}
syscall40: {
    rts
}
syscall39: {
    rts
}
syscall38: {
    rts
}
syscall37: {
    rts
}
syscall36: {
    rts
}
syscall35: {
    rts
}
syscall34: {
    rts
}
syscall33: {
    rts
}
syscall32: {
    rts
}
syscall31: {
    rts
}
syscall30: {
    rts
}
syscall29: {
    rts
}
syscall28: {
    rts
}
syscall27: {
    rts
}
syscall26: {
    rts
}
syscall25: {
    rts
}
syscall24: {
    rts
}
syscall23: {
    rts
}
syscall22: {
    rts
}
syscall21: {
    rts
}
syscall20: {
    rts
}
syscall19: {
    rts
}
syscall18: {
    rts
}
syscall17: {
    rts
}
syscall16: {
    rts
}
syscall15: {
    rts
}
syscall14: {
    rts
}
syscall13: {
    rts
}
syscall12: {
    rts
}
syscall11: {
    rts
}
syscall10: {
    rts
}
syscall9: {
    rts
}
syscall8: {
    rts
}
syscall7: {
    rts
}
syscall6: {
    rts
}
syscall5: {
    rts
}
syscall4: {
    rts
}
syscall3: {
    rts
}
syscall2: {
    lda #'('
    sta SCREEN+$4e
    rts
}
syscall1: {
    lda #')'
    sta SCREEN+$4f
    rts
}
.segment Data
  MASSAGE: .text "checkpoint2.2 by bada0026"
  .byte 0
.segment Syscall
SYSCALLS:
  .byte JMP
  .word syscall1
  .byte NOP
  .byte JMP
  .word syscall2
  .byte NOP
  .byte JMP
  .word syscall3
  .byte NOP
  .byte JMP
  .word syscall4
  .byte NOP
  .byte JMP
  .word syscall5
  .byte NOP
  .byte JMP
  .word syscall6
  .byte NOP
  .byte JMP
  .word syscall7
  .byte NOP
  .byte JMP
  .word syscall8
  .byte NOP
  .byte JMP
  .word syscall9
  .byte NOP
  .byte JMP
  .word syscall10
  .byte NOP
  .byte JMP
  .word syscall11
  .byte NOP
  .byte JMP
  .word syscall12
  .byte NOP
  .byte JMP
  .word syscall13
  .byte NOP
  .byte JMP
  .word syscall14
  .byte NOP
  .byte JMP
  .word syscall15
  .byte NOP
  .byte JMP
  .word syscall16
  .byte NOP
  .byte JMP
  .word syscall17
  .byte NOP
  .byte JMP
  .word syscall18
  .byte NOP
  .byte JMP
  .word syscall19
  .byte NOP
  .byte JMP
  .word syscall20
  .byte NOP
  .byte JMP
  .word syscall21
  .byte NOP
  .byte JMP
  .word syscall22
  .byte NOP
  .byte JMP
  .word syscall23
  .byte NOP
  .byte JMP
  .word syscall24
  .byte NOP
  .byte JMP
  .word syscall25
  .byte NOP
  .byte JMP
  .word syscall26
  .byte NOP
  .byte JMP
  .word syscall27
  .byte NOP
  .byte JMP
  .word syscall28
  .byte NOP
  .byte JMP
  .word syscall29
  .byte NOP
  .byte JMP
  .word syscall30
  .byte NOP
  .byte JMP
  .word syscall31
  .byte NOP
  .byte JMP
  .word syscall32
  .byte NOP
  .byte JMP
  .word syscall33
  .byte NOP
  .byte JMP
  .word syscall34
  .byte NOP
  .byte JMP
  .word syscall35
  .byte NOP
  .byte JMP
  .word syscall36
  .byte NOP
  .byte JMP
  .word syscall37
  .byte NOP
  .byte JMP
  .word syscall38
  .byte NOP
  .byte JMP
  .word syscall39
  .byte NOP
  .byte JMP
  .word syscall40
  .byte NOP
  .byte JMP
  .word syscall41
  .byte NOP
  .byte JMP
  .word syscall42
  .byte NOP
  .byte JMP
  .word syscall43
  .byte NOP
  .byte JMP
  .word syscall44
  .byte NOP
  .byte JMP
  .word syscall45
  .byte NOP
  .byte JMP
  .word syscall46
  .byte NOP
  .byte JMP
  .word syscall47
  .byte NOP
  .byte JMP
  .word syscall48
  .byte NOP
  .byte JMP
  .word syscall49
  .byte NOP
  .byte JMP
  .word syscall50
  .byte NOP
  .byte JMP
  .word syscall51
  .byte NOP
  .byte JMP
  .word syscall52
  .byte NOP
  .byte JMP
  .word syscall53
  .byte NOP
  .byte JMP
  .word syscall54
  .byte NOP
  .byte JMP
  .word syscall55
  .byte NOP
  .byte JMP
  .word syscall56
  .byte NOP
  .byte JMP
  .word syscall57
  .byte NOP
  .byte JMP
  .word syscall58
  .byte NOP
  .byte JMP
  .word syscall59
  .byte NOP
  .byte JMP
  .word syscall60
  .byte NOP
  .byte JMP
  .word syscall61
  .byte NOP
  .byte JMP
  .word syscall62
  .byte NOP
  .byte JMP
  .word syscall63
  .byte NOP
  .byte JMP
  .word syscall64
  .byte NOP
  .align $100
SYSCALL_TRAPS:
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
  .byte JMP
  .word main
  .byte NOP
