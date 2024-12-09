 
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %00000001
RW = %00000010
RS = %00000100
CLS = %00000001

ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

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

  lda #$00
  sta ACIA_STATUS ; soft reset for ACIA

  lda #%00011111   ; 8-N-1 19200 Baud
  sta ACIA_CTRL

  lda #%00001011   ; no parity, echo, or interrupts
  sta ACIA_CMD
;   ldx #0

; print_serial:
;   lda message, x
;   beq done
;   jsr send_char
;   inx
;   jmp print_serial
; done:

rx_wait:
  lda ACIA_STATUS
  and #$08
  beq rx_wait

  lda ACIA_DATA
  jsr send_char
  jsr print_char
  jmp rx_wait


; message: .asciiz "Two way serial baybeee!"


send_char:
  sta ACIA_DATA
  pha 
tx_wait:
  lda ACIA_STATUS
  and #$10
  beq tx_wait
  pla 
  rts


; hello:
;   lda message, x
;   beq loop
;   sta PORTB
;   jsr print_char
;   inx
;   jmp hello

; loop:
;   jmp loop



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

