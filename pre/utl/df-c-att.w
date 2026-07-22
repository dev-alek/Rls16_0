define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание df для таблиц истории и атрибутов".
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
DEFINE VARIABLE v-Field     AS CHARACTER  NO-UNDO.
define temp-table tt-file no-undo like _file
      field f-attr      as logical
      field f-c         as logical
      field f-attr-old  as logical
      field f-c-old     as logical
.
define temp-table tt-trig-name no-undo
      field f-name      as CHARACTER
INDEX pi IS PRIMARY UNIQUE
      f-name
    .
define stream st-out.
DEFINE BUTTON b-drop-all-attr
     LABEL "все атр."
     SIZE 10 BY 1.
DEFINE BUTTON b-drop-all-c
     LABEL "все ист."
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-export
     LABEL "Выгрузить"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel-all-attr
     LABEL "все атр."
     SIZE 10 BY 1.
DEFINE BUTTON b-sel-all-c
     LABEL "все ист."
     SIZE 10 BY 1.
DEFINE VARIABLE v-all AS LOGICAL INITIAL yes
     LABEL "В один файл new.df"
     VIEW-AS TOGGLE-BOX
     SIZE 20.6 BY .81 NO-UNDO.
DEFINE QUERY BR-file FOR
      tt-file SCROLLING.
DEFINE BROWSE BR-file
  QUERY BR-file NO-LOCK DISPLAY
      tt-file._File-Number column-label "№"
      tt-file._File-Name   column-label "Таблица"
      tt-file.f-attr column-label "Атр" view-as toggle-box
      tt-file.f-c column-label "Ист" view-as toggle-box
