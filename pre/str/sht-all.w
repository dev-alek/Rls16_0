DEFINE BUFFER X_shift-obj FOR shift-obj.
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter bttns            as character no-undo.
define input parameter sht-mode         as character no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter parcall-point    as character no-undo .
define input-output parameter p-rid-list        as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список смен".
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable is-super    as logical      no-undo.
define variable s-date      as date         no-undo.
define variable e-date      as date         no-undo.
define variable s-time      as integer      no-undo.
define variable e-time      as integer      no-undo.
define variable s-num       as integer      no-undo.
define variable s-name      as character    no-undo.
define variable rep-name    as character    no-undo.
define variable obj-db-num  as integer      no-undo.
define variable v-cancel    as logical      no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable glog        as logical no-undo .
define variable l-shift-on  as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-sys-key as character no-undo.
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid ) :
  def buffer loc-shift-obj for ub.shift-obj  .
  find first loc-shift-obj no-lock where  recid ( loc-shift-obj ) = p-rec no-error  .
  if error-status :error then return '' .
  if can-do (p-rid-list, string (recid (loc-shift-obj))) then RETURN "*".
  else RETURN "".
END FUNCTION.
DEFINE MENU MENU-B-rep
       MENU-ITEM mi-petrol      LABEL "Сменный отчет"
       MENU-ITEM mi-ptrlch      LABEL "Технологический отчет по ТРК"
       MENU-ITEM mi-closeShift  LABEL "Чек-лист по закрытию смены".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить ожидаемую смену"
     BGCOLOR 8 .
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить ожидаемую смену"
     BGCOLOR 8 .
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ожидаемую смену"
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-mark
     LABEL "*":L
     SIZE 3 BY 1.
DEFINE BUTTON B-param
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из списка смен"
     BGCOLOR 8 .
DEFINE BUTTON B-rep
     LABEL "&Отчеты"
     SIZE 10 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON B-staff
     LABEL "&Персонал"
     SIZE 10 BY 1.
DEFINE QUERY br-shift FOR
      X_shift-obj SCROLLING.
