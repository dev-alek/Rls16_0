define  input parameter parparentproc   as   widget-handle           no-undo.
define  input parameter parlist-mode    as   character               no-undo.
define  input parameter parstat         as   character               no-undo.
define  input parameter partype         as   character               no-undo.
define  input parameter parflag         as   logical                 no-undo.
define  input parameter parinternal     as   logical                 no-undo.
define  input parameter bttns           as   character               no-undo.
define  input parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define  input parameter paris-hold      as   logical                 no-undo.
define  input parameter doc-rec         as   recid                   no-undo.
define  input parameter p-obj-type      like ub.trn-doc.obj-type     no-undo.
define  input parameter p-obj-code      like ub.trn-doc.obj-code     no-undo.
define output parameter mark-list       as   character               no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Список удаленных документов":U .
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
    assign
      p-vss-parameters = substitute('&1|&2',bttns,parext-doc-type)
    .
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
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable filter-point as character no-undo init "Список удаленных документов" .
define variable filter-point0 as character no-undo init "calldocs" .
define variable title0 as character no-undo init "Удаленные документы " .
define variable title1 as character no-undo init "История документа " .
define variable sort-column-name as character no-undo .
define variable is-finvalue as character no-undo.
define variable is-fintype  as character no-undo.
define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.
define new shared variable br-handle as handle no-undo.
define new shared buffer c-t-doc  for ub.c-trn-doc.
define new shared buffer sch-pay  for ub.pay-type.
define new shared buffer sch-curr for ub.currency.
define new shared buffer sch-cli  for ub.clients.
define variable varempty-string as   character               no-undo.
assign
varempty-string = ''
.
define buffer cli-buf for ub.clients.
define buffer c-t-d-b for ub.c-trn-doc.
define variable sch-field   as character no-undo.
define variable v_shift     as character no-undo initial ?.
define variable v_data-type as character no-undo initial ?.
define variable varhold         as character no-undo.
define variable varhold-type    as character no-undo.
define variable objects         as integer   no-undo.
define variable mark            as character no-undo.
define variable varlog          as logical   no-undo.
define variable g#report-num    as integer   no-undo.
define variable v-button-order   as character no-undo .
run get-report-num in parparentproc ( output g#report-num ).
define buffer bf_clients for ub.clients.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-finvalue
  ,output is-fintype
  ) no-error .
if is-finvalue = "yes" then do:
  DEFINE MENU POPUP-MENU-b-gen
    MENU-ITEM m_gen-1  LABEL "Финансовые обязательства"                                     ACCELERATOR "ALT-1"
    MENU-ITEM m_gen-2  LABEL "Отказаться от генерации финобязательств по поставке"          ACCELERATOR "ALT-2"
    MENU-ITEM m_gen-3  LABEL "Отказаться от генерации финобязательств по реализации"        ACCELERATOR "ALT-3"
    MENU-ITEM m_gen-4  LABEL "Снять признак - есть генерация финобязательств по поставке"   ACCELERATOR "ALT-4"
    MENU-ITEM m_gen-5  LABEL "Снять признак - есть генерация финобязательств по реализации" ACCELERATOR "ALT-5"
  .
  define buffer buf_name_clients for clients.
  find first buf_name_clients no-lock where
             buf_name_clients.obj-code = v-cntxt-host-code-obj and
             buf_name_clients.obj-type = 'орг':U
       .
  if available buf_name_clients then do:
    assign v-host-name = buf_name_clients.obj-name.
     assign
      v-host-code = v-cntxt-host-code-obj
      p-obj-type  = v-cntxt-obj-type
      p-obj-code  = v-cntxt-obj-code
    .
  end.
  run make-gen-button in this-procedure.
  run make-fo-button  in this-procedure.
  v-button-order = "b-quit,b-mark," + (if lookup("b-sel", bttns) > 0 then "b-sel," else '') + "but-fo,but-gen,b-lkp,b-lines,b-sums,b-sch,b-help".
  on choose of menu-item m_gen-1 in menu popup-menu-b-gen do: run proc-m_gen-1 in this-procedure. end.
  on choose of menu-item m_gen-2 in menu popup-menu-b-gen do: run proc-m_gen-2 in this-procedure. end.
  on choose of menu-item m_gen-3 in menu popup-menu-b-gen do: run proc-m_gen-3 in this-procedure. end.
  on choose of menu-item m_gen-4 in menu popup-menu-b-gen do: run proc-m_gen-4 in this-procedure. end.
  on choose of menu-item m_gen-5 in menu popup-menu-b-gen do: run proc-m_gen-5 in this-procedure. end.
end.
else do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_name_clients no-lock where buf_name_clients.obj-code = v-host-code
         and buf_name_clients.obj-type = 'орг':U
         .
    if available buf_name_clients then do:
      assign v-host-name = buf_name_clients.obj-name.
    end.
end.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     size 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     size 10 BY 1.
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     size 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     size 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     size 3 BY 1.
DEFINE BUTTON b-lines
     LABEL "&Строки"
     size 10 BY 1.
define variable agnt-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.
define variable boss-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.
define variable obj-name as character format "x(256)":u
      view-as text
     size 34 by 1 no-undo.
define variable ed-notes as character
     view-as editor
     size 98 by 2 no-undo.
define variable varpost   as character no-undo.
define variable varrealiz as character no-undo.
define variable varchold  as logical   no-undo.
define variable sch-code like ub.trn-doc.doc-code                       no-undo.
define variable sch-date as   date    view-as fill-in size 9.00 by 1.00 no-undo.
define variable sch-fact as   date    view-as fill-in size 9.00 by 1.00 no-undo.
define variable sch-num  as   integer view-as fill-in size 3.00 by 1.00 no-undo.
define new shared query br-docs    for c-t-doc      scrolling.
define            query br-changes for temp-changes scrolling.
function mark-string returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( if lookup( string( recid( loc-c-t-doc ) ), mark-list ) > 0 then "*" else "":U ).
end function.
function first-symb-type returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( loc-c-t-doc.doc-type, 1, 1 ) ).
end function.
function day-month returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( ( string( loc-c-t-doc.doc-date ) ), 1, 5 ) ).
end function.
function shift-day-month returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( ( string( loc-c-t-doc.shift-date ) ), 1, 5 ) ).
end function.
function shift-name return char  ( p-rec as recid ) :
def buffer c-loc-t-doc for ub.c-trn-doc .
find first c-loc-t-doc no-lock where recid(c-loc-t-doc) = p-rec no-error . if error-status :error then return "" .
  if c-loc-t-doc.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if c-loc-t-doc.shift-num = integer(c-loc-t-doc.shift-name) then do:
      return c-loc-t-doc.shift-name.
    end.
    else do:
      return c-loc-t-doc.shift-name + "(" + string(c-loc-t-doc.shift-num) + ")".
    end.
  end.
end function.
function object-label returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( trim( loc-c-t-doc.obj-type ) + " ":U + string( loc-c-t-doc.obj-code, ">>>>9":U ) ).
end function.
function total-sum returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.tot-rubl else loc-c-t-doc.tot-doc ).
end function.
function total-dsc returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  if lookup( loc-c-t-doc.doc-type, 'рас,спи,возврат':U ) > 0 then do:
    return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.discnt-rubl
                                       else loc-c-t-doc.tot-doc - loc-c-t-doc.tot-cli ).
  end.
  else do:
    return ( 0.00 ).
  end.
end function.
function total-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.tot-sale else loc-c-t-doc.tot-fact ).
end function.
function total-dsc-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ?.
  if lookup( loc-c-t-doc.doc-type, 'рас,спи,возврат':U ) > 0 then do:
    return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.discnt-rubl else loc-c-t-doc.tot-calc ).
  end.
  else do:
    return ( 0.00 ).
  end.
end function.
function total-pay-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  if loc-c-t-doc.doc-type = 'при':U and
     loc-c-t-doc.internal = no        then do:
    return ( loc-c-t-doc.tot-calc ).
  end.
  else do:
    return ( if loc-c-t-doc.print-rubl then ( loc-c-t-doc.tot-sale - loc-c-t-doc.discnt-rubl )
                                       else ( loc-c-t-doc.tot-fact - loc-c-t-doc.tot-calc    ) ).
  end.
end function.
function total-vat returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.vat-rubl else loc-c-t-doc.vat-base ).
end function.
function total-slt returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.slt-rubl else loc-c-t-doc.slt-base ).
end function.
function fo-postavka returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  if loc-c-t-doc.cr-incfo = yes then do:
    return string( loc-c-t-doc.incfo-date, "99/99/99":U ).
  end.
  else do:
    if loc-c-t-doc.need-incfo = 0 then do:
      return "--------".
    end.
    if loc-c-t-doc.need-incfo = 1 then do:
      return "".
    end.
    if loc-c-t-doc.need-incfo = 2 then do:
      return "не опред".
    end.
  end.
end function.
function fo-realiz returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  if loc-c-t-doc.cr-expfo = yes then do:
    return string( loc-c-t-doc.expfo-date, "99/99/99":U ).
  end.
  else do:
    if loc-c-t-doc.need-expfo = 0 then do:
      return "--------".
    end.
    if loc-c-t-doc.need-expfo = 1 then do:
      return "".
    end.
    if loc-c-t-doc.need-expfo = 2 then do:
      return "не опред".
    end.
  end.
end function.
function c-holding returns logical ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return false  .
  define variable l_holding as logical no-undo.
  run get-c-holding in this-procedure ( input loc-c-t-doc.doc-code, output l_holding ) no-error.
  return ( if error-status :error or l_holding <> yes then no else yes ).
end function.
define browse br-docs query br-docs no-lock display
  mark-string( recid (c-t-doc) )              column-label '*'  format "x(1)"
  first-symb-type( recid (c-t-doc) )              column-label 'Т'  format "x(1)"
  c-t-doc.status_              column-label 'Стат'  format "x(4)"
  c-t-doc.flag_              column-label 'OK'  format "+/-"
  c-t-doc.doc-code              column-label 'Номер'
  day-month( recid (c-t-doc) )              column-label 'Дата'  format "x(5)"
  c-t-doc.fact-date              column-label 'Факт'
  c-t-doc.corr-date              column-label 'Удал(корр)'
  string(c-t-doc.corr-time, "HH:MM")             column-label 'Время'
  c-t-doc.ship-date             column-label 'Дата'
  c-t-doc.corr-user-name             column-label 'Кто'
  usrfulnf(c-t-doc.user-name)        column-label "Исправил"
  c-t-doc.action             column-label 'Действие'
  c-t-doc.chip-num             column-label '№ изменения' format ">>>,>>>,>>9"
  c-t-doc.reason-code             column-label 'Код причины'
  shift-day-month( recid (c-t-doc) )              column-label 'Смена'  format "x(6)"
  shift-name (recid (c-t-doc))             column-label '№' format "99"
  c-t-doc.internal             column-label 'В' format "+/-"
  c-t-doc.cli-name             column-label 'Контрагент' format "x(26)"
  object-label( recid (c-t-doc) )             column-label 'Объект' format "x(9)"
  c-t-doc.office             column-label 'У' format "+/-"
  c-t-doc.doc-qnty             column-label 'Кол-во по док.'
  c-t-doc.fact-qnty             column-label 'Кол-во факт'
  c-t-doc.print-rubl             column-label '$' format "-/$"
  total-sum( recid (c-t-doc) )             column-label 'Сумма по док' format "->,>>>,>>>,>>>,>>9.99"
  total-dsc( recid (c-t-doc) )             column-label 'Скидка по док' format "->,>>>,>>>,>>>,>>9.99"
  total-fact( recid (c-t-doc) )             column-label 'Сумма факт' format "->,>>>,>>>,>>>,>>9.99"
  total-dsc-fact( recid (c-t-doc) )             column-label 'Скидка факт' format "->,>>>,>>>,>>>,>>9.99"
  total-pay-fact( recid (c-t-doc) )             column-label 'К оплате факт' format "->,>>>,>>>,>>>,>>9.99"
  total-vat( recid (c-t-doc) )             column-label 'НДС' format "->,>>>,>>>,>>>,>>9.99"
  total-slt( recid (c-t-doc) )             column-label 'Налог прод.' format "->,>>>,>>>,>>>,>>9.99"
  c-t-doc.discnt-pc             column-label 'Скидка (%)' format "->,>>9.99"
  c-t-doc.discnt-type             column-label 'Тип скидки'
  c-t-doc.base-rate             column-label 'Курс'
  c-t-doc.ov             column-label 'А'
  c-t-doc.tot-ov             column-label 'Авт. переоц. (баз.вал.)'
  c-t-doc.inv-num             column-label 'Инвойс'
  c-t-doc.ord-num             column-label 'Заказ'
  c-t-doc.ship-num             column-label 'Отгрузка'
  c-t-doc.out-code             column-label 'На док-т'
  c-t-doc.is-back-date             column-label 'Задним числом'
  c-t-doc.bge-date             column-label 'Выгрузка'
  c-t-doc.rsrv-date             column-label 'Резерв'
  fo-postavka( recid (c-t-doc) ) @ varpost   column-label 'ФО.поставка' format "x(8)"
  fo-realiz( recid (c-t-doc) ) @ varrealiz column-label 'ФО.реализация' format "x(8)"
  c-holding( recid (c-t-doc) ) @ varchold  column-label 'Меж.фирм' format "Межфирм/ ":U
  usrfulnf(c-t-doc.creid)            column-label "Создал"
enable
  c-t-doc.ship-num
