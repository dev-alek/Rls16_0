block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибутов связи МЦ с товарами

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/07
Author: Polina Gridchina
Creation date: 04/10/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wth-gds-attr old oldwth-gds-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов связи МЦ с товарами".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
/*define buffer buf_wth-ser for ub.wth-ser. */
define buffer buf_c-wth-gds-attr for ub.c-wth-gds-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run str/callnews.p
    ( input "wth-gds-attr"
     ,input (buffer ub.wth-gds-attr:handle)
    ) .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-gds-attr.
    buffer-copy oldwth-gds-attr to buf_c-wth-gds-attr
    assign
    buf_c-wth-gds-attr.wth-code           = ub.wth-gds-attr.wth-code
    buf_c-wth-gds-attr.gds-code           = ub.wth-gds-attr.gds-code
    buf_c-wth-gds-attr.attr-code          = ub.wth-gds-attr.attr-code
    buf_c-wth-gds-attr.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-gds-attr.corr-time          = v-time
    buf_c-wth-gds-attr.corr-user-db-num   = g#db-num
    buf_c-wth-gds-attr.corr-user-name     = g#userid
    buf_c-wth-gds-attr.corr-date          = v-date
    .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_wth-gds-attr}
        , input ( buffer ub.wth-gds-attr:handle )
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