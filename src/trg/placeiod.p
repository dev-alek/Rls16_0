block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление place-io

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/03/09
Author: Dmitry Ukhanov
Creation date: 02/03/09

Автор1: Кочетков Михаил Юрьевич
Дата создания1: 04/26/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.place-io.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление place-io".
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
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .

  /* ищем все вхождения в  trn-doc */
  for each buf_trn-doc exclusive-lock
    where buf_trn-doc.obj-type      = ub.place-io.obj-type
      and buf_trn-doc.obj-code      = ub.place-io.obj-code
      and buf_trn-doc.place-io-code = ub.place-io.place-io-code
    :
    assign buf_trn-doc.place-io-code = 0 .
  end.
  for each buf_doc-line exclusive-lock
    where buf_doc-line.obj-type      = ub.place-io.obj-type
      and buf_doc-line.obj-code      = ub.place-io.obj-code
      and buf_doc-line.place-io-code = ub.place-io.place-io-code
    :
    assign buf_doc-line.place-io-code = 0 .
  end.

  /* пишем историю */
  run cur-time in this-procedure
    ( output v-date
     ,output v-time
    ).
  create buf_c-place-io.
  buffer-copy ub.place-io to buf_c-place-io
    assign
      buf_c-place-io.chip-num         = dynamic-next-value( "s-chip-place-io", "{&db-name_schema}")
      buf_c-place-io.corr-time        = v-time
      buf_c-place-io.corr-date        = v-date
      buf_c-place-io.corr-user-db-num = g#db-num
      buf_c-place-io.corr-user-name   = (if g#news = true then substitute( "СПН в БД &1", g#db-num ) else g#userid )
  .


  run nws/cmd-del.p
    ( input {&table_place-io}
    , input (buffer ub.place-io:handle)
    , input "":U
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &1&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_place-io}
        , input ( buffer ub.place-io:handle )
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