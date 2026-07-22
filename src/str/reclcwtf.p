block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: reclcwtf.p $
$Archive: str/reclcwtf.p $

Пересчет остатков мат ценностей начиная с fact-order предшествующего данному

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter pardelfact-order as decimal no-undo .
define input parameter p-wth-doc-close as logical no-undo .
define input parameter p-hist-action as character no-undo .
define input parameter p-doc-code       like ub.wth-doc.doc-code no-undo .
define input parameter p-fact-date      like ub.wth-doc.fact-date    no-undo .
define input parameter p-user-db-num    like ub.wth-doc.user-db-num  no-undo .
define input parameter p-user-name      like ub.wth-doc.user-name    no-undo .
define input parameter p-sys-date       like ub.wth-doc.sys-date     no-undo .
define input parameter p-sys-time-int   like ub.wth-doc.sys-time-int no-undo .
define input parameter p-sys-time       like ub.wth-doc.sys-time     no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: reclcwtf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/reclcwtf.p $":U .
define variable vss-description as character no-undo init "Пересчет остатков мат ценностей начиная с fact-order предшествующего данному".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ trg/cwthobjh.i }
{ trg/cwthpbjh.i }

define buffer start_wth-line for ub.wth-line.
define buffer start_wth-obj for ub.wth-obj.
define buffer start_wth-pobj for ub.wth-pobj.
define variable v-host-code as integer   no-undo .

do transaction
on error undo, return error
:

  { gbl/hostcode.i
    parobj-type
    parobj-code
    v-host-code
  }

  /*Инициализируем остатки по объекту-субобъекту*/
  for each start_wth-pobj exclusive-lock
    where start_wth-pobj.obj-type = parobj-type
      and start_wth-pobj.obj-code = parobj-code
  on error undo, return error
  :
    find last start_wth-line no-lock
      where start_wth-line.obj-type = parobj-type
        and start_wth-line.obj-code = parobj-code
        and start_wth-line.status_ = {&fact}
        and start_wth-line.fact-order <= pardelfact-order
        and start_wth-line.wth-code = start_wth-pobj.wth-code
        and start_wth-line.w-p-code = start_wth-pobj.w-p-code
      no-error .
    run wth-pobj-hist in this-procedure (
                                          buffer start_wth-pobj
                                        ,input start_wth-pobj.obj-type
                                        ,input start_wth-pobj.obj-code
                                        ,input start_wth-pobj.wth-code
                                        ,input start_wth-pobj.w-p-code
                                        ,input p-hist-action
                                        ,input {&table_wth-doc}
                                        ,input p-doc-code
                                        ,input p-fact-date
                                        ,input p-user-db-num
                                        ,input p-user-name
                                        ,input p-sys-date
                                        ,input p-sys-time-int
                                        ,input p-sys-time
                                        ).
    if available start_wth-line
    then do:
      assign
        start_wth-pobj.incass-pl       = start_wth-line.incass-pl
        start_wth-pobj.income-pl       = start_wth-line.income-pl
        start_wth-pobj.incass-bank-pl  = start_wth-line.incass-bank-pl
        start_wth-pobj.incass-other-pl = start_wth-line.incass-other-pl
        start_wth-pobj.incass-cassa-pl = start_wth-line.incass-cassa-pl
        start_wth-pobj.income-cassa-pl = start_wth-line.income-cassa-pl
        start_wth-pobj.income-other-pl = start_wth-line.income-other-pl
      .
    end.
    else do:
      assign
        start_wth-pobj.incass-pl       = 0
        start_wth-pobj.income-pl       = 0
        start_wth-pobj.incass-bank-pl  = 0
        start_wth-pobj.incass-other-pl = 0
        start_wth-pobj.incass-cassa-pl = 0
        start_wth-pobj.income-cassa-pl = 0
        start_wth-pobj.income-other-pl = 0
      .
    end.
  end.

  for each start_wth-obj exclusive-lock
    where start_wth-obj.obj-type = parobj-type
      and start_wth-obj.obj-code = parobj-code
  on error undo, return error
  :
    find last start_wth-line no-lock
      where start_wth-line.obj-type = parobj-type
        and start_wth-line.obj-code = parobj-code
        and start_wth-line.status_ = {&fact}
        and start_wth-line.fact-order <= pardelfact-order
        and start_wth-line.wth-code = start_wth-obj.wth-code
      no-error .
    run wth-obj-hist in this-procedure (
                                         buffer start_wth-obj
                                        ,input start_wth-obj.obj-type
                                        ,input start_wth-obj.obj-code
                                        ,input start_wth-obj.wth-code
                                        ,input {&c-wth-obj_delete}
                                        ,input {&table_wth-doc}
                                        ,input p-doc-code
                                        ,input p-fact-date
                                        ,input p-user-db-num
                                        ,input p-user-name
                                        ,input p-sys-date
                                        ,input p-sys-time-int
                                        ,input p-sys-time
                                        ).

    if avail start_wth-line then do:
      assign
        start_wth-obj.incass           = start_wth-line.incass
        start_wth-obj.income           = start_wth-line.income
        start_wth-obj.incass-bank      = start_wth-line.incass-bank
        start_wth-obj.incass-other     = start_wth-line.incass-other
        start_wth-obj.incass-cassa     = start_wth-line.incass-cassa
        start_wth-obj.income-cassa     = start_wth-line.income-cassa
        start_wth-obj.income-other     = start_wth-line.income-other
      .
    end.
    else do:
      assign
        start_wth-obj.incass           = 0
        start_wth-obj.income           = 0
        start_wth-obj.incass-bank      = 0
        start_wth-obj.incass-other     = 0
        start_wth-obj.incass-cassa     = 0
        start_wth-obj.income-cassa     = 0
        start_wth-obj.income-other     = 0
      .
    end.
  end.

  for each ub.wth-doc
    where ub.wth-doc.host-code = v-host-code
      and ub.wth-doc.obj-type  = parobj-type
      and ub.wth-doc.obj-code  = parobj-code
      and ub.wth-doc.status_   = {&fact}
      AND ub.wth-doc.fact-order > pardelfact-order
  on error undo, return error
  :
    run str/stkotwth.p
      (input recid(ub.wth-doc)
      ,input yes
      ,input p-wth-doc-close /*для имеющихся документов*/
      ,input 0) no-error.
    if error-status :error then do:
      undo, return error return-value.
    end.
  end.

end.