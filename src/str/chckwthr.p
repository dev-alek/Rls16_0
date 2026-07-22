block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chckwthr.p $
$Archive: str/chckwthr.p $

Запуск процедуры рождения чека МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/


/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: chckwthr.p $":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/chckwthr.p $":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "Запуск процедуры ргждения чека МЦ":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }


define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .


define variable loc#log as logical no-undo .

do
on error undo, return error return-value
:

  { gbl/getcntxt.i get }

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    parobj-type
    parobj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-receipt_input':U
    {&cntxt-object}
    v-chk-act-host-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    loc#log
  }

  if loc#log <> true
  then do:
    return .
  end.

  run str/checkwth.w (
                  input parparentproc
                  ,input par-mode
                  ,input parobj-type
                  ,input parobj-code
                  ,input-output v-doc-rec
                  ,input ?
                  ,input-output next-prev
                  ) no-error.
  if error-status :error
  then do:
    return error.
  end.
end.