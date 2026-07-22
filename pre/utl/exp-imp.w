define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Экспорт-импорт локальных таблиц УБД - запуск" .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable v_os-dir   AS CHAR NO-UNDO INIT "".
define variable v_os-dir-type   AS CHAR NO-UNDO INIT "".
define variable v_can-write as logical no-undo.
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
function corr-file-name returns character (
 input p-file-name as character)
 .
DEFINE variable v-corr-file-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-char-name-list as character no-undo .
assign
v-corr-file-name = p-file-name
.
do ii = 1 to length('\/:*?"<>|':U):
  assign
  v-corr-file-name = replace(
                                v-corr-file-name
                               , substr('\/:*?"<>|':U, ii, 1 )
                               , entry(ii, 'b-slash,slash,colon,star,question,d-quote,d-quote,less-t,great-t,pipe':U)
                           )
  .
end.
return v-corr-file-name.
end function.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-log-gap as logical no-undo .
define variable v-user-name    as character    no-undo.
define variable v-grp-name    as character    no-undo.
define variable v-arm-code    as character    no-undo.
DEFINE BUTTON B-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-import
     LABEL "&Импорт"
     SIZE 10 BY 1.
DEFINE VARIABLE dir-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.6 BY 1 NO-UNDO.
DEFINE VARIABLE F-flt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-gen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-pbc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-rht AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-scl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-seq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-usr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE RECTANGLE RECT-groups
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.7 BY 13.2.
DEFINE VARIABLE T-flt AS LOGICAL INITIAL yes
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-gen AS LOGICAL INITIAL yes
     LABEL "Параметры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-glb AS LOGICAL INITIAL no
     LABEL "Глобальные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE T-pbc AS LOGICAL INITIAL yes
     LABEL "Вес и взвеш коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-rht AS LOGICAL INITIAL yes
     LABEL "Права"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-scl AS LOGICAL INITIAL yes
     LABEL "Весы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-seq AS LOGICAL INITIAL yes
     LABEL "Счетчики"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-usr AS LOGICAL INITIAL yes
     LABEL "Пользователи"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-export AT ROW 1 COL 21
     B-import AT ROW 1 COL 31
     B-Help AT ROW 1 COL 82
     B-dir AT ROW 2.43 COL 81.3
     T-rht AT ROW 5.77 COL 3
     T-gen AT ROW 7 COL 3
     T-flt AT ROW 8.27 COL 3
     T-pbc AT ROW 9.5 COL 3
     T-glb AT ROW 9.5 COL 61 WIDGET-ID 2
     T-scl AT ROW 10.77 COL 3
     T-usr AT ROW 12 COL 3
     T-seq AT ROW 13.27 COL 3
     dir-name AT ROW 2.43 COL 28.6 COLON-ALIGNED NO-LABEL
     F-rht AT ROW 5.77 COL 27 COLON-ALIGNED NO-LABEL
     F-gen AT ROW 7 COL 27 COLON-ALIGNED NO-LABEL
     F-flt AT ROW 8.27 COL 27 COLON-ALIGNED NO-LABEL
     F-pbc AT ROW 9.5 COL 27 COLON-ALIGNED NO-LABEL
     F-scl AT ROW 10.77 COL 27 COLON-ALIGNED NO-LABEL
     F-usr AT ROW 12 COL 27 COLON-ALIGNED NO-LABEL
     F-seq AT ROW 13.27 COL 27 COLON-ALIGNED NO-LABEL
     "Название файла экспорта-импорта" VIEW-AS TEXT
          SIZE 33.5 BY .8 AT ROW 4.43 COL 29.6
          FGCOLOR 4
     "Группы данных" VIEW-AS TEXT
          SIZE 20.1 BY .8 AT ROW 4.43 COL 3.4
          FGCOLOR 4
     "Директория экспорта/импорта" VIEW-AS TEXT
          SIZE 27.9 BY 1 AT ROW 2.37 COL 2
          FGCOLOR 4
     RECT-groups AT ROW 3.87 COL 1.8
     SPACE(0.49) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт-импорт локальных таблиц УБД"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       F-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dir IN FRAME Dialog-Frame
DO:
    run gbl/dir-sel.p (output v_os-dir,
                output v_os-dir-type,
                output v_can-write) no-error.
    if error-status:error then return no-apply.
    dir-name = v_os-dir.
    display
    dir-name
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-export IN FRAME Dialog-Frame
DO:
  if NOT v_can-write then do:
    message "Данная директория доступна только для чтения"
    view-as alert-box ERROR.
    return no-apply.
  end.
  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "export":U).
  run waitfram-hide in this-procedure .
