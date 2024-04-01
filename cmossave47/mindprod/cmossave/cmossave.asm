               page      60,132
NAME           cmossave
               title     CMOSSave Save CMOS to a file on disk or floppy
Comment |
        Version 4.6 by Roedy Green
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

Version History:

 1.0 1991-09-07 released to BIX
 1.1 1991-09-18 released to BIX
                added special check for small 64 character CMOSes.
 1.2 1991-09-19 fix spelling errors
                use CMOS.SAV instead of MyCMOS.SAV in examples
 1.3 1991-09-20 now consider fewer bytes volatile, restore more stuff.
                hints in docs about clearing CMOS.
 1.4 1991-09-21 now consider flags Status register C, offset 0C as volatile.
                fixes false alarms.
 1.5 1994-06-01 change of address and phone number
                address now appears in the banner.
 1.6 1994-08-29 more information about how CMOS bits are used.
 2.0 1994-10-01 easier configuration of CHKCMOS volatile bytes.
                smarter bat files.
                docs on different ways to use.
 2.2 1995-04-16 docs on use before experimentation
 2.3 1995-07-24 add 3F as volatile byte.  PCI Pentiums are volatile.
 2.4 1995-08-07 add /Q switch to suppress banners, only complain
                presume installation done to C:\CMP and that files saved there too.
 2.5 1996-01-27 better documentation
 2.6 1996-06-03 better documentation. Win 95 explanations.
 2.7 1996-08-19 treat hex 3F differently in CMOSRest and CMOSChk
 2.8 1996-10-23 POB in Quathiaski address.  Back to C:\SAFE as presumed directory
                lower cost $10, combined site licence.
 2.9 1996-11-12 fix missing com files.
 3.0 1997-07-08 notes on Y2K checking
                notes on separate rescue diskettes.
 3.1 1998-10-23 new address
                Win98 ok note.
 3.2 1998-11-07 slight changes to visuals to conform with standard.
                embed Barker address
 3.3 1999-10-04 document problems with NT
                CMOSREST now does a read to verify that the restore succeeded.
 3.4 2000-05-10 also treat byte 38 as volatile.
 3.5 2001-01-05 also treat byte 30 as volatile at request of Sony.
 3.6 2001-01-08 major simplification to bat files.
 3.7 2001-01-08 treat 0A as volatile for cmoschk.
 3.8 2002-02-15 new mailing address
 3.9 2006-02-05 different pad directories
                explanation of extended CMOS
 4.0 2008-01-02 add PAD, icon, renaming.
 4.1 2008-09-21 clarify use of standand and extended CMOS in docs.
 4.3 2009-03-10 provide ANT build
                refactor into three separate programs with common includes.
                remove all BAT files.
                remove references to BAT files and automatic mode from documentation.
                more information on use with Vista/XP
 4.4 2009-08-05 make offsets 40, 41 and 42 volatile
 4.5 2009-08-11 fix bug in cmoschk that was making it misidentify volatile bytes. Introduced by recent code reordering.
 4.6 2009-08-20 refactor
 4.7 2012-11-25 minor changes to make compile
*/
How to Assemble
***************

Use the ANT script or

to assemble with MASM 6.0 use:

ml.exe /AT /c /Fl /Zf cmossave.asm
link.exe /TINY /MAP cmossave.obj,cmossave.com,cmossave.map;

to assemble with OPTASM use:
optasm   cmossave.asm,cmossave.obj,cmossave.lst/L/N/G/S
olink    cmossave.obj,cmossave.com,/MAP/TINY;

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
               db        '°±²Û CMOSSave 4.7 Û²±°',13d,10d
               db        13d,10d
               db        'Saves contents of CMOS to a file on hard disk or floppy.',13,10
               db        'Copyright: (c) 1991-2014 Roedy Green, Canadian Mind Products',13,10
               db        '#101 - 2536 Wark Street, Victoria, BC Canada V8T 4G8',13,10
               db        'tel:(250) 361-9093   mailto:roedyg@mindprod.com   http://mindprod.com',13,10
               db        'Freeware to freely distribute and use for any purpose except military.',13,10
               db        13,10
               db        '$'

UsageMsg       db        '°±²Û Error Û²±°',7,13,10
               db        'Insert a formatted diskette.',13,10
               db        'then try:',13,10
               db        'CMOSSave A:\CMOS.Sav',13,10
               db        'or if want to save on hard disk try:',13,10
               db        'CMOSSave C:\SAFE\CMOS.Sav',13,10
               db        'CMOSSave is a DOS utility, and thus can only use short 8.3 file names',13,10
               db        'Read CMOS.TXT to find how to use it properly.',13,10
               db        '$'

FileTroubleMsg db        '°±²Û Error Û²±°',7,13,10
               db        'Cannot create the disk file.',13,10
               db        '$'

WorkedMsg      db        'CMOS successfully saved',13,10
               db        '$'

ParmIndex      dw        0

Filename       db        64 dup (0)
                                        ; asciiz filename

SlashQuiet     db        0
                                        ; -1 means quiet mode /Q

CMOSSize       db        0
                                        ; size of cmos in bytes

CMOSBuff       db        128 dup(0)     ; buffer to hold CMOS contents.

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

               call      GetCMOS        ; fetch CMOS to buffer

               call      WriteCMOSToFile ; write CMOS contents to file
                                        ; we save all CMOS bytes, even the volatile ones.

               lea       dx,WorkedMsg   ; crow about success
               call      Say

Done:
               mov       ax,4c00h
               int       21h            ;normal termination

_Start         endp

;===============================================================

GetCMOS        proc      near

; Get 128 byte contents of CMOS into a buffer.

               mov       cx,128         ; count of times through loop
               lea       bx,CMOSBuff    ; where to put the contents
               sub       al,al          ; start offset in CMOS
GetLoop:
               call      PeekCmos       ; al=offset ah=contents
               mov       byte ptr[bx],ah
               inc       al
               inc       bx
               loop      GetLoop
               ret

GetCMOS        endp

;===============================================================

WriteCMOSToFile proc     near

;       Create a file; write CMOS to it

               lea       dx,FileName    ; DS:DX point to file
               xor       cx,cx          ; CX=0 is attribute
               mov       ah,03ch        ; DOS create function
               int       21h
               jc        FileTrouble
               mov       bx,ax          ; SAVE HANDLE
               mov       CX,128         ; write 128 bytes
               lea       dx,CMOSBuff    ; buffer address
               mov       ah,40h         ; DOS write
               int       21h
               jc        FileTrouble
               cmp       ax,128
               jne       FileTrouble
               mov       ah,3eh         ; DOS close
               int       21h
               jc        FileTrouble
               ret

WriteCMOSToFile endp

;===============================================================

include        cmosinc0.asm

;===============================================================

CODE           ends                     ; end of code segment
               end       _Start