DEFINE BROWSE br-shift
  QUERY br-shift DISPLAY
      mark-string(recid(X_shift-obj)) column-label "*" format "X(1)":U
      X_shift-obj.obj-type + " " + string (X_shift-obj.obj-code, ">>>>9") COLUMN-LABEL "Объект" FORMAT "x(9)":U
      X_shift-obj.shift-date COLUMN-LABEL "Дата смены" FORMAT "99/99/9999":U
      X_shift-obj.shift-name COLUMN-LABEL "№" FORMAT "X(2)":U WIDTH 3
      X_shift-obj.shift-num COLUMN-LABEL "Пр" FORMAT ">9":U
      X_shift-obj.status_ COLUMN-LABEL "Статус" FORMAT "X(3)":U
      X_shift-obj.open-date COLUMN-LABEL "Открыта" FORMAT "99/99/9999":U
      STRING (X_shift-obj.open-time, "HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      usrfulnf(X_shift-obj.open-id) COLUMN-LABEL "Открыл" FORMAT "X(14)":U
      X_shift-obj.close-date COLUMN-LABEL "Закрыта" FORMAT "99/99/9999":U
      string (X_shift-obj.close-time, "HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      usrfulnf(X_shift-obj.close-id) COLUMN-LABEL "Закрыл" FORMAT "X(14)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.08.
DEFINE FRAME d-shifts
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     B-staff AT ROW 1 COL 51
     B-rep AT ROW 1 COL 61
     B-param AT ROW 1 COL 71 WIDGET-ID 2
     B-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     b-mark AT ROW 2 COL 1
     br-shift AT ROW 3 COL 1
     SPACE(0.00) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Смены на объекте"
         DEFAULT-BUTTON b-quit.
ASSIGN
       FRAME d-shifts:SCROLLABLE       = FALSE
       FRAME d-shifts:HIDDEN           = TRUE.
ASSIGN
       B-rep:POPUP-MENU IN FRAME d-shifts       = MENU MENU-B-rep:HANDLE.
ON WINDOW-CLOSE OF FRAME d-shifts
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME d-shifts
DO:
RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-chg IN FRAME d-shifts
DO:
    if not available X_shift-obj
    then do:
      message
        "Не выбрана смена."
        view-as alert-box error.
      return no-apply.
    end.
    if X_shift-obj.status_ <> 'ожд':U
      and X_shift-obj.status_ <> 'зкр':U
      then do:
          message "Можно редактировать только ожидаемую или закрытую смену"
          view-as alert-box.
          return no-apply.
      end.
    assign
      v-doc-rec = recid(X_shift-obj)
    .
    if X_shift-obj.status_ = 'ожд':U then do:
    run change-planned-shift in this-procedure
      ( input X_shift-obj.shift-date
       ,input X_shift-obj.shift-num
       ,input X_shift-obj.shift-name
       ,INPUT v-doc-rec
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения запланированной смены."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
      undo, return no-apply .
    end.
    END.
    else do:
        run change-close-shift-time(input v-doc-rec) no-error.
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения запланированной смены."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
          undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF b-del IN FRAME d-shifts
DO:
if not available X_shift-obj or
   X_shift-obj.status_ <> 'ожд':U then do:
  message
    "Можно удалить только ожидаемую смену."
    view-as alert-box error.
  return no-apply.
end.
run gbl/shtwaidl.p ( INPUT NO
                    ,INPUT recid(X_shift-obj)
                   ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
v-doc-rec = ?.
run UI-on IN THIS-PROCEDURE NO-ERROR.
END.
ON CHOOSE OF B-hist IN FRAME d-shifts
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_shift-obj THEN RETURN NO-APPLY.
    run ref/cshthist.w (
                  INPUT parParentProc
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input '':U
                 ,input 'one':U
                 ,INPUT X_shift-obj.obj-type
                 ,INPUT X_shift-obj.obj-code
                 ,INPUT X_shift-obj.shift-date
                 ,INPUT X_shift-obj.shift-num
                 ,INPUT '':U
                 ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF b-mark IN FRAME d-shifts
DO:
    define variable varlog as logical no-undo .
    run local-mark in this-procedure .
    assign
        varlog = br-shift:select-next-row ()
        .
    apply "entry" to br-shift in frame d-shifts.
END.
ON CHOOSE OF B-param IN FRAME d-shifts
DO:
 run str/shift-params.w(
 input X_shift-obj.obj-type,
 input X_shift-obj.obj-code,
 input X_shift-obj.shift-date,
 input X_shift-obj.shift-num,
 input X_shift-obj.shift-name)  .
END.
ON CHOOSE OF B-rep IN FRAME d-shifts
DO:
 if rep-name = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
 if rep-name = "" then return no-apply.
 run proc-b-rep(input-output rep-name) no-error.
 if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sel IN FRAME d-shifts
DO:
    if ( available X_shift-obj AND p-rid-list = "" ) then
        p-rid-list = string( recid( X_shift-obj) ) .
END.
ON CHOOSE OF B-staff IN FRAME d-shifts
DO:
  def buffer buf_shift-obj for ub.shift-obj.
  if avail X_shift-obj then do:
    find first buf_shift-obj where
               recid(buf_shift-obj) = recid(X_shift-obj) no-error.
    if buf_shift-obj.status_ = 'ожд':U then do:
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                               and lookup("b-add", bttns) > 0
                               then "b-add,b-add-next":U else "")
                       ,input 'смена-объект-откр':U) no-error.
    end.
    else if buf_shift-obj.status_ <> 'зкр':U then do:
      if sht-mode = "obj" and
      is-super then
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                               and lookup("b-add", bttns) > 0
                               then  "b-add,b-add-next":U else "")
                       ,input "") no-error.
      else
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input ""
                       ,input "") no-error.
    end.
    else do:
        if sht-mode = "obj" and
        is-super then
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                              and lookup("b-add", bttns) > 0
                              then "b-add-next" else "")
                       ,input "") no-error.
        else
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input ""
                       ,input "") no-error.
    end.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF br-shift IN FRAME d-shifts
DO:
  IF      b-sel :SENSITIVE IN FRAME d-shifts THEN DO:
    APPLY "CHOOSE":U to b-sel IN FRAME d-shifts.
  END.
  ELSE IF b-chg :SENSITIVE IN FRAME d-shifts THEN DO:
     APPLY "CHOOSE":U to b-chg IN FRAME d-shifts.
  END.
  ELSE IF b-rep :SENSITIVE IN FRAME d-shifts THEN DO:
    APPLY "CHOOSE":U to b-rep IN FRAME d-shifts.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF MENU-ITEM mi-petrol
DO:
  rep-name = "g-shift":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM mi-closeShift
DO:
  rep-name = "g-shiftClose":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM mi-ptrlch
DO:
  rep-name = "g-ptrlch":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-shifts:PARENT eq ?
