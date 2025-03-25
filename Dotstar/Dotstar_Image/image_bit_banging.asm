; image_bit_banging.asm
; program to do SPI input to dotstar LED BGR displays with software bit-banging on KIM-1, single image
; possible issue: not enough delay in clk
.cpu 6502

.equ outputKIM, 0x1700 ; variable for address of SPI pins, bit 7 is MOSI, bit 6 is SCLK
.equ outputSettings, 0x1701 ; variable for address of output settings, where we can set pins to inputs or outputs

.equ output, 0x1000 ; variable for address of output (for byte_send)

.equ globalByte, 0x1001 ; variable for address of first byte sent (for led_send)
.equ blueByte, 0x1002 ; variable for address of second byte sent (for led_send)
.equ greenByte, 0x1003 ; variable for address of third byte sent (for led_send)
.equ redByte, 0x1004 ; variable for address of fourth byte sent (for led_send)

.org 0x0200 ; start main at $0200

main:

    ; setup
    JSR setup

    begin:
    ; send start frame
    JSR start_frame

    ; load Y register
    LDY #0x00

    ; load the intensity value for RGBs
    ;LDA #0b11100000
    LDA intensity
    STA globalByte

    send_data: ; send LED data, up to 256 bytes for each spec bc 3*256 rgb values
        
        LDA blueData,Y
        STA blueByte

        LDA greenData,Y
        STA greenByte

        LDA redData,Y
        STA redByte

        JSR led_send

        CPY numLEDs

        INY
        
        BNE send_data ; branch if numLEDs not reached

    ; send end frame
    JSR end_frame

    ; JMP begin ; comment out if you don't want loop
    
    BRK ; break

byte_send: ; subroutine to send 8 bits

    set_clk_low: ; set the clock low before getting data in pin 7
        LDA outputKIM
        AND #0b10111111   ; Pull CLK (bit 6) low
        STA outputKIM
    
    set_counter: ; counter to see how many bits have been sent of byte
        LDX #0x08
        
    send_output: ; send byte of data
        
        ; store output bit in outputKIM bit 7
        LDA output ; load output into accumulator
        AND #0b10000000 ; AND output so only last bit is recognized
        ORA outputKIM ; OR output to what's in 0x1700, nothing is changed except last bit
        STA outputKIM ; store result in KIM output bit
        
    
    clk_cycle: ; simulate a clock cycle that occurs
               ; data has to be stable before clock rising edge
        
        LDA outputKIM ;load outputKIM into memory
        EOR #0b01000000 ; Invert SCLK (bit 6)
        STA outputKIM ; Store into outputKIM

        ASL output ; arithmetic shift left of output1 to move next output1 bit to bit 0
        
        LDA outputKIM ; load outputKIM
        EOR #0b01000000 ; Invert SCLK (bit 6)
        STA outputKIM ; Store into outputKIM
        
        LDA outputKIM ; set final digit of outputKIM to 0 so it is modified correctly on next edge
        AND #0b01111111
        STA outputKIM
        
        DEX ; decrement number of bits remaining to be sent
        
        BNE send_output ; jump to send_output for next bit
        
    RTS ; end subroutine


led_send: ; subroutine to send 4 bytes for individual LED frame
    
    ; send 3 bits + global byte
    send_global:
        LDA globalByte
        STA output
        JSR byte_send
    
    ; send blue data byte
    send_blue:
        LDA blueByte
        STA output
        JSR byte_send
    
    ; send green data byte
    send_green:
        LDA greenByte
        STA output
        JSR byte_send
    
    ; send red data byte
    send_red:
        LDA redByte
        STA output
        JSR byte_send
        
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
    
    set_low: ; Pull CLK pin to low by AND with outputKIM and storing it back
            LDA outputKIM
            AND #0b10111111  ; Pull CLK (bit 6) low
            STA outputKIM
            
    RTS

start_frame: ; send start frame (0's in every position)

    LDA #0x00
    STA globalByte
    STA blueByte
    STA greenByte
    STA redByte

    JSR led_send
    
    RTS ; end subroutine

end_frame: ; send end frame (1's in every position)

    LDA #0xFF
    STA globalByte
    STA blueByte
    STA greenByte
    STA redByte

    JSR led_send
    
    RTS ; end subroutine


; send image data
; intensity: how bright RGBs are
; numLEDs: total number of LEDs
; blueData: label with up to 256 bytes for blue data
; greenData: label with up to 256 bytes for green data
; redData: label with up to 256 bytes for red data
.org 0x2000

.include "image.txt"