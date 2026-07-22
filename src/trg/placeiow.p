block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись place-io

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/03/09
Author: Dmitry Ukhanov
Creation date: 02/03/09

Автор1: Кочетков Михаил Юрьевич
Дата создания1: 04/26/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.place-io OLD old-place-io .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись place-io".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.place-io.obj-type, ub.place-io.obj-code, ub.place-io.place-io-code ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .

  define buffer buf_c-place-io for ub.c-place-io .

  run cur-time in this-procedure
    ( output v-date
    , output v-time
    ).
  create buf_c-place-io.
  if new(ub.place-io) then do:
    assign
      buf_c-place-io.place-io-code = ub.place-io.place-io-code
      buf_c-place-io.obj-type      = ub.place-io.obj-type
      buf_c-place-io.obj-code      = ub.place-io.obj-code
    .
  end.
  else do:
    buffer-copy old-place-io to buf_c-place-io .
  end.
  assign
    buf_c-place-io.chip-num         = dynamic-next-value( "s-chip-place-io", "{&db-name_schema}")
    buf_c-place-io.corr-time        = v-time
    buf_c-place-io.corr-date        = v-date
    buf_c-place-io.corr-user-db-num = g#db-num
    buf_c-place-io.corr-user-name   = (if g#news = true then substitute( "СПН в БД &1", g#db-num ) else g#userid )
  .
  if trim( buf_c-place-io.corr-user-name ) = "":U then do:
    assign
      buf_c-place-io.corr-user-name = userid( "ub":U )
    .
  end.

  run str/callnews.p
    ( input {&table_place-io}
    , input (buffer ub.place-io:handle)
    ) .

  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_place-io}
        , input ( buffer ub.place-io:handle )
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