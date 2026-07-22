define input  parameter parparentproc   as widget-handle no-undo.
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-mode          as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as integer   no-undo .
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-search-code   as character no-undo .
define output parameter p-sel-node-code as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Окно просмотра признаков товара".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5':u,p-gds-code,p-mode,p-obj-type,p-obj-code,p-doc-code)
    .
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
define temp-table temp-gds-prt no-undo
  field b-code     as integer   format '9999999999':u       label "Осн. код"
  field sort-code  as character                             label "Код сортировки по признакам"
  field node-code  as integer
  field upper-code as integer
  field prt-name   as character format 'x(35)':u            label "Признак"
  field node-name  as character format 'x(16)':u            label "Признак"
  field free-qnty  as decimal   format '->>>,>>>,>>9.999':u label "Свободно"
  field fact-qnty  as decimal   format '->>>,>>>,>>9.999':u label "Факт"
  field price      as decimal   format '>>>,>>>,>>9.99':u   label "Цена"
  field price-ord  as decimal   format '>>>,>>>,>>9.99':u   label "Цена заказа"
  field diff-qnty  as decimal   format '->>>,>>>,>>9.999':u label "Разница"
  field rest-qnty  as decimal   format '->>>,>>>,>>9.999':u label "Факт остаток"
  field prt-level  as integer                               label "Уровень"
  field show-list  as logical                               label "Структура"
  field show-prt   as logical                               label "Движение на объекте"
  field show-rest  as logical                               label "Есть остатки"
  index xpk is primary unique node-code
  index xie1 sort-code
  index xie2 show-rest
  index xie3 show-prt
  index xie4 show-list
.
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable v-filter-mode  as character no-undo .
define variable v-sort-mode    as character no-undo .
define variable v-free-qnty    as decimal   no-undo .
define variable v-fact-qnty    as decimal   no-undo .
define variable v-need-refresh as logical   no-undo .
define variable v-prt-name as character no-undo format "x(35)" label "Признак" .
FUNCTION get-prt-name RETURNS CHARACTER
  ( BUFFER buf_temp-gds-prt FOR temp-gds-prt )  FORWARD.
DEFINE BUTTON b-alt
     LABEL "&Неос/Доп"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-arch
     LABEL "&Арх.Товар"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-check
     LABEL "&Чеки"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-codes
     LABEL "&Коды"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-crebcprt
     LABEL "Добав.БК"
     SIZE 11 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print-ticket
     LABEL "&Ценник"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-prt-arch
     LABEL "&Обороты"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-refresh
     LABEL "Обновить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-rest
     LABEL "&Остатки"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-scale
     LABEL "&Шкала"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fi-fact AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-filter-label AS CHARACTER FORMAT "X(256)":U INITIAL "Фильтр:"
      VIEW-AS TEXT
     SIZE 23.63 BY .67 NO-UNDO.
DEFINE VARIABLE fi-free AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-gds AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-gds-label AS CHARACTER FORMAT "X(256)":U INITIAL "Товар:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-label AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE fi-search-b-code AS CHARACTER FORMAT "X(40)":U
     LABEL "Код(весь)"
     VIEW-AS FILL-IN
     SIZE 28.75 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE fi-sort-label AS CHARACTER FORMAT "X(256)":U INITIAL "Сортировка/Вид:"
      VIEW-AS TEXT
     SIZE 23.75 BY .67 NO-UNDO.
