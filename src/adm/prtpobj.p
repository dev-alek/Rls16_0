block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prtpobj.p $
$Archive: adm/prtpobj.p $

Вызов списка объектных параметров для печатных форм

Автор: Гридчина Полина Дмитриевна
Дата создания: 17/12/10
Author: Mikhail Pervakov
Creation date: 17/12/10

*/
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prtpobj.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/prtpobj.p $":U .
define variable vss-description as character no-undo initial "Вызов списка объектных параметров для печатных форм".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
 main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run gbl/prtpa.w (
  input parparentproc  ,
  input p-mode         ,
  input p-obj-type     ,
  input p-obj-code     ,
  input 'obj':U) .
end.
