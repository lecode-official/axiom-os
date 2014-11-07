
; Prints a string to the screen.
; DS:SI => The address of the string (the string must be null-terminated).
PrintString:
	pusha            ; Pushes all registers to the stack, so that we can manipulate them as we wish without breaking the caller
	mov   ah, 0x0E   ; We use the tele-type function of the BIOS video service
	Loop:
		lodsb        ; Loads the next character of the string into the AL register
		or    al, al ; Performs a bitwise OR on the AL register in order to set the flags register (this is needed to check AL for 0)
		jz    Return ; If the register AL is 0, then we jump to the return label
		int   0x10   ; Calls the BIOS video service interrupt
		jmp   Loop   ; Loops over the string till the 0 terminator is reached
	Return:
		popa         ; Restores all registers from the stack
		ret          ; Returns to the caller