Comment |

Common included routines for CMOSSave, CMOSRest and CMOSCheck

|                                        ; end of comment

;===============================================================

CommandLine    proc      near
;       gets command line into ES:bx with length in cx.
;       This version works for a COM file only.
               xor       ch,ch
               mov       cl,ES:80H
               mov       bx,81H
               ret
CommandLine    endp

;===============================================================

NthParm        proc      near
;       Parses string for Nth Parameter delimited by blanks
;       e.g.  "  A: /Q " with bx=1 would give string "/Q"
;       on entry:
;       ES:bx - string, usually the command line
;       cx - length of string
;       dx - which parm wanted 1=parm1 2=parm2 etc.
;       NthParm only finds one parm per call.
;       On exit ES:bx points to string and cx is its length.
;       If there is no parm, the length will be 0.
;       It also handles multiple leading/trailing blanks on parms.
               mov       al,20h         ; al = blank  -- the search char
               mov       di,bx
Parmloop:
;       Remove leading blanks on parm
               jcxz      NullParm       ; jump if null string
               repe      scasb          ; scan ES:di forwards till hit non blank

                                        ; di points just after it
                                        ; cx is one too small, or 0 if none found
               je        NullParm       ; jump if entire string was blank
               inc       cx             ; cx is length of remainder of string
               dec       di             ; di points to non-blank
               mov       si,di          ; remember start of string
;       Search for terminating blank on parm
               jcxz      NullParm       ; jump if null string
               repne     scasb          ; scan ES:di forwards till hit blank
                                        ; di points just after it
                                        ; cx is one too small, or 0 if none found
               jne       NoBlank        ; jump if entire string was non blank
               inc       cx             ; cx is length of remainder of string
               dec       di             ; backup di to point to blank at string end
NoBlank:
                                        ; di=addr tail end of command string,
                                        ; cx=len tail end of command string
                                        ; si=addr parm just parsed
;       Major loop for each parm
               dec       dx
               jnz       Parmloop       ; loop once for each parm

               mov       cx,di
               sub       cx,si          ; cx is length of parameter.
               mov       bx,si
               ret
NullParm:                               ; was no nth parameter
               mov       cx,0
               mov       bx,si
               ret
NthParm        endp

;===============================================================

Parse          proc      near
;       Parse the command line and process each parameter.
;       sample inputs
;       CMOSSAVE A:\CMOS.SAV /Q
;       CMOSREST C:\CMP\CMOS.SAV
                                        ; counted string at HEX 80 PSP
                                        ; contains command line.
                                        ; Preceeded by unwanted spaces.
                                        ; possibly followed by unwanted spaces.
                                        ; currently missing a trailing null.
                                        ; Both ES and DS cover the command line
                                        ; since this is a COM file.
                                        ; However to make code compatible with EXE
                                        ; files we use ES: to cover the command line.
               call      CommandLine    ; string addr ES:bx, length cx.
               jcxz      NullParms

               mov       ParmIndex,1    ; start parsing with the 1st parm
                                        ; note start with 1 not 0!
                                        ; We don't want the the program name.
               jmp       Short Parseloop

NullParms:
NoMoreParms:
               test      fileName,-1    ; ensure some sort of filename provided
               jz        BadCmd         ; by the time all done
               mov       ax,DS
               mov       ES,ax          ; restore ES to match DS
               ret                      ; we are done

Parseloop:
               call      CommandLine    ; commmandline=ES:bx, length=cx
               mov       dx,ParmIndex
               call      NthParm        ; work left to right
               jcxz      NoMoreParms    ; null param means no more
                                        ; e.g. ES:bx points to A: or /Q
                                        ; cx is length of that piece
               mov       ax,ES:[bx]     ; al=A ah=:  or  al=/ ah=Q
               call      ToUc           ; Convert both chars to upper case
               xchg      ah,al
               call      ToUc
               cmp       ah,'/'         ; drive or Switch?
               jne       ProcessDrive
                                        ; it was a switch with slash
                                        ; was it /Q?
               cmp       al,'Q'
               je        ProcessQ
                                        ; something else, give up.
BadCmd:
               jmp       SyntaxTrouble

