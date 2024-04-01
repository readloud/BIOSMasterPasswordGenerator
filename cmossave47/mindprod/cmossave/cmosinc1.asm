Comment |

Common included routines for CMOSRest and CMOSCheck not needed by CMOSSave.

|                                        ; end of comment

;===============================================================

CalcCMOSSize   proc      near

;       Is CMOS 64 or 128 bytes long?
;       It is 64 if bytes at 10..2F match those at 50..6F.
;       Otherwise it is 128 bytes.
;       Preserves all registers.

               push      si
               push      di
               push      cx
               lea       si,CMOSBuff+10h
               lea       di,CMOSBuff+50h
               mov       cx,02fh+1-10h
               repe      cmpsb
               je        IsCMOS64

IsCMOS128:
               mov       CMOSSize,128   ; differ, must be a big CMOS
               jmp       CalcCMOSSizeDone

IsCMOS64:
               mov       CMOSSize,64    ; all same, small CMOS

CalcCMOSSizeDone:
               pop       cx
               pop       di
               pop       si

               ret

CalcCMOSSize   endp

;===============================================================

ReadCMOSFromFile proc    near

;       Open a file read the CMOS into a buffer

               lea       dx,FileName    ; DS:DX point to file
               xor       al,al          ; AL=0 is attribute read/only
               mov       ah,03Dh        ; DOS open function
               int       21h
               jc        FileTrouble
               mov       bx,ax          ; save handle
               mov       cx,128         ; read 128 bytes
               lea       dx,CMOSBuff    ; buffer address
               mov       ah,3fH         ; DOS read
               int       21h
               jc        FileTrouble
               cmp       ax,128
               jne       FileTrouble
               mov       ah,3eh         ; DOS close
               int       21h
               jc        FileTrouble
               ret

ReadCMOSFromFile endp

;===============================================================

Volatile       proc      near

;       Is cmos offset in AL volatile?  If so set carry.
;       These bytes will be undisturbed.
;       Preserves all registers.
;       00..09, 0C, 32 and 3F are volatile, rest are not.
;       0A 0B 0D 0E 0F used to be considered volatile, now are not.
;       if cmos is small, all bytes past end are considered volatile

               cmp       al,CMOSSize    ; bytes past end are volatile
               jae       IsVolatile
               cmp       al,09h
               jbe       IsVolatile     ; early bytes are for timing
               push      cx
               push      di
               mov       cx,VolatileCount
               lea       di,VolatileList
               repne     scasb          ; search till find a match
               pop       di
               pop       cx
               je        IsVolatile

IsNotVolatile:
               clc                      ; clear carry
               ret

IsVolatile:
               stc
               ret

Volatile       endp

;===============================================================

CompareCMOS    proc      near

;       compares buffer version of CMOS with contents of actual CMOS
;       ignores mismatches of volatile bytes.
;       Aborts if finds a mismatch

               mov       cx,128         ; count of times through loop
               lea       bx,CMOSBuff    ; where to find comparison set
               sub       al,al          ; start offset in CMOS
               push      si
               sub       si,si          ; count of mismatches
CompLoop:
               call      Volatile       ; test if this is a volatile byte
                                        ; test offset in al
               jc        MatchedOk
               call      PeekCMOS       ; al=offset ah=contents
               cmp       ah,byte ptr[bx] ; compare CMOS with buffer
               je        MatchedOk

;       Mismatch
               test      si,si          ; only issue explanation on first mismatch
               jnz       AlreadyComplained

               lea       dx,MatchTroubleMsg ; display CMOS mismatch
               call      Say
AlreadyComplained:
               push      ax
               inc       si             ; count of how many mismatches found
               call      SayHexByte     ; report offset
               lea       dx,ColonMsg
               call      Say
               mov       al,ah          ; report bad value in CMOS
               call      SayHexByte
               lea       dx,ColonMsg
               call      Say
               mov       al,byte ptr[bx] ; report what value should be from file.
               call      SayHexByte
               lea       dx,NextTripleMsg
               call      Say
               pop       ax

MatchedOk:
               inc       bx
               inc       al
               loop      CompLoop

               test      si,si
               jz        NoMismatches

               mov       ax, 4c01h      ; ERRORLEVEL = 1
               int       21h            ; DIE

NoMisMatches:
               pop       si
               ret

CompareCMOS    endp

;===============================================================
