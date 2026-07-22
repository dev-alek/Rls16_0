block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверяет, что шапка документа не обновлена и, если необходимо обновляет ее

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/21/00

*/

define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверяет, что шапка документа не обновлена и, если необходимо обновляет ее".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

find first BatchProcess no-lock
  where BatchProcess.bp_type     = {&btpr-type-trnhd}
    and BatchProcess.bp_status   = {&btpr-normal}
    and BatchProcess.charkey_one = p-doc-code
  no-error .
if available BatchProcess then do:
  run trg/bt_trnhd.p
    (input BatchProcess.BatchProcess#
    ).
end. /* if available batchprocess */