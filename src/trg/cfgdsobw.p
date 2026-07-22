block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории fbr-gds-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fbr-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории АТРИБУТА ТОВАРА РЕСТОРАН".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                        , ub.c-fbr-gds-obj.obj-type
                        , ub.c-fbr-gds-obj.obj-code
                        , ub.c-fbr-gds-obj.gds-code
                        , ub.c-fbr-gds-obj.corr-user-db-num
                        , ub.c-fbr-gds-obj.chip-num
                        ) " }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    /*проверим реляционность*/
    find first buf_fbr-gds-obj no-lock where
               buf_fbr-gds-obj.obj-type = c-fbr-gds-obj.obj-type
           AND buf_fbr-gds-obj.obj-code = c-fbr-gds-obj.obj-code
           AND buf_fbr-gds-obj.gds-code = c-fbr-gds-obj.gds-code
              no-error .
    if not available buf_fbr-gds-obj then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на АТРИБУТ РЕСТОРАН для товара" skip
      "магазин" c-fbr-gds-obj.obj-code
      "Товар" c-fbr-gds-obj.gds-code
      view-as alert-box error .
      undo main-block, return error.
    end.
   { gbl/objdbnum.i ub.c-fbr-gds-obj.obj-type ub.c-fbr-gds-obj.obj-code v-db-num }
   if not g#news and g#db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ИСТОРИИ АТРИБУТА РЕСТОРАН в БД, отличной от БД объекта" skip
      "Номер текущей БД" g#db-num "Номер БД объекта" v-db-num
      view-as alert-box error .
      undo, return error .
    end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and g#db-num = 0
      and ub.c-fbr-gds-obj.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and g#db-num > 0
      and ub.c-fbr-gds-obj.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p (
                        input {&table_c-fbr-gds-obj}
                        ,input (buffer ub.c-fbr-gds-obj:handle)
                        ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fbr-gds-obj}
        , input ( buffer ub.c-fbr-gds-obj:handle )
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
end. /*dow*/