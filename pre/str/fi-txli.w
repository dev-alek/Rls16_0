DEFINE BUFFER locked_c-fin-ob FOR c-fin-ob.
DEFINE BUFFER locked_fin-ob FOR fin-ob.
DEFINE TEMP-TABLE tt-fin-ob-tax NO-UNDO LIKE fin-ob-tax.
DEFINE TEMP-TABLE tt0-fin-ob-tax NO-UNDO LIKE fin-ob-tax.
DEFINE BUFFER X_clients-host FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-ob.host-code no-undo.
define input parameter p-doc-code like ub.fin-ob.doc-code no-undo.
define input parameter p-doc-type as character no-undo .
define input parameter p-sum-doc like ub.fin-ob.sum-doc no-undo .
define input parameter p-curr-code  like ub.fin-ob.curr-code no-undo .
define input parameter p-base-rate  like ub.fin-ob.base-rate no-undo .
define input parameter p-base-scale like ub.fin-ob.base-scale no-undo .
define input parameter p-exch-rate  like ub.fin-ob.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-ob.exch-scale no-undo .
define input-output parameter   p-slt-pc            like ub.fin-ob-tax.slt-pc             no-undo .
define input-output parameter   p-sum-line-doc      like ub.fin-ob-tax.sum-line-doc       no-undo .
define input-output parameter   p-sum-vat-line-doc  like ub.fin-ob-tax.sum-vat-line-doc   no-undo .
define input-output parameter   p-sum-slt-line-doc  like ub.fin-ob-tax.sum-slt-line-doc   no-undo .
define input-output parameter   p-vat-pc            like ub.fin-ob-tax.vat-pc             no-undo .
define input-output parameter   p-with-slt          like ub.fin-ob-tax.with-slt           no-undo .
define input-output parameter   p-with-vat          like ub.fin-ob-tax.with-vat           no-undo .
DEFINE INPUT PARAMETER TABLE FOR tt-fin-ob-tax .
define input parameter p-recid as recid no-undo .
define input parameter p-chip-num like ub.c-fin-ob.chip-num no-undo .
define output parameter p-res as logical no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Налоги для финобязательства".
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
define variable v-db-num like ub.db.db-num no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-add-chg as character no-undo.
define variable v-fin-vat-pc like ub.sysconf.fin-vat-pc no-undo.
define variable v-fin-slt-pc like ub.sysconf.fin-slt-pc no-undo.
define variable v-rest-sum-doc like ub.fin-ob-tax.sum-line-doc no-undo.
define variable last-line like ub.fin-ob-tax.line-num no-undo.
define variable v-change-tab-order as character no-undo .
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_currency for ub.currency.
define buffer X_contract for ub.contract.
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
define temp-table tt-fix no-undo
field line-num as integer
index pi is primary unique
line-num
.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-all-sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по документу"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-curr-code AS INTEGER FORMAT ">9" INITIAL 0
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 4 BY .67.
DEFINE VARIABLE f-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL " %НП"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма (налоги в т.ч.)"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE f-sum-slt AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма  НП"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-sum-vat AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма НДС"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-vat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL "%НДС"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.
DEFINE VARIABLE T-sltpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE T-sltsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE T-vatpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE T-vatsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE T-with-slt AS LOGICAL INITIAL yes
     LABEL "С  НП"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.
DEFINE VARIABLE T-with-vat AS LOGICAL INITIAL yes
     LABEL "С НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1 COL 89
     B-exit AT ROW 1.04 COL 1
     b-quit AT ROW 1.04 COL 11
     f-all-sum-doc AT ROW 2.88 COL 23.25 COLON-ALIGNED
     f-sum-doc AT ROW 4.08 COL 23.63 COLON-ALIGNED
     T-with-slt AT ROW 5.54 COL 25.38
     f-slt-pc AT ROW 5.54 COL 45 COLON-ALIGNED
     f-sum-slt AT ROW 5.54 COL 73.63 COLON-ALIGNED
     T-sltpc AT ROW 5.58 COL 38.75
     T-sltsum AT ROW 5.58 COL 62.5
     T-with-vat AT ROW 6.79 COL 25.38
     f-vat-pc AT ROW 6.79 COL 45 COLON-ALIGNED
     f-sum-vat AT ROW 6.79 COL 73.63 COLON-ALIGNED
     T-vatpc AT ROW 6.83 COL 38.75
     T-vatsum AT ROW 6.83 COL 62.5
     f-curr-abbr AT ROW 2.92 COL 54.63 COLON-ALIGNED NO-LABEL
     F-curr-code AT ROW 2.96 COL 49.5 COLON-ALIGNED
     SPACE(43.74) SKIP(5.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Налоги"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run check-sums in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
  T-with-slt
  T-with-vat
  .
  if f-slt-pc:sensitive then  assign frame Dialog-Frame     f-slt-pc.
  if f-vat-pc:sensitive then  assign frame Dialog-Frame     f-vat-pc.
  if f-sum-vat:sensitive then  assign frame Dialog-Frame    f-sum-vat.
  if f-sum-slt:sensitive then  assign frame Dialog-Frame    f-sum-slt.
assign
  p-res = true
  p-slt-pc              = f-slt-pc
  p-sum-line-doc        = f-sum-doc
  p-sum-vat-line-doc    = f-sum-vat
  p-sum-slt-line-doc    = f-sum-slt
  p-vat-pc              = f-vat-pc
  p-with-slt            = T-with-slt
  p-with-vat            =  T-with-vat
.
apply "window-close" to self.
return .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
 p-res = false  .
END.
ON LEAVE OF f-slt-pc IN FRAME Dialog-Frame
DO:
  assign
  f-slt-pc.
  run recalc-sums in this-procedure("slt-pc":U).
  run recalc-sums in this-procedure("sum-doc":U).
END.
ON return OF f-slt-pc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  f-slt-pc:handle ) .
  return no-apply .
