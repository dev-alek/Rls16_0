block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-cnt.p $
$Archive: str/inv-cnt.p $

Просмотр разбивки по договору поставки для документа инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/16/05


*/
define input parameter parparentproc as handle    no-undo.
define input parameter p-doc-code    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-cnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inv-cnt.p $":U .
define variable vss-description as character no-undo init "Просмотр разбивки по договору поставки для документа инвентаризации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_sysconf for ub.sysconf.

do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  find first buf_sysconf no-lock
    where buf_sysconf.host-code = buf_trn-doc.host-code
    .

  define variable v-ok as logical   no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    buf_trn-doc.host-code
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    0
    0
    0
    true
    v-ok
  }
  if v-ok <> true then do:
    return error .
  end.
  run str/scntdoc.w
    (input  buf_trn-doc.doc-code                     /* pardoc-code */
    ,input  v-cntxt-db-num = buf_sysconf.firm-db-num /* parfin-db   */
    ).
end.