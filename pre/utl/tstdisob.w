define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Интерфейс тестов корректности архивов по дис картам" .
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE NEW SHARED STREAM test.
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable MY-where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable sort-phrase-rus as char no-undo.
def NEW SHARED var ff as decimal.
def NEW SHARED var gg as decimal.
DEF NEW SHARED VAR accum1 as decimal.
DEF NEW SHARED VAR accum2 as decimal.
define variable test-number as integer no-undo.
DEFINE BUTTON B-1
     LABEL "Количество чеков, товарные суммы и суммы оплат"
     SIZE 78 BY 1.
DEFINE BUTTON B-2
     LABEL "Сумма купленного товара в учетных ценах"
     SIZE 78 BY 1.
DEFINE BUTTON B-3
     LABEL "Суммы по объектам + платежи на фирму(не касс и не по накл) = Суммы по фирме"
     SIZE 78 BY 1.
DEFINE BUTTON B-4
     LABEL "Суммы по объектам  =  Кассовые платежи + Платежи по накладным"
     SIZE 78 BY 1.
DEFINE BUTTON B-5
     LABEL "Кредитные карты: Суммы по фирме - Сальдо карты"
     SIZE 78 BY 1.
DEFINE BUTTON B-6
     LABEL "Платеж по продаже/накл = Сумма по накл/чекам по продажи"
     SIZE 78 BY 1.
DEFINE BUTTON B-7
     LABEL "Корректность % скидки (на товар) по накопительной карте"
     SIZE 78 BY 1.
DEFINE BUTTON B-8
     LABEL "Частные итоги по объекту - чеки"
     SIZE 78 BY 1 TOOLTIP "В ГБД чеки по незакрытым продажам - СУММИРУЮТСЯ".
DEFINE BUTTON B-99
     LABEL "Грубый тест по количеству чеков"
     SIZE 78 BY 1 TOOLTIP "В ГБД чеки по незакрытым продажам - СУММИРУЮТСЯ".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-d-card AS CHARACTER FORMAT "X(256)":U
     LABEL "Введите N карты или all"
     VIEW-AS FILL-IN
     SIZE 15 BY 1.04 NO-UNDO.
DEFINE VARIABLE F-mess AS CHARACTER FORMAT "X(256)":U INITIAL "Для all рез-ты только по"
      VIEW-AS TEXT
     SIZE 34.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-sch AS CHARACTER FORMAT "X(256)":U
     LABEL "Фильтр"
      VIEW-AS TEXT
     SIZE 54.88 BY .67 NO-UNDO.
DEFINE VARIABLE Rs-dctype AS CHARACTER INITIAL "фирма"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1"
     SIZE 27.75 BY .79 NO-UNDO.
