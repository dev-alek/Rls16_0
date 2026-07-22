define input  parameter parParentProc as widget-handle no-undo.
define input  parameter doc-rec as recid no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter mode     as character no-undo .
define input        parameter base-bc like ub.bar-code.b-code   no-undo.
define input-output parameter round-method as character     no-undo.
define input-output parameter round-base   as decimal no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных цен приказа переоценки".
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
define new shared buffer base-bar-code for bar-code.
define buffer base-goods    for goods.
define variable mark       as character                      no-undo.
define variable mark-list  as character                      no-undo.
define variable arg-base   like price-list.price-sale no-undo.
define variable calc-dtl   as character                      no-undo.
define variable main-bc-br like bar-code.b-code       no-undo.
define variable base-bc-br like bar-code.b-code       no-undo.
define variable ref-list  as character                      no-undo.
define variable code-rec  as recid                    no-undo.
define variable filter-point as character  no-undo init "pr-alt" .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#libbcrcn as handle no-undo .
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info5 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info5 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info5, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info5
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info5
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer l-price-list for price-list.
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define buffer     rt_tax            for tax.
define variable dor-nal as character no-undo .
define variable g#log as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable ref-rec as recid no-undo .
define new shared buffer price-list for price-list.
define new shared buffer bar-code   for bar-code.
define new shared buffer goods      for goods.
define new shared buffer gds-prt    for gds-prt.
define new shared QUERY br-alt FOR price-list except, bar-code, goods, gds-prt SCROLLING.
define variable sort-column-name as character no-undo .
FUNCTION fnc-mark RETURN char (local-bc as integer).
define buffer local-price-list for price-list.
  find local-price-list no-lock where
       local-price-list.b-code = local-bc and
       local-price-list.doc-num = price-doc.doc-num and
       local-price-list.price-type = "" no-error.
  if not available local-price-list then
    return (?).
  if lookup (string (recid (local-price-list)), mark-list) > 0 then
    return "*".
  else
    return "".
END FUNCTION.
FUNCTION fnc-main-code RETURN integer (local-bc as integer).
define variable local-main-code like bar-code.b-code no-undo.
run prc-main-code (input local-bc, output local-main-code).
return (local-main-code).
END FUNCTION.
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input 'overval':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 6 BY 1.
DEFINE MENU m-add
       MENU-ITEM m-cur-add      LABEL "Список имеющихся спеццен"
       MENU-ITEM m-lst-add      LABEL "Список неосновных кодов"
       .
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 8 BY 1.
DEFINE BUTTON b-discnt
     LABEL "С&кидка":L
     SIZE 8 BY 1.
DEFINE BUTTON b-chg
     LABEL "Рас&чет":L
     SIZE 8 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 8 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 8 BY 1.
define RECTANGLE rect-line EDGE-PIXELS 2 GRAPHIC-EDGE SIZE 98.5 BY 5.4 BGCOLOR GRAY_COLOR.
DEFINE VARIABLE calc-price AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" label "Цена расчет."
VIEW-AS TEXT SIZE 15 BY 0.79
tooltip "Цена, рассчитанная для данной единицы измерения через скидку и коэффициент"
no-undo.
define variable loc-art  as character  VIEW-AS fill-in size 14 by 1 fgcolor RED_COLOR no-undo.
define variable loc-name as character  VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable loc-code as character  VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable conf-par     as character  no-undo.
define variable par-type     as character  no-undo.
define variable a-n-c as character  VIEW-AS RADIO-SET horizontal RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 no-undo.
DEFINE BROWSE br-alt QUERY br-alt NO-LOCK
    DISPLAY fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена' LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена' LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз'
    ENABLE price-list.d-pcnt  price-list.price-sale  price-list.road-tax  price-list.excise
    WITH SIZE 98 BY 10.5
    bgcolor WHITE_COLOR
    separators.
DEFINE FRAME d-pr-alt
     b-exit        AT ROW 1 COL 1
     b-mark        AT ROW 1 COL 9
     b-add         AT ROW 1 COL 15
     b-discnt      AT ROW 1 COL 23
     b-chg         AT ROW 1 COL 31
     b-del         AT ROW 1 COL 39
     b-help        AT ROW 1 COL 79
     round-method  AT ROW 2 COL 73 COLON-ALIGNED LABEL "Окру&гление"
        format "x(15)" VIEW-AS COMBO-BOX INNER-LINES 7 LIST-ITEMS
        '9-окончание':U,
        '9-99окончание':U,
        'Без-дробных':U,
        'Произвольно':U,
        'Вверх':U,
        'Коэффициент':U,
        'Отключено':U SIZE 15 BY 1  bgcolor WHITE_COLOR
     round-base    AT ROW 2    COL 88 COLON-ALIGNED no-LABEL
        format "->>,>>9.99" VIEW-AS FILL-IN SIZE 10 BY 1 bgcolor WHITE_COLOR
     loc-art       AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало артикула"
     loc-name      AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало названия" format "x(40)"
     loc-code      AT ROW 2.5  COL 39 COLON-ALIGNED label "Бар-код (весь)"  format "x(13)"
     br-alt       AT ROW 3    COL 1.5
     a-n-c         at row 1    col 78 no-label
     rect-line     at row 13.6 col 1.5
     " Информация по строке " VIEW-AS TEXT SIZE 22 BY 0.8 AT ROW 13.1 COL 38
     price-list.price-sale
                   AT ROW 14.1 COL 80 COLON-ALIGNED label "Цена" fgcolor BROWN_COLOR
                   view-as fill-in size 15 by 0.79
     calc-price    AT ROW 15.1 COL 80 COLON-ALIGNED
     goods.artic   AT ROW 14.1 COL 10 COLON-ALIGNED label "Артикул"
                   view-as fill-in size 16 by 1
     goods.gds-name
                   AT ROW 14.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     goods.prod-type
                   AT ROW 15.1 COL 10 COLON-ALIGNED label "Пр-тель"
                   view-as fill-in size 3 by 1
     goods.prod-code
                   AT ROW 15.1 COL 13 COLON-ALIGNED no-label
                   view-as fill-in size 9 by 1
     clients.obj-name
                   AT ROW 15.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     gds-prt.f-name
                   AT ROW 16.1 COL 10 COLON-ALIGNED label "Признак" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     bar-code.in-code
                   AT ROW 16.1 COL 27 COLON-ALIGNED label "ПН" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     bar-code.part-code
                   AT ROW 16.1 COL 47 COLON-ALIGNED label "Партия" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "Список неосновных цен":L
         DEFAULT-BUTTON b-exit
         bgcolor grey_color.