DEFINE VARIABLE RADIO-SET-filter AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"На объекте", 2,
"Остаток", 3
     SIZE 39.13 BY .88
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RADIO-SET-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "&Бар-код", 1,
"&Признак", 2,
"&Дерево", 3
     SIZE 39 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      temp-gds-prt SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      b-code
      get-prt-name(buffer temp-gds-prt) @ v-prt-name
      free-qnty
      fact-qnty
      price
      price-ord
      diff-qnty
      rest-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.63 BY 15.58.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 9
     b-check AT ROW 1 COL 17
     b-codes AT ROW 1 COL 25
     b-alt AT ROW 1 COL 33
     b-rest AT ROW 1 COL 43
     b-arch AT ROW 1 COL 53
     b-prt-arch AT ROW 1 COL 64
     b-print AT ROW 1 COL 74
     b-help AT ROW 1 COL 84
     b-scale AT ROW 2 COL 9
     b-print-ticket AT ROW 2 COL 17
     b-crebcprt AT ROW 2 COL 25
     b-refresh AT ROW 2 COL 36
     fi-search-b-code AT ROW 2.13 COL 61.38 COLON-ALIGNED
     RADIO-SET-sort AT ROW 5.21 COL 28 NO-LABEL
     RADIO-SET-filter AT ROW 6.21 COL 27.63 NO-LABEL
     BROWSE-1 AT ROW 7.5 COL 1.5
     fi-gds-label AT ROW 3.38 COL 1.88 NO-LABEL
     fi-gds AT ROW 3.38 COL 16.75 NO-LABEL
     fi-obj AT ROW 4.25 COL 16.63 NO-LABEL
     fi-obj-label AT ROW 4.29 COL 1.75 NO-LABEL
     fi-free AT ROW 5.25 COL 75.75 COLON-ALIGNED
     fi-sort-label AT ROW 5.33 COL 1.88 NO-LABEL
     fi-fact AT ROW 6.21 COL 75.88 COLON-ALIGNED
     fi-filter-label AT ROW 6.42 COL 2.13 NO-LABEL
     SPACE(73.36) SKIP(16.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Признаки товара"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-alt IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run show-alt in this-procedure .
  assign
    v-need-refresh = true
  .
  run local-open-query in this-procedure
    (input ?
    ) .
END.
ON CHOOSE OF b-arch IN FRAME Dialog-Frame
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
  run show-gds-arch in this-procedure .
END.
ON CHOOSE OF b-check IN FRAME Dialog-Frame
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
  run show-check in this-procedure .
END.
ON CHOOSE OF b-codes IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    v-need-refresh = true
  .
  run show-codes in this-procedure .
  if v-need-refresh then do:
    run local-open-query in this-procedure
      (input ?
      ) .
  end.
END.
ON CHOOSE OF b-crebcprt IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-create-bar-code as integer   no-undo .
  define variable v-is-new          as logical   no-undo .
  run str/crebcprt.w
    (input  parparentproc
    ,input  p-gds-code
    ,input  false
    ,output v-create-bar-code
    ,output v-is-new
    ) .
  if v-is-new = true
  then do:
    assign
      v-need-refresh = true
    .
  end.
  run local-open-query in this-procedure
    (input v-create-bar-code
    ) .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 apply "go" to frame Dialog-Frame .
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run print-temp-gds-prt in this-procedure .
END.
ON CHOOSE OF b-print-ticket IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define buffer buf_bar-code for ub.bar-code .
  if available temp-gds-prt
  then do:
    find first buf_bar-code no-lock
         where buf_bar-code.b-code = temp-gds-prt.b-code
         .
      run rep/tick-one.p
        (input parparentproc
        ,input p-obj-type
        ,input p-obj-code
        ,input recid(buf_bar-code)
        ) .
  end.
END.
ON CHOOSE OF b-prt-arch IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run show-gds-prt in this-procedure .
END.
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run make-temp-table in this-procedure no-error .
  run waitfram-hide in this-procedure .
  run local-open-query in this-procedure
    (input ?
    ) .
END.
ON CHOOSE OF b-rest IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run show-rest in this-procedure .
END.
ON CHOOSE OF b-scale IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run show-scale in this-procedure .
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if available temp-gds-prt
  then do:
    assign
      p-sel-node-code = temp-gds-prt.node-code
    .
  end.
  apply "go" to frame Dialog-Frame .
END.
ON RETURN OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  apply "choose":U to b-sel.
END.
ON RETURN OF fi-search-b-code IN FRAME Dialog-Frame
DO:
  define variable v-find-next as logical   no-undo .
  if fi-search-b-code <> input frame Dialog-Frame fi-search-b-code then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.
  do with frame Dialog-Frame:
    assign
      fi-search-b-code
    .
  end.
  run search-bar-code in this-procedure
    (input fi-search-b-code
    ,input false
    ) .
END.
ON VALUE-CHANGED OF RADIO-SET-filter IN FRAME Dialog-Frame
DO:
  assign
    radio-set-filter
    .
  case radio-set-filter :
    when 1 then do:
      assign
        v-filter-mode = 'filter-b-code':u
      .
    end.
    when 2 then do:
      assign
        v-filter-mode = 'filter-prt-obj':u
      .
    end.
    when 3 then do:
      assign
        v-filter-mode = 'filter-not-zero':u
      .
    end.
  end case .
  run local-open-query in this-procedure
    (input ?
    ) .
END.
ON VALUE-CHANGED OF RADIO-SET-sort IN FRAME Dialog-Frame
DO:
  assign
    radio-set-sort
    .
  case radio-set-sort :
    when 1 then do:
      assign
        v-sort-mode = 'sort-b-code':u
      .
    end.
    when 2 then do:
      assign
        v-sort-mode = 'sort-sort-code':u
      .
    end.
    when 3 then do:
      assign
        v-sort-mode = 'sort-tree':u
      .
    end.
  end case .
  run local-open-query in this-procedure
    (input ?
    ) .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
assign
  RADIO-SET-sort   = 2
  RADIO-SET-filter = 3
  v-sort-mode      = 'sort-sort-code':u
  v-filter-mode    = 'filter-not-zero':u
.
assign
  p-sel-node-code = ?
.
define variable v-ok as logical   no-undo .
assign
  v-ok = BROWSE-1 :set-repositioned-row(5, "conditional")
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run validate-input-parameters in this-procedure .
  run make-temp-table in this-procedure .
  run waitfram-hide in this-procedure .
  RUN enable_UI.
  run show-input-info in this-procedure .
  if fi-search-b-code <> ""
  then do:
    run search-bar-code in this-procedure
      (input fi-search-b-code
      ,input true
      ) no-error .
    if error-status :error
    then do:
      assign
        fi-search-b-code :screen-value = ""
      .
      assign
        fi-search-b-code
      .
    end.
  end.
  if p-mode = 'выбор':U
  then do:
    assign
      b-sel :sensitive = true
    .
  end.
  else do:
    assign
      b-sel :sensitive = false
    .
  end.
  define variable v-empty-scale as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'empty-scale=request':u
  ,output v-empty-scale
  )  .
  if v-empty-scale = false
  then do:
    assign
      b-crebcprt :sensitive = true
    .
  end.
  else do:
    assign
      b-crebcprt :sensitive = false
    .
  end.
  apply 'entry':U to BROWSE-1.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-search-b-code RADIO-SET-sort RADIO-SET-filter fi-gds-label fi-gds
          fi-obj fi-obj-label fi-free fi-sort-label fi-fact fi-filter-label
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-sel b-check b-codes b-alt b-rest b-arch b-prt-arch b-print
         b-help b-scale b-print-ticket b-crebcprt b-refresh fi-search-b-code
         RADIO-SET-sort RADIO-SET-filter BROWSE-1 fi-gds-label fi-gds fi-obj
         fi-obj-label fi-free fi-sort-label fi-fact fi-filter-label
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure (input ? ) .
END PROCEDURE.
PROCEDURE get-sort-code :
  define input  parameter p-node-code as integer   no-undo .
  define output parameter p-sort-code as character no-undo .
  define buffer buf_gds-prt for ub.gds-prt .
  define variable v-upper-code as integer   no-undo .
  define variable v-sort-code  as character no-undo .
  define variable v-curr-node-sort as character no-undo .
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .
  do while true
  :
    assign
      v-curr-node-sort = string(buf_gds-prt.prt-num, '999999999':u)
    .
    assign
      v-upper-code = buf_gds-prt.upper-code
    .
    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = v-upper-code
      no-error .
    if not available buf_gds-prt
    then do:
      leave .
    end.
    assign
      v-sort-code = v-curr-node-sort  + '/' + v-sort-code
    .
  end.
  assign
    p-sort-code = v-sort-code
  .
