::REM O.bat assemble *.COM file using Optasm/Olink. Used in form O MYPROG /DXX=YYY
REM adjust to where your OPTASM and OLINK are.
IF NOT EXIST %1.ASM GOTO DONE
"F:\Program Files (x86)\optasm\optasm.exe"   %1.Asm,%1.Obj,%1.Lst/L/N/G/S %2 %3 %4 %5
rem /L  Listing
rem /N  No symbol table in listing
rem /G  Globalize all symbols
rem /S  Segments in defined order
rem for other options type OPTASM /help

IF ERRORLEVEL 1 GOTO GIVEUP

rem OLINK is stripped down OPTLINKR.
rem F:\Program Files\optlink\OPTLINKR.exe    %1.Obj,%1.COM,/MAP/TINY;
"F:\Program Files (x86)\optasm\olink.exe"  /MAP/TINY  %1.Obj,%1.exe,%1.map;
rem /MAP - list of symbols
rem /TINY - 64K COM
IF ERRORLEVEL 1 GOTO GIVEUP
::REM DEL     %1.LST
:GiveUp
del %1.OBJ
del %1.PSS
:Done
