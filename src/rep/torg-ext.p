block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-ext.p $
$Archive: rep/torg-ext.p $

Запуск внешней программы из списка форм

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:
    p-exttype: должен соответствовать параметру в описании вызова внешней процедуры в ext-list.i.
                    Например, "{&print}" или "{&alt-barcode}"
*/

do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define input parameter p-exttype            as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-ext.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-ext.p $":U .
define variable vss-description as character no-undo init "Запуск внешней программы из списка форм".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define variable v-ext-button-label     as character         no-undo.

define temp-table temp_recid-list no-undo
    field string-trn-doc-recid as character
    index pi is primary unique string-trn-doc-recid
.

run str/run-ext.p (   input p-recid
                , input table temp_recid-list
                , input p-exttype
                , input ""
                , output v-ext-button-label
                ) no-error.
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Ошибка вызова внешней программы"
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.

end.