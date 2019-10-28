// XMega65 Kernal Development Template
// Each function of the kernal is a no-args function
// The functions are placed in the SYSCALLS table surrounded by JMP and NOP
  .file [name="os6.1.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE = 1
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE = $c
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS = 4
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS = 8
  .const OFFSET_STRUCT_IPC_MESSAGE_TO = 1
  .const OFFSET_STRUCT_IPC_MESSAGE_PRIORITY = 2
  .const OFFSET_STRUCT_IPC_MESSAGE_SEQUENCE = 3
  .const OFFSET_STRUCT_IPC_MESSAGE_MESSAGE = 4
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  .const STATE_NEW = 1
  .const STATE_READY = 2
  .const STATE_READYSUSPENDED = 3
  .const STATE_BLOCKEDSUSPENDED = 4
  .const STATE_BLOCKED = 5
  .const STATE_RUNNING = 6
  .const STATE_EXIT = 7
  .const STATE_NOTRUNNING = 0
  // Process stored state will live at $C000-$C7FF, with 256 bytes
  // for each process reserved
  .label stored_pdbs = $c000
  // 8 processes x 16 bytes = 128 bytes for names
  .label process_names = $c800
  // 8 processes x 64 bytes context state = 512 bytes
  .label process_context_states = $c900
  // We will have 16 slots of 16 bytes at $CB00-$CBFF
  .label ipc_messages = $cb00
  .const JMP = $4c
  .const NOP = $ea
  .label running_pdb = $29
  .label pid_counter = $2a
  .label lpeek_value = $2b
  .label current_screen_line = $d
  .label current_screen_x = $f
  .label ipc_message_count = $10
  // Which is the current running process?
  lda #$ff
  sta.z running_pdb
  // Counter for helping determine the next available proccess ID.
  lda #0
  sta.z pid_counter
  lda #$12
  sta.z lpeek_value
  lda #<SCREEN
  sta.z current_screen_line
  lda #>SCREEN
  sta.z current_screen_line+1
  lda #0
  sta.z current_screen_x
  sta.z ipc_message_count
  jsr main
  rts
.segment Code
main: {
    rts
}
undefined_trap: {
    jsr exit_hypervisor
    rts
}
exit_hypervisor: {
    lda #1
    sta $d67f
    rts
}
PAGFAULT: {
    jsr exit_hypervisor
    rts
}
RESTOREKEY: {
    jsr exit_hypervisor
    rts
}
ALTTABKEY: {
    jsr exit_hypervisor
    rts
}
VF011WR: {
    jsr exit_hypervisor
    rts
}
VF011RD: {
    jsr exit_hypervisor
    rts
}
RESERVED: {
    jsr exit_hypervisor
    rts
}
CPUKIL: {
    jsr exit_hypervisor
    rts
}
RESET: {
    .label sc = $55
    .label msg = $53
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
    lda #<MESSAGE
    sta.z msg
    lda #>MESSAGE
    sta.z msg+1
  __b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne __b2
    jsr print_to_screen
    jsr print_newline
    //Loop forever with 2 bars"
    lda #<SCREEN
    sta.z current_screen_line
    lda #>SCREEN
    sta.z current_screen_line+1
    jsr print_newline
    jsr print_newline
    jsr print_newline
    // Start with empty message queue
    lda #0
    sta.z ipc_message_count
    jsr queue_message
    jsr initialise_pdb
    jsr load_program
    jsr resume_pdb
  __b4:
    lda #$36
    cmp RASTER
    beq __b5
    lda #$42
    cmp RASTER
    beq __b5
    lda #BLACK
    sta BGCOL
    jmp __b4
  __b5:
    lda #WHITE
    sta BGCOL
    jmp __b4
  __b2:
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
    jmp __b1
  .segment Data
    message: .text "cpoint 6.1 "
    .byte 0
    name: .text "program1.prg"
    .byte 0
}
.segment Code
resume_pdb: {
    .const pdb_number = 0
    .label p = stored_pdbs
    .label __7 = $2c
    .label ss = $53
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z dma_copy.src
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z dma_copy.src+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z dma_copy.src+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z dma_copy.src+3
    lda #0
    sta.z dma_copy.dest
    sta.z dma_copy.dest+1
    sta.z dma_copy.dest+2
    sta.z dma_copy.dest+3
    lda #<$400
    sta.z dma_copy.length
    lda #>$400
    sta.z dma_copy.length+1
    jsr dma_copy
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z __7
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z __7+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z __7+2
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z __7+3
    lda.z __7
    clc
    adc #<$800
    sta.z dma_copy.src
    lda.z __7+1
    adc #>$800
    sta.z dma_copy.src+1
    lda.z __7+2
    adc #0
    sta.z dma_copy.src+2
    lda.z __7+3
    adc #0
    sta.z dma_copy.src+3
    lda #<$800
    sta.z dma_copy.dest
    lda #>$800
    sta.z dma_copy.dest+1
    lda #<$800>>$10
    sta.z dma_copy.dest+2
    lda #>$800>>$10
    sta.z dma_copy.dest+3
    lda #<$1800
    sta.z dma_copy.length
    lda #>$1800
    sta.z dma_copy.length+1
    jsr dma_copy
    // Load stored CPU state into Hypervisor saved register area at $FFD3640
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    sta.z ss
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    sta.z ss+1
    ldy #0
  //XXX - Use a for() loop to copy 63 bytes from ss[0]--ss[62] to ((unsigned char *)$D640)[0]
  // -- ((unsigned char *)$D640)[62] (dma_copy doesn't work for this for some slightly
  // complex reasons.)
  __b1:
    cpy #$3f
    bcc __b2
    // Set state of process to running
    //XXX - Set p->process_state to STATE_RUNNING
    lda #STATE_RUNNING
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    // Mark this PDB as the running process
    //XXX - Set running_pdb to the PDB number we are resuming
    lda #pdb_number
    sta.z running_pdb
    lda #0
    jsr describe_pdb
    jsr exit_hypervisor
    rts
  __b2:
    lda (ss),y
    sta $d640,y
    iny
    jmp __b1
}
// describe_pdb(byte register(A) pdb_number)
describe_pdb: {
    .label __1 = $30
    .label __2 = $30
    .label p = $30
    .label n = $30
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    lda (p),y
    cmp #STATE_NEW
    beq __b8
    //print_to_screen("new"); break;
    lda (p),y
    cmp #STATE_RUNNING
    beq __b8
    //print_to_screen("running"); break;
    lda (p),y
    cmp #STATE_BLOCKED
    beq __b8
    // print_to_screen("blocked"); break;
    lda (p),y
    cmp #STATE_READY
    beq __b8
    //print_to_screen("ready"); break;
    lda (p),y
    cmp #STATE_BLOCKEDSUSPENDED
    beq __b8
    //print_to_screen("blockedsuspended"); break;
    lda (p),y
    cmp #STATE_READYSUSPENDED
    beq __b8
    //print_to_screen("readysuspended"); break;
    lda (p),y
    cmp #STATE_EXIT
  __b8:
    //print_to_screen(" process name: ");
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (n),y
    pha
    iny
    lda (n),y
    sta.z n+1
    pla
    sta.z n
    ldy #0
  __b9:
    lda (n),y
    cmp #0
    bne __b10
    rts
  __b10:
    iny
    jmp __b9
}
// dma_copy(dword zeropage(8) src, dword zeropage(4) dest, word zeropage(2) length)
dma_copy: {
    .label __0 = $32
    .label __2 = $36
    .label __4 = $3a
    .label __5 = $3c
    .label __7 = $40
    .label __9 = $44
    .label src = 8
    .label list_request_format0a = $13
    .label list_source_mb_option80 = $14
    .label list_source_mb = $15
    .label list_dest_mb_option81 = $16
    .label list_dest_mb = $17
    .label list_end_of_options00 = $18
    .label list_cmd = $19
    .label list_size = $1a
    .label list_source_addr = $1c
    .label list_source_bank = $1e
    .label list_dest_addr = $1f
    .label list_dest_bank = $21
    .label list_modulo00 = $22
    .label dest = 4
    .label length = 2
    lda #0
    sta.z list_request_format0a
    sta.z list_source_mb_option80
    sta.z list_source_mb
    sta.z list_dest_mb_option81
    sta.z list_dest_mb
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_size
    sta.z list_size+1
    sta.z list_source_addr
    sta.z list_source_addr+1
    sta.z list_source_bank
    sta.z list_dest_addr
    sta.z list_dest_addr+1
    sta.z list_dest_bank
    sta.z list_modulo00
    lda #$a
    sta.z list_request_format0a
    lda #$80
    sta.z list_source_mb_option80
    lda #$81
    sta.z list_dest_mb_option81
    lda #0
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_modulo00
    lda.z length
    sta.z list_size
    lda.z length+1
    sta.z list_size+1
    ldx #$14
    lda.z dest
    sta.z __0
    lda.z dest+1
    sta.z __0+1
    lda.z dest+2
    sta.z __0+2
    lda.z dest+3
    sta.z __0+3
    cpx #0
    beq !e+
  !:
    lsr.z __0+3
    ror.z __0+2
    ror.z __0+1
    ror.z __0
    dex
    bne !-
  !e:
    lda.z __0
    sta.z list_dest_mb
    lda #0
    sta.z __2+2
    sta.z __2+3
    lda.z dest+3
    sta.z __2+1
    lda.z dest+2
    sta.z __2
    lda #$7f
    and.z __2
    sta.z list_dest_bank
    lda.z dest
    sta.z __4
    lda.z dest+1
    sta.z __4+1
    lda.z __4
    sta.z list_dest_addr
    lda.z __4+1
    sta.z list_dest_addr+1
    ldx #$14
    lda.z src
    sta.z __5
    lda.z src+1
    sta.z __5+1
    lda.z src+2
    sta.z __5+2
    lda.z src+3
    sta.z __5+3
    cpx #0
    beq !e+
  !:
    lsr.z __5+3
    ror.z __5+2
    ror.z __5+1
    ror.z __5
    dex
    bne !-
  !e:
    lda.z __5
    // Work around missing fragments in KickC
    sta.z list_source_mb
    lda #0
    sta.z __7+2
    sta.z __7+3
    lda.z src+3
    sta.z __7+1
    lda.z src+2
    sta.z __7
    lda #$7f
    and.z __7
    sta.z list_source_bank
    lda.z src
    sta.z __9
    lda.z src+1
    sta.z __9+1
    lda.z __9
    sta.z list_source_addr
    lda.z __9+1
    sta.z list_source_addr+1
    // DMA list lives in hypervisor memory, so use correct list address
    // when triggering
    // (Variables in KickC usually end up in ZP, so we have to provide the
    // base page correction
    lda #0
    cmp #>list_request_format0a
    beq __b1
    lda #>list_request_format0a
    sta $d701
  __b2:
    lda #$7f
    sta $d702
    lda #$ff
    sta $d704
    lda #<list_request_format0a
    sta $d705
    rts
  __b1:
    lda #$bf+(>list_request_format0a)
    sta $d701
    jmp __b2
}
load_program: {
    .label pdb = stored_pdbs
    .label __30 = $4e
    .label __31 = $4e
    .label __34 = $2c
    .label __35 = $2c
    .label n = $55
    .label c2 = $52
    .label new_address = $4a
    .label address = $2c
    .label length = $27
    .label dest = $46
    .label match = $c
    lda #0
    sta.z match
    lda #<$20000
    sta.z address
    lda #>$20000
    sta.z address+1
    lda #<$20000>>$10
    sta.z address+2
    lda #>$20000>>$10
    sta.z address+3
  __b1:
    lda.z address
    sta.z lpeek.address
    lda.z address+1
    sta.z lpeek.address+1
    lda.z address+2
    sta.z lpeek.address+2
    lda.z address+3
    sta.z lpeek.address+3
    jsr lpeek
    txa
    cmp #0
    bne b1
    rts
  // Check for name match
  b1:
    ldy #0
  __b2:
    cpy #$10
    bcs !__b3+
    jmp __b3
  !__b3:
    jmp __b5
  b3:
    lda #1
    sta.z match
  __b5:
    lda #0
    cmp.z match
    bne !__b8+
    jmp __b8
  !__b8:
    // Found program -- now copy it into place
    sta.z length
    sta.z length+1
    lda #$10
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z length
    lda #0
    sta.z length+1
    lda #$11
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    stx length+1
    // Copy program into place.
    // As the program is formatted as a C64 program with a 
    // $0801 header, we copy it to offset $07FF.
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta.z dest
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    sta.z dest+1
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    sta.z dest+2
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    sta.z dest+3
    lda.z dest
    clc
    adc #<$7ff
    sta.z dest
    lda.z dest+1
    adc #>$7ff
    sta.z dest+1
    lda.z dest+2
    adc #0
    sta.z dest+2
    lda.z dest+3
    adc #0
    sta.z dest+3
    lda #$20
    clc
    adc.z address
    sta.z dma_copy.src
    lda.z address+1
    adc #0
    sta.z dma_copy.src+1
    lda.z address+2
    adc #0
    sta.z dma_copy.src+2
    lda.z address+3
    adc #0
    sta.z dma_copy.src+3
    lda.z dest
    sta.z dma_copy.dest
    lda.z dest+1
    sta.z dma_copy.dest+1
    lda.z dest+2
    sta.z dma_copy.dest+2
    lda.z dest+3
    sta.z dma_copy.dest+3
    lda.z length
    sta.z dma_copy.length
    txa
    sta.z dma_copy.length+1
    jsr dma_copy
    // Mark process as now runnable
    lda #STATE_READY
    sta pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    rts
  __b8:
    lda #$12
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z new_address
    lda #0
    sta.z new_address+1
    sta.z new_address+2
    sta.z new_address+3
    lda #$13
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __30
    lda #0
    sta.z __30+1
    sta.z __30+2
    sta.z __30+3
    lda.z __31+2
    sta.z __31+3
    lda.z __31+1
    sta.z __31+2
    lda.z __31
    sta.z __31+1
    lda #0
    sta.z __31
    ora.z new_address
    sta.z new_address
    lda.z __31+1
    ora.z new_address+1
    sta.z new_address+1
    lda.z __31+2
    ora.z new_address+2
    sta.z new_address+2
    lda.z __31+3
    ora.z new_address+3
    sta.z new_address+3
    lda #$14
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __34
    lda #0
    sta.z __34+1
    sta.z __34+2
    sta.z __34+3
    lda.z __35+1
    sta.z __35+3
    lda.z __35
    sta.z __35+2
    lda #0
    sta.z __35
    sta.z __35+1
    lda.z new_address
    ora.z address
    sta.z address
    lda.z new_address+1
    ora.z address+1
    sta.z address+1
    lda.z new_address+2
    ora.z address+2
    sta.z address+2
    lda.z new_address+3
    ora.z address+3
    sta.z address+3
    jmp __b1
  __b3:
    tya
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta.z n
    lda pdb+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    sta.z n+1
    lda (n),y
    sta.z c2
    cpx #0
    bne __b4
    cmp #0
    bne !b3+
    jmp b3
  !b3:
  __b4:
    cpx.z c2
    beq __b6
    jmp __b5
  __b6:
    iny
    jmp __b2
}
// lpeek(dword zeropage($46) address)
lpeek: {
    .label t = $23
    .label address = $46
    // Work around all sorts of fun problems in KickC
    // dma_copy(address,$BF00+((unsigned short)<&lpeek_value),1); 
    lda #<lpeek_value
    sta.z t
    lda #>lpeek_value
    sta.z t+1
    lda #<lpeek_value>>$10
    sta.z t+2
    lda #>lpeek_value>>$10
    sta.z t+3
    lda #0
    cmp #>lpeek_value
    bne __b1
    lda.z t
    clc
    adc #<$fffbf00
    sta.z t
    lda.z t+1
    adc #>$fffbf00
    sta.z t+1
    lda.z t+2
    adc #<$fffbf00>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fffbf00>>$10
    sta.z t+3
  __b2:
    lda.z address
    sta.z dma_copy.src
    lda.z address+1
    sta.z dma_copy.src+1
    lda.z address+2
    sta.z dma_copy.src+2
    lda.z address+3
    sta.z dma_copy.src+3
    lda.z t
    sta.z dma_copy.dest
    lda.z t+1
    sta.z dma_copy.dest+1
    lda.z t+2
    sta.z dma_copy.dest+2
    lda.z t+3
    sta.z dma_copy.dest+3
    lda #<1
    sta.z dma_copy.length
    lda #>1
    sta.z dma_copy.length+1
    jsr dma_copy
    ldx.z lpeek_value
    rts
  __b1:
    lda.z t
    clc
    adc #<$fff0000
    sta.z t
    lda.z t+1
    adc #>$fff0000
    sta.z t+1
    lda.z t+2
    adc #<$fff0000>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fff0000>>$10
    sta.z t+3
    jmp __b2
}
// Setup a new process descriptor block
initialise_pdb: {
    .label p = stored_pdbs
    .label pid_counter = $12
    .label pn = $55
    .label ss = $53
    //Setup process ID
    //XXX - Call the function next_free_pid() to get a process ID for the
    //process in this PDB, and store it in p->process_id
    lda #0
    sta.z pid_counter
    jsr next_free_pid
    lda.z next_free_pid.pid
    sta p
    // Setup process name 
    // (32 bytes space for each to fit 16 chars + nul)
    // (we could just use 17 bytes, but kickc can't multiply by 17)
    lda #<process_names
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda #>process_names
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    //XXX - copy the string in the array 'name' into the array 'p->process_name'
    //XXX - To make your life easier, do something like char *pn=p->process_name
    // Then you can just do something along the lines of pn[...]=name[...] 
    // in a loop to copy the name into place.
    // (The arrays are both 17 bytes long)
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta.z pn
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME+1
    sta.z pn+1
    ldy #0
  __b1:
    cpy #$11
    bcc __b2
    // Set process state as not running.
    //XXX - Put the value STATE_NOTRUNNING into p->process_state
    lda #STATE_NOTRUNNING
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    // Set stored memory area
    // (for now, we just use fixed 8KB steps from $30000-$3FFFF
    // corresponding to the PDB number
    //XXX - Set p->storage_start_address to the correct start address
    //for a process that is in this PDB.
    //The correct address is $30000 + (((unsigned dword)pdb_number)*$2000);
    lda #<$30000
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda #>$30000
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+1
    lda #<$30000>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+2
    lda #>$30000>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS+3
    //XXX - Then do the same for the end address of the process
    //This gets stored into p->process_end_address and the correct
    //address is $31FFF + (((unsigned dword)pdb_number)*$2000);
    lda #<$31fff
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    lda #>$31fff
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+1
    lda #<$31fff>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+2
    lda #>$31fff>>$10
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS+3
    // 64 bytes context switching state for each process
    lda #<process_context_states
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda #>process_context_states
    sta p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    sta.z ss
    lda p+OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE+1
    sta.z ss+1
    ldy #0
  //XXX - Set all 64 bytes of the array 'ss' to zero, to clear the context
  //switching state
  __b4:
    cpy #$3f
    bcc __b5
    // Set tandard CPU flags (8-bit stack, interrupts disabled)
    lda #$24
    ldy #7
    sta (ss),y
    //XXX - Set the stack pointer to $01FF
    //(This requires a bit of fiddly pointer arithmetic, so to save you 
    //the trouble working it out, you can use the following as the left 
    //side of the expression: *(unsigned short *)&ss[x] = ...
    //where x is the offset of the stack pointer low byte (SPL) in the
    //Hypervisor saved state registers in Appendix D of the MEGA65 User's
    //Guide. i.e., if it were at $D640, x would be replaced with 0, and
    //if it were at $D641, x would be replaced with 1, and so on.
    //XXX - Note that the MEGA65 User's Guide has been updated on FLO.
    //You will required the latest version, as otherwise SPL is not listed.
    ldy #8
    lda #<$80d
    sta (ss),y
    iny
    lda #>$80d
    sta (ss),y
    ldy #5
    lda #<$1ff
    sta (ss),y
    iny
    lda #>$1ff
    sta (ss),y
    rts
  __b5:
    lda #0
    sta (ss),y
    iny
    jmp __b4
  __b2:
    lda RESET.name,y
    sta (pn),y
    iny
    jmp __b1
}
next_free_pid: {
    .label __2 = $55
    .label pid = $c
    .label p = $55
    .label i = $53
    inc.z pid_counter
    // Start with the next process ID
    lda.z pid_counter
    sta.z pid
    ldx #1
  __b1:
    cpx #0
    bne b1
    rts
  b1:
    ldx #0
    txa
    sta.z i
    sta.z i+1
  __b2:
    lda.z i+1
    cmp #>8
    bcc __b3
    bne !+
    lda.z i
    cmp #<8
    bcc __b3
  !:
    jmp __b1
  __b3:
    lda.z i
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #0
    lda (p),y
    cmp.z pid
    bne __b4
    inc.z pid
    ldx #1
  __b4:
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b2
}
queue_message: {
    .const from = 0
    .const to = 1
    .const priority = 1
    .const sequence = 1
    .label __10 = $55
    .label m = $53
    lda.z ipc_message_count
    cmp #$f+1
    bcc __b1
    rts
  __b1:
    lda.z ipc_message_count
    asl
    asl
    asl
    asl
    clc
    adc #<ipc_messages
    sta.z m
    lda #>ipc_messages
    adc #0
    sta.z m+1
    lda #from
    ldy #0
    sta (m),y
    lda #to
    ldy #OFFSET_STRUCT_IPC_MESSAGE_TO
    sta (m),y
    lda #priority
    ldy #OFFSET_STRUCT_IPC_MESSAGE_PRIORITY
    sta (m),y
    lda #sequence
    ldy #OFFSET_STRUCT_IPC_MESSAGE_SEQUENCE
    sta (m),y
    ldy #0
  __b2:
    cpy #$c
    bcc __b3
    lda #1
    sta.z ipc_message_count
    rts
  __b3:
    lda #OFFSET_STRUCT_IPC_MESSAGE_MESSAGE
    clc
    adc.z m
    sta.z __10
    lda #0
    adc.z m+1
    sta.z __10+1
    lda RESET.message,y
    sta (__10),y
    iny
    jmp __b2
}
print_newline: {
    lda #$28
    clc
    adc.z current_screen_line
    sta.z current_screen_line
    bcc !+
    inc.z current_screen_line+1
  !:
    lda #0
    sta.z current_screen_x
    rts
}
print_to_screen: {
    .label c = $55
    lda #<MESSAGE
    sta.z c
    lda #>MESSAGE
    sta.z c+1
  __b1:
    ldy #0
    lda (c),y
    cmp #0
    bne __b2
    rts
  __b2:
    ldy #0
    lda (c),y
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    inc.z c
    bne !+
    inc.z c+1
  !:
    jmp __b1
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage($55) str, byte register(X) c, word zeropage($53) num)
memset: {
    .label end = $53
    .label dst = $55
    .label num = $53
    .label str = $55
    lda.z num
    bne !+
    lda.z num+1
    beq __breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  __b2:
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
  __breturn:
    rts
  __b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
}
syscall64: {
    jsr exit_hypervisor
    rts
}
syscall63: {
    jsr exit_hypervisor
    rts
}
syscall62: {
    jsr exit_hypervisor
    rts
}
syscall61: {
    jsr exit_hypervisor
    rts
}
syscall60: {
    jsr exit_hypervisor
    rts
}
syscall59: {
    jsr exit_hypervisor
    rts
}
syscall58: {
    jsr exit_hypervisor
    rts
}
syscall57: {
    jsr exit_hypervisor
    rts
}
syscall56: {
    jsr exit_hypervisor
    rts
}
syscall55: {
    jsr exit_hypervisor
    rts
}
syscall54: {
    jsr exit_hypervisor
    rts
}
syscall53: {
    jsr exit_hypervisor
    rts
}
syscall52: {
    jsr exit_hypervisor
    rts
}
syscall51: {
    jsr exit_hypervisor
    rts
}
syscall50: {
    jsr exit_hypervisor
    rts
}
syscall49: {
    jsr exit_hypervisor
    rts
}
syscall48: {
    jsr exit_hypervisor
    rts
}
syscall47: {
    jsr exit_hypervisor
    rts
}
syscall46: {
    jsr exit_hypervisor
    rts
}
syscall45: {
    jsr exit_hypervisor
    rts
}
syscall44: {
    jsr exit_hypervisor
    rts
}
syscall43: {
    jsr exit_hypervisor
    rts
}
syscall42: {
    jsr exit_hypervisor
    rts
}
syscall41: {
    jsr exit_hypervisor
    rts
}
syscall40: {
    jsr exit_hypervisor
    rts
}
syscall39: {
    jsr exit_hypervisor
    rts
}
syscall38: {
    jsr exit_hypervisor
    rts
}
syscall37: {
    jsr exit_hypervisor
    rts
}
syscall36: {
    jsr exit_hypervisor
    rts
}
syscall35: {
    jsr exit_hypervisor
    rts
}
syscall34: {
    jsr exit_hypervisor
    rts
}
syscall33: {
    jsr exit_hypervisor
    rts
}
syscall32: {
    jsr exit_hypervisor
    rts
}
syscall31: {
    jsr exit_hypervisor
    rts
}
syscall30: {
    jsr exit_hypervisor
    rts
}
syscall29: {
    jsr exit_hypervisor
    rts
}
syscall28: {
    jsr exit_hypervisor
    rts
}
syscall27: {
    jsr exit_hypervisor
    rts
}
syscall26: {
    jsr exit_hypervisor
    rts
}
syscall25: {
    jsr exit_hypervisor
    rts
}
syscall24: {
    jsr exit_hypervisor
    rts
}
syscall23: {
    jsr exit_hypervisor
    rts
}
syscall22: {
    jsr exit_hypervisor
    rts
}
syscall21: {
    jsr exit_hypervisor
    rts
}
syscall20: {
    jsr exit_hypervisor
    rts
}
syscall19: {
    jsr exit_hypervisor
    rts
}
syscall18: {
    jsr exit_hypervisor
    rts
}
syscall17: {
    jsr exit_hypervisor
    rts
}
syscall16: {
    jsr exit_hypervisor
    rts
}
syscall15: {
    jsr exit_hypervisor
    rts
}
syscall14: {
    jsr exit_hypervisor
    rts
}
syscall13: {
    jsr exit_hypervisor
    rts
}
syscall12: {
    jsr exit_hypervisor
    rts
}
syscall11: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall09: {
    .label __1 = $58
    .label __2 = $58
    .label __9 = $5a
    .label pdb = $58
    .label m = $5c
    lda.z running_pdb
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    ldy #0
    lda (pdb),y
    sta.z get_next_message_id.receiver
    jsr get_next_message_id
    lda.z get_next_message_id.best_message
    tay
    cpy #$ff
    bne __b1
    ldx #0
  // We have no message to return
  // So set message to all $FFs
  __b2:
    cpx #$10
    bcc __b3
    jsr exit_hypervisor
    rts
  __b3:
    txa
    clc
    adc #<$300
    sta.z __9
    lda #>$300
    adc #0
    sta.z __9+1
    lda #$ff
    ldy #0
    sta (__9),y
    inx
    jmp __b2
  __b1:
    tya
    jsr get_pointer_to_message
    lda.z m
    sta.z dma_copy.src
    lda.z m+1
    sta.z dma_copy.src+1
    lda #0
    sta.z dma_copy.src+2
    sta.z dma_copy.src+3
    lda #<$300
    sta.z dma_copy.dest
    lda #>$300
    sta.z dma_copy.dest+1
    lda #<$300>>$10
    sta.z dma_copy.dest+2
    lda #>$300>>$10
    sta.z dma_copy.dest+3
    lda #<$10
    sta.z dma_copy.length
    lda #>$10
    sta.z dma_copy.length+1
    jsr dma_copy
    jsr dequeue_message
    jsr exit_hypervisor
    rts
}
// dequeue_message(byte register(Y) message_num)
dequeue_message: {
    .label dest = $58
    .label src = $5a
    cpy.z ipc_message_count
    bcc __b1
    rts
  __b1:
    ldx.z ipc_message_count
    dex
    stx.z $ff
    cpy.z $ff
    bne __b2
    dec.z ipc_message_count
    rts
  __b2:
    tya
    asl
    asl
    asl
    asl
    clc
    adc #<ipc_messages
    sta.z dest
    lda #>ipc_messages
    adc #0
    sta.z dest+1
    lda.z ipc_message_count
    sec
    sbc #1
    asl
    asl
    asl
    asl
    clc
    adc #<ipc_messages
    sta.z src
    lda #>ipc_messages
    adc #0
    sta.z src+1
    ldx #0
  __b4:
    cpx #$10
    bcc __b5
    dec.z ipc_message_count
    rts
  __b5:
    stx.z $ff
    txa
    tay
    lda (src),y
    sta (dest),y
    inx
    jmp __b4
}
// get_pointer_to_message(byte register(A) id)
get_pointer_to_message: {
    .label return = $5c
    asl
    asl
    asl
    asl
    clc
    adc #<ipc_messages
    sta.z return
    lda #>ipc_messages
    adc #0
    sta.z return+1
    rts
}
// get_next_message_id(byte zeropage($57) receiver)
get_next_message_id: {
    .label m = $5c
    .label receiver = $57
    .label best_message = $11
    lda #$ff
    sta.z best_message
    ldx #0
  __b1:
    cpx #$10
    bcc __b2
    rts
  __b2:
    txa
    asl
    asl
    asl
    asl
    clc
    adc #<ipc_messages
    sta.z m
    lda #>ipc_messages
    adc #0
    sta.z m+1
    ldy #OFFSET_STRUCT_IPC_MESSAGE_TO
    lda (m),y
    cmp.z receiver
    bne __b3
    lda #$ff
    cmp.z best_message
    bne __b3
    stx.z best_message
  __b3:
    inx
    jmp __b1
}
syscall08: {
    jsr exit_hypervisor
    rts
}
syscall07: {
    jsr exit_hypervisor
    rts
}
syscall06: {
    jsr exit_hypervisor
    rts
}
syscall05: {
    jsr exit_hypervisor
    rts
}
syscall04: {
    lda.z running_pdb
    jsr describe_pdb
    jsr exit_hypervisor
    rts
}
syscall03: {
    jsr exit_hypervisor
    rts
}
syscall02: {
    lda #'<'
    sta SCREEN+$4e
    jsr exit_hypervisor
    rts
}
//XXX - Copy your trap handler functions and entry point tables from os5.2.kc
syscall01: {
    lda #'>'
    sta SCREEN+$4f
    jsr exit_hypervisor
    rts
}
.segment Data
  MESSAGE: .text "cpoint 6.1"
  .byte 0
.segment Syscall
  SYSCALLS: .byte JMP
  .word syscall01
  .byte NOP, JMP
  .word syscall02
  .byte NOP, JMP
  .word syscall03
  .byte NOP, JMP
  .word syscall04
  .byte NOP, JMP
  .word syscall05
  .byte NOP, JMP
  .word syscall06
  .byte NOP, JMP
  .word syscall07
  .byte NOP, JMP
  .word syscall08
  .byte NOP, JMP
  .word syscall09
  .byte NOP, JMP
  .word syscall10
  .byte NOP, JMP
  .word syscall11
  .byte NOP, JMP
  .word syscall12
  .byte NOP, JMP
  .word syscall13
  .byte NOP, JMP
  .word syscall14
  .byte NOP, JMP
  .word syscall15
  .byte NOP, JMP
  .word syscall16
  .byte NOP, JMP
  .word syscall17
  .byte NOP, JMP
  .word syscall18
  .byte NOP, JMP
  .word syscall19
  .byte NOP, JMP
  .word syscall20
  .byte NOP, JMP
  .word syscall21
  .byte NOP, JMP
  .word syscall22
  .byte NOP, JMP
  .word syscall23
  .byte NOP, JMP
  .word syscall24
  .byte NOP, JMP
  .word syscall25
  .byte NOP, JMP
  .word syscall26
  .byte NOP, JMP
  .word syscall27
  .byte NOP, JMP
  .word syscall28
  .byte NOP, JMP
  .word syscall29
  .byte NOP, JMP
  .word syscall30
  .byte NOP, JMP
  .word syscall31
  .byte NOP, JMP
  .word syscall32
  .byte NOP, JMP
  .word syscall33
  .byte NOP, JMP
  .word syscall34
  .byte NOP, JMP
  .word syscall35
  .byte NOP, JMP
  .word syscall36
  .byte NOP, JMP
  .word syscall37
  .byte NOP, JMP
  .word syscall38
  .byte NOP, JMP
  .word syscall39
  .byte NOP, JMP
  .word syscall40
  .byte NOP, JMP
  .word syscall41
  .byte NOP, JMP
  .word syscall42
  .byte NOP, JMP
  .word syscall43
  .byte NOP, JMP
  .word syscall44
  .byte NOP, JMP
  .word syscall45
  .byte NOP, JMP
  .word syscall46
  .byte NOP, JMP
  .word syscall47
  .byte NOP, JMP
  .word syscall48
  .byte NOP, JMP
  .word syscall49
  .byte NOP, JMP
  .word syscall50
  .byte NOP, JMP
  .word syscall51
  .byte NOP, JMP
  .word syscall52
  .byte NOP, JMP
  .word syscall53
  .byte NOP, JMP
  .word syscall54
  .byte NOP, JMP
  .word syscall55
  .byte NOP, JMP
  .word syscall56
  .byte NOP, JMP
  .word syscall57
  .byte NOP, JMP
  .word syscall58
  .byte NOP, JMP
  .word syscall59
  .byte NOP, JMP
  .word syscall60
  .byte NOP, JMP
  .word syscall61
  .byte NOP, JMP
  .word syscall62
  .byte NOP, JMP
  .word syscall63
  .byte NOP, JMP
  .word syscall64
  .byte NOP
  .align $100
  SYSCALL_TRAPS: .byte JMP
  .word RESET
  .byte NOP, JMP
  .word RESERVED
  .byte NOP, JMP
  .word VF011RD
  .byte NOP, JMP
  .word VF011WR
  .byte NOP, JMP
  .word ALTTABKEY
  .byte NOP, JMP
  .word RESTOREKEY
  .byte NOP, JMP
  .word PAGFAULT
  .byte NOP, JMP
  .word CPUKIL
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP, JMP
  .word undefined_trap
  .byte NOP
