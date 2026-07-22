define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter bttns          as character no-undo .
define input  parameter list-mode      as character no-undo .
define input  parameter g#flag         as logical   no-undo .
define input  parameter g#stat         as character no-undo .
define output parameter mark-list      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов флористов".
define variable  parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable v-sys-key   as character         no-undo.
define variable  paris-hold      as   logical              no-undo.
define variable  varlog as logical   no-undo .
define variable  line-rec as recid no-undo .
define variable v-nn as integer   no-undo .
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
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define new shared variable next-prev  as logical   no-undo .
define variable doc-rec               as recid     no-undo .
define variable pardoc-rec            as recid     no-undo .
define variable v-log                 as logical   no-undo .
define variable g#report-num          as integer   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-sale                as logical   no-undo .
define variable from-date  as   date no-undo.
define variable to-date    as   date no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
assign
  parext-doc-type =  'ee':U
  paris-hold = false
.
define new shared var br-handle as handle no-undo.
define variable bf-handle as handle no-undo.
DEFINE new SHARED BUFFER t-doc for ub.trn-doc.
define  new shared buffer sch-pay for ub.pay-type.
define  new shared buffer sch-curr for ub.currency.
define  new shared buffer sch-cli for ub.clients.
define  new shared buffer sch-inv for ub.trn-doc.
define new shared variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define new shared variable varis-hold      as   logical                 no-undo.
assign
  varext-doc-type = parext-doc-type
  varis-hold      = paris-hold
.
define  buffer cli-buf for ub.clients.
define  buffer t-d-b for ub.trn-doc.
define temp-table temp_recid-list no-undo
    field string-trn-doc-recid as character
    index pi is primary unique string-trn-doc-recid
.
define variable sch-field as character no-undo.
define variable mark      as character no-undo.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable old-list           as character  no-undo.
define variable old-stat           as character  no-undo.
define variable chg-qnty like ub.gds-dtl.doc-qnty no-undo.
define variable choice             as logical    no-undo  initial ?.
define variable objects            as integer    no-undo.
define variable varfact-date       as date       no-undo.
define variable varshift-date      as date       no-undo.
define variable varshift-num       as integer    no-undo.
define variable varshift-name      as character  no-undo.
define variable varcheck-return    as logical    no-undo.
define variable varpost            as character  no-undo.
define variable varrealiz          as character  no-undo.
define variable v-ext-button-label as character  no-undo.
define variable v_shift            as character  no-undo  initial ?.
define variable v_data-type        as character  no-undo  initial ?.
define variable varhold            as character  no-undo.
define variable varhold-type       as character  no-undo.
define variable sort-column-name   as character  no-undo.
define variable filter-point       as character  no-undo.
define variable l-query-was-opened as logical    no-undo.
define variable sort-column-phrase as character  no-undo.
define variable parschdoc-code     like ub.trn-doc.doc-code     no-undo.
define variable parschcurr-code    like ub.currency.curr-code   no-undo.
define variable parschobj-code     like ub.clients.obj-code     no-undo.
define variable parschcli-type     like ub.clients.obj-type     no-undo.
define variable parschcli-code     like ub.clients.obj-code     no-undo.
define buffer exp_trn-doc for ub.trn-doc.
define buffer ret-doc     for ub.trn-doc.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 8 BY 1.
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 8 BY 1.
DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-bc
     LABEL "&Ценник":L
     SIZE 10 BY 1.
DEFINE BUTTON b-akt
     LABEL "АПерео&ц":L
     SIZE 10 BY 1.
DEFINE BUTTON b-ext
     LABEL "Запус&к":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-close-new
     LABEL "&Закрыть":L
     SIZE 10 BY 1.
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 1 BY 1.
DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 4 BY 1.
define button b-exp
     label "Экспорт":l
     size 10 by 1.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34 BY 1 NO-UNDO.
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2 NO-UNDO.
define  MENU m-rep
    MENU-ITEM m-rep-1 LABEL "По документам"  ACCELERATOR "ALT-1"
    MENU-ITEM m-rep-2 LABEL "Отчет по оплате заказов на исполнение"  ACCELERATOR "ALT-2"
    .
define new shared variable sch-code    like ub.trn-doc.doc-code no-undo.
define new shared variable sch-date    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-fact    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-objtype like ub.clients.obj-type no-undo.
define new shared variable sch-objcode like ub.clients.obj-code no-undo.
define new shared variable sch-sum     like ub.trn-doc.tot-fact no-undo.
define new shared variable sch-num     as   integer view-as fill-in size 3 by 1 no-undo.
define new shared variable sch-order    as   date view-as fill-in size 9 by 1 no-undo.
define new shared query br-docs for t-doc  scrolling.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function total-fact return decimal  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? . ~
return (if t-d.print-rubl then t-d.tot-sale else t-d.tot-fact). ~
end function. ~
function first-symb-type return char  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring (t-d.doc-type, 1, 1)).                    ~
end function. ~
function day-month return char ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring ((string (t-d.doc-date)), 1, 5)).        ~
end function.  ~
function shift-day-month return char ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring ((string (t-d.shift-date)), 1, 5)).      ~
end function.  ~
function object-label return char  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (trim (t-d.obj-type)  + string (t-d.obj-code)). ~
end function.  ~
function fcli-name return character   ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return t-d.cli-name .  ~
end function.
function total-pay-fact return character
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return chr(1) .
if loc-t-doc.doc-type = 'инв':U then return "" .
if (loc-t-doc.ext-doc-type = 'es':U or loc-t-doc.ext-doc-type = 'rs':U) and v-sale <> yes then return "?" .
if loc-t-doc.doc-type = 'при':U and
   loc-t-doc.internal = no        then do:
  return string ( loc-t-doc.tot-calc , "->,>>>,>>>,>>>,>>9.99" ).
end.
else do:
  return string( ( if loc-t-doc.print-rubl then (loc-t-doc.tot-sale - loc-t-doc.discnt-rubl) else (loc-t-doc.tot-fact - loc-t-doc.tot-calc) ) , "->,>>>,>>>,>>>,>>9.99" ).
end.
end function.
function total-acc return decimal
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ? .
  if (loc-t-doc.ext-doc-type = 'es':U or loc-t-doc.ext-doc-type = 'rs':U) and v-sale <> yes then return ?.
  return (if loc-t-doc.print-rubl then loc-t-doc.fact-rubl else loc-t-doc.fact-base).
end function.
function shift-name return character
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ? .
  if loc-t-doc.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if loc-t-doc.shift-num = integer(loc-t-doc.shift-name) then do:
      return loc-t-doc.shift-name.
    end.
    else do:
      return loc-t-doc.shift-name + "(" + string(loc-t-doc.shift-num) + ")".
    end.
  end.
end function.
function closed-backdated return character
( input p-rec as recid ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ?.
  return ( if loc-t-doc.is-back-date then "+" else "" ).
end function.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function mark-string return character
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
return ( if lookup(string(recid(t-d)),mark-list) > 0 then '*' else '' ).
end function.
function factur return char
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-factur = yes then do:
   return string(t-d.factur-date).
 end.
 else do:
   if t-d.need-factur = 0 then  return '0'.
   if t-d.need-factur = 1 then  return '1'.
   if t-d.need-factur = 2 then  return '2'.
 end.
end function.
function fo-buyer return char
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-fo-buyer = yes then do:
   return string (t-d.buyer-fo-date).
 end.
 else do:
   if t-d.need-buyer = 0 then return '0'.
   if t-d.need-buyer = 1 then return '1'.
   if t-d.need-buyer = 2 then return '2'.
 end.
end function.
function fo-realiz return integer
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
 if t-d.cr-expfo = yes then do:
   return int (t-d.expfo-date).
 end.
 else do:
   if t-d.need-expfo = 0 then return 0.
   if t-d.need-expfo = 1 then return 1.
   if t-d.need-expfo = 2 then return 2.
 end.
end function.
function fo-postavka return character
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-incfo = yes then do:
   return string (t-d.incfo-date).
 end.
 else do:
   if t-d.need-incfo = 0 then return '0'.
   if t-d.need-incfo = 1 then return '1'.
   if t-d.need-incfo = 2 then return '2'.
 end.
end function.
function total-vat return decimal
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
return (if t-d.print-rubl then t-d.vat-rubl else t-d.vat-base).
end function.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function total-doc-qnty return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( t-d.doc-qnty ).
end function.
function total-fact-qnty return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
return ( t-d.fact-qnty ).
end function.
function total-sum return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.tot-rubl else t-d.tot-doc ).
end function.
function total-dsc return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.discnt-rubl  else t-d.tot-doc - t-d.tot-cli ).
end function.
function total-dsc-fact return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.discnt-rubl else t-d.tot-calc ).
end function.
function fn-time return char
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return '' .
define variable v-val as character no-undo init "".
define variable v-type as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input loc-t-doc.doc-code ,
                        input '1ord_time':U ,
                       output v-val ,
                       output v-type ) no-error .
  if error-status :error then v-val = "" .
  return ( v-val ) .
end function.
function fn-deliv return logical
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return false  .
define variable v-val1 as character no-undo  .
define variable v-val  as logical   no-undo  initial false .
define variable v-type as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input loc-t-doc.doc-code ,
                        input '4ord_dl':U ,
                       output v-val1 ,
                       output v-type ) no-error .
  if not error-status :error and  v-val1 = "yes" then v-val = true .
  return ( v-val ) .
