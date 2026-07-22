block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление строки в ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 03/22/06
Author: Svetlana Chernova
Creation date: 03/22/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.price-doc-forming-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление строки в ДНЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-block:
do transaction
on error undo main-block, return error
on end-key undo main-block, return error
:

  for each ub.price-doc-forming-gds-qnty exclusive-lock where
          ub.price-doc-forming-gds-qnty.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-qnty.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-qnty.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-qnty.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-qnty.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-qnty .
  end.
  for each ub.price-doc-forming-gds-sum exclusive-lock where
          ub.price-doc-forming-gds-sum.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-sum.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-sum.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-sum.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-sum.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-sum .
  end.

  for each ub.price-doc-forming-gds-tnv exclusive-lock where
          ub.price-doc-forming-gds-tnv.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-tnv.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-tnv.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-tnv.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-tnv.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-tnv .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_price-doc-forming-gds}
        , input ( buffer ub.price-doc-forming-gds:handle )
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