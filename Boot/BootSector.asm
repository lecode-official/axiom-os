
; Since the computer starts up in 16 bit real mode, the assembler must produce 16 bit code
bits  16

; After detecting the boot sector, the BIOS loads the first 512 bytes of the boot disk into memory at the address 0x7C00, therefore
; all our addresses have to be aligned to this
org   0x7C00

; We have organized our addresses to 0x7C00, this means all addresses are based from 0x7c00:0, because the data segments are within
; the same code segment, they are nulled
xor   ax, ax                      ; Sets the AX register to 0 by performing an exclusive or operation on it
mov   ds, ax                      ; Sets the data segment to 0
mov   es, ax                      ; Sets the extra segment to 0

; Sets up the stack safely away from the code
mov   bp, 0x9000                  ; Sets the bottom of the stack
mov   sp, bp                      ; Sets the top of the stack (since the stack is empty at the beginning, this is the same as the
                                  ; stack's bottom)

; Prints out a success message that the BIOS has successfully loaded the boot sector
mov   si, BootLoaderLoadedMessage
call  PrintString

; In order to prevent the CPU from going on beyond the boot loader and potentially executing random bytes, the CPU is halted (but
; it should not come this far)
cli                               ; Clears all interrupts before halting the CPU
hlt                               ; Prevents any further execution of code

; Includes all the drivers that are needed to run the boot loader
%include "Boot/VideoDriver.asm"   ; A simple video driver, that allows us to print strings to the screen
%include "Boot/StorageDriver.asm" ; A simple storage driver, that allows us to access the drive the boot loader was loaded from
%include "Boot/Ext2Driver.asm"    ; A simple ext2 file system driver, that allows us to load the second stage of the boot loader

; Contains all the string that are used during the execution of the first state of the boot loader
BootLoaderLoadedMessage db "Success: The BIOS has loaded the first stage of the bootloader", 0

; Pads the boot sector to 512 bytes (the boot sector must be exactly 512 bytes) with the last two bytes as the magic boot sector
; number (the recognizes bootable devices if the last to bytes of the boot sector are 0x55AA)
times 510 - ($ - $$)    db 0
dw    0xAA55                      ; x86 and AMD64 are little endian machines, which means that the most significant byte comes first
                                  ; (0x55AA => 0xAA55)