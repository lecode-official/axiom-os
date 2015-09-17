
; Resets the screen to its default state (80x25 text, 16 colors, 8 pages) and clears the screen.
ResetScreen:

	; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function
	; call returns, the registered are restored by popping their values from the stack, this ensures that the registers contain the exact
	; values that the caller expects them to have 
	push  ax
	
	; The BIOS video service, which resides in the interrupt 0x10, expects the number of the function that is being call in the AH
	; register, since the set video mode function is used (which has the number 0x00), then value of AH is set accordingly
	mov   ah, 0x00
	
	; The BIOS video service expects the video mode that is to be set in the AL register, 0x03 stands for the video mode 80x25 text,
	; 16 colors, 8 pages, since the 7th bit of the AL register is not set, the screen is also cleared
	mov   al, 0x03
	
	; Calls the BIOS video service interrupt to set the scren mode
	int   0x10
	
	; Restores all registers to the state that the caller expects them to be and returns to the caller
	pop   ax
	ret

; Write a string to the screen.
; DS:SI => The address of the string that is to written to the screen (the string must be null-terminated).
Write:

	; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function
	; call returns, the registered are restored by popping their values from the stack, this ensures that the registers contain the exact
	; values that the caller expects them to have 
	push  ax
	
	; The BIOS video service, which resides in the interrupt 0x10, expects the number of the function that is being call in the AH
	; register, since the tele-type function is used (which has the number 0x0E), then value of AH is set accordingly
	mov   ah, 0x0E
	
	; Cycles over each character that is to be written and writes it, when the null character is reached, the loop is stopped
	Loop:
		lodsb        ; Loads the next character of the string into the AL register (which is where the interrupt 0x10 expects it)
		or    al, al ; Performs a bitwise OR on the AL register in order to set the flags register (this is needed to check AL for 0)
		jz    Return ; If register AL is 0, then we jump to the return label, since the string is null-terminated and that end was reached
		int   0x10   ; Calls the BIOS video service interrupt to write the current character
		jmp   Loop   ; Loops over the string till the 0 terminator is reached
		
	; This marks the end of the function, it restores all registers to the state that the caller expects them to be
	Return:
		pop   ax     ; Restores all registers from the stack
		ret          ; Returns to the caller