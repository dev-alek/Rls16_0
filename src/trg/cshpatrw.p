block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись cash-pay-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cash-pay-attr OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись cash-pay-attr".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6',  ub.cash-pay-attr.cdpay-code
                                          , ub.cash-pay-attr.curr-code
                                          , ub.cash-pay-attr.host-code
                                          , ub.cash-pay-attr.obj-type
                                          , ub.cash-pay-attr.obj-code
                                          , ub.cash-pay-attr.attr-code
                                          ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_c-cash-pay for ub.c-cash-pay.
define buffer buf_c-cash-pay-attr for ub.c-cash-pay-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cash-pay-attr.
    buffer-copy oldb to buf_c-cash-pay-attr
    assign
    buf_c-cash-pay-attr.cdpay-code         =  ub.cash-pay-attr.cdpay-code
    buf_c-cash-pay-attr.curr-code          =  ub.cash-pay-attr.curr-code
    buf_c-cash-pay-attr.host-code          =  ub.cash-pay-attr.host-code
    buf_c-cash-pay-attr.obj-type           =  ub.cash-pay-attr.obj-type
    buf_c-cash-pay-attr.obj-code           =  ub.cash-pay-attr.obj-code
    buf_c-cash-pay-attr.attr-code          =  ub.cash-pay-attr.attr-code
    buf_c-cash-pay-attr.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-cash-pay-attr.corr-time          = v-time
    buf_c-cash-pay-attr.corr-user-db-num   = g#db-num
    buf_c-cash-pay-attr.corr-user-name     = g#userid
    buf_c-cash-pay-attr.corr-date          = v-date
    .
    create buf_c-cash-pay.
    buffer-copy buf_c-cash-pay-attr to buf_c-cash-pay
    assign
    buf_c-cash-pay.subject            = {&table_cash-pay-attr}
    buf_c-cash-pay.action             = integer(if new(ub.cash-pay-attr) then {&hn-create} else {&hn-update})
    .
  end.
  run str/callnews.p
    ( input {&table_cash-pay-attr}
     ,input (buffer ub.cash-pay-attr:handle)
    ) .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_cash-pay-attr}
        , input ( buffer ub.cash-pay-attr:handle )
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