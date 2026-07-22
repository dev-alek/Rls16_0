define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Задания значений смен для поиска".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable flt-rec as recid no-undo.
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc ( output g#report-num ).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable join-tbl      as character no-undo .
define variable join_rus      as character no-undo .
define variable vh as handle no-undo .
define variable fh as handle no-undo .
define variable next-fill-in  as logical   no-undo initial no .
define variable name          as character no-undo .
define variable ss            as character no-undo .
define variable s_description as character no-undo .
define variable aa            as character no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable p-mandatory AS logical no-undo .
define variable v-confirm AS logical no-undo .
define buffer buf_shift-obj for ub.shift-obj.
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
DEFINE BUTTON B-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY .88.
DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-obj-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-shift-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата смены"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-obj-type AT ROW 3 COL 13.5 COLON-ALIGNED
     f-obj-code AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     f-shift-date AT ROW 5 COL 13 COLON-ALIGNED
     f-shift-name AT ROW 5 COL 35 COLON-ALIGNED
     f-shift-num AT ROW 5 COL 51.5 COLON-ALIGNED
     B-sht AT ROW 5 COL 59.5
     SPACE(4.62) SKIP(1.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор смены"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sht IN FRAME Dialog-Frame
DO:
  v-confirm = NO.
  run proc-sht IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON LEAVE OF f-shift-date IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame f-shift-date <> f-shift-date then do:
    assign
      f-shift-name   = ""
      f-shift-num = 0
      v-confirm = NO.
    display
    f-shift-name
    f-shift-num with frame Dialog-Frame.
    apply "entry" to f-shift-name in frame Dialog-Frame.
    return no-apply.
  end.
END.
ON RETURN OF f-shift-date IN FRAME Dialog-Frame
DO:
  apply "entry" to f-shift-name in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF f-shift-name IN FRAME Dialog-Frame
DO:
  IF INPUT FRAME Dialog-Frame f-shift-name <> f-shift-name THEN DO:
      v-confirm = NO.
  END.
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF f-shift-name IN FRAME Dialog-Frame
DO:
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF f-shift-num IN FRAME Dialog-Frame
DO:
    IF INPUT FRAME Dialog-Frame f-shift-num <> f-shift-num THEN DO:
        v-confirm = NO.
    END.
  run proc-shift-num IN this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON RETURN OF f-shift-num IN FRAME Dialog-Frame
DO:
    apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame Dialog-Frame anywhere do:
  if b-Help :sensitive then DO: apply "CHOOSE":U to b-Help in frame Dialog-Frame. END.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-start IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN ERROR.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-obj-type f-obj-code f-shift-date f-shift-name f-shift-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-obj-type f-obj-code f-shift-date f-shift-name
         f-shift-num B-sht
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE + (IF p-obj-code <> 0
                                                         THEN (p-obj-type + STRING(p-obj-code))
                                                         ELSE '':U)
.
DISPLAY
f-obj-type
f-obj-code
f-shift-date
f-shift-name
f-shift-num
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-Help
f-shift-date WHEN (p-obj-code <> 0)
f-shift-name WHEN (p-obj-code <> 0)
f-shift-num WHEN (p-obj-code <> 0)
B-sht WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF f-shift-date:SENSITIVE THEN DO:
    APPLY "ENTRY" TO f-shift-date.
END.
ELSE DO:
   APPLY "ENTRY" TO b-sht.
END.
END PROCEDURE.
PROCEDURE proc-save :
if input frame Dialog-Frame f-shift-date = ? then do:
  MESSAGE
  "Вы не ввели дату смены"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
IF NOT p-mandatory
AND v-confirm THEN DO:
END.
ELSE DO:
    IF INPUT FRAME Dialog-Frame f-shift-num = 0  THEN
    RUN proc-shift-name IN THIS-PROCEDURE NO-ERROR.
    ELSE
    RUN proc-shift-num IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END.
if znak = "=" then do:
 assign
   join-tbl = " AND "
   join_rus = " И "
 .
end.
else do:
 assign
   join-tbl = " OR "
   join_rus = " ИЛИ "
 .
end.
assign
 vh = frame Dialog-Frame :first-child
.
do while ( vh <> ? ):
  assign fh = vh :first-child.
  _DO:
  do while ( fh <> ? ) :
    if fh :type = 'fill-in'
    then do:
      if p-obj-code > 0 and
      (fh:name = "f-obj-type"
      or
      fh:name = "f-obj-code") then do:
        assign
          fh = fh :next-sibling
        .
        next _do.
      end.
      if next-fill-in then do:
        assign
          str     = str     + (if fh:name <> 'f-shift-name' then join-tbl else '')
          str_rus = str_rus + (if fh:name <> 'f-shift-num' then join_rus else '')
        .
      end.
      assign
        next-fill-in = yes
      .
      assign
      ss            = fh :screen-value
      s_description = fh :screen-value
      aa            = ( if fh :data-type = "character" then '"' else '' )
      .
      if fh :data-type = "date"
      then do:
        define variable v-date as date      no-undo .
        assign
          v-date = date(fh :screen-value)
        .
        if v-date = ?
        then do:
          assign
            ss             = chr(63)
            s_description = "НЕ_ЗАДАНА"
          .
        end.
        else do:
          assign
           ss             = 'date(':u + string(month(v-date))
                          + '~~054':u + string(day(v-date))
                          + '~~054':u + string(year(v-date))
                          + ')':u
            s_description = string(v-date, "99/99/9999")
          .
        end.
      end.
      if fh :data-type = "character"
      then do:
        run replace-special-char in this-procedure
          (input  ss
          ,output ss
          ) .
        assign
          s_description = replace(s_description, ',', '~~054')
        .
      end.
      if fh:name = 'f-shift-name' then do:
        assign
          str     = str
          str_rus = str_rus + entry( 2, fh :private-data ) + " " + znak + " " +
                    substitute("&1(&2)"
                               ,f-shift-name:screen-value
                               ,f-shift-num:screen-value).
        .
      END.
      ELSE DO:
        assign
          str     = str     + entry( 1, fh :private-data ) + " " + znak + " " + aa + ss            + aa
          str_rus = str_rus + (if fh:name <> 'f-shift-num'
                               then  (entry( 2, fh :private-data ) + " " + znak + " " + aa + s_description + aa)
                               else '')
        .
      END.
    end.
    assign
      fh = fh :next-sibling
    .
  end.
  assign
    vh = vh :next-sibling
  .
end.
assign
 str     = "(" + str     + ")"
 str_rus = "(" + str_rus + ")"
.
END PROCEDURE.
PROCEDURE proc-shift-name :
define buffer buf_shift-obj   for ub.shift-obj.
define variable v-find-shift as integer initial 0.
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num  no-undo.
define variable glog as logical no-undo .
if input frame Dialog-Frame f-shift-date <> ? then do:
for each  buf_shift-obj no-lock  where
         buf_shift-obj.obj-type   = f-obj-type
    AND  buf_shift-obj.obj-code   = f-obj-code
    AND  buf_shift-obj.shift-date = input frame Dialog-Frame f-shift-date
    AND  buf_shift-obj.shift-name = input frame Dialog-Frame f-shift-name
    on error undo, return error return-value :
  assign
    v-find-shift = v-find-shift + 1
    v-shift-date = buf_shift-obj.shift-date
    v-shift-num  = buf_shift-obj.shift-num.
end.
if v-find-shift = 0
or v-find-shift > 1 then do:
  if v-find-shift = 0 then do:
    message substitute("Не найдена смена: &1&2&3" +
                       "Дата &4 Номер смены &5."
                       ,p-obj-type
                       ,p-obj-code
                       ,chr(10)
                       ,input frame Dialog-Frame f-shift-date
                       ,input frame Dialog-Frame f-shift-name)
    view-as alert-box error.
  end.
  else do:
    message
    SUBSTITUTE("Найдено более одной смены с одним номером в сменном дне.&1" +
              "Объект: &2&3 Дата &4 Номер смены &5."
              ,chr(10)
              ,p-obj-type
              ,p-obj-code
              ,input frame Dialog-Frame f-shift-date
              ,input frame Dialog-Frame f-shift-name)
    view-as alert-box error.
  end.
  if not p-mandatory
  and v-find-shift = 0
  then do:
    message
    "Хотите задать значения даты смены/№ смены, не соответвующие ни одной из имеющихся в БД смен?"
    view-as alert-box question buttons YES-NO update glog.
    if glog then do:
      assign frame Dialog-Frame
      f-shift-name.
      v-confirm = YES.
      return.
    end.
  end.
  display
  f-shift-name
  with frame Dialog-Frame.
  run proc-sht IN THIS-PROCEDURE no-error.
  if error-status:error then do:
    return error.
  end.
end.
else do:
  assign frame Dialog-Frame
  f-shift-name.
end.
end.
END PROCEDURE.
PROCEDURE proc-shift-num :
define variable glog as logical no-undo .
define buffer buf_shift-obj   for ub.shift-obj.
if input frame Dialog-Frame f-shift-date <> ? then do:
find first buf_shift-obj where
           buf_shift-obj.obj-type   = f-obj-type
       and buf_shift-obj.obj-code   = f-obj-code
       AND buf_shift-obj.shift-date = input frame Dialog-Frame f-shift-date
       and buf_shift-obj.shift-num  = input frame Dialog-Frame f-shift-num  no-lock no-error.
if not available buf_shift-obj then do:
  message substitute("Не найдена смена: &1&2&3"  +
                     "Дата &4 Порядок смены &5."
                     ,p-obj-type
                     ,p-obj-code
                     , chr(10)
                     ,input frame Dialog-Frame f-shift-date
                     ,input frame Dialog-Frame f-shift-num)
  view-as alert-box error.
  if not p-mandatory then do:
    message
    "Хотите задать значения даты смены/№ смены, не соответвующие ни одной из имеющихся в БД смен?"
    view-as alert-box question buttons YES-NO update glog.
    if glog then do:
      assign frame Dialog-Frame
      f-shift-num
      v-confirm = YES
      .
      return.
    end.
  end.
  display
  f-shift-num
  with frame Dialog-Frame.
  run proc-sht IN this-procedure no-error.
  if error-status:error then do:
    return error.
  end.
end.
else do:
  assign
  f-shift-date = buf_shift-obj.shift-date
  f-shift-num  = buf_shift-obj.shift-num
  f-shift-name = buf_shift-obj.shift-name.
  display
  f-shift-date
  f-shift-num
  f-shift-name
  with frame Dialog-Frame.
end.
end.
END PROCEDURE.
PROCEDURE proc-sht :
define buffer buf_shift-obj   for ub.shift-obj.
define variable v-rid-list as character no-undo.
define variable v-recid    as recid     no-undo.
assign
v-rid-list = "".
run str/sht-all.w (input parparentproc
             , INPUT v-cntxt-obj-type
             , input v-cntxt-obj-code
             , input 'b-sel'
             , input (if p-obj-code > 0 then 'obj' else 'all')
             , INPUT (if p-obj-type <> '':U then p-obj-type else v-cntxt-obj-type)
             , input (if p-obj-code <> 0 then p-obj-code else v-cntxt-obj-code)
             , input '':u
             , input-output v-rid-list) no-error.
if error-status:error
or v-rid-list = "":u then do:
  return error.
end.
else do:
  assign
  v-recid = integer (entry(1, v-rid-list)).
  find first buf_shift-obj NO-LOCK where
           recid(buf_shift-obj) = v-recid no-error.
  assign
  f-obj-type   = buf_shift-obj.obj-type
  f-obj-code   = buf_shift-obj.obj-code
  f-shift-date = buf_shift-obj.shift-date
  f-shift-num  = buf_shift-obj.shift-num
  f-shift-name    = buf_shift-obj.shift-name.
  display
  f-obj-type
  f-obj-code
  f-shift-date
  f-shift-num
  f-shift-name
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-start :
define variable vdopstr as character no-undo .
define variable v-param-list as character no-undo .
define variable ii as integer no-undo .
if num-entries(spr, chr(4)) > 1 then do:
assign
vdopstr = spr
spr = entry(1, vdopstr, chr(4) )
.
entry(1, vdopstr, chr(4) ) = ''.
v-param-list = substring(vdopstr, 2).
end.
IF v-param-list <> '':U THEN DO:
    ASSIGN
    p-obj-type = ENTRY(1, v-param-list, chr(4))
    p-obj-code = integer(ENTRY(2, v-param-list, chr(4)))
    p-mandatory = LOGICAL(ENTRY(3, v-param-list, chr(4)))
    NO-ERROR
    .
    IF ERROR-STATUS:ERROR  THEN DO:
        UNDO, RETURN ERROR.
    END.
  ASSIGN
  f-obj-type = p-obj-type
  f-obj-code = p-obj-code
  .
END.
ASSIGN
f-shift-name:PRIVATE-DATA IN FRAME Dialog-Frame = ",Номер смены".
do ii = 1 to num-entries(fld, '*'):
  if entry(2, entry(ii, fld, '*'), '.') = "shift-date" then do:
    assign
    f-shift-date:private-data IN FRAME Dialog-Frame = entry(ii, fld, '*') + chr(44) +
                                                       replace(entry(ii, lab, '*'), "&", '').
  end.
  if entry(2, entry(ii, fld, '*'), '.') = "shift-num" then do:
    assign
    f-shift-num:private-data IN FRAME Dialog-Frame = entry(ii, fld, '*') + chr(44) +
                                                      replace(entry(ii, lab, '*'), "&", '').
  end.
  if entry(2, entry(ii, fld, '*'), '.') = "obj-type" then do:
    assign
    f-obj-type:private-data IN FRAME Dialog-Frame = entry(ii, fld, '*') + chr(44) +
                                                     replace(entry(ii, lab, '*'), "&", '').
  end.
  if entry(2, entry(ii, fld, '*'), '.') = "obj-code" then do:
    assign
    f-obj-code:private-data IN FRAME Dialog-Frame = entry(ii, fld, '*') + chr(44) +
                                                     replace(entry(ii, lab, '*'), "&", '').
  end.
END.
END PROCEDURE.
PROCEDURE replace-special-char :
define input  parameter p-in-string    as character no-undo .
  define output parameter p-out-string   as character no-undo .
  define variable v-out-string   as character no-undo .
  define variable v-enclose-char as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-out-string   = p-in-string
      v-enclose-char = '"'
    .
    if index(v-out-string, '"') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '"', v-enclose-char + ' + chr(' + string(asc('"')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '~~') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '~~', v-enclose-char + ' + chr(' + string(asc('~~')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, ',') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, ',', v-enclose-char + ' + chr(' + string(asc(',')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, "'") > 0
    then do:
      assign
        v-out-string = replace(v-out-string, "'", v-enclose-char + ' + chr(' + string(asc("'")) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '/') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '/', v-enclose-char + ' + chr(' + string(asc('/')) + ') + ' + v-enclose-char)
      .
    end.
    assign
      p-out-string = v-out-string
    .
  end.
END PROCEDURE.
