               page      60,132
NAME           cmosrest
TITLE          cmosrest  Restore CMOS from a file on disk or floppy
Comment |
        Version 4.7 by Roedy Green
        works with MASM 6.0 and Optasm

Note that we never compute or verify a checksum.  Every vendor computes
may compute it a slightly different way.

To come:
  /V:xx - additional volatile byte

See CMOS.TXT for details on use.

  USAGE:

Examples:
*********

CMOSSave A:\MyCMOS.Sav /Q

CMOSRest A:\MyCMOS.Sav /Q

CMOSChk  A:\ByCMOS.Sav /Q

These are DOS utilities and thus can only use short 8.3 file names.

Syntax errors or missing file trouble generates an ERRORLEVEL 4.
CMOSChk generates an ERRORLEVEL 1 if the CMOS has changed since
the CMOSSave was done.

Please report bugs and problems to:

Roedy Green
Canadian Mind Products
#101 - 2536 Wark Street
Victoria, BC Canada V8T 4G8
tel:(250) 361-9093
mailto:roedyg@mindprod.com
http://mindprod.com

Version History
***************

see cmossave.asm

CMOS Usage - see also cmosofs.txt

How to Assemble
***************
Use the ANT script or

to assemble with MASM 6.0 use:
ml.exe /AT /c /Fl /Zf cmosrest.asm
link.exe /TINY /MAP cmosrest.obj,cmosrest.com,cmosrest.map;

to assemble with OPTASM use:
optasm   cmossave.asm,cmossave.obj,cmossave.lst/L/N/G/S
olink    cmosrest.obj,cmosrest.com,/MAP/TINY;

Register Conventions
********************

Subroutines may trash all registers except those explicity
documented as input or output.

|                                        ; end of comment

;==============================================================
               .286
               .model    tiny
stack          segment   stack          ; keep MS link happy by providing null stack
stack          ends

CODE           segment   PARA           ; start off in code.

;==============================================================

data           segment   byte           ; provide a separate DATA segment
                                        ; actually all come after the code
;==============================================================
;  V A R I A B L E S

BannerMsg      label     byte
               db        '°±²Û CMOSRest 4.7 Û²±°',13d,10d
               db        13d,10d
               db        'Restores CMOS from a CMOSSave file on hard disk or floppy.',13,10
               db        'Copyright: (c) 1991-2014 Roedy Green, Canadian Mind Products.',13,10
               db        '#101 - 2536 Wark Street, Victoria, BC Canada V8T 4G8',13,10
               db        'tel:(250) 361-9093   mailto:roedyg@mindprod.com   http://mindprod.com',13,10
               db        'Freeware to freely distribute and use for any purpose except military.',13,10
               db        13,10
               db        '$'

UsageMsg       db        '°±²Û Error Û²±°',13,10
               db        'Insert the diskette you used for CMOSSave.',13,10
               db        'then try:',13,10
               db        'CMOSRest A:\CMOS.Sav',13,10
               db        'or if the file is on hard disk try:',13,10
               db        'CMOSRest C:\SAFE\CMOS.Sav',13,10
               db        'CMOSRest is a DOS utility, and thus can only use short 8.3 file names',13,10
               db        'Read CMOS.TXT to find how to use it properly.',13,10
               db        '$'

FileTroubleMsg db        '°±²Û Error Û²±°',7,13,10
               db        'Cannot find/read the disk file.',13,10
               db        '$'

MatchTroubleMsg db       '°±²Û Error Û²±°',7,13,10
               db        'CMOS restore unsuccessful. CMOS is still corrupted at hex offset:value:expected ',13,10
               db        '$'

ColonMsg       db        ':','$'

NextTripleMsg  db        13,10,'$'

WorkedMsg      db        'CMOS successfully restored',13,10
               db        '$'

ParmIndex      dw        0

Filename       db        64 dup (0)
                                        ; asciiz filename

SlashQuiet     db        0
                                        ; -1 means quiet mode /Q

CMOSSize       db        0
                                        ; size of cmos in bytes

CMOSBuff       db        128 dup(0)     ; buffer to hold CMOS contents.

;       Remember the trailing h.
;       CmosRest wolatile bytes are not restored.  CmosChk volatile bytes are not checked.

;       00ch is status byte
;       032h is century byte

;  CMOSREST list, differs from CMOSCHK  list.

VolatileList   db        0ch,032h

VolatileCount  equ       $-VolatileList

data           ends

com            group     code,data      ; force data segment to go at the end

               assume    CS:com,DS:com,ES:com,SS:com
                                        ; seg regs cover everything
               org       100H           ; in Code segment

;==========================

_Start         proc      near

;       M A I N L I N E   R O U T I N E
               cld
               call      Parse          ; get filename and /Q from command line

               lea       dx,BannerMsg   ; display the banner if no /Q
               call      SayQ

               call      ReadCMOSFromFile ; read CMOS contents from file

               call      CalcCMOSSize   ; it is 64 or 128 bytes long?

               call      PutCMOS        ; store buffer to CMOS

               call      CompareCMOS    ; compare CMOS with buffer

               lea       dx,WorkedMsg   ; crow about success
               call      Say

Done:
               mov       ax,4c00h
               int       21h            ;normal termination

_Start         endp

;===============================================================

PokeCMOS       proc      near

;       Stuffs one byte into cmos.
;       on entry al has offset desired, ah has the value to stuff.
;       Preserves all registers.

;       See page 5-81 IBM AT Tech ref BIOS listing for how to write CMOS
;       We always enable the NMI with bit 7 on.

               push      ax
               cli                      ; disable interrupts
               or        al,80h         ; disable NMI
               out       70h,al         ; output the byte address to CMOS
               jmp       $+2            ; delay, safer than nop

               mov       al,ah          ; get contents
               out       71h,al         ; poke the CMOS byte
               jmp       $+2            ; delay, safer than nop
                                        ; re-enable the NMI
               mov       al,0dh         ; point to battery status register
               out       70h,al         ; leave pointing at a safe r/o register
               sti                      ; restore interrupts
               pop       ax
               ret

PokeCMOS       endp

;===============================================================

PutCMOS        proc      near

;       Put 128-byte contents of buffer into CMOS.
;       do not touch the volatile bytes

               mov       cx,128         ; count of times through loop
               lea       bx,CMOSBuff    ; where to put the contents
               sub       al,al          ; start offset in CMOS
PutLoop:
               call      Volatile       ; test if this is a volatile byte
                                        ; test offset in al
               jc        LeaveItAlone
               mov       ah,byte ptr[bx]
               call      PokeCMOS       ; al=offset ah=contents

LeaveItAlone:
               inc       bx
               inc       al
               loop      PutLoop
               ret

PutCMOS        endp

;===============================================================

include        cmosinc0.asm
include        cmosinc1.asm

;===============================================================

CODE           ends                     ; end of code segment
               end       _Start