end function.
function fn-ord-itogo return decimal
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return 0 .
define variable v-val  as character no-undo initial "".
define variable v-type as character no-undo .
define variable v-dec  as decimal   no-undo .
if loc-t-doc.status_ = 'факт':U then do:
   v-dec = decimal(total-pay-fact (recid( loc-t-doc))) .
   return v-dec   .
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input loc-t-doc.doc-code ,
                        input 'discnt-stop':U ,
                       output v-val ,
                       output v-type ) no-error .
  if error-status :error then v-val = "" .
  return (decimal(v-val) ) .
end function.
define browse br-docs query br-docs no-lock display
      mark-string (recid( t-doc))  column-label '*'  format "x(1)"
      t-doc.status_  column-label 'Стат'  format "x(4)"
      t-doc.flag_  column-label 'OK'  format "+/-"
      t-doc.doc-code  column-label 'Номер'
      t-doc.doc-date  column-label 'Дата'  format "99/99/99"
      t-doc.fact-date  column-label 'Факт'
      fcli-name (recid(t-doc))  column-label 'Контрагент'  format "x(26)"
      t-doc.flora-order-date  column-label 'Дата заказа'  format "99/99/9999"
      fn-time (recid(t-doc))  column-label 'Время'  format "x(5)"
      fn-deliv (recid(t-doc)) column-label 'Д' format "+/-"
      total-sum (recid(t-doc)) column-label 'Сумма по док' format "->>>,>>>,>>9.99"
      fn-ord-itogo (recid(t-doc)) column-label 'К оплате факт' format "->>>,>>>,>>9.99"
      t-doc.doc-qnty column-label 'Кол-во по док.'
      t-doc.fact-qnty column-label 'Кол-во факт'
      t-doc.print-rubl column-label '$'  format "+/-"
      object-label (recid(t-doc)) column-label 'Объект'  format "x(9)"
      total-dsc (recid(t-doc)) column-label 'Скидка по док'  format "->>>,>>>,>>9.99"
      total-dsc-fact (recid(t-doc)) column-label 'Скидка факт'  format "->>>,>>>,>>9.99"
      total-vat (recid(t-doc)) column-label 'НДС'  format "->,>>>,>>>,>>9.99"
      t-doc.discnt-pc column-label 'Скидка (%)'  format "->,>>9.99"
      t-doc.discnt-type column-label 'Тип скидки'
      t-doc.base-rate column-label 'Курс'
      t-doc.ov column-label 'А'
      t-doc.tot-ov column-label 'Авт. переоц. (прод.)'
      t-doc.inv-num column-label 'Инвойс'
      t-doc.out-code column-label 'На док-т'
      t-doc.acc-date column-label 'Проводка'
      t-doc.bge-date column-label 'Экспорт'
      shift-day-month (recid(t-doc)) column-label 'Смена'
      shift-name (recid(t-doc)) column-label '№' format "x(6)"
      t-doc.tot-transp column-label 'Трансп.расх.(Доставка)'
      t-doc.flora-pay-date column-label 'Дата оплаты'
    enable t-doc.acc-date with size 98 by 13.5 separators.
