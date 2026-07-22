block-level on error undo, throw.
define input  parameter parparentproc  as handle    no-undo.
define input  parameter parworkmode    as character no-undo .
define input  parameter parinformation as character no-undo .
define input  parameter add-sens       as logical   no-undo .
define output parameter is-err         as logical   initial no no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE OUTPUT PARAMETER TABLE FOR in-bc.
DEFINE  SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE  SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE  SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer gds-bar-code   for ub.bar-code.
define buffer prt-bar-code   for ub.bar-code.
define buffer main-bar-code  for ub.bar-code.
define buffer gds-anlz-bc    for anlz-bc.
define buffer prt-anlz-bc    for anlz-bc.
define buffer parts-bc       for ub.parts.
define buffer gds-prt-parent for ub.gds-prt.
define buffer last-un-bc     for un-bc.
define buffer last-anlz-bc   for anlz-bc.
define buffer units-base     for ub.units.
define buffer bar-code-base  for ub.bar-code.
define buffer gds-prt-base   for ub.gds-prt.
define buffer buf_chk-doc    for ub.chk-doc.
define buffer bar-code for ub.bar-code.
define buffer goods    for ub.goods   .
define buffer units    for ub.units   .
define variable bar-str     as character no-undo.
define variable pl-str      as character no-undo.
define variable qnty-str    as character no-undo.
define variable part-list   as character no-undo init "".
define variable b-c         as integer   no-undo.
define variable rate        as decimal   no-undo.
define variable discnt      as decimal   no-undo.
define variable flagplace   as logical   no-undo.
define variable conf-par    as character no-undo.
define variable par-type    as character no-undo.
define variable i-num       as integer   no-undo.
define variable u-num       as integer   no-undo.
define variable a-num       as integer   no-undo.
define variable varentity   as character no-undo.
define variable varzero-string as logical no-undo.
define stream scan-file.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type6 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type6
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type6 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type6
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
def var mess as char no-undo.
procedure check-code:
define input parameter parbar-str AS char no-undo.
define input parameter parprice   like ub.gds-dtl.price-base no-undo.
define input parameter parqnty    as dec no-undo.
define input  parameter parg#doc-prt as logical no-undo.
define input  parameter parscales-pref as character no-undo.
define input  parameter parpgscales-pref as character no-undo.
define output parameter parplace   as log initial no no-undo.
define output parameter parb-c     as int no-undo.
define output parameter parrate    as dec no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
def buffer b-bar-code for ub.bar-code.
ASSIGN mess = " Код: " + parbar-str + " количество: " + string (parqnty) + " ".
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  parbar-str
,input  parprice
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  parscales-pref
,input  parpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + parbar-str.
end.
  assign
    un-bc.type-bc = vartype-bc.
  if varresult = "place" then do:
    assign
      un-bc.pl-name = place.pl-name
      un-bc.loc1    = place.loc1
      un-bc.loc2    = place.loc2
      un-bc.loc3    = place.loc3
      un-bc.loc4    = place.loc4 .
  end.
if not available bar-code THEN DO:
   if add-sens = ? and available place
   then DO: parPlace = YES. RETURN. END.
   ELSE RETURN ERROR "Товар отсутствует в базе данных.".
END.
else do:
    assign  parb-c  = bar-code.b-code
            parrate = bar-code.cli-base-rate.
    find ub.goods where ub.goods.gds-code  = ub.bar-code.gds-code no-lock.
       FIND FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK.
       FIND FIRST ub.clients WHERE ub.clients.obj-type = ub.goods.prod-type AND
                                ub.clients.obj-code = ub.goods.prod-code  NO-LOCK.
       ASSIGN un-bc.artic      = ub.goods.artic
              un-bc.prod-type  = ub.goods.prod-type
              un-bc.prod-code  = ub.goods.prod-code
              un-bc.prod-name  = ub.clients.obj-name
              un-bc.gds-name   = ub.goods.gds-name
              un-bc.unit-base  = ub.goods.unit-base
              un-bc.units-type = ub.units.type.
    find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
    ASSIGN mess = mess + "Артикул: " + ub.goods.artic + " производитель: " + ub.goods.prod-type + " " + string (ub.goods.prod-code) + " " + ub.goods.gds-name + chr(10) .
    if parg#doc-prt and gds-prt.node-name <> '_Пустая шкала':U and
       can-find (first gds-prt where gds-prt.upper-code = bar-code.node-code) then
       RETURN ERROR "Ссылка не на подробный признак.".
    if not parg#doc-prt and gds-prt.node-name <> '_Пустая шкала':U and
         bar-code.node-code <> gds-prt.node-code then do:
      find b-bar-code where recid (b-bar-code) = recid (bar-code) no-lock.
      find bar-code where bar-code.gds-code  = b-bar-code.gds-code
                      and bar-code.node-code = gds-prt.node-code
                      and bar-code.in-code   = b-bar-code.in-code
                      and bar-code.part-code = b-bar-code.part-code
                      and bar-code.unit-cli  = ub.goods.unit-base
                        no-lock.
      parb-c = bar-code.b-code.
      RETURN "Ссылка на подробный или узловой признак. Заменяем на код: " + STRING(bar-code.b-code).
    end.
