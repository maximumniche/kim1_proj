; image_bit_banging.asm
; program to do SPI input to dotstar LED BGR displays with software bit-banging on KIM-1, gifs
; support for up to 70 frames, any more than that would need monochrome program

.cpu 6502

.equ outputKIM, 0x1700 ; variable for address of SPI pins, bit 7 is MOSI, bit 6 is SCLK
.equ outputSettings, 0x1701 ; variable for address of output settings, where we can set pins to inputs or outputs

.equ output, 0x1000 ; variable for address of output (for byte_send)

.equ globalByte, 0x1001 ; variable for address of first byte sent (for led_send)
.equ blueByte, 0x1002 ; variable for address of second byte sent (for led_send)
.equ greenByte, 0x1003 ; variable for address of first byte sent (for led_send)
.equ redByte, 0x1004 ; variable for address of second byte sent (for led_send)

.org 0x0200 ; start main at $0200

main:

    ; setup
    JSR setup

    ; load the intensity value for RGBs
    LDA intensity
    STA globalByte

    ; load the Y register
    begin:
    LDY #0x00

    send_frames: ; send LED data, 256 bytes for each spec bc 3*256 rgb values

        JSR start_frame ; send start of frame

        ; include a text file containing instructions to send to all leds
        .include "send_frame.txt"

        JSR end_frame ; send end of frame

        INY ; increase Y register to increase the frame led data is being sent about

        CPY numFrames

        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine
        JSR delay ; delay routine

        BNE not_done ; branch if frame limit isn't reached
    
    ;JMP begin ; repeat unless commented out
    
    BRK ; break

not_done: ; have to use JMP bc BNE can't handle branch this far
    JMP send_frames
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
        
        ASL output ; arithmetic shift left of output1 to move next output1 bit to bit 0
    
    clk_cycle: ; simulate a clock cycle that occurs
               ; data has to be stable before clock rising edge
        
        LDA outputKIM ;load outputKIM into memory
        EOR #0b01000000 ; Invert SCLK (bit 6)
        STA outputKIM ; Store into outputKIM
        
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
    
    ; set SCLK pin low
    set_sclk_low:
        LDA outputKIM
        AND #0b10111111 ; Pull SCLK (bit 6) low
        STA outputKIM
    
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

start_frame: ; send start byte (0's in every position)

    LDA #0x00
    STA globalByte
    STA blueByte
    STA greenByte
    STA redByte

    JSR led_send
    
    RTS ; end subroutine

end_frame: ; send end byte (1's in every position)

    LDA #0xFF
    STA globalByte
    STA blueByte
    STA greenByte
    STA redByte

    JSR led_send
    
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
    

; send gif data, takes a LOOOOOT of space, so more than 70 frames not possible
; numFrames: number of frames in gif
; intensity: how bright RGBs are
; numLEDs: number of LEDs on display
; blue0, blue1, ... blueN: labels for blue of each LED, and offset for each frame
; green0, green1, .... greenN: labels for green of each LED, and offset for each frame
; red0, red1, ... redN: labels for red of each LED, and offset for each frame
.org 0x2000

.include "frames.txt" ; include all data
