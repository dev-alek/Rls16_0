block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ВИДА ОПЛАТЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/05
Author: Bakhtadze Natalya
Creation date: 08/08/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-pay-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ВИДА ОПЛАТЫ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-pay-type.obj-code
                         , ub.c-pay-type.corr-user-db-num
                         , ub.c-pay-type.chip-num
                         ) " }


{ cmp/trg-def.i }

define buffer buf_pay-type for ub.pay-type.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and ub.c-pay-type.action <> integer({&hn-create})
  then do:
    /*проверим реляционность*/
    find first buf_pay-type share-lock where
               buf_pay-type.obj-code = ub.c-pay-type.obj-code  no-error .
    if not available buf_pay-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВИД ОПЛАТЫ" skip
      "код" ub.c-pay-type.obj-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВИД ОПЛАТЫ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input {&table_c-pay-type}
    ,input (buffer ub.c-pay-type:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-pay-type}
        , input ( buffer ub.c-pay-type:handle )
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