block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.layout-elem OLD old_layout-elem.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись элемента раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.layout-elem.layout-type
                         , ub.layout-elem.device-type
                         , ub.layout-elem.mode-id
                         , ub.layout-elem.widget-id
                                                  ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-layout-elem for ub.c-layout-elem.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num > 0
  and not g#news
  then do:
    undo main-block, return error substitute("&1. Нельзя добавлять/изменять элемент раскладки в УБД", vss-workfile ).
  end.
  if not g#news then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-layout-elem.
    buffer-copy old_layout-elem to buf_c-layout-elem
    assign
    buf_c-layout-elem.layout-type        = ub.layout-elem.layout-type
    buf_c-layout-elem.device-type        = ub.layout-elem.device-type
    buf_c-layout-elem.widget-id          = ub.layout-elem.widget-id
    buf_c-layout-elem.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-layout-elem.corr-time          = v-time
    buf_c-layout-elem.corr-user-db-num   = g#db-num
    buf_c-layout-elem.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-layout-elem.corr-date          = v-date
    buf_c-layout-elem.action = integer(if new(ub.layout-elem) then {&hn-create} else {&hn-update})
    buf_c-layout-elem.subject = {&table_layout-elem}
    .
  end.
  if not g#news
  then do:
    run str/callnews.p
      (input {&table_layout-elem}
      ,input (buffer ub.layout-elem:handle)
      ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_layout-elem}
        , input ( buffer ub.layout-elem:handle )
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
end. /*doe*/