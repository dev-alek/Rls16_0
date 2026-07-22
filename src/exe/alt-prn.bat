@echo off
rem %1 full path to print file
echo Full path to print file
echo %1
echo Temporary file-name for internal operations
echo %2
echo Director where rpt-view.bat resides
echo %3
copy %1 %2
rem convert codepage 1251 to 866 without prompt
%3\2dos %2
copy /b %2 prn
del %2
rem Uncomment next line for debug
rem pause
exit