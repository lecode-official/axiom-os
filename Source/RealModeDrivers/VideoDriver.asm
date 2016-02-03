
; Resets the screen to its default state (80x25 text, 16 colors, 8 pages) and clears the screen.
ResetScreen:

    ; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function call returns,
    ; the registers are restored by popping their values from the stack, this ensures that the registers contain the exact values that the caller
    ; expects them to have 
    push  ax
    
    ; The BIOS video service, which resides in the interrupt 0x10, expects the number of the function that is being call in the AH register, since
    ; the set video mode function is used (which has the number 0x00), then value of AH is set accordingly
    mov   ah, 0x00
    
    ; The BIOS video service expects the video mode that is to be set in the AL register, 0x03 stands for the video mode 80x25 text, 16 colors, 8
    ; pages, since the 7th bit of the AL register is not set, the screen is also cleared
    mov   al, 0x03
    
    ; Calls the BIOS video service interrupt to set the scren mode
    int   0x10
    
    ; Restores all registers to the state that the caller expects them to be and returns to the caller
    pop   ax
    ret

; Write a string to the screen.
; DS:SI => The address of the string that is to written to the screen (the string must be null-terminated).
; BL    => The foreground color with which the character is to be displayed. The following color values are allowed: 0x0 = Black, 0x1 = Blue,
;          0x2 = Green, 0x3 = Cyan, 0x4 = Red, 0x5 = Magenta, 0x6 = Brown, 0x7 = Light Gray, 0x8 = Dark Gray, 0x9 = Light Blue, 0xA Ligth Green,
;          0xB = Light Cyan, 0xC = Light Red, 0xD Light Magenta, 0xE = Yellow, 0xD = White.
Write:

    ; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function call returns,
    ; the registers are restored by popping their values from the stack, this ensures that the registers contain the exact values that the caller
    ; expects them to have 
    pusha
    
    ; Cycles over each character that is to be written and writes it, when the null character is reached, the loop is stopped, since the cursor is
    ; not moved when a character is written, the cursor is moved by hand
    WriteLoop:
        mov   ah, 0x9              ; The number of the BIOS 0x10 interrupt function for writing a character and attribute
        mov   bh, 0x0              ; The character is to be written to the first page
        mov   cx, 0x1              ; CX contains the repeat count, since the characters should only be written once, it is set to 0x01
        lodsb                      ; Loads the next character of the string into the AL register (which is where the interrupt 0x10 expects it)
        or    al, al               ; Performs a bitwise OR on the AL register in order to set the flags register (this is needed to check AL for 0)
        jz    Return               ; If register AL is 0, then the function is exited, since the string is null-terminated and that end was reached
        int   0x10                 ; Calls the BIOS video service interrupt to write the current character
        mov   ah, 0x3              ; The number of the BIOS 0x10 interrupt function for querying the current position of the cursor
        int   0x10                 ; Queries the current position of the cursor, so that the cursor position can be increased by one
        mov   ah, 0x2              ; The number of the BIOS 0x10 interrupt function for setting the position of the cursor
        inc   dl                   ; After calling function 0x3, DL contains the current column number of the cursor, which is increased by one
        int   0x10                 ; Sets the new cursor position, which is the next column
        jmp   WriteLoop            ; Loops over the string till the 0 terminator is reached
        
    ; This marks the end of the function, it restores all registers to the state that the caller expects them to be
    Return:
        popa                       ; Pops all registers from the stack to restore them to their previous state
        ret                        ; Returns to the caller

; Write a string to the screen and adds a line break to the end.
; DS:SI => The address of the string that is to written to the screen (the string must be null-terminated).
; BL    => The foreground color with which the character is to be displayed. The following color values are allowed: 0x0 = Black, 0x1 = Blue,
;          0x2 = Green, 0x3 = Cyan, 0x4 = Red, 0x5 = Magenta, 0x6 = Brown, 0x7 = Light Gray, 0x8 = Dark Gray, 0x9 = Light Blue, 0xA Ligth Green,
;          0xB = Light Cyan, 0xC = Light Red, 0xD Light Magenta, 0xE = Yellow, 0xD = White.
WriteLine:

    ; First of all the string itself is written
    call  Write
    
    ; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function call returns,
    ; the registers are restored by popping their values from the stack, this ensures that the registers contain the exact values that the caller
    ; expects them to have 
    pusha
    
    ; After the string is written, the line break is added, which is done by moving the cursor to the first column of the next line
    mov   bh, 0x0                  ; Since the video driver only writes to the first page, the cursor position of the first page is retrieved
    mov   ah, 0x3                  ; The number of the BIOS 0x10 interrupt function for querying the current position of the cursor
    int   0x10                     ; Queries the current position of the cursor
    mov   ah, 0x2                  ; The number of the BIOS 0x10 interrupt function for setting the position of the cursor
    mov   dl, 0x0                  ; After calling function 0x3, DL contains the current colum number of the cursor, which is reset to one
    inc   dh                       ; After calling function 0x3, DH contains the current row number of the cursor, which is increased by one
    int   0x10                     ; Sets the new cursor position, to the beginning of the next line
    
    ; Pops all registers from the stack and restores them to their previous state, terminates the function call, and returns to the caller
    popa
    ret