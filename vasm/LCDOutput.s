 
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000
CLS = %00000001

  .org $8000
 

reset:
  ldx #$ff
  txs  ; reset stack pointer

  ;initalize VIA

  lda #%11111111
  sta DDRB
  
  lda #%11100000
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


rx_wait:
  lda PORTA
  and #%00000010  ; and it with bit one, setting overflow*
  beq bit_delay_tag 
  jmp rx_wait  

bit_delay_tag:
  jsr half_bit_delay

continue:
  jsr bit_delay
  lda PORTA
  and #%00000010
  beq recv_0
  sec
  jmp rx_done

recv_0:
  clc
rx_done:
  ror   ;rotate bits into A from carry
  dex
  bne continue
  ; all 8 bits are in A 
  jsr print_char
  jsr bit_delay
  jmp rx_wait

bit_delay:
  phx
  ldx #17

bit_delay_1:
  dex 
  bne bit_delay_1

  plx
  rts

half_bit_delay:
  phx
  ldx #9

half_bit_delay_1:
  dex 
  bne bit_delay_1

  plx
  rts

; read_bit:

;   ldx #8
;   bne read_bit
;   jmp rx_wait

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

