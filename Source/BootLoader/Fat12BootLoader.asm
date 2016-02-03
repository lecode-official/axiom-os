
; Since the computer starts up in 16 bit real mode, the assembler must produce 16 bit code
bits  16

; The boot sector loads the boot loader to the address 0x10000, therefore all addresses have to be aligned to this
org 0x10000

; We have organized our addresses to 0x10000, this means all addresses are based from 0x10000:0, because the data segments are within the same code
; segment, they are nulled
xor   ax, ax                       ; Sets the AX register to 0 by performing an exclusive or operation on it
mov   ds, ax                       ; Sets the data segment to 0
mov   es, ax                       ; Sets the extra segment to 0

; Sets up the stack safely away from the code at the address 0x11000 (the stack grows from higher address downwards to lower addresses, therefore a
; stack overflow would result in the code of the boot loader to be overwritten, which will result in strange behavior)
mov   bp, 0x11000                  ; Sets the bottom of the stack
mov   sp, bp                       ; Sets the top of the stack (since the stack is empty at the beginning, this is the same as the stack's bottom)

; Prints out a success message that the boot loader has been loaded successfully
mov   si, BootLoaderLoadedMessage
call  WriteSuccessMessage

; In order to prevent the CPU from going on beyond the boot loader and potentially executing random bytes, the CPU is halted (but it should not come
; this far)
cli                                ; Clears all interrupts before halting the CPU
hlt                                ; Prevents any further execution of code

; Includes all the drivers that are needed to run the boot loader and loading the kernel
%include "Source/RealModeDrivers/VideoDriver.asm"   ; The video driver, that allows us to print strings to the screen

; Contains all the strings that are used during the execution of the boot loader
BootLoaderLoadedMessage        db "Boot loader loaded", 0