with size 98 by 14.5 separators.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.
define frame d-calldocs
  b-quit            at row  1.00 col  1.00
  b-mark            at row  1.00 col 10.00
  b-sel             at row  1.00 col 13.00
  b-lkp             at row  1.00 col 23.00
  b-lines           at row  1.00 col 53.00
  b-sch             at row  1.00 col 92.00
  b-help            at row  1.00 col 95.00
  br-docs           at row  2.30 col  1.00
  sch-code          at row 20.00 col  2.00                  label "&Начало номера"
  sch-date          at row 20.00 col 32.00                  label "Д&ата"
  sch-fact          at row 20.00 col 52.00                  label "Фа&кт"
  sch-num           at row 20.00 col 70.00                  label "Найдено"                             fgcolor 12
  pay-type.obj-name at row 18.00 col  5.00 colon-aligned    label "Опл"    view-as fill-in size 34 by 1 fgcolor  4
  obj-name          at row 18.00 col 55.00 colon-aligned    label "Объект" view-as fill-in size 34 by 1 fgcolor  4
  boss-name         at row 19.00 col  5.00 colon-aligned    label "М-р"    view-as fill-in size 14 by 1 fgcolor  4
  agnt-name         at row 19.00 col 30.00 colon-aligned    label "Исп"    view-as fill-in size 14 by 1 fgcolor  4
  wrkr-name         at row 19.00 col 55.00 colon-aligned    label "Кл-к"   view-as fill-in size 14 by 1 fgcolor  4
  c-t-doc.creid     at row 19.00 col 80.00 colon-aligned    label "Опер"   view-as fill-in size 14 by 1 fgcolor  4
  ed-notes          at row 21.00 col  1.00               no-label                             bgcolor 8 fgcolor  4
  br-changes        at row 17    col 1
  space( 0 ) skip( 0.5 )
with view-as dialog-box keep-tab-order
         side-labels no-underline three-d scrollable
         default-button b-quit.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame d-calldocs
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
on delete-character of sch-date in frame d-calldocs
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
on ctrl-d of sch-date in frame d-calldocs
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
on ctrl-b of sch-date in frame d-calldocs
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
on ctrl-e of sch-date in frame d-calldocs
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
on ctrl-f of sch-date in frame d-calldocs
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
  define MENU m-ed-date14
    MENU-ITEM m-ed-date14-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date14-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date14-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date14-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame d-calldocs = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame d-calldocs = MENU m-ed-date14 :HANDLE
      sch-date :MENU-MOUSE in frame d-calldocs = 3
    .
  end.
  define variable v-label-handle14 as handle no-undo .
  assign
    v-label-handle14 = sch-date :side-label-handle in frame d-calldocs
  .
  if valid-handle (v-label-handle14)
  then do:
    if v-label-handle14 :tooltip = ""
    or v-label-handle14 :tooltip = ?
    then do:
      assign
        v-label-handle14 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date14-1 in menu m-ed-date14 DO:
    apply "ctrl-b":U to sch-date in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-2 in menu m-ed-date14 DO:
    apply "ctrl-d":U to sch-date in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-3 in menu m-ed-date14 DO:
    apply "ctrl-e":U to sch-date in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-4 in menu m-ed-date14 DO:
    apply "ctrl-f":U to sch-date in frame d-calldocs .
  END.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact in frame d-calldocs
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
on delete-character of sch-fact in frame d-calldocs
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
on ctrl-d of sch-fact in frame d-calldocs
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
on ctrl-b of sch-fact in frame d-calldocs
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
on ctrl-e of sch-fact in frame d-calldocs
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
on ctrl-f of sch-fact in frame d-calldocs
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
  define MENU m-ed-date16
    MENU-ITEM m-ed-date16-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date16-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date16-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date16-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact :POPUP-MENU in frame d-calldocs = ?
  then do:
    ASSIGN
      sch-fact :POPUP-MENU in frame d-calldocs = MENU m-ed-date16 :HANDLE
      sch-fact :MENU-MOUSE in frame d-calldocs = 3
    .
  end.
  define variable v-label-handle16 as handle no-undo .
  assign
    v-label-handle16 = sch-fact :side-label-handle in frame d-calldocs
  .
  if valid-handle (v-label-handle16)
  then do:
    if v-label-handle16 :tooltip = ""
    or v-label-handle16 :tooltip = ?
    then do:
      assign
        v-label-handle16 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date16-1 in menu m-ed-date16 DO:
    apply "ctrl-b":U to sch-fact in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-2 in menu m-ed-date16 DO:
    apply "ctrl-d":U to sch-fact in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-3 in menu m-ed-date16 DO:
    apply "ctrl-e":U to sch-fact in frame d-calldocs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-4 in menu m-ed-date16 DO:
    apply "ctrl-f":U to sch-fact in frame d-calldocs .
  END.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame d-calldocs do:
   run sort-brbr-docs
     (input (if available c-t-doc
             then recid(c-t-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame d-calldocs
    .
    if sort-clmnbr-docs <> ? then sort-clmnbr-docs:column-fgcolor = 0.
    if cur-clmnbr-docs = sort-clmnbr-docs then do:
      assign
         sort-labelbr-docs = ""
         sort-clmnbr-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs = cur-clmnbr-docs:label
         sort-clmnbr-docs  = cur-clmnbr-docs
         sort-clmnbr-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs = cur-clmn-locbr-docs + 1
    .
  end.
  case sort-labelbr-docs:
        when '*'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Т'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Стат'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'OK'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Номер'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Дата'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Факт'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Удал(корр)'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Смена'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when '№'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'В'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Контрагент'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Объект'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'У'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Кол-во по док.'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Кол-во факт'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when '$'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Сумма по док'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Скидка по док'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Сумма факт'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Скидка факт'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'К оплате факт'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'НДС'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Налог прод.'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Скидка (%)'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Тип скидки'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Курс'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'А'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Авт. переоц. (баз.вал.)'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Инвойс'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Заказ'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Отгрузка'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Дата'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'На док-т'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Задним числом'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Выгрузка'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Резерв'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'ФО.поставка'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'ФО.реализация'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Меж.фирм'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Кто'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when '№ изменения'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Код причины'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
        when 'Действие'  then DO:   run OpenBr in this-procedure ( input yes, input no, input no  ).   . END.
    otherwise do:
      run OpenBr in this-procedure ( input yes, input no, input no  ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-docs') then do:
          run mv-brw-defaultbr-docs.
        end.
      if sort-labelbr-docs <> "" then do:
        assign
          cur-clmnbr-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-docs to recid p-recid no-error.
    apply "value-changed" to br-docs in frame d-calldocs.
  end.
  apply "entry" to br-docs in frame d-calldocs.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no  ).
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available c-t-doc
             then recid(c-t-doc)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
on start-search, ctrl-o of br-docs in frame d-calldocs do:
end.
assign
  frame d-calldocs :scrollable       = false
  br-docs :num-locked-columns in frame d-calldocs = 5
.
on any-printable of br-docs in frame d-calldocs do:
  apply "entry" to sch-code in frame d-calldocs.
end.
on choose of b-sch in frame d-calldocs do:
  run init-flt in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  do on stop undo, leave :
    run gbl/filter.w ( input parparentproc,
                   input filter-point,
                   input tbl,
                   input join-tbl,
                   input fld,
                   input lab,
                   input spr,
                   input dim ).
    run OpenBr in this-procedure ( input yes, input no, input no ).
  end.
end.
ON CHOOSE OF b-sel IN FRAME d-calldocs
DO:
 run local-sel in this-procedure.
END.
on choose of b-mark in frame d-calldocs do:
define variable glog as logical no-undo .
  RUN local-mark.
  glog = br-docs:select-next-row ().
  apply "entry" to br-docs in frame d-calldocs.
end.
ON CHOOSE OF b-lkp IN FRAME d-calldocs
DO:
  if available c-t-doc then do:
    run str/c-doc.w ( input parparentproc, input c-t-doc.doc-code, input c-t-doc.chip-num ).
  end.
end.
on choose of b-quit in frame d-calldocs
do:
  assign doc-rec = ?.
end.
on entry of ed-notes in frame d-calldocs
do:
  if not available c-t-doc then do:
    message "Неправильный выбор документа." view-as alert-box.
    return no-apply.
  end.
  assign
    doc-rec = recid( c-t-doc ).
  if c-t-doc.status_     <> 'факт':U      and
     c-t-doc.discnt-type <> 'касс':U and
     substring( c-t-doc.ps, 1, 1 ) = "@" then do:
    message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @." view-as alert-box.
  end.
end.
on leave of ed-notes in frame d-calldocs
do:
  do transaction :
    find c-t-d-b exclusive-lock where recid( c-t-d-b ) = doc-rec no-error no-wait.
    if not available c-t-d-b then do:
      message "Запись захвачена другим пользователем." skip
              "Редактирование запрещено."
      view-as alert-box.
    end.
    else do:
      assign c-t-d-b.ps = input frame d-calldocs ed-notes.
    end.
  end.
end.
on return, mouse-select-dblclick of ed-notes in frame d-calldocs do:
  apply "entry" to br-docs in frame d-calldocs.
  return no-apply.
end.
on return, mouse-select-dblclick of br-docs in frame d-calldocs do:
  apply "choose" to b-lkp in frame d-calldocs.
end.
on value-changed of br-docs do:
  if available c-t-doc then do:
    find first cli-buf no-lock where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = c-t-doc.boss no-error.
    assign boss-name = ( if available cli-buf then cli-buf.obj-name else ? ).
    find first cli-buf no-lock where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = c-t-doc.agnt no-error.
    assign agnt-name = ( if available cli-buf then cli-buf.obj-name else ? ).
    find first cli-buf no-lock where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = c-t-doc.wrkr no-error.
    assign wrkr-name = ( if available cli-buf then cli-buf.obj-name else ? ).
    find first pay-type no-lock where pay-type.obj-code = c-t-doc.pay-code no-error.
    assign ed-notes = c-t-doc.PS.
    find first cli-buf no-lock where
               cli-buf.obj-type = c-t-doc.obj-type and
               cli-buf.obj-code = c-t-doc.obj-code no-error.
    assign obj-name = ( if available cli-buf then cli-buf.obj-name else ? ).
    if doc-rec <> recid( c-t-doc ) then do:
      assign sch-num = 0.
      hide sch-num in frame d-calldocs.
    end.
    run proc-view-changes in this-procedure no-error.
  end.
end.
on choose of b-lines in frame d-calldocs do:
if not available c-t-doc then return .
  define variable v-list as character no-undo.
  run str/docclins.w (
      input        parparentproc,
      input        '':U,
      input        'doc':U,
      input        ?,
      input        ?,
      input        c-t-doc.doc-code,
      input        ?,
      input        ?,
      input        ?,
      input-output v-list
      ).
end.
ON CTRL-J, RETURN OF sch-date IN FRAME d-calldocs
DO:
  run proc-find-date in this-procedure(lastkey <> keycode("return"), input frame d-calldocs sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J, return OF sch-fact IN FRAME d-calldocs
DO:
  run proc-find-date in this-procedure(lastkey <> keycode("return"), input frame d-calldocs sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J, return OF sch-code IN FRAME d-calldocs
DO:
  run proc-find-code in this-procedure(lastkey <> keycode("return"), input frame d-calldocs sch-code) no-error.
  if error-status:error then return no-apply.
END.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-calldocs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-calldocs. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-calldocs:PARENT eq ?
THEN FRAME d-calldocs:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-calldocs APPLY "END-ERROR":U TO SELF.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-calldocs
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
on choose of b-help in frame d-calldocs
do:
  apply "help":u to frame d-calldocs .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-calldocs:width - 0.3
                fh            = frame d-calldocs:first-child
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-calldocs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-calldocs :height-chars)
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
    if frame d-calldocs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-calldocs :height-chars)
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
            frame d-calldocs :height = v-frame-height
          .
          if frame d-calldocs :scrollable = true
          then do:
            assign
              frame d-calldocs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-calldocs :scrollable = true
          then do:
            assign
              frame d-calldocs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-calldocs :height = v-frame-height
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
      v-frame-height = frame d-calldocs :height
      v-frame-virtual-height = frame d-calldocs :virtual-height
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
      v-field-group-handle = frame d-calldocs :first-child
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
    do with frame d-calldocs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-calldocs :scrollable = true
      then do:
        assign
          frame d-calldocs :virtual-height = frame d-calldocs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-calldocs :height = frame d-calldocs :height + p-change-value
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
        frame d-calldocs :height = frame d-calldocs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-calldocs :scrollable = true
      then do:
        assign
          frame d-calldocs :virtual-height = frame d-calldocs :virtual-height + p-change-value
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
          ,input  string(frame d-calldocs :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-calldocs :height)
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
    if frame d-calldocs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-calldocs :width
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
    if frame d-calldocs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-calldocs :width
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
            frame d-calldocs :width = v-frame-width
          .
          if frame d-calldocs :scrollable = true
          then do:
            assign
              frame d-calldocs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-calldocs :scrollable = true
          then do:
            assign
              frame d-calldocs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-calldocs :width = v-frame-width
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
      v-frame-width = frame d-calldocs :width
      v-frame-virtual-width = frame d-calldocs :virtual-width
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
      v-field-group-handle = frame d-calldocs :first-child
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
    do with frame d-calldocs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-calldocs :scrollable = true
      then do:
        assign
          frame d-calldocs :virtual-width = frame d-calldocs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-calldocs :width = v-frame-width + p-change-value
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
        frame d-calldocs :width = frame d-calldocs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-calldocs :scrollable = true
      then do:
        assign
          frame d-calldocs :virtual-width = frame d-calldocs :virtual-width + p-change-value
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
          ,input  string(frame d-calldocs :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-calldocs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-calldocs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-calldocs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-calldocs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-calldocs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-calldocs :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-calldocs
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
      v-row-delta = v-new-row - frame d-calldocs :height
      v-col-delta = v-new-col - frame d-calldocs :width
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
            - frame d-calldocs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-calldocs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-calldocs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-calldocs :height-chars
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
      v-diasize-current-frame-width  = frame d-calldocs :width
      v-diasize-current-frame-height = frame d-calldocs :height
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
    do with frame d-calldocs
    :
      assign
        v-diasize-orig-frame-height = frame d-calldocs :height
        v-diasize-orig-frame-width  = frame d-calldocs :width
        v-diasize-browse-handle     = browse br-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-calldocs :first-child
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-calldocs:
    if p-filter-name > "" then do:
      assign
        frame d-calldocs:title
          = frame d-calldocs:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure align-buttons :
define input parameter p-frh as handle no-undo .
define input parameter p-button-order as character no-undo .
define input parameter p-row as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable bn as character no-undo .
define variable v-col as integer no-undo init 1.
define variable ii as integer no-undo .
  do
  on error undo, return error
  :
  _ii:
    do ii = 1 to num-entries(p-button-order):
      assign
      bn = entry(ii, p-button-order).
      assign
      fh = p-frh:first-child
      hh = fh:first-child
      .
      do while valid-handle(hh):
        if hh:type <> 'button' then do:
          hh = hh:next-sibling.
          next.
        end.
        if hh:row <> p-row then do:
          hh = hh:next-sibling.
          next.
        end.
        if index(p-button-order, hh:name) = 0 then do:
          hh:hidden = yes.
        end.
        else do:
          if bn = hh:name then do:
            assign
            hh:col = v-col
            v-col = v-col + hh:width-chars
            .
          end.
        end.
        hh = hh:next-sibling.
      end.
    end.
  end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first sch-pay  no-lock where recid( sch-pay  ) = doc-rec no-error.
  find first sch-curr no-lock where recid( sch-curr ) = doc-rec no-error.
  find first sch-cli  no-lock where recid( sch-cli  ) = doc-rec no-error.
  if parlist-mode = 'Контрагент':U                     and
     available sch-cli                             and
     (sch-cli.obj-type = 'скл':U or sch-cli.obj-type = 'маг':U) then do:
    if sch-cli.obj-type = 'скл':U then do:
      find first store no-lock where store.obj-code = sch-cli.obj-code.
      if store.host-code <> v-host-code then do:
        message "Список документов, в которых данный склад является контрагентом,"
                "смотрите из той фирмы, к которой он относится."
        view-as alert-box.
        return.
      end.
    end.
    else do:
      find first shop no-lock where shop.obj-code = sch-cli.obj-code.
      if shop.host-code <> v-host-code then do:
        message "Список документов, в которых данный магазин является контрагентом,"
                "смотрите из той фирмы, к которой он относится."
        view-as alert-box.
        return.
      end.
    end.
  end.
  enable
    b-quit b-lkp b-sch b-help  br-docs sch-code sch-date sch-fact ed-notes
    b-sel when lookup("b-sel":U, bttns) > 0
    b-mark when lookup("b-mark":U, bttns) > 0
    b-lines
  with frame d-calldocs.
  if parlist-mode = 'doc':u then do:
     enable BR-changes with frame d-calldocs .
     hide sch-code
          sch-date
          sch-fact
          sch-num
          pay-type.obj-name
          obj-name
          boss-name
          agnt-name
          wrkr-name
          c-t-doc.creid
          ed-notes
          in frame d-calldocs .
  end.
  else do:
     hide BR-changes in frame d-calldocs .
  end.
  if is-finvalue = "yes" then do:
     run align-buttons in this-procedure (input (frame d-calldocs:handle), input v-button-order, input 1).
  end.
  if parlist-mode = 'doc':u or parlist-mode = 'объект':U then do:
     c-t-doc.corr-date:label = "Изменен" .
  end.
  else do:
     c-t-doc.corr-date:label = "Удален" .
  end.
  if parlist-mode = 'doc':u then do:
      if not can-find ( first ub.c-doc-line no-lock where ub.c-doc-line.doc-code = parext-doc-type ) then
        disable b-lines with frame d-calldocs .
  end.
  view frame d-calldocs .
  run OpenBr in this-procedure ( input yes, input no, input no ).
  if p-obj-type <> "" and
     p-obj-code <> 0  then do:
    find first bf_clients no-lock where
               bf_clients.obj-type = p-obj-type and
               bf_clients.obj-code = p-obj-code.
    if bf_clients.obj-type = 'маг':U then do:
      find first bf_shop no-lock where bf_shop.obj-code = bf_clients.obj-code.
      assign
        v_shift = string( bf_shop.shift-on ).
    end.
    else do:
      find first bf_store no-lock where bf_store.obj-code = bf_clients.obj-code.
      assign
        v_shift = string( bf_store.shift-on ).
    end.
  end.
  else do:
    assign
      v_shift = "no":U.
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 42 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  v_shift <> 'yes'  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('5,6,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '5,6,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36'))] , 6).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 6, 42).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (42, 6).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME d-calldocs then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 6 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 6).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 6 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  wait-for go of frame d-calldocs focus br-docs.
END.
RUN disable_UI IN THIS-PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-calldocs NO-PAUSE.
END PROCEDURE.
procedure OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
  assign c-t-doc.ship-num :read-only in browse br-docs = yes.
  if p-open-query = yes then do:
    frame d-calldocs :title = "ВСЕ  ДОКУМЕНТЫ".
    assign sch-num = 0.
    hide sch-num in frame d-calldocs.
  end.
  else do:
    assign doc-rec = ?.
  end.
  if           paris-hold = no  then do:
    if lookup( parlist-mode, 'уд_работа,уд_фирма,уд_объект,УД_ТИП':U ) > 0 then do:
      run OpenBr-3 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition  ).
    end.
    else do:
      run OpenBr-4 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.
  else if paris-hold = yes then do:
    if lookup( parlist-mode, 'уд_работа,уд_фирма,уд_объект,УД_ТИП':U ) > 0 then do:
      run OpenBr-5 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
    else do:
      run OpenBr-6 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.
  else do:
    if lookup( parlist-mode, 'уд_работа,уд_фирма,уд_объект,УД_ТИП':U ) > 0 then do:
      run OpenBr-1 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
    else do:
      run OpenBr-2 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.
  if p-open-query <> yes   and
     available c-t-d-b then do:
    assign doc-rec = recid( c-t-d-b ).
  end.
  if doc-rec <> ? then do:
    if p-open-query <> yes then do:
      assign  sch-num = sch-num + 1.
      display sch-num with frame d-calldocs.
    end.
    reposition br-docs to recid doc-rec no-error.
  end.
  else do:
    if p-open-query <> yes then do:
      message "Документ не найден." view-as alert-box.
      assign sch-num = 0.
    end.
  end.
if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.
  apply "entry"         to br-docs in frame d-calldocs.
  apply "value-changed" to br-docs in frame d-calldocs.
end procedure.
procedure OpenBr-1 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'уд_работа':U then do:
    frame d-calldocs :title = title0.
    assign filter-point = parlist-mode.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-25  as logical   no-undo .
define variable  l-filter-open-25    as logical   .
define variable  flt-rec-25       as recid     no-undo .
define variable  filter-name-25      as character no-undo .
define variable  where-phrase-25     as character no-undo .
define variable  sort-phrase-25      as character no-undo .
define variable  where-phrase-rus-25 as character no-undo .
define variable  sort-phrase-rus-25  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-25
  ,output filter-name-25
  ,output where-phrase-25
  ,output sort-phrase-25
  ,output where-phrase-rus-25
  ,output sort-phrase-rus-25
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-25
      ) no-error .
  assign
    l-filter-open-25 = false
  .
  if flt-rec-25 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "FOR EACH c-t-doc"
      parameter-4-25 =
        (
          if (" c-t-doc.is-del = yes " + " " + where-phrase-25) <> ""
          then ' c-t-doc.is-del = yes ' + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + "")
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          (" c-t-doc.is-del = yes " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          )
      .
      assign
        l-filter-open-25 = true
      .
    end.
    if l-filter-open-25 = false then do:
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
  if l-filter-open-25 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.is-del = yes
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u + ' c-t-doc.is-del = yes ' + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "   "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "FOR EACH c-t-doc"
      parameter-4-25 =
        (
          if (" c-t-doc.is-del = yes " + " " + where-phrase-25) <> ""
          then ' c-t-doc.is-del = yes ' + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
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
  when 'уд_фирма':U then do:
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'уд_работа':U
            objects = 1.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-27
      ) no-error .
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "FOR EACH c-t-doc"
      parameter-4-27 =
        (
          if (" c-t-doc.host-code = v-host-code  and c-t-doc.is-del    = yes " + " " + where-phrase-27) <> ""
          then  substitute ( ' c-t-doc.host-code = &1  and c-t-doc.is-del    = yes ', v-host-code ) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "")
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" c-t-doc.host-code = v-host-code  and c-t-doc.is-del    = yes " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
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
  if l-filter-open-27 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code  and c-t-doc.is-del    = yes
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute ( ' c-t-doc.host-code = &1  and c-t-doc.is-del    = yes ', v-host-code ) + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "FOR EACH c-t-doc"
      parameter-4-27 =
        (
          if (" c-t-doc.host-code = v-host-code  and c-t-doc.is-del    = yes " + " " + where-phrase-27) <> ""
          then  substitute ( ' c-t-doc.host-code = &1  and c-t-doc.is-del    = yes ', v-host-code ) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
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
  when 'уд_объект':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-29
      ) no-error .
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "FOR EACH c-t-doc"
      parameter-4-29 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes " + " " + where-phrase-29) <> ""
          then  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code  ) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "")
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
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
  if l-filter-open-29 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u +  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code  ) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "FOR EACH c-t-doc"
      parameter-4-29 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes " + " " + where-phrase-29) <> ""
          then  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code  ) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
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
  when 'УД_ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'уд_все':U + partype
            objects = 2.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-31  as logical   no-undo .
