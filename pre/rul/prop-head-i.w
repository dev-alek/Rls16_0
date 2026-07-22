DEFINE BUFFER locked_prop-head FOR ub.prop-head.
DEFINE TEMP-TABLE tt-prop-head NO-UNDO LIKE ub.prop-head.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-head".
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
DEFINE BUFFER FIRST_prop-head FOR dictdb.prop-head.
DEFINE BUFFER buf_prop-head FOR dictdb.prop-head.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-general-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-general-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-general-view-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-general-view-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-select-general AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE cb-select-general-view AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE f-get-hist-from-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Принимает историю из чужих БД"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-hist-from-prim AS CHARACTER FORMAT "X(256)":U INITIAL "Запись истории при изменении"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-hist-to-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Передача истории в другие БД"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-nws-to-cd AS CHARACTER FORMAT "X(256)":U INITIAL "Активация пер-чи на кассу из СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-nws-to-hist AS CHARACTER FORMAT "X(256)":U INITIAL "Создание истории при приходе СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-smart-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Смарт-передача через СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE list-general AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "1","1"
     SIZE 24 BY 8 NO-UNDO.
DEFINE VARIABLE list-general-view AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "1","1"
     SIZE 24 BY 6.13 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-prop-head SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-head.dtm-code AT ROW 1 COL 34 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     B-Help AT ROW 1 COL 54.9
     tt-prop-head.prop-name AT ROW 2.33 COL 9 COLON-ALIGNED WIDGET-ID 4
          LABEL "Название" FORMAT "X(255)"
          VIEW-AS FILL-IN NATIVE
          SIZE 87 BY 1
     tt-prop-head.prop-label AT ROW 3.57 COL 9 COLON-ALIGNED WIDGET-ID 6
          LABEL "Лейбл" FORMAT "X(255)"
          VIEW-AS FILL-IN NATIVE
          SIZE 87 BY 1
     tt-prop-head.prop-des AT ROW 5.8 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4.77
     f-hist-from-prim AT ROW 10.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     tt-prop-head.hist-from-prim AT ROW 10.87 COL 76.5 NO-LABEL WIDGET-ID 52
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place AT ROW 11.13 COL 16 COLON-ALIGNED WIDGET-ID 14
          LABEL "Хранение глоб" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-hist-to-nws AT ROW 11.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     tt-prop-head.hist-to-nws AT ROW 11.87 COL 76.5 NO-LABEL WIDGET-ID 58
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place-host AT ROW 12.37 COL 16 COLON-ALIGNED WIDGET-ID 16
          LABEL "Хранение фирма" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-nws-to-hist AT ROW 12.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     tt-prop-head.nws-to-hist AT ROW 12.87 COL 76.5 NO-LABEL WIDGET-ID 64
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place-obj AT ROW 13.63 COL 16 COLON-ALIGNED WIDGET-ID 18
          LABEL "Хранение объект" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-smart-nws AT ROW 13.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     tt-prop-head.smart-nws AT ROW 13.87 COL 76.5 NO-LABEL WIDGET-ID 70
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     f-get-hist-from-nws AT ROW 14.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 98
     tt-prop-head.get-hist-from-nws AT ROW 14.87 COL 76.5 NO-LABEL WIDGET-ID 76
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     list-general AT ROW 15.13 COL 25.5 NO-LABEL WIDGET-ID 34
     f-nws-to-cd AT ROW 15.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     tt-prop-head.nws-to-cd AT ROW 15.87 COL 76.5 NO-LABEL WIDGET-ID 84
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     cb-select-general AT ROW 16 COL 1 NO-LABEL WIDGET-ID 32
     b-general-add AT ROW 17 COL 1 WIDGET-ID 44
     b-general-del AT ROW 17 COL 15.5 WIDGET-ID 48
     list-general-view AT ROW 17 COL 75.5 NO-LABEL WIDGET-ID 38
     tt-prop-head.ref-type AT ROW 18.87 COL 1.5 NO-LABEL WIDGET-ID 102
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 23.5 BY 4.4
     cb-select-general-view AT ROW 19 COL 51 NO-LABEL WIDGET-ID 36
     b-general-view-add AT ROW 19.93 COL 51 WIDGET-ID 46
     b-general-view-del AT ROW 19.93 COL 65.5 WIDGET-ID 50
     "Описание" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 4.83 COL 2.5 WIDGET-ID 10
     "Предназначение" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 15 COL 1 WIDGET-ID 40
          FGCOLOR 3
     "Представление" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 18 COL 51 WIDGET-ID 42
          FGCOLOR 3
     "Тип итогов/срезов" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 18.07 COL 1 WIDGET-ID 106
          FGCOLOR 3
     SPACE(74.69) SKIP(4.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объект rule-машины"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-get-hist-from-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-hist-from-prim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-hist-to-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-nws-to-cd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-nws-to-hist:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-smart-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-general-add IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF cb-select-general = '':U THEN DO:
    MESSAGE
    "Нечего добавлять"
    VIEW-AS ALERT-BOX ERROR.
    RETURN  NO-APPLY.
  END.
  IF LOOKUP(cb-select-general, list-general) > 0 THEN DO:
      MESSAGE
      "Объект уже имеет данное предназначение"
      VIEW-AS ALERT-BOX ERROR.
      RETURN  NO-APPLY.
  END.
    glog = list-general:ADD-LAST((if lookup (cb-select-general, 'dis-card-type,Loyalty,dc-storage,dc-prop,goods':U) > 0 then entry (lookup (cb-select-general, 'dis-card-type,Loyalty,dc-storage,dc-prop,goods':U), 'Типы ДК,Система Лояльности,Св-ва и итоги по ДК,Св-ва ДК,Товары':U) else cb-select-general), cb-select-general) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
  DISPLAY
  list-general
  WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-general-del IN FRAME Dialog-Frame
DO:
  IF list-general:SCREEN-VALUE  = '':U
  OR list-general:SCREEN-VALUE  = ?
  OR list-general:IS-SELECTED(INPUT FRAME Dialog-Frame list-general) = NO
  THEN DO:
     MESSAGE
     "Нечего удалять"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  list-general:DELETE(INPUT FRAME Dialog-Frame list-general).
END.
ON CHOOSE OF b-general-view-add IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    IF cb-select-general-view = '':U THEN DO:
      MESSAGE
      "Нечего добавлять"
      VIEW-AS ALERT-BOX ERROR.
      RETURN  NO-APPLY.
    END.
    IF LOOKUP(cb-select-general-view, list-general-view) > 0 THEN DO:
        MESSAGE
        "Объект уже имеет данное предназначение"
        VIEW-AS ALERT-BOX ERROR.
        RETURN  NO-APPLY.
    END.
        glog = list-general-view:ADD-LAST((if lookup (cb-select-general-view, 'dis-card-type,Loyalty,Loyalty2,dc-storage,dc-prop,goods':U) > 0 then entry (lookup (cb-select-general-view, 'dis-card-type,Loyalty,Loyalty2,dc-storage,dc-prop,goods':U), 'Типы ДК,Система Лояльности,Система Лояльности,Св-ва и итоги по ДК,Св-ва ДК,Товары':U) else cb-select-general-view), cb-select-general-view) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
    END.
    DISPLAY
    list-general-view
    WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-general-view-del IN FRAME Dialog-Frame
DO:
  IF list-general-view:SCREEN-VALUE = '':U
  OR list-general-view:SCREEN-VALUE  = ?
  OR list-general-view:IS-SELECTED(INPUT FRAME Dialog-Frame list-general-view) = NO
  THEN DO:
     MESSAGE
     "Нечего удалять"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  list-general-view:DELETE(INPUT FRAME Dialog-Frame list-general-view).
END.
ON VALUE-CHANGED OF cb-select-general IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-select-general.
END.
ON VALUE-CHANGED OF cb-select-general-view IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-select-general-view.
END.
ON VALUE-CHANGED OF tt-prop-head.ref-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-head.ref-type.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST first_prop-head EXCLUSIVE-LOCK.
    CREATE tt-prop-head.
  END.
  else do:
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      FIND FIRST LOCKED_prop-head EXCLUSIVE-LOCK WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code .
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_prop-head no-LOCK WHERE
                  LOCKED_prop-head.dtm-code = p-dtm-code NO-ERROR.
    END.
    create tt-prop-head.
    buffer-copy locked_prop-head to tt-prop-head.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-prop-head SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-hist-from-prim f-hist-to-nws f-nws-to-hist f-smart-nws
          f-get-hist-from-nws list-general f-nws-to-cd cb-select-general
          list-general-view cb-select-general-view
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-head THEN
    DISPLAY tt-prop-head.dtm-code tt-prop-head.prop-name tt-prop-head.prop-label
          tt-prop-head.prop-des tt-prop-head.hist-from-prim
          tt-prop-head.storage-place tt-prop-head.hist-to-nws
          tt-prop-head.storage-place-host tt-prop-head.nws-to-hist
          tt-prop-head.storage-place-obj tt-prop-head.smart-nws
          tt-prop-head.get-hist-from-nws tt-prop-head.nws-to-cd
          tt-prop-head.ref-type
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-head.dtm-code B-Help tt-prop-head.prop-name
         tt-prop-head.prop-label tt-prop-head.prop-des f-hist-from-prim
         tt-prop-head.hist-from-prim tt-prop-head.storage-place f-hist-to-nws
         tt-prop-head.hist-to-nws tt-prop-head.storage-place-host f-nws-to-hist
         tt-prop-head.nws-to-hist tt-prop-head.storage-place-obj f-smart-nws
         tt-prop-head.smart-nws f-get-hist-from-nws
         tt-prop-head.get-hist-from-nws list-general f-nws-to-cd
         tt-prop-head.nws-to-cd cb-select-general b-general-add b-general-del
         list-general-view tt-prop-head.ref-type cb-select-general-view
         b-general-view-add b-general-view-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-general AS character  NO-UNDO.
DEFINE VARIABLE v-general-view AS character  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
DEFINE VARIABLE v-dop AS CHARACTER.
v-dop = "Не предусмотрено,,".
DO v-ii = 1 TO NUM-ENTRIES('blank,period,sel-goods,one-ptrl':U):
   ASSIGN
   v-dop = v-dop + ENTRY(v-ii, '_,Период дат,Опред.товары,Вид топлива':U) + chr(44) +
           ENTRY(v-ii, 'blank,period,sel-goods,one-ptrl':U) + chr(44).
END.
ASSIGN
v-dop = TRIM(v-dop, chr(44)).
ASSIGN
tt-prop-head.ref-type:radio-buttons IN FRAME Dialog-Frame = v-dop.
ASSIGN
tt-prop-head.get-hist-from-nws:RADIO-BUTTONS IN FRAME Dialog-Frame = 'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
tt-prop-head.hist-from-prim:RADIO-BUTTONS IN FRAME Dialog-Frame = 'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
tt-prop-head.hist-to-nws:RADIO-BUTTONS IN FRAME Dialog-Frame =  'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
tt-prop-head.nws-to-cd:RADIO-BUTTONS IN FRAME Dialog-Frame =  'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
tt-prop-head.nws-to-hist:RADIO-BUTTONS IN FRAME Dialog-Frame =  'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
tt-prop-head.smart-nws:RADIO-BUTTONS IN FRAME Dialog-Frame = 'Всегда,10,Да,0,Нет,-1,Смарт2,1,Никогда,-10':U
.
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-head.general):
  assign
  v-general = v-general + chr(44) +
              (if lookup (ENTRY(v-ii, tt-prop-head.general), 'dis-card-type,Loyalty,dc-storage,dc-prop,goods':U) > 0 then entry (lookup (ENTRY(v-ii, tt-prop-head.general), 'dis-card-type,Loyalty,dc-storage,dc-prop,goods':U), 'Типы ДК,Система Лояльности,Св-ва и итоги по ДК,Св-ва ДК,Товары':U) else ENTRY(v-ii, tt-prop-head.general)) + chr(44) +
               ENTRY(v-ii, tt-prop-head.general).