END PROCEDURE.
PROCEDURE local-open-query :
  define input  parameter p-reposition-b-code as integer   no-undo .
  define variable v-last-b-code as integer   no-undo .
  if p-reposition-b-code <> ?
  then do:
    assign
      v-last-b-code = p-reposition-b-code
    .
  end.
  else do:
    if available temp-gds-prt
    then do:
      assign
        v-last-b-code = temp-gds-prt.b-code
      .
    end.
    else do:
      assign
        v-last-b-code = ?
      .
    end.
  end.
  if  v-need-refresh = true
  and v-filter-mode = 'filter-b-code':u
  then do:
    run make-temp-table in this-procedure no-error .
    run waitfram-hide in this-procedure .
    assign
      v-need-refresh = false
    .
  end.
  display
    v-free-qnty @ fi-free
    v-fact-qnty @ fi-fact
    with frame Dialog-Frame .
  case v-filter-mode :
    when 'filter-b-code':u then do:
      case v-sort-mode
      :
        when 'sort-b-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-list = true
            by b-code .
        end.
        when 'sort-sort-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-list = true
            by sort-code .
        end.
        when 'sort-tree':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    when 'filter-prt-obj':u then do:
      case v-sort-mode
      :
        when 'sort-b-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-prt = true
              and temp-gds-prt.show-list = true
            by b-code .
        end.
        when 'sort-sort-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-prt = true
              and temp-gds-prt.show-list = true
            by sort-code .
        end.
        when 'sort-tree':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-prt = true
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    when 'filter-not-zero':u then do:
      case v-sort-mode
      :
        when 'sort-b-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-rest = true
              and temp-gds-prt.show-list = true
            by b-code .
        end.
        when 'sort-sort-code':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-rest = true
              and temp-gds-prt.show-list = true
            by sort-code .
        end.
        when 'sort-tree':u
        then do:
          open query BROWSE-1 for each temp-gds-prt
            where temp-gds-prt.show-rest = true
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестное значение переменной v-filter-mode" skip
        "" v-filter-mode skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  if v-last-b-code <> ?
  then do:
    define buffer buf_reposition_temp-gds-prt for temp-gds-prt .
    define variable v-reposition-rowid as rowid     no-undo .
    find first buf_reposition_temp-gds-prt
      where buf_reposition_temp-gds-prt.b-code = v-last-b-code
      no-error .
    if available buf_reposition_temp-gds-prt
    then do:
      assign
        v-reposition-rowid = rowid(buf_reposition_temp-gds-prt)
      .
      reposition BROWSE-1 to rowid v-reposition-rowid no-error .
      if error-status :error
      then do:
        reposition BROWSE-1 to row 1 .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE make-temp-table :
  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_goods        for ub.goods .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_gds-prt      for ub.gds-prt .
  for each buf_temp-gds-prt
  on error undo, return error return-value
  :
    delete buf_temp-gds-prt .
  end.
  assign
    v-free-qnty = 0
    v-fact-qnty = 0
  .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  define variable v-root-node as integer   no-undo .
  define variable v-prt-level as integer   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtlevel in g#library
  (input  v-root-node
  ,output v-prt-level
  )  .
  define variable v-ind as integer   no-undo .
  assign
    v-ind = 0
  .
  for each buf_prt-obj no-lock
    where buf_prt-obj.obj-type  = p-obj-type
      and buf_prt-obj.obj-code  = p-obj-code
      and buf_prt-obj.artic     = buf_goods.artic
      and buf_prt-obj.prod-type = buf_goods.prod-type
      and buf_prt-obj.prod-code = buf_goods.prod-code
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Просмотр признаков товара на объекте &1", v-ind)
        ) .
    end.
    define variable v-node-code as integer   no-undo .
    assign
      v-node-code = buf_prt-obj.prt-code
    .
    define variable v-is-new as logical   no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  v-node-code
  ,input  ''
  ,input  ''
  ,input  buf_goods.unit-base
  ,input  ?
  ,output v-is-new
  ,buffer buf_bar-code
  )  .
    define variable v-term-prt as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-node-code
  ,input  'terminal-prt=request':u
  ,output v-term-prt
  )  .
    if v-term-prt = true
    then do:
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      create buf_temp-gds-prt .
      assign
        buf_temp-gds-prt.b-code     = buf_bar-code.b-code
        buf_temp-gds-prt.node-code  = v-node-code
        buf_temp-gds-prt.upper-code = buf_gds-prt.upper-code
        buf_temp-gds-prt.prt-name   = buf_gds-prt.f-name
        buf_temp-gds-prt.node-name  = buf_gds-prt.node-name
        buf_temp-gds-prt.free-qnty  = buf_prt-obj.free-qnty
        buf_temp-gds-prt.fact-qnty  = buf_prt-obj.fact-qnty
        buf_temp-gds-prt.price      = buf_prt-obj.price-sale
        buf_temp-gds-prt.price-ord  = ?
        buf_temp-gds-prt.diff-qnty  = 0
        buf_temp-gds-prt.rest-qnty  = 0
        buf_temp-gds-prt.show-list  = true
        buf_temp-gds-prt.show-prt   = true
        buf_temp-gds-prt.show-rest  = false
        buf_temp-gds-prt.prt-level  = v-prt-level
      .
      assign
        v-free-qnty = v-free-qnty + buf_prt-obj.free-qnty
        v-fact-qnty = v-fact-qnty + buf_prt-obj.fact-qnty
      .
      if (buf_temp-gds-prt.free-qnty <> 0
           and buf_temp-gds-prt.free-qnty <> ?
          )
      or (buf_temp-gds-prt.fact-qnty <> 0
           and buf_temp-gds-prt.fact-qnty = ?
          )
      then do:
        assign
          buf_temp-gds-prt.show-rest = true
        .
      end.
      run get-sort-code in this-procedure
        (input  buf_temp-gds-prt.node-code
        ,output buf_temp-gds-prt.sort-code
        ) .
    end.
  end.
  assign
    v-ind = 0
  .
  for each buf_bar-code no-lock
    where buf_bar-code.gds-code  = p-gds-code
      and buf_bar-code.part-code = ""
      and buf_bar-code.in-code   = ""
      and buf_bar-code.unit-cli  = buf_goods.unit-base
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Просмотр бар-кодов &1", v-ind)
        ) .
    end.
    find first buf_temp-gds-prt
      where buf_temp-gds-prt.node-code = buf_bar-code.node-code
      no-error .
    if not available buf_temp-gds-prt
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  buf_bar-code.node-code
  ,input  'terminal-prt=request':u
  ,output v-term-prt
  )  .
      if v-term-prt = true
      then do:
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = buf_bar-code.node-code
          .
        create buf_temp-gds-prt .
        assign
          buf_temp-gds-prt.b-code     = buf_bar-code.b-code
          buf_temp-gds-prt.node-code  = buf_bar-code.node-code
          buf_temp-gds-prt.upper-code = buf_gds-prt.upper-code
          buf_temp-gds-prt.prt-name   = buf_gds-prt.f-name
          buf_temp-gds-prt.node-name  = buf_gds-prt.node-name
          buf_temp-gds-prt.free-qnty  = 0
          buf_temp-gds-prt.fact-qnty  = 0
          buf_temp-gds-prt.price      = ?
          buf_temp-gds-prt.price-ord  = ?
          buf_temp-gds-prt.diff-qnty  = 0
          buf_temp-gds-prt.rest-qnty  = 0
          buf_temp-gds-prt.show-list  = true
          buf_temp-gds-prt.show-prt   = false
          buf_temp-gds-prt.show-rest  = false
          buf_temp-gds-prt.prt-level  = v-prt-level
        .
        run get-sort-code in this-procedure
          (input  buf_temp-gds-prt.node-code
          ,output buf_temp-gds-prt.sort-code
          ) .
      end.
    end.
  end.
  define variable v-level-tree as integer   no-undo .
  do v-level-tree = v-prt-level to 2 by -1
  :
    define buffer upper_temp-gds-prt for temp-gds-prt .
    for each buf_temp-gds-prt
      where buf_temp-gds-prt.prt-level = v-level-tree
    :
      find first upper_temp-gds-prt
        where upper_temp-gds-prt.node-code = buf_temp-gds-prt.upper-code
        no-error .
      if not available upper_temp-gds-prt
      then do:
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = buf_temp-gds-prt.upper-code
          .
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .
        find first buf_bar-code no-lock
          where buf_bar-code.gds-code  = buf_goods.gds-code
            and buf_bar-code.node-code = buf_gds-prt.node-code
            and buf_bar-code.part-code = ""
            and buf_bar-code.in-code   = ""
            and buf_bar-code.unit-cli  = buf_goods.unit-base
          no-error .
        define variable v-b-code as integer   no-undo .
        if available buf_bar-code
        then do:
          assign
            v-b-code = buf_bar-code.b-code
          .
        end.
        else do:
          assign
            v-b-code = ?
          .
        end.
        create upper_temp-gds-prt .
        assign
          upper_temp-gds-prt.b-code     = v-b-code
          upper_temp-gds-prt.node-code  = buf_gds-prt.node-code
          upper_temp-gds-prt.upper-code = buf_gds-prt.upper-code
          upper_temp-gds-prt.prt-name   = ( if v-level-tree <> 2
                                            then buf_gds-prt.f-name
                                            else buf_gds-prt.node-name
                                          )
          upper_temp-gds-prt.node-name  = buf_gds-prt.node-name
          upper_temp-gds-prt.free-qnty  = 0
          upper_temp-gds-prt.fact-qnty  = 0
          upper_temp-gds-prt.price      = ?
          upper_temp-gds-prt.price-ord  = ?
          upper_temp-gds-prt.diff-qnty  = 0
          upper_temp-gds-prt.rest-qnty  = 0
          upper_temp-gds-prt.show-list  = false
          upper_temp-gds-prt.show-prt   = false
          upper_temp-gds-prt.show-rest  = false
          upper_temp-gds-prt.prt-level  = v-level-tree - 1
        .
        run get-sort-code in this-procedure
          (input  upper_temp-gds-prt.node-code
          ,output upper_temp-gds-prt.sort-code
          ) .
      end.
      assign
        upper_temp-gds-prt.free-qnty = upper_temp-gds-prt.free-qnty + buf_temp-gds-prt.free-qnty
        upper_temp-gds-prt.fact-qnty = upper_temp-gds-prt.fact-qnty + buf_temp-gds-prt.fact-qnty
      .
      if buf_temp-gds-prt.show-prt = true
      then do:
        assign
          upper_temp-gds-prt.show-prt = true
        .
      end.
      if buf_temp-gds-prt.show-rest = true
      then do:
        assign
          upper_temp-gds-prt.show-rest = true
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE print-temp-gds-prt :
  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-gds-prt)
  .
  run ref/prtobxls.p
    (input this-procedure :handle
    ,input frame Dialog-Frame :title
    ,input "Сортировка/Вид"
    ,input radio-label(string(RADIO-SET-sort),   RADIO-SET-sort   :radio-buttons)
    ,input "Фильтр"
    ,input radio-label(string(RADIO-SET-filter), RADIO-SET-filter :radio-buttons)
    ) .
  reposition BROWSE-1 to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition BROWSE-1 to row 1 .
  end.
