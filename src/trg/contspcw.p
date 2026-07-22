block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись спец. договора

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

При корректировке бонусов меняю  whole-send-news

*/

TRIGGER PROCEDURE FOR WRITE OF ub.contract-specif  old old-contract-specif.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись спец. договора".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.contract-specif.contract-num, ub.contract-specif.host-code, ub.contract-specif.gds-code) " }
{ cmp/trg-def.i }
{ cmp/library.i }

define buffer buf_c-contract-specif for ub.c-contract-specif .
define variable p-sys-time   as character no-undo .

main-block :
do transaction
on error undo main-block, return error
:
  if not g#news then do: /* история */
    create buf_c-contract-specif .
      BUFFER-COPY old-contract-specif except host-code  contract-num gds-code
      TO buf_c-contract-specif
      assign
        buf_c-contract-specif.host-code    = ub.contract-specif.host-code
        buf_c-contract-specif.contract-num = ub.contract-specif.contract-num
        buf_c-contract-specif.gds-code     = ub.contract-specif.gds-code
        buf_c-contract-specif.artic        = ub.contract-specif.artic
        buf_c-contract-specif.prod-type    = ub.contract-specif.prod-type
        buf_c-contract-specif.prod-code    = ub.contract-specif.prod-code
        buf_c-contract-specif.chip-num     = next-value (s-chip-contract-specif, {&db-name_schema})
      .
    { gbl/curdburt.i  buf_c-contract-specif.corr-user-db-num   buf_c-contract-specif.corr-user-name  buf_c-contract-specif.corr-date  p-sys-time  buf_c-contract-specif.corr-time }
  end.

  if g#db-num = 0 then do:
    run str/callnews.p ( input "contract-specif", input (buffer ub.contract-specif:handle)) no-error .
    if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip  "Ошибка при передаче в новости спецификации к договору" skip
          error-status :get-message(1) skip    return-value skip  view-as alert-box error .
        undo, return error.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_contract-specif}
        , input ( buffer ub.contract-specif:handle )
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
