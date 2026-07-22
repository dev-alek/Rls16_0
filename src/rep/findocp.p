block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findocp.p $
$Archive: rep/findocp.p $

Печать одного платежа с разбором в зависимости от типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/03
Author: Bakhtadze Natalya
Creation date: 11/19/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findocp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/findocp.p $":U .
define variable vss-description as character no-undo init "Печать одного платежа с разбором в зависимости от типа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-format as integer no-undo .
/*1 landscape 0-Portrait*/
define buffer buf_fin-doc for ub.fin-doc.

do
on error undo, return error
:
  assign
  v-format = p-format
  .
  find first buf_fin-doc no-lock where
            buf_fin-doc.host-code = p-host-code
        AND buf_fin-doc.fin-doc-code = p-fin-doc-code .
  CASE buf_fin-doc.fin-doc-type:
    when {&income-cash} then do:
      run rep/pko-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when {&expense-cash} then do:
      run rep/rko-2.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when {&income-cashless}
    or
    when {&expense-cashless}
    then do:
      run rep/rpp-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when {&income-payoff} then do:
      run rep/apz-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when {&expense-payoff} then do:
      run rep/apz-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
  END CASE.
  assign
  p-format = v-format
  .
end. /*doe*/