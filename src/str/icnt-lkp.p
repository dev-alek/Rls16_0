block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: icnt-lkp.p $
$Archive: str/icnt-lkp.p $

Показать инвентаризацию счетчков ТРК

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-icnt-doc-recid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: icnt-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/icnt-lkp.p $":U .
define variable vss-description as character no-undo init "Показать инвентаризацию счетчков ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }


do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  define variable v-icnt-line-rec as recid no-undo .
  define variable next-prev as character no-undo .
  define buffer buf_icnt-doc for ub.icnt-doc .

  find buf_icnt-doc no-lock
    where recid(buf_icnt-doc) = p-icnt-doc-recid
    no-error.
  if available buf_icnt-doc
  then do:
    define variable v-recid as recid     no-undo .
    assign
      v-recid = p-icnt-doc-recid
    .

    define variable v-ok as logical   no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_icnt-doc_lookup':U
      {&cntxt-object}
      buf_icnt-doc.host-code
      buf_icnt-doc.obj-type
      buf_icnt-doc.obj-code
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      return .
    end.
    CASE buf_icnt-doc.doc-type:
      when {&icnt-doc} then do:
        run ref/icntdoci.w ( INPUT parparentproc
                        ,INPUT {&lookup}
                        ,INPUT buf_icnt-doc.obj-type
                        ,INPUT buf_icnt-doc.obj-code
                        ,input-output p-icnt-doc-recid
                        ,input-output v-icnt-line-rec
                        ,input this-procedure:handle
                        ,input-output next-prev
                        ) no-error .
      end.
      when {&icnt-err} then do:
        run ref/icntdoce.w ( INPUT parparentproc
                        ,INPUT {&lookup}
                        ,INPUT buf_icnt-doc.obj-type
                        ,INPUT buf_icnt-doc.obj-code
                        ,input-output p-icnt-doc-recid
                        ,input-output v-icnt-line-rec
                        ,input this-procedure:handle
                        ,input-output next-prev
                        ) no-error .

      end.
    end case.
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      view-as alert-box error .
    undo, return error return-value .
  end.


end.