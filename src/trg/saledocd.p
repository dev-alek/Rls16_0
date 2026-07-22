block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление подчиненного документа продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/27/06
Author: Bakhtadze Natalya
Creation date: 12/27/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.sale-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление подчиненного документа продажи".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u
                             ,ub.sale-doc.inkas-code
                             ,ub.sale-doc.storage
                             ,ub.sale-doc.doc-code)" }
{ cmp/trg-def.i  }

define buffer buf_inkas for ub.inkas.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

  find first buf_inkas no-lock where
            buf_inkas.inkas-code = ub.sale-doc.inkas-code no-error.
  if available buf_inkas
  and (buf_inkas.status_ = {&fact}
      or
      buf_inkas.status_ = {&inquiry}
      )
  and buf_inkas.is-del = no
  then do:
    message
    vss-workfile vss-revision vss-description skip
      "Нельзя удалять записи по связанным документам по продаже, закрытой до статуса" buf_inkas.status_ skip
      "Номер продажи" buf_inkas.inkas-code skip
      "Статус продажи" buf_inkas.status_ skip
      "Запись по связанному документу" ub.sale-doc.doc-code
      view-as alert-box error .
    undo main-block, return error .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_sale-doc}
        , input ( buffer ub.sale-doc:handle )
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
end. /*doe*/