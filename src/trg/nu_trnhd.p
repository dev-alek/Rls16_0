block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что шапку документа необходимо пересчитать

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 06/21/00

*/

define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что шапку документа необходимо пересчитать".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

{ trg/btpr_upd.i
  &btpr-status="create"
  &btpr-type="{&btpr-type-trnhd}"
  &charkey_one=p-doc-code
}