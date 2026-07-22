block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shwcfind.p $
$Archive: ref/shwcfind.p $

Инкапсулированный вызов на просмотр ИСТОРИИ финансового документа

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
define input parameter p-corr-user-db-num as integer no-undo .
define input parameter p-chip-num as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shwcfind.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/shwcfind.p $":U .
define variable vss-description as character no-undo init "Показать историю финансового документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable loc-doc-rec as recid no-undo .
define buffer buf_c-fin-doc for ub.c-fin-doc.

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  find first buf_c-fin-doc no-lock
    where buf_c-fin-doc.host-code    = p-host-code
      and buf_c-fin-doc.fin-doc-code = p-fin-doc-code
      and buf_c-fin-doc.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc.chip-num = p-chip-num
    no-error.
  if not available buf_c-fin-doc then do:
    return error substitute("Не найдена история платежа: фирма &1 внутр№ &2 БД изменений &3 срез &4"
                             , p-host-code
                             , p-fin-doc-code
                             , p-corr-user-db-num
                             , p-chip-num
                             ).
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

  assign
  loc-doc-rec = recid(buf_c-fin-doc).
  CASE buf_c-fin-doc.fin-doc-type:
    when {&income-cash} then do:
            run ref/fncdoci1.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-cash} then do:
            run ref/fncdoci2.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&income-cashless} then do:
            run ref/fncdoci3.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-cashless} then do:
            run ref/fncdoci4.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&income-payoff} then do:
            run ref/fncdoci5.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-payoff} then do:
            run ref/fncdoci6.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
END CASE.

end. /*doe*/