define variable  l-filter-open-31    as logical   .
define variable  flt-rec-31       as recid     no-undo .
define variable  filter-name-31      as character no-undo .
define variable  where-phrase-31     as character no-undo .
define variable  sort-phrase-31      as character no-undo .
define variable  where-phrase-rus-31 as character no-undo .
define variable  sort-phrase-rus-31  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-31
  ,output filter-name-31
  ,output where-phrase-31
  ,output sort-phrase-31
  ,output where-phrase-rus-31
  ,output sort-phrase-rus-31
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-31
      ) no-error .
  assign
    l-filter-open-31 = false
  .
  if flt-rec-31 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-31 as character no-undo .
    define variable  parameter-3-31 as character no-undo .
    define variable  parameter-4-31 as character no-undo .
    define variable  parameter-5-31 as character no-undo .
    define variable  parameter-6-31 as character no-undo .
    define variable  parameter-7-31 as character no-undo .
      assign
      parameter-3-31 =
                              "FOR EACH c-t-doc"
      parameter-4-31 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                        and c-t-doc.obj-code     = p-obj-code                        and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type                   and c-t-doc.is-del       = yes " + " " + where-phrase-31) <> ""
          then  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "")
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" c-t-doc.obj-type     = p-obj-type                        and c-t-doc.obj-code     = p-obj-code                        and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type                   and c-t-doc.is-del       = yes " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          )
      .
      assign
        l-filter-open-31 = true
      .
    end.
    if l-filter-open-31 = false then do:
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
  if l-filter-open-31 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                        and c-t-doc.obj-code     = p-obj-code                        and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type                   and c-t-doc.is-del       = yes
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-4-31 =
        "where ":u +  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " ":u + where-phrase-31 + " ":u + p-find-condition + " " + ""
      parameter-5-31 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-3-31 =  "FOR EACH c-t-doc"
      parameter-4-31 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                        and c-t-doc.obj-code     = p-obj-code                        and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type                   and c-t-doc.is-del       = yes " + " " + where-phrase-31) <> ""
          then  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         and c-t-doc.is-del = yes ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
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
end procedure.
procedure OpenBr-2 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'работа':U then do:
    assign filter-point = 'работа':U.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH c-t-doc"
      parameter-4-33 =
        (
          if (" yes " + " " + where-phrase-33) <> ""
          then  'yes'  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "    " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "    " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" yes " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  yes
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  'yes'  + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "    "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH c-t-doc"
      parameter-4-33 =
        (
          if (" yes " + " " + where-phrase-33) <> ""
          then  'yes'  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "    " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "    " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
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
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'работа':U
            objects = 1.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH c-t-doc"
      parameter-4-35 =
        (
          if (" c-t-doc.host-code = v-host-code " + " " + where-phrase-35) <> ""
          then  substitute ( ' c-t-doc.host-code = &1 ', v-host-code ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" c-t-doc.host-code = v-host-code " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute ( ' c-t-doc.host-code = &1 ', v-host-code ) + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH c-t-doc"
      parameter-4-35 =
        (
          if (" c-t-doc.host-code = v-host-code " + " " + where-phrase-35) <> ""
          then  substitute ( ' c-t-doc.host-code = &1 ', v-host-code ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
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
    frame d-calldocs :title = "История по документам " + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = 'объект':U
            objects = 2.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH c-t-doc"
      parameter-4-37 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code " + " " + where-phrase-37) <> ""
          then  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 ', chr(34) , p-obj-type , p-obj-code  ) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 ', chr(34) , p-obj-type , p-obj-code  ) + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH c-t-doc"
      parameter-4-37 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code " + " " + where-phrase-37) <> ""
          then  substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 ', chr(34) , p-obj-type , p-obj-code  ) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
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
  when 'ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'все':U + partype
            objects = 2.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH c-t-doc"
      parameter-4-39 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type " + " " + where-phrase-39) <> ""
          then  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH c-t-doc"
      parameter-4-39 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type " + " " + where-phrase-39) <> ""
          then  substitute ( '
            c-t-doc.obj-type = &1&2&1             and c-t-doc.obj-code = &3                 and c-t-doc.internal =  &4                and c-t-doc.doc-type =  &1&5&1            and c-t-doc.ext-doc-type = &1&6&1         ', chr(34) , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type )  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
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
  when 'doc':U then do:
    frame d-calldocs :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH c-t-doc"
      parameter-4-41 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-41) <> ""
          then  substitute ( ' c-t-doc.doc-code = &1&2&1 ', chr(34) , parext-doc-type ) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "")
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.doc-code = parext-doc-type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute ( ' c-t-doc.doc-code = &1&2&1 ', chr(34) , parext-doc-type ) + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "   "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH c-t-doc"
      parameter-4-41 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-41) <> ""
          then  substitute ( ' c-t-doc.doc-code = &1&2&1 ', chr(34) , parext-doc-type ) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "   " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
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
end procedure.
procedure OpenBr-3 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'уд_работа':U then do:
     assign frame d-calldocs:title = title0 .
    assign filter-point = parlist-mode.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-43
      ) no-error .
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH c-t-doc"
      parameter-4-43 =
        (
          if ("
        c-t-doc.is-del = yes and       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      " + " " + where-phrase-43) <> ""
          then  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "")
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          ("
        c-t-doc.is-del = yes and       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
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
  if l-filter-open-43 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where
        c-t-doc.is-del = yes and       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-3-43 =  "FOR EACH c-t-doc"
      parameter-4-43 =
        (
          if ("
        c-t-doc.is-del = yes and       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      " + " " + where-phrase-43) <> ""
          then  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
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
  when 'уд_фирма':U then do:
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'уд_работа':U
            objects = 1.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-45
      ) no-error .
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH c-t-doc"
      parameter-4-45 =
        (
          if (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-45) <> ""
          then  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "")
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
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
  if l-filter-open-45 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-3-45 =  "FOR EACH c-t-doc"
      parameter-4-45 =
        (
          if (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-45) <> ""
          then  substitute ( '
      c-t-doc.is-del = yes and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
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
  when 'уд_объект':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-47
      ) no-error .
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH c-t-doc"
      parameter-4-47 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-47) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code ) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "")
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
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
  if l-filter-open-47 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code ) + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-3-47 =  "FOR EACH c-t-doc"
      parameter-4-47 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-47) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code ) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
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
  when 'УД_ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'уд_все':U + partype
            objects = 2.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-49
  ,output filter-name-49
  ,output where-phrase-49
  ,output sort-phrase-49
  ,output where-phrase-rus-49
  ,output sort-phrase-rus-49
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-49
      ) no-error .
  assign
    l-filter-open-49 = false
  .
  if flt-rec-49 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-49 as character no-undo .
    define variable  parameter-3-49 as character no-undo .
    define variable  parameter-4-49 as character no-undo .
    define variable  parameter-5-49 as character no-undo .
    define variable  parameter-6-49 as character no-undo .
    define variable  parameter-7-49 as character no-undo .
      assign
      parameter-3-49 =
                              "FOR EACH c-t-doc"
      parameter-4-49 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-49) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "")
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          )
      .
      assign
        l-filter-open-49 = true
      .
    end.
    if l-filter-open-49 = false then do:
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
  if l-filter-open-49 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u +  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-3-49 =  "FOR EACH c-t-doc"
      parameter-4-49 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                       ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-49) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and       c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
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
assign frame d-calldocs :title = frame d-calldocs :title + " (внешние контрагенты)".
end procedure.
procedure OpenBr-4 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'работа':U then do:
    assign frame d-calldocs:title = title0.
    assign filter-point = 'работа':U.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-51  as logical   no-undo .
