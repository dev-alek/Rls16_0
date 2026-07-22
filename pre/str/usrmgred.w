define input  parameter parparentproc               as widget-handle no-undo .
define input  parameter p-db-num                    as integer   no-undo .
define input  parameter p-user-id                   as character no-undo .
define input  parameter p-menu-code                 as integer   no-undo .
define input  parameter p-menu-group-code           as integer   no-undo .
define input  parameter p-menu-group-context        as character no-undo .
define input  parameter p-host-code                 as integer   no-undo .
define input  parameter p-obj-type                  as character no-undo .
define input  parameter p-obj-code                  as integer   no-undo .
define output parameter p-update-data               as logical   no-undo .
define output parameter p-output-menu-code          as integer   no-undo .
define output parameter p-output-menu-group-code    as integer   no-undo .
define output parameter p-output-menu-group-context as character no-undo .
define output parameter p-output-host-code          as integer   no-undo .
define output parameter p-output-obj-type           as character no-undo .
define output parameter p-output-obj-code           as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование пользовательской группы меню".
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
define variable v-select-menu-group-code    as integer   no-undo .
define variable v-select-menu-group-context as character no-undo .
define variable v-select-host-code          as integer   no-undo .
define variable v-select-obj-type           as character no-undo .
define variable v-select-obj-code           as integer   no-undo .
define temp-table temp-menu-group-id no-undo
  field menu-group-id as character
  field item-value    as character
  index xpk is primary unique menu-group-id
  index xie1 item-value
  .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON r-sel-host
     LABEL "Выбор фирмы"
     SIZE 19.5 BY .88 TOOLTIP "Выбор фирмы".
DEFINE BUTTON r-sel-obj
     LABEL "Выбор объекта"
     SIZE 19.5 BY .88 TOOLTIP "Выбор объекта".
DEFINE VARIABLE cb-menu-group-id AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 52 BY 1 NO-UNDO.
DEFINE VARIABLE fi-host-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-host-label AS CHARACTER FORMAT "X(256)":U INITIAL "Фирма:"
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE fi-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-label AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-cntxt-level AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без фирмы, объекта", 1,
"Только фирма", 2,
"Фирма и объект", 3
     SIZE 22 BY 7.5
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 4
     b-help AT ROW 1 COL 61
     cb-menu-group-id AT ROW 2.5 COL 1 COLON-ALIGNED NO-LABEL
     rs-cntxt-level AT ROW 4.25 COL 3 NO-LABEL
     r-sel-host AT ROW 7.63 COL 51.13
     r-sel-obj AT ROW 10.13 COL 51.25
     fi-host-label AT ROW 7.75 COL 24 COLON-ALIGNED NO-LABEL
     fi-host-name AT ROW 7.75 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-host-description AT ROW 8.79 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-obj-label AT ROW 10.25 COL 24 COLON-ALIGNED NO-LABEL
     fi-obj-name AT ROW 10.25 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-obj-description AT ROW 11.29 COL 32.5 COLON-ALIGNED NO-LABEL
     SPACE(0.74) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор фирмы, объекта".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run select-context in this-procedure
    no-error .
  if error-status :error then do:
    return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF cb-menu-group-id IN FRAME Dialog-Frame
DO:
  assign
    cb-menu-group-id
    .
  run change-menu-group-id in this-procedure .
END.
ON CHOOSE OF r-sel-host IN FRAME Dialog-Frame
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
  run proc-sel-host in this-procedure .
END.
ON CHOOSE OF r-sel-obj IN FRAME Dialog-Frame
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
  run proc-sel-obj in this-procedure .
END.
ON VALUE-CHANGED OF rs-cntxt-level IN FRAME Dialog-Frame
DO:
  assign
    rs-cntxt-level
  .
  run update-cntxt-level in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  v-select-menu-group-context = p-menu-group-context
  v-select-host-code          = p-host-code
  v-select-obj-type           = p-obj-type
  v-select-obj-code           = p-obj-code
