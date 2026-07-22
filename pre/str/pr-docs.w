define input  parameter parParentProc as widget-handle no-undo.
define input  parameter bttns         as character no-undo .
define input  parameter list-mode     as character no-undo .
define input  parameter g#stat        as character no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-doc-rec     as character no-undo .
define output parameter mark-list     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Cписок документов переоценки ".
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
define new global shared variable g#lib-log as handle no-undo .
define variable doc-rec as recid no-undo .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable next-prev    as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-host-code  as integer   no-undo .
define variable v-host-name  as character no-undo .
define variable v-obj-db-num as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-user-name  as character no-undo .
define variable v-user-name-corr as character no-undo .
define variable v-doc-rec    as recid     no-undo .
define variable v-log-handle as handle    no-undo .
define variable v-mess as character no-undo .
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable varoldstatus        as character no-undo .
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
if (valid-handle(g#lib-log) <> true) then do:   run gbl/lib-log.p persistent no-error .   if error-status :error or (valid-handle(g#lib-log) <> true) then do:     message       "Error starting gbl/lib-log.p" skip       g#lib-log skip       g#lib-log :type skip       g#lib-log :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-log_get-log-handle in g#lib-log
  (output  v-log-handle
  )  .
run get-report-num in parParentProc ( output g#report-num ).
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
def new shared var br-handle as handle no-undo.
def new shared buffer sch-cli for clients.
def new shared buffer p-doc         for ub.price-doc.
define buffer p-d-b                 for ub.price-doc.
define buffer sch_price-list-type   for ub.price-list-type    .
define buffer sch_price-doc-forming for ub.price-doc-forming  .
define variable sch-field as character no-undo.
define variable mark      as character no-undo.
define variable filter-point as character no-undo init "Список переоценок" .
define variable filter-point0 as character no-undo init "Список_переоценок" .
define variable sort-column-name as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable old-list as character no-undo .
define variable old-stat as character no-undo .
define variable g#log    as logical   no-undo .
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE  12 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE  12 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE  12 BY 1.
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE  12 BY 1.
DEFINE BUTTON b-history
     LABEL "&История":L
     SIZE  12 BY 1.
DEFINE BUTTON b-print
     LABEL "Печат&ь":L
     SIZE 12 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1
     TOOLTIP "Отметить текущий документ"
     .
DEFINE BUTTON b-markAll
     LABEL "&+":L
     SIZE 3 BY 1
     TOOLTIP "Отметить все"
     .
DEFINE BUTTON b-demark
     LABEL "&-":L
     SIZE 3 BY 1
     TOOLTIP "Снять все отметки"
     .
DEFINE BUTTON b-quit AUTO-go
     LABEL "&Выход ":L
     SIZE 12 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE  12 BY 1.
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE  12 BY 1.
DEFINE BUTTON b-copy
     LABEL "&Копии":L
     tooltip "Скопировать переоценку по выбранным объектам"
     SIZE  12 BY 1.
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2 NO-UNDO.
DEFINE new shared VARIABLE sch-code AS CHARACTER format "x(12)" VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
DEFINE new shared VARIABLE sch-date AS date VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
DEFINE new shared VARIABLE sch-fact AS date VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
define new shared variable sch-num as integer view-as fill-in size 3 by 1 no-undo.
DEFINE new shared QUERY br-docs FOR p-doc SCROLLING.
FUNCTION mark-string RETURN CHAR (buffer loc-p-doc for p-doc , input mark-list as character ).
  if lookup ( string(recid (loc-p-doc)) , mark-list ) > 0 then RETURN "*".
  else RETURN "".
END FUNCTION.
DEFINE BROWSE br-docs QUERY br-docs NO-LOCK DISPLAY
      mark-string ( buffer p-doc , input mark-list) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
      p-doc.status_    COLUMN-LABEL "Статус"
      p-doc.doc-num format "x(12)"
      p-doc.doc-date   column-label "Дата"
      p-doc.fact-date  COLUMN-LABEL "Факт"
      (trim (p-doc.obj-type) + string (p-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "x(8)"
      p-doc.rest-qnty  column-label "Кол-во"
      p-doc.sale-base  COLUMN-LABEL "Сумма "  FORMAT "->>>>>,>>>,>>>.99"
      p-doc.rest-sale  COLUMN-LABEL "Было "
      p-doc.pdf-id     COLUMN-LABEL "№ ДНЦ"
      p-doc.pdf-db     COLUMN-LABEL "БД ДНЦ"
      p-doc.plt-id     COLUMN-LABEL "№ ТПЛ"
      p-doc.plt-db-num COLUMN-LABEL "БД ТПЛ"
      p-doc.acc-date   column-label "Проводка"
      p-doc.bge-date   column-label "Внеш.пров."
      p-doc.out-code   column-label "Накл."
    WITH SIZE 98 BY 15 separators.
DEFINE FRAME d-pr-docs
     b-quit   AT ROW 1  COL 1
     b-sel    AT ROW 1  COL 13
     b-mark   AT ROW 1 COL  25
     b-markall   AT ROW 2 COL  25
     b-demark    AT ROW 2 COL  28
     b-lkp    AT ROW 1 COL  28
     b-chg    AT ROW 1 COL 40
     b-close  AT ROW 1 COL  52
     b-sch    AT ROW 1  COL 50
     b-history AT ROW 1  COL 74
     b-help   AT ROW 1  COL 86
     b-add    AT ROW 2 COL 5
     b-del    AT ROW 2 COL  26
     b-copy   AT ROW 2  COL 50
     b-print  AT ROW 2 COL 86
     br-docs AT ROW 3 COL 1
     v-user-name AT ROW 18 COL 1 label "Создал"      fgcolor 4 format "x(15)"
     v-user-name-corr AT ROW 19 COL 1 label "Правил" fgcolor 4 format "x(15)"
     ed-notes AT ROW 20 COL 1 no-label bgcolor 8 fgcolor 4
     sch-code at row 22 col 2 label "&Начало номера"
     sch-date at row 22 col 29 label "Д&ата"
     sch-fact at row 22 col 47 label "Фак&т"
     sch-num at row 22 col 65 label "Найдено" fgcolor 12
     SPACE(0) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.
ASSIGN
       FRAME d-pr-docs:SCROLLABLE       = FALSE.
ASSIGN
       br-docs:NUM-LOCKED-COLUMNS IN FRAME d-pr-docs = 3.
on any-printable of br-docs in frame d-pr-docs do:
  apply "entry" to sch-code in frame d-pr-docs.
end.
ON CHOOSE OF b-add IN FRAME d-pr-docs
DO:
define variable old-type as character no-undo .
define variable v-dead-doc   as character initial no no-undo.
define variable v-type       as character initial ? no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'dead-doc'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-dead-doc
  ,output v-type
  ) no-error .
if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      message "В системе установлен запрет на ввод документов!"
      view-as alert-box error .
      return no-apply  .
    end.
end.
if list-mode = 'статус':U and g#stat <> 'новый':U then do:
  message "В этом списке нет новых переоценок, поэтому добавление здесь запрещено.".
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_preparation':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
if g#log <> yes then return no-apply.
doc-rec = ? .
run str/pr-doc.w
( input parParentProc   ,
  input-output doc-rec  ,
  input 'ДОБАВЛЕНИЕ':U        ,
  input-output  next-prev ) .
if doc-rec = ? then return no-apply.
run OpenBr in this-procedure  (yes, no, '':U).
END.
ON CHOOSE OF b-chg IN FRAME d-pr-docs
DO:
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_preparation':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return no-apply.
  run str/pr-doc.w
  ( input parParentProc   ,
    input-output doc-rec  ,
    input 'ИЗМЕНЕНИЕ':U        ,
    input-output  next-prev
  ) no-error.
  apply "entry" to br-docs in frame d-pr-docs.
  if error-status:error then do:
    find p-doc where recid (p-doc) = doc-rec no-lock.
    return no-apply.
  end.
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF b-del IN FRAME d-pr-docs  DO:
define variable del-rec as recid no-undo.
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
  if p-doc.status_ = 'приказ':U and  (v-obj-db-num <> 0) or
    p-doc.status_ = 'разрешен':U and p-obj-type = 'маг':U or
    p-doc.status_ = 'акт':U then do:
    find p-doc where recid (p-doc) = doc-rec no-lock.
    message "Закрытый документ не может быть удален.".
    return no-apply.
  end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_preparation':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if g#log <> true then do:   find p-doc where recid (p-doc) = doc-rec no-lock.   return no-apply. end.
  g#log = no.
  message "Удалить документ № " p-doc.doc-num
              " ?   Вы уверены ?" view-as alert-box question buttons OK-Cancel
                update g#log.
  if g#log <> true then do:   find p-doc where recid (p-doc) = doc-rec no-lock.   return no-apply. end.
  run waitfram-show in this-procedure ("Удаление переоценки № " + p-doc.doc-num + ". Ждите...").
  br-handle = br-docs:handle.
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    del-rec = recid (p-doc).
  end.
  find p-doc where recid (p-doc) = doc-rec.
  do on stop undo, return no-apply.
    delete p-doc.
  end.
  doc-rec = del-rec.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF b-history IN FRAME d-pr-docs
DO:
 run str/pr-cdoc.w (parParentProc ,p-doc.host-code, p-doc.doc-num) .
end.
ON CHOOSE OF b-lkp IN FRAME d-pr-docs
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_lookup':U
    ,input  'object':U
    ,input  p-doc.host-code
    ,input  p-doc.obj-type
    ,input  p-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if g#log <> yes then return no-apply.
  next-prev = yes.
  br-handle = br-docs:handle.
  do while next-prev <> ?:
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
    run str/pr-doc.w
  ( input parParentProc   ,
    input-output doc-rec ,
    input 'ПРОСМОТР':U        ,
    input-output  next-prev ) .
  end.
  if br-handle = ? then reposition br-docs to recid doc-rec no-error.
  apply "entry" to br-docs in frame d-pr-docs.
  apply "iteration-changed" to br-docs in frame d-pr-docs.
END.
ON CHOOSE OF b-close IN FRAME d-pr-docs
DO:
  define variable v-v1         as logical   no-undo .
  define variable v-close-type as integer   no-undo .
  define variable v-varmode    as character no-undo .
  define variable vv as integer   no-undo .
  define variable i-v as integer   no-undo .
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
  vv = num-entries(mark-list) .
  v-v1 = false .
    if vv >= 1 then do:
      message "Выбрано " num-entries(mark-list) "переоценок "
              "Закрыть их списком до АКТ ?"
              view-as alert-box question
              button yes-no
              title "Вопрос"
              update v-v1.
    end.
    else do:
      mark-list = string(recid ( p-doc )) .
      vv = num-entries(mark-list) .
    end.
  g#auto = false .
    if list-mode = 'работа':U and v-v1 = false  then do:
      if not ( p-doc.status_ = 'новый':U ) then do:
      message "В этом режиме можно закрывать только до статуса " caps( 'приказ':U) view-as alert-box information .
      return  .
      end.
    end.
  repeat i-v = 1 to vv :
    find first p-doc no-lock  where recid(p-doc) = integer(entry(i-v,mark-list )) no-error .
    if error-status :error then next.
    if p-doc.doc-date > today
    then do :
      message ("Нельзя закрыть переоценку " + p-doc.doc-num + ". Дата переоценки больше текущей даты.") view-as alert-box information .
      vv = 0.
      mark-list = "" .
      return.
    end.
  if v-v1 = true then assign
    v-varmode = "close-act":U
  .
  else assign
    v-varmode = "close":U .
  .
  do transaction :
  define buffer buf_price-doc-forming for ub.price-doc-forming  .
  if  p-doc.status_ = 'приказ':U or p-doc.status_ = 'разрешен':U  then do:
    find first buf_price-doc-forming exclusive-lock where
              buf_price-doc-forming.plt-db-num = p-doc.plt-db-num and
              buf_price-doc-forming.plt-id     = p-doc.plt-id     and
              buf_price-doc-forming.pdf-db     = p-doc.pdf-db     and
              buf_price-doc-forming.pdf-id     = p-doc.pdf-id     and
              buf_price-doc-forming.stts       = int('3':U) no-error .
    if not available buf_price-doc-forming then do:
      message
      substitute("Нельзя закрыть переоценку &1 , так как ДНЦ &2 еще не в статусе ФАКТ !" , p-doc.doc-num, p-doc.pdf-id )
      view-as alert-box information .
      return .
    end.
  end.
      if  p-doc.status_ = 'приказ':U and v-v1 = false  then do:
          run gbl/d-askw.w
          ( input "Вопрос"
            ,input "Закрытие переоценки" + chr(10)
              + substitute("№         &1", p-doc.doc-num) + chr(10)
              + substitute("Дата      &1", string(p-doc.doc-date, '99/99/9999':u)) + chr(10)
              + (if p-doc.fact-date <> ? then substitute("Факт дата &1", string(p-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
              + substitute("Оператор  &1", p-doc.user-name)
            ,input "|^"
            ,input "Разрешен" + '|':u
                + "Акт" + '|':u
                + "Отмена"
            ,input "поэтапное закрытие переоценки|"
                + "установление новых цен на товары, пересылка цен на кассы и по новостям |"
                + "Отмена закрытия переоценки"
            ,input 1
            ,input 3
            ,output v-close-type
            ).
          case v-close-type :
            when 1
            then do:
              assign
                v-varmode = "close":U
              .
            end.
            when 2
            then do:
              assign
                v-varmode = "close-act":U
              .
            end.
            when 3
            then do:
              assign mark-list = "" .
              return no-apply.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Способ закрытия переоценки" skip
                "Неизвестное значение" v-close-type skip
                view-as alert-box error .
              undo, return no-apply .
            end.
          end case .
      end.
  end.
    v-mess = "".
    varoldstatus = p-doc.status_.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-doc.obj-type
  ,input  p-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
    run str/pr-stat.p
      ( input parParentProc
      , input v-log-handle
      , input v-varmode
      , input p-doc.doc-num
      , input p-doc.out-code
      , input false
      , input false
      ) no-error .
    if error-status :error then do:
        v-mess = "Ошибка закрытия переоценки " + p-doc.doc-num + chr(10) +
          return-value + chr(10) +
          error-status :get-message(1).
        message v-mess
                "Продолжить процесс ?"
                view-as alert-box question
                buttons yes-no
                update v11 as logical
                .
                assign mark-list = "" .
                v-vid-action = 57 .
                v-vid-param = "Initiator=" + v-initiator + chr(4) +
                              "SHOP_NUM=" + string(p-doc.obj-code) + chr(4) +
                              "DocNum=" + string(p-doc.doc-num) + chr(4) +
                              "DocType=" + "Переоценка" + chr(4) +
                              "FactDate=" + (if string(p-doc.fact-date) = ? then '' else string(p-doc.fact-date)) + chr(4) +
                              "ShiftNum=" + (if string(p-doc.shift-num) = ? then '' else string(p-doc.shift-num)) + chr(4) +
                              "ShiftDate=" + (if string(p-doc.shift-date) = ? then '' else string(p-doc.shift-date)) + chr(4) +
                              "ShiftNumCurr=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + chr(4) +
                              "ShiftDateCurr=" + (if string(varshift-date) = ? then '' else string(varshift-date)) + chr(4) +
                              "StatusOld=" + varoldstatus + chr(4) +
                              "StatusNew=" + string(p-doc.status_) + chr(4) +
                              "RESULT=1" + chr(4) +
                              "Description=" + v-mess.
                run trg/userlog.p (
                      input 'update_err':U
                    , input 'price-doc':U
                    , input ( buffer p-doc :handle )
                    , input v-vid-action
                    , input v-vid-param
                ) no-error.
        if v11 = false  then  return no-apply .
    end.
    if v-mess = ""
    then do:
      v-vid-action = 57 .
      v-vid-param = "Initiator=" + v-initiator + chr(4) +
                    "SHOP_NUM=" + string(p-doc.obj-code) + chr(4) +
                    "DocNum=" + string(p-doc.doc-num) + chr(4) +
                    "DocType=" + "Переоценка" + chr(4) +
                    "FactDate=" + (if string(p-doc.fact-date) = ? then '' else string(p-doc.fact-date)) + chr(4) +
                    "SHIFT_NUM_DOC=" + (if string(p-doc.shift-num) = ? then '' else string(p-doc.shift-num)) + (if string(p-doc.shift-date) = ? then '' else string(p-doc.shift-date, "99999999")) + chr(4) +
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                    "StatusOld=" + varoldstatus + chr(4) +
                    "StatusNew=" + string(p-doc.status_) + chr(4) +
                    "RESULT=" + chr(4) +
                    "Description=" no-error.
      find last ub.c-price-doc no-lock where ub.c-price-doc.doc-num = p-doc.doc-num no-error.
      if available (ub.c-price-doc)
      then do:
        run trg/userlog.p (
              input 'update':U
            , input 'c-price-doc':U
            , input ( buffer ub.c-price-doc :handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      end.
    end.
  end.
  assign mark-list = "" .
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF b-copy IN FRAME d-pr-docs
DO:
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
  run str/pr-copy.p
    (input  parParentProc , input p-doc.doc-num ) no-error .
  if error-status :error then do:
    find p-doc no-lock
      where recid (p-doc) = doc-rec
      .
    return no-apply .
  end.
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF b-print IN FRAME d-pr-docs
DO:
if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_print':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if g#log <> yes then return no-apply.
  run rep/pr-dprn.w ( parParentProc , doc-rec ).
  apply "entry" to br-docs.
END.
ON CHOOSE OF b-quit IN FRAME d-pr-docs
DO:
  doc-rec = ?.
END.
ON entry OF ed-notes IN FRAME d-pr-docs
DO:
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
  if p-doc.status_ <> 'акт':U and substring (p-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
END.
ON leave OF ed-notes IN FRAME d-pr-docs
DO:
  do on stop undo, return no-apply:
    find p-d-b where recid (p-d-b) = doc-rec exclusive.
    p-d-b.PS = input frame d-pr-docs ed-notes.
  end.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME d-pr-docs DO:
  apply "entry" to br-docs in frame d-pr-docs.
  return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME d-pr-docs DO:
  if list-mode = 'выбор':U and lookup("b-mark":U, bttns) = 0 then apply "choose" to b-sel in frame d-pr-docs.
  else apply "choose" to b-lkp in frame d-pr-docs.
END.
ON iteration-changed OF br-docs do:
  if available p-doc then do:
    ed-notes = p-doc.PS.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-doc.creid
  ,output v-user-name
  )  .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-doc.user-name
  ,output v-user-name-corr
  )  .
    display ed-notes v-user-name v-user-name-corr with frame d-pr-docs.
    if doc-rec <> recid (p-doc) then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
  end.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME d-pr-docs DO:
  if sch-code <> input frame d-pr-docs sch-code or sch-field <> "doc-num" then do:
    sch-num = 0.
    hide sch-num in frame d-pr-docs.
  end.
  sch-field = "doc-num" .
  assign sch-code = input frame d-pr-docs sch-code.
  run OpenBr in this-procedure (NO,NO, substitute(" and p-doc.doc-num begins '&1' ", sch-code)).
  apply "entry":u to sch-num in frame d-pr-docs.
END.
on ctrl-j of sch-code in frame d-pr-docs  do:
  if sch-code <> input frame d-pr-docs sch-code or sch-field <> "doc-num" then do:
    sch-num = 0.
    hide sch-num in frame d-pr-docs.
  end.
  sch-field = "doc-num" .
  assign sch-code = input frame d-pr-docs sch-code.
  run OpenBr in this-procedure ( no, yes, substitute (" and p-doc.doc-num begins '&1' ", sch-code) ).
  apply "entry":U to sch-num in frame d-pr-docs.
  apply "entry":U to sch-num in frame d-pr-docs.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME d-pr-docs DO:
define variable v-date as character no-undo .
    if sch-date <> input frame d-pr-docs sch-date or sch-field <> "doc-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "doc-date".
    assign sch-date = input frame d-pr-docs sch-date.
    v-date = string ( month (sch-date)) + chr(47) +
             string ( day   (sch-date)) + chr(47) +
             string ( year  (sch-date))
            .
    run OpenBr ( no, yes, substitute (" and p-doc.doc-date = &1 ", v-date) ) .
    apply "entry":u to sch-date in frame d-pr-docs.
end.
on ctrl-j of sch-date in frame d-pr-docs  do:
define variable v-date as character no-undo .
    if sch-date <> input frame d-pr-docs sch-date or sch-field <> "doc-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "doc-date".
    assign sch-date = input frame d-pr-docs sch-date.
    v-date =
    string (day (sch-date)  ) + chr(47) +
    string (month (sch-date)) + chr(47) +
                        string (year (sch-date) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.doc-date = &1 ", v-date) ) .
    apply "entry":u to sch-date in frame d-pr-docs.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-fact IN FRAME d-pr-docs DO:
define variable v-date as character no-undo .
    if sch-fact <> input frame d-pr-docs sch-fact or sch-field <> "fact-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "fact-date".
    assign sch-fact = input frame d-pr-docs sch-fact.
    v-date =
            string ( day (sch-fact)  ) + chr(47) +
            string ( month (sch-fact)) + chr(47) +
            string ( year (sch-fact) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.fact-date = &1 ", v-date) ) .
    apply "entry":u to sch-fact in frame d-pr-docs.
END.
on ctrl-j of sch-fact in frame d-pr-docs   do:
define variable v-date as character no-undo .
    if sch-fact <> input frame d-pr-docs sch-fact or sch-field <> "fact-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "fact-date".
    assign sch-fact = input frame d-pr-docs sch-fact.
    v-date = string ( month (sch-fact)) + chr(47) +
            string ( day (sch-fact)  ) + chr(47) +
            string ( year (sch-fact) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.fact-date = &1 ", v-date) ) .
    apply "entry":u to sch-fact in frame d-pr-docs.
END.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-pr-docs anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ALT-F8 of frame d-pr-docs anywhere do:
  if b-history :sensitive then DO: apply "CHOOSE":U to b-history in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-pr-docs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-pr-docs anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-pr-docs anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame d-pr-docs anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame d-pr-docs. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-pr-docs anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-pr-docs. END.
  return no-apply.
end.
ON CHOOSE OF b-sel IN FRAME d-pr-docs
DO:
  if not available p-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (p-doc). do on stop undo, return no-apply :   find p-doc where recid (p-doc) = doc-rec exclusive.   end.
  if mark-list <> "" then do:
  end.
  else do:
    mark-list = string(recid(p-doc)).
  end.
  apply "go" to frame d-pr-docs.
END.
on choose of b-mark in frame d-pr-docs do:
  run local-mark in this-procedure .
  if available p-doc then do:
    g#log = br-docs:select-next-row ().
  end.
  apply "entry" to br-docs in frame d-pr-docs.
end.
on choose of b-demark in frame d-pr-docs do:
   assign mark-list = "" .
   run OpenBr in this-procedure  (yes, no, '':U).
end.
on choose of b-markall in frame d-pr-docs do:
  define variable loc#log as logical no-undo .
  assign mark-list = "".
  GET first br-docs.
  DO WHILE available p-doc  :
    if available p-doc then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid27 as character no-undo .
define variable v-num-entry27 as integer   no-undo .
assign
  v-str-recid27 = trim( string( recid( p-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry27 = lookup( v-str-recid27 , mark-list )
.
if v-num-entry27 > 0 then do:
  assign
    entry( v-num-entry27, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid27
  .
end.
    end.
  GET next br-docs.
  end.
  run OpenBR in this-procedure (yes, no, '':U).
  apply "entry" to br-docs in frame d-pr-docs.
end.
on choose of b-sch in frame d-pr-docs do:
  run init-flt in this-procedure no-error.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pr-docs:PARENT eq ?
THEN FRAME d-pr-docs:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-pr-docs APPLY "END-ERROR":U TO SELF.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pr-docs
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame d-pr-docs
do:
  apply "help":u to frame d-pr-docs .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame d-pr-docs:width - 0.3
                fh            = frame d-pr-docs:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-pr-docs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-pr-docs :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-pr-docs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-pr-docs :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-pr-docs :height = v-frame-height
          .
          if frame d-pr-docs :scrollable = true
          then do:
            assign
              frame d-pr-docs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-pr-docs :scrollable = true
          then do:
            assign
              frame d-pr-docs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-pr-docs :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame d-pr-docs :height
      v-frame-virtual-height = frame d-pr-docs :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-pr-docs :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-pr-docs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-pr-docs :scrollable = true
      then do:
        assign
          frame d-pr-docs :virtual-height = frame d-pr-docs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-pr-docs :height = frame d-pr-docs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-pr-docs :height = frame d-pr-docs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-pr-docs :scrollable = true
      then do:
        assign
          frame d-pr-docs :virtual-height = frame d-pr-docs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame d-pr-docs :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame d-pr-docs :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-pr-docs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-pr-docs :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-pr-docs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-pr-docs :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-pr-docs :width = v-frame-width
          .
          if frame d-pr-docs :scrollable = true
          then do:
            assign
              frame d-pr-docs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-pr-docs :scrollable = true
          then do:
            assign
              frame d-pr-docs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-pr-docs :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame d-pr-docs :width
      v-frame-virtual-width = frame d-pr-docs :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-pr-docs :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-pr-docs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-pr-docs :scrollable = true
      then do:
        assign
          frame d-pr-docs :virtual-width = frame d-pr-docs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-pr-docs :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame d-pr-docs :width = frame d-pr-docs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-pr-docs :scrollable = true
      then do:
        assign
          frame d-pr-docs :virtual-width = frame d-pr-docs :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame d-pr-docs :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame d-pr-docs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-pr-docs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-pr-docs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-pr-docs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-pr-docs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-pr-docs :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame d-pr-docs
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame d-pr-docs :height
      v-col-delta = v-new-col - frame d-pr-docs :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame d-pr-docs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-pr-docs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-pr-docs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-pr-docs :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame d-pr-docs :width
      v-diasize-current-frame-height = frame d-pr-docs :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame d-pr-docs
    :
      assign
        v-diasize-orig-frame-height = frame d-pr-docs :height
        v-diasize-orig-frame-width  = frame d-pr-docs :width
        v-diasize-browse-handle     = browse br-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-pr-docs :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-pr-docs anywhere
do:
   assign v-doc-rec = ?. if available p-doc then v-doc-rec = recid(p-doc). run OpenBr in this-procedure (yes, no, '':U). reposition br-docs to recid v-doc-rec no-error. apply 'iteration-changed' to br-docs.
end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-date in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-date in frame d-pr-docs
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-date in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-date in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-date in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date33
    MENU-ITEM m-ed-date33-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date33-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date33-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date33-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame d-pr-docs = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame d-pr-docs = MENU m-ed-date33 :HANDLE
      sch-date :MENU-MOUSE in frame d-pr-docs = 3
    .
  end.
  define variable v-label-handle33 as handle no-undo .
  assign
    v-label-handle33 = sch-date :side-label-handle in frame d-pr-docs
  .
  if valid-handle (v-label-handle33)
  then do:
    if v-label-handle33 :tooltip = ""
    or v-label-handle33 :tooltip = ?
    then do:
      assign
        v-label-handle33 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date33-1 in menu m-ed-date33 DO:
    apply "ctrl-b":U to sch-date in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-2 in menu m-ed-date33 DO:
    apply "ctrl-d":U to sch-date in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-3 in menu m-ed-date33 DO:
    apply "ctrl-e":U to sch-date in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-4 in menu m-ed-date33 DO:
    apply "ctrl-f":U to sch-date in frame d-pr-docs .
  END.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-fact in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-fact in frame d-pr-docs
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-fact in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-fact in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-fact in frame d-pr-docs
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date35
    MENU-ITEM m-ed-date35-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date35-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date35-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date35-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact :POPUP-MENU in frame d-pr-docs = ?
  then do:
    ASSIGN
      sch-fact :POPUP-MENU in frame d-pr-docs = MENU m-ed-date35 :HANDLE
      sch-fact :MENU-MOUSE in frame d-pr-docs = 3
    .
  end.
  define variable v-label-handle35 as handle no-undo .
  assign
    v-label-handle35 = sch-fact :side-label-handle in frame d-pr-docs
  .
  if valid-handle (v-label-handle35)
  then do:
    if v-label-handle35 :tooltip = ""
    or v-label-handle35 :tooltip = ?
    then do:
      assign
        v-label-handle35 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date35-1 in menu m-ed-date35 DO:
    apply "ctrl-b":U to sch-fact in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-2 in menu m-ed-date35 DO:
    apply "ctrl-d":U to sch-fact in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-3 in menu m-ed-date35 DO:
    apply "ctrl-e":U to sch-fact in frame d-pr-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-4 in menu m-ed-date35 DO:
    apply "ctrl-f":U to sch-fact in frame d-pr-docs .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
find sch-cli where recid (sch-cli) = int(p-doc-rec) no-error.
find sch_price-list-type where recid (sch_price-list-type) = int(p-doc-rec) no-error.
if available  sch_price-list-type and list-mode = "typepricelist":U then
    assign
        v-plt-db-num = sch_price-list-type.plt-db-num
        v-plt-id     = sch_price-list-type.plt-id
    .
find sch_price-doc-forming where recid (sch_price-doc-forming) = int(p-doc-rec) no-error.
if available  sch_price-doc-forming and list-mode = "pricedocforming":U then
    assign
        v-plt-db-num = sch_price-doc-forming.plt-db-num
        v-plt-id     = sch_price-doc-forming.plt-id
        v-pdf-db-num = sch_price-doc-forming.pdf-db
        v-pdf-id     = sch_price-doc-forming.pdf-id
     .
ENABLE b-quit b-lkp b-history b-print b-sch b-help br-docs sch-code sch-date sch-fact ed-notes
b-mark when lookup("b-mark":U, bttns) > 0
b-demark when lookup("b-mark":U, bttns) > 0
b-markall when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
WITH FRAME d-pr-docs.
define variable var-pr-r-b as character no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
if var-pr-r-b = "rubl" then
   assign
      p-doc.sale-base:LABEL = "Сумма " + "(руб)"
      p-doc.rest-sale:LABEL = "Было "  + "(руб)"
   .
  else  assign
        p-doc.sale-base:LABEL = "Сумма " + "(б.в)"
        p-doc.rest-sale:LABEL = "Было "  + "(б.в)"
    .
run OpenBr in this-procedure (yes, no, '':U).
hide b-add b-del   b-copy in frame d-pr-docs .
WAIT-FOR GO OF FRAME d-pr-docs focus br-docs.
END.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-pr-docs.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where buf_clients.obj-code = v-host-code and buf_clients.obj-type = 'орг':U no-error .
if not available buf_clients then return .
filter-point = filter-point0 + list-mode.
if p-open-query = true  then do:
  frame d-pr-docs:title = "ВСЕ  ПЕРЕОЦЕНКИ".
  sch-num = 0.
  hide sch-num in frame d-pr-docs.
end.
else  do:
   doc-rec = ?.
end.
case list-mode :
  when "typepricelist":U then do:
      frame d-pr-docs:title = "ПЕРЕОЦЕНКИ  по ТПЛ " +  sch_price-list-type.name .
      c-point = 'акт':U + list-mode.
      enable b-copy b-close with frame d-pr-docs.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-38
  ,output filter-name-38
  ,output where-phrase-38
  ,output sort-phrase-38
  ,output where-phrase-rus-38
  ,output sort-phrase-rus-38
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-38
      ) no-error .
  assign
    l-filter-open-38 = false
  .
  if flt-rec-38 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-38 as character no-undo .
    define variable  parameter-3-38 as character no-undo .
    define variable  parameter-4-38 as character no-undo .
    define variable  parameter-5-38 as character no-undo .
    define variable  parameter-6-38 as character no-undo .
    define variable  parameter-7-38 as character no-undo .
      assign
      parameter-3-38 =
                              "FOR EACH p-doc"
      parameter-4-38 =
        (
          if (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id " + " " + where-phrase-38) <> ""
          then  substitute( 'p-doc.plt-db-num = &1  and p-doc.plt-id =  &2 ' , v-plt-db-num , v-plt-id)  + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-38 =
          (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          )
      .
      assign
        l-filter-open-38 = true
      .
    end.
    if l-filter-open-38 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-38 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id
       use-index pdf
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute( 'p-doc.plt-db-num = &1  and p-doc.plt-id =  &2 ' , v-plt-db-num , v-plt-id)  + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " use-index pdf "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-3-38 =  "FOR EACH p-doc"
      parameter-4-38 =
        (
          if (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id " + " " + where-phrase-38) <> ""
          then  substitute( 'p-doc.plt-db-num = &1  and p-doc.plt-id =  &2 ' , v-plt-db-num , v-plt-id)  + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "pricedocforming":U then do:
      frame d-pr-docs:title = "ПЕРЕОЦЕНКИ  по ДНЦ " +  sch_price-doc-forming.name .
      c-point = 'акт':U + list-mode.
      enable b-copy b-close with frame d-pr-docs.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH p-doc"
      parameter-4-40 =
        (
          if (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id and p-doc.pdf-db = v-pdf-db-num and p-doc.pdf-id = v-pdf-id " + " " + where-phrase-40) <> ""
          then  substitute( '                      p-doc.plt-db-num = &1 and                       p-doc.plt-id =  &2 and                         p-doc.pdf-db =  &3 and                         p-doc.pdf-id =  &4 ' ,                       v-plt-db-num ,                      v-plt-id     ,                      v-pdf-db-num ,                      v-pdf-id   )                        + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id and p-doc.pdf-db = v-pdf-db-num and p-doc.pdf-id = v-pdf-id " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-40 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id and p-doc.pdf-db = v-pdf-db-num and p-doc.pdf-id = v-pdf-id
       use-index pdf
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute( '                      p-doc.plt-db-num = &1 and                       p-doc.plt-id =  &2 and                         p-doc.pdf-db =  &3 and                         p-doc.pdf-id =  &4 ' ,                       v-plt-db-num ,                      v-plt-id     ,                      v-pdf-db-num ,                      v-pdf-id   )                        + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " use-index pdf "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH p-doc"
      parameter-4-40 =
        (
          if (" p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id and p-doc.pdf-db = v-pdf-db-num and p-doc.pdf-id = v-pdf-id " + " " + where-phrase-40) <> ""
          then  substitute( '                      p-doc.plt-db-num = &1 and                       p-doc.plt-id =  &2 and                         p-doc.pdf-db =  &3 and                         p-doc.pdf-id =  &4 ' ,                       v-plt-db-num ,                      v-plt-id     ,                      v-pdf-db-num ,                      v-pdf-id   )                        + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index pdf " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'работа':U then do:
      c-point = 'акт':U + list-mode.
      enable b-copy b-close with frame d-pr-docs.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-42
  ,output filter-name-42
  ,output where-phrase-42
  ,output sort-phrase-42
  ,output where-phrase-rus-42
  ,output sort-phrase-rus-42
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-42
      ) no-error .
  assign
    l-filter-open-42 = false
  .
  if flt-rec-42 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-42 as character no-undo .
    define variable  parameter-3-42 as character no-undo .
    define variable  parameter-4-42 as character no-undo .
    define variable  parameter-5-42 as character no-undo .
    define variable  parameter-6-42 as character no-undo .
    define variable  parameter-7-42 as character no-undo .
      assign
      parameter-3-42 =
                              "FOR EACH p-doc"
      parameter-4-42 =
        (
          if (" true  " + " " + where-phrase-42) <> ""
          then  'true'   + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index date-num " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index date-num " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          (" true  " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          )
      .
      assign
        l-filter-open-42 = true
      .
    end.
    if l-filter-open-42 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-42 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  true
       use-index date-num
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  'true'   + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " use-index date-num "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-3-42 =  "FOR EACH p-doc"
      parameter-4-42 =
        (
          if (" true  " + " " + where-phrase-42) <> ""
          then  'true'   + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index date-num " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index date-num " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'фирма':U then do:
      frame d-pr-docs:title = "ПЕРЕОЦЕНКА   Фирма : " + v-host-name .
      c-point = "актРАБОТА".
  enable b-copy with frame d-pr-docs.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-44
  ,output filter-name-44
  ,output where-phrase-44
  ,output sort-phrase-44
  ,output where-phrase-rus-44
  ,output sort-phrase-rus-44
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-44
      ) no-error .
  assign
    l-filter-open-44 = false
  .
  if flt-rec-44 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-44 as character no-undo .
    define variable  parameter-3-44 as character no-undo .
    define variable  parameter-4-44 as character no-undo .
    define variable  parameter-5-44 as character no-undo .
    define variable  parameter-6-44 as character no-undo .
    define variable  parameter-7-44 as character no-undo .
      assign
      parameter-3-44 =
                              "FOR EACH p-doc"
      parameter-4-44 =
        (
          if (" p-doc.host-code = v-host-code " + " " + where-phrase-44) <> ""
          then  substitute ( 'p-doc.host-code = &1' , v-host-code )  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " use-index  host-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          (" p-doc.host-code = v-host-code " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          )
      .
      assign
        l-filter-open-44 = true
      .
    end.
    if l-filter-open-44 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-44 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.host-code = v-host-code
       use-index  host-date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute ( 'p-doc.host-code = &1' , v-host-code )  + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " use-index  host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH p-doc"
      parameter-4-44 =
        (
          if (" p-doc.host-code = v-host-code " + " " + where-phrase-44) <> ""
          then  substitute ( 'p-doc.host-code = &1' , v-host-code )  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " use-index  host-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'объект':U then do:
      frame d-pr-docs:title = "ПЕРЕОЦЕНКА   Объект : " + p-obj-type + " " + string (p-obj-code).
      enable b-add b-chg b-del b-close with frame d-pr-docs.
      if (v-cntxt-db-num <> 0) then enable b-copy with frame d-pr-docs.
      c-point = 'акт':U + list-mode.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-46  as logical   no-undo .
define variable  l-filter-open-46    as logical   .
define variable  flt-rec-46       as recid     no-undo .
define variable  filter-name-46      as character no-undo .
define variable  where-phrase-46     as character no-undo .
define variable  sort-phrase-46      as character no-undo .
define variable  where-phrase-rus-46 as character no-undo .
define variable  sort-phrase-rus-46  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-46
  ,output filter-name-46
  ,output where-phrase-46
  ,output sort-phrase-46
  ,output where-phrase-rus-46
  ,output sort-phrase-rus-46
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-46
      ) no-error .
  assign
    l-filter-open-46 = false
  .
  if flt-rec-46 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-46 as character no-undo .
    define variable  parameter-3-46 as character no-undo .
    define variable  parameter-4-46 as character no-undo .
    define variable  parameter-5-46 as character no-undo .
    define variable  parameter-6-46 as character no-undo .
    define variable  parameter-7-46 as character no-undo .
      assign
      parameter-3-46 =
                              "FOR EACH p-doc"
      parameter-4-46 =
        (
          if (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code " + " " + where-phrase-46) <> ""
          then  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3', chr(34) , p-obj-type, p-obj-code )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " use-index  obj-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          )
      .
      assign
        l-filter-open-46 = true
      .
    end.
    if l-filter-open-46 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-46 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code
       use-index  obj-date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3', chr(34) , p-obj-type, p-obj-code )  + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = " use-index  obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH p-doc"
      parameter-4-46 =
        (
          if (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code " + " " + where-phrase-46) <> ""
          then  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3', chr(34) , p-obj-type, p-obj-code )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " use-index  obj-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'статус':U then do:
      frame d-pr-docs:title = "Объект : " + p-obj-type + " " + string (p-obj-code) + "  Статус : " + g#stat.
      enable b-add b-chg b-del b-close with frame d-pr-docs.
      c-point = 'акт':U + list-mode.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-48  as logical   no-undo .
define variable  l-filter-open-48    as logical   .
define variable  flt-rec-48       as recid     no-undo .
define variable  filter-name-48      as character no-undo .
define variable  where-phrase-48     as character no-undo .
define variable  sort-phrase-48      as character no-undo .
define variable  where-phrase-rus-48 as character no-undo .
define variable  sort-phrase-rus-48  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-48
  ,output filter-name-48
  ,output where-phrase-48
  ,output sort-phrase-48
  ,output where-phrase-rus-48
  ,output sort-phrase-rus-48
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-48
      ) no-error .
  assign
    l-filter-open-48 = false
  .
  if flt-rec-48 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-48 as character no-undo .
    define variable  parameter-3-48 as character no-undo .
    define variable  parameter-4-48 as character no-undo .
    define variable  parameter-5-48 as character no-undo .
    define variable  parameter-6-48 as character no-undo .
    define variable  parameter-7-48 as character no-undo .
      assign
      parameter-3-48 =
                              "FOR EACH p-doc"
      parameter-4-48 =
        (
          if (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code and  p-doc.status_ = g#stat " + " " + where-phrase-48) <> ""
          then  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3 and p-doc.status_ = &1&4&1', chr(34) , p-obj-type, p-obj-code , g#stat)  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " use-index  stat-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  stat-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code and  p-doc.status_ = g#stat " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          )
      .
      assign
        l-filter-open-48 = true
      .
    end.
    if l-filter-open-48 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-48 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code and  p-doc.status_ = g#stat
       use-index  stat-date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3 and p-doc.status_ = &1&4&1', chr(34) , p-obj-type, p-obj-code , g#stat)  + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = " use-index  stat-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH p-doc"
      parameter-4-48 =
        (
          if (" p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code and  p-doc.status_ = g#stat " + " " + where-phrase-48) <> ""
          then  substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3 and p-doc.status_ = &1&4&1', chr(34) , p-obj-type, p-obj-code , g#stat)  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " use-index  stat-date " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  stat-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'бгх-все':U then do:
      frame d-pr-docs:title = "Все ПЕРЕОЦЕНКИ  БЕЗ  выгрузки  по ФИРМЕ   (кроме нулевых сумм)".
      c-point = 'акт':U + list-mode.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-50  as logical   no-undo .
define variable  l-filter-open-50    as logical   .
define variable  flt-rec-50       as recid     no-undo .
define variable  filter-name-50      as character no-undo .
define variable  where-phrase-50     as character no-undo .
define variable  sort-phrase-50      as character no-undo .
define variable  where-phrase-rus-50 as character no-undo .
define variable  sort-phrase-rus-50  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-50
  ,output filter-name-50
  ,output where-phrase-50
  ,output sort-phrase-50
  ,output where-phrase-rus-50
  ,output sort-phrase-rus-50
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-50
      ) no-error .
  assign
    l-filter-open-50 = false
  .
  if flt-rec-50 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-50 as character no-undo .
    define variable  parameter-3-50 as character no-undo .
    define variable  parameter-4-50 as character no-undo .
    define variable  parameter-5-50 as character no-undo .
    define variable  parameter-6-50 as character no-undo .
    define variable  parameter-7-50 as character no-undo .
      assign
      parameter-3-50 =
                              "FOR EACH p-doc"
      parameter-4-50 =
        (
          if (" p-doc.status_ = 'акт':U       and p-doc.bge-date = ?       and p-doc.host-code = v-host-code       and p-doc.sale-base <> 0 " + " " + where-phrase-50) <> ""
          then  substitute ( 'p-doc.status_ = &1&2&1 and p-doc.bge-date = date(?) and p-doc.sale-base <> 0 and p-doc.host-code = &3 ', chr(34) ,  'акт':U, v-host-code )  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " use-index  bge-host " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  bge-host " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          (" p-doc.status_ = 'акт':U       and p-doc.bge-date = ?       and p-doc.host-code = v-host-code       and p-doc.sale-base <> 0 " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          )
      .
      assign
        l-filter-open-50 = true
      .
    end.
    if l-filter-open-50 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-50 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  p-doc.status_ = 'акт':U       and p-doc.bge-date = ?       and p-doc.host-code = v-host-code       and p-doc.sale-base <> 0
       use-index  bge-host
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute ( 'p-doc.status_ = &1&2&1 and p-doc.bge-date = date(?) and p-doc.sale-base <> 0 and p-doc.host-code = &3 ', chr(34) ,  'акт':U, v-host-code )  + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = " use-index  bge-host "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH p-doc"
      parameter-4-50 =
        (
          if (" p-doc.status_ = 'акт':U       and p-doc.bge-date = ?       and p-doc.host-code = v-host-code       and p-doc.sale-base <> 0 " + " " + where-phrase-50) <> ""
          then  substitute ( 'p-doc.status_ = &1&2&1 and p-doc.bge-date = date(?) and p-doc.sale-base <> 0 and p-doc.host-code = &3 ', chr(34) ,  'акт':U, v-host-code )  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " use-index  bge-host " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " use-index  bge-host " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'выбор':U then do:
      frame d-pr-docs:title = trim (frame d-pr-docs:title) + " :   ВЫБОР".
      c-point = 'акт':U + 'работа':U.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-52  as logical   no-undo .
define variable  l-filter-open-52    as logical   .
define variable  flt-rec-52       as recid     no-undo .
define variable  filter-name-52      as character no-undo .
define variable  where-phrase-52     as character no-undo .
define variable  sort-phrase-52      as character no-undo .
define variable  where-phrase-rus-52 as character no-undo .
define variable  sort-phrase-rus-52  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-52
  ,output filter-name-52
  ,output where-phrase-52
  ,output sort-phrase-52
  ,output where-phrase-rus-52
  ,output sort-phrase-rus-52
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-52
      ) no-error .
  assign
    l-filter-open-52 = false
  .
  if flt-rec-52 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-52 as character no-undo .
    define variable  parameter-3-52 as character no-undo .
    define variable  parameter-4-52 as character no-undo .
    define variable  parameter-5-52 as character no-undo .
    define variable  parameter-6-52 as character no-undo .
    define variable  parameter-7-52 as character no-undo .
      assign
      parameter-3-52 =
                              "FOR EACH p-doc"
      parameter-4-52 =
        (
          if (" true " + " " + where-phrase-52) <> ""
          then  'true'  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-52 =
          (" true " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
                          )
      .
      assign
        l-filter-open-52 = true
      .
    end.
    if l-filter-open-52 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-52 = false then do:
    OPEN QUERY br-docs FOR EACH p-doc NO-LOCK
      where  true
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( p-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer p-doc:handle) then do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  'true'  + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(p-doc)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer p-doc:handle)
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-3-52 =  "FOR EACH p-doc"
      parameter-4-52 =
        (
          if (" true " + " " + where-phrase-52) <> ""
          then  'true'  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
end case.
if p-open-query <> true  and available p-d-b then doc-rec = recid (p-d-b).
if doc-rec <> ? then do:
  if p-open-query <> true  then do:
    sch-num = sch-num + 1.
    disp sch-num with frame d-pr-docs.
  end.
  reposition br-docs to recid doc-rec no-error.
end.
else if p-open-query <> true  then do:
  message "Переоценка не найдена.".
  sch-num = 0.
end.
apply "entry" to br-docs in frame d-pr-docs.
apply "iteration-changed" to br-docs in frame d-pr-docs.
hide b-add b-del   b-copy in frame d-pr-docs .
END PROCEDURE.
PROCEDURE init-flt :
  assign
  tbl = 'price-doc'
  join-tbl = "p-doc"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-num', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rest-qnty', 'Кол-во', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rest-sale', 'Сумма До пер-ки ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sale-base', 'Сумма по док. ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('creid', 'Создал', 'usr',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', 'Правил', 'usr',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-id', '№ ТПЛ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pdf-id', '№ ДНЦ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':u).
END.
END PROCEDURE.
PROCEDURE local-mark:
  if not available p-doc then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid54 as character no-undo .
define variable v-num-entry54 as integer   no-undo .
assign
  v-str-recid54 = trim( string( recid( p-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry54 = lookup( v-str-recid54 , mark-list )
.
if v-num-entry54 > 0 then do:
  assign
    entry( v-num-entry54, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid54
  .
end.
   if lookup(string( recid(p-doc) ), mark-list ) = 0
      then display  "" @ mark with browse br-docs.
      else display "*" @ mark with browse br-docs.
END PROCEDURE.
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-pr-docs:
    if p-filter-name > "" then do:
      assign
        frame d-pr-docs:title
          = frame d-pr-docs:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end.
END PROCEDURE.