THEN FRAME d-shifts:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-shifts anywhere
do:
   if available X_shift-obj then v-doc-rec = recid(X_shift-obj).  RUn OpenBr in this-procedure.  REPOSITION br-shift to recid v-doc-rec No-ERROR.
    apply "VALUE-CHANGED" to br-shift.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-shift :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-shifts
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
on choose of b-help in frame d-shifts
do:
  apply "help":u to frame d-shifts .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-shifts:width - 0.3
                fh            = frame d-shifts:first-child
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-shifts :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-shifts :height-chars)
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
    if frame d-shifts :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-shifts :height-chars)
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
            frame d-shifts :height = v-frame-height
          .
          if frame d-shifts :scrollable = true
          then do:
            assign
              frame d-shifts :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-shifts :scrollable = true
          then do:
            assign
              frame d-shifts :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-shifts :height = v-frame-height
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
      v-frame-height = frame d-shifts :height
      v-frame-virtual-height = frame d-shifts :virtual-height
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
      v-field-group-handle = frame d-shifts :first-child
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
    do with frame d-shifts
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-shifts :scrollable = true
      then do:
        assign
          frame d-shifts :virtual-height = frame d-shifts :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-shifts :height = frame d-shifts :height + p-change-value
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
        frame d-shifts :height = frame d-shifts :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-shifts :scrollable = true
      then do:
        assign
          frame d-shifts :virtual-height = frame d-shifts :virtual-height + p-change-value
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
          ,input  string(frame d-shifts :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-shifts :height)
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
    if frame d-shifts :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-shifts :width
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
    if frame d-shifts :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-shifts :width
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
            frame d-shifts :width = v-frame-width
          .
          if frame d-shifts :scrollable = true
          then do:
            assign
              frame d-shifts :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-shifts :scrollable = true
          then do:
            assign
              frame d-shifts :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-shifts :width = v-frame-width
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
      v-frame-width = frame d-shifts :width
      v-frame-virtual-width = frame d-shifts :virtual-width
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
      v-field-group-handle = frame d-shifts :first-child
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
    do with frame d-shifts
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-shifts :scrollable = true
      then do:
        assign
          frame d-shifts :virtual-width = frame d-shifts :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-shifts :width = v-frame-width + p-change-value
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
        frame d-shifts :width = frame d-shifts :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-shifts :scrollable = true
      then do:
        assign
          frame d-shifts :virtual-width = frame d-shifts :virtual-width + p-change-value
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
          ,input  string(frame d-shifts :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-shifts :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-shifts
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-shifts :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-shifts :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-shifts :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-shifts :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-shifts
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
      v-row-delta = v-new-row - frame d-shifts :height
      v-col-delta = v-new-col - frame d-shifts :width
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
            - frame d-shifts :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-shifts :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-shifts :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-shifts :height-chars
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
      v-diasize-current-frame-width  = frame d-shifts :width
      v-diasize-current-frame-height = frame d-shifts :height
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
    do with frame d-shifts
    :
      assign
        v-diasize-orig-frame-height = frame d-shifts :height
        v-diasize-orig-frame-width  = frame d-shifts :width
        v-diasize-browse-handle     = browse br-shift :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-shifts :first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
if sht-mode = 'obj':U then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objat" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return.
  end.
  if not l-shift-on then do:
    message
      vss-workfile vss-revision vss-description skip
      "На объекте выключены смены." skip
      "Работа со сменами невозможна." skip
      "Объект:" p-obj-type p-obj-code skip
      view-as alert-box error .
    return.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметра конфигурации" '"sys-key"' skip
      error-status :get-message( 1 ) skip
      return-value skip
    view-as alert-box error .
    return.
  end.
  is-super = no.
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_super':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  if glog then do:
    is-super = yes.
  end.
  else do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_regular':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  end.
  if not glog then do:
    message
      "Вы не имеете прав для работы со сменами." skip
      "Объект:" p-obj-type p-obj-code
      view-as alert-box.
    return.
  end.
end.
if not is-super
and lookup("b-sel", bttns) = 0
and lookup("b-add", bttns) > 0
then do:
  message
    "Отменить смену может только менеджер." skip
    "Объект:" p-obj-type p-obj-code
    view-as alert-box.
  return.
end.
if p-rid-list <> '':U
and p-rid-list <> ? then do:
  assign
  v-doc-rec = integer(entry(1, p-rid-list))
  p-rid-list = '':U
  no-error .
end.
RUN UI-on no-error.
if error-status:error then return error.
WAIT-FOR GO OF FRAME d-shifts.
END.
RUN disable_UI.
PROCEDURE change-planned-shift :
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num  like ub.shift-obj.shift-num  no-undo .
define input parameter p-shift-name like ub.shift-obj.shift-name no-undo .
define input parameter p-rec AS RECID NO-UNDO .
DEFINE VARIABLE v-loc-doc-rec AS RECID NO-UNDO.
  do
  on error undo, return error
  :
    define buffer buf_shift-obj     for ub.shift-obj.
    assign
      s-date = p-shift-date
      s-num  = p-shift-num
      s-name = p-shift-name
    .
    run gbl/shift.w
      ( input parparentproc
       ,input p-curr-obj-type
       ,input p-curr-obj-code
       ,input-output s-date
       ,input-output e-date
       ,input-output s-time
       ,input-output e-time
       ,input-output s-num
       ,input-output s-name
       ,input "no-time"
       ,output v-cancel
      ) no-error.
    if error-status:error
      or v-cancel = yes
    then do:
      if v-cancel = yes then do:
        undo, return.
      end.
      else do:
        undo, return error "change-planned-shift: Ошибка получения данных для изменения смены." + chr(10) + return-value.
      end.
    end.
    if s-name <> p-shift-name then do:
     run gbl/shtwaicr.p ( INPUT 'ИЗМЕНЕНИЕ':U
                        ,INPUT NO
                        ,INPUT-OUTPUT p-rec
                        ,INPUT p-curr-obj-type
                        ,INPUT p-curr-obj-code
                        ,INPUT p-shift-date
                        ,INPUT p-shift-num
                        ,INPUT s-name) NO-ERROR.
        IF NOT ERROR-STATUS:ERROR
        AND p-rec  <> ? THEN DO:
           v-doc-rec = p-rec.
           run UI-on IN THIS-PROCEDURE NO-ERROR.
        END.
      end.
  end.
END PROCEDURE.
procedure change-close-shift-time:
define input parameter p-rec as recid no-undo.
define buffer bf_shift-obj for ub.shift-obj.
find first bf_shift-obj no-lock where recid(bf_shift-obj) = p-rec.
assign
    s-date = bf_shift-obj.shift-date
    e-date = bf_shift-obj.close-date
    s-time = bf_shift-obj.open-time
    e-time = bf_shift-obj.close-time
    s-num = bf_shift-obj.shift-num
    s-name = bf_shift-obj.shift-name
.
run gbl/shift.w
  ( input parparentproc
   ,input p-curr-obj-type
   ,input p-curr-obj-code
   ,input-output s-date
   ,input-output e-date
   ,input-output s-time
   ,input-output e-time
   ,input-output s-num
   ,input-output s-name
   ,input "edit-time"
   ,output v-cancel
  ) no-error.
  if error-status:error
    or v-cancel = yes
  then do:
    if v-cancel = yes then do:
      undo, return.
    end.
    else do:
      undo, return error "change-closed-shift: Ошибка получения данных для изменения смены." + chr(10) + return-value + chr(10) + error-status:get-message (1).
    end.
  end.
run gbl/sht-set-time.p(
    bf_shift-obj.shift-date,
    bf_shift-obj.shift-num,
    bf_shift-obj.obj-type,
    bf_shift-obj.obj-code,
    e-time,
    s-time
) no-error.
if error-status:error then
    undo, return error "change-closed-shift: Ошибка при изменение времени смены" + chr(10) + return-value + chr(10) + error-status:get-message (1).
run UI-on IN THIS-PROCEDURE NO-ERROR.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME d-shifts.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit B-sel b-add b-chg b-del B-staff B-rep B-param B-hist b-help
         b-mark br-shift
      WITH FRAME d-shifts.
  VIEW FRAME d-shifts.
  OPEN QUERY br-shift FOR EACH X_shift-obj       WHERE X_shift-obj.obj-type = p-obj-type and X_shift-obj.obj-code = p-obj-code NO-LOCK.
END PROCEDURE.
PROCEDURE OpenBr :
run waitfram-show in this-procedure ("Заполняется список. ЖДИТЕ...").
case sht-mode :
  when "all" then do:
    ENABLE b-staff
    WITH FRAME d-shifts.
    frame d-shifts :title = "Все смены системы".
    OPEN QUERY br-shift
      FOR EACH X_shift-obj NO-LOCK
          by X_shift-obj.shift-date descending
          by X_shift-obj.shift-num descending.
  end.
  when "host" then do:
  end.
  when "obj" then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output obj-db-num
  )  .
    if is-super then
      ENABLE
      b-add when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-chg when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-del when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-staff
      B-sel when lookup("b-sel":U, bttns) > 0
      WITH FRAME d-shifts.
    else
    ENABLE
    b-staff WITH FRAME d-shifts.
    frame d-shifts :title = substitute("Смены по объекту: &1&2"
                                            , p-obj-type
                                            ,p-obj-code).
    OPEN QUERY br-shift
      FOR EACH X_shift-obj WHERE
              X_shift-obj.obj-type = p-obj-type and
              X_shift-obj.obj-code = p-obj-code NO-LOCK
          by X_shift-obj.shift-date descending
          by X_shift-obj.shift-num descending.
  end.
