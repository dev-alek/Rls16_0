block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showfind.p $
$Archive: ref/showfind.p $

Инкапсулированный вызов на просмотр финансового документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/27/03
Author: Bakhtadze Natalya
Creation date: 11/27/03

*/

DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showfind.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/showfind.p $":U .
define variable vss-description as character no-undo init "Показать финансовый документ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable loc-doc-rec as recid no-undo .
define buffer buf_fin-doc for ub.fin-doc.

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  find first buf_fin-doc no-lock
    where buf_fin-doc.host-code    = p-host-code
      and buf_fin-doc.fin-doc-code = p-fin-doc-code
    no-error.
  if not available buf_fin-doc then do:
    return error substitute("Не найден платеж: фирма &1 внутр№ &2", p-host-code, p-fin-doc-code).
  end.
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_lookup':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if not v-ok then return error.


  CASE buf_fin-doc.fin-doc-type:
    when {&income-cash} then do:
      run ref/findoci1.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input buf_fin-doc.contract-code
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
    when {&expense-cash} then do:
      run ref/findoci2.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input 0
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
    when {&income-cashless} then do:
      run ref/findoci3.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input 0
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
    when {&expense-cashless} then do:
      run ref/findoci4.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input 0
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
    when {&income-payoff} then do:
      run ref/findoci5.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input buf_fin-doc.contract-code
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
    when {&expense-payoff} then do:
      run ref/findoci6.w
                    (
                        input parParentProc
                      ,input p-curr-host-code /*p-curr-host-code*/
                      ,input {&lookup}
                      ,input buf_fin-doc.host-code /*p-host-code*/
                      ,input buf_fin-doc.fin-doc-code /*p-fin-doc-code*/
                      ,input buf_fin-doc.obj-type    /*p-obj-type*/
                      ,input buf_fin-doc.obj-code    /*p-obj-code*/
                      ,input buf_fin-doc.fin-ext-doc-type
                      ,input 0
                      ,input '':U /*p-ob-doc-code*/
                      ,input "":U
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input "":U /*p-other*/
                      ,input-output loc-doc-rec
                                  )
      .
    end.
  END CASE.
end. /*doe*/