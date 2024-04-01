               page      60,132
NAME           cmosrest
               title     CMOSChk Check that CMOS is relatively unmodified since last use of CMOSSave
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

CMOS Usage - see also CMOS.OFS

How to Assemble
***************

use the ANT script or

to assemble with MASM 6.0 use:
ml.exe /AT /c /Fl  /Zf cmoschk.asm
link.exe /TINY /MAP cmoschk.Obj,cmoschk.com,cmoschk.map;
copy cmos.com cmossave.com

to assemble with OPTASM use:
Optasm   cmoschk.asm,cmoschk.obj,cmoschk.lst/L/N/G/S
OLINK    cmoschk.obj,cmoschk.com,/MAP/TINY;

Register Conventions
********************

Subroutines may trash all registers except those explicity
documented as input or output.

|                                        ; end of comment

;==============================================================

stack          segment   stack          ; keep MS link happy by providing null stack
stack          ends

CODE           segment   PARA           ; start off in code.

;==============================================================

data           segment   byte           ; provide a separate DATA segment
                                        ; actually all come after the code
;==============================================================
;  V A R I A B L E S

BannerMsg      label     byte
               db        '°±²Û CMOSChk 4.6 Û²±°',13d,10d
               db        13d,10d
               db        'Ensures CMOS not corrupted or changed.',13,10
               db        'Copyright: (c) 1991-2014 Roedy Green, Canadian Mind Products.',13,10
               db        '#101 - 2536 Wark Street, Victoria, BC Canada V8T 4G8',13,10
               db        'tel:(250) 361-9093   mailto:roedyg@mindprod.com   http://mindprod.com',13,10
               db        'Freeware to freely distribute and use for any purpose except military.',13,10
               db        13,10
               db        '$'

UsageMsg       db        '°±²Û Error Û²±°',7,13,10
               db        'Insert the diskette you used for CMOSSave.',13,10
               db        'then try:',13,10
               db        'CMOSChk A:\CMOS.Sav',13,10
               db        'or if you have the file on hard disk try:',13,10
               db        'CMOSChk C:\SAFE\CMOS.Sav',13,10
               db        'CMOSChk is a DOS utility, and thus can only use short 8.3 file names',13,10
               db        'Read CMOS.TXT to find how to use it properly.',13,10
               db        '$'

FileTroubleMsg db        '°±²Û Error Û²±°',7,13,10
               db        'Cannot find/read the disk file.',13,10
               db        '$'

MatchTroubleMsg db       '°±²Û Error Û²±°',7,13,10
               db        'CMOS has been corrupted! at hex offset:value:expected ',13,10
               db        '$'

ColonMsg       db        ':','$'

NextTripleMsg  db        13,10,'$'

WorkedMsg      db        'CMOS is OK, i.e. unchanged since the last CMOSSave.',13,10
               db        '$'

ParmIndex      dw        0

Filename       db        64 dup (0)     ; asciiz filename

SlashQuiet     db        0              ; -1 means quiet mode /Q

CMOSSize       db        0              ; size of cmos in bytes

CMOSBuff       db        128 dup(0)     ; buffer to hold CMOS contents.

;       Add to this list if you need more volatile bytes.

;       Remember the trailing h.
;       CmosRest Volatile bytes are not restored.  CmosChk volatile bytes are not checked.

;       0..0A are volatile
;       00ch is status byte
;       032h is century byte
;       038h is volatile why?
;       03Ah is Sony PNP BIOS bit
;       03Fh is Pentium volatile byte
;       040 to 042 are chip maker proprietary bytes.

;  CMOSCHK list, differs from CMSREST  list.
VolatileList   db        0ah,0ch,032h,038h,03Ah,03Fh,040h,041h,042h

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

               call      CompareCMOS    ; compare CMOS with buffer

               lea       dx,WorkedMsg   ; crow about success
               call      SayQ

Done:
               mov       ax,4c00h
               int       21h            ;normal termination

_Start         endp

;===============================================================

include        cmosinc0.asm
include        cmosinc1.asm

;===============================================================

CODE           ends                     ; end of code segment
               end       _Start
