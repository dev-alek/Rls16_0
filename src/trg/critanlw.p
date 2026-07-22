block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на запись справочника критерии анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.criterion-analysis  OLD old_criterion-analysis .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "триггер на запись справочника критерии анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block :
do transaction
on error undo main-block, return error
:
/* Отправка по новостям */
/*
  run str/callnews.p
    (input "criterion-analysis "
    ,input (buffer ub.criterion-analysis :handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
*/
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_criterion-analysis}
        , input ( buffer ub.criterion-analysis:handle )
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