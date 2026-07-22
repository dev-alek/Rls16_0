block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/27/04
Author: Bakhtadze Natalya
Creation date: 01/27/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-card.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-dis-card.d-card
                        , ub.c-dis-card.corr-user-db-num
                        , ub.c-dis-card.chip-num
                        ) " }
{ cmp/trg-def.i }

define buffer buf_dis-card for ub.dis-card.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    if ub.c-dis-card.status_ <> {&nonused-status} then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = ub.c-dis-card.d-card
                no-error .
      if not available buf_dis-card then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на ДК" skip
        "ДК" c-dis-card.d-card
        view-as alert-box error .
        undo main-block, return error.
      end.
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-card}
        , input ( buffer ub.c-dis-card:handle )
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