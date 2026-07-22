block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sh-finob.p $
$Archive: str/sh-finob.p $

Просмотр ФО по recid fin-ob

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 03/25/04 3:38


*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-recid       as recid no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: sh-finob.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/sh-finob.p $":U .
def var vss-description as character no-undo init "Просмотр ФО по recid fin-ob".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define new shared buffer buf_fin-liab for ub.fin-ob .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .

{ gbl/getcntxt.i get }

find first buf_fin-liab no-lock where recid(buf_fin-liab) = p-recid no-error .
if error-status :error then do:
   message  "Не найдено ФО с recid = " p-recid .
   return error .
end.

define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}


if not g-log then  return .

define variable rr as recid no-undo .

    if available buf_fin-liab then do:
        rr = recid( buf_fin-liab ).
        br-handle = ? .
        next-prev = no.
        run str/fi-liabi.w
         ( input parParentProc,
           input {&lookup} ,
           input-output rr ,
           input par-host-code  ,
           input buf_fin-liab.doc-type,
           input buf_fin-liab.status_
           ).
     end.