ENABLE
      tt-file.f-attr
      tt-file.f-c
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52.6 BY 16.52 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-export AT ROW 1 COL 11 WIDGET-ID 4
     b-help AT ROW 1 COL 43.6
     v-all AT ROW 1.1 COL 22 WIDGET-ID 2
     b-sel-all-c AT ROW 2 COL 11 WIDGET-ID 8
     b-sel-all-attr AT ROW 2 COL 21 WIDGET-ID 6
     b-drop-all-c AT ROW 3 COL 11 WIDGET-ID 16
     b-drop-all-attr AT ROW 3 COL 21 WIDGET-ID 18
     BR-file AT ROW 4 COL 1 WIDGET-ID 200
     "Выделить" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 2.24 COL 2 WIDGET-ID 12
     "Сбросить" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 3.24 COL 2 WIDGET-ID 14
     SPACE(43.63) SKIP(16.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Таблицы"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-drop-all-attr IN FRAME Dialog-Frame
DO:
   run deselect-all-attr in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-drop-all-c IN FRAME Dialog-Frame
DO:
   run deselect-all-c in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-export IN FRAME Dialog-Frame
DO:
   assign
      v-all
   .
   run waitfram-show in this-procedure
      ( input "Идет формирование файла"
      ) .
   run create-df in this-procedure NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE "Ошибка формированяи DF-файла" RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
   run waitfram-hide in this-procedure .
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\df-c-att.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF b-sel-all-attr IN FRAME Dialog-Frame
DO:
   run select-all-attr in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.
ON CHOOSE OF b-sel-all-c IN FRAME Dialog-Frame
DO:
   run select-all-c in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.
ON ROW-DISPLAY OF BR-file IN FRAME Dialog-Frame
DO:
   IF  tt-file.f-c-old = FALSE
   AND tt-file.f-c     = TRUE
   then do:
      assign
         tt-file.f-c:bgcolor    in browse br-file = GRAY_COLOR
      .
   end.
   IF  tt-file.f-attr-old = FALSE
   AND tt-file.f-attr     = TRUE
   then do:
      assign
         tt-file.f-attr:bgcolor in browse br-file = GRAY_COLOR
      .
   end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
ON "value-changed" OF tt-file.f-attr  IN BROWSE br-file
DO:
   define variable v-ok    as logical      no-undo.
   IF tt-file.f-attr-old = TRUE THEN dO:
      assign
         tt-file.f-attr:SCREEN-VALUE in browse br-file = STRING(tt-file.f-attr-old)
         tt-file.f-attr = tt-file.f-attr-old
      .
         APPLY "LEAVE" TO tt-file.f-attr in browse br-file.
      RETURN.
   END.
END.
ON "value-changed" OF tt-file.f-c  IN BROWSE br-file
DO:
   define variable v-ok    as logical      no-undo.
   IF tt-file.f-c-old = TRUE THEN dO:
      assign
         tt-file.f-c:SCREEN-VALUE in browse br-file = STRING(tt-file.f-c-old)
         tt-file.f-c = tt-file.f-c-old
      .
      APPLY "LEAVE" TO tt-file.f-c in browse br-file.
      RETURN.
   END.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run fill-file in this-procedure .
  RUN enable_UI.
  RUN post-enable_UI IN THIS-PROCEDURE .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-all-attr :
define variable v-trig-delete     as character    no-undo.
define variable v-trig-write     as character    no-undo.
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       no-lock
       :
       RUN add-attr  IN THIS-PROCEDURE ( INPUT tt-file._File-Number ) .
   end.
end.
END PROCEDURE.
PROCEDURE add-attr :
define input parameter p-number as integer no-undo .
define variable v-file-name     as character    no-undo.
define variable v-trig-name     as character    no-undo.
define variable v-log-gds-code     as LOGICAL    no-undo.
define variable v-log-host-code     as LOGICAL    no-undo.
define variable v-log-obj-code     as LOGICAL    no-undo.
define variable v-log-b-code     as LOGICAL    no-undo.
define variable v-log-doc-code     as LOGICAL    no-undo.
define variable V-LOG-wth-CODE     as LOGICAL    no-undo.
define variable v-log-rvs-code     as LOGICAL    no-undo.
define variable v-log-artic     as LOGICAL    no-undo.
define variable v-log-doc-num     as LOGICAL    no-undo.
DEFINE VARIABLE v-idx-c AS INTEGER NO-UNDO .
define buffer buf__Field      for _Field .
do
on error undo, return error
:
    ASSIGN
        v-log-gds-code = FALSE
        v-log-host-code = FALSE
        v-log-obj-code = FALSE
        v-log-b-code   = FALSE
        v-log-doc-code = FALSE
        V-LOG-wth-CODE = FALSE
        v-log-rvs-code = FALSE
        v-idx-c = 0
   .
        FIND FIRST _file
         where _file._File-Number = p-number
         no-lock
         .
    run trig-name in this-procedure
       ( input _file._File-Name
       , output v-trig-name
       ) .
    IF v-all THEN DO:
      assign
      v-file-name = SUBSTITUTE("new.df")
      .
    END.
    ELSE DO:
      assign
         v-file-name = SUBSTITUTE("&1-attr.df", _file._File-Name)
      .
    END.
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
        ASSIGN
              v-idx-c = v-idx-c + 1
        .
    END.
    IF v-idx-c >= 16 THEN DO:
        MESSAGE "В таблице "
            _File._File-Name
            " первичный ключ шестнадцать полей."
            SKIP "Создание таблицы атрибутов невозможно."
            VIEW-AS ALERT-BOX.
        NEXT.
    END.
    output stream st-out to value(v-file-name) append .
    put stream st-out unformatted
        'ADD TABLE "' + _File._File-Name + '-attr"' + chr(10)
      + '  AREA "Schema Area"' + chr(10)
      + '  CAN-READ "!,*"' + chr(10)
      + '  CAN-WRITE "!,!odbc,*"' + chr(10)
      + '  CAN-CREATE "!,!odbc,*"' + chr(10)
      + '  CAN-DELETE "!,!odbc,*"' + chr(10)
      + '  CAN-DUMP "!odbc,*"' + chr(10)
      + '  CAN-LOAD "!odbc,*"' + chr(10)
      + '  LABEL "ABC анализ"' + chr(10)
      + SUBSTITUTE('  DUMP-NAME "&1"', SUBSTRING(v-trig-name, 5, 8)) + chr(10)
      + Substitute('  TABLE-TRIGGER "DELETE" OVERRIDE PROCEDURE "&1d.p" CRC "?"', v-trig-name) + chr(10)
      + Substitute('  TABLE-TRIGGER "WRITE" OVERRIDE PROCEDURE "&1w.p" CRC "?"', v-trig-name) + chr(10)
      + chr(10)
      .
    field-block:
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
      CASE _Field._Field-Name:
          WHEN "gds-code"  THEN v-log-gds-code  = TRUE.
          WHEN "b-code"    THEN v-log-b-code    = TRUE.
          WHEN "doc-code"  THEN v-log-doc-code  = TRUE.
          WHEN "rvs-code"  THEN v-log-rvs-code  = TRUE.
          WHEN "wth-code"  THEN v-log-wth-code  = TRUE.
          WHEN "host-code" THEN v-log-host-code = TRUE.
          WHEN "obj-code"  THEN IF CAN-FIND(FIRST buf__Field of _File where buf__Field._Field-Name = "obj-type" no-lock)
                           THEN v-log-obj-code  = TRUE.
          WHEN "artic"     THEN IF  CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-type" no-lock)
                                and CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-code" no-lock)
                           THEN v-log-artic     = TRUE.
          WHEN "doc-num"   THEN v-log-doc-num   = TRUE.
          OTHERWISE DO:
          END.
      END CASE.
      put stream st-out unformatted
        'ADD FIELD "' + _Field._Field-Name
                      + '" OF "'
                      + _File._File-Name
                      + '-attr"'
                      + ' AS '
                      + _Field._Data-Type
                      + chr(10)
        .
      put stream st-out unformatted
        '  DESCRIPTION ' .
      export stream st-out
          _Field._Desc
        .
      put stream st-out unformatted
        '  FORMAT ' .
      export stream st-out
          _Field._Format
        .
      put stream st-out unformatted
        '  INITIAL ' .
      export stream st-out
          _Field._Initial
        .
      put stream st-out unformatted
        '  LABEL ' .
      export stream st-out
          _Field._Label
        .
      put stream st-out unformatted
        '  MANDATORY '
        chr(10)
        .
      put stream st-out unformatted
        chr(10)
      .
    end.
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "attr-code" OF "&1-attr" AS CHARACTER', _File._File-Name )
                      + chr(10)
         '  FORMAT "X(8)"'
                      + chr(10)
         '  INITIAL ""'
                      + chr(10)
         '  LABEL "Атрибут"'
                      + chr(10)
         '  MAX-WIDTH 16'
                      + chr(10)
         '  COLUMN-LABEL "Атрибут"'
                      + chr(10)
         '  MANDATORY'
                      + chr(10)
                      + chr(10)
      .
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "attr-value" OF "&1-attr" AS CHARACTER', _File._File-Name )
                      + chr(10)
         + '  FORMAT "X(30)"'
                      + chr(10)
         + '  INITIAL ""'
                      + chr(10)
         + '  LABEL "Значение атрибута"'
                      + chr(10)
         + '  MAX-WIDTH 60'
                      + chr(10)
         + '  COLUMN-LABEL "Значение!атрибута"'
                      + chr(10)
                      + chr(10)
      .
    find first _index
         where recid( _index  ) = _file._prime-index
           and LC( _index._index-name ) <> "default":U
         no-lock
         no-error.
    if not available _index then do:
      message
         "Не найден первичный индекс для таблицы" _File._File-Name
      view-as alert-box information.
      next.
    end.
    put stream st-out unformatted
      SUBSTITUTE('ADD INDEX "pi" ON "&1-attr"', _File._File-Name )
                        + chr(10)
      + '  AREA "Schema Area"'
                        + chr(10)
      + '  UNIQUE'
                        + chr(10)
      + '  PRIMARY'
                        + chr(10)
    .
    for each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq:
      put stream st-out unformatted
         SUBSTITUTE('  INDEX-FIELD "&1" &2', _Field._Field-Name, IF _index-field._Ascending THEN "ASCENDING" ELSE "DESCENDING")
                           + chr(10)
      .
    end.
    put stream st-out unformatted
      '  INDEX-FIELD "attr-code" ASCENDING'
                        + chr(10)
                        + chr(10)
    .
    IF v-log-gds-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-gds-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "gds-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-b-code    THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-b-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "b-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-doc-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "doc-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-rvs-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-rvs-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "rvs-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-wth-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-wth-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "wth-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-host-code THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-host-code" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "host-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-obj-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-obj" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "obj-type" ASCENDING'
                           + chr(10)
         + '  INDEX-FIELD "obj-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-artic     THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-artic" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "artic" ASCENDING'
                           + chr(10)
         + '  INDEX-FIELD "prod-type" ASCENDING'
                           + chr(10)
         + '  INDEX-FIELD "prod-code" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    IF v-log-doc-num   THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-num" ON "&1-attr"', _File._File-Name )
                           + chr(10)
         + '  AREA "Schema Area"'
                           + chr(10)
         + '  INDEX-FIELD "doc-num" ASCENDING'
                           + chr(10)
                           + chr(10)
      .
    end.
    output stream st-out close .
    RUN create-trg-w IN THIS-PROCEDURE (INPUT Substitute('&1w.p', v-trig-name), INPUT SUBSTITUTE('&1-attr', _file._File-Name) ) .
    RUN create-trg-d IN THIS-PROCEDURE (INPUT Substitute('&1d.p', v-trig-name), INPUT SUBSTITUTE('&1-attr', _file._File-Name) ) .
    output stream st-out to value("tbl.lst") append .
    put stream st-out unformatted
       SUBSTITUTE('&1-attr', _File._File-Name )
       + chr(10)
    .
    output stream st-out close .
