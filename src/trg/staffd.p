block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ПЕРСОНАЛА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/23/06
Author: Bakhtadze Natalya
Creation date: 05/23/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.staff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ПЕРСОНАЛА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         ,  ub.staff.role
                         ,  ub.staff.role-level
                         ,  ub.staff.work-place
                         ,  ub.staff.staff-code
                         ,  ub.staff.date-start
                         ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-no-uniq as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-staff for ub.c-staff.
define buffer buf_staff for ub.staff.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#news
  and  (ub.staff.db-num <> 0
        or
        not (ub.staff.obj-type = '':U and ub.staff.obj-code = 0)
        ) then do:
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_staff}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      {&nws-to-hist}
      v-send
      no-error
      }
    end.
  end.
  else do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ПЕРСОНАЛА"
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not  G#news
  or v-send >= 0 then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    create buf_c-staff.
    assign
    buf_c-staff.role               = ub.staff.role
    buf_c-staff.role-level         = ub.staff.role-level
    buf_c-staff.work-place         = ub.staff.work-place
    buf_c-staff.date-start         = ub.staff.date-start
    buf_c-staff.staff-code         = ub.staff.staff-code
    buf_c-staff.psn-code           = ub.staff.psn-code
    buf_c-staff.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-staff.corr-user-db-num   = g#db-num
    buf_c-staff.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
    buf_c-staff.corr-date          = v-today
    buf_c-staff.corr-time          = v-time
    .
    if buf_c-staff.role-level = {&role-level-object} then do:
    { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
    end.
    else do:
      v-host-code = buf_c-staff.host-code.
    end.
    create buf_c-cli-hist.
    buffer-copy buf_c-staff to buf_c-cli-hist
    assign
    buf_c-cli-hist.obj-type = {&prs}
    buf_c-cli-hist.obj-code = ub.staff.psn-code
    buf_c-cli-hist.action = integer({&hn-delete})
    buf_c-cli-hist.subject = {&table_staff}
    buf_c-cli-hist.host-code = buf_c-staff.host-code
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-cli-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
  if not (g#news
  and (ub.staff.db-num = g#news-source-db
      or
      (ub.staff.obj-code > 0
      and can-find(first ub.clients no-lock where
                          ub.clients.obj-type = ub.staff.obj-type
                      and ub.clients.obj-code = ub.staff.obj-code
                      and ub.clients.db-num = g#news-source-db)
       )
      )
      )
  then do:
    run nws/cmd-del.p
      ( input {&table_staff}
        ,input (buffer ub.staff:handle)
        ,input '':U
      ) no-error .
   end.
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_staff}
        , input ( buffer ub.staff:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.