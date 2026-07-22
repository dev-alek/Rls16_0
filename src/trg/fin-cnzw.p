block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись кода целевого назначени

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-code-cel-nazn OLD old_fin-code-cel-nazn.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись кода целевого назначени ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-code-cel-nazn.fin-code, ub.fin-code-cel-nazn.host-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define buffer buf_c-fin-code-cel-nazn for ub.c-fin-code-cel-nazn  .

main-block :
do transaction
on error undo main-block, return error
:
  run str/callnews.p
    (input "fin-code-cel-nazn"
    ,input (buffer ub.fin-code-cel-nazn:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.


  if not g#news then do:

    define variable v-date as date no-undo .
    define variable v-time as integer no-undo .

    run cur-time in this-procedure(output v-date, output v-time).

    create buf_c-fin-code-cel-nazn.
    buffer-copy old_fin-code-cel-nazn to buf_c-fin-code-cel-nazn
    assign
      buf_c-fin-code-cel-nazn.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      buf_c-fin-code-cel-nazn.corr-time          = v-time
      buf_c-fin-code-cel-nazn.corr-user-db-num   = g#db-num
      buf_c-fin-code-cel-nazn.corr-user-name     = g#userid
      buf_c-fin-code-cel-nazn.corr-date          = v-date
    .

  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-code-cel-nazn}
        , input ( buffer ub.fin-code-cel-nazn:handle )
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