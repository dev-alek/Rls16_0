block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-inkas.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории по продаже".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-inkas.inkas-code
                         , ub.c-inkas.corr-user-db-num
                         , ub.c-inkas.chip-num
                         ) " }
{ cmp/str-glbl.i }
{ cmp/trg-def.i }

define buffer buf_inkas for ub.inkas.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_inkas no-lock where
            buf_inkas.inkas-code = ub.c-inkas.inkas-code no-error.
  if available buf_inkas
  and buf_inkas.status_ = {&fact} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ИСТОРИИ ПРОДАЖИ"
    view-as alert-box error .
    undo main-block, return error .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-inkas}
        , input ( buffer ub.c-inkas:handle )
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