
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