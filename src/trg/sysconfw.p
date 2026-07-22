block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись sysconf

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.sysconf OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись sysconf".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-sysconf for ub.c-sysconf.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_sysconf~}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
    ~{&nws-to-hist~}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-sysconf.
    buffer-copy oldb to buf_c-sysconf
    assign
    buf_c-sysconf.host-code          = ub.sysconf.host-code
    buf_c-sysconf.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-sysconf.corr-time          = v-time
    buf_c-sysconf.corr-user-db-num   = g#db-num
    buf_c-sysconf.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-sysconf.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-sysconf to buf_c-cli-hist
    assign
    buf_c-cli-hist.obj-type = {&cmp}
    buf_c-cli-hist.obj-code = ub.sysconf.host-code

    buf_c-cli-hist.action = (if new (ub.sysconf )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-cli-hist.subject = {&table_sysconf}
    buf_c-cli-hist.host-code = ub.sysconf.host-code
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-cli-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
  end.
  run str/callnews.p
    (input {&table_sysconf}
    ,input (buffer ub.sysconf:handle)
    ) no-error .
  if error-status:error then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры callnews.p" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo main-block,  return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_sysconf}
        , input ( buffer ub.sysconf:handle )
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