ASSIGN
  FRAME d-pr-alt:SCROLLABLE = FALSE
  br-alt   :NUM-LOCKED-COLUMNS IN FRAME d-pr-alt = 1
  b-add     :POPUP-MENU IN FRAME d-pr-alt         = MENU m-add  :HANDLE
  b-add     :MENU-MOUSE                                = 1
  .
def var sort-labelbr-alt   as character no-undo .
def var sort-clmnbr-alt    as handle    no-undo .
def var cur-clmnbr-alt     as handle    no-undo .
def var cur-clmn-locbr-alt as integer   no-undo .
def var re-querybr-alt     as logical   initial no no-undo .
on start-search, ctrl-o of br-alt in frame d-pr-alt do:
   run sort-brbr-alt
     (input (if available price-list
             then recid(price-list)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-alt :
  define input parameter p-recid as recid no-undo .
  if re-querybr-alt = no then do:
    assign
       cur-clmnbr-alt = br-alt:current-column in frame d-pr-alt
    .
    if sort-clmnbr-alt <> ? then sort-clmnbr-alt:column-fgcolor = 0.
    if cur-clmnbr-alt = sort-clmnbr-alt then do:
      assign
         sort-labelbr-alt = ""
         sort-clmnbr-alt = ?
      .
     end.
     else do:
       assign
         sort-labelbr-alt = cur-clmnbr-alt:label
         sort-clmnbr-alt  = cur-clmnbr-alt
         sort-clmnbr-alt:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-alt = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-alt:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-alt then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-alt = cur-clmn-locbr-alt + 1
    .
  end.
  case sort-labelbr-alt:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-mark&1,price-list.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U"     .     run open-br.   . END.
        when 'Глав. код'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-main-code&1,price-list.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Осн. код'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-base-code&1,price-list.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Код'  then DO:    assign       sort-column-name = "bar-code.b-code"     .     run open-br.   . END.
        when 'Осн. цена'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-base-price&1,price-list.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Изм'  then DO:    assign       sort-column-name = "goods.unit-base"     .     run open-br.   . END.
        when 'Коэф'  then DO:    assign       sort-column-name = "bar-code.cli-base-rate"     .     run open-br.   . END.
        when 'Скидка'  then DO:    assign       sort-column-name = "price-list.d-pcnt"     .     run open-br.   . END.
        when 'Цена'  then DO:    assign       sort-column-name = "price-list.price-sale"     .     run open-br.   . END.
        when 'Изм'  then DO:    assign       sort-column-name = "bar-code.unit-cli"     .     run open-br.   . END.
        when dor-nal  then DO:    assign       sort-column-name = "price-list.road-tax"     .     run open-br.   . END.
        when 'Акциз'  then DO:    assign       sort-column-name = "price-list.excise"     .     run open-br.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run open-br.
      if sort-labelbr-alt <> "" then do:
        assign
          cur-clmnbr-alt:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-alt = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-alt to recid p-recid no-error.
    apply "value-changed" to br-alt in frame d-pr-alt.
  end.
  apply "entry" to br-alt in frame d-pr-alt.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-alt:
if cur-clmnbr-alt = ? then do:
   run open-br.
end.
else do:
   assign re-querybr-alt = yes.
   run sort-brbr-alt
     (input (if available price-list
             then recid(price-list)
             else ?
            )
     ).
   assign re-querybr-alt = no.
end.
end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-pr-alt anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-pr-alt anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-pr-alt anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-pr-alt anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-pr-alt anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
end.
on SHIFT-F9 of frame d-pr-alt anywhere do:
  if not available goods then
    return no-apply.
  gds-rec = recid (goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref44 as character no-undo .
define variable varpgscales-pref44 as character no-undo.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type45 as character no-undo.
varscales-pref44  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref44
  ,output varscales-pref-type45
  ) no-error .
if varscales-pref44 = ? then do:
  assign
  varscales-pref44 = '21,23,25':U.
end.
define variable varpgscales-pref-type45 as character no-undo.
varpgscales-pref44  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref44
  ,output varpgscales-pref-type45
  ) no-error .
if varpgscales-pref44 = ? then do:
  assign
  varpgscales-pref44 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-pr-alt do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-alt in frame d-pr-alt do:
  run proc-any-printable-br-alt in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-alt in frame d-pr-alt do:
  run proc-backspace-br-alt in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-pr-alt do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-pr-alt do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-pr-alt a-n-c :
    when "art" then do:
      apply "entry" to br-alt in frame d-pr-alt.
      hide loc-name loc-code
      in frame d-pr-alt.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-pr-alt.
      disp loc-name with frame d-pr-alt.
      hide loc-art loc-code
      in frame d-pr-alt.
      apply "entry" to loc-name in frame d-pr-alt.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-pr-alt.
      disp loc-code with frame d-pr-alt.
      hide loc-art loc-name
      in frame d-pr-alt.
      apply "entry" to loc-code in frame d-pr-alt.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-alt :
  if input frame d-pr-alt a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-price-list where
               l-price-list.doc-num = price-doc.doc-num and l-price-list.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-price-list then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-pr-alt.
      code-rec = recid (l-price-list).
      reposition br-alt to recid code-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-alt:
  if input frame d-pr-alt a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-price-list where
               l-price-list.doc-num = price-doc.doc-num and l-price-list.artic begins loc-art
               no-lock.
    disp loc-art with frame d-pr-alt.
    code-rec = recid (l-price-list).
    reposition br-alt to recid code-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame d-pr-alt
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  price-list.obj-type
,input  price-list.obj-code
,input  yes
,input  no
,input  varscales-pref44
,input  varpgscales-pref44
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-pr-alt = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  price-list.obj-type
,input  price-list.obj-code
,input  yes
,input  no
,input  varscales-pref44
,input  varpgscales-pref44
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-price-list where l-price-list.doc-num = price-doc.doc-num and
                  l-price-list.artic = l-goods.artic AND
                  l-price-list.prod-type = l-goods.prod-type AND
                  l-price-list.prod-code = l-goods.prod-code no-lock no-error.
    if available l-price-list then do:
      code-rec = recid (l-price-list).
      reposition br-alt to recid code-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-pr-alt.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-pr-alt
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-price-list where l-price-list.doc-num = price-doc.doc-num and
                can-find (ub.goods where ub.goods.artic = l-price-list.artic and
                ub.goods.prod-type = l-price-list.prod-type and
                ub.goods.prod-code = l-price-list.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-price-list where l-price-list.doc-num = price-doc.doc-num and
                can-find (ub.goods where ub.goods.artic = l-price-list.artic and
                ub.goods.prod-type = l-price-list.prod-type and
                ub.goods.prod-code = l-price-list.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-price-list then do:
      code-rec = recid (l-price-list).
      reposition br-alt to recid code-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-pr-alt.
END PROCEDURE.
on value-changed of br-alt in frame d-pr-alt do:
if not available ub.price-list or recid (ub.price-list) <> code-rec then do:
    hide loc-art in frame d-pr-alt.
    loc-art = "".
end.
end.
ON find OF goods DO: END.
ON find OF gds-obj DO: END.
on end-error of price-list.price-sale, price-list.road-tax, price-list.excise in browse br-alt do:
  disp fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена'  goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена'  bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз' with browse br-alt.
  return no-apply.
end.
ON MOUSE-SELECT-DBLCLICK, return OF br-alt IN FRAME d-pr-alt DO:
apply "choose" to b-mark in frame d-pr-alt.
END.
ON CHOOSE OF b-mark IN FRAME d-pr-alt
DO:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available price-list then
  return no-apply.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid48 as character no-undo .
define variable v-num-entry48 as integer   no-undo .
assign
  v-str-recid48 = trim( string( recid( price-list ) , "->>>>>>>>>>>9":U ) )
  v-num-entry48 = lookup( v-str-recid48 , mark-list )
.
if v-num-entry48 > 0 then do:
  assign
    entry( v-num-entry48, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid48
  .
end.
br-alt :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-alt :select-next-row ().
apply "entry" to br-alt in frame d-pr-alt.
END.
on row-display of br-alt do:
  if sort-column-name <> "calc-dtl"  then
    if gds-prt.upper-code = goods.prt-root then
      if bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-alt = BLACK_COLOR.
      else
        calc-dtl :fgcolor in browse br-alt = BLUE_COLOR.
    else
      calc-dtl :fgcolor in browse br-alt = DARK_GREEN_COLOR.
end.
on value-changed of br-alt in frame d-pr-alt do:
  if not available price-list then do:
    hide calc-price
         price-list.price-sale
         goods.artic
         goods.gds-name
         goods.prod-type
         goods.prod-code
         clients.obj-name
         gds-prt.f-name
         bar-code.in-code
         bar-code.part-code in frame d-pr-alt.
    return no-apply.
  end.
  if doc-mode = 'ИЗМЕНЕНИЕ':U then do:
    calc-price = fnc-base-price (bar-code.b-code, price-list.doc-num) *
                bar-code.cli-base-rate *
                (1 - price-list.d-pcnt / 100)
                .
case input frame d-pr-alt round-method :
  when '9-окончание':U then do:
    if calc-price < 29 then do:
      if (calc-price - truncate (calc-price, 0)) <> 0 then do:
        assign
          calc-price = truncate (calc-price, 0) + 1
        .
      end.
    end.
    else do:
      if (calc-price modulo 10) < 3 then do:
        assign
          calc-price = (calc-price - (calc-price modulo 100))
              + ( truncate (((calc-price modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          calc-price = (calc-price - (calc-price modulo 100))
              + ( truncate (((calc-price modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        calc-price = round (calc-price, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if calc-price < input frame d-pr-alt round-base then do:
      assign
        calc-price = truncate (calc-price, 0) + 0.99
      .
    end.
    else do:
      assign
        calc-price = truncate (calc-price / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      calc-price = round (calc-price, 0)
    .
  end.
  when 'Произвольно':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      assign
        calc-price = round (calc-price / input frame d-pr-alt round-base, 0) * input frame d-pr-alt round-base
      .
      if calc-price = 0 then do:
        assign
          calc-price = input frame d-pr-alt round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      if truncate ( calc-price / input frame d-pr-alt round-base, 0 ) <> (calc-price / input frame d-pr-alt round-base) then do:
        assign
          calc-price = truncate (calc-price / input frame d-pr-alt round-base, 0) * input frame d-pr-alt round-base + input frame d-pr-alt round-base
        .
      end.
    end.
    if calc-price = 0 then do:
      assign
        calc-price = input frame d-pr-alt round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      assign
        calc-price = calc-price * input frame d-pr-alt round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" input frame d-pr-alt round-method skip
      "round-base"   input frame d-pr-alt round-base   skip
      "price"        calc-price             skip
      view-as alert-box error .
  end.
end.
    disp calc-price with frame d-pr-alt.
  end.
  else
    hide calc-price in frame d-pr-alt.
  find clients no-lock where
       clients.obj-type = goods.prod-type and
       clients.obj-code = goods.prod-code.
  disp price-list.price-sale
       goods.artic
       goods.gds-name
       goods.prod-type
       goods.prod-code
       clients.obj-name with frame d-pr-alt.
  if gds-prt.upper-code = goods.prt-root then
    hide gds-prt.f-name in frame d-pr-alt.
  else
    disp gds-prt.f-name with frame d-pr-alt.
  if bar-code.in-code = "" then
    hide bar-code.in-code bar-code.part-code in frame d-pr-alt.
  else
    disp bar-code.in-code bar-code.part-code with frame d-pr-alt.
end.
on leave of price-list.price-sale in browse br-alt or
   leave of price-list.d-pcnt     in browse br-alt or
   leave of price-list.road-tax   in browse br-alt or
   leave of price-list.excise     in browse br-alt do:
  if not available price-list then
    return.
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale or
     decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt or
     decimal  (price-list.road-tax   :screen-value in browse br-alt) <> price-list.road-tax or
     decimal  (price-list.excise     :screen-value in browse br-alt) <> price-list.excise then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons YES-NO update g#log.
    if g#log then
      run upd-br-field.
  end.
  disp fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена'  goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена'  bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз' with browse br-alt.
  apply "value-changed" to br-alt in frame d-pr-alt.
end.
on return of price-list.price-sale in browse br-alt or
   return of price-list.d-pcnt     in browse br-alt or
   return of price-list.road-tax   in browse br-alt or
   return of price-list.excise     in browse br-alt do:
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale or
     decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt or
     decimal  (price-list.road-tax   :screen-value in browse br-alt) <> price-list.road-tax or
     decimal  (price-list.excise     :screen-value in browse br-alt) <> price-list.excise then
    run upd-br-field.
  disp fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена'  goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена'  bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз' with browse br-alt.
  apply "value-changed" to br-alt in frame d-pr-alt.
end.
ON CHOOSE OF b-discnt in frame d-pr-alt DO:
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-pr-discnt (input price-list.doc-num,
                    input bar-code.b-code) no-error.
disp fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена'  goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена'  bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз' with browse br-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END.
ON CHOOSE OF b-chg in frame d-pr-alt DO:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-pr-alt (input price-list.doc-num,
                input bar-code.b-code,
                input round-method,
                input round-base) no-error.
disp fnc-mark (price-list.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if gds-prt.upper-code = goods.prt-root then         if bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (price-list.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (price-list.b-code)   @ base-bc-br           COLUMN-LABEL 'Осн. код'  bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price (price-list.b-code, price-list.doc-num)   @ arg-base             COLUMN-LABEL 'Осн. цена'  goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  price-list.d-pcnt                          COLUMN-LABEL 'Скидка'  price-list.price-sale                         COLUMN-LABEL 'Цена'  bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  price-list.road-tax                          price-list.excise                         COLUMN-LABEL 'Акциз' with browse br-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END.
ON return OF round-base IN FRAME d-pr-alt DO:
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
END.
on end-error, stop of frame d-pr-alt do:
  apply "choose" to b-exit in frame d-pr-alt.
  return no-apply.
end.
ON CHOOSE OF MENU-ITEM m-lst-add DO:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-pr-alt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-alt skip
    "Тип" self :type in frame d-pr-alt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-pr-alt .
  if focus :handle <> b-add :handle in frame d-pr-alt then do:
    return no-apply .
  end.
end.
run add-alt ("all").
END.
ON CHOOSE OF MENU-ITEM m-cur-add DO:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-pr-alt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-alt skip
    "Тип" self :type in frame d-pr-alt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-pr-alt .
  if focus :handle <> b-add :handle in frame d-pr-alt then do:
    return no-apply .
  end.
end.
run add-alt ("current").
END.
ON CHOOSE OF b-del in frame d-pr-alt DO:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  code-rec = recid (price-list)
  g#log = no
  .
message "Удалить строку документа?   Вы уверены?"
        view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then
  return no-apply.
get next br-alt.
if available price-list then
  rep-rec = recid (price-list).
else do:
  reposition br-alt to recid code-rec no-error.
  get prev br-alt.
  if available price-list then
    rep-rec = recid (price-list).
end.
reposition br-alt to recid code-rec no-error.
find price-list where recid (price-list) = code-rec.
delete price-list.
code-rec = rep-rec.
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br.
END.
ON value-changed OF round-method IN FRAME d-pr-alt DO:
assign
  round-method.
run UI-on.
END.
ON LEAVE OF round-base IN FRAME d-pr-alt DO:
if input frame d-pr-alt round-base = 0 then do:
  if input frame d-pr-alt round-method = 'Произвольно':U then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
disp round-base with frame d-pr-alt.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pr-alt:PARENT eq ? THEN
  FRAME d-pr-alt:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-pr-alt APPLY "END-ERROR":U TO SELF.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pr-alt
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
on choose of b-help in frame d-pr-alt
do:
  apply "help":u to frame d-pr-alt .
end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-pr-alt:width - 0.3
                fh            = frame d-pr-alt:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run tax-name( input 'rdt':U, output  dor-nal) .
   assign price-list.road-tax :label  = dor-nal.
  if doc-mode <> 'ПРОСМОТР':U then
    code-rec = ?.
  find  price-doc no-lock where
        recid (price-doc) = doc-rec.
   define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  price-doc.host-code
        ,input  price-doc.obj-type
        ,input  price-doc.obj-code
      ) no-error .
  find  base-bar-code no-lock where
        base-bar-code.b-code = base-bc no-error.
  if available base-bar-code then
    find base-goods no-lock where
         base-goods.gds-code = base-bar-code.gds-code.
  case mode:
    when "code" then do:
    end.
    when "scl-gds" then do:
    end.
    when "par-gds" then do:
    end.
    when "scl-doc" then do:
    end.
    when "par-doc" then do:
    end.
    when "doc" then do:
    end.
  end case.
  run UI-on.
  run open-br.
  WAIT-FOR GO OF FRAME d-pr-alt focus br-alt.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-pr-alt.
END PROCEDURE.
PROCEDURE UI-on :
doc-rec = recid (price-doc).
disable all with frame d-pr-alt.
hide loc-art loc-name loc-code in frame d-pr-alt.
loc-art = "".
enable a-n-c b-exit b-help br-alt with frame d-pr-alt.
frame d-pr-alt:title = "Список неосновных цен переоценки № " + price-doc.doc-num.
case mode:
  when "code"    then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Код: " + string (base-bc, ">>>>>>>>9").
  when "scl-gds" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Товар: " + base-goods.artic + "  " + base-goods.gds-name +
                                "      ПРИЗНАКИ".
  when "par-gds" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Товар: " + base-goods.artic + "  " + base-goods.gds-name +
                                "      ПАРТИИ".
  when "scl-doc" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      ПРИЗНАКИ по переоценке".
  when "par-doc" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      ПАРТИИ по переоценке".
  when "doc"     then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Вся переоценка".
end.
frame d-pr-alt:title = frame d-pr-alt:title + "              " +
                            doc-mode.
if doc-mode = 'ПРОСМОТР':U then do:
  assign
    price-list.d-pcnt :read-only in browse br-alt = yes price-list.price-sale :read-only in browse br-alt = yes price-list.road-tax :read-only in browse br-alt = yes price-list.excise :read-only in browse br-alt = yes
    .
  hide round-method in frame d-pr-alt.
end.
else do:
  assign
    price-list.d-pcnt :read-only in browse br-alt = no price-list.price-sale :read-only in browse br-alt = no price-list.road-tax :read-only in browse br-alt = no price-list.excise :read-only in browse br-alt = no
    .
  disp round-method round-base with frame d-pr-alt.
  if lookup (mode, "code,scl-gds,par-gds") > 0 then
    enable b-add with frame d-pr-alt.
  enable b-mark b-discnt b-chg b-del round-method with frame d-pr-alt.
  if lookup( input frame d-pr-alt round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable round-base with frame d-pr-alt.
    disp round-base with frame d-pr-alt.
  end.
  else
    hide round-base in frame d-pr-alt.
end.
apply "entry" to br-alt in frame d-pr-alt.
END PROCEDURE.
PROCEDURE open-br :
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character     no-undo .
define variable d-num like price-doc.doc-num  no-undo.
assign
  l-query-was-opened = false
  d-num = price-doc.doc-num
  .
if sort-column-name = "" then
   sort-column-phrase = "" .
else
  sort-column-phrase = "by " + sort-column-name.
if available price-list then
  code-rec = recid (price-list).
case mode:
  when 'code-old'    then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-57  as logical   no-undo .
define variable  l-filter-open-57    as logical   .
define variable  flt-rec-57       as recid     no-undo .
define variable  filter-name-57      as character no-undo .
define variable  where-phrase-57     as character no-undo .
define variable  sort-phrase-57      as character no-undo .
define variable  where-phrase-rus-57 as character no-undo .
define variable  sort-phrase-rus-57  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-57
  ,output filter-name-57
  ,output where-phrase-57
  ,output sort-phrase-57
  ,output where-phrase-rus-57
  ,output sort-phrase-rus-57
  ).
  assign
    l-filter-open-57 = false
  .
  if flt-rec-57 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-57 as character no-undo .
    define variable  parameter-3-57 as character no-undo .
    define variable  parameter-4-57 as character no-undo .
    define variable  parameter-5-57 as character no-undo .
    define variable  parameter-6-57 as character no-undo .
    define variable  parameter-7-57 as character no-undo .
      assign
      parameter-3-57 =
                              "for each price-list"
      parameter-4-57 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-57) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = &2 and              bar-code.node-code = &3 and              bar-code.in-code   = &1&4&1 and              bar-code.part-code = &1&5&1              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-57 = if sort-phrase-57 = ''
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
        " " + sort-phrase-57
        )
      parameter-7-57 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          )
      .
      assign
        l-filter-open-57 = true
      .
    end.
    if l-filter-open-57 = false then do:
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
  if l-filter-open-57 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = base-bar-code.gds-code  and              bar-code.node-code = base-bar-code.node-code and              bar-code.in-code   = base-bar-code.in-code   and              bar-code.part-code = base-bar-code.part-code              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'code'    then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-59  as logical   no-undo .
define variable  l-filter-open-59    as logical   .
define variable  flt-rec-59       as recid     no-undo .
define variable  filter-name-59      as character no-undo .
define variable  where-phrase-59     as character no-undo .
define variable  sort-phrase-59      as character no-undo .
define variable  where-phrase-rus-59 as character no-undo .
define variable  sort-phrase-rus-59  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-59
  ,output filter-name-59
  ,output where-phrase-59
  ,output sort-phrase-59
  ,output where-phrase-rus-59
  ,output sort-phrase-rus-59
  ).
  assign
    l-filter-open-59 = false
  .
  if flt-rec-59 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-59 as character no-undo .
    define variable  parameter-3-59 as character no-undo .
    define variable  parameter-4-59 as character no-undo .
    define variable  parameter-5-59 as character no-undo .
    define variable  parameter-6-59 as character no-undo .
    define variable  parameter-7-59 as character no-undo .
      assign
      parameter-3-59 =
                              "for each price-list"
      parameter-4-59 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-59) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = &2               ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-59 = if sort-phrase-59 = ''
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
        " " + sort-phrase-59
        )
      parameter-7-59 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          )
      .
      assign
        l-filter-open-59 = true
      .
    end.
    if l-filter-open-59 = false then do:
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
  if l-filter-open-59 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = base-bar-code.gds-code                ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'scl-gds' then do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-61  as logical   no-undo .
define variable  l-filter-open-61    as logical   .
define variable  flt-rec-61       as recid     no-undo .
define variable  filter-name-61      as character no-undo .
define variable  where-phrase-61     as character no-undo .
define variable  sort-phrase-61      as character no-undo .
define variable  where-phrase-rus-61 as character no-undo .
define variable  sort-phrase-rus-61  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-61
  ,output filter-name-61
  ,output where-phrase-61
  ,output sort-phrase-61
  ,output where-phrase-rus-61
  ,output sort-phrase-rus-61
  ).
  assign
    l-filter-open-61 = false
  .
  if flt-rec-61 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-61 as character no-undo .
    define variable  parameter-3-61 as character no-undo .
    define variable  parameter-4-61 as character no-undo .
    define variable  parameter-5-61 as character no-undo .
    define variable  parameter-6-61 as character no-undo .
    define variable  parameter-7-61 as character no-undo .
      assign
      parameter-3-61 =
                              "for each price-list"
      parameter-4-61 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-61) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = &2 and              bar-code.node-code = &3 and              bar-code.in-code   = &1&1 and              bar-code.part-code = &1&1              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-61 = if sort-phrase-61 = ''
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
        " " + sort-phrase-61
        )
      parameter-7-61 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-61 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-61 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
                          )
      .
      assign
        l-filter-open-61 = true
      .
    end.
    if l-filter-open-61 = false then do:
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
  if l-filter-open-61 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = base-bar-code.gds-code  and              bar-code.node-code = base-bar-code.node-code and              bar-code.in-code   = ''   and              bar-code.part-code = ''               ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'par-gds' then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-63  as logical   no-undo .
define variable  l-filter-open-63    as logical   .
define variable  flt-rec-63       as recid     no-undo .
define variable  filter-name-63      as character no-undo .
define variable  where-phrase-63     as character no-undo .
define variable  sort-phrase-63      as character no-undo .
define variable  where-phrase-rus-63 as character no-undo .
define variable  sort-phrase-rus-63  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-63
  ,output filter-name-63
  ,output where-phrase-63
  ,output sort-phrase-63
  ,output where-phrase-rus-63
  ,output sort-phrase-rus-63
  ).
  assign
    l-filter-open-63 = false
  .
  if flt-rec-63 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-63 as character no-undo .
    define variable  parameter-3-63 as character no-undo .
    define variable  parameter-4-63 as character no-undo .
    define variable  parameter-5-63 as character no-undo .
    define variable  parameter-6-63 as character no-undo .
    define variable  parameter-7-63 as character no-undo .
      assign
      parameter-3-63 =
                              "for each price-list"
      parameter-4-63 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-63) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-63
          else "true"
        )
      parameter-5-63 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = &2 and              bar-code.in-code   <> &1&&1              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                ))
      parameter-6-63 = if sort-phrase-63 = ''
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
        " " + sort-phrase-63
        )
      parameter-7-63 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-63 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-63 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-63
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ,input parameter-6-63
                          ,input parameter-7-63
                          )
      .
      assign
        l-filter-open-63 = true
      .
    end.
    if l-filter-open-63 = false then do:
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
  if l-filter-open-63 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.gds-code  = base-bar-code.gds-code  and              bar-code.in-code   <> ''              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'scl-doc' then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-65  as logical   no-undo .