DEFINE VARIABLE RS-view-mode AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Показывать только ошибочные", 0,
"Показывать все", 1
     SIZE 50 BY .75 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-Help AT ROW 1 COL 54.88
     Rs-dctype AT ROW 2.25 COL 3.5 NO-LABEL
     RS-view-mode AT ROW 2.25 COL 47 NO-LABEL
     F-d-card AT ROW 4.54 COL 25.38 COLON-ALIGNED
     B-1 AT ROW 6.17 COL 2
     B-2 AT ROW 7.54 COL 2
     B-3 AT ROW 8.96 COL 2
     B-4 AT ROW 10.25 COL 2
     B-5 AT ROW 11.67 COL 2
     B-6 AT ROW 13.25 COL 2
     B-7 AT ROW 14.75 COL 2
     B-8 AT ROW 16.25 COL 2
     B-99 AT ROW 17.75 COL 2
     F-sch AT ROW 3.38 COL 19.13 COLON-ALIGNED
     F-mess AT ROW 4.75 COL 41.5 COLON-ALIGNED NO-LABEL
     "test7dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 14.75 COL 80.5
          FGCOLOR 4
     "test4dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 10.25 COL 80.5
          FGCOLOR 4
     "test8dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 16.25 COL 80.5
          FGCOLOR 4
     "test5dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 11.63 COL 80.5
          FGCOLOR 4
     "test2dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 7.42 COL 80.5
          FGCOLOR 4
     "test6dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 13.25 COL 80.5
          FGCOLOR 4
     "test99dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 17.75 COL 80.5
          FGCOLOR 4
     "test3dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 8.92 COL 80.5
          FGCOLOR 4
     "Результаты ищите в:" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 4.5 COL 79.5
          FGCOLOR 4
     "test1dc.txt" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 6 COL 80.5
          FGCOLOR 4
     SPACE(4.62) SKIP(12.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тест корректности архивов по дисконтным картам"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 1
  rs-dctype
  rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 2
  rs-dctype
   rs-view-mode
  .
  message "В процессе разработки!" view-as alert-box.
  return no-apply.
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
   assign
  f-d-card
  f-sch
  test-number = 3
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
   assign
  f-d-card
  f-sch
  test-number = 4
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 5
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 6
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 7
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 8
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF B-99 IN FRAME Dialog-Frame
DO:
  assign
  f-d-card
  f-sch
  test-number = 99
  rs-dctype
   rs-view-mode
  .
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RS-dctype:RADIO-Buttons =  "Глобальные" + chr(44) +  'все':U + chr(44) +
                             "По фирме" + chr(44) + 'фирма':U
                             .
  rs-dctype = 'все':U.
  RUN enable_UI.
  ASSIGN
  f-mess = f-mess + chr(32) + v-cntxt-obj-type + STRING(v-cntxt-obj-code).
  DISPLAY
  f-mess
  WITH FRAME Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-dctype RS-view-mode F-d-card F-sch F-mess
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-Help Rs-dctype RS-view-mode F-d-card B-1 B-2 B-3 B-4 B-5 B-6
         B-7 B-8 B-99 F-sch F-mess
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE test0 :
  IF F-d-card <> "all" AND
  F-sch = "" then do:
    FIND FIRST ub.dis-card No-LOCK WHERE ub.dis-card.d-card = f-d-card No-ERROR.
    IF NOT AVAIL ub.dis-card then do:
        message "Не найдена карта с номером " f-d-card
        view-as alert-box ERROR.
        return no-apply.
    end.
    if RS-dctype = 'фирма':U AND ub.dis-card.emitent-host-code = 0 OR
       RS-dctype = 'все':U and ub.dis-card.emitent-host-code <> 0 then do:
       message "Дисконтная карта не "
       (if RS-dctype = 'все':U then " глобальна!" else " по фирме!")
       view-as alert-box ERROR.
       return no-apply.
    end.
    if dis-card.emitent-host-code > 0 and dis-card.emitent-host-code <> v-cntxt-host-code-obj then do:
        message "Дисконтная карта не принадлежит текущей фирме!"
        view-as alert-box ERROR.
        return no-apply.
    end.
  end.
assign
ff = 0
gg = 0
accum1 = 0
accum2 = 0
.
run waitfram-show in this-procedure ("Ждите - идет обработка " ).
case test-number:
    WHEN 1 then do:
       OUTPUT stream test to test1dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Кол. чеков" format "X(10)" space(1)
       "Сумма покупок руб" format "X(15)" space(1)
       "Сумма скидок руб" format "X(15)" space(1)
       "Сумма оплат руб" format "X(15)" space(1)
       "Сумма покупок б.в." format "X(15)" space(1)
       "Сумма скидок б.в." format "X(15)" space(1)
       "Сумма оплат б.в." format "X(15)"
       SKIP
       .
    END.
    WHEN 2 then do:
       OUTPUT stream test to test2dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Сумма учетн.цен руб" format "X(15)" space(1)
       "Сумма учетн.цен б.в." format "X(15)" space(1)
       SKIP
       .
    END.
    when 3 then do:
       OUTPUT stream test to test3dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "КОд фирмы" format "X(9)" space(3)
       "Число че-" format "X(9)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(3)
       "Прямые поступления" format "X(19)" space(1)
       "Прямые поступления" format "X(19)" space(3)
       "Число че-" format "X(9)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       " 17 - (8 + 10)" format "X(15)" space(1)
       " 18 - (9 + 11)" format "X(15)" space(1)
       SKIP
        " " format "X(16)" space(1)
       " " format "X(9)" space(3)
       "ков объек" format "X(9)" space(1)
       "объекты руб" format "X(15)" space(1)
       "объекты б.в." format "X(15)" space(1)
       "объекты руб" format "X(15)" space(1)
       "объекты б.в." format "X(15)" space(1)
       "объекты руб" format "X(15)" space(1)
       "оъекты б.в." format "X(15)" space(3)
       "на карту руб" format "X(19)" space(1)
       "на карту б.в." format "X(19)" space(3)
       "ков фирма" format "X(9)" space(1)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "      1" format "X(16)" space(1)
       "      2" format "X(9)" space(3)
       "      3" format "X(9)" space(1)
       "      4" format "X(15)" space(1)
       "      5" format "X(15)" space(1)
       "      6" format "X(15)" space(1)
       "      7" format "X(15)" space(1)
       "      8" format "X(15)" space(1)
       "      9" format "X(15)" space(3)
       "      10" format "X(15)" space(1)
       "      11" format "X(15)" space(3)
       "      12" format "X(15)" space(1)
       "      13" format "X(9)" space(1)
       "      14" format "X(15)" space(1)
       "      15" format "X(15)" space(1)
       "      16" format "X(15)" space(1)
       "      17" format "X(15)" space(1)
       "      18" format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .
    end.
    when 4 then do:
       OUTPUT stream test to test4dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(3)
       "Касс и накл" format "X(15)" space(1)
       "Касс и накл" format "X(15)" space(3)
       " 2 - 4" format "X(15)" space(1)
       " 3 - 5" format "X(15)" space(1)
       SKIP
        " " format "X(16)" space(1)
       "объекты руб" format "X(15)" space(1)
       "оъекты б.в." format "X(15)" space(3)
       "платежи руб" format "X(15)" space(1)
       "платежи б.в." format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "      1" format "X(16)" space(1)
       "       2" format "X(15)" space(1)
       "       3" format "X(15)" space(3)
       "       4" format "X(15)" space(1)
       "       5" format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .
    end.
    when 5 then do:
       OUTPUT stream test to test5dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "Код фирмы" format "X(9)" space(3)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная сумма" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Товарная скидка" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "Сумма оплат" format "X(15)" space(1)
       "(3-5)-7)" format "X(15)" space(1)
       "(4-6)-8)" format "X(15)" space(3)
       "Сальдо" format "X(15)" space(1)
       "Сальдо" format "X(15)" space(3)
       "((3-5)-7)-11)" format "X(15)" space(1)
       "((4-6)-8)-12)" format "X(15)" space(1)
       SKIP
       " " format "X(16)" space(1)
       " " format "X(9)" space(3)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       "фирма руб" format "X(15)" space(1)
       "фирма б.в." format "X(15)" space(1)
       " " format "X(15)" space(1)
       " " format "X(15)" space(3)
       "руб" format "X(15)" space(1)
       "б.в." format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       "       1" format "X(16)" space(1)
       " 2" format "X(9)" space(3)
       "       3" format "X(15)" space(1)
       "       4" format "X(15)" space(1)
       "       5" format "X(15)" space(1)
       "       6" format "X(15)" space(1)
       "       7" format "X(15)" space(1)
       "       8" format "X(15)" space(1)
       "       9" format "X(15)" space(1)
       "       10" format "X(15)" space(3)
       "       11" format "X(15)" space(1)
       "       12" format "X(15)" space(3)
       " " format "X(15)" space(1)
       " " format "X(15)" space(1)
       SKIP
       .
    end.
    WHEN 6 THEN DO:
        OUTPUT stream test to test6dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "№ НАКЛ/ПРОД" format "X(14)" space(1)
        "Сумма по чекам" format "X(15)" space(1)
        "Сумма по чекам" format "X(15)" space(3)
        "Касс и накл" format "X(15)" space(1)
        "Касс и накл" format "X(15)" space(3)
        " 3 - 5" format "X(15)" space(1)
        " 4 - 6" format "X(15)" space(1)
        SKIP
         " " format "X(16)" space(1)
         " " format "X(14)" space(1)
        "объекты руб" format "X(15)" space(1)
        "оъекты б.в." format "X(15)" space(3)
        "платежи руб" format "X(15)" space(1)
        "платежи б.в." format "X(15)" space(3)
        " " format "X(15)" space(1)
        " " format "X(15)" space(1)
        SKIP
        "      1" format "X(16)" space(1)
        "       2" format "X(14)" space(1)
        "       3" format "X(15)" space(3)
        "       4" format "X(15)" space(1)
        "       5" format "X(15)" space(3)
        "       6" format "X(15)" space(3)
        " " format "X(15)" space(1)
        " " format "X(15)" space(1)
        SKIP
        .
    END.
    WHEN 7 THEN DO:
        OUTPUT stream test to test7dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "Тип"   FORMAT "X(8)"   space(1)
        "Сумма оплаченного" format "X(15)" space(1)
        "% скидки" format "X(9)" space(1)
        "Верный %" format "X(9)" space(1)
        SKIP
        .
   END.
    WHEN 8 then do:
       OUTPUT stream test to test1dc.txt.
       PUT STREAM test UNFORMATTED
       "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
       SKIP
       "НОМЕР КАРТЫ" format "X(16)" space(1)
       "М-н"    format "X(5)" space(1)
       "Кол. чеков в БД" format "X(19)" space(1)
       "Кол. чеков объект" format "X(19)" space(1)
       "Сумма нетто руб чеков" format "X(19)" space(1)
       "Сумма нетто руб объект" format "X(19)" space(1)
       SKIP
       .
    END.
    WHEN 99 THEN DO:
        OUTPUT stream test to test99dc.txt.
        PUT STREAM test UNFORMATTED
        "ДИСКОНТНЫЕ КАРТЫ " f-d-card " Фильтр - " filter-name
        SKIP
        FILL(chr(32), 20)
        "НОМЕР КАРТЫ" format "X(16)" space(1)
        "Тип"   FORMAT "X(8)"   space(1)
        "Кол-во чеков в БД"   format "X(19)" space(1)
        "Кол-во чеков расчет" format "X(19)" space(1)
        SKIP
        .
   END.
END CASE.
  if f-d-card = "all" or f-d-card = "ALL" THEN DO:
   run utl/tstdisoq.p (
                 input parparentproc
                ,input "ALL":U
                ,input test-number
                ,input f-d-card
                ,input (if RS-dctype = 'фирма':U then v-cntxt-host-code-obj else 0)
                ,INPUT rs-view-mode
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                 )
  .
  END.
  ELSE DO:
   run utl/tstdisoq.p (
                 input parparentproc
                ,input "":U
                ,input test-number
                ,input f-d-card
                ,input (if RS-dctype = 'фирма':U then v-cntxt-host-code-obj else 0)
                ,INPUT rs-view-mode
                ,input "":U
                ,input 0
                 )
  .
  END.
run waitfram-hide in this-procedure .
OUTPUT STREAM test close.
END PROCEDURE.
