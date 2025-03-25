; bit_banging_digit_display.asm
; program to do SPI input to MAX7219 LED chip with software bit-banging on KIM-1
; MOS6502 assembly

.cpu 6502
.equ outputKIM, 0x1700 ; variable for address of SPI pins, bit 7 is MOSI, bit 6 is SS, bit 5 is SCLK
.equ outputSettings, 0x1701 ; variable for address of output settings, where we can set pins to inputs or outputs

.equ output, 0x1000 ; variable for address of output (for byte_send)

.equ byte1, 0x1001 ; variable for address of first byte sent (for spi_send)
.equ byte2, 0x1002 ; variable for address of second byte sent (for spi_send)

.org 0x0000
; 8 bytes of data to send to digits, MSB to LSB (for display_send), default is HELLO
data: .byte 0x0F, 0x0F, 0x0F, 0x0C, 0x0B, 0x0D, 0x0D, 0x00

.org 0x0200 ; start main at $0200

main:

    ; setup
    JSR setup

    ; initialize LED chip
    JSR initialize
    
    ; send all data from registers 0x2000-0x20FF to display in 2 second intervals,
    ; 8 bytes per display, loops indefinitely unless JMP is commented out
    LDY #0x00
    
    send:
    
        LDA data_input,Y
        STA data
        INY
        LDA data_input,Y
        STA data+1
        INY
        LDA data_input,Y
        STA data+2
        INY
        LDA data_input,Y
        STA data+3
        INY
        LDA data_input,Y
        STA data+4
        INY
        LDA data_input,Y
        STA data+5
        INY
        LDA data_input,Y
        STA data+6
        INY
        LDA data_input,Y
        STA data+7
        INY
        
        JSR display_send
        
        JSR delay
        JSR delay
        JSR delay
        JSR delay
        
        CPY limit
        
        BPL send
    
    JMP main
    
    BRK ; break

byte_send: ; subroutine to send 8 bits

    set_clk_low: ; set the clock low before getting data in pin 7
        LDA outputKIM
        AND #0b11011111   ; Pull CLK (bit 5) low
        STA outputKIM
    
    set_counter: ; counter to see how many bits have been sent of byte
        LDX #0x08
        
    send_output: ; send byte of data
        
        ; store output bit in outputKIM bit 7
        LDA output ; load output into accumulator
        AND #0b10000000 ; AND output so only last bit is recognized
        ORA outputKIM ; OR output to what's in 0x1700, nothing is changed except last bit
        STA outputKIM ; store result in KIM output bit
        
        ASL output ; arithmetic shift left of output1 to move next output1 bit to bit 0
    
    clk_cycle: ; simulate a clock cycle that occurs
               ; data has to be stable before clock rising edge
        
        LDA outputKIM ;load outputKIM into memory
        EOR #0b00100000 ; Invert SCLK (bit 5)
        STA outputKIM ; Store into outputKIM
        
        LDA outputKIM ; load outputKIM
        EOR #0b00100000 ; Invert SCLK (bit 5)
        STA outputKIM ; Store into outputKIM
        
        LDA outputKIM ; set final digit of outputKIM to 0 so it is modified correctly on next edge
        AND #0b01111111
        STA outputKIM
        
        DEX ; decrement number of bits remaining to be sent
        
        BNE send_output ; jump to send_output for next bit
        
    RTS ; end subroutine


spi_send: ; subroutine to send 2 bytes for LED
    
    ; set SS pin low
    set_ss_low:
        LDA outputKIM
        AND #0b10111111 ; Pull SS (bit 6) low
        STA outputKIM
    
    ; send address byte
    send_address:
        LDA byte1
        STA output
        JSR byte_send
    
    ; send data byte
    send_data:
        LDA byte2
        STA output
        JSR byte_send
    
    ; set SS pin high
    set_ss_high:
        LDA outputKIM
        ORA #0b01000000 ; Pull SS (bit 6) high
        STA outputKIM
        
    RTS ; end subroutine
    
setup: ; setup subroutine

    clear_decimal_mode:
        CLD
    
    set_initial_output_state: ; set outputKIM to 0x00
        LDA #0x00
        STA outputKIM
    
    make_output: ; make port A an output
        LDA #0xFF
        STA outputSettings
    
    set_low: ; Pull SS and CLK pin to low by AND with outputKIM and storing it back
            LDA outputKIM
            AND #0b11011111  ; Pull CLK (bit 5) low
            AND #0b10111111  ; Pull SS (bit 6) low
            STA outputKIM
            
    RTS

initialize: ; Initialize MAX7219 subroutine

    ; Set Decode Mode to no code B (Address 0x09 -> Data 0x00)
    LDA #0x09
    STA byte1
    LDA #0x00
    STA byte2
    JSR spi_send

    ; Set Intensity (Address 0x0A -> Data 0x0F)
    LDA #0x0A
    STA byte1
    LDA intensity
    STA byte2
    JSR spi_send

    ; Set Scan Limit (Address 0x0B -> Data 0x07)
    LDA #0x0B
    STA byte1
    LDA #0x07
    STA byte2
    JSR spi_send

    ; Turn on display (Address 0x0C -> Data 0x01)
    LDA #0x0C
    STA byte1
    LDA #0x01
    STA byte2
    JSR spi_send

    ; Exit Display Test Mode (Address 0x0F -> Data 0x00)
    LDA #0x0F
    STA byte1
    LDA #0x00
    STA byte2
    JSR spi_send
    
    RTS ; end subroutine

display_send: ; Send data to display digits on 8 parts of display, from MSB to LSB

    ; send bytes to display data[0] on digit 7 (Address 0x08 -> data[0])
    LDA #0x08
    STA byte1
    LDA data
    STA byte2
    
    JSR spi_send
    
    ; display data[1] on digit 6 (Address 0x07 -> data[1])
    LDA #0x07
    STA byte1
    LDA data+1
    STA byte2
    
    JSR spi_send
    
    ; display data[2] on digit 5 (Address 0x06 -> data[2])
    LDA #0x06
    STA byte1
    LDA data+2
    STA byte2
    
    JSR spi_send
    
    ; display data[3] on digit 4 (Address 0x05 -> data[3])
    LDA #0x05
    STA byte1
    LDA data+3
    STA byte2
    
    JSR spi_send
    
    ; display data[4] on digit 3 (Address 0x04 -> data[4])
    LDA #0x04
    STA byte1
    LDA data+4
    STA byte2
    
    JSR spi_send
    
    ; display data[5] on digit 2 (Address 0x03 -> data[5])
    LDA #0x03
    STA byte1
    LDA data+5
    STA byte2
    
    JSR spi_send
    
    ; display data[6] on digit 1 (Address 0x02 -> data[6])
    LDA #0x02
    STA byte1
    LDA data+6
    STA byte2
    
    JSR spi_send
    
    ; display data[7] on digit 0 (Address 0x01 -> data[7])
    LDA #0x01
    STA byte1
    LDA data+7
    STA byte2
    
    JSR spi_send
    
    RTS ; end subroutine
    
delay: ; delay subroutine

    LDX #0xFF ; Load X with outer loop count (e.g., 255)
    outer_loop:
    
            LDA #0xFF
            inner_loop:
                SBC #0x01
                BNE inner_loop
            
        DEX
        BNE outer_loop
        
    RTS ; end subroutine



; intensity and up to 16 displays that can be sent in order
.org 0x2000

.include "displays.txt"