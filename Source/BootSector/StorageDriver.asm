
; Resets the floppy disk drive from which the boot sector was booted and goes immediately goes to the first sector off the disk.
ResetDrive:
    mov   ah, 0                                   ; AH contains the function number of the 13h BIOS interrupt, function 0 resets the drive
    mov   dl, 0                                   ; DL contains the drive number, drive 0 is the floppy disk drive from which the BIOS has booted
    int   13h                                     ; Calls the BIOS interrupt 13h to reset the floppy disk drive
    jc    ResetDrive                              ; If anything went wrong then the carry flag is set, if so the resetting is retried

; Reads a series of sectors from disk.
; CX    => The number of sectors to read.
; AX    => The sector from which on should be read.
; ES:BX => The address of the buffer to which the read bytes are written.
ReadSectors:
    Start:
        mov   di, 0x0005                          ; five retries for error
    Loop:
        push  ax
        push  bx
        push  cx
        call  ConvertLbaToChs                     ; convert starting sector to CHS
        mov   ah, 0x02                            ; BIOS read sector
        mov   al, 0x01                            ; read one sector
        mov   ch, BYTE [absoluteTrack]            ; track
        mov   cl, BYTE [absoluteSector]           ; sector
        mov   dh, BYTE [absoluteHead]             ; head
        mov   dl, BYTE [bsDriveNumber]            ; drive
        int   0x13                                ; invoke BIOS
        jnc   Success                             ; test for read error
        xor   ax, ax                              ; BIOS reset disk
        int   0x13                                ; invoke BIOS
        dec   di                                  ; decrement error counter
        pop   cx
        pop   bx
        pop   ax
        jnz   Loop                                ; attempt to read again
        int   0x18
    Success:
        pop   cx
        pop   bx
        pop   ax
        add   bx, WORD [bpbBytesPerSector]        ; queue next buffer
        inc   ax                                  ; queue next sector
        loop  Start                               ; read next sector
        ret

; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
ConvertChsToLba:
    sub   ax, 0x0002                          ; zero base cluster number
    xor   cx, cx
    mov   cl, BYTE [bpbSectorsPerCluster]     ; convert byte to word
    mul   cx
    add   ax, WORD [datasector]               ; base data sector
    ret

; Convert LBA to CHS
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
; AX    => LBA Address to convert
ConvertLbaToChs:
    xor   dx, dx                              ; prepare dx:ax for operation
    div   WORD [bpbSectorsPerTrack]           ; calculate
    inc   dl                                  ; adjust for sector 0
    mov   BYTE [absoluteSector], dl
    xor   dx, dx                              ; prepare dx:ax for operation
    div   WORD [bpbHeadsPerCylinder]          ; calculate
    mov   BYTE [absoluteHead], dl
    mov   BYTE [absoluteTrack], al
    ret