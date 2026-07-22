define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Запуск тестов корректности чеков" .
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE NEW SHARED STREAM PrnLibstream.
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
define buffer c-doc for ub.chk-doc.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code no-undo.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "Фильтр"
     SIZE 10 BY 1.
DEFINE BUTTON BUTTON-1
     LABEL "Нераспознанные товары"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-10
     LABEL "Товарная сумма по строкам - нетто"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-11
     LABEL "Товарная сумма по строкам - брутто-скидка"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-12
     LABEL "Один код - разные цены в одном чеке"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-13
     LABEL "Сумма списания - сумма по строкам списания"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-14
     LABEL "Скидки погрешностей и округления"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-2
     LABEL "Товарная сумма по строкам и оплаты (abbr_rubli)"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-3
     LABEL "Товарная сумма по строкам и оплаты (баз вал)"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-4
     LABEL "Оплаты (abbr_rubli) - нетто"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-5
     LABEL "Оплаты (баз вал) - нетто"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-6
     LABEL "Нераспознанные платежи"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-7
     LABEL "Оплаты abbr_rubli - оплаты баз вал (только для баз вал=0)"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-8
     LABEL "Скидки по строкам - общая скидка чека"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-9
     LABEL "Нетто - брутто-скидка"
     SIZE 56.38 BY 1.08.
DEFINE VARIABLE F-sch AS CHARACTER FORMAT "X(256)":U
     LABEL "Фильтр"
      VIEW-AS TEXT
     SIZE 54.88 BY .67 NO-UNDO.
