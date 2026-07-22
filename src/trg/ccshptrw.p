block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибутов типов касссовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cash-pay-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибутов типов касссовых платежей".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                                          , ub.c-cash-pay-attr.curr-code
                                          , ub.c-cash-pay-attr.host-code
                                          , ub.c-cash-pay-attr.obj-type
                                          , ub.c-cash-pay-attr.obj-code
                                          , ub.c-cash-pay-attr.attr-code
                                          , ub.c-cash-pay-attr.corr-user-db-num
                                          , ub.c-cash-pay-attr.chip-num
                                          ) " }
{ cmp/trg-def.i }

define buffer buf_cash-pay for ub.cash-pay.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_cash-pay no-lock where
               buf_cash-pay.cdpay-code = c-cash-pay-attr.cdpay-code
           AND buf_cash-pay.curr-code = c-cash-pay-attr.curr-code    no-error .
    if not available buf_cash-pay then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на тип кассового платежа" skip
      "Код платежа" c-cash-pay-attr.cdpay-code skip
      "Код валюты" c-cash-pay-attr.curr-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-cash-pay-attr.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p
      (input "c-cash-pay-attr"
      ,input (buffer ub.c-cash-pay-attr:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cash-pay-attr}
        , input ( buffer ub.c-cash-pay-attr:handle )
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