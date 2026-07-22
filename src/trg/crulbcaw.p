block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории алгоритма расчета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/06
Author: Bakhtadze Natalya
Creation date: 09/14/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-rule-by-call.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории алгоритма расчета".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-rule-by-call.call#_id
                         , ub.c-rule-by-call.codex_id
                        , ub.c-rule-by-call.ruleset_id
                        , ub.c-rule-by-call.order_id
                        , ub.c-rule-by-call.corr-user-db-num
                        , ub.c-rule-by-call.chip-num
                         ) " }

{ cmp/trg-def.i }
define variable v-descr as character no-undo .

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
      and ub.c-rule-by-call.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-rule-by-call.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    if ub.c-rule-by-call.call_id begins ({&table_layout-elem-rule} + {&delim-key})
    and g#news then do:
    end.
    else do:
      run str/callnews.p
        (input {&table_c-rule-by-call}
        ,input (buffer ub.c-rule-by-call:handle)
        ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-rule-by-call}
        , input ( buffer ub.c-rule-by-call:handle )
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