end case.
if v-doc-rec <> ? then reposition br-shift to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE buffer buf_shift-obj for ub.shift-obj.
DEFINE VARIABLE v-loc-doc-rec AS RECID NO-UNDO.
assign
  s-date = ?
  s-time = ?
  s-num  = ?
  s-name = ?.
run gbl/shift.w (  input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input-output s-date
             , input-output e-date
             , input-output s-time
             , input-output e-time
             , input-output s-num
             , input-output s-name
             , input "no-time"
             , output v-cancel
            ) no-error.
if error-status:error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Ошибка добавления смены."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return no-apply .
end.
if v-cancel = yes
then do:
    undo, return.
end.
run gbl/shtwaicr.p ( INPUT 'ДОБАВЛЕНИЕ':U
                    ,INPUT NO
                    ,INPUT-OUTPUT v-loc-doc-rec
                    ,INPUT p-curr-obj-type
                    ,INPUT p-curr-obj-code
                    ,INPUT s-date
                    ,INPUT s-num
                    ,INPUT s-name) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
AND v-loc-doc-rec  <> ? THEN DO:
   v-doc-rec = v-loc-doc-rec.
   run UI-on IN THIS-PROCEDURE NO-ERROR.
END.
END PROCEDURE.
PROCEDURE proc-b-rep :
DEFINE INPUT-OUTPUT PARAMETER prep-name as character no-undo.
DEFINE variable mypar as CHARACTER no-undo.
define variable check-html as character no-undo .
define buffer t-shift-obj for ub.shift-obj.
IF NOT AVAIL X_shift-obj then do:
    bell.
    prep-name = "".
    return.
