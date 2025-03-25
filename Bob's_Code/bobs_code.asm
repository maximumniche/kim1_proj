        .equ    PortADR, 0x1700
        .equ    PortADDR, 0x1701
        .equ    PortBDR, 0x1702
        .equ    PortBDDR, 0x1703
        .equ    PortA2DR, 0x1740
        .equ    PortA2DDR, 0x1741
        .equ    BobsPort, 0x1700
        .equ    GETKEY, 0x1f6a
        .equ    Temp, 0x00
        .equ    TableAddrL, 0x01
        .equ    TableAddrH, 0x02
        .equ    LEDCounter, 0x03
        .equ    Temp2, 0x04

        .equ    NumberOfLEDs, 64

        .org    0x0200
Begin:
        lda     #0x00
        sta     BobsPort
        ldy     #0x00

Loop:   jsr     InitTableAddr

        lda     #0x00        ; Send 4 leading 0x00's
        jsr     SPIByte
        lda     #0x00
        jsr     SPIByte
        lda     #0x00
        jsr     SPIByte
        lda     #0x00
        jsr     SPIByte

        lda     #NumberOfLEDs
        sta     LEDCounter

NextLED:
        lda     #0xf0        ; 50% brightness
        jsr     SPIByte

        jsr     GetNextTableValue    ; Send 1 LED color
        jsr     SPIByte
        jsr     GetNextTableValue
        jsr     SPIByte
        jsr     GetNextTableValue
        jsr     SPIByte

        dec     LEDCounter
        bne     NextLED

        jmp     Loop        ; Comment out this JMP if you want to skip the 4 ending 0xFFs

        lda     #0xff
        jsr     SPIByte
        lda     #0xff
        jsr     SPIByte
        lda     #0xff
        jsr     SPIByte
        lda     #0xff
        jsr     SPIByte

        jmp     Loop

SPIByte:                    ; Send 1 byte of data in A on clock rising edge
        sta     Temp
        ldx     #0x08    
NextBit:
        lda     Temp
        and     #0x01
        sta     BobsPort
        ora     #0x02
        sta     BobsPort
        and     #0x01
        sta     BobsPort
        ror     Temp
        dex
        bne     NextBit
        lda     #0x00
        sta     BobsPort
        rts

InitTableAddr:
        lda     #0x00
        sta     TableAddrL
        lda     #0x04
        sta     TableAddrH
        rts

GetNextTableValue:            ; Load A with the next table value and inc the pointer
        lda     (TableAddrL),y
        jsr     IncTablePtr
        rts

IncTablePtr:                  ; Increment the table pointer in absolute indexed mode
        pha
        inc     TableAddrL
        clc
        lda     TableAddrL
        sta     TableAddrL
        lda     TableAddrH
        adc     #0x00
        sta     TableAddrH
        pla
        rts

        .org    0x0400

Image1:
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0
        .byte   0xf0,0x00,0x00
        .byte   0x00,0xf0,0x00
        .byte   0x00,0x00,0xf0