END.
v-general = LEFT-TRIM(v-general, chr(44)).
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-head.general-view):
  assign
  v-general-view = v-general-view + chr(44) +
              (if lookup (ENTRY(v-ii, tt-prop-head.general-view), 'dis-card-type,Loyalty,Loyalty2,dc-storage,dc-prop,goods':U) > 0 then entry (lookup (ENTRY(v-ii, tt-prop-head.general-view), 'dis-card-type,Loyalty,Loyalty2,dc-storage,dc-prop,goods':U), 'Типы ДК,Система Лояльности,Система Лояльности,Св-ва и итоги по ДК,Св-ва ДК,Товары':U) else ENTRY(v-ii, tt-prop-head.general-view)) + chr(44) +
               ENTRY(v-ii, tt-prop-head.general-view).
END.
v-general-view = LEFT-TRIM(v-general-view, chr(44)).
IF v-general <> '':U THEN DO:
  ASSIGN
  list-general:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-general.
END.
ELSE DO:
  ASSIGN
  list-general:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = ",".
END.
IF v-general-view <> '':U THEN DO:
  ASSIGN
  list-general-view:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-general-view.
END.
ELSE DO:
  ASSIGN
  list-general-view:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = ",".
END.
ASSIGN
cb-select-general:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = 'Типы ДК,dis-card-type,Система Лояльности,Loyalty,Св-ва и итоги по ДК,dc-storage,Св-ва ДК,dc-prop,Товары,goods':U
cb-select-general-view:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = 'Типы ДК,dis-card-type,Система Лояльности,Loyalty,Система Лояльности,Loyalty2,Св-ва и итоги по ДК,dc-storage,Св-ва ДК,dc-prop,Товары,goods':U
.
DISPLAY
f-get-hist-from-nws
f-hist-from-prim
f-hist-to-nws
f-nws-to-cd
f-nws-to-hist
f-smart-nws
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-prop-head THEN
DISPLAY
tt-prop-head.dtm-code
tt-prop-head.prop-name
tt-prop-head.prop-label
tt-prop-head.prop-des
tt-prop-head.storage-place
tt-prop-head.storage-place-host
tt-prop-head.storage-place-obj
tt-prop-head.hist-from-prim
tt-prop-head.hist-to-nws
tt-prop-head.nws-to-hist
tt-prop-head.nws-to-cd
tt-prop-head.smart-nws
tt-prop-head.get-hist-from-nws
tt-prop-head.ref-type
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-prop-head.dtm-code  WHEN p-mode = 'ДОБАВЛЕНИЕ':U
tt-prop-head.prop-name  WHEN p-mode <> 'ПРОСМОТР':U
tt-prop-head.prop-label  WHEN p-mode <> 'ПРОСМОТР':U
tt-prop-head.prop-des    WHEN p-mode <> 'ПРОСМОТР':U
tt-prop-head.storage-place WHEN p-mode = 'ДОБАВЛЕНИЕ':U
tt-prop-head.storage-place-host WHEN p-mode = 'ДОБАВЛЕНИЕ':U
tt-prop-head.storage-place-obj  WHEN p-mode = 'ДОБАВЛЕНИЕ':U
tt-prop-head.hist-from-prim    WHEN (p-mode <> 'ПРОСМОТР':U AND (
     tt-prop-head.hist-from-prim <> INTEGER('10':U)
 AND tt-prop-head.hist-from-prim <> INTEGER('-10':U) ))
