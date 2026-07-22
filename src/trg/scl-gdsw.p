block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись scales-gds

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.scales-gds OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись scales-gds".
{ cmp/vssrevis.i "substitute('&1|&2|&3',  ub.scales-gds.db-num
                                    , ub.scales-gds.scales-num
                                    , ub.scales-gds.PLU-code
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable p-news as logical no-undo.
define variable p-hist as logical no-undo.
define variable v-changes as character no-undo .

define buffer buf_scales for ub.scales.
define buffer buf_c-scales for ub.c-scales.
define buffer buf_c-scales-gds for ub.c-scales-gds.
define buffer buf_c-gds-hist for ub.c-gds-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news and ub.scales-gds.db-num <> g#db-num then do:
    message
    "Нельзя изменять запись об товаре на весах," skip
    "принадлежащих другой БД"
    view-as alert-box .
    undo, return error.
  end.
  buffer-compare oldb to ub.scales-gds
  case-sensitive
  save result in v-changes.
  if v-changes = "to-send"
  or v-changes = "to-del"
  or v-changes = "to-del,to-send"
  or v-changes = "to-send,to-del"
  then return.
  run str/callnews.p
    ( input {&table_scales-gds}
      ,input (buffer ub.scales-gds:handle)
    ) no-error .
  if error-status:error then undo, return error return-value  .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-scales-gds.
    assign
    buf_c-scales-gds.b-code             =  (if new(ub.scales-gds)
                                           then ub.scales-gds.b-code
                                           else oldb.b-code)
    buf_c-scales-gds.db-num             =  ub.scales-gds.db-num
    buf_c-scales-gds.scales-num         =  ub.scales-gds.scales-num
    buf_c-scales-gds.PLU-code           =  ub.scales-gds.PLU-code
    buf_c-scales-gds.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-scales-gds.corr-time          = v-time
    buf_c-scales-gds.corr-user-db-num   = g#db-num
    buf_c-scales-gds.corr-user-name     = g#userid
    buf_c-scales-gds.corr-date          = v-date
    .
    create buf_c-scales.
    buffer-copy buf_c-scales-gds
    using
    db-num
    PLU-code
    scales-num
    corr-user-db-num
    corr-time
    corr-user-name
    corr-date
    chip-num
    to  buf_c-scales
    assign

    buf_c-scales.action               = integer(if new(ub.scales-gds)
                                                  then  {&hn-create}
                                                  else {&hn-update})
    buf_c-scales.subject               = {&table_scales-gds}
    .

  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_scales-gds}
        , input ( buffer ub.scales-gds:handle )
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