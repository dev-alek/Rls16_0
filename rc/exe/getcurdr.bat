@echo off
echo Full path to getcurdr.exe :
echo %1
echo Process id:
echo %2
echo Output file:
echo %3
%1\getcurdr.exe %2 %3
rem Uncomment next line for debug
rem pause
exit