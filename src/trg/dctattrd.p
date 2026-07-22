block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление для таблицы атрибуты типов дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-card-type-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление для таблицы атрибуты типов дисконтных карт".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.dis-card-type-attr.emitent-host-code
                         , ub.dis-card-type-attr.type
                         , ub.dis-card-type-attr.host-code
                        , ub.dis-card-type-attr.obj-type
                        , ub.dis-card-type-attr.obj-code
                        , ub.dis-card-type-attr.attr-code
                         ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-dis-card-type-attr for ub.c-dis-card-type-attr.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card-type-attr.
  buffer-copy ub.dis-card-type-attr to buf_c-dis-card-type-attr
  assign
  buf_c-dis-card-type-attr.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-card-type-attr.corr-time          = v-time
  buf_c-dis-card-type-attr.corr-user-db-num   = g#db-num
  buf_c-dis-card-type-attr.corr-user-name     = g#userid
  buf_c-dis-card-type-attr.corr-date          = v-date
  .

  create buf_c-dis-card-type.
  buffer-copy buf_c-dis-card-type-attr to buf_c-dis-card-type
  assign
  buf_c-dis-card-type.action = integer({&hn-delete})
  buf_c-dis-card-type.subject = {&table_dis-card-type-attr}
  .
  /*cmd-del.p не вызываем, потому что работаем через cmd-bush*/
end.