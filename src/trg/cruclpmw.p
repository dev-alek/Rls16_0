block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории параметров вызова правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/06
Author: Bakhtadze Natalya
Creation date: 12/14/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-rule-call-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории параметров вызова правила".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                        ,  ub.c-rule-call-param.call#_id
                        ,  ub.c-rule-call-param.codex_id
                        ,  ub.c-rule-call-param.ruleset_id
                        ,  ub.c-rule-call-param.order_id
                        ,  ub.c-rule-call-param.param-name
                        ,  ub.c-rule-call-param.p-index
                        ,  ub.c-rule-call-param.corr-user-db-num
                        ,  ub.c-rule-call-param.chip-num
                        ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  or g#db-num <> 0
  then do:
    if ub.c-rule-call-param.call_id begins ({&table_layout-elem-rule} + {&delim-key})
    and g#news then do:
    end.
    else do:
        run str/callnews.p
        (input {&table_c-rule-call-param}
        ,input (buffer ub.c-rule-call-param:handle)
        ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-rule-call-param}
        , input ( buffer ub.c-rule-call-param:handle )
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