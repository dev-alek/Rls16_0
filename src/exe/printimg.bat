@echo off

SET ImageViewer1="C:\Program Files\Windows NT\Accessories\ImageVue\KodakPrv.exe"
rem SET ImageViewer2="C:\Program Files\IrfanView\i_view32.exe"

echo Full path to file with list of printed docs
echo %1
echo Printer name
echo %2

for /F "delims=|" %%c in (%1) do %ImageViewer1% /p "%%c"
rem for /F "delims=|" %%c in (%1) do %ImageViewer2% "%%c" /print
rem Uncomment next line for debug
rem pause
del %1
exit