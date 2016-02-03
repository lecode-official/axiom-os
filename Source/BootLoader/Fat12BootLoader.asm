
; Since the computer starts up in 16 bit real mode, the assembler must produce 16 bit code
bits  16

; The boot sector loads the boot loader to the address 0x10000, therefore all addresses have to be aligned to this
org 0x10000

; Disables all interrupts, so that the set up of the segments and the stack is not interrupted
cli

; We have organized our addresses to 0x10000, this means all addresses are based from 0x0000:0x10000, because the data segments are within the same code
; segment, they are all set to 0
xor   ax, ax                       ; Sets the AX to 0, this is needed, because segment registers can not be set directly
mov   ds, ax                       ; Sets the data segment to 0
mov   es, ax                       ; Sets the extra segment to 0
mov   fs, ax                       ; Sets the FS general purpose segment to 0
mov   gs, ax                       ; Sets the GS general purpose segment to 0

; Sets up the stack safely away from the code at the address 0x9000 (the stack grows from higher address downwards to lower addresses, therefore a
; stack overflow would result in the code of the boot sector to be overwritten, which will result in strange behavior)
mov   ss, ax                       ; Sets the stack segment to 0
mov   bp, 0x11000                  ; Sets the bottom of the stack
mov   sp, bp                       ; Sets the top of the stack (since the stack is empty at the beginning, this is the same as the stack's bottom)

; Enables all interrupts again after the segments and the stack have been set up
sti

; Prints out a success message that the boot loader has been loaded successfully
mov   si, BootLoaderLoadedMessage
mov   bl, 0x2                      ; Sets the foreground color of the text to green
call  WriteLine

; In order to prevent the CPU from going on beyond the boot loader and potentially executing random bytes, the CPU is halted (but it should not come
; this far)
cli                                ; Clears all interrupts before halting the CPU
hlt                                ; Prevents any further execution of code

; Includes all the drivers that are needed to run the boot loader and loading the kernel
%include "Source/RealModeDrivers/VideoDriver.asm"   ; The video driver, that allows us to print strings to the screen

; Contains all the strings that are used during the execution of the boot loader
BootLoaderLoadedMessage        db "Boot loader loaded", 0