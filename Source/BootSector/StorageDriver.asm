
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