END.
ON LEAVE OF f-sum-doc IN FRAME Dialog-Frame
DO:
  if f-sum-doc:modified = true then do:
      assign
        f-sum-doc
      .
      if abs(p-sum-doc) < abs(f-sum-doc) then do:
          message "Сумма налогов в том числе больше чем общая сумма документа" p-sum-doc .
          return no-apply.
      end.
  end.
  run recalc-sums in this-procedure("sum-doc":U).
END.
ON return OF f-sum-doc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  f-sum-doc:handle ) .
  return no-apply .
END.
ON LEAVE OF f-sum-slt IN FRAME Dialog-Frame
DO:
    assign
  f-sum-slt.
  run recalc-sums in this-procedure("sum-slt":U).
  run recalc-sums in this-procedure("sum-doc":U).
END.
ON return OF f-sum-slt IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  f-sum-slt:handle ) .
  return no-apply .
END.
ON LEAVE OF f-sum-vat IN FRAME Dialog-Frame
DO:
  assign
  f-sum-vat.
  run recalc-sums in this-procedure("sum-vat":U).
    run recalc-sums in this-procedure("sum-doc":U).
END.
ON return OF f-sum-vat IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  f-sum-vat:handle ) .
  return no-apply .
END.
ON LEAVE OF f-vat-pc IN FRAME Dialog-Frame
DO:
    assign
  f-vat-pc.
  run recalc-sums in this-procedure("vat-pc":U).
  run recalc-sums in this-procedure("sum-doc":U).
END.
ON return OF f-vat-pc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  f-vat-pc:handle ) .
  return no-apply .
END.
ON VALUE-CHANGED OF T-sltpc IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  t-sltpc.
  run disable-enable in this-procedure("slt-pc":U).
END.
ON VALUE-CHANGED OF T-sltsum IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  t-sltsum.
  run disable-enable in this-procedure("slt-sum":U).
END.
ON VALUE-CHANGED OF T-vatpc IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  t-vatpc.
  run disable-enable in this-procedure("vat-pc":U).
END.
ON VALUE-CHANGED OF T-vatsum IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  t-vatsum.
  run disable-enable in this-procedure("vat-sum":U).
END.
ON VALUE-CHANGED OF T-with-slt IN FRAME Dialog-Frame
DO:
  assign
  t-with-slt.
  run with-without in this-procedure ("slt":U, t-with-slt).
  run recalc-sums in this-procedure("sum-doc":U).
END.
ON VALUE-CHANGED OF T-with-vat IN FRAME Dialog-Frame
DO:
  assign
  t-with-vat.
  run with-without in this-procedure ("vat":U, t-with-vat).
    run recalc-sums in this-procedure("sum-doc":U).
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> ('ПРОСМОТР':U + chr(4) + "history":U)
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
    find first X_curr_sysconf no-lock where
                    X_curr_sysconf.host-code = p-curr-host-code.
    find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code.
   assign
    v-fin-vat-pc = X_sysconf.fin-vat-pc
    v-fin-slt-pc = X_sysconf.fin-slt-pc
    .
    find first X_clients-host no-lock where
              X_clients-host.obj-type = 'орг':U
          AND X_clients-host.obj-code = p-host-code.
  if p-doc-type = 'рас':U then do:
      if LOOKUP('ПРОСМОТР':U , p-mode, chr(4)) = 0
        then do:
        if X_curr_sysconf.host-code <> p-host-code
        or (v-db-num <> X_sysconf.firm-db-num)
        then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code skip
          X_sysconf.firm-db-num
          v-db-num
          view-as alert-box ERROR.
          undo, return error.
        end.
      end.
  end.
  if p-mode = ('ПРОСМОТР':U + chr(4) + "history":U)
  then do:
  end.
  else do:
    run get-rest-sum in this-procedure(output v-rest-sum-doc).
    run proc-b-add-chg in this-procedure ( p-mode) .
  end.
  find first X_currency no-lock where
               X_currency.curr-code = p-curr-code.
  run myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS f-sum-doc.
