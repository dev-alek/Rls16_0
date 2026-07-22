@echo off
echo %1 файл для конвертации
echo %2 файл ошибок
echo %3 временный файл
echo %4 файл после конвертации
echo %5 prowin
echo %6 progress.ini
if "%1"=="" goto ERRORPAR
if "%2"=="" goto ERRORPAR
if "%3"=="" goto ERRORPAR
if "%4"=="" goto ERRORPAR
if "%5"=="" goto ERRORPAR
if "%6"=="" goto ERRORPAR
:prowin
%5 -p convcan1.p -param "%1,%2,%3,%4" -basekey "INI" -ininame %6
if not exist %4 copy nul %4
goto end

:ERRORPAR
echo SYNTAX ERROR!
echo Must be: convimp.bat {conv file} {err file} {temp file} {out file} {exe file} {ini file}
echo for example: convimp.bat C:\filecnv.txt C:\filecnv.err C:\filecnv.tmp C:\filecnv.out C:\dlc82c\prowin.exe C:\progress.ini
goto end

:end
echo on