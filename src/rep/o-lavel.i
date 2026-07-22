/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 03/20/03 4:25

*/
find clients where clients.obj-type = {4}.prod-type and
                   clients.obj-code = {4}.prod-code no-lock .
  assign
      gds-zap-unit-base  = {4}.unit-base
      gds-zap-prt-root   = {4}.prt-root
      gds-zap-prod-type  = {4}.prod-type
      gds-zap-prod-code  = {4}.prod-code
      gds-zap-artic      = {4}.artic
      gds-zap-type       = {4}.gds-type
      gds-zap-grp-name   = {4}.grp-name
      gds-zap-b-code     = {4}.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = {4}.engl-name.
  else
      assign gds-zap-gds-name = {4}.gds-name.
  { gbl/gdsbcode.i gds-zap-b-code ? v-bar-code  }
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( {2} )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( {2} ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
/* $Workfile$ e n d */