END.
run disable_ui.
PROCEDURE check-sums :
END PROCEDURE.
PROCEDURE disable-enable :
define input parameter p-main-widget as character no-undo.
CASE p-main-widget:
  when "vat-sum" then do:
    assign
        T-vatpc = no.
        enable
          t-vatpc
          f-sum-vat
          with frame Dialog-Frame.
        disable
          t-vatsum
          f-vat-pc
          with frame Dialog-Frame.
  end.
    when "slt-sum" then do:
      assign
        T-sltpc = no.
        enable
          t-sltpc
          f-sum-slt
          with frame Dialog-Frame.
        disable
            t-sltsum
            f-slt-pc
            with frame Dialog-Frame.
  end.
  when "vat-pc" then do:
    assign
        T-vatsum = no.
        enable
          t-vatsum
          f-vat-pc
          with frame Dialog-Frame.
        disable
        t-vatpc
        f-sum-vat
        with frame Dialog-Frame.
  end.
  when "slt-pc" then do:
        assign
        T-sltsum = no.
        enable
        t-sltsum
        f-slt-pc
        with frame Dialog-Frame.
        disable
        t-sltpc
        f-sum-slt
        with frame Dialog-Frame.
  end.
END CASE.
display
T-sltpc
T-sltsum
T-vatpc
T-vatsum
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-all-sum-doc f-sum-doc T-with-slt f-slt-pc f-sum-slt T-sltpc T-sltsum
          T-with-vat f-vat-pc f-sum-vat T-vatpc T-vatsum f-curr-abbr F-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE B-Help B-exit b-quit f-sum-doc T-with-slt f-slt-pc T-sltpc T-with-vat
         f-vat-pc T-vatpc F-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
define buffer buf_fin-ob-tax for ub.fin-ob-tax.
define buffer buf_c-fin-ob-tax for ub.c-fin-ob-tax.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
do on error undo, return error:
  if p-mode = 'ПРОСМОТР':U + chr(4) + "History":U then do:
  end.
  else do:
  end.
  run get-rest-sum in this-procedure ( output v-rest-sum-doc).
end.
END PROCEDURE.
PROCEDURE get-rest-sum :
define output parameter p-rest-sum like ub.fin-ob-tax.sum-line-doc no-undo.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
for each buf_tt-fin-ob-tax  where  recid(buf_tt-fin-ob-tax) <> p-recid :
    assign
    p-rest-sum = p-rest-sum + buf_tt-fin-ob-tax.sum-line-doc
    .
end.
assign
p-rest-sum = p-sum-doc - p-rest-sum
.
if p-rest-sum < 0 then do : p-rest-sum = 0.
end.
END PROCEDURE.
PROCEDURE Myenable :
assign
frame Dialog-Frame:title = frame Dialog-Frame:title + " фирма " + x_clients-host.obj-name + "  - " + caps(p-mode)
b-quit:label = (if lookup('ПРОСМОТР':U, p-mode, chr(4)) > 0 then "&Выход" else b-quit:label)
t-with-slt = yes
t-with-vat = yes
t-sltpc = yes
t-vatpc = yes
t-sltsum = no
t-vatsum = no
.
DISPLAY
p-sum-doc @ f-all-sum-doc
p-curr-code @ f-curr-code
X_currency.curr-abbr @ f-curr-abbr
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-exit when lookup('ПРОСМОТР':U, p-mode, chr(4)) = 0
B-Help
WITH FRAME Dialog-Frame.
if lookup('ПРОСМОТР':U, p-mode, chr(4)) > 0 then do:
  hide
  b-exit
  in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE next-focus :