end.
END PROCEDURE.
PROCEDURE add-c :
define input parameter p-number as integer no-undo .
define variable v-file-name     as character    no-undo.
define variable v-trig-name     as character    no-undo.
define variable v-log-gds-code     as LOGICAL    no-undo.
define variable v-log-host-code     as LOGICAL    no-undo.
define variable v-log-obj-code     as LOGICAL    no-undo.
define variable v-log-b-code     as LOGICAL    no-undo.
define variable v-log-doc-code     as LOGICAL    no-undo.
define variable V-LOG-wth-CODE     as LOGICAL    no-undo.
define variable v-log-rvs-code     as LOGICAL    no-undo.
define variable v-log-artic     as LOGICAL    no-undo.
define variable v-log-doc-num     as LOGICAL    no-undo.
DEFINE VARIABLE v-idx-c AS INTEGER NO-UNDO .
define buffer buf__Field      for _Field .
do
on error undo, return error
:
    FIND FIRST _file
         where _file._File-Number = p-number
         no-lock
         .
    run trig-name in this-procedure
       ( input _file._File-Name
       , output v-trig-name
       ) .
    IF v-all THEN DO:
      assign
      v-file-name = SUBSTITUTE("new.df")
      .
    END.
    ELSE DO:
      assign
         v-file-name = SUBSTITUTE("c-&1.df", _file._File-Name)
      .
    END.
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
        ASSIGN
              v-idx-c = v-idx-c + 1
        .
    END.
    IF v-idx-c >= 16 THEN DO:
        MESSAGE "В таблице "
            _File._File-Name
            " первичный ключ шестнадцать полей."
            SKIP "Создание таблицы атрибутов невозможно."
            VIEW-AS ALERT-BOX.
        NEXT.
    END.
    output stream st-out to value(v-file-name) append .
    put stream st-out unformatted
        'ADD TABLE "c-' + _File._File-Name + '"' + chr(10)
      + '  AREA "Schema Area"' + chr(10)
      + '  CAN-READ "!,*"' + chr(10)
      + '  CAN-WRITE "!,!odbc,*"' + chr(10)
      + '  CAN-CREATE "!,!odbc,*"' + chr(10)
      + '  CAN-DELETE "!,!odbc,*"' + chr(10)
      + '  CAN-DUMP "!odbc,*"' + chr(10)
      + '  CAN-LOAD "!odbc,*"' + chr(10)
      + '  LABEL "ABC анализ"' + chr(10)
      + SUBSTITUTE('  DUMP-NAME "&1"', v-trig-name) + chr(10)
      + Substitute('  TABLE-TRIGGER "DELETE" OVERRIDE PROCEDURE "&1d.p" CRC "?"', v-trig-name) + chr(10)
      + Substitute('  TABLE-TRIGGER "WRITE" OVERRIDE PROCEDURE "&1w.p" CRC "?"', v-trig-name) + chr(10)
      + chr(10)
      .
    field-block:
    for each _Field of _File
        no-lock
        on error undo, return error
      :
      CASE _Field._Field-Name:
          WHEN "gds-code"  THEN v-log-gds-code  = TRUE.
          WHEN "b-code"    THEN v-log-b-code    = TRUE.
          WHEN "doc-code"  THEN v-log-doc-code  = TRUE.
          WHEN "rvs-code"  THEN v-log-rvs-code  = TRUE.
          WHEN "wth-code"  THEN v-log-wth-code  = TRUE.
          WHEN "host-code" THEN v-log-host-code = TRUE.
          WHEN "obj-code"  THEN IF CAN-FIND(FIRST buf__Field of _File where buf__Field._Field-Name = "obj-type" no-lock)
                           THEN v-log-obj-code  = TRUE.
          WHEN "artic"     THEN IF  CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-type" no-lock)
                                and CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-code" no-lock)
                           THEN v-log-artic     = TRUE.
          WHEN "doc-num"   THEN v-log-doc-num   = TRUE.
          OTHERWISE DO:
          END.
      END CASE.
      put stream st-out unformatted
        'ADD FIELD "' + _Field._Field-Name
                      + '" OF c-"'
                      + _File._File-Name
                      + '" AS '
                      + _Field._Data-Type
                      + chr(10)
        .
      put stream st-out unformatted
        '  DESCRIPTION ' .
      export stream st-out
          _Field._Desc
        .
      put stream st-out unformatted
        '  FORMAT ' .
      export stream st-out
          _Field._Format
        .
      put stream st-out unformatted
        '  INITIAL ' .
      export stream st-out
          _Field._Initial
        .
      put stream st-out unformatted
        '  LABEL ' .
      export stream st-out
          _Field._Label
        .
      put stream st-out unformatted
        '  MANDATORY '
        chr(10)
        .
      put stream st-out unformatted
        chr(10)
      .
    end.
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-user-db-num" OF "c-&1" AS INTEGER', _File._File-Name )
                      + chr(10)
         '  DESCRIPTION "Номер БД"'
                      + chr(10)
         '  FORMAT ">>>>9"'
                      + chr(10)
         '  INITIAL ?'
                      + chr(10)
         '  LABEL "Номер БД"'
                      + chr(10)
         '  MAX-WIDTH 4'
                      + chr(10)
         '  COLUMN-LABEL "Номер БД"'
                      + chr(10)
         '  MANDATORY'
                      + chr(10)
                      + chr(10)
      .
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "chip-num" OF "c-&1" AS INTEGER', _File._File-Name )
                      + chr(10)
         '  FORMAT ">,>>>,>>9"'
                      + chr(10)
         '  INITIAL 0'
                      + chr(10)
         '  LABEL "Щепка"'
                      + chr(10)
         '  MAX-WIDTH 4'
                      + chr(10)
         '  COLUMN-LABEL "Щепка"'
                      + chr(10)
         '  MANDATORY'
                      + chr(10)
                      + chr(10)
      .
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-time" OF "c-&1" AS INTEGER', _File._File-Name )
                      + chr(10)
         '  DESCRIPTION "Время изменения в секундах"'
                      + chr(10)
         '  FORMAT ">>>,>>9"'
                      + chr(10)
         '  INITIAL 0'
                      + chr(10)
         '  LABEL "Время изменения в секундах"'
                      + chr(10)
         '  MAX-WIDTH 4'
                      + chr(10)
         '  COLUMN-LABEL "Время"'
                      + chr(10)
                      + chr(10)
      .
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-date" OF "c-&1" AS DATE', _File._File-Name )
                      + chr(10)
         '  FORMAT 99/99/9999"'
                      + chr(10)
         '  INITIAL ?'
                      + chr(10)
         '  LABEL "Дата коррекции"'
                      + chr(10)
         '  MAX-WIDTH 4'
                      + chr(10)
         '  COLUMN-LABEL "Номер БД"'
                      + chr(10)
                      + chr(10)
      .
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-user-name" OF "c-&1" AS CHARACTER', _File._File-Name )
                      + chr(10)
         '  DESCRIPTION "Имя пользователя"'
                      + chr(10)
         '  FORMAT "X(8)"'
                      + chr(10)
         '  INITIAL ""'
                      + chr(10)
         '  LABEL "Имя пользователя"'
                      + chr(10)
         '  MAX-WIDTH 16'
                      + chr(10)
         '  COLUMN-LABEL "Имя"'
                      + chr(10)
                      + chr(10)
      .
    find first _index
         where recid( _index  ) = _file._prime-index
           and LC( _index._index-name ) <> "default":U
         no-lock
         no-error.
    if not available _index then do:
      message
         "Не найден первичный индекс для таблицы" _File._File-Name
      view-as alert-box information.
      next.
    end.
    put stream st-out unformatted
      SUBSTITUTE('ADD INDEX "pi" ON "c-&1"', _File._File-Name )
                        + chr(10)
      + '  AREA "Schema Area"'
                        + chr(10)
      + '  UNIQUE'
                        + chr(10)
      + '  PRIMARY'
                        + chr(10)
    .
    for each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq:
      put stream st-out unformatted
         SUBSTITUTE('  INDEX-FIELD "&1" &2', _Field._Field-Name, IF _index-field._Ascending THEN "ASCENDING" ELSE "DESCENDING")
                           + chr(10)
      .
    end.
    put stream st-out unformatted
         '  INDEX-FIELD "corr-user-db-num" ASCENDING'
                           + chr(10)
         '  INDEX-FIELD "chip-num" ASCENDING'
                           + chr(10)
                           + chr(10)
    .
    output stream st-out close .
    RUN create-trg-w IN THIS-PROCEDURE (INPUT Substitute('&1w.p', v-trig-name), INPUT SUBSTITUTE('c-&1', _file._File-Name)).
    RUN create-trg-d IN THIS-PROCEDURE (INPUT Substitute('&1d.p', v-trig-name), INPUT SUBSTITUTE('c-&1', _file._File-Name)).
    output stream st-out to value("tbl.lst") append .
    put stream st-out unformatted
       SUBSTITUTE('&1-attr', _File._File-Name )
       + chr(10)
    .
    output stream st-out close .
