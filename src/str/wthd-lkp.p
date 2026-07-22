block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthd-lkp.p $
$Archive: str/wthd-lkp.p $

Просмотр одного документа МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter  p-rid as recid no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthd-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthd-lkp.p $":U .
define variable vss-description as character no-undo init "Просмотр одного документа МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable glog as logical no-undo .
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_wth-doc for ub.wth-doc.


do
on error undo, return error return-value
:
  find first buf_wth-doc no-lock where recid(buf_wth-doc) = p-rid no-error.
  if not available buf_wth-doc then  do:
    message
      "Неправильный выбор документа МЦ."
      view-as alert-box warning .
    return no-apply.
  end.

  { gbl/getcntxt.i get }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_lookup':U
    {&cntxt-object}
    buf_wth-doc.host-code
    buf_wth-doc.obj-type
    buf_wth-doc.obj-code
    0
    0
    0
    true
    glog
  }
  if not glog then return .

  assign
  v-doc-rec = recid(buf_WTH-DOC)
  .


  case buf_wth-doc.doc-type :
  when {&income}   or
  when {&expense}  or
  when {&write-off}
  then do:
    run str/wth-inc.w
      ( input parparentproc
      ,input {&lookup}
      ,input buf_wth-doc.host-code
      ,input buf_wth-doc.obj-type
      ,input buf_wth-doc.obj-code
      ,input buf_wth-doc.cli-type
      ,input buf_wth-doc.cli-code
      ,input buf_wth-doc.ext-doc-type
      ,input buf_wth-doc.doc-type
      ,input buf_wth-doc.auto-fill
      ,input-output v-doc-rec
      ,input ? /*this-procedure:handle*/
      ,input-output next-prev
      ).

  end.
  when {&inventory}
  then do:
    run str/wth-inv.w
      ( input parparentproc
      ,input {&lookup}
      ,input buf_wth-doc.host-code
      ,input buf_wth-doc.obj-type
      ,input buf_wth-doc.obj-code
      ,input buf_wth-doc.cli-type
      ,input buf_wth-doc.cli-code
      ,input buf_wth-doc.ext-doc-type
      ,input buf_wth-doc.auto-fill
      ,input-output v-doc-rec
      ,input ? /*this-procedure:handle*/
      ,input-output next-prev
      ).
  end.
  end case.
end.