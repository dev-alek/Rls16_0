block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории статьи словар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07


*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-ruledict.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории статьи словаря".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-ruledict.entry-id
                         , ub.c-ruledict.corr-user-db-num
                         , ub.c-ruledict.chip-num
                         ) " }

{ cmp/trg-def.i }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if (not g#news
  or g#db-num <> 0)
  and ub.c-ruledict.entry-id = 0
  then do:
    run str/callnews.p
      (input {&table_c-ruledict}
      ,input (buffer ub.c-ruledict:handle)
      ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-ruledict}
        , input ( buffer ub.c-ruledict:handle )
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