.
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
  RUN enable_UI.
  run get-default-context in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE change-menu-group-id :
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-menu-group-id for temp-menu-group-id .
    find first buf_temp-menu-group-id
      where buf_temp-menu-group-id.item-value = cb-menu-group-id
      .
    assign
      v-select-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-menu-group-id rs-cntxt-level fi-host-label fi-host-name
          fi-host-description fi-obj-label fi-obj-name fi-obj-description
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help cb-menu-group-id rs-cntxt-level r-sel-host
         r-sel-obj fi-host-label fi-host-name fi-host-description fi-obj-label
         fi-obj-name fi-obj-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-menu-group-list :
  define variable v-local-number as integer   no-undo .
  define variable v-menu-name    as character no-undo .
  define buffer buf_menu-group for ub.menu-group .
  define buffer buf_temp-menu-group-id for temp-menu-group-id .
  do
  on error undo, return error return-value
  :
    assign
      v-local-number = 0
    .
    for each buf_temp-menu-group-id
    on error undo, return error return-value
    :
      delete buf_temp-menu-group-id .
    end.
    for each buf_menu-group
      where buf_menu-group.menu-code = p-menu-code
    on error undo, return error return-value
    :
      assign
        v-local-number = v-local-number + 1
      .
      assign
        v-menu-name = replace(buf_menu-group.menu-group-name, ',':U, '':U)
        v-menu-name = replace(v-menu-name, '&':U, '':U)
      .
      create buf_temp-menu-group-id .
      assign
        buf_temp-menu-group-id.menu-group-id  = string(buf_menu-group.menu-group-code)
        buf_temp-menu-group-id.item-value     = v-menu-name
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-default-context :
  define buffer buf_temp-menu-group-id for temp-menu-group-id .
  do
  on error undo, return error return-value
  :
    assign
      fi-host-name        = '':U
      fi-host-description = '':U
      fi-obj-name         = '':U
      fi-obj-description  = '':U
    .
    case v-select-menu-group-context
    :
      when 'global':U
      then do:
        assign
          rs-cntxt-level = 1
        .
        hide
          fi-host-name        in frame Dialog-Frame
          fi-host-description in frame Dialog-Frame
          r-sel-host          in frame Dialog-Frame
          fi-obj-name         in frame Dialog-Frame
          fi-obj-description  in frame Dialog-Frame
          r-sel-obj           in frame Dialog-Frame
          .
        display
          rs-cntxt-level
          with frame Dialog-Frame .
      end.
      when 'firm':U
      then do:
        assign
          rs-cntxt-level = 2
        .
        run set-host-variables in this-procedure
          (input  'орг':U
          ,input  v-select-host-code
          ) .
        hide
          fi-obj-name        in frame Dialog-Frame
          fi-obj-description in frame Dialog-Frame
          r-sel-obj          in frame Dialog-Frame
          .
        display
          rs-cntxt-level
          fi-host-name fi-host-description r-sel-host
          with frame Dialog-Frame .
        enable
          r-sel-host
          with frame Dialog-Frame .
      end.
      when 'object':U
      then do:
        assign
          rs-cntxt-level = 3
        .
        run set-host-variables in this-procedure
          (input  'орг':U
          ,input  v-select-host-code
          ) .
        run set-obj-variables in this-procedure
          (input  v-select-obj-type
          ,input  v-select-obj-code
          ).
        display
          rs-cntxt-level
          fi-host-name fi-host-description r-sel-host
          fi-obj-name fi-obj-description r-sel-obj
          with frame Dialog-Frame .
        enable
          r-sel-host
          r-sel-obj
          with frame Dialog-Frame .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение конектста" skip
          "Значение контекста" v-select-menu-group-context skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    run fill-menu-group-list in this-procedure .
    run update-cb-menu-group-id-list-items in this-procedure .
  end.
END PROCEDURE.
PROCEDURE proc-sel-host :
  define variable v-user-select      as logical   no-undo .
  define variable v-choose-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if  v-user-select      = true
    and v-select-host-code <> v-choose-host-code
    then do:
      assign
        v-select-host-code = v-choose-host-code
        v-select-obj-type  = '':U
        v-select-obj-code  = 0
      .
      run set-host-variables in this-procedure
        (input  'орг':U
        ,input  v-select-host-code
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-obj-type
        ,input  v-select-obj-code
        ) .
      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame Dialog-Frame .
    end.
  end.
END PROCEDURE.
PROCEDURE proc-sel-obj :
  define variable v-rid-list as character no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    run ref/cli-all.w
      (input  parparentproc
      ,input  'b-sel':U
      ,input  (if v-cntxt-db-num = 0 then 'объект':U else "db":U)
      ,input  'все':U
      ,input  'текущие':U
      ,input  ?
      ,input  ',,,,,,NO,,'
      ,input  'lock-cli-type':U
      ,output v-rid-list
      ).
   if v-rid-list = '':U
   then do:
     return.
   end.
   else do:
    find first buf_clients no-lock
      where recid(buf_clients) = integer(entry(1, v-rid-list)).
      assign
        v-select-obj-type = buf_clients.obj-type
        v-select-obj-code = buf_clients.obj-code
      .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-select-obj-type
  ,input  v-select-obj-code
  ,output v-select-host-code
  )  .
      run set-host-variables in this-procedure
        (input  'орг':U
        ,input  v-select-host-code
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-obj-type
        ,input  v-select-obj-code
        ) .
      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame Dialog-Frame .
   end.
  end.