END PROCEDURE.
PROCEDURE prt-ref_get-current :
  define output parameter p-available as logical   no-undo .
  define output parameter p-b-code    as integer   no-undo .
  define output parameter p-prt-name  as character no-undo .
  define output parameter p-free-qnty as decimal   no-undo .
  define output parameter p-fact-qnty as decimal   no-undo .
  define output parameter p-price     as decimal   no-undo .
  if available temp-gds-prt
  then do:
    assign
      p-available = true
      p-b-code    = temp-gds-prt.b-code
      p-prt-name  = get-prt-name(buffer temp-gds-prt)
      p-free-qnty = temp-gds-prt.free-qnty
      p-fact-qnty = temp-gds-prt.fact-qnty
      p-price     = temp-gds-prt.price
    .
  end.
  else do:
    assign
      p-available = false
    .
  end.
END PROCEDURE.
PROCEDURE prt-ref_get-first :
  apply "home":u to browse BROWSE-1 .
END PROCEDURE.
PROCEDURE prt-ref_get-next :
  get next BROWSE-1 .
END PROCEDURE.
PROCEDURE search-bar-code :
  define input  parameter p-search-code  as character no-undo .
  define input  parameter p-first-search as logical   no-undo .
  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .
  define variable v-b-code as integer   no-undo .
  run gbl/getbcode.p
    (input  parparentproc
    ,input  p-search-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  true
    ,output v-b-code
    ) .
  if v-b-code = ?
  then do:
    if p-first-search <> true
    then do:
      message
        "Бар-код не найден !"
        "Бар-код" p-search-code skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  find first buf_bar-code no-lock
    where buf_bar-code.b-code = v-b-code
    no-error .
  if not available buf_bar-code
  then do:
    if p-first-search <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Бар-код не найден !"
        "Бар-код" v-b-code skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  if buf_bar-code.gds-code <> p-gds-code
  then do:
    if p-first-search <> true
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_bar-code.gds-code
        .
      message
        "Заданный бар-код принадлежит другому товару" skip
        "В данном окне поиск работает только внутри бар-кодов одного товара"
        "Бар-код" fi-search-b-code skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        view-as alert-box information .
    end.
    undo, return error return-value .
  end.
  find first buf_temp-gds-prt
    where buf_temp-gds-prt.node-code = buf_bar-code.node-code
    no-error .
  if available buf_temp-gds-prt
  then do:
    define variable v-curr-rowid as rowid no-undo .
    assign
      v-curr-rowid = rowid(temp-gds-prt)
    .
    reposition BROWSE-1 to rowid rowid(buf_temp-gds-prt) no-error .
    if error-status :error
    then do:
      message
        "Признак с указанным бар-кодом не показывается в заданных условиях выбора" skip
        "Бар-код"  buf_temp-gds-prt.b-code    skip
        "Признак"  buf_temp-gds-prt.prt-name  skip
        "Свободно" buf_temp-gds-prt.free-qnty skip
        "Факт"     buf_temp-gds-prt.fact-qnty skip
        "Цена"     buf_temp-gds-prt.price     skip
        view-as alert-box information .
      reposition BROWSE-1 to rowid v-curr-rowid no-error .
      if error-status :error
      then do:
        reposition BROWSE-1 to row 1 .
      end.
    end.
  end.
  else do:
    message
      "Внутренняя ошибка - не найден указанный признак" skip
      "Код товара" p-gds-code skip
      "Задан бар-код" v-b-code skip
      "Код признака" buf_bar-code.node-code skip
      view-as alert-box error .
  end.