define variable  l-filter-open-51    as logical   .
define variable  flt-rec-51       as recid     no-undo .
define variable  filter-name-51      as character no-undo .
define variable  where-phrase-51     as character no-undo .
define variable  sort-phrase-51      as character no-undo .
define variable  where-phrase-rus-51 as character no-undo .
define variable  sort-phrase-rus-51  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-51
  ,output filter-name-51
  ,output where-phrase-51
  ,output sort-phrase-51
  ,output where-phrase-rus-51
  ,output sort-phrase-rus-51
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-51
      ) no-error .
  assign
    l-filter-open-51 = false
  .
  if flt-rec-51 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-51 as character no-undo .
    define variable  parameter-3-51 as character no-undo .
    define variable  parameter-4-51 as character no-undo .
    define variable  parameter-5-51 as character no-undo .
    define variable  parameter-6-51 as character no-undo .
    define variable  parameter-7-51 as character no-undo .
      assign
      parameter-3-51 =
                              "FOR EACH c-t-doc"
      parameter-4-51 =
        (
          if (" ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-51) <> ""
          then  substitute ( '      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) )  + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "")
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-51 =
          (" ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          )
      .
      assign
        l-filter-open-51 = true
      .
    end.
    if l-filter-open-51 = false then do:
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
  if l-filter-open-51 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u +  substitute ( '      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) )  + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-3-51 =  "FOR EACH c-t-doc"
      parameter-4-51 =
        (
          if (" ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-51) <> ""
          then  substitute ( '      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) )  + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
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
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'работа':U
            objects = 1.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-53  as logical   no-undo .
define variable  l-filter-open-53    as logical   .
define variable  flt-rec-53       as recid     no-undo .
define variable  filter-name-53      as character no-undo .
define variable  where-phrase-53     as character no-undo .
define variable  sort-phrase-53      as character no-undo .
define variable  where-phrase-rus-53 as character no-undo .
define variable  sort-phrase-rus-53  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-53
  ,output filter-name-53
  ,output where-phrase-53
  ,output sort-phrase-53
  ,output where-phrase-rus-53
  ,output sort-phrase-rus-53
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-53
      ) no-error .
  assign
    l-filter-open-53 = false
  .
  if flt-rec-53 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-53 as character no-undo .
    define variable  parameter-3-53 as character no-undo .
    define variable  parameter-4-53 as character no-undo .
    define variable  parameter-5-53 as character no-undo .
    define variable  parameter-6-53 as character no-undo .
    define variable  parameter-7-53 as character no-undo .
      assign
      parameter-3-53 =
                              "FOR EACH c-t-doc"
      parameter-4-53 =
        (
          if (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-53) <> ""
          then  substitute ( '        c-t-doc.host-code = &2 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ,  v-host-code )  + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "")
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-53 =
          (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          )
      .
      assign
        l-filter-open-53 = true
      .
    end.
    if l-filter-open-53 = false then do:
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
  if l-filter-open-53 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u +  substitute ( '        c-t-doc.host-code = &2 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ,  v-host-code )  + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-3-53 =  "FOR EACH c-t-doc"
      parameter-4-53 =
        (
          if (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-53) <> ""
          then  substitute ( '        c-t-doc.host-code = &2 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) ,  v-host-code )  + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
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
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = 'объект':U
            objects = 2.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-55  as logical   no-undo .
define variable  l-filter-open-55    as logical   .
define variable  flt-rec-55       as recid     no-undo .
define variable  filter-name-55      as character no-undo .
define variable  where-phrase-55     as character no-undo .
define variable  sort-phrase-55      as character no-undo .
define variable  where-phrase-rus-55 as character no-undo .
define variable  sort-phrase-rus-55  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-55
  ,output filter-name-55
  ,output where-phrase-55
  ,output sort-phrase-55
  ,output where-phrase-rus-55
  ,output sort-phrase-rus-55
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-55
      ) no-error .
  assign
    l-filter-open-55 = false
  .
  if flt-rec-55 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-55 as character no-undo .
    define variable  parameter-3-55 as character no-undo .
    define variable  parameter-4-55 as character no-undo .
    define variable  parameter-5-55 as character no-undo .
    define variable  parameter-6-55 as character no-undo .
    define variable  parameter-7-55 as character no-undo .
      assign
      parameter-3-55 =
                              "FOR EACH c-t-doc"
      parameter-4-55 =
        (
          if (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-55) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code )  + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + "")
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-55 =
          (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-55 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          )
      .
      assign
        l-filter-open-55 = true
      .
    end.
    if l-filter-open-55 = false then do:
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
  if l-filter-open-55 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-4-55 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code )  + " ":u + where-phrase-55 + " ":u + p-find-condition + " " + ""
      parameter-5-55 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-3-55 =  "FOR EACH c-t-doc"
      parameter-4-55 =
        (
          if (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-55) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code )  + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
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
  when 'ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'все':U + partype
            objects = 2.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-57  as logical   no-undo .
define variable  l-filter-open-57    as logical   .
define variable  flt-rec-57       as recid     no-undo .
define variable  filter-name-57      as character no-undo .
define variable  where-phrase-57     as character no-undo .
define variable  sort-phrase-57      as character no-undo .
define variable  where-phrase-rus-57 as character no-undo .
define variable  sort-phrase-rus-57  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-57
  ,output filter-name-57
  ,output where-phrase-57
  ,output sort-phrase-57
  ,output where-phrase-rus-57
  ,output sort-phrase-rus-57
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-57
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-57 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                   and c-t-doc.obj-code     = p-obj-code                   and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-57) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "")
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          (" c-t-doc.obj-type     = p-obj-type                   and c-t-doc.obj-code     = p-obj-code                   and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                   and c-t-doc.obj-code     = p-obj-code                   and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-3-57 =  "FOR EACH c-t-doc"
      parameter-4-57 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                   and c-t-doc.obj-code     = p-obj-code                   and c-t-doc.internal     = parinternal                        and c-t-doc.doc-type     = partype                            and c-t-doc.ext-doc-type = parext-doc-type and                     ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and                     ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) " + " " + where-phrase-57) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and     ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
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
  when 'doc':U then do:
    frame d-calldocs :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-59  as logical   no-undo .
define variable  l-filter-open-59    as logical   .
define variable  flt-rec-59       as recid     no-undo .
define variable  filter-name-59      as character no-undo .
define variable  where-phrase-59     as character no-undo .
define variable  sort-phrase-59      as character no-undo .
define variable  where-phrase-rus-59 as character no-undo .
define variable  sort-phrase-rus-59  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-59
  ,output filter-name-59
  ,output where-phrase-59
  ,output sort-phrase-59
  ,output where-phrase-rus-59
  ,output sort-phrase-rus-59
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-59
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-59 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-59) <> ""
          then  substitute ( '        c-t-doc.ext-doc-type = &1&2&1        ', chr(34)  ,  parext-doc-type )  + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "")
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.doc-code = parext-doc-type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute ( '        c-t-doc.ext-doc-type = &1&2&1        ', chr(34)  ,  parext-doc-type )  + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-3-59 =  "FOR EACH c-t-doc"
      parameter-4-59 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-59) <> ""
          then  substitute ( '        c-t-doc.ext-doc-type = &1&2&1        ', chr(34)  ,  parext-doc-type )  + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
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
if parlist-mode <> 'doc':U then do:
  assign frame d-calldocs :title = frame d-calldocs :title + " (внешние контрагенты)".
end.
end procedure.
procedure OpenBr-5 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'уд_работа':U then do:
    assign frame d-calldocs:title = title0.
    assign filter-point = parlist-mode.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-61  as logical   no-undo .
define variable  l-filter-open-61    as logical   .
define variable  flt-rec-61       as recid     no-undo .
define variable  filter-name-61      as character no-undo .
define variable  where-phrase-61     as character no-undo .
define variable  sort-phrase-61      as character no-undo .
define variable  where-phrase-rus-61 as character no-undo .
define variable  sort-phrase-rus-61  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-61
  ,output filter-name-61
  ,output where-phrase-61
  ,output sort-phrase-61
  ,output where-phrase-rus-61
  ,output sort-phrase-rus-61
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-61
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-61 =
        (
          if (" c-t-doc.is-del = yes and                   ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                     c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-61) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + "")
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-61 =
          (" c-t-doc.is-del = yes and                   ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                     c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-61 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.is-del = yes and                   ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                     c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-4-61 =
        "where ":u +  substitute ( '        c-t-doc.is-del = yes and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " ":u + where-phrase-61 + " ":u + p-find-condition + " " + ""
      parameter-5-61 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-3-61 =  "FOR EACH c-t-doc"
      parameter-4-61 =
        (
          if (" c-t-doc.is-del = yes and                   ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                     c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-61) <> ""
          then  substitute ( '        c-t-doc.is-del = yes and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
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
  when 'уд_фирма':U then do:
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'уд_работа':U
            objects = 1.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-63  as logical   no-undo .
define variable  l-filter-open-63    as logical   .
define variable  flt-rec-63       as recid     no-undo .
define variable  filter-name-63      as character no-undo .
define variable  where-phrase-63     as character no-undo .
define variable  sort-phrase-63      as character no-undo .
define variable  where-phrase-rus-63 as character no-undo .
define variable  sort-phrase-rus-63  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-63
  ,output filter-name-63
  ,output where-phrase-63
  ,output sort-phrase-63
  ,output where-phrase-rus-63
  ,output sort-phrase-rus-63
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-63
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-63 =
        (
          if (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-63) <> ""
          then  substitute ( '        c-t-doc.is-del    = yes
      c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " " + where-phrase-63
          else "true"
        )
      parameter-5-63 = (" " + "" + " " + "")
      parameter-6-63 = if sort-phrase-63 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-63
        )
      parameter-7-63 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-63 =
          (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-63 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-63 = (if p-find-next then "true":u else "false":u )
      parameter-4-63 =
        "where ":u +  substitute ( '        c-t-doc.is-del    = yes
      c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " ":u + where-phrase-63 + " ":u + p-find-condition + " " + ""
      parameter-5-63 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-63)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-63 = (if p-find-next then "true":u else "false":u )
      parameter-3-63 =  "FOR EACH c-t-doc"
      parameter-4-63 =
        (
          if (" c-t-doc.host-code = v-host-code                   and c-t-doc.is-del    = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-63) <> ""
          then  substitute ( '        c-t-doc.is-del    = yes
      c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " " + where-phrase-63
          else "true"
        )
      parameter-5-63 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-63 = if sort-phrase-63 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-63
        )
      parameter-7-63 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-63)
                          ,input no-lock
                          ,input parameter-3-63
                          ,input parameter-4-63
                          ,input parameter-5-63
                          ,input parameter-6-63
                          ,input parameter-7-63
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
  when 'уд_объект':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-65  as logical   no-undo .
define variable  l-filter-open-65    as logical   .
define variable  flt-rec-65       as recid     no-undo .
define variable  filter-name-65      as character no-undo .
define variable  where-phrase-65     as character no-undo .
define variable  sort-phrase-65      as character no-undo .
define variable  where-phrase-rus-65 as character no-undo .
define variable  sort-phrase-rus-65  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-65
  ,output filter-name-65
  ,output where-phrase-65
  ,output sort-phrase-65
  ,output where-phrase-rus-65
  ,output sort-phrase-rus-65
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-65
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-65 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-65) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.is-del   = yes and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code )  + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + "")
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-65 =
          (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-65 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-4-65 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.is-del   = yes and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code )  + " ":u + where-phrase-65 + " ":u + p-find-condition + " " + ""
      parameter-5-65 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-3-65 =  "FOR EACH c-t-doc"
      parameter-4-65 =
        (
          if (" c-t-doc.obj-type = p-obj-type                   and c-t-doc.obj-code = p-obj-code                   and c-t-doc.is-del   = yes and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-65) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.is-del   = yes and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code )  + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
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
  when 'УД_ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'уд_все':U + partype
            objects = 2.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-67  as logical   no-undo .
define variable  l-filter-open-67    as logical   .
define variable  flt-rec-67       as recid     no-undo .
define variable  filter-name-67      as character no-undo .
define variable  where-phrase-67     as character no-undo .
define variable  sort-phrase-67      as character no-undo .
define variable  where-phrase-rus-67 as character no-undo .
define variable  sort-phrase-rus-67  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-67
  ,output filter-name-67
  ,output where-phrase-67
  ,output sort-phrase-67
  ,output where-phrase-rus-67
  ,output sort-phrase-rus-67
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-67
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-67 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-67) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.is-del       = yes and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-67
          else "true"
        )
      parameter-5-67 = (" " + "" + " " + "")
      parameter-6-67 = if sort-phrase-67 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-67
        )
      parameter-7-67 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-67 =
          (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-67 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-67 = (if p-find-next then "true":u else "false":u )
      parameter-4-67 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.is-del       = yes and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " ":u + where-phrase-67 + " ":u + p-find-condition + " " + ""
      parameter-5-67 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-67)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-67 = (if p-find-next then "true":u else "false":u )
      parameter-3-67 =  "FOR EACH c-t-doc"
      parameter-4-67 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                          and c-t-doc.obj-code     = p-obj-code                          and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type                     and c-t-doc.is-del       = yes and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-67) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.is-del       = yes and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-67
          else "true"
        )
      parameter-5-67 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-67 = if sort-phrase-67 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-67
        )
      parameter-7-67 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-67)
                          ,input no-lock
                          ,input parameter-3-67
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ,input parameter-6-67
                          ,input parameter-7-67
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
  assign frame d-calldocs :title = frame d-calldocs :title + " (межфирменные перемещения)".
end procedure.
procedure OpenBr-6 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
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
case parlist-mode :
  when 'работа':U then do:
    assign frame d-calldocs:title = title0.
    assign filter-point = 'работа':U.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-69  as logical   no-undo .
define variable  l-filter-open-69    as logical   .
define variable  flt-rec-69       as recid     no-undo .
define variable  filter-name-69      as character no-undo .
define variable  where-phrase-69     as character no-undo .
define variable  sort-phrase-69      as character no-undo .
define variable  where-phrase-rus-69 as character no-undo .
define variable  sort-phrase-rus-69  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-69
  ,output filter-name-69
  ,output where-phrase-69
  ,output sort-phrase-69
  ,output where-phrase-rus-69
  ,output sort-phrase-rus-69
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-69
      ) no-error .
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
                              "FOR EACH c-t-doc"
      parameter-4-69 =
        (
          if (" ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-69) <> ""
          then  substitute ( '      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " " + where-phrase-69
          else "true"
        )
      parameter-5-69 = (" " + "" + " " + "")
      parameter-6-69 = if sort-phrase-69 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-69
        )
      parameter-7-69 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-69 =
          (" ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-69 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-69 = (if p-find-next then "true":u else "false":u )
      parameter-4-69 =
        "where ":u +  substitute ( '      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " ":u + where-phrase-69 + " ":u + p-find-condition + " " + ""
      parameter-5-69 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-69)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-69 = (if p-find-next then "true":u else "false":u )
      parameter-3-69 =  "FOR EACH c-t-doc"
      parameter-4-69 =
        (
          if (" ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-69) <> ""
          then  substitute ( '      (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34)  )  + " " + where-phrase-69
          else "true"
        )
      parameter-5-69 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-69 = if sort-phrase-69 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-69
        )
      parameter-7-69 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-69)
                          ,input no-lock
                          ,input parameter-3-69
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ,input parameter-6-69
                          ,input parameter-7-69
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
    frame d-calldocs :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = 'работа':U
            objects = 1.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-71  as logical   no-undo .
define variable  l-filter-open-71    as logical   .
define variable  flt-rec-71       as recid     no-undo .
define variable  filter-name-71      as character no-undo .
define variable  where-phrase-71     as character no-undo .
define variable  sort-phrase-71      as character no-undo .
define variable  where-phrase-rus-71 as character no-undo .
define variable  sort-phrase-rus-71  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-71
  ,output filter-name-71
  ,output where-phrase-71
  ,output sort-phrase-71
  ,output where-phrase-rus-71
  ,output sort-phrase-rus-71
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-71
      ) no-error .
  assign
    l-filter-open-71 = false
  .
  if flt-rec-71 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-71 as character no-undo .
    define variable  parameter-3-71 as character no-undo .
    define variable  parameter-4-71 as character no-undo .
    define variable  parameter-5-71 as character no-undo .
    define variable  parameter-6-71 as character no-undo .
    define variable  parameter-7-71 as character no-undo .
      assign
      parameter-3-71 =
                              "FOR EACH c-t-doc"
      parameter-4-71 =
        (
          if (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-71) <> ""
          then  substitute ( '        c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " " + where-phrase-71
          else "true"
        )
      parameter-5-71 = (" " + "" + " " + "")
      parameter-6-71 = if sort-phrase-71 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-71
        )
      parameter-7-71 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-71 =
          (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-71 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-71
                          ,input parameter-4-71
                          ,input parameter-5-71
                          ,input parameter-6-71
                          ,input parameter-7-71
                          )
      .
      assign
        l-filter-open-71 = true
      .
    end.
    if l-filter-open-71 = false then do:
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
  if l-filter-open-71 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-71 = (if p-find-next then "true":u else "false":u )
      parameter-4-71 =
        "where ":u +  substitute ( '        c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " ":u + where-phrase-71 + " ":u + p-find-condition + " " + ""
      parameter-5-71 = " use-index host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-71)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-71
                          ,input parameter-5-71
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-71 = (if p-find-next then "true":u else "false":u )
      parameter-3-71 =  "FOR EACH c-t-doc"
      parameter-4-71 =
        (
          if (" c-t-doc.host-code = v-host-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-71) <> ""
          then  substitute ( '        c-t-doc.host-code = &2 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , v-host-code )  + " " + where-phrase-71
          else "true"
        )
      parameter-5-71 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-71 = if sort-phrase-71 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-71
        )
      parameter-7-71 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-71)
                          ,input no-lock
                          ,input parameter-3-71
                          ,input parameter-4-71
                          ,input parameter-5-71
                          ,input parameter-6-71
                          ,input parameter-7-71
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
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = 'объект':U
            objects = 2.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-73  as logical   no-undo .
define variable  l-filter-open-73    as logical   .
define variable  flt-rec-73       as recid     no-undo .
define variable  filter-name-73      as character no-undo .
define variable  where-phrase-73     as character no-undo .
define variable  sort-phrase-73      as character no-undo .
define variable  where-phrase-rus-73 as character no-undo .
define variable  sort-phrase-rus-73  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-73
  ,output filter-name-73
  ,output where-phrase-73
  ,output sort-phrase-73
  ,output where-phrase-rus-73
  ,output sort-phrase-rus-73
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-73
      ) no-error .
  assign
    l-filter-open-73 = false
  .
  if flt-rec-73 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-73 as character no-undo .
    define variable  parameter-3-73 as character no-undo .
    define variable  parameter-4-73 as character no-undo .
    define variable  parameter-5-73 as character no-undo .
    define variable  parameter-6-73 as character no-undo .
    define variable  parameter-7-73 as character no-undo .
      assign
      parameter-3-73 =
                              "FOR EACH c-t-doc"
      parameter-4-73 =
        (
          if (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-73) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or      ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-73
          else "true"
        )
      parameter-5-73 = (" " + "" + " " + "")
      parameter-6-73 = if sort-phrase-73 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-73
        )
      parameter-7-73 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-73 =
          (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-73 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-73
                          ,input parameter-4-73
                          ,input parameter-5-73
                          ,input parameter-6-73
                          ,input parameter-7-73
                          )
      .
      assign
        l-filter-open-73 = true
      .
    end.
    if l-filter-open-73 = false then do:
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
  if l-filter-open-73 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-73 = (if p-find-next then "true":u else "false":u )
      parameter-4-73 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or      ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " ":u + where-phrase-73 + " ":u + p-find-condition + " " + ""
      parameter-5-73 = " use-index obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-73)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-73
                          ,input parameter-5-73
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-73 = (if p-find-next then "true":u else "false":u )
      parameter-3-73 =  "FOR EACH c-t-doc"
      parameter-4-73 =
        (
          if (" c-t-doc.obj-type = p-obj-type and                       c-t-doc.obj-code = p-obj-code and                     ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                       c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-73) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and     (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or      ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-73
          else "true"
        )
      parameter-5-73 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-73 = if sort-phrase-73 = ''
                           then
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-73
        )
      parameter-7-73 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-73)
                          ,input no-lock
                          ,input parameter-3-73
                          ,input parameter-4-73
                          ,input parameter-5-73
                          ,input parameter-6-73
                          ,input parameter-7-73
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
  when 'ТИП':U then do:
    frame d-calldocs :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ).
    assign filter-point = 'все':U + partype
            objects = 2.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-75  as logical   no-undo .
define variable  l-filter-open-75    as logical   .
define variable  flt-rec-75       as recid     no-undo .
define variable  filter-name-75      as character no-undo .
define variable  where-phrase-75     as character no-undo .
define variable  sort-phrase-75      as character no-undo .
define variable  where-phrase-rus-75 as character no-undo .
define variable  sort-phrase-rus-75  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-75
  ,output filter-name-75
  ,output where-phrase-75
  ,output sort-phrase-75
  ,output where-phrase-rus-75
  ,output sort-phrase-rus-75
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-75
      ) no-error .
  assign
    l-filter-open-75 = false
  .
  if flt-rec-75 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-75 as character no-undo .
    define variable  parameter-3-75 as character no-undo .
    define variable  parameter-4-75 as character no-undo .
    define variable  parameter-5-75 as character no-undo .
    define variable  parameter-6-75 as character no-undo .
    define variable  parameter-7-75 as character no-undo .
      assign
      parameter-3-75 =
                              "FOR EACH c-t-doc"
      parameter-4-75 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                     and c-t-doc.obj-code     = p-obj-code                     and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-75) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-75
          else "true"
        )
      parameter-5-75 = (" " + "" + " " + "")
      parameter-6-75 = if sort-phrase-75 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-75
        )
      parameter-7-75 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-75 =
          (" c-t-doc.obj-type     = p-obj-type                     and c-t-doc.obj-code     = p-obj-code                     and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-75 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-75
                          ,input parameter-4-75
                          ,input parameter-5-75
                          ,input parameter-6-75
                          ,input parameter-7-75
                          )
      .
      assign
        l-filter-open-75 = true
      .
    end.
    if l-filter-open-75 = false then do:
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
  if l-filter-open-75 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.obj-type     = p-obj-type                     and c-t-doc.obj-code     = p-obj-code                     and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' )
       use-index type-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-75 = (if p-find-next then "true":u else "false":u )
      parameter-4-75 =
        "where ":u +  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " ":u + where-phrase-75 + " ":u + p-find-condition + " " + ""
      parameter-5-75 = " use-index type-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-75)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-75
                          ,input parameter-5-75
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-75 = (if p-find-next then "true":u else "false":u )
      parameter-3-75 =  "FOR EACH c-t-doc"
      parameter-4-75 =
        (
          if (" c-t-doc.obj-type     = p-obj-type                     and c-t-doc.obj-code     = p-obj-code                     and c-t-doc.internal     = parinternal                          and c-t-doc.doc-type     = partype                              and c-t-doc.ext-doc-type = parext-doc-type and                       ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or                         c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) " + " " + where-phrase-75) <> ""
          then  substitute ( '        c-t-doc.obj-type = &1&2&1 and       c-t-doc.obj-code = &3 and       c-t-doc.internal     = &4 and        c-t-doc.doc-type     = &1&5&1 and        c-t-doc.ext-doc-type = &1&6&1 and      ( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 )
      ', chr(34) , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type )  + " " + where-phrase-75
          else "true"
        )
      parameter-5-75 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-75 = if sort-phrase-75 = ''
                           then
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index type-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-75
        )
      parameter-7-75 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-75)
                          ,input no-lock
                          ,input parameter-3-75
                          ,input parameter-4-75
                          ,input parameter-5-75
                          ,input parameter-6-75
                          ,input parameter-7-75
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
  when 'doc':U then do:
    frame d-calldocs :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-77  as logical   no-undo .