END.
ON CHOOSE OF B-import IN FRAME Dialog-Frame
DO:
 run waitfram-show in this-procedure ( input "Ждите..." ).
 run proc-b-ie in this-procedure ( input "import":U).
 run waitfram-hide in this-procedure .
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    file-info:file-name = ".".
    assign
    dir-name = file-info:full-pathname
    v_os-dir-type = file-info :file-type
    v_can-write = (index(v_os-dir-type, "W") > 0)
   .
  FIND FIRST ub.sys-ctrl No-LOCK.
  FIND FIRST ub.db no-LOCK where
             ub.db.db-num = sys-ctrl.db-num.
    assign
    f-rht = corr-file-name(db.db-key) + ".":U +   "rht"
    F-flt = corr-file-name(db.db-key) + ".":U +   "flt"
    F-pbc = corr-file-name(db.db-key) + ".":U +   "pbc"
    F-scl = corr-file-name(db.db-key) + ".":U +   "scl"
    F-usr = corr-file-name(db.db-key) + ".":U +   "usr"
    F-gen = corr-file-name(db.db-key) + ".":U +   "gen"
    F-seq = corr-file-name(db.db-key) + ".":U +   "seq"
    .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-iefile :
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
FIND FIRST ub.sys-ctrl No-LOCK.
FIND FIRST ub.db no-LOCK where
            ub.db.db-num = ub.sys-ctrl.db-num.
if not avail ub.db then do:
    message "Отсутствует информация в таблице db"
    view-as alert-box ERROR.
    return error.
end.
full_name = dir-name + "\":U + corr-file-name(ub.db.db-key) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
    message "Не найден файл данных" full_name  skip
                        "для импорта"
        view-as alert-box ERROR.
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message "Уже имеется в выбранной директории файл с именем" full_name  skip
            "совпадающим с именем одного из файлов экспорта" skip
            "Перезаписывать?"
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-rht T-gen T-flt T-pbc T-glb T-scl T-usr dir-name F-rht F-gen F-flt
          F-pbc F-scl F-usr
      WITH FRAME Dialog-Frame.
  ENABLE RECT-groups B-exit B-export B-import B-Help B-dir T-rht T-gen T-flt
         T-pbc T-glb T-scl T-usr dir-name F-rht F-gen F-flt F-pbc F-scl F-usr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-ie :
define input parameter p-mode as character no-undo.
 define variable ii as integer no-undo.
 define variable loc#log as logical no-undo.
 define variable file-extensions as char format "X(3)" no-undo init "rht,gen,flt,pbc,scl,usr,seq,cdr,cdk,thb,pet":U.
 define variable t-vals as logical no-undo extent 11.
 define variable v-proc-name as character no-undo .
 define variable v-proc-title as character no-undo .
 define variable v-param as character no-undo .
 define variable v-choice as integer no-undo .
 assign
 dir-name
 T-gen frame Dialog-Frame
 T-flt
 T-rht
 T-pbc
 T-scl
 T-usr
 T-seq = no
 t-glb
 .
 assign
 t-vals[2] = t-gen
 t-vals[3] = t-flt
 t-vals[1] = t-rht
 t-vals[4] = t-pbc
 t-vals[5] = t-scl
 t-vals[6] = t-usr
 t-vals[7] = t-seq
 .
 if dir-name = "" then do:
    message "Не задана директория для файлов экспорта/импорат"
    view-as alert-box ERROR.
    return error.
 end.
 DO ii = 1 to num-entries(file-extensions):
    if t-vals[ii] then do:
        run check-iefile in this-procedure (
                                           input dir-name
                                           ,input entry(ii, file-extensions)
                                           ,input p-mode
                                           ,output loc#log).
        if not loc#log then  return no-apply.
    end.
  end.
  assign
  v-param = string(T-vals[1])  + chr(4) +
            string(T-vals[2])  + chr(4) +
            string(T-vals[3])  + chr(4) +
            string(T-vals[4])  + chr(4) +
            string(T-vals[5])  + chr(4) +
            string(T-vals[6])  + chr(4) +
            string(T-vals[7])  + chr(4) +
            corr-file-name(ub.db.db-key) + chr(4) +
            dir-name + chr(4) +
            string(T-glb)
            .
  if p-mode = "export":U then do:
    assign
    v-proc-name = "utl/imp-expe.p"
    v-proc-title = "Экспорт локальных таблиц БД"
    .
  end.
  else do:
    run gbl/d-askw.w ( input "Версия файлов импорта"
                ,input "Для корректного импорта данных необходимо знать, в какой версии IBS TH они были экспортированы"
                ,input "|"
                ,input ("12.3|" +
                       "14.1|" +
                       "15.0|" +
                       "Отказ")
                ,input "|||"
                ,input 3
                ,input 4
                ,output v-choice).
    if v-choice = 4 then do:
      undo, return error .
    end.
    assign
    v-param = v-param + chr(4) + (if v-choice = 1
                                        then "12.3"
                                        else (if v-choice = 2
                                              then "14.1"
                                              else "15.0"
                                             )
                                       )
    v-proc-name = "utl/imp-expi.p"
    v-proc-title = "Импорт локальных таблиц БД"
    .
  end.
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input v-proc-name
        , input v-param
        , input no
        , input "":U
        , input v-proc-title
    ) no-error.
  if error-status:error then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error.
  end.
END PROCEDURE.
