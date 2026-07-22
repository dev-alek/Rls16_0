block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sht-time-check.p $
$Archive: gbl/sht-time-check.p $

Проверки при изменение времени открытия и закрытия закрытой смены

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
define input parameter p-start-date as date no-undo.
define input parameter p-end-date as date no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sht-time-check.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sht-time-check.p $":U .
define variable vss-description as character no-undo init "Изменение времени закрытой смены".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable prev-timestamp as decimal no-undo.
define variable next-timestamp as decimal no-undo.
define variable new-start-timestamp as decimal no-undo.
define variable new-end-timestamp as decimal no-undo.

define buffer bf_curr-shift-obj for ub.shift-obj.
define buffer bf_prev-shift-obj for ub.shift-obj.
define buffer bf_next-shift-obj for ub.shift-obj.

find first bf_curr-shift-obj no-lock
    where bf_curr-shift-obj.obj-type = p-obj-type
    and bf_curr-shift-obj.obj-code = p-obj-code
    and bf_curr-shift-obj.shift-date = p-shift-date
    and bf_curr-shift-obj.shift-num = p-shift-num
    no-error.
if not available bf_curr-shift-obj then
    return error subst("Смена &1 &2 на объекте &3 &4 не найдена", p-shift-date, p-shift-num, p-obj-type, p-obj-code).
if bf_curr-shift-obj.status_ <> {&sht-closed} then
    return error "Время смены можно менять только при статусе <Закрыта>".

/* ищем предыдущую смену */
find first bf_prev-shift-obj no-lock
    where recid(bf_prev-shift-obj) = recid(bf_curr-shift-obj).
find prev bf_prev-shift-obj no-lock
    where bf_prev-shift-obj.obj-type = p-obj-type
    and bf_prev-shift-obj.obj-code = p-obj-code
    no-error.

/* ищем следующую смену */
find first bf_next-shift-obj no-lock
    where recid(bf_next-shift-obj) = recid(bf_curr-shift-obj).
find next bf_next-shift-obj no-lock
    where bf_next-shift-obj.obj-type = p-obj-type
    and bf_next-shift-obj.obj-code = p-obj-code
    and bf_next-shift-obj.open-date <> ?
    no-error.

if p-start-date >= p-end-date AND p-start-time >= p-end-time then
    return error "Новое время открытия смены должно быть меньше закрытия".

assign
    new-start-timestamp = int(bf_curr-shift-obj.open-date) * 60 * 60 * 60 * 24 + p-start-time
    new-end-timestamp = int(if bf_curr-shift-obj.close-date <> ? then bf_curr-shift-obj.close-date else p-shift-date) * 60 * 60 * 60 * 24 + p-end-time
    prev-timestamp = int(bf_prev-shift-obj.close-date) * 60 * 60 * 60 * 24 + bf_prev-shift-obj.close-time when available bf_prev-shift-obj
    next-timestamp = int(bf_next-shift-obj.open-date) * 60 * 60 * 60 * 24 + bf_next-shift-obj.open-time when available bf_next-shift-obj
.

if available bf_next-shift-obj and new-end-timestamp >= next-timestamp then
    return error "Время открытия смены должно быть больше времени закрытия предыдущей смены".
if available bf_prev-shift-obj and new-start-timestamp <= prev-timestamp then
    return error "Время закрытия смены должно быть меньше времени открытия следующей смены".