define variable  l-filter-open-77    as logical   .
define variable  flt-rec-77       as recid     no-undo .
define variable  filter-name-77      as character no-undo .
define variable  where-phrase-77     as character no-undo .
define variable  sort-phrase-77      as character no-undo .
define variable  where-phrase-rus-77 as character no-undo .
define variable  sort-phrase-rus-77  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-77
  ,output filter-name-77
  ,output where-phrase-77
  ,output sort-phrase-77
  ,output where-phrase-rus-77
  ,output sort-phrase-rus-77
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-77
      ) no-error .
  assign
    l-filter-open-77 = false
  .
  if flt-rec-77 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-77 as character no-undo .
    define variable  parameter-3-77 as character no-undo .
    define variable  parameter-4-77 as character no-undo .
    define variable  parameter-5-77 as character no-undo .
    define variable  parameter-6-77 as character no-undo .
    define variable  parameter-7-77 as character no-undo .
      assign
      parameter-3-77 =
                              "FOR EACH c-t-doc"
      parameter-4-77 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-77) <> ""
          then  substitute ( '        c-t-doc.doc-code = &1&2&1       ', chr(34) ,  parext-doc-type )  + " " + where-phrase-77
          else "true"
        )
      parameter-5-77 = (" " + "" + " " + "")
      parameter-6-77 = if sort-phrase-77 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-77
        )
      parameter-7-77 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-77 =
          (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-77 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-77
                          ,input parameter-4-77
                          ,input parameter-5-77
                          ,input parameter-6-77
                          ,input parameter-7-77
                          )
      .
      assign
        l-filter-open-77 = true
      .
    end.
    if l-filter-open-77 = false then do:
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
  if l-filter-open-77 = false then do:
    OPEN QUERY br-docs FOR EACH c-t-doc
      where  c-t-doc.doc-code = parext-doc-type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( c-t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer c-t-doc:handle) then do:
      assign
      parameter-2-77 = (if p-find-next then "true":u else "false":u )
      parameter-4-77 =
        "where ":u +  substitute ( '        c-t-doc.doc-code = &1&2&1       ', chr(34) ,  parext-doc-type )  + " ":u + where-phrase-77 + " ":u + p-find-condition + " " + ""
      parameter-5-77 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(c-t-doc)
                          ,input logical(parameter-2-77)
                          ,input no-lock
                          ,input (buffer c-t-doc:handle)
                          ,input parameter-4-77
                          ,input parameter-5-77
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-77 = (if p-find-next then "true":u else "false":u )
      parameter-3-77 =  "FOR EACH c-t-doc"
      parameter-4-77 =
        (
          if (" c-t-doc.doc-code = parext-doc-type " + " " + where-phrase-77) <> ""
          then  substitute ( '        c-t-doc.doc-code = &1&2&1       ', chr(34) ,  parext-doc-type )  + " " + where-phrase-77
          else "true"
        )
      parameter-5-77 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-77 = if sort-phrase-77 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-77
        )
      parameter-7-77 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-77)
                          ,input no-lock
                          ,input parameter-3-77
                          ,input parameter-4-77
                          ,input parameter-5-77
                          ,input parameter-6-77
                          ,input parameter-7-77
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
if parlist-mode <> 'doc':U then do:
  assign frame d-calldocs :title = frame d-calldocs :title + " (межфирменные перемещения)".
