block-level on error undo, throw.
define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-doc-code         as character FORMAT "x(14)"       no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-exch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-exch.p $":U .
define variable vss-description as character no-undo init "обмен талонов на нефтепродукты".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define stream Out-Stream.
define variable sym1  as character initial "|"   no-undo.
define variable sym2  as character initial "|"   no-undo.
define variable sym3  as character initial "|"   no-undo.
define variable sym4  as character initial "|"   no-undo.
define variable sym5  as character initial "|"   no-undo.
define variable sym6  as character initial "|"   no-undo.
define variable v-range       as character    no-undo.
define variable v-doc-date    as date         no-undo .
define variable v-firm-name   as character FORMAT "x(40)"    no-undo.
define variable g#quest-print as logical   no-undo .
define variable g#log         as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-counter    as integer      no-undo.
define buffer buf_goods        for ub.goods .
define buffer buf_wth-doc      for ub.wth-doc .
define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .
  DEFINE FRAME frm-exch-1
      sym1                 no-label  format "X(1)"  space(0)
      ub.goods.gds-name       no-label  format "x(33)" space(0)
      sym3                 no-label  format "X(1)"  space(0)
      ub.wealth.wth-name      no-label  format "X(33)" space(0)
      sym2                 no-label  format "X(1)"  space(0)
      ub.wth-ser.series       no-label  format "X(18)" space(0)
      Sym4                 no-label  format "X(1)"  space(0)
      v-range              no-label  format "x(32)" space(0)
      sym5                 no-label  format "X(1)"  space(0)
      ub.wth-parts.fact-qnty  no-label  format "->>>,>>>,>>9"  space(0)
      sym6                 no-label  format "X(1)"  space(0)
     HEADER
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                                 |                                 |                  |                                |            |" skip
         "|   Наименование нефтепродуктов   |             купюры              |       серия      |           № талона             | количество |" skip
         "|                                 |                                 |                  |                                |  талонов   |" skip
         "|                                 |                                 |                  |                                |            |" skip
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                 1               |               2                 |         3        |                4               |      5     |" skip
      with width 136 down stream-io use-text no-label NO-BOX.
  DEFINE FRAME frm-exch-2
      sym1                 no-label  format "X(1)"  space(0)
      ub.goods.gds-name       no-label  format "x(33)" space(0)
      sym3                 no-label  format "X(1)"  space(0)
      ub.wealth.wth-name      no-label  format "X(33)" space(0)
      sym2                 no-label  format "X(1)"  space(0)
      ub.wth-ser.series       no-label  format "X(18)" space(0)
      Sym4                 no-label  format "X(1)"  space(0)
      v-range              no-label  format "x(32)" space(0)
      sym5                 no-label  format "X(1)"  space(0)
      ub.wth-parts.fact-qnty  no-label  format "->>>,>>>,>>9"  space(0)
      sym6                 no-label  format "X(1)"  space(0)
     HEADER
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                                 |                                 |                  |                                |            |" skip
         "|   Наименование нефтепродуктов   |             купюры              |       серия      |           № талона             | количество |" skip
         "|                                 |                                 |                  |                                |  талонов   |" skip
         "|                                 |                                 |                  |                                |            |" skip
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                 1               |               2                 |         3        |                4               |      5     |" skip
      with width 136 down stream-io use-text no-label NO-BOX.
