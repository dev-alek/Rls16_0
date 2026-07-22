block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории принтеров кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/11/05
Author: Bakhtadze Natalya
Creation date: 08/11/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fbr-prn.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории принтеров кухни".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                           , ub.c-fbr-prn.db-num
                           , ub.c-fbr-prn.prn-num
                           , ub.c-fbr-prn.corr-user-db-num
                           , ub.c-fbr-prn.chip-num
                           ) " }
{ cmp/trg-def.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news and ub.c-fbr-prn.db-num <> g#db-num then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ПРИНТЕРА КУХНИ в чужой БД" skip
      "ПРИНТЕР КУХНИ установлен в БД" ub.c-fbr-prn.db-num skip
      "Текущая БД" g#db-num
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    run str/callnews.p
      (input "c-fbr-prn"
      ,input (buffer ub.c-fbr-prn:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fbr-prn}
        , input ( buffer ub.c-fbr-prn:handle )
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