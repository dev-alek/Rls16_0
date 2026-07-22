/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка, что утилита nds22.p для BTS-2056 еще не запускалась и не ТБД.

Автор: Ростовцев А.М.
Дата создания: 30.10.2025
Author: 
Creation date: 

*/

define output parameter oRun as logical no-undo.

{ cmp/str-glbl.i }
define buffer buf_code for ub.code.
define buffer buf_sys-ctrl for ub.sys-ctrl.

find first buf_sys-ctrl no-lock.

if buf_sys-ctrl.db-num = 0 then
do:
  oRun = no.  
end.
else
do:
  oRun = not can-find(first buf_code where
                            buf_code.parent = substitute("RunUtils&1&2",{&delim-par}, buf_sys-ctrl.db-num)
                        and buf_code.code = "nds22").
end.