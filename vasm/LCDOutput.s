 
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %00000001
RW = %00000010
RS = %00000100
CLS = %00000001

  .org $8000
 

reset:
  ldx #$ff
  txs  ; reset stack pointer

  ;initalize VIA

  lda #%11111111
  sta DDRB
  
  lda #%00000111
  sta DDRA

  ;initalize lcd

  lda #%00111000
  sta PORTB
  
  jsr lcd_init
 
  lda #%00001111
  sta PORTB
  
  jsr lcd_init

  lda #%00000110
  sta PORTB

  jsr lcd_init

  lda #CLS ; clear screen
  sta PORTB

  jsr lcd_init

  ldx #0 
  ldy #0

rx_wait:
  bit PORTA
  bvs rx_wait

  jsr half_bit_delay

  ldx #8
read_bit:
  jsr bit_delay
  bit PORTA
  bvs recv_1
  clc
  jmp rx_done
recv_1:
  sec 
rx_done:
  ror 
  dex
  bne read_bit
  iny
  cmp #$08
  beq clear_screen

  jsr print_char

rx_done_1:
  jsr bit_delay
  jmp rx_wait

bit_delay:
  phx 
  ldx #13

bit_delay_1:
  dex
  bne bit_delay_1
  plx 
  rts

half_bit_delay:
  phx 
  ldx #6
half_bit_delay_1:
  dex 
  bne half_bit_delay_1
  plx 
  rts


clear_screen:
  lda #CLS
  sta PORTB
  jsr lcd_init
  jmp rx_done_1


; hello:
;   lda message, x
;   beq loop
;   sta PORTB
;   jsr print_char
;   inx
;   jmp hello

; loop:
;   jmp loop


message: .asciiz "Ouagadougou"

 print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts

lcd_init:
  jsr lcd_wait
  lda #0
  sta PORTA

  lda #E
  sta PORTA

  lda #0 
  sta PORTA 
  
  rts

lcd_wait:
  pha 
  lda #%0000000 
  sta DDRB 

lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcd_busy
  
  lda #RW 
  sta PORTA
  lda #%11111111
  sta DDRB 
  pla 
  rts

; lcd:
;   jsr lcd_wait
;   sta PORTB
;   lda #RS
;   sta PORTA

;   lda #(RS | E)
;   sta PORTA

;   lda #RS 
;   sta PORTA 
  
;   rts
  .org $fffc
  .word reset
  .word $0000

