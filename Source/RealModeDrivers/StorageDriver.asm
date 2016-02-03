
; Resets the floppy disk drive from which the boot sector was booted and goes immediately goes to the first sector off the disk.
ResetDrive:

    ; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function call returns,
    ; the registers are restored by popping their values from the stack, this ensures that the registers contain the exact values that the caller
    ; expects them to have 
    pusha
    
    ; Calls an interrupt, which resets the floopy disk drive
    mov   ah, 0                                   ; AH contains the function number of the 13h BIOS interrupt, function 0 resets the drive
    mov   dl, BYTE [DriveNumber]                  ; DL contains the number of the floppy disk drive from which the BIOS has booted
    int   13h                                     ; Calls the BIOS interrupt 13h to reset the floppy disk drive
    
    ; If anything went wrong while resetting the floppy disk drive then the carry flag is set, if so the resetting is retried, till it works
    jc    ResetDrive
    
    ; Pops all registers from the stack and restores them to their previous state, terminates the function call, and returns to the caller
    popa
    ret

;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;

ReadSectors:
     .MAIN:
          mov     di, 0x0005                          ; five retries for error
     .SECTORLOOP:
          pusha
          call    LBACHS                              ; convert starting sector to CHS
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, BYTE [absoluteTrack]            ; track
          mov     cl, BYTE [absoluteSector]           ; sector
          mov     dh, BYTE [absoluteHead]             ; head
          mov     dl, BYTE [DriveNumber]            ; drive
          int     0x13                                ; invoke BIOS
          jnc     .SUCCESS                            ; test for read error
          xor     ax, ax                              ; BIOS reset disk
          int     0x13                                ; invoke BIOS
          dec     di                                  ; decrement error counter
          popa
          jnz     .SECTORLOOP                         ; attempt to read again
          int     0x18
     .SUCCESS:
          popa
          add     bx, WORD [NumberOfBytesPerSector]        ; queue next buffer
          inc     ax                                  ; queue next sector
          loop    .MAIN                               ; read next sector
          ret

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;

ClusterLBA:
          sub     ax, 0x0002                          ; zero base cluster number
          xor     cx, cx
          mov     cl, BYTE [NumberOfSectorsPerCluster]     ; convert byte to word
          mul     cx
          add     ax, WORD [datasector]               ; base data sector
          ret
     
;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;

LBACHS:
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [NumberOfSectorsPerTrack]           ; calculate
          inc     dl                                  ; adjust for sector 0
          mov     BYTE [absoluteSector], dl
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [NumberOfHeadsPerCylinder]          ; calculate
          mov     BYTE [absoluteHead], dl
          mov     BYTE [absoluteTrack], al
          ret

absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

datasector     dw 0x0000