MAIN-BLOCK:
do
on error undo, return error
:
   run waitfram-show in this-procedure ( input "Заполнение формы. Ждите..." ).
   find first buf_wth-doc
        where buf_wth-doc.doc-code = p-doc-code
        no-lock
        .
   assign
      v-doc-date = buf_wth-doc.fact-date
   .
   FIND FIRST This_Object
        WHERE This_Object.obj-type  = buf_wth-doc.obj-type
          AND This_Object.obj-code  = buf_wth-doc.obj-code
        NO-LOCK
        .
   FIND FIRST buf_clients
        WHERE buf_clients.obj-type  = 'орг':U
          AND buf_clients.obj-code  = buf_wth-doc.host-code
        NO-LOCK
        .
   assign
      v-firm-name = buf_clients.obj-name
   .
   release buf_wth-doc .
   run get-report-num  in parParentProc ( output g#report-num ).
   run get-quest-print in parParentProc ( output g#quest-print ).
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
   assign
      v-counter = 0
   .
   run print-header-1 in this-procedure .
   run print-body-1   in this-procedure .
   run print-footer-1 in this-procedure .
   assign
      v-counter = 0
   .
   run print-header-2 in this-procedure .
   run print-body-2   in this-procedure .
   run print-footer-2 in this-procedure .
   run waitfram-hide in this-procedure .
   output stream Out-Stream CLOSE .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure print-header-1 :
do
on error undo, return error
:
   PUT  STREAM Out-Stream
      SPACE(60) "Форма НН-3-ДО" SKIP
      SPACE(5) v-firm-name    FORMAT "x(40)"  SKIP
      SPACE(5) "_______________________________________" SKIP
      SPACE(5) "(наименование предприятия, организации)" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(50) "|   Вид операции | Склад  |" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(50) "|                |        |" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(21) "НАКЛАДНАЯ No." p-doc-code FORMAT "x(14)"  SKIP
      SPACE(15) "НА ОБМЕН ТАЛОНОВ НА НЕФТЕПРОДУКТЫ" SKIP
      SPACE(25) "(литровые)" SKIP
      SPACE(25) v-doc-date FORMAT "99/99/9999" "г." SKIP(1)
      SPACE(5) "Основание ____________________________________________________________" SKIP(1)
      SPACE(5) "Кому ________________________________ через кого _____________________" SKIP(1)
      SPACE(5) "доверенность No. ____________" SKIP(2)
      SPACE(11) "РАСШИФРОВКА ПРИНЯТЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО"    SKIP
      SPACE(10) "КУПЮРАМ, СЕРИЯМ И НОМЕРАМ (ЕДИНЫХ, РЫНОЧНОГО ФОНДА)" SKIP(1)
   .
end.
end procedure.
procedure print-header-2 :
do
on error undo, return error
:
   PUT  STREAM Out-Stream
      SPACE(11) "РАСШИФРОВКА ВЫДАННЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО" SKIP
      SPACE(10) "КУПЮРАМ, СЕРИЯМ И НОМЕРАМ (ЕДИНЫХ, РЫНОЧНОГО ФОНДА)" SKIP
   .
end.
end procedure.
procedure print-body-1 :
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_wealth      for ub.wealth .
define buffer buf_goods       for ub.goods .
define buffer buf_wth-ser     for ub.wth-ser.
do
on error undo, return error
:
   for each buf_wth-parts
      where buf_wth-parts.out-code  = p-doc-code
      and buf_wth-parts.type      = 'при':U
      no-lock
      ,
      first buf_wealth
      where buf_wealth.wth-code     = buf_wth-parts.wth-code
      no-lock
      ,
      first buf_goods
      where buf_goods.gds-code      = buf_wth-parts.gds-code
      no-lock
      ,
      first buf_wth-ser
      where buf_wth-ser.ser-code    = buf_wth-parts.ser-code
      and buf_wth-ser.db-num      = buf_wth-parts.db-num
      no-lock
      :
         assign
            v-counter = v-counter + 1
         .
         display stream Out-Stream
            buf_goods.gds-name  @ ub.goods.gds-name
            buf_wealth.wth-name @ ub.wealth.wth-name
            buf_wth-ser.series  @ ub.wth-ser.series
            SUBSTITUTE("&1 - &2", buf_wth-parts.fact-rangeFrom, buf_wth-parts.fact-rangeTo) @ v-range
            buf_wth-parts.fact-qnty @ ub.wth-parts.fact-qnty
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
         with FRAME frm-exch-1.
   end.
end.
end procedure.
procedure print-body-2 :
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_wealth      for ub.wealth .
define buffer buf_goods       for ub.goods .
define buffer buf_wth-ser     for ub.wth-ser.
do
on error undo, return error
:
   for each buf_wth-parts
      where buf_wth-parts.out-code  = p-doc-code
      and buf_wth-parts.type      = 'рас':U
      no-lock
      ,
      first buf_wealth
      where buf_wealth.wth-code     = buf_wth-parts.wth-code
      no-lock
      ,
      first buf_goods
      where buf_goods.gds-code      = buf_wth-parts.gds-code
      no-lock
      ,
      first buf_wth-ser
      where buf_wth-ser.ser-code    = buf_wth-parts.ser-code
      and buf_wth-ser.db-num      = buf_wth-parts.db-num
      no-lock
      :
         assign
            v-counter = v-counter + 1
         .
         display stream Out-Stream
            buf_goods.gds-name  @ ub.goods.gds-name
            buf_wealth.wth-name @ ub.wealth.wth-name
            buf_wth-ser.series  @ ub.wth-ser.series
            SUBSTITUTE("&1 - &2", buf_wth-parts.fact-rangeFrom, buf_wth-parts.fact-rangeTo) @ v-range
            buf_wth-parts.fact-qnty @ ub.wth-parts.fact-qnty
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
         with FRAME frm-exch-2.
   end.
end.
end procedure.
procedure print-footer-1 :
do
on error undo, return error
:
   PUT  STREAM Out-Stream
   "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
   .
   PUT  STREAM Out-Stream
      SKIP(2)
      SPACE(5) "Сдал    _____________________________  Принял _______________________" SKIP(4)
   .
end.
end procedure.
procedure print-footer-2 :
do
on error undo, return error
:
   PUT  STREAM Out-Stream
   "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
   .
   PUT  STREAM Out-Stream
      SKIP(2)
      SPACE(5) "Сдал    _____________________________  Принял _______________________"
   .
end.
end procedure.