end.
RETURN.
END PROCEDURE.
run delete-in-bc.
if parworkmode = "code-add" or
   parworkmode = "code-update"
   then do:
   create   in-bc.
   assign   in-bc.bar-str = parinformation
            in-bc.nm      = 1.
   validate in-bc.
end.
if parworkmode = "chk-doc"
then do:
   run waitfram-show in this-procedure ("Разбор строк чека.").
end.
else do:
  run waitfram-show in this-procedure ("Разбор сканерного файла.").
end.
if parworkmode = "table" then do:
   run loadTempTable in this-procedure no-error.
   if error-status:error then
   do:
      message return-value view-as alert-box error buttons ok.
        run waitfram-hide in this-procedure.
      return error.
   end.
end.
if parworkmode = "file" then do:
   if search(parinformation) = ? then do:
      message "Не найден файл: " parinformation " с бар-кодами для анализа."
      view-as alert-box error buttons ok.
      run waitfram-hide in this-procedure.
      return error.
   end.
   run gbl/filnline.p (input parinformation, output varzero-string).
   if varzero-string <> true then do:
     message return-value skip
             "Файл " search(parinformation) view-as alert-box.
     return error.
   end.
   run loadnewfile in this-procedure.
end.
if parworkmode = "chk-doc"
then do:
  find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = entry(1, parinformation) no-error.
  if not available buf_chk-doc then do:
      message "Не найден чек: " parinformation " с бар-кодами для анализа."
      view-as alert-box error buttons ok.
      run waitfram-hide in this-procedure.
      return error.
   end.
   for each un-bc:
     assign un-bc.file-qnty = 0.
   end.
   run loadnewcheck in this-procedure.
