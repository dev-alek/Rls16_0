block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись скидки на платеж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/06
Author: Bakhtadze Natalya
Creation date: 12/13/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.dis-cp-rule old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись скидки на платеж".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                        ,  ub.dis-cp-rule.cdpay-code
                        ,  ub.dis-cp-rule.curr-code
                        ,  ub.dis-cp-rule.host-code
                        ,  ub.dis-cp-rule.obj-type
                        ,  ub.dis-cp-rule.obj-code
                        ,  ub.dis-cp-rule.pos-type
                        ,  ub.dis-cp-rule.discnt-role
                        ,  ub.dis-cp-rule.nonunique
                        ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_c-cash-pay for ub.c-cash-pay.
define buffer buf_c-dis-cp-rule for ub.c-dis-cp-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-cp-rule.
    buffer-copy oldb to buf_c-dis-cp-rule
    assign
    buf_c-dis-cp-rule.cdpay-code         =  ub.dis-cp-rule.cdpay-code
    buf_c-dis-cp-rule.curr-code          =  ub.dis-cp-rule.curr-code
    buf_c-dis-cp-rule.host-code          =  ub.dis-cp-rule.host-code
    buf_c-dis-cp-rule.obj-type           =  ub.dis-cp-rule.obj-type
    buf_c-dis-cp-rule.obj-code           =  ub.dis-cp-rule.obj-code
    buf_c-dis-cp-rule.pos-type           =  ub.dis-cp-rule.pos-type
    buf_c-dis-cp-rule.discnt-role        =  ub.dis-cp-rule.discnt-role
    buf_c-dis-cp-rule.nonunique          =  ub.dis-cp-rule.nonunique
    buf_c-dis-cp-rule.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-dis-cp-rule.corr-time          = v-time
    buf_c-dis-cp-rule.corr-user-db-num   = g#db-num
    buf_c-dis-cp-rule.corr-user-name     = g#userid
    buf_c-dis-cp-rule.corr-date          = v-date
    .
    if buf_c-dis-cp-rule.cdpay-code > 0 then do:
      create buf_c-cash-pay.
      buffer-copy buf_c-dis-cp-rule to buf_c-cash-pay
      assign
      buf_c-cash-pay.subject            = {&table_dis-cp-rule}
      buf_c-cash-pay.action             = integer(if new(ub.dis-cp-rule) then {&hn-create} else {&hn-update})
      .
    end.
  end.
  run str/callnews.p
    ( input {&table_dis-cp-rule}
     ,input (buffer ub.dis-cp-rule:handle)
    ) .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-cp-rule}
        , input ( buffer ub.dis-cp-rule:handle )
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