end.
end procedure.
procedure init-flt :
  assign
    tbl = 'c-trn-doc'
    join-tbl = 'c-t-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
    run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure ('flag_', 'OK', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-code', 'Номер', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-name', 'Номер смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-type*cli-code', 'Контрагент', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    if lookup( parlist-mode, 'уд_работа,уд_фирма,работа,фирма':U ) > 0 then do:
    run fltfield-add in this-procedure('obj-type', 'Тип объекта', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
    run fltfield-add in this-procedure('boss', 'Менеджер', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-rubl', 'Сумма (руб)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-rubl', 'Скидка (руб)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-type', 'Тип скидки', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('internal', 'Внутренняя', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-name', 'Название контр-а', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('creid', 'Создал', 'usr',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('agnt', 'Исполнитель', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('out-code', 'На док-т', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('base-rate', 'Курс', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('inv-num', 'Инвойс', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ord-num', 'Заказ', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('office', 'Услуги', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('print-rubl', 'Рублевый', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ship-num', 'Отгрузка', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ship-date', 'Дата отгрузки', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ov', 'Акт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-ov', 'Сумма акта', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('exch-code', 'Валюта', 'cur',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('reason-code', 'Код основания (причины)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('PS', 'Примечание', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end procedure.
procedure make-gen-button :
  do
  on error undo, return error return-value
  :
    if parlist-mode = 'doc':U then return .
    define variable  but-gen  as widget-handle.
    create button but-gen
    assign
      row          = 1
      column       = 63
      HEIGHT-CHARS = 1
      WIDTH-CHARS  = 10
      name         = "but-gen"
      label        = "Г&енерация"
      tooltip      = "Генерация Фин.обязательств по удаленным накладным"
      frame        = frame d-calldocs:handle
      sensitive    = true
      visible      = true
      POPUP-MENU   = MENU POPUP-MENU-b-gen :HANDLE
      MENU-MOUSE   = 1
        .
  end.
end procedure.
procedure make-fo-button :
  do
  on error undo, return error return-value
  :
  if parlist-mode = 'doc':U then return .
  define variable  but-fo  as widget-handle.
  create button but-fo
  assign
      row = 1
      column = 73
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 10
      name = "but-fo"
      label = "Фин.Об"
      tooltip = "Список Фин.обязательств по накладной"
      frame = frame d-calldocs:handle
      sensitive = true
      visible = true
        triggers :
          on choose persistent run list-fo in this-procedure.
        end triggers.
 end.
end procedure.
procedure list-fo :
  do
  on error undo, return error return-value
  :
    find current c-t-doc no-lock no-error .
    if available c-t-doc then do:
      run str/fi-trns.w (
          input parparentproc,
          input v-host-code,
          input ?              ,
          input c-t-doc.doc-code ,
          input "trn-doc":U
          ) .
    end.
  end.
end procedure.
procedure local-mark :
  if not available c-t-doc then do:
    message "Неправильный выбор строки." view-as alert-box.
    return no-apply.
  end.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid79 as character no-undo .
define variable v-num-entry79 as integer   no-undo .
assign
  v-str-recid79 = trim( string( recid( c-t-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry79 = lookup( v-str-recid79 , mark-list )
.
if v-num-entry79 > 0 then do:
  assign
    entry( v-num-entry79, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid79
  .
end.
  br-docs :refresh() in frame d-calldocs.
  apply "entry" to br-docs in frame d-calldocs.
end procedure.
procedure proc-m_gen-1 :
  do
  on error undo, return error return-value
  :
    if num-entries(mark-list) = 0 then do:
      message "Не выделено ни одной накладной для генерации финансовых обязательств !" view-as alert-box .
      return error .
    end.
    run str/gen-fl.w (
        input parparentproc,
        input v-host-code,
        input mark-list,
        input "del"
    )   .
    assign
      mark-list = ""
      .
    run OpenBr in this-procedure ( input yes, input no, input no ).
  end.
end procedure.
procedure proc-m_gen-2 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.
  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-incfo = yes then do:
        message "По документу " bf_c-trn-doc.doc-code " уже генерилось финансовое обязательство от "
                bf_c-trn-doc.incfo-date " числа."
        view-as alert-box error.
      end.
      else do:
        assign
          bf_c-trn-doc.need-incfo = 0.
        if bf_c-trn-doc.need-incfo = 0 and
           bf_c-trn-doc.need-expfo = 0 then do:
          assign
            bf_c-trn-doc.need-incorexpfo = 0.
        end.
        reposition br-docs to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc) ) @ varpost with browse br-docs.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end.
end procedure.
procedure proc-m_gen-3 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.
  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-expfo = yes then do:
        message "По документу " bf_c-trn-doc.doc-code " уже генерилось финансовое обязательство от "
                bf_c-trn-doc.expfo-date " числа."
        view-as alert-box error.
      end.
      else do:
        assign
          bf_c-trn-doc.need-expfo = 0.
        if bf_c-trn-doc.need-incfo = 0 and
           bf_c-trn-doc.need-expfo = 0 then do:
          assign
            bf_c-trn-doc.need-incorexpfo = 0.
        end.
        reposition br-docs to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc )) @ varpost with browse br-docs.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end.
end procedure.
procedure proc-m_gen-4 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.
  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  define variable varcr-incfo as logical no-undo.
  define variable varinc-exp  as integer no-undo.
  define buffer buf_parts    for ub.parts.
  define buffer buf_contract for ub.contract.
  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.
    vari-cycle:
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-incfo = yes then do:
        assign
          varlog = no.
        message "По документу " bf_c-trn-doc.doc-code " было создано финансовое обязательство от " bf_c-trn-doc.incfo-date " ." skip
                "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          next vari-cycle.
        end.
        assign
          bf_c-trn-doc.cr-incfo   = no
          bf_c-trn-doc.incfo-date = 01/01/1990.
        if bf_c-trn-doc.cr-incfo = no and
           bf_c-trn-doc.cr-expfo = no then do:
          assign
            bf_c-trn-doc.cr-incorexpfo = no.
        end.
        reposition br-docs to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc) ) @ varpost with browse br-docs.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end.
end procedure.
procedure proc-m_gen-5 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.
  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  define variable varcr-expfo as logical no-undo.
  define variable varinc-exp  as integer no-undo.
  define buffer buf_parts    for ub.parts.
  define buffer buf_contract for ub.contract.
  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.
    vari-cycle:
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      if bf_c-trn-doc.status_ <> 'факт':U then do:
        message "Документ " bf_c-trn-doc.status_ " не в статусе " 'факт':U " . Пропускаем."
        view-as alert-box.
        next.
      end.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-expfo = yes then do:
        assign
          varlog = no.
        message "По документу " bf_c-trn-doc.doc-code " было создано финансовое обязательство от " bf_c-trn-doc.incfo-date " ." skip
                "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          next vari-cycle.
        end.
        assign
          bf_c-trn-doc.cr-expfo   = no
          bf_c-trn-doc.expfo-date = 01/01/1990.
        if bf_c-trn-doc.cr-incfo = no and
           bf_c-trn-doc.cr-expfo = no then do:
          assign
            bf_c-trn-doc.cr-incorexpfo = no.
        end.
        reposition br-docs to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-realiz( recid( bf_c-trn-doc )) @ varrealiz with browse br-docs.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end.
end procedure.
procedure get-c-holding :
  define  input parameter p-doc-code as character no-undo.
  define output parameter p-holding  as logical   no-undo.
  define variable l_is-holding as logical no-undo.
  do on error undo, return error return-value :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_holdcdoc in g#lib-trn3
(
   input p-doc-code
, output l_is-holding
)
         no-error .
    assign p-holding = ( if error-status :error or l_is-holding <> yes then no else yes ).
  end.
end procedure.
procedure local-sel :
if not available c-t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
if mark-list <> "" then do:
  assign doc-rec = recid (c-t-doc).
end.
else do:
  mark-list = string(recid(c-t-doc)).
  assign doc-rec = recid (c-t-doc).
end.
apply "go" to frame d-calldocs.
end procedure.
PROCEDURE proc-find-date :
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.trn-doc.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-code
"":U @ sch-num
with frame d-calldocs.
CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-fact = ?
      .
      display
      sch-fact
      '' @ sch-code
      with frame d-calldocs.
    end.
    when "fact-date":U then do:
      assign
      sch-date = ?
      .
      display
      sch-date
      '' @ sch-code
      with frame d-calldocs.
    end.
END CASE.
assign
v-date-chr = string(day(p-date)) + chr(47) +
                 string(month(p-date)) + chr(47) +
                 string(year(p-date)).
CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and c-t-doc.doc-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-date in frame d-calldocs.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and c-t-doc.fact-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-fact in frame d-calldocs.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-doc-code like ub.c-trn-doc.doc-code no-undo.
assign
sch-date = ?
sch-fact = ?
.
display
sch-date
sch-fact
with frame d-calldocs.
assign
  p-doc-code = replace(p-doc-code, chr(39), chr(39) + chr(39))
.
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and c-t-doc.doc-code begins '&1'"
      ,p-doc-code)
    ).
apply "entry":u to sch-code in frame d-calldocs .
END PROCEDURE.
PROCEDURE proc-view-changes :
define buffer new_c-trn-doc for ub.c-trn-doc.
define buffer current_trn-doc for ub.trn-doc.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available c-t-doc then do:
  open query br-changes for each temp-changes.
  return.
end.
find first new_c-trn-doc no-lock where
           new_c-trn-doc.doc-code  = c-t-doc.doc-code
       and new_c-trn-doc.chip-num  > c-t-doc.chip-num no-error.
if not available new_c-trn-doc then do:
    find first current_trn-doc no-lock where
               current_trn-doc.doc-code  = c-t-doc.doc-code no-error.
         if not available current_trn-doc then do:
         return error.
    end.
    buffer-compare current_trn-doc to c-t-doc
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-trn-doc except chip-num corr-date corr-user-db-num  action to c-t-doc
    save result in v-chg-fields.
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields) .
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):
when "acc-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "acc-date":U     temp-changes.l_name = "дата"     temp-changes.v_old = string(c-t-doc.acc-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.acc-date)                               else string(current_trn-doc.acc-date))     .   end.
when "agnt":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt":U     temp-changes.l_name = "исполнитель"     temp-changes.v_old = string(c-t-doc.agnt)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.agnt)                               else string(current_trn-doc.agnt))     .   end.
when "bge-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "bge-date":U     temp-changes.l_name = "дата выгрузки"     temp-changes.v_old = string(c-t-doc.bge-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.bge-date)                               else string(current_trn-doc.bge-date))     .   end.
when "boss":U then do:     create temp-changes.     assign     temp-changes.f_name = "boss":U     temp-changes.l_name = "менеджер"     temp-changes.v_old = string(c-t-doc.boss)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.boss)                               else string(current_trn-doc.boss))     .   end.
when "buyer-fo-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "buyer-fo-date":U     temp-changes.l_name = "ФО покупателя"     temp-changes.v_old = string(c-t-doc.buyer-fo-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.buyer-fo-date)                               else string(current_trn-doc.buyer-fo-date))     .   end.
when "cli-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-code":U     temp-changes.l_name = "Код контрагента"     temp-changes.v_old = string(c-t-doc.cli-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cli-code)                               else string(current_trn-doc.cli-code))     .   end.
when "cli-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-name":U     temp-changes.l_name = "Контрагент"     temp-changes.v_old = string(c-t-doc.cli-name)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cli-name)                               else string(current_trn-doc.cli-name))     .   end.
when "hold-obj-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-obj-code":U     temp-changes.l_name = "Объект МФ"     temp-changes.v_old = string(c-t-doc.hold-obj-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-obj-code)                               else string(current_trn-doc.hold-obj-code))     .   end.
when "hold-obj-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-obj-type":U     temp-changes.l_name = "Тип объекта МФ"     temp-changes.v_old = string(c-t-doc.hold-obj-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-obj-type)                               else string(current_trn-doc.hold-obj-type))     .   end.
when "cli-qnty":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-qnty":U     temp-changes.l_name = "Кол-во в ед.пос-ка"     temp-changes.v_old = string(c-t-doc.cli-qnty)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cli-qnty)                               else string(current_trn-doc.cli-qnty))     .   end.
when "cli-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-type":U     temp-changes.l_name = "Тип Контрагента"     temp-changes.v_old = string(c-t-doc.cli-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cli-type)                               else string(current_trn-doc.cli-type))     .   end.
when "closed":U then do:     create temp-changes.     assign     temp-changes.f_name = "closed":U     temp-changes.l_name = "партии закрыты."     temp-changes.v_old = string(c-t-doc.closed)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.closed)                               else string(current_trn-doc.closed))     .   end.
when "cr-db-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-db-num":U     temp-changes.l_name = "БД создания"     temp-changes.v_old = string(c-t-doc.cr-db-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-db-num)                               else string(current_trn-doc.cr-db-num))     .   end.
when "cr-expfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-expfo":U     temp-changes.l_name = "Создано ФО по расх"     temp-changes.v_old = string(c-t-doc.cr-expfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-expfo)                               else string(current_trn-doc.cr-expfo))     .   end.
when "cr-factur":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-factur":U     temp-changes.l_name = "Создан счет-фактура"     temp-changes.v_old = string(c-t-doc.cr-factur)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-factur)                               else string(current_trn-doc.cr-factur))     .   end.
when "cr-fo-buyer":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-fo-buyer":U     temp-changes.l_name = "Создано ФО покупателя"     temp-changes.v_old = string(c-t-doc.cr-fo-buyer)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-fo-buyer)                               else string(current_trn-doc.cr-fo-buyer))     .   end.
when "cr-incfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-incfo":U     temp-changes.l_name = "Создано ФО по прих"     temp-changes.v_old = string(c-t-doc.cr-incfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-incfo)                               else string(current_trn-doc.cr-incfo))     .   end.
when "cr-incorexpfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "cr-incorexpfo":U     temp-changes.l_name = "Создано ФО поставщика"     temp-changes.v_old = string(c-t-doc.cr-incorexpfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cr-incorexpfo)                               else string(current_trn-doc.cr-incorexpfo))     .   end.
when "creid":U then do:     create temp-changes.     assign     temp-changes.f_name = "creid":U     temp-changes.l_name = "создал"     temp-changes.v_old = string(c-t-doc.creid)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.creid)                               else string(current_trn-doc.creid))     .   end.
when "cst-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "cst-code":U     temp-changes.l_name = "ГТД"     temp-changes.v_old = string(c-t-doc.cst-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.cst-code)                               else string(current_trn-doc.cst-code))     .   end.
when "d-card":U then do:     create temp-changes.     assign     temp-changes.f_name = "d-card":U     temp-changes.l_name = "Дисконтная карта"     temp-changes.v_old = string(c-t-doc.d-card)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.d-card)                               else string(current_trn-doc.d-card))     .   end.
when "discnt-pc":U then do:     create temp-changes.     assign     temp-changes.f_name = "discnt-pc":U     temp-changes.l_name = "Скидка"     temp-changes.v_old = string(c-t-doc.discnt-pc)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.discnt-pc)                               else string(current_trn-doc.discnt-pc))     .   end.
when "discnt-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "discnt-rubl":U     temp-changes.l_name = "Скидка в нац.вал."     temp-changes.v_old = string(c-t-doc.discnt-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.discnt-rubl)                               else string(current_trn-doc.discnt-rubl))     .   end.
when "discnt-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "discnt-type":U     temp-changes.l_name = "Тип скидки"     temp-changes.v_old = string(c-t-doc.discnt-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.discnt-type)                               else string(current_trn-doc.discnt-type))     .   end.
when "doc-qnty":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-qnty":U     temp-changes.l_name = "Кол-во по док-ту"     temp-changes.v_old = string(c-t-doc.doc-qnty)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.doc-qnty)                               else string(current_trn-doc.doc-qnty))     .   end.
when "exch-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-code":U     temp-changes.l_name = "валюта док-та"     temp-changes.v_old = string(c-t-doc.exch-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.exch-code)                               else string(current_trn-doc.exch-code))     .   end.
when "exch-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-date":U     temp-changes.l_name = "дата валюты"     temp-changes.v_old = string(c-t-doc.exch-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.exch-date)                               else string(current_trn-doc.exch-date))     .   end.
when "excise":U then do:     create temp-changes.     assign     temp-changes.f_name = "excise":U     temp-changes.l_name = "акциз"     temp-changes.v_old = string(c-t-doc.excise)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.excise)                               else string(current_trn-doc.excise))     .   end.
when "expfo-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "expfo-date":U     temp-changes.l_name = "дата расх ФО"     temp-changes.v_old = string(c-t-doc.expfo-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.expfo-date)                               else string(current_trn-doc.expfo-date))     .   end.
 when "ext-doc-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "ext-doc-type":U     temp-changes.l_name = "тип док-та"     temp-changes.v_old = string(c-t-doc.ext-doc-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ext-doc-type)                               else string(current_trn-doc.ext-doc-type))     .   end.
 when "fact-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-base":U     temp-changes.l_name = "факт сумма в баз.вал."     temp-changes.v_old = string(c-t-doc.fact-base)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-base)                               else string(current_trn-doc.fact-base))     .   end.
