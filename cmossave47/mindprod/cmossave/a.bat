::REM A.bat assemble *.COM file using Microsoft MASM. Used in form A MYPROG

REM configure to where assembler and linker are. Make sure we use the old MASM ML.exe 6 and LINK 5.6

rem You must have ml6.exe, ml.err (the assembler) and link56.exe on the path. -->" );
rem You can get ml.exe 6.15 from http://download.microsoft.com/download/vb60ent/Update/6/W9X2KXP/EN-US/vcpp5.exe extract with WinZip.
rem You can get link.exe 5.6 from http://download.microsoft.com/download/vc15/Update/1/W98/EN-US/Lnk563.exe and extract with WinZip.
rem and rename them to ml6.exe and link56.exe so they will not be confused with ml.exe 11.0 and link.exe 11.0 used by C/C++

rem 16-bit COM file generated here will not work under Windows 7 64-bit.
echo assembling %1.asm

IF NOT EXIST %1.ASM GOTO DONE

rem assemble with MASM 6, If you use  other versions, you will have to adjust source.
rem /AT Enable tiny model (.COM file)
rem /c Assemble without linking.
rem /Fl[file] Generate listing
rem /Sf generate first pass listing.
rem /Zf Make all symbols public
rem /Zm Enable MASM 5.10 compatibility.
rem for other options type ml6.exe /?
rem will not work with more recent ml since contains GROUP directives and uses tiny model.

ml6.exe  /AT /c /Fl /Zf /Zm %1.Asm %2 %3 %4 %5

IF  ERRORLEVEL 1 GOTO GIVEUP

link56.exe /MAP /TINY %1.obj,%1.com,%1.map,,,

::REM DEL     %1.LST
:GiveUp
del %1.OBJ
:Done

rem -30-
