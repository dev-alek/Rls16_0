block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sht-set-time.p $
$Archive: gbl/sht-set-time.p $

Изменение времени закрытой смены

Автор: Харитонов Владимир Александрович
Дата создания: 11/06/13
Author: KHaritonov Vladimir
Creation date: 11/06/13

*/

define input parameter p-shift-date as date no-undo.
define input parameter p-shift-num as integer no-undo.
define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-start-time as integer no-undo.
define input parameter p-end-time as integer no-undo.

find first ub.shift-obj exclusive-lock
    where ub.shift-obj.obj-type = p-obj-type
    and ub.shift-obj.obj-code = p-obj-code
    and ub.shift-obj.shift-date = p-shift-date
    and ub.shift-obj.shift-num = p-shift-num
    no-error.
if not available ub.shift-obj then
    return error subst("Смена &1 &2 на объекте &3 &4 не найдена", p-shift-date, p-shift-num, p-obj-type, p-obj-code).

/* если ничего не поменялось, то выход */
if ub.shift-obj.open-time = p-start-time and ub.shift-obj.close-time = p-end-time then
    return.    
    
assign
    ub.shift-obj.open-time = p-start-time
    ub.shift-obj.close-time = p-end-time
.

release ub.shift-obj no-error.

if error-status:error then
    return error return-value.