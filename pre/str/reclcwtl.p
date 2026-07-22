block-level on error undo, throw.
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter pardelfact-order as decimal no-undo .
define input parameter p-wth-code       like ub.wealth.wth-code      no-undo .
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
define variable vss-workfile    as character no-undo init "$Workfile: reclcwtl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/reclcwtl.p $":U .
define variable vss-description as character no-undo init "Пересчет остатков мат ценностей начиная с fact-order предшествующего данному по одной МЦ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wth-obj-hist :
define parameter buffer buf_wth-obj for ub.wth-obj.
define input parameter p-obj-type like ub.wth-obj.obj-type no-undo .
define input parameter p-obj-code like ub.wth-obj.obj-code no-undo .
define input parameter p-wth-code like ub.wth-obj.wth-code no-undo .
define input parameter p-action-type as character no-undo .
define input  parameter p-source-type        as character no-undo .
define input  parameter p-source-ref         as character no-undo .
define input  parameter p-source-date        as date      no-undo .
define input  parameter p-corr-user-db-num   as integer   no-undo .
define input  parameter p-corr-user-name     as character no-undo .
define input  parameter p-corr-date          as date      no-undo .
define input  parameter p-corr-time          as integer   no-undo .
define input  parameter p-corr-time-str      as character no-undo .
define variable v-new-chip-num as integer   no-undo .
define buffer buf_c-wth-obj for ub.c-wth-obj .
  do
  for buf_c-wth-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-wth-obj exclusive-lock
      where buf_c-wth-obj.obj-type = buf_wth-obj.obj-type
        and buf_c-wth-obj.obj-code = buf_wth-obj.obj-code
        and buf_c-wth-obj.wth-code = buf_wth-obj.wth-code
        and buf_c-wth-obj.corr-user-db-num = p-corr-user-db-num
      use-index pi
      no-error .
    if available buf_c-wth-obj
    then do:
      assign
        v-new-chip-num = buf_c-wth-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.
    create buf_c-wth-obj .
    if p-action-type = 'delete':U
    and
    not available buf_wth-obj then do:
      assign
      buf_c-wth-obj.obj-type = p-obj-type
      buf_c-wth-obj.obj-code = p-obj-code
      buf_c-wth-obj.wth-code = p-wth-code
      .
    end.
    else do:
      buffer-copy buf_wth-obj to
      buf_c-wth-obj.
    end.
    assign
      buf_c-wth-obj.chip-num          = v-new-chip-num
      buf_c-wth-obj.action-type       = p-action-type
      buf_c-wth-obj.source-type       = p-source-type
      buf_c-wth-obj.source-ref        = p-source-ref
      buf_c-wth-obj.source-date       = p-source-date
      buf_c-wth-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-wth-obj.corr-user-name    = p-corr-user-name
      buf_c-wth-obj.corr-date         = p-corr-date
      buf_c-wth-obj.corr-time         = p-corr-time
      buf_c-wth-obj.corr-time-str     = p-corr-time-str
    .
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wth-pobj-hist :
define parameter buffer buf_wth-pobj for ub.wth-pobj.
define input parameter p-obj-type like ub.wth-pobj.obj-type no-undo .
define input parameter p-obj-code like ub.wth-pobj.obj-code no-undo .
define input parameter p-wth-code like ub.wth-pobj.wth-code no-undo .
define input parameter p-w-p-code like ub.wth-pobj.w-p-code no-undo .
define input parameter p-action-type as character no-undo .
define input  parameter p-source-type        as character no-undo .
define input  parameter p-source-ref         as character no-undo .
define input  parameter p-source-date        as date      no-undo .
define input  parameter p-corr-user-db-num   as integer   no-undo .
define input  parameter p-corr-user-name     as character no-undo .
define input  parameter p-corr-date          as date      no-undo .
define input  parameter p-corr-time          as integer   no-undo .
define input  parameter p-corr-time-str      as character no-undo .
define variable v-new-chip-num as integer   no-undo .
define buffer buf_c-wth-pobj for ub.c-wth-pobj .
  do
  for buf_c-wth-pobj
  transaction
  on error undo, return error return-value
  :
    find first buf_c-wth-pobj exclusive-lock
      where buf_c-wth-pobj.obj-type = buf_wth-pobj.obj-type
        and buf_c-wth-pobj.obj-code = buf_wth-pobj.obj-code
        and buf_c-wth-pobj.wth-code = buf_wth-pobj.wth-code
        and buf_c-wth-pobj.w-p-code = buf_wth-pobj.w-p-code
      use-index ishow
      no-error .
    if available buf_c-wth-pobj
    then do:
       assign
        v-new-chip-num = buf_c-wth-pobj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.
    create buf_c-wth-pobj .
    if p-action-type = 'delete':U
    and
    not available buf_wth-pobj then do:
      assign
      buf_c-wth-pobj.obj-type = p-obj-type
      buf_c-wth-pobj.obj-code = p-obj-code
      buf_c-wth-pobj.wth-code = p-wth-code
      buf_c-wth-pobj.w-p-code = p-w-p-code
      buf_c-wth-pobj.corr-user-db-num  = p-corr-user-db-num
      .
    end.
    else do:
      buffer-copy buf_wth-pobj to buf_c-wth-pobj
      assign buf_c-wth-pobj.corr-user-db-num  = p-corr-user-db-num
      .
    end.
    assign
      buf_c-wth-pobj.chip-num          = v-new-chip-num
      buf_c-wth-pobj.action-type       = p-action-type
      buf_c-wth-pobj.source-type       = p-source-type
      buf_c-wth-pobj.source-ref        = p-source-ref
      buf_c-wth-pobj.source-date       = p-source-date
      buf_c-wth-pobj.corr-user-name    = p-corr-user-name
      buf_c-wth-pobj.corr-date         = p-corr-date
      buf_c-wth-pobj.corr-time         = p-corr-time
      buf_c-wth-pobj.corr-time-str     = p-corr-time-str
    .
  end.
