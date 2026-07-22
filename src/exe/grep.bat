@echo off
rem %1 search string in file
echo Execute command file
echo %0
echo Full path to grep program
echo %1
echo Search string
echo %2
echo Search in file
echo %3
echo Output file
echo %4
rem convert codepage 1251 to 866 without prompt
%1\grep.exe -F -n %2 %3 >%4
rem Uncomment next line for debug
rem pause
exit