tt-prop-head.hist-to-nws       WHEN (p-mode <> 'ПРОСМОТР':U AND (
    tt-prop-head.hist-to-nws <> INTEGER('10':U)
 AND tt-prop-head.hist-to-nws <> INTEGER('-10':U) ))
tt-prop-head.nws-to-hist       WHEN (p-mode <> 'ПРОСМОТР':U AND (
    tt-prop-head.nws-to-hist <> INTEGER('10':U)
 AND tt-prop-head.nws-to-hist <> INTEGER('-10':U) ))
tt-prop-head.nws-to-cd         WHEN (p-mode <> 'ПРОСМОТР':U AND (
    tt-prop-head.nws-to-cd <> INTEGER('10':U)
 AND tt-prop-head.nws-to-cd <> INTEGER('-10':U) ))
tt-prop-head.smart-nws         WHEN (p-mode <> 'ПРОСМОТР':U AND (
    tt-prop-head.smart-nws <> INTEGER('10':U)
 AND tt-prop-head.smart-nws <> INTEGER('-10':U) ))
tt-prop-head.get-hist-from-nws WHEN (p-mode <> 'ПРОСМОТР':U AND (
    tt-prop-head.get-hist-from-nws <> INTEGER('10':U)
 AND tt-prop-head.get-hist-from-nws <> INTEGER('-10':U) ))
