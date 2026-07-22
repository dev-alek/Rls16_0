block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы ИСТОРИЯ СКИДОК ПО ТИПУ дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/06
Author: Bakhtadze Natalya
Creation date: 12/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-dct-rule OLD old-c-dis-dct-rule .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы ИСТОРИЯ СКИДОК ПО ТИПУ дисконтных карт".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                         , ub.c-dis-dct-rule.emitent-host-code
                         , ub.c-dis-dct-rule.type
                         , ub.c-dis-dct-rule.host-code
                        , ub.c-dis-dct-rule.obj-type + string(Ub.c-dis-dct-rule.obj-code)
                        , ub.c-dis-dct-rule.pos-type
                        , ub.c-dis-dct-rule.discnt-role
                        , ub.c-dis-dct-rule.nonunique
                        , ub.c-dis-dct-rule.corr-user-db-num
                        , ub.c-dis-dct-rule.chip-num
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-dis-dct-rule.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-dis-dct-rule.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then

  run str/callnews.p
    (input {&table_c-dis-dct-rule}
    ,input (buffer ub.c-dis-dct-rule:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-dct-rule}
        , input ( buffer ub.c-dis-dct-rule:handle )
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