end.
i-num = 0.
if parworkmode <> "undo" then do:
   if parworkmode = "chk-doc"then do:
   end.
   else do:
     for each un-bc:
        assign un-bc.file-qnty = 0.
     end.
   end.
   for each in-bc where in-bc.bar-str <> "":U
   :
      run unitedcode.
   end.
   if parworkmode = "code-update" then do:
      find last in-bc.
      find first un-bc where un-bc.bar-code = in-bc.bar-code no-error.
      if available un-bc then run add-un-bc.
   end.
   else
   for each un-bc where un-bc.file-qnty > 0 use-index file-qnty by un-bc.nm:
       run add-un-bc.
   end.
   for each anlz-bc:
    find first bar-code     where bar-code.b-code         = anlz-bc.b-c       no-lock.
    find first goods        where goods.gds-code          = bar-code.gds-code no-lock.
    find first units        where units.unit-name         = bar-code.unit-cli no-lock.
    find first units-base   where units-base.unit-name    = goods.unit-base   no-lock.
    find first gds-prt-base where gds-prt-base.upper-code = goods.prt-root    no-lock.
    find first bar-code-base where bar-code-base.gds-code  = goods.gds-code         and
                                   bar-code-base.node-code = gds-prt-base.node-code and
                                   bar-code-base.part-code = ""                     and
                                   bar-code-base.in-code   = ""                     and
                                   bar-code-base.unit-cli  = goods.unit-base        no-lock.
    find first main-bar-code where main-bar-code.gds-code  = bar-code.gds-code  and
                                   main-bar-code.node-code = bar-code.node-code and
                                   main-bar-code.part-code = ""                 and
                                   main-bar-code.in-code   = ""                 and
                                   main-bar-code.unit-cli  = goods.unit-base    no-lock.
    find gds-prt where gds-prt.node-code = bar-code.node-code no-lock.
    if not can-find(first gds-prt-parent where gds-prt-parent.node-code = gds-prt.upper-code no-lock) then
       assign varentity = 'ТОВАР':U.
    else assign varentity = 'ПРИЗНАК':U.
    if bar-code.in-code <> "" then do:
       find first parts-bc where parts-bc.artic     = goods.artic
                             and parts-bc.prod-type = goods.prod-type
                             and parts-bc.prod-code = goods.prod-code
                             and parts-bc.in-code   = bar-code.in-code
                             and parts-bc.part-code = bar-code.part-code no-lock no-error.
    end.
    if available parts-bc then assign varentity = 'ПАРТИЯ':U.
    for each un-bc where un-bc.b-c = anlz-bc.b-c:
        if un-bc.entity <> 'СКЛАДСКОЕ МЕСТО':U then un-bc.entity = varentity.
         assign un-bc.f-name         = gds-prt.f-name
                un-bc.in-code        = if available parts-bc then parts-bc.in-code   else ?
                un-bc.fact-date      = if available parts-bc then parts-bc.fact-date else ?
                un-bc.part-code      = if available parts-bc then parts-bc.part-code else ?
                un-bc.unit-name      = units.unit-name
                un-bc.long-name      = units.long-name
                un-bc.b-c-base       = bar-code-base.b-code
                un-bc.unit-name-base = units-base.unit-name
                un-bc.long-name-base = units-base.long-name.
    end.
    find first main-bc where main-bc.b-c = main-bar-code.b-code no-error.
    if not available main-bc then do:
       create main-bc.
       assign main-bc.nm     = anlz-bc.nm
              main-bc.b-c    = main-bar-code.b-code
              main-bc.scn-pl = anlz-bc.scn-pl
              main-bc.rez    = anlz-bc.rez.
    end.
    assign main-bc.scn-qnty = main-bc.scn-qnty + anlz-bc.scn-qnty
           main-bc.des      = main-bc.des + " | " + anlz-bc.des.
   end.
end.
else run undo-qnty.
run waitfram-hide in this-procedure.
procedure read-str.
  bar-str = trim (bar-str).
  if bar-str = "" then return error.
  if substr (bar-str, 1, 1) < "0" or substr (bar-str, 1, 1) > "9" then
    if substr (bar-str, 1, 4) = "data" then bar-str = entry (2, bar-str, ":").
    else return error "Cтрока начинается не с цифры и не со слова date.".
  if num-entries (bar-str) > 1 then qnty-str = trim (entry (2, bar-str)).
  else qnty-str = "1".
  if num-entries (bar-str) > 2 then pl-str = trim (entry (3, bar-str)).
  else pl-str = "".
  bar-str = trim (entry (1, bar-str)).
end procedure.
procedure loadTempTable:
  define variable vTime   as integer   no-undo.
  define variable vWhere  as character no-undo.
  define variable hTable  as handle  no-undo.
  define variable hBuffer as handle  no-undo.
  define variable hQuery  as handle  no-undo.
  assign
    vTime = TIME
    hTable = handle(parinformation)
    vWhere = substitute("FOR EACH &1", hTable:name)
  no-error.
  if error-status:error or not valid-handle(hTable) then
    return error "Ошибка при чтении таблицы строк документа".
  create buffer hBuffer for table hTable.
  create query  hQuery.
  hQuery:set-buffers(hBuffer).
  hQuery:query-prepare(vWhere).
  hQuery:query-open().
  hQuery:get-first().
  repeat while not hQuery:query-off-end:
    assign
      bar-str = ""
      i-num = i-num + 1
    .
    run waitfram-show in this-procedure (substitute("Разбор записей с бар-кодами. Всего считано &1. Время &2.", i-num, string (time - vTime, "hh:mm:ss"))).
    create in-bc.
    assign
      in-bc.nm       = i-num
      in-bc.bar-str  = substitute(
                         "&1,&2",
                         hBuffer:buffer-field("b-code"):buffer-value,
                         hBuffer:buffer-field("fact-qnty"):buffer-value)
    .
    hQuery:GET-NEXT().
  end.
  hQuery:query-close().
  delete object hQuery.
end procedure.
procedure loadnewfile:
define variable vartime as integer no-undo.
input stream scan-file from value (parinformation).
assign
  vartime = TIME.
