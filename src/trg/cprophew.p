block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ДЕКЛАРАЦИИ СВОЙСТВ ОБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/18/06
Author: Bakhtadze Natalya
Creation date: 09/18/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-prop-head.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ДЕКЛАРАЦИИ СВОЙСТВ ОБЪЕКТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-prop-head.dtm-code
                         , ub.c-prop-head.corr-user-db-num
                         , ub.c-prop-head.chip-num
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
    run str/callnews.p
      (input {&table_c-prop-head}
      ,input (buffer ub.c-prop-head:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-prop-head}
        , input ( buffer ub.c-prop-head:handle )
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