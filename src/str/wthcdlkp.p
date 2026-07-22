block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthcdlkp.p $
$Archive: str/wthcdlkp.p $

Просмотр одного УДАЛЕННОГО документа МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/05
Author: Bakhtadze Natalya
Creation date: 08/15/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter  p-rid as recid no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthcdlkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthcdlkp.p $":U .
define variable vss-description as character no-undo init "Просмотр одного УДАЛЕННОГО документа МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable glog as logical no-undo .
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_c-wth-doc for ub.c-wth-doc.

find first buf_c-wth-doc no-lock where recid(buf_c-wth-doc) = p-rid no-error.

if NOT available buf_c-wth-doc then  do:
  message
  "Неправильный выбор удаленного документа МЦ."
  view-as alert-box WARNING .
  return no-apply.
end.

{ gbl/getcntxt.i get }

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_wth-doc_lookup':U
  {&cntxt-object}
  buf_c-wth-doc.host-code
  buf_c-wth-doc.obj-type
  buf_c-wth-doc.obj-code
  0
  0
  0
  true
  glog
}


if NOT glog then return .

assign
v-doc-rec = recid(buf_c-WTH-DOC)
.

CASE buf_c-wth-doc.doc-type :
WHEN {&income} OR
WHEN {&expense} OR
WHEN {&write-off} THEN DO:
    run str/wth-inc.w (  INPUT parparentproc
                    ,INPUT {&lookup}
                    ,INPUT buf_c-wth-doc.host-code
                    ,INPUT buf_c-wth-doc.obj-type
                    ,INPUT buf_c-wth-doc.obj-code
                    ,INPUT buf_c-wth-doc.cli-type
                    ,INPUT buf_c-wth-doc.cli-code
                    ,INPUT buf_c-wth-doc.ext-doc-type
                    ,INPUT buf_c-wth-doc.doc-type
                    ,INPUT buf_c-wth-doc.auto-filL
                    ,INPUT-OUTPUT v-doc-rec
                    ,input ? /*this-procedure:handle*/
                    ,input-output next-prev
                    ) no-error .
END.
WHEN {&inventory} THEN DO:
    run str/wth-inv.w (  INPUT parparentproc
                    ,INPUT {&lookup}
                    ,INPUT buf_c-wth-doc.host-code
                    ,INPUT buf_c-wth-doc.obj-type
                    ,INPUT buf_c-wth-doc.obj-code
                    ,INPUT buf_c-wth-doc.cli-type
                    ,INPUT buf_c-wth-doc.cli-code
                    ,input buf_c-wth-doc.ext-doc-type
                    ,INPUT buf_c-wth-doc.auto-fill
                    ,INPUT-OUTPUT v-doc-rec
                    ,input ? /*this-procedure:handle*/
                    ,input-output next-prev

                    ) no-error .
END.
END CASE.