b-general-add WHEN p-mode <> 'ПРОСМОТР':U
b-general-del WHEN p-mode <> 'ПРОСМОТР':U
b-general-view-add WHEN p-mode <> 'ПРОСМОТР':U
b-general-view-del WHEN p-mode <> 'ПРОСМОТР':U
CB-select-general WHEN p-mode <> 'ПРОСМОТР':U
CB-select-general-view WHEN p-mode <> 'ПРОСМОТР':U
tt-prop-head.ref-type WHEN p-mode <> 'ПРОСМОТР':U
list-general
list-general-view
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
IF p-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-general-add
  b-general-view-add
  b-general-del
  b-general-view-del
  cb-select-general
  cb-select-general-view
  b-exit
  IN FRAME Dialog-Frame.
  ASSIGN
  b-quit:LABEL = "&Отмена"
  b-quit:COLUMN = 1.
END.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
DEFINE VARIABLE v-general AS character  NO-UNDO.
DEFINE VARIABLE v-general-view AS character  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME Dialog-Frame
tt-prop-head.dtm-code
tt-prop-head.prop-name
tt-prop-head.prop-label
tt-prop-head.prop-des
tt-prop-head.ref-type
tt-prop-head.storage-place
tt-prop-head.storage-place-host
tt-prop-head.storage-place-obj
.
IF  tt-prop-head.hist-from-prim <> INTEGER('10':U)
AND tt-prop-head.hist-from-prim <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.hist-from-prim .
END.
IF  tt-prop-head.hist-to-nws <> INTEGER('10':U)
AND tt-prop-head.hist-to-nws <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.hist-to-nws .
END.
IF  tt-prop-head.nws-to-cd <> INTEGER('10':U)
AND tt-prop-head.nws-to-cd <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.nws-to-cd .
END.
IF  tt-prop-head.nws-to-hist <> INTEGER('10':U)
AND tt-prop-head.nws-to-hist <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.nws-to-hist.
END.
IF  tt-prop-head.smart-nws <> INTEGER('10':U)
AND tt-prop-head.smart-nws <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.smart-nws .
END.
IF  tt-prop-head.get-hist-from-nws <> INTEGER('10':U)
AND tt-prop-head.get-hist-from-nws <> INTEGER('-10':U) THEN DO:
 ASSIGN
 tt-prop-head.get-hist-from-nws .
