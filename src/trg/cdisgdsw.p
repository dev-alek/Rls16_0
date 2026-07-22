block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории dis-gds-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/13/06
Author: Bakhtadze Natalya
Creation date: 11/13/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-gds-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории СКИДОК ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                        , ub.c-dis-gds-rule.obj-type
                        , ub.c-dis-gds-rule.obj-code
                        , ub.c-dis-gds-rule.gds-code
                        , ub.c-dis-gds-rule.pos-type
                        , ub.c-dis-gds-rule.discnt-role
                        , ub.c-dis-gds-rule.nonunique
                        , ub.c-dis-gds-rule.corr-user-db-num
                        , ub.c-dis-gds-rule.chip-num
                        ) " }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_dis-gds-rule for ub.dis-gds-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   if ub.c-dis-gds-rule.obj-type = {&shop}
   or ub.c-dis-gds-rule.obj-type = {&stock} then do:
    { gbl/objdbnum.i ub.c-dis-gds-rule.obj-type ub.c-dis-gds-rule.obj-code v-db-num }
    if not g#news and g#db-num <> v-db-num and g#db-num <> 0 then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять запись ИСТОРИИ СКИДОК НА ОБЪЕКТЕ в БД, отличной от БД объекта, если она не ГБД" skip
        "Номер текущей БД" g#db-num "Номер БД объекта" v-db-num
        view-as alert-box error .
        undo, return error .
      end.
  end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and g#db-num = 0
      and ub.c-dis-gds-rule.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and g#db-num > 0
      and ub.c-dis-gds-rule.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
      run str/callnews.p
        (input {&table_c-dis-gds-rule}
    ,input (buffer ub.c-dis-gds-rule:handle)
    ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-gds-rule}
        , input ( buffer ub.c-dis-gds-rule:handle )
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