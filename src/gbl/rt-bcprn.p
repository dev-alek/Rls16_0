block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-bcprn.p $
$Archive: gbl/rt-bcprn.p $

Радиотерминал. Проверка цены. Пометить штрих-код для печати

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/22/05

*/

define input  parameter p-user-id  as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-b-code   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-bcprn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-bcprn.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Проверка цены. Пометить штрих-код для печати".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define buffer buf_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:
  create buf_batchprocess .

  define variable v-btpr_upd-today as date      no-undo .
  define variable v-btpr_upd-time  as integer   no-undo .

  run cur-time in this-procedure
    (output v-btpr_upd-today
    ,output v-btpr_upd-time
    ).
  assign
    buf_batchprocess.bp_type        = {&btpr-type-rt-bcprint}
    buf_batchprocess.bp_status      = {&btpr-normal}
    buf_batchprocess.batchprocess#  = next-value(s-btpr, {&db-name_schema})
    buf_batchprocess.user_id        = p-user-id
    buf_batchprocess.bp_sysdate     = v-btpr_upd-today
    buf_batchprocess.bp_systime     = string( v-btpr_upd-time, 'hh:mm' )
    buf_batchprocess.bp_systimeint  = v-btpr_upd-time
    buf_batchprocess.charkey_one    = p-user-id
    buf_batchprocess.charkey_two    = p-obj-type
    buf_batchprocess.key#_one       = p-obj-code
    buf_batchprocess.key#_two       = p-b-code
  .
end.