END PROCEDURE.
PROCEDURE show-alt :
  define variable v-select-function as character no-undo .
  define variable v-rec-list as character no-undo .
  if available temp-gds-prt
  then do:
    run gbl/d-list.w
      (input "b-sel"
      ,input "Просмотр"
      ,input 'alt-current':u
        + chr(44) + 'alt-all':u
        + chr(44) + 'prod-all':u
      ,input "Существующие неосновные цены"
        + chr(44) + "Все неосновные коды"
        + chr(44) + "Дополнительные коды"
      ,input chr(44)
      ,'':U
      ,output v-select-function
      ).
    case v-select-function
    :
      when 'alt-current':u
      then do:
        run ref/alt-cds.w
          (input  parparentproc
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  'code-current':u
          ,input  p-gds-code
          ,input  temp-gds-prt.b-code
          ,output v-rec-list
          ).
      end.
      when 'alt-all':u
      then do:
        run ref/alt-cds.w
          (input  parparentproc
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  'code-all':u
          ,input  p-gds-code
          ,input  temp-gds-prt.b-code
          ,output v-rec-list
          ).
      end.
      when 'prod-all':u
      then do:
        run ref/prod-cds.w
          (input  parparentproc
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  'code-all':u
          ,input  p-gds-code
          ,input  temp-gds-prt.b-code
          ,output v-rec-list
          ).
      end.
    end case.
  end.
