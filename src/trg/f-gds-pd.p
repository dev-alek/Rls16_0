block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление fin-gds-part

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06


*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-gds-part.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление fin-gds-part".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-gds-part.fin-ob-code, ub.fin-gds-part.gds-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .

main-block :
do transaction
on error undo main-block, return error
:
define buffer buf_c-fin-gds-part for ub.c-fin-gds-part  .

run cur-time in this-procedure(output v-date, output v-time).

create buf_c-fin-gds-part.
buffer-copy fin-gds-part to buf_c-fin-gds-part
assign
  buf_c-fin-gds-part.chip-num           = next-value (s-corr-chip, {&db-name_schema})
  buf_c-fin-gds-part.corr-time          = v-time
  buf_c-fin-gds-part.corr-user-db-num   = g#db-num
  buf_c-fin-gds-part.corr-user-name     = g#userid
  buf_c-fin-gds-part.corr-date          = v-date
  buf_c-fin-gds-part.is-doc-del         = true
  .

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-gds-part}
        , input ( buffer ub.fin-gds-part:handle )
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