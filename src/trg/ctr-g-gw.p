block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории НАЛОГОВ ДЛЯ ГРУППЫ ТОВАРОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/04
Author: Bakhtadze Natalya
Creation date: 08/24/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-tax-rate-gds-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории НАЛОГОВ ДЛЯ ГРУПП ТОВАРОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           ,  ub.c-tax-rate-gds-grp.node-code
                           ,  ub.c-tax-rate-gds-grp.tax-code
                           ,  ub.c-tax-rate-gds-grp.host-code
                           ,  ub.c-tax-rate-gds-grp.obj-type
                           ,  ub.c-tax-rate-gds-grp.obj-code
                           ,  ub.c-tax-rate-gds-grp.corr-user-db-num
                           ,  ub.c-tax-rate-gds-grp.chip-num
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
      (input "c-tax-rate-gds-grp"
      ,input (buffer ub.c-tax-rate-gds-grp:handle)
      ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-tax-rate-gds-grp}
        , input ( buffer ub.c-tax-rate-gds-grp:handle )
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