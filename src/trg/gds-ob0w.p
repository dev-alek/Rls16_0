block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы gds-obj-prop-attr

Автор: Чернова Светлана Александровна
Дата создания: 10/28/08
Author: Svetlana Chernova
Creation date: 10/28/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-obj-prop-attr old old-gds-obj-prop-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы gds-obj-prop-attr".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/gdsoattr.i trigger }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable p-news as logical no-undo.
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-gds-obj-attr for ub.c-gds-obj-attr.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_gds-obj for ub.gds-obj.
define buffer locked_gds-obj-prop-attr for ub.gds-obj-prop-attr.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
if lookup( ub.gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) = 0 then do:
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_gds-obj-prop~}
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
    create buf_c-gds-obj-attr.
    buffer-copy old-gds-obj-prop-attr to buf_c-gds-obj-attr
    assign
    buf_c-gds-obj-attr.gds-code           = ub.gds-obj-prop-attr.gds-code
    buf_c-gds-obj-attr.obj-type           = ub.gds-obj-prop-attr.obj-type
    buf_c-gds-obj-attr.obj-code           = ub.gds-obj-prop-attr.obj-code
    buf_c-gds-obj-attr.attr-code          = ub.gds-obj-prop-attr.attr-code
    buf_c-gds-obj-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-obj-attr.corr-time          = v-time
    buf_c-gds-obj-attr.corr-user-db-num   = g#db-num
    buf_c-gds-obj-attr.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
    buf_c-gds-obj-attr.corr-date          = v-date
    .
    { gbl/hostcode.i ub.gds-obj-prop-attr.obj-type ub.gds-obj-prop-attr.obj-code v-host-code }
    create buf_c-gds-hist.
    buffer-copy buf_c-gds-obj-attr to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new ub.gds-obj-prop-attr then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_gds-obj-prop-attr}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news  = g#news
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
    if not g#news
    or g#db-num > 0 then do:
      run str/callnews.p ( input {&table_gds-obj-prop-attr}
                        , input (buffer ub.gds-obj-prop-attr:handle)).
    end.
  end.
end. /*if lookup( ub.gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) = 0 then do:*/
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-obj-attr}
        , input ( buffer ub.gds-obj-attr:handle )
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