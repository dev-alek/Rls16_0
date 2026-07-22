block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись gds-host-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-host-attr OLD oldgds-host-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись gds-host-attr".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.gds-host-attr.host-code, ub.gds-host-attr.gds-code, ub.gds-host-attr.attr-code) " }
{ cmp/trg-def.i  }
{ ref/gdshattr.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable p-news as logical no-undo.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-label as character no-undo .
define variable v-tooltip as character no-undo .
define buffer buf_c-gds-host-attr for ub.c-gds-host-attr.
define buffer buf_c-gds-hist for ub.c-gds-hist.


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
    {&table_gds-host-attr}
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
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-host-attr.
    buffer-copy oldgds-host-attr to buf_c-gds-host-attr
    assign
    buf_c-gds-host-attr.gds-code           = ub.gds-host-attr.gds-code
    buf_c-gds-host-attr.host-code          = ub.gds-host-attr.host-code
    buf_c-gds-host-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-host-attr.attr-code          = ub.gds-host-attr.attr-code
    buf_c-gds-host-attr.corr-time          = v-time
    buf_c-gds-host-attr.corr-user-db-num   = g#db-num
    buf_c-gds-host-attr.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
    buf_c-gds-host-attr.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-gds-host-attr to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new ub.gds-host-attr then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_gds-host-attr}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
  run gdshattr-news in this-procedure(input ub.gds-host-attr.attr-code,
                                      output p-news) no-error.
  if p-news then do:
    run str/callnews.p
      ( input {&table_gds-host-attr}
       ,input (buffer ub.gds-host-attr:handle)
      ) .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-host-attr}
        , input ( buffer ub.gds-host-attr:handle )
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