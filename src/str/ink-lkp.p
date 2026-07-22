block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ink-lkp.p $
$Archive: str/ink-lkp.p $

Простой просмотр продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

define input parameter parparentproc as handle no-undo.
define input parameter t-rid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ink-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/ink-lkp.p $":U .
define variable vss-description as character no-undo init "Простой просмотр продажи".
{ cmp/vssrevis.i }
/* простой просмотр любой записи ink-doc */
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }


define variable glog as logical no-undo .

DEFINE VARiable           v-call-handle as handle no-undo.
DEFINE BUFFER    ink-doc FOR ub.inkas.
define variable next-prev as character no-undo init ?.
define variable v-doc-rec as recid no-undo .

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  find first  ink-doc where recid( ink-doc ) = t-rid no-lock.

  if NOT available ink-doc then   do:
      message "Неправильный выбор кассового отчета."
                      view-as alert-box WARNING .
      return error.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_sale_lookup':U
    {&cntxt-object}
    ink-doc.host-code
    ink-doc.obj-type
    ink-doc.obj-code
    0
    0
    0
    true
    glog
  }

  if NOT glog then return .
  assign
  v-doc-rec = recid(ink-doc)
  v-call-handle = ?
  next-prev = ?
  .
  run str/sale.w (
             input parparentproc
            ,input {&lookup}
            ,input-output v-doc-rec
            ,input-output v-call-handle /*p-call-handle*/
            ,input-output next-prev
            ,buffer ink-doc
            ).
end. /*doe*/