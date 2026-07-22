block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ВАРИАНТЫ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/


TRIGGER PROCEDURE FOR DELETE OF ub.var-deliv-gr-per-val.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ВАРИАНТЫ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5', ub.c-var-deliv-gr-per-val.deliv-type-code,
                                                ub.c-var-deliv-gr-per-val.deliv-subj-code,
                                              ub.c-var-deliv-gr-per-val.obj-type,
                                              ub.c-var-deliv-gr-per-val.obj-code,
                                              ub.c-var-deliv-gr-per-val.gr-per-val-code) " }

{ cmp/trg-def.i }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ВАРИАНТА ДОСТАВКИ ПО СРОКАМ ГОДНОСТИ"
  view-as alert-box error .
  undo main-block, return error .


end.