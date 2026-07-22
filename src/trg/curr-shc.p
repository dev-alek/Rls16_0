block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ЭТО НЕ ТРИГГЕР - ЭТО СОЗДАНИЕ curr-shop при рождении магазина

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter varobj-code like ub.shop.obj-code no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "СОЗДАНИЕ curr-shop при рождении магазина".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.


find first ub.clients No-LOCK WHERE
           ub.clients.obj-type = {&shop} and
           ub.clients.obj-code = varobj-code no-error .

if not available ub.clients then do:
   message
   vss-workfile vss-revision vss-description skip
   "Не найден магазин с кодом " varobj-code
   view-as alert-box error .
   return error.
end.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run cur-time in this-procedure ( output v-today
                                  , output v-time
                                ).
  create ub.curr-shop.
  assign
  ub.curr-shop.curr-code  = 0
  ub.curr-shop.exch-date  = v-today
  ub.curr-shop.exch-rate  = 1
  ub.curr-shop.exch-scale = 1
  ub.curr-shop.exch-time  = v-time
  ub.curr-shop.obj-code   = varobj-code
  ub.curr-shop.obj-type   = {&shop}
  .

  if not can-find(first ub.curr-shop no-lock where
                        ub.curr-shop.obj-type = {&shop}
                    AND ub.curr-shop.obj-code = varobj-code
                    AND ub.curr-shop.exch-date = 04/01/1990
                    AND ub.curr-shop.curr-code = 0
                    AND ub.curr-shop.exch-time = 0) then do:
    create ub.curr-shop.
    assign
    ub.curr-shop.curr-code  = 0
    ub.curr-shop.exch-date  = 04/01/1990
    ub.curr-shop.exch-rate  = 1
    ub.curr-shop.exch-scale = 1
    ub.curr-shop.exch-time  = 0
    ub.curr-shop.obj-code   = varobj-code
    ub.curr-shop.obj-type   = {&shop}
    .
  end.
end.
