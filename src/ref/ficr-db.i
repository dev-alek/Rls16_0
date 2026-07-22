/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка для ФБ

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 10/17/03 5:25

*/
procedure current-db :
 do
 on error undo, return error return-value
 :

define input parameter  p-host-code as integer no-undo . /* проверяемая фирма */
define input parameter  c-host-code as integer no-undo . /* текущая     фирма */
define output parameter ret         as logical no-undo . /* no - фирма не с текущей БД */

define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .

find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .

find first ub.sysconf where ub.sysconf.host-code = p-host-code no-lock no-error .
if not( ub.sysconf.firm-db-num = v-current-db or
        ub.sysconf.firm-db-num = 0 )
  then do:
  ret = false .
  message "Нельзя добавлять запись в  справочнике  для фирмы с не главной БД !!!" view-as alert-box information .
  return .
end.


 end. /* do */
end procedure. /* current-db */


procedure ver-db :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter  c-host-code as integer no-undo . /* текущая     фирма */
define input parameter  par-ver-db  as integer no-undo . /* проверяемый номер базы */
define input parameter  p-mess as logical no-undo .
define output parameter ret         as logical no-undo . /* no - фирма не с текущей БД */

define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .

find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
/*
message
c-host-code
par-ver-db
v-current-db
.
*/

if not( par-ver-db = v-current-db or
        par-ver-db = 0 )
  then do:
  ret = false .
  if p-mess = true then message "База , на которой мы работаем не является главной базой данных текущей фирмы!!!" view-as alert-box information .
  return .
end.

 end. /* do */
end procedure. /* ver-db */

/* $Workfile$ e n d */