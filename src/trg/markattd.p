block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы marking-attr

Автор: 
Дата создания: 
Author: Aleksandr Rostovtsev
Creation date: 10/10/2023

*/

&scoped-define main-tbl marking-attr
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления marking-attr".


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if {&main-tbl}.attr-code = "notOnlineCheck" then
  do:
    { trg/trghistnws.i
      &hist = yes
      &seqnamehist = "s-c-mark-attr-chip-num"
      &del  = yes
    }
  end.
end. /* main-block */