end.
END PROCEDURE.
PROCEDURE create-df :
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = TRUE
       :
       RUN add-c in this-procedure ( INPUT tt-file._File-Number) .
   end.
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       :
       RUN add-attr in this-procedure  ( INPUT tt-file._File-Number) .
   end.
end.
END PROCEDURE.
PROCEDURE create-trg-d :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO .
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO .
do
on error undo, return error
:
    output stream st-out to value(p-file-name) .
put stream st-out unformatted '/*' +  chr(10).
put stream st-out unformatted '' +  chr(10).
put stream st-out unformatted '$Revision$' +  chr(10).
put stream st-out unformatted '$Author$' +  chr(10).
put stream st-out unformatted '$Date$' +  chr(10).
put stream st-out unformatted '$Workfile$' +  chr(10).
put stream st-out unformatted '$Archive$' +  chr(10).
put stream st-out unformatted '' +  chr(10).
put stream st-out unformatted SUBSTITUTE('??????? ?? ???????? ??????? &1', p-tbl-name) +  chr(10).
put stream st-out unformatted '' +  chr(10).
put stream st-out unformatted '?????: ' +  chr(10).
put stream st-out unformatted '???? ????????:' +  chr(10).
put stream st-out unformatted 'Author: Ilia Belousov' +  chr(10).
put stream st-out unformatted 'Creation date:' +  chr(10) +  chr(10).
put stream st-out unformatted '*/' +  chr(10)  +  chr(10).
put stream st-out unformatted SUBSTITUTE('TRIGGER PROCEDURE FOR DELETE OF ub.&1 old old-&1.', p-tbl-name) +  chr(10) +  chr(10).
put stream st-out unformatted 'define variable vss-revision    as character no-undo init "$Revision$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-author      as character no-undo init "$Author$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-date        as character no-undo init "$Date$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-workfile    as character no-undo init "$Workfile$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-archive     as character no-undo init "$Archive$":U .' +  chr(10).
put stream st-out unformatted SUBSTITUTE('define variable vss-description as character no-undo init "??????? ?? ???????? ???????".', p-tbl-name) +  chr(10)  +  chr(10) +  chr(10).
put stream st-out unformatted 'main-block:' +  chr(10).
put stream st-out unformatted 'do' +  chr(10).
put stream st-out unformatted 'on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))' +  chr(10).
put stream st-out unformatted 'on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )' +  chr(10).
put stream st-out unformatted 'on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )' +  chr(10).
put stream st-out unformatted ':' +  chr(10)  +  chr(10) +  chr(10).
put stream st-out unformatted 'end. /* main-block */' +  chr(10).
    output stream st-out close .