ProcessDrive:
                                        ; don't insist on drive letter.
                                        ; should have C:\CMP\CMOS.SAV
                                        ; copy string to FileName
                                        ; followed by a null

               mov       si,bx
               lea       di,FileName    ; ES:si -> DS:di ( segs are backwards )
               push      ES             ; swap ES DS
               push      DS
               pop       ES
               pop       DS
               rep       movsb          ; copy filename DS:si -> ES:di
               mov       ES:[di],byte ptr 0 ; append a null
               push      ES             ; swap ES DS back to normal
               push      DS
               pop       ES
               pop       DS
               jmp       short Next

ProcessQ:                               ; handle /Quiet
               mov       SlashQuiet,-1

Next:
               inc       ParmIndex      ; bump loop counter
               jmp       Parseloop      ; loop till hit null param

Parse          endp

;===============================================================

PeekCMOS       proc      near

;       Reads one byte from cmos.
;       on entry al has offset desired
;       on exit ah has the contents of that byte.
;       preserves all registers

;       See page 5-81 IBM AT Tech ref BIOS listing for how to read CMOS
;       We always enable the NMI with bit 7 on.

               push      bx
               push      ax
               cli                      ; disable interrupts
               or        al,80h         ; disable NMI
                                        ; controlled by port 70
               out       70h,al         ; output the byte address to CMOS
               jmp       $+2            ; delay, safer than nop
               in        al,71h         ; read the CMOS byte
               jmp       $+2            ; delay, safer than nop
               mov       bl,al
                                        ; re-enable the NMI, high bit off
               mov       al,0dh         ; point to battery status register
               out       70h,al         ; leave pointing at a safe r/o register
               sti                      ; restore interrupts
               pop       ax
               mov       ah,bl
               pop       bx
               ret

PeekCMOS       endp

;===============================================================

Say            proc

;       on entry DX points to a string to display
               push      ax
               mov       AH,9
               int       21h
               pop       ax
               ret

Say            endp

;======================================

hexPAD         db        '00$'          ; where numeric output built by SayHexByte

SayHexByte     proc      near
                                        ;       al contains hex byte to display:

               push      ax             ; preserve regs
               push      bx
               push      cx
               push      dx
               mov       dl,al          ; save input
;       Do first (leftmost digit)
               mov       cl,4
               shr       al,cl
               and       al,0fh         ; get first digit
               cmp       al,9
               jg        HexChar1
               add       al,'0'         ; convert digit to ASCII
               jmp       StoreChar1
HexChar1:
               add       al,'A'-0AH     ; convert to uppercase A..H
StoreChar1:
               mov       hexPad,al

;       Do second (rightmost digit)
               mov       al,dl
               and       al,0fh         ; get last digit
               cmp       al,9
               jg        HexChar2
               add       al,'0'         ; convert digit to ASCII
               jmp       StoreChar2
HexChar2:
               add       al,'A'-0AH     ; convert to uppercase A..H
StoreChar2:
               mov       hexPad+1,al

;       Number is ready
               lea       dx,Hexpad
               mov       AH,09h         ; BIOS put string terminated by $
               int       21h
               pop       dx
               pop       cx
               pop       bx
               pop       ax
               ret

SayHexByte     endp

;===============================================================

SayQ           proc
;       on entry DX points to a string to display
;       Only displays string if /Q not on
               test      SlashQuiet,-1
               jnz       Quietly
               call      Say
Quietly:
               ret
SayQ           endp

;========================================

ToUC           proc      NEAR
;       converts char in AL to upper case
               cmp       al,'a'
               jb        FineAsIs
               cmp       al,'z'
               ja        FineAsIs
               sub       al,20H         ; convert a to A
FineAsIs:
               ret

ToUc           endp

;===============================================================
; various sorts of trouble

FileTrouble    proc      near
               lea       dx,FileTroubleMsg ; display file trouble
               call      Say
               jmp       Abort
FileTrouble    endp

SyntaxTrouble  proc      near
               lea       dx,BannerMsg
               call      Say
               lea       dx,UsageMsg
               call      Say
               jmp       Abort
SyntaxTrouble  endp

abort          proc      near
                                        ; error exit
               mov       ax, 4c04h      ; ERRORLEVEL = 4
               int       21h            ; DIE
abort          endp

;===============================================================