define variable  l-filter-open-65    as logical   .
define variable  flt-rec-65       as recid     no-undo .
define variable  filter-name-65      as character no-undo .
define variable  where-phrase-65     as character no-undo .
define variable  sort-phrase-65      as character no-undo .
define variable  where-phrase-rus-65 as character no-undo .
define variable  sort-phrase-rus-65  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-65
  ,output filter-name-65
  ,output where-phrase-65
  ,output sort-phrase-65
  ,output where-phrase-rus-65
  ,output sort-phrase-rus-65
  ).
  assign
    l-filter-open-65 = false
  .
  if flt-rec-65 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-65 as character no-undo .
    define variable  parameter-3-65 as character no-undo .
    define variable  parameter-4-65 as character no-undo .
    define variable  parameter-5-65 as character no-undo .
    define variable  parameter-6-65 as character no-undo .
    define variable  parameter-7-65 as character no-undo .
      assign
      parameter-3-65 =
                              "for each price-list"
      parameter-4-65 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-65) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.in-code   = &1&4&1 and              bar-code.part-code = &1&5&1              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-65 = if sort-phrase-65 = ''
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
        " " + sort-phrase-65
        )
      parameter-7-65 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-65 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-65 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
                          )
      .
      assign
        l-filter-open-65 = true
      .
    end.
    if l-filter-open-65 = false then do:
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
  if l-filter-open-65 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.in-code   = '' and              bar-code.part-code = ''               ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'par-doc' then do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-67  as logical   no-undo .
