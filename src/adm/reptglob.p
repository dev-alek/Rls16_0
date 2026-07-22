block-level on error undo, throw.
/*

$Revision: 9721f156f19a, 502, rls $
$Author: EShklyar $
$Date: Sun Feb 28 19:23:25 2016 +0400 $
$Workfile: reptglob.p $
$Archive: adm/reptglob.p $

Вызов списка фирменных параметров для отчетов

Автор: Гридчина Полина Дмитриевна
Дата создания: 17/12/10
Author: Mikhail Pervakov
Creation date: 17/12/10

*/
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 9721f156f19a, 502, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Sun Feb 28 19:23:25 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: reptglob.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/reptglob.p $":U .
define variable vss-description as character no-undo initial "Вызов списка фирменных параметров для отчетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
 main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run gbl/reportpa.w (
  input parparentproc  ,
  input p-mode         ,
  input p-obj-type     ,
  input p-obj-code     ,
  input 'glob':U) .
end.