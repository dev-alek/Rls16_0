block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: glthbjat.p $
$Archive: adm/glthbjat.p $

Глобальные параметры

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/07
Author: Bakhtadze Natalya
Creation date: 05/26/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: glthbjat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/glthbjat.p $":U .
define variable vss-description as character no-undo init "Глобальные параметры".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
{ adm/shattrg.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i get }

if p-mode <> "update"
and p-mode <> "lookup" then do:
  message
  substitute("Неверное значение параметра p-mode=&1", p-mode)
  view-as alert-box .
  return.
end.

run proc-b-attr in this-procedure (
                                    input (if p-mode = "update"
                                           then {&update}
                                           else {&lookup})
                                   ,input '':U
                                   ,input 0
                                           ).