define variable  l-filter-open-67    as logical   .
define variable  flt-rec-67       as recid     no-undo .
define variable  filter-name-67      as character no-undo .
define variable  where-phrase-67     as character no-undo .
define variable  sort-phrase-67      as character no-undo .
define variable  where-phrase-rus-67 as character no-undo .
define variable  sort-phrase-rus-67  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-67
  ,output filter-name-67
  ,output where-phrase-67
  ,output sort-phrase-67
  ,output where-phrase-rus-67
  ,output sort-phrase-rus-67
  ).
  assign
    l-filter-open-67 = false
  .
  if flt-rec-67 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-67 as character no-undo .
    define variable  parameter-3-67 as character no-undo .
    define variable  parameter-4-67 as character no-undo .
    define variable  parameter-5-67 as character no-undo .
    define variable  parameter-6-67 as character no-undo .
    define variable  parameter-7-67 as character no-undo .
      assign
      parameter-3-67 =
                              "for each price-list"
      parameter-4-67 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-67) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-67
          else "true"
        )
      parameter-5-67 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.in-code   <> &1&&1              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-67 = if sort-phrase-67 = ''
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
        " " + sort-phrase-67
        )
      parameter-7-67 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-67 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-67 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-67
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ,input parameter-6-67
                          ,input parameter-7-67
                          )
      .
      assign
        l-filter-open-67 = true
      .
    end.
    if l-filter-open-67 = false then do:
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
  if l-filter-open-67 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code and              bar-code.in-code   <> ''              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'doc'     then do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-69  as logical   no-undo .
