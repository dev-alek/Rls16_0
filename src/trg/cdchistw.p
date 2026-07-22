block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись шапки истории ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 22/01/04
Author: Bakhtadze Natalya
Creation date: 22/01/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dc-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шапки истории ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-dc-hist.d-card
                        , ub.c-dc-hist.corr-user-db-num
                        , ub.c-dc-hist.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup(ub.c-dc-hist.subject, {&dc-hist-subject}) > 0 then do:
    if ub.c-dc-hist.subject <> {&table_dis-host}
    and ub.c-dc-hist.subject <> {&table_dis-obj}
    and ub.c-dc-hist.subject <> {&table_dis-card-property}
    and ub.c-dc-hist.source-ref = ''
    and ub.c-dc-hist.source-type = ''
    then do: /*для dis-host в dis-hsth.i*/
      if not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
      OR (g#news
          and not ( g#db-num > 0 )
          and ub.c-dc-hist.is-news = no
          ) /*транзит из УБД1 через ГБД в УБД2*/
          /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
      or (g#news
          and ( g#db-num > 0 )
          and ub.c-dc-hist.is-news = yes
          )   /*из УБД - записи рожденные СПН*/
      then
      run str/callnews.p
        (input {&table_c-dc-hist}
        ,input (buffer ub.c-dc-hist:handle)
        ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dc-hist}
        , input ( buffer ub.c-dc-hist:handle )
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