END PROCEDURE.
PROCEDURE show-check :
  define variable v-rid-list as character no-undo .
  if available temp-gds-prt
  then do:
    run ref/gds-chk.w
      (input parparentproc
      ,input temp-gds-prt.b-code
      ,input "":U
      ,input 'объект':U
      ,input ?
      ,input p-obj-type
      ,input p-obj-code
      ,input "":U
      ,input "":U
      ,output v-rid-list
      ).
  end.
END PROCEDURE.
PROCEDURE show-codes :
define buffer buf_bar-code for ub.bar-code.
  if available temp-gds-prt then do:
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = temp-gds-prt.b-code no-error .
    if available buf_bar-code then do:
      run ref/alt-bc.w
        (input parparentproc
        ,input  p-obj-type
        ,input  p-obj-code
        ,input temp-gds-prt.b-code
        ).
    end.
    else do:
      assign
      v-need-refresh = no
      .
    end.
  end.
  else do:
    assign
    v-need-refresh = no
    .
  end.
END PROCEDURE.
PROCEDURE show-gds-arch :
  run gbl/shgdsarh.p
    (input parparentproc
    ,input p-gds-code
    ,input p-obj-type
    ,input p-obj-code
    ) .
END PROCEDURE.
PROCEDURE show-gds-prt :
  if available temp-gds-prt
  then do:
    run ref/docprtob.p
      (input parparentproc
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input temp-gds-prt.b-code
      ) .
  end.