when "fact-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-num":U     temp-changes.l_name = "№ пп"     temp-changes.v_old = string(c-t-doc.fact-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-num)                               else string(current_trn-doc.fact-num))     .   end.
 when "fact-qnty":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-qnty":U     temp-changes.l_name = "Кол-во факт"     temp-changes.v_old = string(c-t-doc.fact-qnty)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-qnty)                               else string(current_trn-doc.fact-qnty))     .   end.
when "fact-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-rubl":U     temp-changes.l_name = "факт сумма в нац.вал."     temp-changes.v_old = string(c-t-doc.fact-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-rubl)                               else string(current_trn-doc.fact-rubl))     .   end.
when "fact-time":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-time":U     temp-changes.l_name = "время закрытия"     temp-changes.v_old = string(c-t-doc.fact-time)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-time)                               else string(current_trn-doc.fact-time))     .   end.
when "factur-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "factur-date":U     temp-changes.l_name = "дата счета-фактуры"     temp-changes.v_old = string(c-t-doc.factur-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.factur-date)                               else string(current_trn-doc.factur-date))     .   end.
when "fbr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "fbr-code":U     temp-changes.l_name = "производсво"     temp-changes.v_old = string(c-t-doc.fbr-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fbr-code)                               else string(current_trn-doc.fbr-code))     .   end.
when "flag_":U then do:     create temp-changes.     assign     temp-changes.f_name = "flag_":U     temp-changes.l_name = "ОК"     temp-changes.v_old = string(c-t-doc.flag_)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.flag_)                               else string(current_trn-doc.flag_))     .   end.
 when "flora-order-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "flora-order-date":U     temp-changes.l_name = "Дата заказа (букет)"     temp-changes.v_old = string(c-t-doc.flora-order-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.flora-order-date)                               else string(current_trn-doc.flora-order-date))     .   end.
when "flora-pay-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "flora-pay-date":U     temp-changes.l_name = "Дата оплаты(букет)"     temp-changes.v_old = string(c-t-doc.flora-pay-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.flora-pay-date)                               else string(current_trn-doc.flora-pay-date))     .   end.
 when "hold-doc-code-child":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-doc-code-child":U     temp-changes.l_name = "МФ №док-та ребенка"     temp-changes.v_old = string(c-t-doc.hold-doc-code-child)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-doc-code-child)                               else string(current_trn-doc.hold-doc-code-child))     .   end.
 when "hold-doc-code-parent":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-doc-code-parent":U     temp-changes.l_name = "МФ №док-та родителя"     temp-changes.v_old = string(c-t-doc.hold-doc-code-parent)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-doc-code-parent)                               else string(current_trn-doc.hold-doc-code-parent))     .   end.
when "hold-obj-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-obj-code":U     temp-changes.l_name = "МФ объект"     temp-changes.v_old = string(c-t-doc.hold-obj-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-obj-code)                               else string(current_trn-doc.hold-obj-code))     .   end.
 when "hold-obj-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "hold-obj-type":U     temp-changes.l_name = "МФ тип объекта"     temp-changes.v_old = string(c-t-doc.hold-obj-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.hold-obj-type)                               else string(current_trn-doc.hold-obj-type))     .   end.
when "incfo-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "incfo-date":U     temp-changes.l_name = "дата прих ФО"     temp-changes.v_old = string(c-t-doc.incfo-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.incfo-date)                               else string(current_trn-doc.incfo-date))     .   end.
when "internal":U then do:     create temp-changes.     assign     temp-changes.f_name = "internal":U     temp-changes.l_name = "внутр. док-т"     temp-changes.v_old = string(c-t-doc.internal)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.internal)                               else string(current_trn-doc.internal))     .   end.
 when "inv-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "inv-num":U     temp-changes.l_name = "инвентаризация"     temp-changes.v_old = string(c-t-doc.inv-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.inv-num)                               else string(current_trn-doc.inv-num))     .   end.
when "is-back-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "is-back-date":U     temp-changes.l_name = "Кор-ка задним числом"     temp-changes.v_old = string(c-t-doc.is-back-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.is-back-date)                               else string(current_trn-doc.is-back-date))     .   end.
 when "is-del":U then do:     create temp-changes.     assign     temp-changes.f_name = "is-del":U     temp-changes.l_name = "Удален"     temp-changes.v_old = string(c-t-doc.is-del)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.is-del)                               else string(current_trn-doc.is-del))     .   end.
when "is-flora":U then do:     create temp-changes.     assign     temp-changes.f_name = "is-flora":U     temp-changes.l_name = "Букет"     temp-changes.v_old = string(c-t-doc.is-flora)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.is-flora)                               else string(current_trn-doc.is-flora))     .   end.
when "need-buyer":U then do:     create temp-changes.     assign     temp-changes.f_name = "need-buyer":U     temp-changes.l_name = "Нужно ФО покупателя"     temp-changes.v_old = string(c-t-doc.need-buyer)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.need-buyer)                               else string(current_trn-doc.need-buyer))     .   end.
when "need-expfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "need-expfo":U     temp-changes.l_name = "Нужно ФО по расходу"     temp-changes.v_old = string(c-t-doc.need-expfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.need-expfo)                               else string(current_trn-doc.need-expfo))     .   end.
when "need-factur":U then do:     create temp-changes.     assign     temp-changes.f_name = "need-factur":U     temp-changes.l_name = "Нужен счет-фактура"     temp-changes.v_old = string(c-t-doc.need-factur)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.need-factur)                               else string(current_trn-doc.need-factur))     .   end.
when "need-incfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "need-incfo":U     temp-changes.l_name = "Нужно ФО по приходу"     temp-changes.v_old = string(c-t-doc.need-incfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.need-incfo)                               else string(current_trn-doc.need-incfo))     .   end.
when "need-incorexpfo":U then do:     create temp-changes.     assign     temp-changes.f_name = "need-incorexpfo":U     temp-changes.l_name = "Нужно ФО поставщика"     temp-changes.v_old = string(c-t-doc.need-incorexpfo)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.need-incorexpfo)                               else string(current_trn-doc.need-incorexpfo))     .   end.
when "obj-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "obj-code":U     temp-changes.l_name = "объект"     temp-changes.v_old = string(c-t-doc.obj-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.obj-code)                               else string(current_trn-doc.obj-code))     .   end.
 when "obj-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "obj-type":U     temp-changes.l_name = "тип объекта"     temp-changes.v_old = string(c-t-doc.obj-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.obj-type)                               else string(current_trn-doc.obj-type))     .   end.
