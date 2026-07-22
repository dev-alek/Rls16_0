block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись point-io

Автор: Чернова Светлана Александровна
Дата создания: 04/26/06
Author: Svetlana Chernova
Creation date: 04/26/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.point-io old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись point-io".
{ cmp/vssrevis.i "substitute('&1|&2', ub.point-io.db-num, ub.point-io.point-code ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-cmp-str as character no-undo .
define variable v-sys-time as character no-undo .
define buffer buf_c-point-io for ub.c-point-io .
define buffer b_point-io for ub.point-io .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  buffer-compare ub.point-io to oldb save result in v-cmp-str.
  if ub.point-io.is-default = yes then do:
    find first b_point-io
      where b_point-io.cli-code   = ub.point-io.cli-code
        and b_point-io.cli-type   = ub.point-io.cli-type
        and b_point-io.point-type = ub.point-io.point-type
        and b_point-io.is-default = yes
    no-error .
    if available b_point-io
    and recid(b_point-io) <> recid(ub.point-io)
    then do:
      assign
      b_point-io.is-default = no.
    end.
  end.
  if not g#news then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    create buf_c-point-io .
    BUFFER-COPY oldb  except point-code db-num
    TO buf_c-point-io
    assign
    buf_c-point-io.point-code = ub.point-io.point-code
    buf_c-point-io.cli-type = ub.point-io.cli-type
    buf_c-point-io.cli-code = ub.point-io.cli-code
    buf_c-point-io.db-num = ub.point-io.db-num
    buf_c-point-io.chip-num  = next-value (s-chip-point-io, {&db-name_schema}) .
    { gbl/curdburt.i  buf_c-point-io.corr-user-db-num   buf_c-point-io.corr-user-name   buf_c-point-io.corr-date   v-sys-time   buf_c-point-io.corr-time  }
  end.
  if not (v-cmp-str = "is-default"
          and g#news
          and g#db-num > 0
          ) then do:
    run str/callnews.p ( input {&table_point-io}
                      , input (buffer ub.point-io:handle) ) .
    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_point-io}
          , input ( buffer ub.point-io:handle )
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
end.