END PROCEDURE.
PROCEDURE show-input-info :
  do with frame Dialog-Frame:
    define buffer buf_goods for ub.goods .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if available buf_goods
    then do:
      assign
        fi-gds :screen-value = substitute("&1 &2 &3 &4"
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        ,buf_goods.gds-name
                                        )
      .
      assign
        frame Dialog-Frame :title = substitute("Признаки товара &1 &2 &3 &4"
                                                ,buf_goods.artic
                                                ,buf_goods.prod-type
                                                ,buf_goods.prod-code
                                                ,buf_goods.gds-name
                                                )
      .
    end.
    else do:
      assign
        fi-gds :screen-value = ''
      .
      assign
        frame Dialog-Frame :title = "Признаки товара"
      .
    end.
    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj :screen-value = substitute('&1 &2 &3'
                                ,buf_clients.obj-type
                                ,buf_clients.obj-code
                                ,buf_clients.obj-name
                                )
      .
    end.
    if p-search-code <> ""
    then do:
      assign
        fi-search-b-code :screen-value = p-search-code
      .
      assign
        fi-search-b-code
      .
    end.
  end.
END PROCEDURE.
PROCEDURE show-rest :
  if available temp-gds-prt
  then do:
    define variable v-host-code as integer   no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    define buffer buf_goods for ub.goods .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .
    run rep/gds-objs.w
      (input  parparentproc
      ,input  buf_goods.artic
      ,input  buf_goods.prod-type
      ,input  buf_goods.prod-code
      ,input  v-host-code
      ,input  temp-gds-prt.node-code
      ).
  end.