repeat:
  assign
    bar-str = "".
  import stream scan-file unformatted bar-str.
  i-num = i-num + 1.
  run waitfram-show in this-procedure (substitute("Разбор сканерного файла. Всего считано &1. Время &2.", i-num, string (time - vartime, "hh:mm:ss"))).
  create in-bc.
  assign in-bc.nm       = i-num.
         in-bc.bar-str  = bar-str.
end.
end procedure.
procedure loadnewcheck:
define variable vartime as integer no-undo.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-doc-code as character no-undo .
define variable v-line-num as integer no-undo .
define variable qnty-dec as decimal no-undo .
define variable v-chk-gds-type-bc as character no-undo .
assign
vartime = TIME
v-doc-code = entry(1, parinformation)
v-line-num = (if num-entries(parinformation) > 1
              then integer(entry(2, parinformation))
              else 0)
.
for each buf_chk-gds where
        buf_chk-gds.doc-code = v-doc-code
by buf_chk-gds.doc-code
by buf_chk-gds.line-num :
  run waitfram-show in this-procedure ( substitute("Разбор чека. Всего считано &1. Время &2.", i-num, string (time - vartime, "hh:mm:ss"))).
  if buf_chk-gds.is-err = yes then do:
    if v-line-num > 0 and buf_chk-gds.line-num <> v-line-num then next.
    assign
    v-chk-gds-type-bc = if buf_chk-gds.b-code > 0
                        then 'b-code':U
                        else 'src-code':U
    bar-str = (if v-chk-gds-type-bc = 'b-code':U
                then string(buf_chk-gds.b-code)
                else buf_chk-gds.src-code )
    qnty-dec = (if v-chk-gds-type-bc = 'b-code':U
                then buf_chk-gds.src-qnty
                else buf_chk-gds.doc-qnty )
    pl-str    = '':U
    .
    find first un-bc where
             un-bc.bar-code = bar-str no-error.
    if not available un-bc
    or add-sens = ?
    or (parworkmode = "chk-doc"
        and
        un-bc.type-bc <> v-chk-gds-type-bc)
    then do:
      find last last-un-bc no-error.
      create un-bc.
      assign
      un-bc.nm       = if available last-un-bc
                       then (last-un-bc.nm + 1)
                       else 1
      un-bc.bar-code = bar-str
      un-bc.type-bc = v-chk-gds-type-bc
      .
    end.
    assign
    un-bc.file-qnty = un-bc.file-qnty + qnty-dec
    un-bc.scn-qnty  = un-bc.scn-qnty  + qnty-dec
    un-bc.scn-pl    = if un-bc.scn-pl <> ""
                      and un-bc.scn-pl <> ?
                      then un-bc.scn-pl
                      else pl-str
    .
    if buf_chk-gds.b-code > 0 then do:
      buf_chk-gds.is-err = no.
    end.
  end.
end.
end procedure.
procedure unitedcode:
bar-str = in-bc.bar-str.
run read-str no-error.
if error-status:error then do:
   assign in-bc.bar-code = ?
          in-bc.rez      = "err"
          in-bc.err-msg  = return-value.
      assign is-err = yes.
      next.
end.
find first un-bc where un-bc.bar-code = bar-str no-error.
if not available un-bc or add-sens = ? then do:
   find last last-un-bc no-error.
   create un-bc.
   assign un-bc.nm       = if available last-un-bc then last-un-bc.nm + 1 else 1
          un-bc.bar-code = bar-str.
          in-bc.des      = in-bc.des + "Код: " + bar-str + " помещен в таблицу с количеством: " + qnty-str + chr(10) .
end.
else assign in-bc.des = in-bc.des + "Код: " + bar-str + " найден в таблице. Количество: " + string(un-bc.scn-qnty) + " увеличено на: " + qnty-str + chr(10) .
assign
 un-bc.file-qnty = if parworkmode = "code-update" then un-bc.file-qnty else un-bc.file-qnty + decimal(qnty-str)
 un-bc.scn-qnty  = if parworkmode = "code-update" then un-bc.scn-qnty  else un-bc.scn-qnty  + decimal(qnty-str)
 un-bc.scn-pl    = if un-bc.scn-pl <> "" and un-bc.scn-pl <> ? then un-bc.scn-pl else pl-str
 in-bc.bar-code  = un-bc.bar-code.
return.
end procedure.
procedure delete-in-bc:
 for each in-bc:
    delete in-bc.
 end.
