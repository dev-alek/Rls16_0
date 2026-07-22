block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление arh-fin-doc-contr-schet-tax

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06

*/

TRIGGER PROCEDURE FOR DELETE OF arh-fin-doc-contr-schet-tax.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление arh-fin-doc-contr-schet-tax".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
main-block:
do
on error undo main-block, return error return-value :
  run nws/cmd-del.p
    ( input "arh-fin-doc-contr-schet-tax":U
     ,input (buffer ub.arh-fin-doc-contr-schet-tax:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_arh-fin-doc-contr-schet-tax}
        , input ( buffer ub.arh-fin-doc-contr-schet-tax:handle )
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