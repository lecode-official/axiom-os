
; Since the computer starts up in 16 bit real mode, the assembler must produce 16 bit code
bits  16

; After detecting the active partition, the master boot record loads the first 512 bytes of the partition into memory at the address 0x7C00,
; therefore all our addresses have to be aligned to this
org   0x7C00

; Jumps over the BIOS parameter block, which contains all the information about the FAT12 file system
jmp short BootSectorMain           ; Jumps directly to the start of the boot sector code
nop                                ; The no-operation is needed to fill up the space, because the BIOS parameter block start at byte 3

; The BIOS parameter block, which contains all information about the FAT12 file system on the boot medium
%include "Source/RealModeDrivers/Fat12BiosParameterBlock.asm"

; Pads the beginning of the boot loader with 62 bytes of zeros, this is needed, because the boot loader is written to a FAT12 filesystem, the first 62
; bytes of the boot sector contain the FAT12 headers
times 59                       db 0

; Marks the actual start of the boot sector code
BootSectorMain:

; We have organized our addresses to 0x7C00, this means all addresses are based from 0x7c00:0, because the data segments are within the same code
; segment, they are nulled
xor   ax, ax                       ; Sets the AX register to 0 by performing an exclusive or operation on it
mov   ds, ax                       ; Sets the data segment to 0
mov   es, ax                       ; Sets the extra segment to 0

; Sets up the stack safely away from the code at the address 0x9000 (the stack grows from higher address downwards to lower addresses, therefore a
; stack overflow would result in the code of the boot sector to be overwritten, which will result in strange behavior)
mov   bp, 0x9000                   ; Sets the bottom of the stack
mov   sp, bp                       ; Sets the top of the stack (since the stack is empty at the beginning, this is the same as the stack's bottom)

; Resets the screen to the standard video mode and clears it
call ResetScreen

; Prints out the title of the operating system
mov   si, OperatingSystemTitle     ; Loads the address of the success message
mov   bl, 0xE                      ; Sets the foreground color of the text to yellow
call  WriteLine                    ; Writes the operating system title to the screen
call  WriteEmptyLine               ; Writes an empty line which separates the title from the messages

; Prints out a success message that the boot sector has been loaded successfully
mov   si, BootSectorLoadedMessage
call  WriteSuccessMessage

; Prints out an informational message that the boot sector is loading the boot loader
mov   si, LoadingBootLoaderMessage
call  WriteInformationalMessage

; In order to prevent the CPU from going on beyond the boot sector and potentially executing random bytes, the CPU is halted (but it should not come
; this far)
cli                                ; Clears all interrupts before halting the CPU
hlt                                ; Prevents any further execution of code

; Includes all the drivers that are needed to run the boot sector and loading the boot loader
%include "Source/RealModeDrivers/VideoDriver.asm"   ; The video driver, that allows us to print strings to the screen
%include "Source/RealModeDrivers/StorageDriver.asm" ; The storage driver, that allows us to access the drive the boot sector was loaded from
%include "Source/RealModeDrivers/Fat12Driver.asm"   ; The FAT12 file system driver, that allows us to load the actual boot loader

; Contains all the strings that are used during the execution of the boot sector
OperatingSystemTitle           db "Axiom-0.0.1-Pre-Alpha-1", 0
BootSectorLoadedMessage        db "Boot sector loaded", 0
LoadingBootLoaderMessage       db "Loading boot loader...", 0
LoadingBootLoaderFailedMessage db "BootLoader could not be loaded", 0

; Pads the boot sector to 512 bytes (the boot sector must be exactly 512 bytes) with the last two bytes as the magic boot sector number (the BIOS
; and the master boot record recognize bootable devices if the last to bytes of the boot sector are 0x55AA)
times 510 - ($ - $$)           db 0
dw    0xAA55                       ; x86 & AMD64 are little endian machines, which means that the most significant byte comes 1st (0x55AA => 0xAA55)