block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер записи истории

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/31/05
Author: Bakhtadze Natalya
Creation date: 08/31/05

*/
TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-prt.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер записи истории ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-gds-prt.node-code
                         , ub.c-gds-prt.corr-user-db-num
                         , ub.c-gds-prt.chip-num
                         ) " }

{ cmp/trg-def.i }

on write of ub.c-gds-prt override do: end.
define buffer buf_c-gds-prt for ub.c-gds-prt.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*флаги изменения справочников групп шкал
  */
  if (ub.c-gds-prt.corr-user-db-num = 0
      or
      ub.c-gds-prt.corr-user-db-num = g#db-num)
  and ub.c-gds-prt.node-code <> 0
  then do:
    /*запишем это к корневой записи*/
    find last buf_c-gds-prt where
          buf_c-gds-prt.node-code = 0
      AND buf_c-gds-prt.corr-user-db-num = ub.c-gds-prt.corr-user-db-num no-error.
    if not available buf_c-gds-prt then do:
      create buf_c-gds-prt.
    end.
    buffer-copy
    ub.c-gds-prt
    except
    node-code
    to buf_c-gds-prt
    assign
    buf_c-gds-prt.node-code = 0
    .
  end.

  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  then do:
    run str/callnews.p
      (input {&table_c-gds-prt}
      ,input (buffer ub.c-gds-prt:handle)
      ).
 end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-gds-prt}
        , input ( buffer ub.c-gds-prt:handle )
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