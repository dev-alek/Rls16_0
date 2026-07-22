block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории АТРИБУТОВ ГРУППЫ ТОВАРА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/04
Author: Bakhtadze Natalya
Creation date: 08/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-grp-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории АТРИБУТОВ ГРУППЫ ТОВАРА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           ,  ub.c-gds-grp-attr.node-code
                           ,  ub.c-gds-grp-attr.attr-code
                           ,  ub.c-gds-grp-attr.host-code
                           ,  ub.c-gds-grp-attr.obj-type
                           ,  ub.c-gds-grp-attr.obj-code
                           , ub.c-gds-grp-attr.corr-user-db-num
                           , ub.c-gds-grp-attr.chip-num
                           ) " }
{ cmp/trg-def.i }

define buffer buf_gds-grp for ub.gds-grp.

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
      (input "c-gds-grp-attr"
      ,input (buffer ub.c-gds-grp-attr:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-gds-grp-attr}
        , input ( buffer ub.c-gds-grp-attr:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.