END.
DO v-ii = 1 TO NUM-ENTRIES(list-general:LIST-ITEM-PAIRS IN FRAME Dialog-Frame) BY 2:
  v-general = v-general + chr(44) +  entry(v-ii + 1, list-general:LIST-ITEM-PAIRS IN FRAME Dialog-Frame).
END.
v-general = TRIM(v-general, chr(44)).
tt-prop-head.general = v-general.
 .
DO v-ii = 1 TO NUM-ENTRIES(list-general-view:LIST-ITEM-PAIRS IN FRAME Dialog-Frame)  BY 2:
  v-general-view = v-general-view + chr(44) +  entry(v-ii + 1, list-general-view:LIST-ITEM-PAIRS IN FRAME Dialog-Frame).
END.
v-general-view = TRIM(v-general-view, chr(44)).
tt-prop-head.general-view = v-general-view.
 .
run rul/prop-head1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-head.dtm-code
                ,INPUT tt-prop-head.prop-name
                ,INPUT tt-prop-head.prop-label
                ,INPUT tt-prop-head.prop-des
                ,INPUT tt-prop-head.ref-type
                ,INPUT tt-prop-head.storage-place
                ,INPUT tt-prop-head.storage-place-host
                ,INPUT tt-prop-head.storage-place-obj
                ,INPUT tt-prop-head.hist-from-prim
                ,INPUT tt-prop-head.hist-to-nws
                ,INPUT tt-prop-head.get-hist-from-nws
                ,INPUT tt-prop-head.nws-to-hist
                ,INPUT tt-prop-head.smart-nws
                ,INPUT tt-prop-head.nws-to-cd
                ,INPUT tt-prop-head.general
                ,INPUT tt-prop-head.general-view
) no-error.
if error-status:error then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.
