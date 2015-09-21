
; Since the computer starts up in 16 bit real mode, the assembler must produce 16 bit code
bits  16

; After detecting the active partition, the master boot record loads the first 512 bytes of the partition into memory at the address
; 0x7C00, therefore all our addresses have to be aligned to this
org   0x7C00

; Jumps over the BIOS parameter block, which contains all the information about the FAT12 file system
jmp short BootSectorMain           ; Jumps directly to the start of the boot sector code
nop                                ; The no-operation is needed to fill up the space, because the BIOS parameter block start at byte 3

; The BIOS parameter block, which contains all information about the FAT12 file system on the boot medium
OemIdentifier                  db "Axiom   "
NumberOfBytesPerSector         dw 512
NumberOfSectorsPerCluster      db 1
NumberOfReservedSectors        dw 1
NumberOfFileAllocationTables   db 2
NumberOfDirectoryEntries       dw 224
TotalSectorsInLogicalVolume    dw 2880
MediaDescriptorType            db 0xF0
NumberOfSectorsPerFat          dw 9
NumberOfSectorsPerTrack        dw 18
NumberOfHeadsPerCylinder       dw 2
NumberOfHiddenSectors          dd 0
NumberOfTotalSectorsBig        dd 0
DriveNumber                    db 0
UnusedReservedFlags            db 0
BootSignature                  db 0x29
SerialNumber                   dd 0xA0A1A2A3
VolumeLabel                    db "AxiomVolume"
FileSystem                     db "FAT12   "

; Pads the beginning of the bootloader with 62 bytes of zeros, this is needed, because the bootloader is written to a FAT12 filesystem,
; the first 62 bytes of the boot sector contain the FAT12 headers
times 59                       db 0

; Marks the actual start of the boot sector code
BootSectorMain:

; We have organized our addresses to 0x7C00, this means all addresses are based from 0x7c00:0, because the data segments are within the
; same code segment, they are nulled
xor   ax, ax                       ; Sets the AX register to 0 by performing an exclusive or operation on it
mov   ds, ax                       ; Sets the data segment to 0
mov   es, ax                       ; Sets the extra segment to 0

; Sets up the stack safely away from the code at the address 0x9000 (the stack grows from higher address downwards to lower addresses,
; therefore a stack overflow would result in the code of the boot sector to be overwritten, which will result in strange behavior)
mov   bp, 0x9000                   ; Sets the bottom of the stack
mov   sp, bp                       ; Sets the top of the stack (since the stack is empty at the beginning, this is the same as the
                                   ; stack's bottom)

; Resets the screen to the standard video mode and clears it
call ResetScreen

; Prints out the title of the operating system
mov   si, OperatingSystemTitle     ; Loads the address of the success message
mov   bl, 0xE                      ; Sets the foreground color of the text to yellow
call  WriteLine                    ; Writes the operating system title to the screen
mov   si, EmptyString              ; Loads the address of the empty string
call  WriteLine                    ; Write an empty string, which results in just breaking the line

; Prints out a success message that the BIOS has successfully loaded the boot sector
mov   si, SuccessMessage           ; Loads the address of the success message
mov   bl, 0x2                      ; Sets the foreground color of the text to green
call  Write                        ; Writes the informational message to the screen
mov   si, BootSectorLoadedMessage  ; Loads the address of the success message
mov   bl, 0x7                      ; Sets the foreground color of the text to light gray
call  WriteLine                    ; Writes the success message to the screen

; Prints out an informational message that the boot sector is loading the bootloader
mov   si, InformationalMessage     ; Loads the address of the informational message
mov   bl, 0x9                      ; Sets the foreground color of the text to light blue
call  Write                        ; Writes the informational message to the screen
mov   si, LoadingBootloaderMessage ; Loads the address of the informational message
mov   bl, 0x7                      ; Sets the foreground color of the text to light gray
call  WriteLine                    ; Writes the success message to the screen

; In order to prevent the CPU from going on beyond the boot loader and potentially executing random bytes, the CPU is halted (but it
; should not come this far)
cli                                ; Clears all interrupts before halting the CPU
hlt                                ; Prevents any further execution of code

; Includes all the drivers that are needed to run the boot sector and loading the boot loader
%include "Source/BootSector/VideoDriver.asm"   ; The video driver, that allows us to print strings to the screen
%include "Source/BootSector/StorageDriver.asm" ; The storage driver, that allows us to access the drive the boot sector was loaded from
%include "Source/BootSector/Fat12Driver.asm"   ; The FAT12 file system driver, that allows us to load the actual boot loader

; Contains all the strings that are used during the execution of the boot sector
EmptyString                    db 0
OperatingSystemTitle           db "Axiom-0.0.1-Pre-Alpha-1", 0
InformationalMessage           db "[ Info ] ", 0
SuccessMessage                 db "[ Okay ] ", 0
ErrorMessage                   db "[ Fail ] ", 0
BootSectorLoadedMessage        db "Bootsector loaded", 0
LoadingBootloaderMessage       db "Loading bootloader...", 0
LoadingBootloaderFailedMessage db "Bootloader could not be loaded", 0

; Pads the boot sector to 512 bytes (the boot sector must be exactly 512 bytes) with the last two bytes as the magic boot sector number
; (the BIOS and the master boot record recognize bootable devices if the last to bytes of the boot sector are 0x55AA)
times 510 - ($ - $$)           db 0
dw    0xAA55                       ; x86 and AMD64 are little endian machines, which means that the most significant byte comes first
                                   ; (0x55AA => 0xAA55)