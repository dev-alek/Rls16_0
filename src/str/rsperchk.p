block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rsperchk.p $
$Archive: str/rsperchk.p $

Вызов программы ручного создания, редактирования, просмотра чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parParentProc as Widget-handle no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rsperchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rsperchk.p $":U .
define variable vss-description as character no-undo init "Вызов программы ручного создания, редактирования, просмотра чека".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable v-doc-rec as recid     no-undo .
define variable next-prev as character   no-undo .

define variable loc#log as logical no-undo .

{ gbl/getcntxt.i get }

define variable v-host-code as integer   no-undo .
{ gbl/hostcode.i
  p-obj-type
  p-obj-code
  v-host-code
}

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_receipt_input':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  loc#log
}

if not loc#log then do:
  return ''.
end.
run str/superchk.w (
                parparentproc
               ,input par-mode
               ,input p-obj-type
               ,input p-obj-code
               ,input-output v-doc-rec
               ,input ? /*thist-procedure:handle*/
               ,input-output next-prev
               ) no-error .