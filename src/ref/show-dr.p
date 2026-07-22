block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: show-dr.p $
$Archive: ref/show-dr.p $

Просмотр правила скидки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/26/07
Author: Bakhtadze Natalya
Creation date: 06/26/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rule-num as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: show-dr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/show-dr.p $":U .
define variable vss-description as character no-undo init "Просмотр правила скидки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/disrules.i work }

define variable loc-doc-rec as recid no-undo .
define variable glog as logical no-undo .
define variable v-branch-rl-root as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

   { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_discount_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
    }
    if not glog then return .
    FIND FIRST buf_Dis-rule NO-LOCK WHERE
              buf_Dis-rule.rule-num = p-rule-num NO-ERROR.
    IF NOT AVAILABLE buf_Dis-rule THEN do:
      message
      substitute("Не найдено правило скидки &1", p-rule-num)
      view-as alert-box error .
      RETURN error.
    end.
    if buf_dis-rule.root = no then do:
      assign
      v-branch-rl-root = buf_dis-rule.rl-root
      .
      FIND FIRST buf_Dis-rule NO-LOCK WHERE
                buf_Dis-rule.rule-num = v-branch-rl-root NO-ERROR.
      IF NOT AVAILABLE buf_Dis-rule THEN do:
        message
        substitute("Не найдено правило скидки &1", v-branch-rl-root)
        view-as alert-box error .
        RETURN error.
      end.
    end.
    ASSIGN
    loc-doc-rec = recid(buf_dis-rule)
    .
    define variable v-form-name as character no-undo init "ref/dis-ruli.w".
    run disrules-get-interface-form in this-procedure ( input buf_dis-rule.templ-rl-root
                                                      ,output v-form-name) .
    run value(v-form-name) (
                             input parParentProc
                            ,input {&lookup}
                            ,input buf_dis-rule.templ-rl-root
                            ,input buf_dis-rule.host-code
                            ,input buf_dis-rule.obj-type
                            ,input buf_dis-rule.obj-code
                            ,input buf_dis-rule.rule-num /*p-rule-num*/
                            ,input buf_dis-rule.upper-rule-num
                            ,input 0 /*p-b-code*/
                            ,input buf_dis-rule.time-templ-rl-root
                            ,input '':U /*p-pos-type*/
                            ,input-output loc-doc-rec
                                        ) no-error .

end. /*doe*/