DEFINE VARIABLE my-inkas AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер продажи или ? или all"
     VIEW-AS FILL-IN
     SIZE 14.63 BY .92 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sch AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     my-inkas AT ROW 3.08 COL 29 COLON-ALIGNED
     BUTTON-1 AT ROW 4.25 COL 1.75
     BUTTON-2 AT ROW 5.42 COL 1.75
     BUTTON-3 AT ROW 6.58 COL 1.75
     BUTTON-4 AT ROW 7.79 COL 1.75
     BUTTON-5 AT ROW 9 COL 1.75
     BUTTON-9 AT ROW 10.21 COL 1.75
     BUTTON-10 AT ROW 11.42 COL 1.75
     BUTTON-11 AT ROW 12.58 COL 1.75
     BUTTON-12 AT ROW 13.79 COL 1.75
     BUTTON-6 AT ROW 15 COL 1.75
     BUTTON-7 AT ROW 16.21 COL 1.75
     BUTTON-8 AT ROW 17.42 COL 1.75
     BUTTON-13 AT ROW 18.58 COL 1.75
     BUTTON-14 AT ROW 19.75 COL 1.75
     F-sch AT ROW 2.21 COL 21.63 COLON-ALIGNED
     "test8.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 17.42 COL 59.5
          FGCOLOR 4
     "test1.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 4.25 COL 59.25
          FGCOLOR 4
     "Результаты ищите в файле:" VIEW-AS TEXT
          SIZE 25.25 BY 1 AT ROW 3.08 COL 51.63
          FGCOLOR 4
     "test10.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 11.42 COL 59.25
          FGCOLOR 4
     "test9.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 10.21 COL 59.25
          FGCOLOR 4
     "test12.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 13.79 COL 59.25
          FGCOLOR 4
     "test11.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 12.58 COL 59.25
          FGCOLOR 4
     "test3.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 6.58 COL 59.25
          FGCOLOR 4
     "test2.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 5.42 COL 59.25
          FGCOLOR 4
     "test5.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 9 COL 59.25
          FGCOLOR 4
     "test4.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 7.79 COL 59.25
          FGCOLOR 4
     "test14.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 19.75 COL 59.5
          FGCOLOR 4
     "test7.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 16.21 COL 59.25
          FGCOLOR 4
     "test6.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 15 COL 59.25
          FGCOLOR 4
     "test13.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 18.58 COL 59.5
          FGCOLOR 4
     SPACE(2.74) SKIP(1.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тесты корректности чеков"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  if v-cntxt-obj-type = 'скл':U then do:
    message
    "Опция ФИЛЬТР работает только при запуске утилиты на объекте типа МАГАЗИН!"
    view-as alert-box ERROR.
    return no-apply.
  end.
  assign
  c-point = "chk-docs" + 'объект':U
  tbl = 'chk-doc'
  join-tbl = 'c-DOC'
  fld = 'doc-code,chk-date,office,shift-date,shift-num,chk-num,pay-desk,cashier,sales-man,tot-doc,discnt,sub-discnt,netto,out-code,d-card'
  lab = 'Номер в базе,,,Смена от,Номер смены,Номер по кассе,,,,,,Сумма списанного,Нетто сумма (выручка),Номер продажи,N дис.карты'
  spr = ',,,,,,,,,,,,,,'
  dim = '15'.
  run gbl/filter.w ( input parparentproc
                   , input (c-point + chr(4) + "Список чеков, один объект")
                   , input tbl
                   , input join-tbl
                   , input fld
                   , input lab
                   , input spr
                   , input dim).
  define variable v-flt-rec as recid no-undo .
  run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
  MY-WHERE-PHRASE = REPLACE(WHERE-PHRASE, "C-DOC", "CHK-DOC").
  assign f-sch = filter-name.
  display f-sch with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas =  "?" then my-inkas = ?.
  assign test-number = 1.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-10 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas  = "?" then my-inkas = ?.
  assign test-number = 10.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-11 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 11.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-12 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 12.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-13 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 13.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-14 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 14.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 2.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 3.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-4 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 4.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-5 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 5.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-6 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 6.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-7 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 7.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-8 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 8.
  run test0 no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-9 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  if my-inkas = "?" then my-inkas = ?.
  assign test-number = 9.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type8 as character no-undo.
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
  ,output varscales-pref-type8
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type8 as character no-undo.
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
  ,output varpgscales-pref-type8
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
  assign
  BUTTON-2:LABEL in frame Dialog-Frame = "Товарная сумма по строкам и оплаты (рубли)"
  BUTTON-4:LABEL in frame Dialog-Frame = "Оплаты (рубли) - нетто"
  BUTTON-7:LABEL in frame Dialog-Frame = "Оплаты рубли - оплаты баз вал (только для баз вал=0)"
  .
  RUN MyEnable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY my-inkas F-sch
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sch B-Help my-inkas BUTTON-1 BUTTON-2 BUTTON-3 BUTTON-4
         BUTTON-5 BUTTON-9 BUTTON-10 BUTTON-11 BUTTON-12 BUTTON-6 BUTTON-7
         BUTTON-8 BUTTON-13 BUTTON-14 F-sch
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyENable :
DISPLAY my-inkas F-sch
      WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-sch
  B-Help
  my-inkas
  BUTTON-1
  BUTTON-2 WHEN v-curr-r-b = 'rubl':U OR v-base-code = 0
  BUTTON-3 WHEN v-curr-r-b = 'base':U OR v-base-code = 0
  BUTTON-4 WHEN v-curr-r-b = 'rubl':U OR v-base-code = 0
  BUTTON-5 WHEN v-curr-r-b = 'base':U OR v-base-code = 0
  BUTTON-9
  BUTTON-10
  BUTTON-11
  BUTTON-12
  BUTTON-6
  BUTTON-7 WHEN v-base-code = 0
  BUTTON-8
  BUTTON-13
  BUTTON-14
  F-sch
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE test0 :
if not my-inkas = ? then do:
    IF my-inkas = "ALL" OR my-inkas = "all" then.
    else do:
        FIND FIRST ub.inkas no-lock where ub.inkas.inkas-code = my-inkas NO-ERROR.
        if not avail ub.inkas then do:
            message "Нет такой продажи!" view-as alert-box ERROR.
            return error.
        END.
        if test-number = 7 then do:
            FIND FIRST ub.shop no-lock where ub.shop.obj-code = ub.inkas.obj-code No-ERROR.
            FIND FIRST ub.sysconf NO-LOCK where ub.sysconf.host-code = ub.shop.host-code NO-ERROR.
            if NOT ub.sysconf.base-code = 0 then do:
                message "Базовая валюта фирмы для продажи " my-inkas " не рубли!" skip
                "Тестирование лишено смысла!" view-as alert-box.
                return error.
            end.
        end.
    end.
end.
else do:
    if v-cntxt-obj-type = 'скл':U then do:
        message
        "Тестирование незакрытых чеков возможно только на объекте типа магазин!"
        view-as alert-box ERROR.
        return error.
    end.
    if test-number = 7 then do:
      FIND FIRST sysconf NO-LOCK where sysconf.host-code = v-cntxt-host-code-obj NO-ERROR.
      if NOT sysconf.base-code = 0 then do:
        message "Базовая валюта текущей фирмы не рубли!" skip
        "Тестирование лишено смысла!" view-as alert-box.
        return error.
      end.
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
       OUTPUT stream PrnLibStream to test1.txt.
       PUT stream PrnLibStream UNFORMATTED
       "ЧЕКИ С НЕРАСПОЗНАННЫМ ТОВАРОМ ПО ПРОДАЖЕ " my-inkas " Фильтр - " filter-name
       SKIP
       "НОМЕР ЧЕКА" format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "БАР-КОД" format "X(9)" space(1)
       "Ош-ка номера продажи" format "X(20)"
       SKIP
       .
    END.
    WHEN 2 then do:
       OUTPUT stream PrnLibStream to test2.txt.
       PUT stream PrnLibStream UNFORMATTED
       "Разница между товарной суммой по строкам и оплатам (рубли) по чеку по продаже " my-inkas " Фильтр - " filter-name skip
       "Номер чека"  format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "Товарная сумма"     format "X(19)" space(1)
       "Сумма оплат"  format "X(19)" space(1)
       "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 3 then do:
       OUTPUT stream PrnLibStream to test3.txt.
       PUT stream PrnLibStream UNFORMATTED
       "Разница между товарной суммой по строкам и оплатам (баз вал) по чеку по продаже " my-inkas " Фильтр - " filter-name skip
       "Номер чека"  format "X(20)" space(1)
       "Касса"    format "X(5)" space(1)
       "Чек" format "X(6)" space(1)
       "Товарная сумма"     format "X(19)" space(1)
       "Сумма оплат"  format "X(19)" space(1)
       "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 4 then do:
        OUTPUT stream PrnLibStream to test4.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат (рубли) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма нетто"     format "X(19)" space(1)
        "Сумма оплат"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 5 then do:
        OUTPUT stream PrnLibStream to test5.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат (баз вал) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма нетто"     format "X(19)" space(1)
        "Сумма оплат"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
       "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 6 then do:
        OUTPUT stream PrnLibStream to test6.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Нераспознанные платежи по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма в валюте продаж"  format "X(19)" space(1)
        "Нет такого типа касс. платежа" format "X(29)" space(1)
        "Код валюты платежа в системе" format "X(28)" space(1)
        "Код валюты платежа в чеке" format  "X(25)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 7 then do:
        OUTPUT stream PrnLibStream to test7.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат (рубли) и суммой оплат (баз вал) чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма оплат рубли"   format "X(19)" space(1)
        "Сумма оплат баз вал"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    end.
    WHEN 8 then do:
        OUTPUT stream PrnLibStream to test8.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой скидок по строкам и общей скидкой чека продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма скидок строк"   format "X(19)" space(1)
        "Общая скидка чека"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    end.
    WHEN 9 then do:
        output stream PrnLibStream to test9.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой нетто по чеку и брутто-скидка  по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Брутто" format "X(19)" space(1)
        "Скидка" format "X(19)" space(1)
        "Нетто"     format "X(19)" space(1)
        "Разность брутто-скидка"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        SKIP.
    END.
    WHEN 10 then do:
        output stream PrnLibStream to TEST10.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между товарной суммой по строкам чека и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Товарная сумма"     format "X(19)" space(1)
        "Сумма нетто по чеку"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        SKIP.
    END.
    WHEN 11 then do:
        output stream PrnLibStream to test11.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между товарной суммой по строкам чека и брутто-скидка по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Брутто" format "X(19)" space(1)
        "Скидка" format "X(19)" space(1)
        "Скидка на итог" format "X(19)" space(1)
        "Товарная сумма"     format "X(19)" space(1)
        "Разность брутто-скидка"  format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 12 then do:
        output stream PrnLibStream to test12.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой оплат (рубли) и суммой нетто по чекам продажи " my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Бар-код" format "X(9)" space(1)
        "Цена1" format "X(12)" space(1)
        "Цена2" format "X(12)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
    END.
    WHEN 13 then do:
        output stream PrnLibStream to test13.txt.
        PUT stream PrnLibStream UNFORMATTED
        "Разница между суммой списания и суммой по строкам списания" my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "Сумма списания" format "X(19)" space(1)
        "Сумма по строкам списания"     format "X(19)" space(1)
        "Погрешность"  format "X(19)" space(1)
        "Ош-ка номера продажи" format "X(20)"
        SKIP.
   END.
   WHEN 14 then do:
        output stream PRnLibStream to test14.txt.
        PUT STREAM PrnLibStream UNFORMATTED
        "Скидки погрешностей и округления" my-inkas " Фильтр - " filter-name
        skip
        "Номер чека"  format "X(20)" space(1)
        "Дата"  format "X(10)" space(1)
        "№ продажи"  format "X(20)" space(1)
        "Касса"    format "X(5)" space(1)
        "Чек" format "X(6)" space(1)
        "№№" format "X(6)"  space(1)
        "Бар-код" FORMAT "X(9)"  SPACE(1)
        "Цена" FORMAT "X(15)"  SPACE(1)
        "Кол-во" FORMAT "X(11)"   SPACE(1)
        "Сумма нетто" FORMAT "X(22)"  SPACE(1)
        "Скидка погрешности" format "X(22)"  space(1)
        "Сумма погрешности" format "X(22)"
        SKIP.
   END.
END CASE.
define variable v-prepare-phrase as character no-undo .
if my-inkas = "ALL" OR my-inkas = "all" then do:
  v-prepare-phrase = substitute('FOR EACH inkas NO-LOCK where ' +
                                ' inkas.obj-type = &1&2&1 ' +
                                ' AND  inkas.obj-code = &3,' +
                                ' EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.out-code = inkas.inkas-code &4'
                              ,chr(34)
                              ,'маг':U
                              ,v-cntxt-obj-code
                              ,my-where-phrase).
  run utl/testq00.p (
             input parparentproc
            ,input test-number
            ,input my-inkas
            ,INPUT v-cntxt-obj-type
            ,INPUT v-cntxt-obj-code
            ,input v-prepare-phrase
            ,input varscales-pref
            ,input varpgscales-pref
            )
   no-error.
end.
else do:
  if my-inkas = ?
  or my-inkas = chr(63) then do:
  v-prepare-phrase = substitute('FOR EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.obj-type = &1&2&1 ' +
                                ' AND chk-doc.obj-code = &3' +
                                ' and chk-doc.out-code = ? &4'
                              ,chr(34)
                              ,'маг':U
                              ,v-cntxt-obj-code
                              ,my-where-phrase).
  end.
  else do:
  v-prepare-phrase = substitute('FOR EACH chk-doc NO-LOCK where ' +
                                ' chk-doc.obj-type = &1&2&1 ' +
                                ' AND chk-doc.obj-code = &3' +
                                ' and chk-doc.out-code = &1&4&1 &5'
                              ,chr(34)
                              ,'маг':U
                              ,v-cntxt-obj-code
                              ,my-inkas
                              ,my-where-phrase).
  end.
  run utl/testq00.p (
             input parparentproc
            ,input test-number
            ,input my-inkas
            ,INPUT v-cntxt-obj-type
            ,INPUT v-cntxt-obj-code
            ,input v-prepare-phrase
            ,input varscales-pref
            ,input varpgscales-pref
            )
  no-error.
end.
if not test-number = 1 and NOT test-number = 6 then
PUT stream PrnLibStream UNFORMATTED
"Накопленная погрешность"
SKIP
accum1 format "-999,999.9999999999"
SKIP.
run waitfram-hide in this-procedure .
OUTPUT stream PrnLibStream close.
END PROCEDURE.