end.
  case prep-name:
    WHEN "g-shift":U
    or
    when "g-ptrlch":U
    or
    when "g-shiftClose":U
    or
    when "g-zmzvit"
    then do:
        IF sht-mode <> "obj" then do:
            message
            "Отчет можно сделать только находясь в списке смен по текущему объекту"
            view-as alert-box ERROR.
            prep-name = "".
            return.
        end.
        FIND FIRST t-shift-obj No-LOCK WHERE
                   recid(t-shift-obj) = recid(X_shift-obj) No-ERROR.
        IF NOT AVAIL t-shift-obj then do:
            message
            substitute("Не найдена смена:&1" +
                       "объект &2&3 смена от &4 номер &5 порядок &6"
                       , chr(10)
                       ,X_shift-obj.obj-type
                       ,X_shift-obj.obj-code
                       ,string(X_shift-obj.shift-date, "99/99/9999")
                       ,X_shift-obj.shift-name
                       ,X_shift-obj.shift-num)
            view-as alert-box ERROR.
            prep-name = "".
            return.
        end.
        if prep-name = "g-shiftClose"
        and t-shift-obj.status_ <>  'зкр':U then do:
            Message
            SUBSTITUTE("На объекте &1&2 смена № &3 порядок &4 от &5&6еще не закрыта&6Чек-лист не сформирован!"
                       ,t-shift-obj.obj-type
                       ,t-shift-obj.obj-code
                       ,t-shift-obj.shift-name
                       ,t-shift-obj.shift-num
                       ,string(t-shift-obj.shift-date,"99/99/9999")
                       ,chr(10)
                       )
            prep-name = "".
            return.
        end.
        if   ( prep-name = "g-shift"
        or   prep-name = "g-zmzvit" )
        and t-shift-obj.status_ <>  'зкр':U then do:
            Message
            SUBSTITUTE("На объекте &1&2 смена № &3 порядок &4 от &5&6еще не закрыта&6Сменный отчет сделать нельзя!"
                       ,t-shift-obj.obj-type
                       ,t-shift-obj.obj-code
                       ,t-shift-obj.shift-name
                       ,t-shift-obj.shift-num
                       ,string(t-shift-obj.shift-date,"99/99/9999")
                       ,chr(10)
                       )
            prep-name = "".
            return.
        end.
        mypar =
            "X-DATE-START = " + string(X_shift-obj.shift-date, "99/99/9999") + chr(44) +
            "X-SHIFT-START = " + string(X_shift-obj.shift-num) + chr(44) +
            "X-OBJ-CODE = " + string(X_shift-obj.obj-code) + chr(44) +
            "X-OBJ-TYPE = " + string(X_shift-obj.obj-type) .
       if prep-name = "g-shift"
       then do:
          run rep/g-new-shift.p
            (input parparentproc
            ,input mypar
            ) .
       end.
      if prep-name = "g-shiftClose" then do:
    define variable vRas as logical no-undo .
    find first shift-param no-lock where shift-param.obj-code = t-shift-obj.obj-code and
        shift-param.obj-type = t-shift-obj.obj-type and
        shift-param.shift-date = t-shift-obj.shift-date and
        shift-param.shift-name = t-shift-obj.shift-name and
        shift-param.shift-num = t-shift-obj.shift-num and (shift-param.error-mass or
        shift-param.error-paid-trans) no-error .
        if available (shift-param) then vRas = true .
          run rep/r-shiftClose.p
            (input X_shift-obj.host-code
            ,input mypar
            ,input false
            ,input vRas
            ,input true
            ,output check-html
            ) .
      end.
       if prep-name = "g-ptrlch"
       then do:
        run rep/g-ptrlch.p
          (input parparentproc
          ,input mypar
          ) .
       end.
       if prep-name = "g-zmzvit"
       then do:
         run rep/g-zmzvit.p
           (input parparentproc
           ) no-error .
       end.
    END.
  end case.
  prep-name = "".
