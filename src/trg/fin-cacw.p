block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись кода корресп. счета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-code-cor-acc OLD old_fin-code-cor-acc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись кода корресп. счета ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-code-cor-acc.fin-code, ub.fin-code-cor-acc.host-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
define buffer buf_c-fin-code-cor-acc for ub.c-fin-code-cor-acc  .

main-block :
do transaction
on error undo main-block, return error
:
  run str/callnews.p
    (input "fin-code-cor-acc"
    ,input (buffer ub.fin-code-cor-acc:handle)
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

    create buf_c-fin-code-cor-acc.
    buffer-copy old_fin-code-cor-acc to buf_c-fin-code-cor-acc
    assign
      buf_c-fin-code-cor-acc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      buf_c-fin-code-cor-acc.corr-time          = v-time
      buf_c-fin-code-cor-acc.corr-user-db-num   = g#db-num
      buf_c-fin-code-cor-acc.corr-user-name     = g#userid
      buf_c-fin-code-cor-acc.corr-date          = v-date
    .

  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-code-cor-acc}
        , input ( buffer ub.fin-code-cor-acc:handle )
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