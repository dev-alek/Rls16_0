DEFINE TEMP-TABLE tt-ruleset NO-UNDO LIKE ub.ruleset.
DEFINE BUFFER X_ruleset FOR ub.ruleset.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input-output parameter p-rid-list as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список ruleset".
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define temp-table tt0-rule-call-param no-undo  like ub.rule-call-param.
DEFINE VARIABLE v-browse-mode as character no-undo .
DEFINE MENU MENU-b-links
       MENU-ITEM m_prop-ruleset LABEL "Объекты-операнды"
       MENU-ITEM m_rule         LABEL "Правила"
       MENU-ITEM m_pscript-ruleset LABEL "Скрипты для объектов"
       MENU-ITEM m_rule-by-profile LABEL "Правила профайлов"
       MENU-ITEM m_rule-call-param LABEL "Параметры вызова правил".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-links
     LABEL "Связи"
     SIZE 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE QUERY br-ruleset FOR
      X_ruleset SCROLLING.
DEFINE QUERY br-temp-ruleset FOR
      tt-ruleset SCROLLING.
DEFINE BROWSE br-ruleset
  QUERY br-ruleset NO-LOCK DISPLAY
      mark-string(recid(X_ruleset), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_ruleset.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.
DEFINE BROWSE br-temp-ruleset
  QUERY br-temp-ruleset NO-LOCK DISPLAY
      tt-ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
tt-ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
tt-ruleset.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     b-links AT ROW 1 COL 78 WIDGET-ID 16
     B-Help AT ROW 1 COL 95
     br-temp-ruleset AT ROW 2.33 COL 1.5 WIDGET-ID 200
     br-ruleset AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.
ASSIGN
       br-temp-ruleset:HIDDEN  IN FRAME Dialog-Frame                = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
 define variable v-rec as recid no-undo.
  v-rec = recid(X_ruleset).
  run rul/ruleset-i.w ( input parparentproc
                       ,input 'ДОБАВЛЕНИЕ':U
                       ,input 0
                       ,input 0
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    reposition br-ruleset to recid v-rec no-error.
    apply "Entry" to br-ruleset.
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  if not available X_ruleset then return no-apply.
  v-rec = recid(X_ruleset).
  run rul/ruleset-i.w ( input parparentproc
                       ,input 'ИЗМЕНЕНИЕ':U
                       ,input X_ruleset.codex_id
                       ,input X_ruleset.ruleset_id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-ruleset:refresh().
  end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_ruleset then return no-apply.
  v-rec = recid(X_ruleset).
  message "Вы уверены, что хотите удалить Кодекс или набор правил?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run rul/ruleset3.p ( input no
                      ,input v-rec
                      ) no-error.
 if error-status:error then return no-apply.
 run OpenBr in this-procedure .
END.
ON CHOOSE OF b-links IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
case v-browse-mode:
  when "temp" then do:
    IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
  end.
  otherwise do:
    IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
  end.
end case.
IF link-option = '':U THEN DO:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
END.
if link-option = "":U then do:
   return no-apply.
end.
RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  link-option = '':U.
  RETURN NO-APPLY.
 END.
link-option = '':U.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  define buffer buf_ruleset for ub.ruleset.
  if v-browse-mode = "temp" then do:
    if not available tt-ruleset then return no-apply.
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = tt-ruleset.codex_id
          and buf_ruleset.ruleset_id = tt-ruleset.ruleset_id.
   v-rec = recid(buf_ruleset).
    run rul/ruleset-i.w ( input parparentproc
                        ,input 'ПРОСМОТР':U
                        ,input buf_ruleset.codex_id
                        ,input buf_ruleset.ruleset_id
                        ,input-output v-rec) no-error.
  end.
  else do:
    if not available X_ruleset then return no-apply.
    v-rec = recid(X_ruleset).
    run rul/ruleset-i.w ( input parparentproc
                        ,input 'ПРОСМОТР':U
                        ,input X_ruleset.codex_id
                        ,input X_ruleset.ruleset_id
                        ,input-output v-rec) no-error.
  end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
    define variable glog as logical no-undo .
  if available X_ruleset then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid5 as character no-undo .
define variable v-num-entry5 as integer   no-undo .
assign
  v-str-recid5 = trim( string( recid( X_ruleset ) , "->>>>>>>>>>>9":U ) )
  v-num-entry5 = lookup( v-str-recid5 , v-rid-list )
.
if v-num-entry5 > 0 then do:
  assign
    entry( v-num-entry5, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid5
  .
end.
  glog = br-ruleset:refresh() .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-ruleset:select-next-row ().
      apply "VALUE-CHANGED" to br-ruleset in frame Dialog-Frame.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame Dialog-Frame.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
end.
apply "entry" to br-ruleset in frame Dialog-Frame.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
define buffer buf_ruleset for ub.ruleset.
  case v-browse-mode:
    when "temp" then do:
      if available tt-ruleset then do:
        find first buf_ruleset no-lock where buf_ruleset.codex_id = tt-ruleset.codex_id and
        buf_ruleset.ruleset_id = tt-ruleset.ruleset_id.
        if  ( v-rid-list = "" ) or b-mark:sensitive = no
        then  v-rid-list = string( recid( buf_ruleset ) ) .
      end.
    end.
    otherwise do:
      if available X_ruleset then do:
        if  ( v-rid-list = "" ) or b-mark:sensitive = no
        then  v-rid-list = string( recid( X_ruleset ) ) .
      end.
    end.
  end case.
END.
ON VALUE-CHANGED OF br-ruleset IN FRAME Dialog-Frame
DO:
   IF AVAILABLE X_ruleset and X_ruleset.ruleset_id = 0 THEN DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE IN MENU menu-b-links = NO
      MENU-ITEM m_pscript-ruleset:SENSITIVE IN MENU menu-b-links = no
      .
  END.
  ELSE DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE  IN MENU menu-b-links = YES
      MENU-ITEM m_pscript-ruleset :SENSITIVE IN MENU menu-b-links = (lookup("b-add", bttns) > 0)
      .
  END.
END.
ON VALUE-CHANGED OF br-temp-ruleset IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_ruleset and X_ruleset.ruleset_id = 0 THEN DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE IN MENU menu-b-links = NO
      MENU-ITEM m_pscript-ruleset:SENSITIVE IN MENU menu-b-links = NO
      .
  END.
  ELSE DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE  IN MENU menu-b-links = YES
      MENU-ITEM m_pscript-ruleset :SENSITIVE IN MENU menu-b-links = (lookup("b-add", bttns) > 0)
      .
  END.
END.
ON CHOOSE OF MENU-ITEM m_prop-ruleset
DO:
case v-browse-mode:
  when "temp" then do:
    IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    if tt-ruleset.ruleset_id = 0 then do:
        message
        "Доступно только для наборов правил, но не для кодексов"
        view-as alert-box .
        return no-apply.
    end.
  end.
  otherwise do:
    IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    if X_ruleset.ruleset_id = 0 then do:
        message
        "Доступно только для наборов правил, но не для кодексов"
        view-as alert-box .
        return no-apply.
    end.
  end.
end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'prop-ruleset':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_pscript-ruleset
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
      if tt-ruleset.ruleset_id = 0 then do:
          message
          "Доступно только для наборов правил, но не для кодексов"
          view-as alert-box .
          return no-apply.
      end.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
      if X_ruleset.ruleset_id = 0 then do:
          message
          "Доступно только для наборов правил, но не для кодексов"
          view-as alert-box .
          return no-apply.
      end.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'pscript-ruleset':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_rule
DO:
define variable v-ruleset-id as integer no-undo .
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
      v-ruleset-id = tt-ruleset.ruleset_Id.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
      v-ruleset-id = X_ruleset.ruleset_Id.
    end.
  end case.
  IF v-ruleset-id = 0  THEN DO:
    RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'rule':U) NO-ERROR.
  END.
  ELSE DO:
    RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'rule-by-set':U) NO-ERROR.
  END.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_rule-by-profile
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'rule-by-profile':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_rule-call-param
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT 'rule-call-param':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON ROW-DISPLAY OF br-ruleset IN frame Dialog-Frame
DO:
  case v-browse-mode:
    when "temp" then do:
      IF AVAIL tt-ruleset THEN DO:
        RUN set-row-color IN this-procedure  ( INPUT tt-ruleset.ruleset_id).
      END.
    end.
    otherwise do:
      IF AVAIL X_ruleset THEN DO:
        RUN set-row-color IN this-procedure  ( INPUT X_ruleset.ruleset_id).
      END.
    end.
  end case.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   run refresh in this-procedure .
    apply "VALUE-CHANGED" to br-ruleset.
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-ruleset :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if lookup( entry(1, p-list-mode, chr(4)), 'все':U + chr(44) +
                          "codex" + chr(44) +
                          "only-codex" + chr(44) +
                          "only-ruleset" + chr(44) +
                          "profile-type") = 0 then do:
    message
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  v-rid-list = p-rid-list.
  if entry(1, p-list-mode, chr(4)) = "profile-type" then do:
    run fill-table in this-procedure ( input entry(2, p-list-mode, chr(4))).
  end.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links B-Help
         br-temp-ruleset br-ruleset mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-ruleset FOR EACH X_ruleset.    OPEN QUERY br-temp-ruleset FOR EACH tt-ruleset.
END PROCEDURE.
PROCEDURE fill-table :
DEFINE INPUT PARAMETER p-profile-type AS CHARACTER NO-UNDO.
DEFINE buffer buf_rule-profile FOR ub.rule-profile.
DEFINE buffer buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE buffer buf_ruleset FOR ub.ruleset.
DEFINE buffer buf_tt-ruleset FOR tt-ruleset.
FOR EACH buf_tt-ruleset:
    DELETE buf_tt-ruleset.
END.
FOR EACH buf_rule-profile NO-LOCK WHERE
        buf_rule-profile.profile-type begins (entry(1, p-profile-type, "_") + "_")
        or buf_rule-profile.profile-type = p-profile-type
        ,
    EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_rule-profile.profile_id
BREAK
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id:
   IF FIRST-OF(buf_rule-by-profile.ruleset_id) THEN DO:
     case entry(3, p-list-mode, chr(4)):
       when "ruleset" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
       when "codex" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = 0 NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = 0 NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
       when "all" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = 0 NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = 0 NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
     end case.
   END.
END.
END PROCEDURE.
PROCEDURE MyEnable :
b-links:MENU-MOUSE IN FRAME Dialog-Frame = 1.
if entry(1, p-list-mode, chr(4)) = "profile-type" THEN DO:
  v-browse-mode = "temp".
    ASSIGN
    tt-ruleset.NAME:RESIZABLE IN BROWSE br-temp-ruleset = YES.
    ENABLE
    b-quit
    b-lkp
    B-Help
    b-links
    b-sel when lookup("b-sel", bttns) > 0
    br-temp-ruleset
    WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    run OpentempBr in this-procedure .
    DISABLE
    b-add
    b-chg
    b-del
    br-ruleset
    WITH FRAME Dialog-Frame.
    HIDE
    br-ruleset
    IN FRAME Dialog-Frame.
    assign
    menu-item m_prop-ruleset:sensitive in menu menu-b-links = no
    menu-item m_pscript-ruleset:sensitive in menu menu-b-links = no
    .
  apply "entry" to br-ruleset in frame Dialog-Frame .
  apply "VALUE-CHANGED" to br-ruleset in frame Dialog-Frame .
END.
ELSE DO:
    ASSIGN
    X_ruleset.NAME:RESIZABLE IN BROWSE br-ruleset = YES .
    ENABLE
    b-quit
    b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-lkp
    B-Help
    b-mark when lookup("b-mark", bttns) > 0
    b-sel when lookup("b-sel", bttns) > 0
    b-links
    br-ruleset
    WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    DISABLE
    br-temp-ruleset
    WITH FRAME Dialog-Frame.
    HIDE
    br-temp-ruleset
    IN FRAME Dialog-Frame.
    run OpenBr in this-procedure .
  apply "entry" to br-temp-ruleset in frame Dialog-Frame .
  apply "VALUE-CHANGED" to br-temp-ruleset in frame Dialog-Frame .
END.
END PROCEDURE.
PROCEDURE Openbr :
case p-list-mode:
  when 'все':U then do:
    frame Dialog-Frame :title = "Все кодексы и наборы правил RULE машины".
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK INDEXED-REPOSITION.
  end.
  when "codex" then do:
    frame Dialog-Frame :title = substitute("Все наборы правил для кодекса &1", p-codex-id).
    OPEN QUERY br-ruleset
    FOR EACH X_ruleset NO-LOCK where
           X_ruleset.codex_id = p-codex-id
       and X_ruleset.ruleset_id > 0 INDEXED-REPOSITION.
  end.
  when "only-codex" then do:
    frame Dialog-Frame :title = substitute("Кодексы правил").
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK where X_ruleset.ruleset_id = 0 INDEXED-REPOSITION.
  end.
  when "only-ruleset" then do:
    frame Dialog-Frame :title = substitute("Наборы правил").
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK where X_ruleset.ruleset_id > 0 INDEXED-REPOSITION.
  end.
END CASE.
APPLY "ENTRY" to br-ruleset.
APPLY "VALUE-CHANGED" to br-ruleset.
END PROCEDURE.
PROCEDURE Opentempbr :
define variable v-call-type as character no-undo .
case entry(2, p-list-mode, chr(4)):
  when 'dis-card-type':U then do:
    v-call-type = "для типов ДК".
  end.
  when 'clients':U then do:
    v-call-type = "для клиентов".
  end.
  when 'goods':U then do:
    v-call-type = "для товаров".
  end.
  when 'gds-grp':U then do:
    v-call-type = "для групп товаров".
  end.
  when 'cli-grp':U then do:
    v-call-type = "для групп клиентов".
  end.
end.
case entry(1, p-list-mode, chr(4)):
  WHEN "profile-type" THEN DO:
    case entry(3, p-list-mode, chr(4)) :
      when "ruleset" then do:
        frame Dialog-Frame :title = SUBSTITUTE("Все наборы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
      when "codex" then do:
        frame Dialog-Frame :title = SUBSTITUTE("Все кодексы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
      when "all" then do:
        frame Dialog-Frame :title = SUBSTITUTE("Все кодексы и наборы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
    end case.
    OPEN QUERY br-temp-ruleset FOR EACH tt-ruleset NO-LOCK INDEXED-REPOSITION.
  end.
END CASE.
APPLY "ENTRY" to br-temp-ruleset.
APPLY "VALUE-CHANGED" to br-temp-ruleset.
END PROCEDURE.
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-codex-id as integer no-undo .
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule for ub.rule.
define buffer buf_rule-call-param for ub.rule-call-param.
case v-browse-mode:
  when "temp" then do:
    assign
    v-ruleset-id = tt-ruleset.ruleset_id
    v-codex-id = tt-ruleset.codex_id
    .
  end.
  otherwise do:
    assign
    v-ruleset-id = X_ruleset.ruleset_id
    v-codex-id = X_ruleset.codex_id
    .
  end.
end.
CASE p-option:
  WHEN 'prop-ruleset':U THEN DO:
    run rul/prop-ruleset-s.w ( INPUT parparentproc
                              ,INPUT "":U
                              ,INPUT "ruleset"
                              ,INPUT v-codex-id
                              ,INPUT v-ruleset-id
                              ,INPUT 0
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
  when 'pscript-ruleset':U then do:
    run rul/pscript-ruleset-s.w ( INPUT parparentproc
                              ,INPUT "":U
                              ,INPUT "ruleset"
                              ,INPUT v-codex-id
                              ,INPUT v-ruleset-id
                              ,INPUT 0
                              ,input '':U
                              ,input '':U
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when 'rule':U then do:
    run rul/rule-by-set-s.w ( INPUT parparentproc
                      ,INPUT "":U
                      ,INPUT "codex"
                      ,INPUT v-codex-id
                      ,input 0
                      ,INPUT 0
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when 'rule-by-set':U then do:
    run rul/rule-by-set-s.w ( INPUT parparentproc
                      ,INPUT "":U
                      ,INPUT "ruleset"
                      ,INPUT v-codex-id
                      ,INPUT v-ruleset-id
                      ,input 0
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when 'rule-by-profile':U then do:
    run rul/rule-by-profile-s.w ( INPUT parparentproc
                      ,INPUT "":U
                      ,INPUT "ruleset"
                      ,INPUT 0
                      ,INPUT v-codex-id
                      ,INPUT v-ruleset-id
                      ,INPUT 0
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when 'rule-call-param':U then do:
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.
    if v-ruleset-id <> 0 then do:
      for each buf_rule-by-set where
              buf_rule-by-set.codex_id = v-codex-id
          and buf_rule-by-set.ruleset_id = v-ruleset-id,
          each buf_rule-call-param no-lock where
              buf_Rule-call-param.rule_id = buf_rule-by-set.rule_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
      end.
    end.
    else do:
      for each buf_rule where
              buf_rule.codex_id = v-codex-id,
          each buf_rule-call-param no-lock where
              buf_Rule-call-param.rule_id = buf_rule.rule_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
      end.
    end.
    run ref/rulercps.w ( INPUT parparentproc
                        ,input this-procedure:handle
                        ,INPUT "":U
                        ,input 'ПРОСМОТР':U
                        ,input 'rule-call-param':U
                        ,input 0
                        ,input ?
                        ,input '':U
                        ,input v-codex-id
                        ,input v-ruleset-id
                        ,input ?
                        ,input 0
                        ,input substitute("Параметры вызова правил: кодекс &1 набор правил &2"
                                          , v-codex-id
                                          , v-ruleset-id)
                        ,input-output table tt0-rule-call-param ) no-error.
  end.
END CASE.
END PROCEDURE.
PROCEDURE refresh :
if v-browse-mode  = "temp" THEN DO:
    v-doc-rec = recid(tt-ruleset).
    RUn OpentempBR in this-procedure.
    REPOSITION br-temp-ruleset to recid v-doc-rec No-ERROR.
    apply 'value-changed' to br-temp-ruleset in frame Dialog-Frame .
END.
ELSE DO:
    v-doc-rec = recid(X_ruleset).
    RUn OpenBR in this-procedure.
    REPOSITION br-ruleset to recid v-doc-rec No-ERROR.
    apply 'value-changed' to br-ruleset in frame Dialog-Frame .
END.
END PROCEDURE.
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.
CASE p-ruleset-id:
  WHEN 0 THEN DO:
  IF p-ruleset-id = 0 THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = DARK_GREEN_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
    if v-browse-mode = "temp" then do:
      ASSIGN
      tt-ruleset.name:FGCOLOR IN BROWSE br-temp-ruleset = iFGColor
      tt-ruleset.name:BGCOLOR IN BROWSE br-temp-ruleset = iBGColor
      .
    end.
    else do:
      ASSIGN
      X_ruleset.name:FGCOLOR IN BROWSE br-ruleset = iFGColor
      X_ruleset.name:BGCOLOR IN BROWSE br-ruleset = iBGColor
      .
    end.
  END.
  OTHERWISE DO:
  END.
END CASE.
END PROCEDURE.
