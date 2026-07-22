block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление режима работы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wi-mode.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление режима работы".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.wi-mode.mode-type
                         , ub.wi-mode.mode-id
                                                  ) " }

{ cmp/trg-def.i }

{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wi-mode for ub.c-wi-mode.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*запись в историю надо осуществлять в редакторе раскладки*/
  if g#db-num > 0
  and not g#news
  then do:
    undo main-block, return error substitute("&1. Нельзя удалять РЕЖИМ РАБОТЫ в УБД", vss-workfile ).
  end.
  if not g#news then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-wi-mode.
    buffer-copy ub.wi-mode to buf_c-wi-mode
    assign
    buf_c-wi-mode.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-wi-mode.corr-time          = v-time
    buf_c-wi-mode.corr-user-db-num   = g#db-num
    buf_c-wi-mode.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-wi-mode.corr-date          = v-date
    buf_c-wi-mode.subject            = {&table_wi-mode}
    buf_c-wi-mode.action             = integer({&hn-delete})
    .
    run nws/cmd-del.p
      ( input {&table_wi-mode}
      ,input (buffer ub.wi-mode:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wi-mode}
        , input ( buffer ub.wi-mode:handle )
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
end. /*doe*/