END.
END PROCEDURE.
PROCEDURE create-trg-w :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO .
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO .
do
on error undo, return error
:
    output stream st-out to value(p-file-name) .
put stream st-out unformatted '/*' +  chr(10).
put stream st-out unformatted '' +  chr(10).
put stream st-out unformatted '$Revision$' +  chr(10).
put stream st-out unformatted '$Author$' +  chr(10).
put stream st-out unformatted '$Date$' +  chr(10).
put stream st-out unformatted '$Workfile$' +  chr(10).
put stream st-out unformatted '$Archive$' +  chr(10) +  chr(10).
put stream st-out unformatted SUBSTITUTE('??????? ?? ????????? ??????? &1', p-tbl-name) +  chr(10) +  chr(10).
put stream st-out unformatted '?????: ' +  chr(10).
put stream st-out unformatted '???? ????????:' +  chr(10).
put stream st-out unformatted 'Author: Ilia Belousov' +  chr(10).
put stream st-out unformatted 'Creation date:' +  chr(10) +  chr(10).
put stream st-out unformatted '*/' +  chr(10) +  chr(10).
put stream st-out unformatted SUBSTITUTE('TRIGGER PROCEDURE FOR WRITE OF ub.&1 old old-&1.', p-tbl-name) +  chr(10) +  chr(10).
put stream st-out unformatted 'define variable vss-revision    as character no-undo init "$Revision$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-author      as character no-undo init "$Author$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-date        as character no-undo init "$Date$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-workfile    as character no-undo init "$Workfile$":U .' +  chr(10).
put stream st-out unformatted 'define variable vss-archive     as character no-undo init "$Archive$":U .' +  chr(10).
put stream st-out unformatted SUBSTITUTE('define variable vss-description as character no-undo init "??????? ??  ????????? ???????".', p-tbl-name) +  chr(10) +  chr(10) +  chr(10).
put stream st-out unformatted 'main-block:' +  chr(10).
put stream st-out unformatted 'do' +  chr(10).
put stream st-out unformatted 'on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))' +  chr(10).
put stream st-out unformatted 'on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )' +  chr(10).
put stream st-out unformatted 'on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )' +  chr(10).
put stream st-out unformatted ':' +  chr(10) +  chr(10) +  chr(10).
put stream st-out unformatted 'end. /* main-block */' +  chr(10).
    output stream st-out close .
