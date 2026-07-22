block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение кода ГТД для партии приходной накладной и для всех партий, которые были получены из этой партии

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 01/10/01

TODO - основные проблемы:

  Не обновляется информация в УБД .

  Что делать с пакетами новостей, которые идут из УБД в офисную БД
  и затем будут разбираться .

*/

define input parameter p-cst-code  like ub.parts.cst-code  no-undo .
define input parameter p-in-code   like ub.parts.in-code   no-undo .
define input parameter p-artic     like ub.parts.artic     no-undo .
define input parameter p-prod-type like ub.parts.prod-type no-undo .
define input parameter p-prod-code like ub.parts.prod-code no-undo .
define input parameter p-part-code like ub.parts.part-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение кода ГТД для партии приходной накладной ".
{ cmp/vssrevis.i }
{ cmp/library.i  }

define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_parts for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .

main-block:
do transaction
on error undo main-block, return error
:
  /* блокируем товар на всех объектах */
  for each ub.gds-obj no-lock
    where ub.gds-obj.artic     = p-artic
      and ub.gds-obj.prod-type = p-prod-type
      and ub.gds-obj.prod-code = p-prod-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.

  define variable v-gds-code as integer   no-undo .
  { gbl/gds-code.i
    p-artic
    p-prod-type
    p-prod-code
    v-gds-code
  }

  /* обновляем ГТД в атрибуте исходной партии */
  find first buf_parts-attr exclusive-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = v-gds-code
      and buf_parts-attr.part-code = p-part-code
    no-error .
  if available buf_parts-attr
  then do:
    assign
      buf_parts-attr.cst-code = p-cst-code
    .
  end.

  /* просматривается исходная партия и все партии, которые были получены из нее */
  for each ub.parts no-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.part-code = p-part-code
  on error undo main-block, return error
  :
    if ub.parts.cst-code <> p-cst-code then do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.cst-code = p-cst-code
      .
    end.
  end.
end.