define variable  l-filter-open-69    as logical   .
define variable  flt-rec-69       as recid     no-undo .
define variable  filter-name-69      as character no-undo .
define variable  where-phrase-69     as character no-undo .
define variable  sort-phrase-69      as character no-undo .
define variable  where-phrase-rus-69 as character no-undo .
define variable  sort-phrase-rus-69  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-69
  ,output filter-name-69
  ,output where-phrase-69
  ,output sort-phrase-69
  ,output where-phrase-rus-69
  ,output sort-phrase-rus-69
  ).
  assign
    l-filter-open-69 = false
  .
  if flt-rec-69 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-69 as character no-undo .
    define variable  parameter-3-69 as character no-undo .
    define variable  parameter-4-69 as character no-undo .
    define variable  parameter-5-69 as character no-undo .
    define variable  parameter-6-69 as character no-undo .
    define variable  parameter-7-69 as character no-undo .
      assign
      parameter-3-69 =
                              "for each price-list"
      parameter-4-69 =
        (
          if ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-69) <> ""
          then               substitute ( ' price-list.doc-num = &2&1&2 and                             price-list.price-type = &2&2 ', d-num , chr(34) )  + " " + where-phrase-69
          else "true"
        )
      parameter-5-69 = (" " + "" + " " + substitute(' ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code                ', chr(34)                   , base-bar-code.gds-code                , base-bar-code.node-code               , base-bar-code.in-code                 , base-bar-code.part-code ))
      parameter-6-69 = if sort-phrase-69 = ''
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
        " " + sort-phrase-69
        )
      parameter-7-69 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-69 =
          ("              price-list.doc-num = d-num and              price-list.price-type = '' " + " " + where-phrase-69 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-69
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ,input parameter-6-69
                          ,input parameter-7-69
                          )
      .
      assign
        l-filter-open-69 = true
      .
    end.
    if l-filter-open-69 = false then do:
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
  if l-filter-open-69 = false then do:
    open query br-alt for each price-list no-lock
      where               price-list.doc-num = d-num and              price-list.price-type = ''
    ,         each bar-code no-lock where              bar-code.b-code    = price-list.b-code              ,         each goods no-lock where              goods.gds-code   = bar-code.gds-code and              goods.unit-base <> bar-code.unit-cli,         each gds-prt no-lock where              gds-prt.node-code = bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