when "office":U then do:     create temp-changes.     assign     temp-changes.f_name = "office":U     temp-changes.l_name = "услуги"     temp-changes.v_old = string(c-t-doc.office)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.office)                               else string(current_trn-doc.office))     .   end.
when "ord-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "ord-num":U     temp-changes.l_name = "Номер заказа"     temp-changes.v_old = string(c-t-doc.ord-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ord-num)                               else string(current_trn-doc.ord-num))     .   end.
when "out-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "out-code":U     temp-changes.l_name = "Ссылка на док-т"     temp-changes.v_old = string(c-t-doc.out-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.out-code)                               else string(current_trn-doc.out-code))     .   end.
 when "ov":U then do:     create temp-changes.     assign     temp-changes.f_name = "ov":U     temp-changes.l_name = "акт авт.переоценки"     temp-changes.v_old = string(c-t-doc.ov)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ov)                               else string(current_trn-doc.ov))     .   end.
 when "pay-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "pay-code":U     temp-changes.l_name = "Способ платежа"     temp-changes.v_old = string(c-t-doc.pay-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.pay-code)                               else string(current_trn-doc.pay-code))     .   end.
when "place-io-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "place-io-code":U     temp-changes.l_name = "Место п/о"     temp-changes.v_old = string(c-t-doc.place-io-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.place-io-code)                               else string(current_trn-doc.place-io-code))     .   end.
 when "point-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "point-code":U     temp-changes.l_name = "Пункт п/о"     temp-changes.v_old = string(c-t-doc.point-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.point-code)                               else string(current_trn-doc.point-code))     .   end.
  when "print-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "print-rubl":U     temp-changes.l_name = "Печать в нац.вал."     temp-changes.v_old = string(c-t-doc.print-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.print-rubl)                               else string(current_trn-doc.print-rubl))     .   end.
  when "PS":U then do:     create temp-changes.     assign     temp-changes.f_name = "PS":U     temp-changes.l_name = "Примечание"     temp-changes.v_old = string(c-t-doc.PS)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.PS)                               else string(current_trn-doc.PS))     .   end.
 when "purch-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "purch-code":U     temp-changes.l_name = "тип приобретения"     temp-changes.v_old = string(c-t-doc.purch-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.purch-code)                               else string(current_trn-doc.purch-code))     .   end.
 when "re-grading-parts-minus":U then do:     create temp-changes.     assign     temp-changes.f_name = "re-grading-parts-minus":U     temp-changes.l_name = "пересорт по -парт."     temp-changes.v_old = string(c-t-doc.re-grading-parts-minus)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.re-grading-parts-minus)                               else string(current_trn-doc.re-grading-parts-minus))     .   end.
 when "real-date-create":U then do:     create temp-changes.     assign     temp-changes.f_name = "real-date-create":U     temp-changes.l_name = "дата создания"     temp-changes.v_old = string(c-t-doc.real-date-create)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.real-date-create)                               else string(current_trn-doc.real-date-create))     .   end.
when "real-time-create":U then do:     create temp-changes.     assign     temp-changes.f_name = "real-time-create":U     temp-changes.l_name = "время создания"     temp-changes.v_old = string(c-t-doc.real-time-create)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.real-time-create)                               else string(current_trn-doc.real-time-create))     .   end.
  when "reason-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "reason-code":U     temp-changes.l_name = "Код причины"     temp-changes.v_old = string(c-t-doc.reason-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.reason-code)                               else string(current_trn-doc.reason-code))     .   end.
  when "ret-supp":U then do:     create temp-changes.     assign     temp-changes.f_name = "ret-supp":U     temp-changes.l_name = "возврат поставщика"     temp-changes.v_old = string(c-t-doc.ret-supp)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ret-supp)                               else string(current_trn-doc.ret-supp))     .   end.
 when "road-tax":U then do:     create temp-changes.     assign     temp-changes.f_name = "road-tax":U     temp-changes.l_name = "дор.налог"     temp-changes.v_old = string(c-t-doc.road-tax)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.road-tax)                               else string(current_trn-doc.road-tax))     .   end.
when "rsrv-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "rsrv-date":U     temp-changes.l_name = "резервирование"     temp-changes.v_old = string(c-t-doc.rsrv-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.rsrv-date)                               else string(current_trn-doc.rsrv-date))     .   end.
 when "scf-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "scf-date":U     temp-changes.l_name = "счет-фактура"     temp-changes.v_old = string(c-t-doc.scf-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.scf-date)                               else string(current_trn-doc.scf-date))     .   end.
 when "shift-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "shift-date":U     temp-changes.l_name = "сменная дата"     temp-changes.v_old = string(c-t-doc.shift-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.shift-date)                               else string(current_trn-doc.shift-date))     .   end.
when "shift-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "shift-name":U     temp-changes.l_name = "№ смены"     temp-changes.v_old = string(c-t-doc.shift-name)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.shift-name)                               else string(current_trn-doc.shift-name))     .   end.
when "shift-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "shift-num":U     temp-changes.l_name = "Порядок смены"     temp-changes.v_old = string(c-t-doc.shift-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.shift-num)                               else string(current_trn-doc.shift-num))     .   end.
when "ship-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "ship-date":U     temp-changes.l_name = "Дата отгрузки"     temp-changes.v_old = string(c-t-doc.ship-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ship-date)                               else string(current_trn-doc.ship-date))     .   end.
when "ship-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "ship-num":U     temp-changes.l_name = "Отгрузка"     temp-changes.v_old = string(c-t-doc.ship-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.ship-num)                               else string(current_trn-doc.ship-num))     .   end.
when "SLT-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "SLT-base":U     temp-changes.l_name = "НДС б.в."     temp-changes.v_old = string(c-t-doc.SLT-base)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.SLT-base)                               else string(current_trn-doc.SLT-base))     .   end.
when "SLT-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "SLT-rubl":U     temp-changes.l_name = "НДС н.в"     temp-changes.v_old = string(c-t-doc.SLT-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.SLT-rubl)                               else string(current_trn-doc.SLT-rubl))     .   end.
when "SLT-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "SLT-type":U     temp-changes.l_name = "НДС тип"     temp-changes.v_old = string(c-t-doc.SLT-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.SLT-type)                               else string(current_trn-doc.SLT-type))     .   end.
when "status_":U then do:     create temp-changes.     assign     temp-changes.f_name = "status_":U     temp-changes.l_name = "статус"     temp-changes.v_old = string(c-t-doc.status_)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.status_)                               else string(current_trn-doc.status_))     .   end.
when "sys-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "sys-date":U     temp-changes.l_name = "Системная дата"     temp-changes.v_old = string(c-t-doc.sys-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.sys-date)                               else string(current_trn-doc.sys-date))     .   end.
when "sys-time":U then do:     create temp-changes.     assign     temp-changes.f_name = "sys-time":U     temp-changes.l_name = "Системное время"     temp-changes.v_old = string(c-t-doc.sys-time)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.sys-time)                               else string(current_trn-doc.sys-time))     .   end.
when "tot-calc":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-calc":U     temp-changes.l_name = "Расчет"     temp-changes.v_old = string(c-t-doc.tot-calc)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-calc)                               else string(current_trn-doc.tot-calc))     .   end.
when "tot-cli":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-cli":U     temp-changes.l_name = "По ТТН"     temp-changes.v_old = string(c-t-doc.tot-cli)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-cli)                               else string(current_trn-doc.tot-cli))     .   end.
when "tot-doc":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-doc":U     temp-changes.l_name = "По накл."     temp-changes.v_old = string(c-t-doc.tot-doc)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-doc)                               else string(current_trn-doc.tot-doc))     .   end.
when "tot-fact":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-fact":U     temp-changes.l_name = "Факт"     temp-changes.v_old = string(c-t-doc.tot-fact)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-fact)                               else string(current_trn-doc.tot-fact))     .   end.
when "tot-lines":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-lines":U     temp-changes.l_name = "Строк"     temp-changes.v_old = string(c-t-doc.tot-lines)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-lines)                               else string(current_trn-doc.tot-lines))     .   end.
when "tot-other":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-other":U     temp-changes.l_name = "Прочие"     temp-changes.v_old = string(c-t-doc.tot-other)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-other)                               else string(current_trn-doc.tot-other))     .   end.
when "tot-ov":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-ov":U     temp-changes.l_name = "По акту"     temp-changes.v_old = string(c-t-doc.tot-ov)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-ov)                               else string(current_trn-doc.tot-ov))     .   end.
when "tot-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-rubl":U     temp-changes.l_name = "По накл.н.в."     temp-changes.v_old = string(c-t-doc.tot-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-rubl)                               else string(current_trn-doc.tot-rubl))     .   end.
when "tot-sale":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-sale":U     temp-changes.l_name = "Сумма накладной Факт "     temp-changes.v_old = string(c-t-doc.tot-sale)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-sale)                               else string(current_trn-doc.tot-sale))     .   end.
when "tot-transp":U then do:     create temp-changes.     assign     temp-changes.f_name = "tot-transp":U     temp-changes.l_name = "трансп.расх"     temp-changes.v_old = string(c-t-doc.tot-transp)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.tot-transp)                               else string(current_trn-doc.tot-transp))     .   end.
when "user-db-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "user-db-num":U     temp-changes.l_name = "БД корректирования"     temp-changes.v_old = string(c-t-doc.user-db-num)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.user-db-num)                               else string(current_trn-doc.user-db-num))     .   end.
when "user-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "user-name":U     temp-changes.l_name = "оператор"     temp-changes.v_old = string(c-t-doc.user-name)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.user-name)                               else string(current_trn-doc.user-name))     .   end.
when "VAT-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "VAT-base":U     temp-changes.l_name = "НсП б.в"     temp-changes.v_old = string(c-t-doc.VAT-base)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.VAT-base)                               else string(current_trn-doc.VAT-base))     .   end.
when "VAT-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "VAT-rubl":U     temp-changes.l_name = "НсП н.в"     temp-changes.v_old = string(c-t-doc.VAT-rubl)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.VAT-rubl)                               else string(current_trn-doc.VAT-rubl))     .   end.
when "VAT-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "VAT-type":U     temp-changes.l_name = "НсП тип"     temp-changes.v_old = string(c-t-doc.VAT-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.VAT-type)                               else string(current_trn-doc.VAT-type))     .   end.
when "whole-send-news":U then do:     create temp-changes.     assign     temp-changes.f_name = "whole-send-news":U     temp-changes.l_name = "ушла в новости"     temp-changes.v_old = string(c-t-doc.whole-send-news)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.whole-send-news)                               else string(current_trn-doc.whole-send-news))     .   end.
when "wrkr":U then do:     create temp-changes.     assign     temp-changes.f_name = "wrkr":U     temp-changes.l_name = "кладовщик"     temp-changes.v_old = string(c-t-doc.wrkr)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.wrkr)                               else string(current_trn-doc.wrkr))     .   end.
when "base-rate":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-rate":U     temp-changes.l_name = "м-б баз.ва."     temp-changes.v_old = string(c-t-doc.base-rate)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.base-rate)                               else string(current_trn-doc.base-rate))     .   end.
when "base-scale":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-scale":U     temp-changes.l_name = "шкала баз.вал."     temp-changes.v_old = string(c-t-doc.base-scale)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.base-scale)                               else string(current_trn-doc.base-scale))     .   end.
when "contract-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-code":U     temp-changes.l_name = "Номер договора"     temp-changes.v_old = string(c-t-doc.contract-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.contract-code)                               else string(current_trn-doc.contract-code))     .   end.
when "doc-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-date":U     temp-changes.l_name = "Дата создания"     temp-changes.v_old = string(c-t-doc.doc-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.doc-date)                               else string(current_trn-doc.doc-date))     .   end.
when "doc-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-type":U     temp-changes.l_name = "Тип"     temp-changes.v_old = string(c-t-doc.doc-type)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.doc-type)                               else string(current_trn-doc.doc-type))     .   end.
when "exch-rate":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-rate":U     temp-changes.l_name = "м-б валюты платежа"     temp-changes.v_old = string(c-t-doc.exch-rate)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.exch-rate)                               else string(current_trn-doc.exch-rate))     .   end.
when "exch-scale":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-scale":U     temp-changes.l_name = "шкала валюты платежа"     temp-changes.v_old = string(c-t-doc.exch-scale)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.exch-scale)                               else string(current_trn-doc.exch-scale))     .   end.
when "fact-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-date":U     temp-changes.l_name = "Дата факт"     temp-changes.v_old = string(c-t-doc.fact-date)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-date)                               else string(current_trn-doc.fact-date))     .   end.
when "fact-order":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-order":U     temp-changes.l_name = "факт-ордер"     temp-changes.v_old = string(c-t-doc.fact-order)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.fact-order)                               else string(current_trn-doc.fact-order))     .   end.
when "host-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "host-code":U     temp-changes.l_name = "Код фирмы"     temp-changes.v_old = string(c-t-doc.host-code)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.host-code)                               else string(current_trn-doc.host-code))     .   end.
when "status_":U then do:     create temp-changes.     assign     temp-changes.f_name = "status_":U     temp-changes.l_name = "Статус"     temp-changes.v_old = string(c-t-doc.status_)     temp-changes.v_new = (if available new_c-trn-doc                               then string(new_c-trn-doc.status_)                               else string(current_trn-doc.status_))     .   end.
end case.
end.
open query br-changes for each temp-changes.
END PROCEDURE.
