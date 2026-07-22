block-level on error undo, throw.
/*

$Revision: 387c9a6a2a52, 2235, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:24:00 2019 +0300 $
$Workfile: findocpr2.p $
$Archive: rep/findocpr2.p $

Запуск печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/15/10
Author: Bakhtadze Natalya
Creation date: 04/15/10

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: 387c9a6a2a52, 2235, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findocpr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/findocpr2.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define variable v-format as character no-undo .
define buffer buf_fin-doc for ub.fin-doc.
find first buf_fin-doc share-lock where
          recid(buf_fin-doc) = p-recid.
  find first ub.fin-doc-attr no-lock where ub.fin-doc-attr.attr-code = "pre-vedom"
    and ub.fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code and ub.fin-doc-attr.host-code = buf_fin-doc.host-code no-error .
    if not available (ub.fin-doc-attr) then do:
      message "У документа " + string(buf_fin-doc.prn-doc-code) + " нет препроводительной ведомости."
      view-as alert-box.
      return no-apply .
    end.  
run rep/pre-vedom.p (
                  INPUT parParentProc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
              ) no-error.
if error-status:error then do:
  return error.
end.

