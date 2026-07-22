block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо пересчитать складской архив по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/13/00

*/

define input  parameter p-doc-code   as character no-undo .
define input  parameter p-table-name as character no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо пересчитать складской архив по типам приобретения".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-doc-code,p-table-name,p-obj-type,p-obj-code)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

do
on error undo, return error return-value
:
  if lookup( p-table-name, {&table_trn-doc} + {&comma-char} + {&table_price-doc}) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестнаия таблица" skip
      "doc-code"   p-doc-code skip
      "table-name" p-table-name skip
      view-as alert-box error .
    undo, return error .
  end.

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-aht}"
    &charkey_one=p-doc-code
    &charkey_two=p-table-name
    &charkey_three=p-obj-type
    &key#_one=p-obj-code
  }

end.