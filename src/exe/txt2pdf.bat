@echo off
echo Full path to text file
echo %1
echo Full path to pdf file
echo %2
echo Directory where txt2pdf.bat resides
echo %3
echo Extra options
echo %4
%3\txt2pdf.exe -d %3\ %4 %1 %2
exit
