@echo off
rem %1 full path to print file
echo Full path to print file
echo %1
echo Temporary file-name for internal operations
echo %2
echo Director where rpt-view.bat resides
echo %3
echo Delete all previos copies of report
echo del %4\p?????r.tmp
del %4\p?????r.tmp
echo Make a copy of report
copy %1 %2
echo Start viewer
start %3\ibsview.exe %2
echo Close session
exit