END PROCEDURE.
PROCEDURE select-context :
  do
  on error undo, return error return-value
  :
    case rs-cntxt-level
    :
      when 1
      then do:
        assign
          p-output-menu-group-context  = 'global':U
          p-output-host-code           = 0
          p-output-obj-type            = '':u
          p-output-obj-code            = 0
        .
      end.
      when 2
      then do:
        if v-select-host-code = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure .
          undo, return error return-value .
        end.
        assign
          p-output-menu-group-context = 'firm':U
          p-output-host-code          = v-select-host-code
          p-output-obj-type           = '':u
          p-output-obj-code           = 0
        .
      end.
      when 3
      then do:
        if v-select-host-code = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure .
          undo, return error return-value .
        end.
        if v-select-obj-type = '':U
        or v-select-obj-code = 0
        then do:
          message
            "Не задан объект" skip
            view-as alert-box error .
          run proc-sel-obj in this-procedure .
          undo, return error return-value .
        end.
        assign
          p-output-menu-group-context = 'object':U
          p-output-host-code          = v-select-host-code
          p-output-obj-type           = v-select-obj-type
          p-output-obj-code           = v-select-obj-code
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной rs-cntxt-level" skip
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    assign
      p-output-menu-code       = p-menu-code
      p-output-menu-group-code = v-select-menu-group-code
    .
    assign
      p-update-data = true
    .
  end.
END PROCEDURE.
PROCEDURE set-host-state :
  define input  parameter p-host-show as logical   no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if p-host-show = true
      then do:
        assign
          fi-host-label       :visible   = true
          fi-host-name        :visible   = true
          fi-host-description :visible   = true
          r-sel-host          :visible   = true
          r-sel-host          :sensitive = true
        .
      end.
      else do:
        assign
          fi-host-label       :visible   = false
          fi-host-name        :visible   = false
          fi-host-description :visible   = false
          r-sel-host          :sensitive = false
          r-sel-host          :visible   = false
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE set-host-variables :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-host-name        = substitute('&1 &2':U
                                        ,buf_clients.obj-type
                                        ,buf_clients.obj-code
                                        )
        fi-host-description = buf_clients.obj-name
      .
    end.
  end.
END PROCEDURE.
PROCEDURE set-obj-state :
  define input  parameter p-obj-show as logical   no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if p-obj-show = true
      then do:
        assign
          fi-obj-label       :visible   = true
          fi-obj-name        :visible   = true
          fi-obj-description :visible   = true
          r-sel-obj          :visible   = true
          r-sel-obj          :sensitive = true
        .
      end.
      else do:
        assign
          fi-obj-label       :visible   = false
          fi-obj-name        :visible   = false
          fi-obj-description :visible   = false
          r-sel-obj          :sensitive = false
          r-sel-obj          :visible   = false
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE set-obj-variables :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj-name        = substitute('&1 &2':U
                                        ,buf_clients.obj-type
                                        ,buf_clients.obj-code
                                        )
        fi-obj-description = buf_clients.obj-name
      .
    end.
    else do:
      assign
        fi-obj-name        = '':U
        fi-obj-description = '':U
      .
    end.
  end.
END PROCEDURE.
PROCEDURE update-cb-menu-group-id-list-items :
  define variable v-list-items as character no-undo .
  define buffer buf_temp-menu-group-id for temp-menu-group-id .
  do
  on error undo, return error return-value
  :
    assign
      v-list-items = '':U
    .
    for each buf_temp-menu-group-id
    :
      assign
        v-list-items = v-list-items
                     + (if v-list-items <> '':U then ',':U else '':U)
                     + buf_temp-menu-group-id.item-value
      .
    end.
    do with frame Dialog-Frame
    :
      assign
        cb-menu-group-id :list-items = v-list-items
      .
      if v-list-items <> '':U
      then do:
        find first buf_temp-menu-group-id
          where buf_temp-menu-group-id.menu-group-id = string(p-menu-group-code)
          no-error .
        if available buf_temp-menu-group-id
        then do:
          assign
            v-select-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
            cb-menu-group-id         = buf_temp-menu-group-id.item-value
          .
        end.
        else do:
          assign
            cb-menu-group-id = entry(1, cb-menu-group-id :list-items)
          .
          run change-menu-group-id in this-procedure .
        end.
        display
          cb-menu-group-id
          with frame Dialog-Frame .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-cntxt-level :
  define variable v-host-show as logical   no-undo .
  define variable v-obj-show  as logical   no-undo .
  do
  on error undo, return error return-value
  :
    case rs-cntxt-level
    :
      when 1
      then do:
        assign
          v-host-show = false
          v-obj-show  = false
        .
      end.
      when 2
      then do:
        assign
          v-host-show = true
          v-obj-show  = false
        .
      end.
      when 3
      then do:
        assign
          v-host-show = true
          v-obj-show  = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной контекста" skip
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    run set-host-state in this-procedure
      (input  v-host-show
      ) .
    run set-obj-state in this-procedure
      (input  v-obj-show
      ) .
    case rs-cntxt-level
    :
      when 1
      then do:
      end.
      when 2
      then do:
        if v-select-host-code = 0
        then do:
          run proc-sel-host in this-procedure .
        end.
      end.
      when 3
      then do:
        if v-select-obj-type = '':U
        or v-select-obj-code = 0
        then do:
          run proc-sel-obj in this-procedure .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной контекста" skip
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.
END PROCEDURE.
