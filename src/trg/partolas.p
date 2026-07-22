block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение срока годности для партии на объекте

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 08/05/04

*/

define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-in-code    as character no-undo .
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-part-code  as character no-undo .
define input  parameter p-last-date  as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение срока годности для партии приходной накладной".
{ cmp/vssrevis.i }
{ cmp/library.i  }

define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_parts for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .

define variable v-artic     as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer   no-undo .

main-block:
do transaction
on error undo main-block, return error
:
  /* блокируем товар на объекте */
  find first buf_gds-obj exclusive-lock
    where buf_gds-obj.gds-code = p-gds-code
      and buf_gds-obj.obj-type = p-obj-type
      and buf_gds-obj.obj-code = p-obj-code
    no-error .
  if not available buf_gds-obj
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена запись товар на объекте" skip
      "Объект" p-obj-type p-obj-code skip
      "Код товара" p-gds-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/arptpc.i
    p-gds-code
    v-artic
    v-prod-type
    v-prod-code
  }

  /* просматриваются все партии на объекте */
  for each ub.parts share-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = v-artic
      and ub.parts.prod-type = v-prod-type
      and ub.parts.prod-code = v-prod-code
      and ub.parts.part-code = p-part-code
      and ub.parts.obj-type  = p-obj-type
      and ub.parts.obj-code  = p-obj-code
  on error undo main-block, return error
  :
    if ub.parts.last-date <> p-last-date
    then do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.last-date = p-last-date
      .
    end.
  end.
end.