do
 on error undo, return error return-value
 :
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .
  assign
    l-apply-entry =   true
  .
     do with frame Dialog-Frame :
          if  f-sum-doc          :handle = p-widget-handle then do:
              if f-slt-pc  :sensitive then do: apply "entry":u to f-slt-pc  .  return . end.
              if f-sum-slt :sensitive then do: apply "entry":u to f-sum-slt .  return . end.
              if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-slt-pc           :handle = p-widget-handle then do:
            if f-sum-slt :sensitive then do: apply "entry":u to f-sum-slt .  return . end.
            if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
            if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
            if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-sum-slt          :handle = p-widget-handle then do:
              if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-vat-pc           :handle = p-widget-handle then do:
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-sum-vat          :handle = p-widget-handle then do:
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-b-add-chg :
define input parameter p-mode as character no-undo.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    assign
    f-slt-pc     =  p-slt-pc
    f-sum-doc    =  p-sum-line-doc
    f-sum-vat    =  p-sum-vat-line-doc
    f-sum-slt    =  p-sum-slt-line-doc
    f-vat-pc     =  p-vat-pc
    T-with-slt   =  p-with-slt
    T-with-vat   =  p-with-vat
    .
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    f-vat-pc     = v-fin-vat-pc
    f-slt-pc     = v-fin-slt-pc
    f-sum-doc    = v-rest-sum-doc
    T-with-slt   = yes
    T-with-vat   = yes
    f-sum-slt    = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
    f-sum-vat    = (f-sum-doc -  f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
    .
end.
display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
with frame Dialog-Frame.
disable
b-exit
t-sltpc
t-vatpc
with frame Dialog-Frame.
enable
f-sum-doc
f-vat-pc   when T-with-vat = true
f-slt-pc   when T-with-slt = true
T-sltsum   when T-with-slt = true
T-vatsum   when T-with-vat = true
T-with-slt
T-with-vat
with frame Dialog-Frame.
APPLY "ENTRY" to f-sum-doc.
END PROCEDURE.
PROCEDURE recalc-sums :
define input parameter p-main-widget as character no-undo.
define variable v-line-num like ub.fin-ob-tax.line-num no-undo.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
case v-add-chg:
  when 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-line-num = tt-fin-ob-tax.line-num
    .
  end.
  when 'ДОБАВЛЕНИЕ':U then do:
    assign
    v-line-num = last-line
    .
  end.
 END CASE.
CASE p-main-widget :
    when "sum-doc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
      .
    end.
    when "slt-pc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
      .
    end.
    when "vat-pc":U then do:
      assign
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
      .
    end.
    when "sum-slt":U then do:
      assign
      f-slt-pc = f-sum-slt / (f-sum-doc - f-sum-slt ) * 100
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "sum-vat":U then do:
      assign
      f-vat-pc = f-sum-vat / (f-sum-doc - f-sum-slt - f-sum-vat ) * 100
      .
    end.
END CASE.
if abs( f-sum-vat + f-sum-slt) >= abs( f-sum-doc)  then do:
  message
  "Сумма налогов больше налогооблагаемой суммы + налоги!"
  view-as alert-box error .
  return error.
end.
display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE with-without :
define input parameter p-widget as character no-undo.
define input parameter p-on as logical no-undo.
CASE p-widget:
  when "slt":U then do:
    CASE p-on:
      when yes then do:
        assign
          f-slt-pc     = v-fin-slt-pc
          T-with-slt   = yes
          f-sum-slt    = f-sum-doc * f-slt-pc / 100
          T-sltsum = false
          t-sltpc  = true
        .
        display
          f-slt-pc
          f-sum-slt
          t-with-slt
          T-sltsum
          t-sltpc
        with frame Dialog-Frame.
        enable
          f-slt-pc
          T-sltsum
        with frame Dialog-Frame.
        disable
          f-sum-slt
          t-sltpc
        with frame Dialog-Frame.
      end.
      when no then do:
        assign
        f-slt-pc = 0
        .
        display
        f-slt-pc
        with frame Dialog-Frame.
        apply "LEAVE" to f-slt-pc.
        disable
        f-slt-pc
        f-sum-slt
        T-sltpc
        T-sltsum
        with frame Dialog-Frame.
      end.
    END CASE.
  end.
  when "vat":U then do:
    CASE p-on:
      when yes then do:
        assign
        f-vat-pc     = v-fin-vat-pc
        T-with-vat   = yes
        f-sum-vat    = (f-sum-doc - f-sum-slt) * f-vat-pc / 100
        T-vatsum = false
        t-vatpc  = true
        .
        display
        f-vat-pc
        f-sum-vat
        t-with-vat
        T-vatsum
        t-vatpc
        with frame Dialog-Frame.
        enable
        f-vat-pc
        T-vatsum
        with frame Dialog-Frame.
        disable
        f-sum-vat
        t-vatpc
        with frame Dialog-Frame.
      end.
      when no then do:
        assign
        f-vat-pc = 0
        .
        display
        f-vat-pc
        with frame Dialog-Frame.
        apply "LEAVE" to f-vat-pc.
        disable
        f-vat-pc
        f-sum-vat
        T-vatpc
        T-vatsum
        with frame Dialog-Frame.
      end.
    END CASE.
  end.
END CASE.
END PROCEDURE.