END PROCEDURE.
PROCEDURE UI-on :
ASSIGN b-rep:POPUP-MENU IN FRAME d-shifts = MENU menu-b-rep:HANDLE.
ASSIGN b-rep:MENU-MOUSE = 1.
if parcall-point = "rep/e-shift.w":U
or parcall-point = "rep/r-ptrlch.p":U
or parcall-point = "e-zmzvit.w":U
then
assign
menu-item mi-petrol:sensitive  in menu menu-b-rep = no
menu-item mi-ptrlch:sensitive  in menu menu-b-rep = no
menu-item mi-closeShift:sensitive  in menu menu-b-rep = no
.
else do:
   if lookup( v-sys-key, "Astral_UKR,Lila_UKR," + 'ExpertekIBS':U  ) > 0
   then do:
      define variable h_menu_item as handle no-undo.
      create menu-item h_menu_item
      assign
         parent      = menu menu-b-rep:handle
         label       = "Сменный отчет АЗС (Украина)"
         sensitive   = TRUE
         triggers :
            ON choose PERSISTENT RUN smenUcr IN THIS-PROCEDURE.
         end triggers.
   end.
end.
ENABLE
b-quit
b-help
b-rep
br-shift
b-hist
b-param
B-sel when lookup("b-sel":U, bttns) > 0
WITH FRAME d-shifts.
VIEW FRAME d-shifts.
if lookup("b-mark":U, bttns) > 0
then do :
  display b-mark WITH FRAME d-shifts.
  enable b-mark WITH FRAME d-shifts.
end .
else do :
  disable b-mark WITH FRAME d-shifts.
  hide b-mark in FRAME d-shifts.
end .
RUN OpenBr IN THIS-PROCEDURE.
END PROCEDURE.
procedure smenUcr:
   rep-name = "g-zmzvit":U.
   run proc-b-rep in this-procedure ( input-output rep-name ) no-error .
   if error-status :error then do: return no-apply. end.
end.
PROCEDURE local-mark :
if not available X_shift-obj then
do:
    message "Неправильный выбор строки.".
    return .
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid19 as character no-undo .
define variable v-num-entry19 as integer   no-undo .
assign
  v-str-recid19 = trim( string( recid( X_shift-obj ) , "->>>>>>>>>>>9":U ) )
  v-num-entry19 = lookup( v-str-recid19 , p-rid-list )
.
if v-num-entry19 > 0 then do:
  assign
    entry( v-num-entry19, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid19
  .
end.
br-shift:refresh() in frame d-shifts .
END PROCEDURE.