DEFINE FRAME d-all-docs
     b-quit AT ROW 1 COL 2
     b-mark AT ROW 1 COL 10
     b-sel  AT ROW 1 COL 14
     b-rep  AT ROW 1 COL 22
     b-bc   AT ROW 1 COL 32
     b-akt  AT ROW 1 COL 42
     b-ext  AT ROW 1 COL 52
     b-exp  at row 1 col 62
     b-sch  AT ROW 1 COL 32
     b-help AT ROW 1 COL 86
     b-add    AT ROW 2.3 COL 2
     b-lkp    AT ROW 2.3 COL 12
     b-chg    AT ROW 2.3 COL 22
     b-del    AT ROW 2.3 COL 32
     b-close-new  AT ROW 2.3 COL 42
     b-open   AT ROW 2.3 COL 52
     b-print  AT ROW 2.3 COL 86
     br-docs  AT ROW 3.5 COL 1
     sch-code at row 19 col 2 label "&Начало номера"
     sch-date at row 19 col 33 label "Д&ата"
     sch-fact at row 19 col 52 label "Фа&кт"
     sch-objcode at row 19 col 71 label "&Контрагент"
     sch-objtype at row 19 col 94 no-label
     sch-order at row 20 col 33 label "Дата заказа"
     sch-sum at row 20 col 2 label "&Сумма факт   "
     sch-num at row 19 col 80 label "Найдено" fgcolor 12
     ub.pay-type.obj-name at row 17 col 5 COLON-ALIGNED LABEL "Опл" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     obj-name at row 17 col 55 COLON-ALIGNED LABEL "Объект" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     boss-name at row 18 col 5 COLON-ALIGNED LABEL "М-р" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     agnt-name at row 18 col 30 COLON-ALIGNED LABEL "Исп" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     wrkr-name at row 18 col 55 COLON-ALIGNED LABEL "Кл-к" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     v-user-name at row 18 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 16 BY 1 fgcolor 4
     ed-notes AT ROW 21 COL 1 no-label bgcolor 8 fgcolor 4
     b-close AT ROW 21 COL 1
     SPACE(0) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame d-all-docs do:
   run sort-brbr-docs
     (input (if available t-doc
             then recid(t-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame d-all-docs
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
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Стат'  then DO:    assign       sort-column-name = "t-doc.status_"     .     run ui-on ('open').   . END.
        when 'OK'  then DO:    assign       sort-column-name = "t-doc.flag_"     .     run ui-on ('open').   . END.
        when 'Номер'  then DO:    assign       sort-column-name = "t-doc.doc-code"     .     run ui-on ('open').   . END.
        when 'Дата'  then DO:    assign       sort-column-name = "t-doc.doc-date"     .     run ui-on ('open').   . END.
        when 'Факт'  then DO:    assign       sort-column-name = "t-doc.fact-date"     .     run ui-on ('open').   . END.
        when 'Контрагент'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fcli-name&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Дата заказа'  then DO:    assign       sort-column-name = "t-doc.flora-order-date"     .     run ui-on ('open').   . END.
        when 'Время'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fn-time&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Д'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fn-deliv&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Объект'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fobject-label&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Кол-во по док.'  then DO:    assign       sort-column-name = "t-doc.doc-qnty"     .     run ui-on ('open').   . END.
        when 'Кол-во факт'  then DO:    assign       sort-column-name = "t-doc.fact-qnty"     .     run ui-on ('open').   . END.
        when '$'  then DO:    assign       sort-column-name = "t-doc.print-rubl"     .     run ui-on ('open').   . END.
        when 'Сумма по док'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-sum&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Скидка по док'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-dsc&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Сумма факт'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-fact&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Скидка факт'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-dsc-fact&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'К оплате факт'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fn-ord-itogo&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'НДС'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-vat&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Налог прод.'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1total-slt&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Скидка (%)'  then DO:    assign       sort-column-name = "t-doc.discnt-pc"     .     run ui-on ('open').   . END.
        when 'Тип скидки'  then DO:    assign       sort-column-name = "t-doc.discnt-type"     .     run ui-on ('open').   . END.
        when 'Курс'  then DO:    assign       sort-column-name = "t-doc.base-rate"     .     run ui-on ('open').   . END.
        when 'А'  then DO:    assign       sort-column-name = "t-doc.ov"     .     run ui-on ('open').   . END.
        when 'Авт. переоц. (прод.)'  then DO:    assign       sort-column-name = "t-doc.tot-ov"     .     run ui-on ('open').   . END.
        when 'Инвойс'  then DO:    assign       sort-column-name = "t-doc.inv-num"     .     run ui-on ('open').   . END.
        when 'Заказ'  then DO:    assign       sort-column-name = "t-doc.ord-num"     .     run ui-on ('open').   . END.
        when 'Отгрузка приход'  then DO:    assign       sort-column-name = "t-doc.ship-num"     .     run ui-on ('open').   . END.
        when 'Дата'  then DO:    assign       sort-column-name = "t-doc.ship-date"     .     run ui-on ('open').   . END.
        when 'На док-т'  then DO:    assign       sort-column-name = "t-doc.out-code"     .     run ui-on ('open').   . END.
        when 'Проводка'  then DO:    assign       sort-column-name = "t-doc.acc-date"     .     run ui-on ('open').   . END.
        when 'Экспорт'  then DO:    assign       sort-column-name = "t-doc.bge-date"     .     run ui-on ('open').   . END.
        when 'Смена'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1shift-day-month&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when '№'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1shift-name&1 , ( recid(t-doc)) )' , chr(34))     .     run ui-on ('open').   . END.
        when 'Трансп.расх.(Доставка)'  then DO:    assign       sort-column-name = "t-doc.tot-transp"     .     run ui-on ('open').   . END.
        when 'Дата оплаты'  then DO:    assign       sort-column-name = "t-doc.flora-pay-date"     .     run ui-on ('open').   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run ui-on ('open').
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
    apply "value-changed" to br-docs in frame d-all-docs.
  end.
  apply "entry" to br-docs in frame d-all-docs.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   run ui-on ('open').
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available t-doc
             then recid(t-doc)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
ASSIGN
  FRAME d-all-docs :SCROLLABLE       = FALSE
  br-docs :NUM-LOCKED-COLUMNS IN FRAME d-all-docs = 5.
ASSIGN b-rep :POPUP-MENU IN FRAME d-all-docs = MENU m-rep :HANDLE.
ASSIGN b-rep :MENU-MOUSE = 1.
ON CHOOSE OF MENU-ITEM m-rep-1 in menu m-rep DO:
  define variable buf-handle as handle no-undo .
  define variable q-handle as handle no-undo .
  buf-handle = buffer t-doc :handle .
  q-handle   = query br-docs :handle .
  run rep/rep-par.w (input  parparentproc , input   frame d-all-docs:title , input  q-handle , input buf-handle ).
  choice = ?.
END.
ON CHOOSE OF MENU-ITEM m-rep-2 in menu m-rep DO:
  run rep/g-flora.p (input parparentproc ).
  choice = ?.
END.
on choose of b-mark in frame d-all-docs do:
  RUN local-mark.
  v-log = br-docs:select-next-row ().
  apply "entry" to br-docs in frame d-all-docs.
end.
on any-printable of br-docs in frame d-all-docs do:
  assign
    sch-code:screen-value = sch-code:screen-value + last-event:label.
  apply "entry" to sch-code in frame d-all-docs.
end.
on ctrl-j of sch-code in frame d-all-docs
do:
  run proc-find-code in this-procedure(yes, input frame d-all-docs sch-code).
end.
on return of sch-code in frame d-all-docs
do:
  run proc-find-code in this-procedure(no, input frame d-all-docs sch-code).
  return no-apply.
end.
on ctrl-j of sch-date in frame d-all-docs
do:
  run proc-find-date in this-procedure(yes, input frame d-all-docs sch-date, "doc-date").
end.
on return of sch-date in frame d-all-docs
DO:
  run proc-find-date in this-procedure(no, input frame d-all-docs sch-date, "doc-date":U).
  return no-apply.
END.
on ctrl-j of sch-fact in frame d-all-docs
do:
  run proc-find-date in this-procedure(yes, input frame d-all-docs sch-fact, "fact-date":u).
end.
on return of sch-fact in frame d-all-docs
do:
  run proc-find-date in this-procedure(no, input frame d-all-docs sch-fact, "fact-date":u).
  return no-apply.
end.
on ctrl-j of sch-objtype in frame d-all-docs
do:
  run proc-find-cli in this-procedure(input frame d-all-docs sch-objtype, input frame d-all-docs sch-objcode).
end.
on return of sch-objtype in frame d-all-docs
do:
  run proc-find-cli in this-procedure(input frame d-all-docs sch-objtype, input frame d-all-docs sch-objcode).
  return no-apply.
end.
on return of sch-objcode in frame d-all-docs
do:
  run proc-find-cli in this-procedure(input frame d-all-docs sch-objtype, input frame d-all-docs sch-objcode).
  return no-apply.
end.
on ctrl-j of sch-sum in frame d-all-docs
do:
  run proc-find-sum in this-procedure(input frame d-all-docs sch-sum).
end.
on return of sch-sum in frame d-all-docs
do:
  run proc-find-sum in this-procedure(input frame d-all-docs sch-sum).
  return no-apply.
end.
on ctrl-j of sch-order in frame d-all-docs
do:
  run proc-find-order in this-procedure(yes, input frame d-all-docs sch-order).
end.
on return of sch-order in frame d-all-docs
DO:
  run proc-find-order in this-procedure(no, input frame d-all-docs sch-order).
  return no-apply.
END.
ON CHOOSE OF b-close-new IN FRAME d-all-docs
DO:
define variable v-err as logical no-undo .
define variable v-recid as recid no-undo .
if not available t-doc then return.
v-recid = recid(t-doc) .
run str/fl-cls.p ( input parParentProc ,
                   input  t-doc.doc-code ,
                   output v-err ) .
if v-err = false then return .
if t-doc.status_ = 'накл':U and t-doc.flag_  = false  then do:
   run proc-close no-error .
   if error-status :error then return no-apply.
end.
else do:
   if t-doc.status_ = 'запрос':U and  t-doc.flag_  = false  then do:
       run proc-close-zapr no-error.
       if error-status:error then return no-apply.
   end.
   else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
      br-docs:refresh() in frame d-all-docs.
   end.
end.
find t-doc where recid (t-doc) = v-recid no-lock.
run UI-on ("open").
reposition br-docs to recid v-recid no-error.
END.
on choose of b-add in frame d-all-docs
do:
define variable  v-recid as recid no-undo .
  run local-add in this-procedure no-error.
  v-recid = pardoc-rec.
  if pardoc-rec <> ? then do:
    run UI-on ("open").
    reposition br-docs to recid v-recid no-error.
  end.
end.
ON CHOOSE OF b-chg IN FRAME d-all-docs
DO:
  run proc-b-chg in this-procedure.
END.
ON CHOOSE OF b-del IN FRAME d-all-docs  DO:
  run proc-b-del no-error .
  if error-status :error then return no-apply.
  run UI-on ("open").
end.
on choose of b-sch in frame d-all-docs do:
  run proc-b-sch in this-procedure.
end.
ON CHOOSE OF b-akt IN FRAME d-all-docs
DO:
  run proc-b-akt no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-lkp IN FRAME d-all-docs
DO:
  run proc-b-lkp no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-print IN FRAME d-all-docs
DO:
  run proc-b-print no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-bc IN FRAME d-all-docs
DO:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  assign
    doc-rec    = recid (t-doc)
    pardoc-rec = recid (t-doc)
  .
  run rep/tick-doc.p (parParentProc, doc-rec, "trn", 1, no, no).
  apply "entry" to br-docs in frame d-all-docs.
END.
ON CHOOSE OF b-ext IN FRAME d-all-docs
DO:
  run proc-b-ext no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF b-rep IN FRAME d-all-docs
DO:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
END.
on choose of b-exp in frame d-all-docs
do:
  run local-export.
end.
ON CHOOSE OF b-sel IN FRAME d-all-docs
DO:
 run local-sel in this-procedure.
END.
ON CHOOSE OF b-quit IN FRAME d-all-docs
DO:
  assign
    doc-rec = ?
    pardoc-rec = ?
  .
END.
on entry of ed-notes in frame d-all-docs
do:
  run entry-notes in this-procedure.
end.
on leave of ed-notes in frame d-all-docs
do:
  run local-notes.
end.
on return, mouse-select-dblclick of ed-notes in frame d-all-docs do:
  apply "entry" to br-docs in frame d-all-docs.
  return no-apply.
end.
on return, mouse-select-dblclick of br-docs in frame d-all-docs do:
  apply "choose" to b-lkp in frame d-all-docs.
end.
on value-changed of br-docs do:
  run local-value-changed.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile: trn-clos.i $ $Revision: aea5316774be, 0, rls $".
on choose of b-open in frame d-all-docs
  do:
    define buffer bf_inv-doc-attr for ub.inv-doc-attr .
    define buffer buf_doc-line-attr for doc-line-attr.
    DEFINE buffer curr_inv-doc-attr for ub.inv-doc-attr .
    if not available t-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (t-doc). pardoc-rec = recid (t-doc). do on stop undo, return no-apply :   find t-doc where recid (t-doc) = doc-rec exclusive.   end. if t-doc.status_      = 'факт':U                     or          t-doc.status_      = 'готов':U                    or          t-doc.status_      = 'отказ':U                 or          t-doc.status_      = 'нередакт':U                or          t-doc.status_      = 'прво':U                         then do:    find t-doc where recid (t-doc) = doc-rec no-lock.    message "Данный документ закрыт по факту или не может быть обработан в этом списке.".    return no-apply. end.
    assign
      pardoc-rec = recid (t-doc)
      .
    if t-doc.status_ = 'разрешен':U then
    do:
      find first ub.inv-doc-attr no-lock where (ub.inv-doc-attr.attr-code = "ItogInv" or ub.inv-doc-attr.attr-code = "ItogInvManual")and
        ub.inv-doc-attr.doc-code = t-doc.doc-code no-error .
      if available (ub.inv-doc-attr) then
      do:
        message "Этот документ запрещено открывать!" skip
          "Номер документа" t-doc.doc-code
          view-as alert-box information .
        return .
      end.
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
      ub.inv-doc-attr.attr-code = 'invMultDevice' no-error .
      if available (ub.inv-doc-attr) then
      do:
        message "Этот документ запрещено открывать!" skip
          "Номер документа" t-doc.doc-code
          view-as alert-box information .
        return .
      end.
    end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-open in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
    if error-status :error
      then
    do:
      find t-doc no-lock
        where recid( t-doc) = pardoc-rec
        .
      return no-apply.
    end.
    find t-doc no-lock
      where recid( t-doc) = pardoc-rec
      .
    if t-doc.status_ = 'накл':U then
    do:
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then
      do:
        for each bf_inv-doc-attr exclusive-lock where bf_inv-doc-attr.attr-value = t-doc.doc-code and
          bf_inv-doc-attr.attr-code = 'ManualTSD':
          delete bf_inv-doc-attr .
        end.
      end.
      for each buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.attr-code = 'tsd-qnty':
          delete buf_doc-line-attr .
        end.
    end.
    run UI-on in this-procedure ( input "open" ).
    return no-apply.
  END.
ON CHOOSE OF b-close IN FRAME d-all-docs
  DO:
    define buffer bf_inv-doc-attr for ub.inv-doc-attr .
    define buffer curr_inv-doc-attr for ub.inv-doc-attr .
    define buffer del_inv-doc-attr for ub.inv-doc-attr .
    define variable p-ok as logical no-undo .
    define variable ii      as integer   no-undo .
    define variable docCode as character no-undo .
    if not available t-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (t-doc). pardoc-rec = recid (t-doc). do on stop undo, return no-apply :   find t-doc where recid (t-doc) = doc-rec exclusive.   end. if t-doc.status_      = 'факт':U                     or          t-doc.status_      = 'готов':U                    or          t-doc.status_      = 'отказ':U                 or          t-doc.status_      = 'нередакт':U                or          t-doc.status_      = 'прво':U                         then do:    find t-doc where recid (t-doc) = doc-rec no-lock.    message "Данный документ закрыт по факту или не может быть обработан в этом списке.".    return no-apply. end.
    assign
      pardoc-rec = recid (t-doc)
      .
    if t-doc.doc-type = 'инв':U and t-doc.status_ = 'разрешен':U then
    do:
      define variable is-pos   as logical   no-undo .
      define variable is-date  as logical   no-undo .
      define variable is-fio   as logical   no-undo .
      define variable is-check as logical   no-undo .
      define variable is-mes   as character no-undo .
      define buffer fio_inv-doc-attr    for ub.inv-doc-attr .
      define buffer pos_inv-doc-attr    for ub.inv-doc-attr .
      define buffer prikaz_inv-doc-attr for ub.inv-doc-attr .
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = "invTech" and
        ub.inv-doc-attr.attr-value = string(true) no-error .
      if not available (ub.inv-doc-attr) then
      do:
        if not can-find (first prikaz_inv-doc-attr no-lock where prikaz_inv-doc-attr.doc-code = t-doc.doc-code and
          prikaz_inv-doc-attr.attr-code = 'trdcattr-prikaz-date':U and
          prikaz_inv-doc-attr.attr-value <> "") then
        do:
          is-date = true .
          is-check = true .
        end.
        if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = t-doc.doc-code and
          (fio_inv-doc-attr.attr-code = 'trdcattr-fio-agent':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player1':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player2':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player3':U) and
          fio_inv-doc-attr.attr-value <> "") then
        do:
          is-fio = true .
          is-check = true .
        end.
        if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = t-doc.doc-code and
          (fio_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U or
          fio_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U) and
          fio_inv-doc-attr.attr-value <> "")then
        do:
          is-pos = true .
          is-check = true .
        end.
        if is-check then
        do:
          is-mes = "Ошибка при закрытии документа инвентаризации." .
          if is-date then
          do:
            is-mes = is-mes + chr(10) + "Не указана дата приказа." .
          end.
          if is-fio then
          do:
            is-mes = is-mes + chr(10) + "Не указано ФИО." .
          end.
          if is-pos then
          do:
            is-mes = is-mes + chr(10) + "Не указана должность." .
          end.
        end.
        find first fio_inv-doc-attr no-lock where
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-agent':U and
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + chr(10).
          end.
        end.
        else
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if not available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена должность председателя комиссии." + chr(10).
          end.
        end.
        find first fio_inv-doc-attr no-lock where
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player1':U and
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + chr(10).
          end.
        end.
        else
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if not available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена должность первого участника комиссии." + chr(10).
          end.
        end.
        find first fio_inv-doc-attr no-lock where
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player2':U and
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + chr(10).
          end.
        end.
        else
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if not available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена должность второго участника комиссии." + chr(10).
          end.
        end.
        find first fio_inv-doc-attr no-lock where
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = 'trdcattr-fio-player3':U and
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + chr(10).
          end.
        end.
        else
        do:
          find first pos_inv-doc-attr no-lock where
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
            pos_inv-doc-attr.attr-value <> "" no-error .
          if not available (pos_inv-doc-attr) then
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
            is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + chr(10).
          end.
        end.
        if is-mes <> "" then
        do:
          message
            is-mes
            view-as alert-box .
          return no-apply.
        end.
      end.
    if t-doc.status_ = 'разрешен':U then do:
        run proc-close-inv (output p-ok).
        if not p-ok then return no-apply .
    end.
    end .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
      ub.inv-doc-attr.attr-code = 'invMultDevice' and
      ub.inv-doc-attr.attr-value = string(true) no-error .
    if available (ub.inv-doc-attr) and t-doc.status_ = 'разрешен':U then return no-apply .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
    if error-status :error
      then
    do:
      find t-doc no-lock
        where recid( t-doc) = pardoc-rec
        .
      return no-apply.
    end.
    find t-doc
      no-lock where recid( t-doc ) = pardoc-rec.
    if t-doc.status_ = 'факт':U then
    do:
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInv' no-error .
      if available(ub.inv-doc-attr) then
      do:
        for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code begins ub.inv-doc-attr.attr-value:
          if entry(2,ub.trn-doc.doc-code,"/") = "и" then next .
          delete ub.trn-doc .
        end.
      for each del_inv-doc-attr exclusive-lock where del_inv-doc-attr.attr-value = t-doc.doc-code and
      del_inv-doc-attr.attr-code = "MultiTSD":
       find first ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = del_inv-doc-attr.doc-code no-error .
       if available (ub.trn-doc) then delete ub.trn-doc .
      end.
      end.
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then
      do:
        for each bf_inv-doc-attr no-LOCK where bf_inv-doc-attr.attr-value = t-doc.doc-code and
          bf_inv-doc-attr.attr-code = 'ManualTSD':
          for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = bf_inv-doc-attr.doc-code:
            if docCode = "" then docCode = ub.trn-doc.doc-code .
            else docCode = docCode + ";" + ub.trn-doc.doc-code .
            delete ub.trn-doc .
            for first curr_inv-doc-attr EXCLUSIVE-LOCK where curr_inv-doc-attr.attr-code = bf_inv-doc-attr.attr-code and
            curr_inv-doc-attr.doc-code = bf_inv-doc-attr.doc-code:
            delete bf_inv-doc-attr .
            end.
          end.
        end.
        define variable dd as integer no-undo .
        do dd = 1 to num-entries(docCode,";"):
              for first bf_inv-doc-attr no-lock where bf_inv-doc-attr.attr-code = 'isManualError' and
                  bf_inv-doc-attr.doc-code = entry(dd,docCode,";") + "-M" :
                  message "В системе есть ошибочные накладные инвентаризации." skip
                      "Удалить их?"  view-as alert-box question buttons yes-no update v-ok as logical .
                  if v-ok then
                  do:
                      for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = bf_inv-doc-attr.doc-code:
                          delete ub.trn-doc .
                      end.
                  end.
              end.
          end.
      end.
    end.
    if t-doc.status_ = 'разрешен':U then
    do:
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then
      do:
        do ii = 1 to num-entries(ub.inv-doc-attr.attr-value):
          create bf_inv-doc-attr .
          assign
            bf_inv-doc-attr.attr-code  = 'ManualTSD'
            bf_inv-doc-attr.doc-code   = entry(ii,ub.inv-doc-attr.attr-value)
            bf_inv-doc-attr.attr-value = t-doc.doc-code
            .
        end.
      end.
    end.
    run UI-on in this-procedure ( input "open" ) .
    reposition br-docs to recid pardoc-rec no-error.
  END.
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-all-docs anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-all-docs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-all-docs anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-all-docs anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame d-all-docs anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F8 of frame d-all-docs anywhere do:
  if b-open :sensitive then DO: apply "CHOOSE":U to b-open in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-all-docs anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-all-docs anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-all-docs. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-all-docs:PARENT eq ?
THEN FRAME d-all-docs:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-all-docs APPLY "END-ERROR":U TO SELF.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-all-docs
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
on choose of b-help in frame d-all-docs
do:
  apply "help":u to frame d-all-docs .
end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-all-docs:width - 0.3
                fh            = frame d-all-docs:first-child
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-all-docs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-all-docs :height-chars)
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
    if frame d-all-docs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-all-docs :height-chars)
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
            frame d-all-docs :height = v-frame-height
          .
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-all-docs :height = v-frame-height
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
      v-frame-height = frame d-all-docs :height
      v-frame-virtual-height = frame d-all-docs :virtual-height
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
      v-field-group-handle = frame d-all-docs :first-child
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
    do with frame d-all-docs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-height = frame d-all-docs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-all-docs :height = frame d-all-docs :height + p-change-value
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
        frame d-all-docs :height = frame d-all-docs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-height = frame d-all-docs :virtual-height + p-change-value
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
          ,input  string(frame d-all-docs :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-all-docs :height)
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
    if frame d-all-docs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-all-docs :width
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
    if frame d-all-docs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-all-docs :width
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
            frame d-all-docs :width = v-frame-width
          .
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-all-docs :width = v-frame-width
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
      v-frame-width = frame d-all-docs :width
      v-frame-virtual-width = frame d-all-docs :virtual-width
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
      v-field-group-handle = frame d-all-docs :first-child
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
    do with frame d-all-docs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-width = frame d-all-docs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-all-docs :width = v-frame-width + p-change-value
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
        frame d-all-docs :width = frame d-all-docs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-width = frame d-all-docs :virtual-width + p-change-value
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
          ,input  string(frame d-all-docs :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-all-docs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-all-docs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-all-docs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-all-docs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-all-docs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-all-docs :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-all-docs
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
      v-row-delta = v-new-row - frame d-all-docs :height
      v-col-delta = v-new-col - frame d-all-docs :width
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
            - frame d-all-docs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-all-docs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-all-docs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-all-docs :height-chars
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
      v-diasize-current-frame-width  = frame d-all-docs :width
      v-diasize-current-frame-height = frame d-all-docs :height
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
    do with frame d-all-docs
    :
      assign
        v-diasize-orig-frame-height = frame d-all-docs :height
        v-diasize-orig-frame-width  = frame d-all-docs :width
        v-diasize-browse-handle     = browse br-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-all-docs :first-child
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
sch-code   :TOOLTIP = "Поиск по началу номера документа".
sch-date   :TOOLTIP = "Поиск по дате создания документа".
sch-order  :TOOLTIP = "Поиск по дате заказа".
sch-fact   :TOOLTIP = "Поиск по дате закрытия док-та на факт".
sch-objtype:TOOLTIP = "Поиск по типу контрагента".
sch-objcode:TOOLTIP = "Поиск по номеру контрагента ".
sch-sum    :TOOLTIP = "Поиск по сумме".
sch-num    :TOOLTIP = "Поиск по началу номера документа".
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
  run local-conf-rd    in this-procedure.
  run local-enable     in this-procedure.
run UI-on ("open").
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 37 no-undo.
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
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 6, 37).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (37, 6).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME d-all-docs then.
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
WAIT-FOR GO OF FRAME d-all-docs focus br-docs.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-all-docs.
END PROCEDURE.
PROCEDURE UI-on :
define  input param fnc as char no-undo.
assign t-doc.acc-date:read-only in browse br-docs = yes.
hide b-close in frame d-all-docs .
if fnc = "open" then do:
  frame d-all-docs:title = "ВСЕ  заказы на исполнение".
  sch-num = 0.
  hide sch-num in frame d-all-docs.
