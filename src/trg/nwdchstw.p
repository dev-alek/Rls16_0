block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

TRIGGER PROCEDURE FOR WRITE OF ub.nws-doc-hist old buffer old-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление документа".
{ cmp/vssrevis.i "substitute('&1|&2', ub.nws-doc-hist.db-num, ub.nws-doc-hist.ord-num) " }
{ cmp/trg-def.i }

main-block :
do transaction
on error undo main-block, return error
:
  run validate-nws-doc-hist in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи истории документа" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if  g#news
  and g#db-num <> 0
  then do:
    /* отправляем информацию об обработке документа в офис */
    run str/callnews.p
      (input "nws-doc-hist"
      ,input (buffer ub.nws-doc-hist:handle)
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_nws-doc-hist}
        , input ( buffer ub.nws-doc-hist:handle )
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



procedure validate-nws-doc-hist :

  do
  on error undo, return error return-value
  :
    /* проверка целостности записи об обработке документа */

  end.

end procedure. /* validate-nws-doc-hist */