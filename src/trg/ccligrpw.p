block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ГРУППЫ КЛИЕНТОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 24/08/04
Author: Bakhtadze Natalya
Creation date: 24/08/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cli-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ГРУППЫ КЛИЕНТОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                           ,  ub.c-cli-grp.node-code
                           , ub.c-cli-grp.corr-user-db-num
                           , ub.c-cli-grp.chip-num
                           ) " }
{ cmp/trg-def.i }

define buffer buf_cli-grp for ub.cli-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  then do:
    run str/callnews.p
      (input "c-cli-grp"
      ,input (buffer ub.c-cli-grp:handle)
      ).
  end.
end.