END PROCEDURE.
PROCEDURE show-scale :
  define variable v-root-node as character no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output v-root-node
  )  .
  run str/showprop.w
    (input v-root-node
    ) .
END PROCEDURE.
PROCEDURE validate-input-parameters :
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Режим" p-mode skip
      "Код товара" p-gds-code skip
      "Объект" p-obj-type p-obj-code skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable v-valid-obj as logical   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'check-exist':u
  ,output v-valid-obj
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" skip
      "Режим" p-mode skip
      "Код товара" p-gds-code skip
      "Объект" p-obj-type p-obj-code skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if lookup(p-mode, 'ПРОСМОТР':U + chr(44) + 'выбор':U) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестный режим" skip
      "Режим" p-mode skip
      "Код товара" p-gds-code skip
      "Объект" p-obj-type p-obj-code skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
END PROCEDURE.
FUNCTION get-prt-name RETURNS CHARACTER
  ( BUFFER buf_temp-gds-prt FOR temp-gds-prt ) :
  define variable v-return-prt-name as character no-undo .
  if v-sort-mode = 'sort-tree':u
  then do:
    assign
      v-return-prt-name = fill(" ", 2 * (buf_temp-gds-prt.prt-level - 1) )+ buf_temp-gds-prt.node-name
    .
  end.
  else do:
    assign
      v-return-prt-name = buf_temp-gds-prt.prt-name
    .
  end.
  RETURN v-return-prt-name.
END FUNCTION.