end case.
if code-rec <> ? then
  reposition br-alt to recid code-rec no-error.
apply "entry" to br-alt in frame d-pr-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END PROCEDURE.
PROCEDURE add-alt :
define input  parameter add-list as character  no-undo.
define variable rec-list as character     no-undo.
define variable num-rec  as integer no-undo.
run ref/alt-cds.w  ( parParentProc
                ,input price-doc.obj-type
                ,input price-doc.obj-code
                ,input (mode + "-" + add-list)
                ,input base-goods.gds-code
                ,input base-bc
                ,output rec-list).
apply "entry" to br-alt in frame d-pr-alt.
if rec-list = '' then
  return no-apply.
code-rec = ?.
define variable v-1 as integer   no-undo .
v-1 = num-entries (rec-list) .
do num-rec = 1 to v-1 :
  ref-rec = integer (entry (num-rec, rec-list)).
  find bar-code no-lock where
       recid (bar-code) = ref-rec.
  run cre-pr-list (input  bar-code.b-code,
                   input  price-doc.doc-num,
                   output code-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" bar-code.b-code
      view-as alert-box.
    next.
  end.
  run calc-pr-alt (input price-doc.doc-num,
                   input bar-code.b-code,
                   input round-method,
                   input round-base) no-error.
  if error-status:error then
    next.
end.
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br.
END PROCEDURE.
procedure upd-br-field:
  find current price-list.
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale then do:
    assign
      price-list.calc-method = 'Отсутствует':U
      price-list.price-calc = price-list.price-sale
      price-list.price-sale = decimal  (price-list.price-sale :screen-value in browse br-alt)
      .
    if price-list.d-pcnt = ? then do:
    end.
  end.
  else do:
    if decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt then do:
      price-list.d-pcnt     = decimal  (price-list.d-pcnt     :screen-value in browse br-alt).
      if price-list.d-pcnt <> ? then do:
          run calc-pr-alt (input price-doc.doc-num,
                           input price-list.b-code,
                           input round-method,
                           input round-base) no-error.
          if error-status:error then
             return error.
      end.
    end.
    else
      assign
        price-list.road-tax   = decimal  (price-list.road-tax   :screen-value in browse br-alt)
        price-list.excise     = decimal  (price-list.excise     :screen-value in browse br-alt)
        .
  end.
end procedure.
procedure exp-prt:
  define input  parameter  g-code  like ub.goods.gds-code    no-undo.
  define input  parameter  old-num like ub.price-doc.doc-num no-undo.
  define input  parameter  new-num like ub.price-doc.doc-num no-undo.
  define output parameter  new-rec as recid               no-undo.
  define buffer buf-bar-code   for ub.bar-code.
  define buffer buf-goods      for ub.goods.
  define buffer buf-price-list for ub.price-list.
  find buf-goods no-lock where
      buf-goods.gds-code = g-code.
  if par-pr-altex = "yes" and
     par-pr-notls = "yes" then do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each  buf-price-list where
          buf-price-list.doc-num    = old-num and
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
  end.
  if par-pr-sclex = "yes" and
    par-pr-notls = "yes" then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define buffer buf_alt-calc_price-doc72 for ub.price-doc .
  find first buf_alt-calc_price-doc72 no-lock
    where buf_alt-calc_price-doc72.doc-num = old-num
    .
  define variable v-ok as logical   no-undo .
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_properties':U
    ,input  'object':U
    ,input  buf_alt-calc_price-doc72.host-code
    ,input  buf_alt-calc_price-doc72.obj-type
    ,input  buf_alt-calc_price-doc72.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
  if v-ok then do:
for each  buf-price-list where
          buf-price-list.doc-num    = old-num and
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.in-code = "" and
          buf-bar-code.unit-cli = buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
end.
  end.
  end procedure.
def var vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
