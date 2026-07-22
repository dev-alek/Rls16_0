block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись prod-bc-db

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

trigger procedure for write of ub.prod-bc-db old buffer old-prod-bc-db.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись prod-bc-db".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_bar-code for ub.bar-code.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find buf_bar-code where buf_bar-code.b-code = ub.prod-bc-db.b-code no-lock no-error .
  if available buf_bar-code then do:
    if buf_bar-code.stts_ = integer({&hn-delete}) and not g#news then do:
      undo main-block, return error substitute("bar-code &1 is blocked for deletion":U, buf_bar-code.b-code).
    end.
  end.
  if not g#news then do:
    run str/callnews.p
      (input "prod-bc-db"
      ,input (buffer ub.prod-bc-db:handle)
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать prod-bc-db для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box.
      undo main-block, return error .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prod-bc-db}
        , input ( buffer ub.prod-bc-db:handle )
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