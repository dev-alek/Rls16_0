block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает текущее свободное количество признака на объекте

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input parameter  p-obj-type  like ub.prt-obj.obj-type  no-undo .
define input parameter  p-obj-code  like ub.prt-obj.obj-code  no-undo .
define input parameter  p-artic     like ub.prt-obj.artic     no-undo .
define input parameter  p-prod-type like ub.prt-obj.prod-type no-undo .
define input parameter  p-prod-code like ub.prt-obj.prod-code no-undo .
define input parameter  p-node-code like ub.prt-obj.prt-code  no-undo .
define output parameter p-free-qnty like ub.prt-obj.free-qnty no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Возвращает текущее свободное количество признака на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_prt-obj for prt-obj .

find first buf_prt-obj
  where buf_prt-obj.obj-type  = p-obj-type
    and buf_prt-obj.obj-code  = p-obj-code
    and buf_prt-obj.artic     = p-artic
    and buf_prt-obj.prod-type = p-prod-type
    and buf_prt-obj.prod-code = p-prod-code
    and buf_prt-obj.prt-code  = p-node-code
  no-error .

if available buf_prt-obj then do:
  assign
    p-free-qnty = buf_prt-obj.free-qnty
  .
end.
else do:
  assign
    p-free-qnty = 0
  .
end.