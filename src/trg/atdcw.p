block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись финансового архива по складским документам

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.arh-trn-doc-contract OLD old_arh-trn-doc-contract.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись финансового архива по складским документам ".
{ cmp/vssrevis.i " " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

main-block :
do transaction
on error undo main-block, return error
: /*Отправляется кустом при отправке складского документа*/
  /*
  /*Если это не заглушка для локирования, отправляем ее в новости*/
  if ub.arh-trn-doc-contract.fact-order <> 0 then do:
    run str/callnews.p
      (input "arh-trn-doc-contract"
      ,input (buffer ub.arh-trn-doc-contract:handle)
      ) no-error .
    if error-status:error then do:
       message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче в новости" skip
        return-value skip
        view-as alert-box error .
        return error.
    end.
  end.
  */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_arh-trn-doc-contract}
        , input ( buffer ub.arh-trn-doc-contract:handle )
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