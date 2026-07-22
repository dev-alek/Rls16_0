block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на корректировку fin-ob-trn

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
TRIGGER PROCEDURE FOR WRITE OF ub.fin-ob-trn.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на корректировку fin-ob-trn".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


main-block :
do transaction
on error undo main-block, return error
:
    assign
      ub.fin-ob-trn.id = next-value (s-trn-fo , {&db-name_schema} )
      ub.fin-ob-trn.corr-user-db-num = g#db-num
    .
/* Для живых накладных историю создания ФО */
define buffer buf_trn-doc for ub.trn-doc  .
find first buf_trn-doc no-lock where   buf_trn-doc.doc-code  =  ub.fin-ob-trn.trn-doc-code no-error .
if available buf_trn-doc then do:
  run str/trn-hist.p
    (buffer buf_trn-doc ,
    input  buf_trn-doc.obj-type ,
    input  buf_trn-doc.obj-code ,
    input  "ФО"
    ) no-error .
end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-ob-trn}
        , input ( buffer ub.fin-ob-trn:handle )
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