end.
else
assign
  doc-rec = ?
  pardoc-rec = ?
.
if lookup (list-mode , 'is-flor':U + ","  + 'is-flor':U + 'объект':U + ","  + 'is-flor':U + 'статус':U   )  > 0 then do:
  run enb-1 (fnc).
end.
else message "Неверный вызов процедуры all-docf.w" .
if fnc <> "open"   and
   available t-d-b then do:
  assign
    doc-rec = recid (t-d-b)
    pardoc-rec = recid (t-d-b).
end.
run openbr( yes, no, '':U, fnc).
end procedure.
PROCEDURE local-mark:
  if not available t-doc then do:
    message "Неправильный выбор строки.".
    return error.
  end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid36 as character no-undo .
define variable v-num-entry36 as integer   no-undo .
assign
  v-str-recid36 = trim( string( recid( t-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry36 = lookup( v-str-recid36 , mark-list )
.
if v-num-entry36 > 0 then do:
  assign
    entry( v-num-entry36, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid36
  .
end.
  br-docs:refresh() in frame d-all-docs.
END PROCEDURE.
procedure proc-b-sch :
assign
  tbl      = 'trn-doc'
  join-tbl = 't-doc'
  fld      = ""
  lab      = ""
  spr      = ""
  dim      = '0'
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
run fltfield-add in this-procedure('ext-doc-type', 'Расширенный тип', 'ext-doc-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rsrv-date', 'Дата резервирования', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
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
run fltfield-add in this-procedure('creid', 'Создал', '',
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
run fltfield-add in this-procedure('PS', 'Примечание', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('purch-code', 'Тип приобретения', 'purch-code',
                                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flora-order-date', 'Дата заказа БУКЕТЫ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flora-pay-date', 'Оплата заказа БУКЕТЫ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
   ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
   ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
RUN OpenBr( yes, no, '':U, 'open':U).
END.
end procedure.
procedure OpenBr :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
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
assign
  parschdoc-code  = (if available sch-inv  then sch-inv.doc-code   else ?)
  parschcurr-code = (if available sch-curr then sch-curr.curr-code else ?)
  parschobj-code  = (if available sch-pay  then sch-pay.obj-code   else ?)
  parschcli-type  = (if available sch-cli  then sch-cli.obj-type   else ?)
  parschcli-code  = (if available sch-cli  then sch-cli.obj-code   else ?)
.
define variable l-open-query as logical   no-undo .
      run modes-3 (
        p-open-query     ,
        p-find-next      ,
        p-find-condition ,
        fnc
        ).
if doc-rec <> ? then do:
  if fnc <> "open" then do:
    assign sch-num = sch-num + 1.
    disp sch-num with frame d-all-docs.
  end.
  reposition br-docs to recid doc-rec no-error.
end.
else do:
  if fnc <> "open" then do:
    message "Документ не найден.".
    assign sch-num = 0.
  end.
end.
run waitfram-hide in this-procedure .
apply "value-changed" to br-docs in frame d-all-docs.
apply "entry" to br-docs.
end procedure.
procedure modes-3:
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
    case list-mode :
      when 'is-flor':U then do:
        if fnc = "open" then do:
          assign
          frame d-all-docs:title = "Заказы на исполнение ВСЕ " .
          assign
           filter-point = "Заказы на исполнение".
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
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
                              "FOR EACH t-doc"
      parameter-4-38 =
        (
          if (" t-doc.is-flora = yes  " + " " + where-phrase-38) <> ""
          then  't-doc.is-flora = yes'   + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
          (" t-doc.is-flora = yes  " + " " + where-phrase-38 = "")
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
    open query br-docs for each t-doc  use-index obj-date
      where  t-doc.is-flora = yes
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer t-doc:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  't-doc.is-flora = yes'   + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(t-doc)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer t-doc:handle)
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
      parameter-3-38 =  "FOR EACH t-doc"
      parameter-4-38 =
        (
          if (" t-doc.is-flora = yes  " + " " + where-phrase-38) <> ""
          then  't-doc.is-flora = yes'   + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
        end.
      end.
      when 'is-flor':U + 'объект':U then do:
        if fnc = "open" then do:
          assign
            frame d-all-docs:title = "Заказы на исполнение  по " + v-cntxt-obj-type + " " + string (v-cntxt-obj-code)
            objects = 2
            .
          assign
            filter-point = list-mode.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
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
                              "FOR EACH t-doc"
      parameter-4-40 =
        (
          if ("t-doc.is-flora = yes
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
                       and t-doc.status_ <> 'готов'
                       and t-doc.status_ <> 'отказ'  " + " " + where-phrase-40) <> ""
          then              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ <> &1&4&1               and t-doc.status_ <> &1&5&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,'готов':U ,'отказ':U )                  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
          ("t-doc.is-flora = yes
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
                       and t-doc.status_ <> 'готов'
                       and t-doc.status_ <> 'отказ'  " + " " + where-phrase-40 = "")
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
    open query br-docs for each t-doc  use-index obj-date
      where t-doc.is-flora = yes
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
                       and t-doc.status_ <> 'готов'
                       and t-doc.status_ <> 'отказ'
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer t-doc:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ <> &1&4&1               and t-doc.status_ <> &1&5&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,'готов':U ,'отказ':U )                  + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(t-doc)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer t-doc:handle)
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
      parameter-3-40 =  "FOR EACH t-doc"
      parameter-4-40 =
        (
          if ("t-doc.is-flora = yes
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
                       and t-doc.status_ <> 'готов'
                       and t-doc.status_ <> 'отказ'  " + " " + where-phrase-40) <> ""
          then              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ <> &1&4&1               and t-doc.status_ <> &1&5&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,'готов':U ,'отказ':U )                  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
        end.
      end.
      when 'is-flor':U + 'статус':U then do:
        if fnc = "open" then do:
          assign
            frame d-all-docs:title = "Заказы на исполнение  по " + v-cntxt-obj-type + " " + string (v-cntxt-obj-code) + "  Статус : " + g#stat
            objects = 2
            .
          assign
            filter-point = list-mode.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
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
                              "FOR EACH t-doc"
      parameter-4-42 =
        (
          if ("t-doc.is-flora = yes
                       and t-doc.status_ = g#stat
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code  " + " " + where-phrase-42) <> ""
          then              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ = &1&4&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,  g#stat )                  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
          ("t-doc.is-flora = yes
                       and t-doc.status_ = g#stat
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code  " + " " + where-phrase-42 = "")
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
    open query br-docs for each t-doc  use-index obj-date
      where t-doc.is-flora = yes
                       and t-doc.status_ = g#stat
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( t-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer t-doc:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ = &1&4&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,  g#stat )                  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(t-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer t-doc:handle)
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
      parameter-3-42 =  "FOR EACH t-doc"
      parameter-4-42 =
        (
          if ("t-doc.is-flora = yes
                       and t-doc.status_ = g#stat
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code  " + " " + where-phrase-42) <> ""
          then              substitute('                    t-doc.is-flora = yes               and t-doc.obj-type = &1&2&1               and t-doc.obj-code = &3                  and t-doc.status_ = &1&4&1                ', chr(34), v-cntxt-obj-type , v-cntxt-obj-code ,  g#stat )                  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + " " +
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
        end.
      end.
      otherwise do:
        message "ошибка!" list-mode  view-as alert-box error .
      end.
    end case.
if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.
end procedure.
PROCEDURE enb-1 :
define  input param fnc as char no-undo.
  if fnc = "open" then do:
      enable b-chg b-del b-add b-close-new b-open  WITH FRAME d-all-docs.
  end.
end procedure.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'' @ sch-objtype
'' @ sch-objcode
'' @ sch-sum
'' @ sch-order
with frame d-all-docs.
assign
pardoc-code = chr(34) + pardoc-code + chr(34).
run OpenBr in this-procedure
  (input false
  ,input par-next
  ,input substitute("and t-doc.doc-code   begins &1 ", pardoc-code)
  ,input "open"
  ).
apply "entry":u to sch-code in frame d-all-docs .
end procedure.
procedure proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define input parameter parwhat-date as character no-undo.
define variable var-datechr as character no-undo.
display
'':u @ sch-code
'':u @ sch-objcode
'':u @ sch-objtype
'':u @ sch-sum
'':u @ sch-order
with frame d-all-docs.
assign
var-datechr = string(day(par-date)) + chr(47) +
               string(month(par-date)) + chr(47) +
              string(year(par-date)).
case parwhat-date:
  when "doc-date":u then do:
    display
    "  /  /":u @ sch-fact
    with frame d-all-docs.
    run openbr in this-procedure
    (input false
    ,input true
    ,input substitute("and t-doc.doc-date = &1 "
      , var-datechr)
    , "open"
    ).
    apply "entry":u to sch-date in frame d-all-docs.
  end.
  when "fact-date":u then do:
    display
    "  /  /":u @ sch-date
    with frame d-all-docs.
    run openbr in this-procedure
      (input false
      ,input true
      ,input substitute("and t-doc.fact-date = &1 "
      , var-datechr)
      , "open"
      ).
    apply "entry":u to sch-fact in frame d-all-docs.
  end.
end.
end procedure.
PROCEDURE proc-find-cli :
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u  @ sch-sum
'':u  @ sch-order
with frame d-all-docs.
run OpenBr in this-procedure
  (input false
  ,input yes
  ,input substitute("and t-doc.cli-type = '&1' and t-doc.cli-code = &2", parcli-type, parcli-code)
  ,input "open"
  ) no-error .
apply "entry":u to sch-objtype in frame d-all-docs .
end procedure.
PROCEDURE proc-find-sum :
define input parameter parsum as decimal no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u @ sch-objtype
'':u @ sch-objcode
with frame d-all-docs.
run OpenBr in this-procedure
  (input false
  ,input yes
  ,input substitute("and (t-doc.print-rubl = yes and round(t-doc.tot-sale, 2) = &1 or t-doc.print-rubl = no and round(t-doc.tot-fact, 2) = &1)", parsum)
  ,input "open"
  ).
apply "entry":u to sch-sum in frame d-all-docs .
end procedure.
procedure proc-find-order :
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define variable v-recid     as recid     no-undo .
define variable var-datechr as character no-undo .
var-datechr = string(day(par-date)) + chr(47) +
              string(month(par-date)) + chr(47) +
              string(year(par-date)).
display
'':u @ sch-code
'':u @ sch-objcode
'':u @ sch-objtype
'':u @ sch-sum
'':u @ sch-date
'':u @ sch-fact
with frame d-all-docs.
    run openbr in this-procedure
      (input false
      ,input true
      ,input substitute(" and t-doc.flora-order-date = &1 "
      , var-datechr)
      , "open"
      ).
    apply "entry":u to sch-order in frame d-all-docs.
end procedure.
PROCEDURE set-filter-name :
  define input parameter p-filter-name as character no-undo .
  do with frame d-all-docs:
    if p-filter-name > "" then do:
      assign
        frame d-all-docs:title
          = frame d-all-docs:title + "   ФИЛЬТР: " + p-filter-name.
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
procedure local-add:
define buffer bf_clients for ub.clients.
define buffer bf_sysconf for ub.sysconf.
define variable varis-active as logical no-undo.
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
      return error  .
    end.
end.
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
if not v-log then return error.
  if g#stat = ? then do:
    if (v-cntxt-db-num-obj = v-cntxt-db-num) or
       not (v-cntxt-db-num-obj <> 0) then do:
      assign
        g#stat = 'запрос':U.
    end.
    else do:
      assign
        g#stat = 'запрос':U.
    end.
  end.
  if g#stat = 'запрос':U then do:
    v-log = yes.
    message "Внимание !  Создаю новый ЗАПРОС !" skip (2)
                    "Продолжать ?" view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then return no-apply.
    run str/out-doc.w (
         input         parparentproc
       , input-output  pardoc-rec
       , input         'ДОБАВЛЕНИЕ':U
       , input         list-mode
       , input         'рас':U
       , input         false
       , input-output next-prev
       , input        'ee':U
       , input        false
       , input-output line-rec
       , input (br-docs:handle in frame d-all-docs)
       , input (buffer t-doc :handle in frame d-all-docs )
       , input        g#stat
       ).
  end.
  else do:
    message "Добавление нового документа не работает в этом списке" view-as alert-box information .
    return no-apply.
  end.
if doc-rec = ? then do:
  return error.
end.
run UI-on ("open").
end procedure.
procedure proc-b-del :
do on error undo, return error return-value :
define variable del-rec          as recid     no-undo.
define variable unrv-qnty        as decimal   no-undo.
define variable varmes           as character no-undo.
define variable v-user-action    as character no-undo.
define variable v-printed        as logical   no-undo.
define variable varchip-num-main as integer   no-undo.
define variable varchip-num      as integer   no-undo.
define buffer bf-acp_trn-doc for ub.trn-doc.
define buffer bf-pri_trn-doc for ub.trn-doc.
define buffer bf-vzv_trn-doc for ub.trn-doc.
define buffer bf_clients     for ub.clients.
define buffer bf-c_clients   for ub.clients.
define variable vardel-rec as recid no-undo.
define variable vardel-doc-code like ub.trn-doc.doc-code no-undo.
if not available t-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (t-doc). pardoc-rec = recid (t-doc). do on stop undo, return no-apply :   find t-doc where recid (t-doc) = doc-rec exclusive.   end. if t-doc.status_      = 'нередакт':U        or          t-doc.status_      = 'прво':U                 then do:    find t-doc where recid (t-doc) = doc-rec no-lock.    message "Данный документ не может быть удален.".    return no-apply. end.
if can-do ('накл,запрос':U, t-doc.status_) and t-doc.flag_ then do:
    v-log = no.
    message "Редактирование документа уже закончено. Вы уверены, что хотите удалить его?"
                    view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then do:   find t-doc where recid (t-doc) = doc-rec no-lock.   return no-apply. end.
end.
else do:
  if t-doc.status_ = 'факт':U then do:
    assign
    v-log = no.
    message "Документ закрыт на 'ФАКТ'." skip
            "Удаление документа повлечет за собой пересчет данных, связанных с данным документом."
            "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then do:   find t-doc where recid (t-doc) = doc-rec no-lock.   return no-apply. end.
  end.
  else do:
    assign
    v-log = no.
    message "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then do:   find t-doc where recid (t-doc) = doc-rec no-lock.   return no-apply. end.
  end.
end.
br-handle = br-docs:handle in frame d-all-docs .
assign
  vardel-rec = recid (t-doc).
if valid-handle (br-handle) then do:
  v-log = br-handle:select-next-row().
  if not v-log then v-log = br-handle:select-prev-row().
  assign
    doc-rec    = recid(t-doc)
    pardoc-rec = recid(t-doc)
  .
end.
if search ("del-doc.err") <> ? then do:
  os-delete "del-doc.err".
end.
assign
  varchip-num-main = next-value (s-corr-chip, ub).
find first t-doc where recid(t-doc) = vardel-rec.
define buffer bufd_doc-line for ub.doc-line  .
define buffer bufd_gds-dtl  for ub.gds-dtl   .
if t-doc.ext-doc-type = 'ee':U and
   t-doc.status_      = 'накл':U            and
   t-doc.flag_        = false           then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_delnabor in g#lib-trn3
( input parParentProc ,
  input t-doc.doc-code
) no-error
.
end.
assign
  vardel-doc-code = t-doc.doc-code.
if t-doc.ext-doc-type = 'ev':U and
   t-doc.status_      = 'факт':U            then do:
  find first bf_clients where bf_clients.obj-type = t-doc.obj-type and
                              bf_clients.obj-code = t-doc.obj-code no-lock.
  find first bf-c_clients where bf-c_clients.obj-type = t-doc.cli-type and
                                bf-c_clients.obj-code = t-doc.cli-code no-lock.
  if bf_clients.db-num <> bf-c_clients.db-num then do:
    message substitute("Во внутреннем документе &1 по объекту &2 &3 базы данных &4 контрагентом является объект &5 &6 базы данных &7. Нельзя удалять внутренние документы относящиеся к разным базам данных.",
                            t-doc.doc-code,
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_clients.db-num,
                            t-doc.cli-type,
                            t-doc.cli-code,
                            bf-c_clients.db-num
                            ) view-as alert-box error.
    return error.
  end.
  find first bf-pri_trn-doc where bf-pri_trn-doc.out-code     = t-doc.doc-code     and
                                  bf-pri_trn-doc.ext-doc-type = 'iv':U exclusive-lock.
  if bf-pri_trn-doc.status_ = 'факт':U then do:
    find first bf-vzv_trn-doc where bf-vzv_trn-doc.out-code     = bf-pri_trn-doc.doc-code and
                                    bf-vzv_trn-doc.ext-doc-type = 'rv':U  exclusive-lock no-error.
    if available bf-vzv_trn-doc then do:
      if bf-vzv_trn-doc.status_ = 'факт':U then do:
        run str/del-doc.p
          ( input parParentProc,
            input bf-vzv_trn-doc.doc-code,
            input v-cntxt-db-num,
            input "del-doc.err",
            input ?,
            input ?,
            input v-cntxt-userid,
            input 0,
            input  varchip-num-main,
            output varchip-num )
          no-error.
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа возврата." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            view-as alert-box error.
          if search ("del-doc.err") <> ? then do:
            run gbl/prnfilen.w
              (input  "Ошибки при удалении документа"
              ,input  0
              ,input  "del-doc.err"
              ,input  7
              ,output v-user-action
              ,output v-printed
              ).
          end.
          return error.
        end.
      end.
      else do:
        message "Имеется открытый документ внутреннего возврата по данному внутреннему расходу." skip
                "Номер документа: " bf-vzv_trn-doc.doc-code skip
        view-as alert-box error.
        return error.
      end.
    end.
    run str/del-doc.p
      ( input parParentProc,
        input  bf-pri_trn-doc.doc-code,
        input  v-cntxt-db-num,
        input  "del-doc.err",
        input  ?,
        input  ?,
        input  v-cntxt-userid,
        input  0,
        input  varchip-num-main,
        output varchip-num )
      no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении документа прихода." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        view-as alert-box error.
      if search ("del-doc.err") <> ? then do:
        run gbl/prnfilen.w
          (input  "Ошибки при удалении документа"
          ,input  0
          ,input  "del-doc.err"
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
      return error.
    end.
  end.
  else do:
    message "Имеется открытый документ внутреннего прихода по данному внутреннему расходу." skip
            "Номер документа: " bf-pri_trn-doc.doc-code skip
    view-as alert-box error.
    return error.
  end.
end.
run str/del-doc.p
  ( input parParentProc,
    input  t-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  0,
    input  varchip-num-main,
    output varchip-num )
no-error.
if error-status:error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении документа." skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  if search ("del-doc.err") <> ? then do:
    run gbl/prnfilen.w
      (input  "Ошибки при удалении документа"
      ,input  0
      ,input  "del-doc.err"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
  end.
  return error.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code         and
                                bf-acp_trn-doc.ext-doc-type = 'pc':U no-lock no-error.
if available bf-acp_trn-doc then do:
  run str/del-doc.p
  ( input parParentProc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       trim(error-status :get-message(2))
       trim(error-status :get-message(3))
       trim(error-status :get-message(4))
       trim(error-status :get-message(5)) skip
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input 7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code           and
                                bf-acp_trn-doc.ext-doc-type = 'mp':U no-lock no-error.
if available bf-acp_trn-doc then do:
  run str/del-doc.p
  ( input parParentProc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       trim(error-status :get-message(2))
       trim(error-status :get-message(3))
       trim(error-status :get-message(4))
       trim(error-status :get-message(5)) skip
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input 7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
end.
end.
end procedure.
procedure proc-b-ext :
 do
 on error undo, return error return-value
 :
    define variable v-list-index     as integer           no-undo.
    define variable v-trn-doc-recid  as recid             no-undo.
    for each temp_recid-list
    :
        delete temp_recid-list.
    end.
    if available t-doc
    then do:
        assign
            v-trn-doc-recid = recid( t-doc )
            v-nn = num-entries( mark-list )
        .
        do v-list-index = 1 to v-nn :
            create temp_recid-list .
            assign
                temp_recid-list.string-trn-doc-recid = entry( v-list-index, mark-list )
            .
        end.
    end.
    else do:
        assign
            v-trn-doc-recid = 0
        .
    end.
    run str/run-ext.p ( input v-trn-doc-recid
                  , input table temp_recid-list
                  , input 'документы':U
                  , input ""
                  , output v-ext-button-label
                  ) no-error.
    if error-status :error
    then do:
        return error .
    end.
 end.
end procedure.
procedure proc-b-chg :
define variable varrecid as recid no-undo.
 do
 on error undo, return error return-value
 :
if not available t-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (t-doc). pardoc-rec = recid (t-doc). do on stop undo, return no-apply :   find t-doc where recid (t-doc) = doc-rec exclusive.   end. if t-doc.status_      = 'факт':U                     or          t-doc.status_      = 'готов':U                    or          t-doc.status_      = 'отказ':U                 or          t-doc.status_      = 'нередакт':U                or          t-doc.status_      = 'прво':U                         then do:    find t-doc where recid (t-doc) = doc-rec no-lock.    message "Данный документ закрыт по факту или не может быть обработан в этом списке.".    return no-apply. end.
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
if not v-log then do:   find t-doc where recid (t-doc) = doc-rec no-lock.   return no-apply. end.
if t-doc.status_ = 'запрос':U then do:
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)).
  assign
    varrecid = recid(t-doc).
  run str/out-doc.w (
         input         parparentproc
       , input-output  varrecid
       , input         'ИЗМЕНЕНИЕ':U
       , input         list-mode
       , input         'рас':U
       , input         false
       , input-output  next-prev
       , input         'ee':U
       , input         false
       , input-output  line-rec
       , input         br-handle
       , input (buffer t-doc :handle in frame d-all-docs )
       , input         t-doc.status_
       ).
end.
else
run str/out-docf.w (
      input parParentProc ,
      input 'ИЗМЕНЕНИЕ':U ,
      input t-doc.status_ ,
      input (br-docs:handle in frame d-all-docs) ,
      input (buffer t-doc :handle in frame d-all-docs )
      ).
apply "entry" to br-docs in frame d-all-docs.
if error-status:error then do:
  find t-doc where recid (t-doc) = doc-rec no-lock.
  return error.
end.
else run UI-on ("open").
 end.
end procedure.
procedure proc-b-akt :
 do
 on error undo, return error return-value
 :
next-prev = no.
br-handle = br-docs:handle in frame d-all-docs .
do while next-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_lookup':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
  if not v-log then return no-apply.
  assign
    doc-rec = recid (t-doc)
    pardoc-rec = recid (t-doc)
  .
  bf-handle = buffer t-doc:handle in frame d-all-docs .
   run str/trn-pr.w
     (input parparentproc ,
      input recid(t-doc) ,
      input 'ПРОСМОТР':U ,
      input-output next-prev ,
      input ? ,
      input ? ,
      input ? ,
      input br-handle ,
      input bf-handle)
      no-error .
end.
if br-handle = ? then reposition br-docs to recid doc-rec no-error.
apply "entry" to br-docs in frame d-all-docs.
apply "iteration-changed" to br-docs in frame d-all-docs.
 end.
end procedure.
procedure proc-b-lkp :
 do
 on error undo, return error return-value
 :
next-prev = no.
br-handle = br-docs:handle  in frame d-all-docs .
do while next-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
  if not v-log then
    return error.
    assign
      doc-rec    = recid (t-doc)
      pardoc-rec = recid (t-doc)
    .
    if t-doc.status_ = 'запрос':U then
            run str/out-doc.w  (
                input         parparentproc
              , input-output  doc-rec
              , input         'ПРОСМОТР':U
              , input         list-mode
              , input         'рас':U
              , input         false
              , input-output  next-prev
              , input         'ee':U
              , input         false
              , input-output  line-rec
              , input (br-docs:handle in frame d-all-docs)
              , input (buffer t-doc :handle in frame d-all-docs )
              , input         t-doc.status_
              ).
    else    run str/out-docf.w
                  ( input parParentProc ,
                    input 'ПРОСМОТР':U ,
                    input t-doc.status_ ,
                    input (br-docs:handle in frame d-all-docs) ,
                    input (buffer t-doc:handle in frame d-all-docs )
                    ) .
end.
if br-handle = ? then reposition br-docs to recid doc-rec no-error.
apply "entry" to br-docs in frame d-all-docs.
apply "iteration-changed" to br-docs in frame d-all-docs.
 end.
end procedure.
procedure proc-b-print :
 do
 on error undo, return error return-value
 :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
assign
  pardoc-rec = recid (t-doc)
  doc-rec    = recid (t-doc)
.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_print':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
if not v-log then return no-apply.
find t-doc where recid (t-doc) = doc-rec .
run rep/doc-prn.p (
      input parParentProc
    , input this-procedure
    , input doc-rec
).
apply "entry" to br-docs in frame d-all-docs.
 end.
end procedure.
procedure local-export :
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
run str/xml-doc.p (input t-doc.doc-code, input ?) no-error .
if error-status :error
then do:
  if error-status :get-message(1) <> ""
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы xml-doc.p" skip
      error-status :get-message(1) skip
      return-value
      view-as alert-box error .
  end.
  else do:
    message
      return-value
      view-as alert-box information .
  end.
  return no-apply .
end.
define variable v-sys-key   as character         no-undo.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
assign
v-file-name =  str-encode ( replace(t-doc.doc-code , "*", "$")
                          , ""
                          , '\/:*?"<>|':U
                          ) + ".xml".
if search ("xml-doc.bat") <> ? then do:
  os-command silent value(search ("xml-doc.bat") + chr(32) + chr(34) +  v-file-name + chr(34) + chr(32) + v-sys-key + chr(32) + v-cntxt-userid ).
end.
else do:
  if search (v-file-name ) <> ? then do:
    message
    substitute("Документ выгружен в файл &1"
               ,v-file-name
               )
    view-as alert-box.
  end.
end.
end procedure.
procedure entry-notes :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
assign
  pardoc-rec = recid (t-doc)
  doc-rec    = recid (t-doc)
.
if t-doc.status_ <> 'факт':U and t-doc.discnt-type <> 'касс':U and substring (t-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
end.
procedure local-notes:
do on stop undo, return no-apply:
  find t-d-b where recid (t-d-b) = doc-rec exclusive no-error no-wait.
  if not available t-d-b then do:
     message "Запись захвачена другим пользователем." skip
             "Редактирование запрещено."
     view-as alert-box.
  end.
  else t-d-b.PS = input frame d-all-docs ed-notes.
end.
end procedure.
procedure local-value-changed :
if available t-doc then do:
  find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = t-doc.boss no-lock no-error.
  if available cli-buf then boss-name = cli-buf.obj-name. else boss-name = ?.
  find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = t-doc.agnt no-lock no-error.
  if available cli-buf then agnt-name = cli-buf.obj-name. else agnt-name = ?.
  find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = t-doc.wrkr no-lock no-error.
  if available cli-buf then wrkr-name = cli-buf.obj-name. else wrkr-name = ?.
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  t-doc.creid
  ,output v-user-name
  )  .
  find ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock no-error.
  if available ub.pay-type then disp ub.pay-type.obj-name with frame d-all-docs.
  else disp ? @ ub.pay-type.obj-name with frame d-all-docs.
  ed-notes = t-doc.PS.
  find cli-buf where cli-buf.obj-type = t-doc.obj-type and cli-buf.obj-code = t-doc.obj-code no-lock no-error.
  if available cli-buf then obj-name = cli-buf.obj-name. else obj-name = ?.
  display ed-notes obj-name boss-name agnt-name wrkr-name v-user-name with frame d-all-docs.
  if doc-rec <> recid (t-doc) then do:
    sch-num = 0.
    hide sch-num in frame d-all-docs.
  end.
end.
end procedure.
procedure local-sel :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
if mark-list <> "" then do:
  assign
    pardoc-rec = recid (t-doc)
    doc-rec = recid (t-doc)
  .
end.
else do:
  assign
    mark-list = string(recid(t-doc))
    pardoc-rec = recid (t-doc)
    doc-rec = recid (t-doc)
    .
end.
apply "go" to frame d-all-docs.
end procedure.
procedure local-conf-rd:
define buffer bf_clients for ub.clients.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varhold
  ,output varhold-type
  ) no-error .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
if v-cntxt-obj-type <> "" and
   v-cntxt-obj-code <> 0  then do:
  find first bf_clients where bf_clients.obj-type = v-cntxt-obj-type and
                              bf_clients.obj-code = v-cntxt-obj-code no-lock.
  if bf_clients.obj-type = 'маг':U then do:
    find first bf_shop where bf_shop.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_shop.shift-on).
  end.
  else do:
    find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_store.shift-on).
  end.
end.
else do:
  assign
    v_shift = "no":u.
end.
end procedure.
procedure local-enable :
ENABLE
b-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
b-quit b-lkp b-print b-exp b-sch b-help br-docs b-rep sch-code sch-date sch-order sch-fact sch-objtype sch-objcode sch-sum ed-notes
WITH FRAME d-all-docs.
hide b-akt in frame d-all-docs .
if v-cntxt-obj-type = 'скл':U or v-cntxt-obj-type = 'маг':U  then do:
  enable b-bc WITH FRAME d-all-docs.
end.
run str/run-ext.p ( input ?
                , input table temp_recid-list
                , input 'документы':U
                , input "init"
                , output v-ext-button-label
                ) no-error.
if error-status :error
then do:
    assign
        b-ext :visible   = no
    .
end.
else do:
    assign
        b-ext :label     = v-ext-button-label
        b-ext :visible   = yes
        b-ext :sensitive = yes
    .
end.
end procedure.
procedure proc-close :
  do
  on error undo, return error return-value
  :
  define variable v-close-type as integer   no-undo .
  define variable varchg-inv as logical   no-undo .
            run gbl/d-askw.w
              (input "Вопрос"
              ,input "Закрытие запроса на исполнение" + chr(10)
                + substitute("РН        &1", t-doc.doc-code) + chr(10)
                + substitute("Дата      &1", string(t-doc.doc-date, '99/99/9999':u)) + chr(10)
                + (if t-doc.fact-date <> ? then substitute("Факт дата &1", string(t-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
                + substitute("Оператор  &1", t-doc.user-name)
              ,input "|^"
              ,input "Разр+" + '|':u
                  + "Факт+" + '|':u
                  + "Отмена"
              ,input "Возможно открыть заказ на корректировку до накл- и изменить фактическое количество в разр+|"
                  + "Закрыть заказ без возможности корректировки |"
                  + "Отмена закрытия заказа на исполнение"
              ,input 1
              ,input 3
              ,output v-close-type
              ).
            case v-close-type
            :
              when 1
              then do:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
                    br-docs:refresh() in frame d-all-docs.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
                    if t-doc.status_ = 'накл':U and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  '<закрытие документа>':U,
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             br-docs:refresh() in frame d-all-docs.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
              end.
              when 2
              then do:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_fact':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
                    if t-doc.status_ = 'накл':U and t-doc.flag_ = false then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
                        br-docs:refresh() in frame d-all-docs.
                        if error-status:error then do:
                          find t-doc where recid (t-doc) = doc-rec no-lock.
                          return error.
                        end.
                    end.
                    if t-doc.status_ = 'накл':U and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  '<закрытие документа>':U,
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             br-docs:refresh() in frame d-all-docs.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
                    if t-doc.status_ = 'разрешен':U then do:
                            run str/trn-stat.p (input parParentProc,
                            input this-procedure ,
                                            input  '<закрытие документа>':U,
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             br-docs:refresh() in frame d-all-docs.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
              end.
              when 3
              then do:
                if doc-rec <> ? then do:
                  find t-doc where recid (t-doc) = doc-rec no-lock.
                end.
                return error.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Способ закрытия накладной" skip
                  "Неизвестное значение" v-close-type skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
    if varchg-inv = yes then do:
      assign v-log = no.
      message "За время пребывания в статусе разр- было движение товаров, участвующих в инвентаризации." SKIP
      "Показать список товаров по которым было движение?"
        view-as alert-box question buttons yes-no update v-log .
      if v-log then run str/gds-list.w (input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
     end.
end.
end procedure.
procedure proc-close-zapr :
  do
  on error undo, return error return-value
  :
  define variable v-close-type as integer   no-undo .
  define variable varchg-inv as logical   no-undo .
            run gbl/d-askw.w
              (input "Вопрос"
              ,input "Закрытие запроса на исполнение" + chr(10)
                + substitute("РН        &1", t-doc.doc-code) + chr(10)
                + substitute("Дата      &1", string(t-doc.doc-date, '99/99/9999':u)) + chr(10)
                + (if t-doc.fact-date <> ? then substitute("Факт дата &1", string(t-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
                + substitute("Оператор  &1", t-doc.user-name)
              ,input "|^"
              ,input "Запр+" + '|':u
                  + "Накл-" + '|':u
                  + "Отмена"
              ,input "Возможно открыть заказ на корректировку |"
                  + "Передать заказ флористам |"
                  + "Отмена закрытия заказа на исполнение"
              ,input 1
              ,input 3
              ,output v-close-type
              ).
            case v-close-type
            :
            when 1 then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
                    br-docs:refresh() in frame d-all-docs.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
            end.
            when 2 then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  t-doc.doc-code
  ,output table gds-list
  ) no-error .
                    br-docs:refresh() in frame d-all-docs.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
                    if t-doc.status_ = 'запрос':U and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  '<закрытие документа>':U,
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             br-docs:refresh() in frame d-all-docs.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
            end.
            end case.
  end.
end procedure.
procedure get-browse-buffer-handle :
define output parameter p-browse-buffer-handle      as handle           no-undo.
do
on error undo, return error
:
    assign
        p-browse-buffer-handle = buffer t-doc :handle in frame d-all-docs
    .
end.
end procedure.
procedure get-browse-query-handle :
define output parameter p-browse-query-handle      as handle           no-undo.
do
on error undo, return error
:
    assign
        p-browse-query-handle = query br-docs :handle in frame d-all-docs
    .
end.
end procedure.
