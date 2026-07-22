@echo off
echo Full path to compinfo.bat :
echo %1
echo Output information to file :
echo %2
echo Information type :
echo %3
echo ################################################################################ >>%2
echo Общая информация о компьютере >>%2
%1\compinfo.exe >>%2
echo ################################################################################ >>%2
echo Подключенные диски >>%2
net use | %1\oem2ansi >>%2
echo ################################################################################ >>%2
echo Сетевая статистика >>%2
net statistics server | %1\oem2ansi >>%2
net statistics workstation | %1\oem2ansi >>%2
echo ################################################################################ >>%2
echo Конфигурация сетевых интерфейсов >>%2
ipconfig /all | %1\oem2ansi >>%2
echo ################################################################################ >>%2
echo Таблица маршрутизации >>%2
netstat -r | %1\oem2ansi >>%2
if "%3"=="common" goto skipdtl
echo "Сбор подробной информации" | %1\ansi2oem
echo "Это может занять несколько минут" | %1\ansi2oem
echo "Пожалуйста, не закрывайте это окно" | %1\ansi2oem
echo ################################################################################ >>%2
echo Информация об операционной системе >>%2
cscript %1\compinfo.vbs | %1\oem2ansi >>%2
:skipdtl
rem Uncomment next line for debug
rem pause
exit