END.
END PROCEDURE.
PROCEDURE deselect-all-attr :
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       :
       assign
         tt-file.f-attr     = FALSE
       .
   end.
end.
END PROCEDURE.
PROCEDURE deselect-all-c :
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = TRUE
       :
       assign
         tt-file.f-c     = FALSE
       .
   end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-all
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-export b-help v-all b-sel-all-c b-sel-all-attr b-drop-all-c
         b-drop-all-attr BR-file
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  RUN refresh-query in this-procedure .
END PROCEDURE.
PROCEDURE fill-file :
do
on error undo, return error
:
  define buffer buf__file     for _file .
  for each  _file
      where _file._hidden = false
      no-lock
      :
      if _file._File-Name begins "c-":U
      or index(_file._File-Name , "-attr":U ) <> 0
      then do:
         next.
      end.
      FIND FIRST _Field OF _File WHERE _Field._Field-Name = "attr-code"
          NO-LOCK
          NO-ERROR
          .
      IF AVAILABLE _Field THEN DO:
          NEXT.
      END.
      create tt-file.
      buffer-copy _file to tt-file .
      IF can-find (FIRST buf__file
                   where buf__file._file-name = SUBSTITUTE( "&1-attr", _file._File-Name)
                   no-lock
                  )
      then do:
         assign
            tt-file.f-attr       = YES
            tt-file.f-attr-old   = YES
         .
      end.
      IF can-find (FIRST buf__file
                   where buf__file._file-name = SUBSTITUTE( "c-&1", _file._File-Name)
                   no-lock
                  )
      then do:
         assign
            tt-file.f-c       = YES
            tt-file.f-c-old   = YES
         .
      end.
  end.
