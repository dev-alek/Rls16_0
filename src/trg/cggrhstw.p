block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на главную запись истории ГРУПП ТОВАРОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/04
Author: Bakhtadze Natalya
Creation date: 08/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-grp-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на главную запись истории ГРУПП ТОВАРОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           ,  ub.c-gds-grp-hist.node-code
                           , ub.c-gds-grp-hist.corr-user-db-num
                           , ub.c-gds-grp-hist.chip-num
                           , ub.c-gds-grp-hist.host-code
                           , ub.c-gds-grp-hist.obj-type
                           , ub.c-gds-grp-hist.obj-code
                           , ub.c-gds-grp-hist.subject
                           ) " }
{ cmp/trg-def.i }
on write of ub.c-gds-grp-hist override do: end.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  /*флаги изменения справочников групп товаров
    эта запись не идет по новостям
  */
  if ub.c-gds-grp-hist.subject = {&table_gds-grp}
  and (ub.c-gds-grp-hist.corr-user-db-num = 0
      or
      ub.c-gds-grp-hist.corr-user-db-num = g#db-num)
  and ub.c-gds-grp-hist.node-code <> 0
  then do:
    /*запишем это к корневой записи*/
    find last buf_c-gds-grp-hist where
          buf_c-gds-grp-hist.node-code = 0
      AND buf_c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-hist.corr-user-db-num
      AND buf_c-gds-grp-hist.host-code = 0
      AND buf_c-gds-grp-hist.obj-type = '':U
      AND buf_c-gds-grp-hist.obj-code = 0
      AND buf_c-gds-grp-hist.subject = ub.c-gds-grp-hist.subject no-error.
    if not available buf_c-gds-grp-hist then do:
      create buf_c-gds-grp-hist.
      assign
      buf_c-gds-grp-hist.host-code = 0
      buf_c-gds-grp-hist.obj-type = '':U
      buf_c-gds-grp-hist.obj-code = 0
      buf_c-gds-grp-hist.subject = ub.c-gds-grp-hist.subject
      .
    end.
    buffer-copy
    ub.c-gds-grp-hist
    except
    node-code
    host-code
    obj-type
    obj-code
    to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code = 0
    .
  end.

  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  then do:
    /*пока все таблицы которые охватывает c-gds-grp-hist ходят только из ГБД*/
    /*c-gds-grp c-gds-grp-attr c-gds-grp-obj c-tax-rate-gds-grp*/



    run str/callnews.p
      (input "c-gds-grp-hist"
      ,input (buffer ub.c-gds-grp-hist:handle)
      ).
 end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-gds-grp-hist}
        , input ( buffer ub.c-gds-grp-hist:handle )
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