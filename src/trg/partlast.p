block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение срока годности для партии приходной накладной и для всех партий, которые были получены из этой партии

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 08/05/04

TODO - основные проблемы:

  Не обновляется информация в УБД .

  Что делать с пакетами новостей, которые идут из УБД в офисную БД
  и затем будут разбираться .
  Возможно необходимо копировать значение срока годности партии из таблицы атрибутов партии

*/

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
  /* блокируем товар на всех объектах */
  for each ub.gds-obj no-lock
    where ub.gds-obj.gds-code = p-gds-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.

  { gbl/arptpc.i
    p-gds-code
    v-artic
    v-prod-type
    v-prod-code
  }

  /* обновляем ГТД в атрибуте исходной партии */
  find first buf_parts-attr exclusive-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
    no-error .
  if available buf_parts-attr
  then do:
    assign
      buf_parts-attr.last-date = p-last-date
    .
  end.

  /* просматривается исходная партия и все партии, которые были получены из нее */
  for each ub.parts share-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = v-artic
      and ub.parts.prod-type = v-prod-type
      and ub.parts.prod-code = v-prod-code
      and ub.parts.part-code = p-part-code
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