end.
procedure undo-qnty:
  for each un-bc:
     find first anlz-bc where anlz-bc.b-c = un-bc.b-c no-error.
     if available anlz-bc then do:
        assign anlz-bc.scn-qnty = anlz-bc.scn-qnty - un-bc.rate * un-bc.file-qnty
               anlz-bc.des      = anlz-bc.des + " Откат кол-во:" + string(un-bc.rate * un-bc.file-qnty) + ".".
        if anlz-bc.scn-qnty = 0 then delete anlz-bc.
     end.
     assign un-bc.scn-qnty = un-bc.scn-qnty - un-bc.file-qnty
            un-bc.file-qnty = 0.
     if un-bc.scn-qnty = 0 then delete un-bc.
  end.
end.
procedure add-un-bc:
define variable v-chk-gds-type-bc as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
  if parworkmode = "chk-doc" then do:
    assign
    v-chk-gds-type-bc = un-bc.type-bc
    un-bc.type-bc = '':U
    .
  end.
  run check-code in this-procedure (
                  input un-bc.bar-code
                  ,input 0
                  ,input un-bc.scn-qnty
                  ,input ?
                  ,input varscales-pref
                  ,input varpgscales-pref
                  ,output flagplace
                  ,output b-c
                  ,output rate
                  ) no-error.
 if error-status:error then do:
     assign un-bc.b-c     = ?
            un-bc.rez     = "err"
            un-bc.err-msg = mess + " " + if return-value <> "" then return-value else "Ошибка из процедуры проверки бар-кода."
            un-bc.type-bc = un-bc.type-bc + un-bc.err-msg.
        assign is-err = yes.
   if parworkmode = "chk-doc"
    and v-chk-gds-type-bc = 'b-code' then do:
      for each buf_chk-gds where
              buf_chk-gds.doc-code = entry(1, parinformation)
          and buf_chk-gds.b-code = integer(un-bc.bar-code)
      on error undo, return error:
        assign
        buf_chk-gds.is-error = yes
        .
      end.
    end.
    next.
 end.
 if parworkmode = "chk-doc"
   and v-chk-gds-type-bc = 'src-code' then do:
     for each buf_chk-gds where
            buf_chk-gds.doc-code = entry(1, parinformation)
        and buf_chk-gds.b-code = 0
        and buf_chk-gds.src-code = un-bc.bar-code
    on error undo, return error:
      assign
      buf_chk-gds.is-error = no
      .
     end.
   end.
 find first anlz-bc where anlz-bc.b-c = b-c no-error.
 if not available anlz-bc or add-sens = ? then do:
    find last last-anlz-bc no-error.
    create anlz-bc.
    assign anlz-bc.nm  = if available last-anlz-bc then last-anlz-bc.nm + 1 else 1
           anlz-bc.b-c = b-c
           anlz-bc.rez = if flagplace = yes then "place" else "" .
 end.
 assign anlz-bc.scn-qnty = anlz-bc.scn-qnty + rate * un-bc.file-qnty
        anlz-bc.scn-pl   = if anlz-bc.scn-pl = "" or anlz-bc.scn-pl = ? then un-bc.scn-pl else anlz-bc.scn-pl
        anlz-bc.des      = anlz-bc.des + mess
        un-bc.des        = mess
        un-bc.b-c        = b-c
        un-bc.rate       = rate.
 find first bar-code where bar-code.b-code = b-c no-lock.
 if bar-code.in-code <> "" then do:
    for each gds-bar-code where gds-bar-code.gds-code  = bar-code.gds-code  and
                                gds-bar-code.in-code   = "" no-lock,
        first gds-anlz-bc where gds-anlz-bc.b-c = gds-bar-code.b-code
        :
        assign gds-anlz-bc.rez = "wrn"
               gds-anlz-bc.err-msg = gds-anlz-bc.err-msg +
               "По данному бар-коду партии есть товар в данном файле. При инвентаризации с заменой возможны проблемы.".
        leave.
    end.
 end.
 else do:
    for each prt-bar-code where prt-bar-code.gds-code  =  bar-code.gds-code  and
                                prt-bar-code.in-code  <>  ""                 use-index prt-parts
                                no-lock,
       first prt-anlz-bc where prt-anlz-bc.b-c = prt-bar-code.b-code
       :
       assign anlz-bc.rez = "wrn"
              anlz-bc.err-msg = anlz-bc.err-msg +
              "По данному товару есть бар-код партии в данном файле. При инвентаризации с заменой возможны проблемы.".
       leave.
    end.
 end.
end procedure.
