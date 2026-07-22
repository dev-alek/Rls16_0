block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findocpr.p $
$Archive: rep/findocpr.p $

Запуск печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/15/10
Author: Bakhtadze Natalya
Creation date: 04/15/10

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findocpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/findocpr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define variable v-format as character no-undo .
define buffer buf_fin-doc for ub.fin-doc.
find first buf_fin-doc share-lock where
          recid(buf_fin-doc) = p-recid.

run rep/findocp.p (
                  INPUT parParentProc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
                ,input no /*p-append*/
                ,input yes /*p-is-last*/
                ,input yes /*p-form-form*/
                ,input-output v-format
              ) no-error.
if error-status:error then do:
  return error.
end.