end.
END PROCEDURE.
PROCEDURE post-enable_UI :
do
on error undo, return error
:
   ASSIGN
      tt-file.f-c :READ-ONLY    in browse br-file = NO
      tt-file.f-attr :READ-ONLY in browse br-file = NO
   .
end.
END PROCEDURE.
PROCEDURE refresh-query :
do
on error undo, return error
:
      OPEN QUERY BR-file
           for each  tt-file
      INDEXED-REPOSITION .
end.
END PROCEDURE.
PROCEDURE select-all-attr :
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = FALSE
       :
       assign
         tt-file.f-attr     = TRUE
       .
   end.
end.
END PROCEDURE.
PROCEDURE select-all-c :
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = FALSE
       :
       assign
         tt-file.f-c     = TRUE
       .
   end.
end.
END PROCEDURE.
PROCEDURE trig-name :
define input  parameter p-name   as character no-undo .
define output parameter p-trig-name as character no-undo .
define variable v-absent    as logical      no-undo.
define variable v-file-name as character    no-undo.
define variable v-counter    as integer      no-undo.
do
on error undo, return error
:
   assign
      v-file-name = SUBSTITUTE("trg/&1", SUBSTRING(p-name, 1 , 7 ))
      v-counter   = 0
   .
   REPEAT WHILE NOT v-absent:
      FIND FIRST _File-Trig
         WHERE _File-Trig._Proc-Name begins v-file-name
         no-lock
         no-error
         .
      FIND FIRST tt-trig-name
         WHERE tt-trig-name.f-name begins v-file-name
         no-lock
         no-error
         .
      IF AVAILABLE _File-Trig
      OR AVAILABLE tt-trig-name
      THEN DO:
         assign
            v-file-name = IF v-counter < 10
                          THEN
                          SUBSTITUTE
                          ( "trg/&1&2"
                          , SUBSTRING(p-name, 1 , 6 )
                          , STRING(v-counter, "9")
                          )
                          ELSE
                          SUBSTITUTE
                          ( "trg/&1&2"
                          , SUBSTRING(p-name, 1 , 5 )
                          , STRING(v-counter, "99")
                          )
            v-counter = v-counter + 1
         .
         next.
      END.
      ELSE DO:
         CREATE tt-trig-name.
         assign
            tt-trig-name.f-name = v-file-name
            v-absent = TRUE
            p-trig-name = v-file-name
         .
         return.
      END.
   END.
end.
END PROCEDURE.