end procedure.
define buffer start_wth-line for ub.wth-line.
define buffer start_wth-obj  for ub.wth-obj.
define buffer start_wth-pobj for ub.wth-pobj.
define buffer buf_wth-line   for ub.wth-line.
define buffer buf_wth-doc    for ub.wth-doc.
define variable v-host-code as integer   no-undo .
do transaction
on error undo, return error
:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
  for each start_wth-pobj exclusive-lock
    where start_wth-pobj.obj-type = parobj-type
      and start_wth-pobj.obj-code = parobj-code
      and start_wth-pobj.wth-code = p-wth-code
  on error undo, return error
  :
    find last start_wth-line no-lock
      where start_wth-line.obj-type = parobj-type
        and start_wth-line.obj-code = parobj-code
        and start_wth-line.status_ = 'факт':U
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
                                        ,input 'wth-doc':U
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
      and start_wth-obj.wth-code = p-wth-code
  on error undo, return error
  :
    find last start_wth-line no-lock
      where start_wth-line.obj-type = parobj-type
        and start_wth-line.obj-code = parobj-code
        and start_wth-line.status_ = 'факт':U
        and start_wth-line.fact-order <= pardelfact-order
        and start_wth-line.wth-code = start_wth-obj.wth-code
      no-error .
    run wth-obj-hist in this-procedure (
                                         buffer start_wth-obj
                                        ,input start_wth-obj.obj-type
                                        ,input start_wth-obj.obj-code
                                        ,input start_wth-obj.wth-code
                                        ,input 'delete':U
                                        ,input 'wth-doc':U
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
  for each buf_wth-line no-lock where buf_wth-line.obj-type = parobj-type
                          and buf_wth-line.obj-code = parobj-code
                          and buf_wth-line.wth-code = p-wth-code
                          and buf_wth-line.status_   = 'факт':U
                          AND buf_wth-line.fact-order > pardelfact-order
                          use-index stat-fact
      , first buf_wth-doc no-lock where buf_wth-doc.doc-code = buf_wth-line.doc-code
  on error undo, return error
  :
     define variable v-wth-code as integer no-undo .
     define variable v-doc-code as character no-undo .
     if v-wth-code = buf_wth-line.wth-code
     and v-doc-code = buf_wth-line.doc-code then next.
      run str/stkotwth.p
        (input recid(buf_wth-doc)
        ,input yes
        ,input p-wth-doc-close
        ,input p-wth-code) no-error.
      if error-status :error then do:
        undo, return error return-value.
      end.
      assign
      v-wth-code = buf_wth-line.wth-code
      v-doc-code = buf_wth-line.doc-code
      .
  end.
end.
