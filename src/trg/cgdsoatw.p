block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории gds-obj-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории АТРИБУТА ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        , ub.c-gds-obj-attr.obj-type
                        , ub.c-gds-obj-attr.obj-code
                        , ub.c-gds-obj-attr.gds-code
                        , ub.c-gds-obj-attr.attr-code
                        , ub.c-gds-obj-attr.corr-user-db-num
                        , ub.c-gds-obj-attr.chip-num
                        ) " }
{ cmp/trg-def.i }
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_gds-obj-attr for ub.gds-obj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   { gbl/objdbnum.i ub.c-gds-obj-attr.obj-type ub.c-gds-obj-attr.obj-code v-db-num }
   if not g#news and g#db-num <> v-db-num and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ИСТОРИИ АТРИБУТА НА ОБЪЕКТЕ в БД, отличной от БД объекта, если она не ГБД" skip
      "Номер текущей БД" g#db-num "Номер БД объекта" v-db-num
      view-as alert-box error .
      undo, return error .
    end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and g#db-num = 0
      and ub.c-gds-obj-attr.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and g#db-num > 0
      and ub.c-gds-obj-attr.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
      run str/callnews.p
        (input {&table_c-gds-obj-attr}
    ,input (buffer ub.c-gds-obj-attr:handle)
    ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-gds-obj-attr}
        , input ( buffer ub.c-gds-obj-attr:handle )
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