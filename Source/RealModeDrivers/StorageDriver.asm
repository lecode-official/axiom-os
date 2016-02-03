
; Resets the floppy disk drive from which the boot sector was booted and goes immediately goes to the first sector off the disk.
ResetDrive:

    ; Pushes all registers that are used in this function to the stack, so that we can manipulate them as we wish, before the function call returns,
    ; the registers are restored by popping their values from the stack, this ensures that the registers contain the exact values that the caller
    ; expects them to have 
    pusha
    
    ; Calls an interrupt, which resets the floopy disk drive
    mov   ah, 0                                   ; AH contains the function number of the 13h BIOS interrupt, function 0 resets the drive
    mov   dl, 0                                   ; DL contains the drive number, drive 0 is the floppy disk drive from which the BIOS has booted
    int   13h                                     ; Calls the BIOS interrupt 13h to reset the floppy disk drive
    
    ; If anything went wrong while resetting the floppy disk drive then the carry flag is set, if so the resetting is retried, till it works
    jc    ResetDrive
    
    ; Pops all registers from the stack and restores them to their previous state, terminates the function call, and returns to the caller
    popa
    ret