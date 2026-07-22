block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " работа с деревом признаков   ".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tt-goods no-undo like ub.goods.
define new shared temp-table tt-clients no-undo like ub.clients.
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
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter doc-rec        as recid no-undo .
define input  parameter line-rec       as recid no-undo .
define input  parameter gds-rec        as recid no-undo .
define input  parameter prt-mode       as character no-undo .
define variable prt-rec        as recid no-undo .
define variable g#host-code    as integer   no-undo .
define variable g#host-name  as character no-undo .
define variable store-type     as character no-undo .
define variable store-code     as integer   no-undo .
define variable g#log          as logical   no-undo .
define variable g#report-num   as integer   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE QUERY br-dtl FOR ub.gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.
def work-table prt-tree no-undo
  field bc        like ub.bar-code.b-code    format "9999999999" column-label "Осн. код"
  field n-code    like ub.gds-prt.node-code
  field n-name    like ub.gds-prt.node-name
  field rid       as   recid
  field visible   as   log
  field exp       as   log
  field is-term   like ub.gds-prt.is-term
  field is-root   like ub.gds-prt.root
  field level     as   integer
  field mark      as   char
  field doc-amnt  like ub.gds-dtl.doc-qnty   format "->>>,>>>,>>>.<<<" init 0 column-label "По накл."
  field fac-amnt  like ub.gds-dtl.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Факт"
  field free-qnty like ub.prt-obj.free-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Свободно"
  field fact-qnty like ub.prt-obj.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Остаток"
  field price     like ub.prt-obj.price-sale format ">>>,>>>,>>9.99"   init ? column-label "Цена"
  .
define variable tree-level  as   integer           no-undo.
define variable gds-prt-row as   integer init 1    no-undo.
define variable old_qnty    like ub.doc-line.doc-qnty no-undo.
define variable shift-name  as   char              no-undo.
define variable flt-amnt    as   log               no-undo.
define variable rec-list    as   char              no-undo.
define variable print-option as character no-undo.
define variable varr-b as character no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
FUNCTION fnc-shift-name RETURN char (cur-lev  as integer,
                                     cur-mark as char,
                                     cur-name as char).
  return (fill ("  ", cur-lev) +
          cur-mark +
          " " +
          cur-name).
END FUNCTION.
def  query   br-gds-prt for prt-tree SCROLLING.
def  browse  br-gds-prt
       query br-gds-prt
       disp
       fnc-shift-name (prt-tree.level, prt-tree.mark, prt-tree.n-name) @ shift-name
       format "x(23)" column-label "Признак"
       prt-tree.doc-amnt
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
WITH SIZE 93 BY 15 separators.
DEFINE BUTTON b-exit AUTO-go
     LABEL "&Выход ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-sel AUTO-go
     LABEL "Вы&бор ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-exp-nd
     LABEL "&>>":L
     SIZE 4.5 BY 1.
DEFINE BUTTON b-exp-tree
     LABEL ">>&->>":L
     SIZE 9 BY 1.
DEFINE BUTTON b-amnt
     LABEL "&Колич":L
     SIZE 9 BY 1.
DEFINE BUTTON b-codes
     LABEL "&Коды":L
     SIZE 9 BY 1.
DEFINE MENU m-alt
       MENU-ITEM m-alt-current  LABEL "Существующие неосновные цены"
       MENU-ITEM m-alt-all      LABEL "Все неосновные коды"
       rule
       MENU-ITEM m-prod-all     LABEL "Дополнительные коды"
       .
DEFINE MENU MENU-b-print
       MENU-ITEM m_hor          LABEL "Уровни по горизонтали"
       MENU-ITEM m_vert         LABEL "Уровни по вертикали"
       .
DEFINE BUTTON b-alt
     LABEL "&Неос/Доп":L
     SIZE 9 BY 1.
DEFINE BUTTON b-rest
     LABEL "&Остатки":L
     SIZE 9 BY 1.
DEFINE MENU m-inf
       MENU-ITEM m-inf-prt      LABEL "По признаку"
       MENU-ITEM m-inf-gds      LABEL "По товару"
       .
DEFINE BUTTON b-info
     LABEL "&Архив":L
     SIZE 9 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 9 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.
DEFINE FRAME d-gds-prt
  b-exit     AT ROW 1.25  COL 1
  b-sel      AT ROW 1.25  COL 10
  b-del      AT ROW 1.25  COL 19
  b-exp-nd   AT ROW 1.25  COL 28
  b-exp-tree AT ROW 1.25  COL 32.5
  b-amnt     AT ROW 1.25  COL 41.5
  b-codes    AT ROW 1.25  COL 50.5
  b-alt      AT ROW 1.25  COL 59.5
  b-rest     AT ROW 1.25  COL 68.5
  b-info     AT ROW 1.25  COL 77.5
  b-print    AT ROW 1.25  COL 76.5
  b-help     AT ROW 1.25  COL 78.5
  ub.doc-line.doc-qnty
             at row 2.5   col 30  label "Товар" format "->>>,>>>,>>9.<<<"
  ub.goods.unit-base at row 2.5   col 70  no-label      format "x(3)"
  flt-amnt        at row 3.5   col 5   label "Только с количествами" view-as toggle-box
  br-gds-prt      AT ROW 4.5   COL 2
  WITH size 96 by 21 VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D.
  ASSIGN
  b-print:POPUP-MENU IN FRAME d-gds-prt       = MENU MENU-b-print:HANDLE.
  br-gds-prt :set-repositioned-row (10, "conditional").
  b-print:MENU-MOUSE in frame d-gds-prt  = 1.
  ASSIGN
    FRAME d-gds-prt:SCROLLABLE = FALSE
    b-info    :POPUP-MENU IN FRAME d-gds-prt         = MENU m-inf  :HANDLE
    b-info    :MENU-MOUSE                                = 1
    b-alt     :POPUP-MENU IN FRAME d-gds-prt         = MENU m-alt  :HANDLE
    b-alt     :MENU-MOUSE                                = 1
    .
on value-changed of flt-amnt do:
  gds-prt-row = current-result-row ("br-gds-prt").
  find first prt-tree.
  if input frame d-gds-prt flt-amnt then
    run exp-tree.
    run UI-on.
end.
on row-display of br-gds-prt do:
  if prt-tree.is-root then
    shift-name :fgcolor in browse br-gds-prt = BLUE_COLOR.
  else
    if not prt-tree.is-term then
      shift-name :fgcolor in browse br-gds-prt = BROWN_COLOR.
end.
ON CHOOSE OF b-exit IN FRAME d-gds-prt  DO:
  prt-rec = prt-tree.rid.
  return "exit":U.
END.
ON CHOOSE OF b-sel IN FRAME d-gds-prt  DO:
  prt-rec = prt-tree.rid.
END.
ON choose of b-del IN FRAME d-gds-prt DO:
   def var gds-prt-recid as recid   no-undo.
   def var chg-qnty      as decimal no-undo.
  if available prt-tree then do:
     assign
       gds-prt-recid = recid(prt-tree)
       prt-tree.doc-amnt = 0
     .
    disp prt-tree.doc-amnt with browse br-gds-prt.
  end.
  def buffer b-gds-prt for gds-prt .
  find gds-dtl exclusive-lock where
      gds-dtl.artic     = doc-line.artic and
      gds-dtl.prod-code = doc-line.prod-code and
      gds-dtl.prod-type = doc-line.prod-type and
      gds-dtl.doc-code  = doc-line.doc-code and
      gds-dtl.prt-code  = prt-tree.n-code no-error.
  if available gds-dtl then do:
    chg-qnty =  - ( gds-dtl.doc-qnty ).
    run trg/rsrv-dtl.p
      ( input        ParParentProc
      , input        'reserv':U
      , buffer       gds-dtl
      , input-output chg-qnty
      , input-output doc-line.price-base
      , input-output doc-line.price-rubl
      , input        -1
      , input ""
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "rsrv-dtl.p "
        view-as alert-box error
      .
    end.
    delete gds-dtl .
  end.
  run clc-nd (buffer prt-tree).
  disp  prt-tree.doc-amnt
        prt-tree.bc
        with browse br-gds-prt.
  find first prt-tree.
   run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
  run ui-on.
  reposition br-gds-prt to recid gds-prt-recid no-error.
END.
ON choose of b-exp-nd IN FRAME d-gds-prt DO:
  gds-prt-row = current-result-row ("br-gds-prt").
  run exp-nd (?).
  run UI-on.
END.
ON choose of b-exp-tree IN FRAME d-gds-prt DO:
  gds-prt-row = current-result-row ("br-gds-prt").
  run exp-tree.
  run UI-on.
END.
ON MOUSE-SELECT-DBLCLICK, return OF br-gds-prt IN FRAME d-gds-prt DO:
  gds-prt-row = current-result-row ("br-gds-prt").
  if prt-tree.is-term then do:
    if b-amnt:sensitive then
      apply "choose" to b-amnt in frame d-gds-prt.
  end.
  else
    apply "choose" to b-exp-nd in frame d-gds-prt.
  return no-apply.
END.
ON CHOOSE OF b-amnt IN FRAME d-gds-prt  DO:
  DEFINE VARIABLE rid-list as character no-undo .
  gds-prt-row = current-result-row ("br-gds-prt").
  if not prt-tree.is-root and
     not prt-tree.is-term then do:
    message "Данный признак промежуточный и не может быть выбран."
            view-as alert-box error.
    return no-apply.
  end.
  case ub.trn-doc.doc-type:
    when 'при':U or
    when 'рас':U or
    when 'спи':U or
    when 'возврат':U then
      run str/out-prt.w (
                      parParentProc ,
                      doc-rec       ,
                      line-rec      ,
                      gds-rec       ,
                      prt-mode      ,
                      prt-tree.rid,
                     (if prt-tree.is-term then 'терм':U  else 'корн':U))
                     no-error.
    when 'инв':U then do:
      if ub.trn-doc.ext-doc-type = 'vt':U then do:
        run str/inv-prt.w (
                      parParentProc ,
                      doc-rec       ,
                      line-rec      ,
                      gds-rec       ,
                      prt-mode      ,
                      prt-tree.rid,
                       (if prt-tree.is-term then
                          'терм':U
                        else
                          'корн':U)) no-error.
      end.
      else do:
        message "Работа с признаками запрещена при работе с документом, имеющим расширенный тип: " ub.trn-doc.ext-doc-type "."
        view-as alert-box.
        return no-apply.
      end.
    end.
  end.
  if not error-status:error then do:
    run clc-nd (buffer prt-tree).
    disp  prt-tree.doc-amnt
          prt-tree.bc
          with browse br-gds-prt.
    find first prt-tree.
     run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
    run ui-on.
  end.
END.
ON CHOOSE OF b-codes IN FRAME d-gds-prt do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  prt-rec = prt-tree.rid.
  run ref/alt-bc.w (
                input parParentProc
              , input store-type
              , input store-code
              , input prt-tree.bc).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
ON CHOOSE OF menu-item m-alt-current do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/alt-cds.w ( input parParentProc
                     ,input store-type
                     ,input store-code
                     ,input "code-current"
                     ,input ub.goods.gds-code
                     ,input prt-tree.bc
                     ,output rec-list).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
ON CHOOSE OF menu-item m-alt-all do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/alt-cds.w ( input parParentProc
                     ,input store-type
                     ,input store-code
                     ,input "code-all"
                     ,input ub.goods.gds-code
                     ,input prt-tree.bc
                     ,output rec-list).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
ON CHOOSE OF menu-item m-prod-all do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/prod-cds.w (parParentProc, store-type, store-code,
                  "code-all", ub.goods.gds-code, prt-tree.bc, output rec-list).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
ON CHOOSE OF menu-item m-inf-prt
do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_archive':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if g#log then
    run ref/prt_inf.w (buffer ub.goods,
                   input prt-tree.n-code,
                   input store-type,
                   input store-code).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
ON CHOOSE OF menu-item m-inf-gds do:
   run local-gds_inf.
END.
ON CHOOSE OF b-rest IN FRAME d-gds-prt do:
  prt-rec = prt-tree.rid.
    run rep/gds-objs.w (parparentproc, ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, g#host-code, prt-tree.n-code).
  apply "entry" to br-gds-prt in frame d-gds-prt.
END.
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED THEN
  CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-gds-prt
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
on choose of b-help in frame d-gds-prt
do:
  apply "help":u to frame d-gds-prt .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-gds-prt:width - 0.3
                fh            = frame d-gds-prt:first-child
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
ON WINDOW-CLOSE OF FRAME d-gds-prt APPLY "END-ERROR":U TO SELF.
find ub.goods no-lock where
     recid (ub.goods) = gds-rec.
find ub.gds-prt no-lock where
     ub.gds-prt.upper-code = ub.goods.prt-root.
find ub.trn-doc no-lock where
     recid (ub.trn-doc) = doc-rec.
find ub.doc-line no-lock where
     recid (ub.doc-line) = line-rec.
assign
store-type = ub.trn-doc.obj-type
store-code = ub.trn-doc.obj-code
.
g#log = session:set-wait-state ("COMPILER") .
ENABLE br-gds-prt
       b-exit
       b-help
       b-rest
       b-del
       b-exp-nd
       b-exp-tree with FRAME d-gds-prt.
run cre-nd (buffer  ub.gds-prt, buffer prt-tree, 0).
find first prt-tree.
run exp-nd (yes).
FRAME d-gds-prt:title =
  ub.goods.artic + " " + ub.goods.gds-name + "  -  " + prt-mode.
ENABLE b-sel when prt-mode = 'выбор':U
       b-info
       b-codes b-alt b-amnt
       with FRAME d-gds-prt.
ENABLE flt-amnt with FRAME d-gds-prt.
find first prt-tree.
 run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
run ui-on.
g#log = session:set-wait-state ( "" ) .
do on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME d-gds-prt.
end.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME d-gds-prt.
END PROCEDURE.
PROCEDURE UI-on :
find  ub.prt-obj where  ub.prt-obj.prt-code  =  ub.gds-prt.node-code
               and  ub.prt-obj.prod-code = ub.goods.prod-code
               and  ub.prt-obj.prod-type = ub.goods.prod-type
               and  ub.prt-obj.artic     = ub.goods.artic
               and  ub.prt-obj.obj-code  = store-code
               and  ub.prt-obj.obj-type  = store-type
               no-lock no-error.
find ub.doc-line where recid (ub.doc-line) = line-rec no-lock.
old_qnty = ub.doc-line.doc-qnty - ub.doc-line.fact-qnty.
if old_qnty = ? then
  if available  ub.prt-obj then
    old_qnty =  ub.prt-obj.fact-qnty.
  else
    old_qnty = 0.
disp ub.goods.unit-base ub.doc-line.doc-qnty
    with frame d-gds-prt.
if input frame d-gds-prt flt-amnt then
  OPEN QUERY br-gds-prt
    FOR EACH  prt-tree where
              prt-tree.visible = yes and
              (prt-tree.is-term = no or
              prt-tree.doc-amnt <> 0 or
              prt-tree.fac-amnt <> 0
              ) no-lock.
else
OPEN QUERY  br-gds-prt
  FOR EACH  prt-tree where
            prt-tree.visible = yes no-lock.
reposition br-gds-prt to row gds-prt-row no-error.
apply "ENTRY":U to br-gds-prt in frame d-gds-prt.
END PROCEDURE.
PROCEDURE calc-tree:
def output param doc-accum like ub.gds-dtl.doc-qnty  no-undo.
def output param fac-accum like ub.gds-dtl.fact-qnty no-undo.
def buffer b-gds-dtl for ub.gds-dtl.
for each b-gds-dtl no-lock where
         b-gds-dtl.doc-code  = ub.doc-line.doc-code and
         b-gds-dtl.artic     = ub.doc-line.artic and
         b-gds-dtl.prod-type = ub.doc-line.prod-type and
         b-gds-dtl.prod-code = ub.doc-line.prod-code:
  accumulate b-gds-dtl.doc-qnty  (total)
             b-gds-dtl.fact-qnty (total)
             .
end.
assign
  doc-accum  = (accum total b-gds-dtl.doc-qnty)
  fac-accum  = (accum total b-gds-dtl.fact-qnty)
  .
END PROCEDURE.
PROCEDURE exp-nd :
def input param make-visible as logical no-undo.
define variable nd-level as integer no-undo.
def buffer b-prt-tree for prt-tree.
if prt-tree.exp then do:
  nd-level = prt-tree.level.
  find b-prt-tree where
       recid (b-prt-tree) = recid (prt-tree).
  inverse:
  do while true:
    find next b-prt-tree no-error.
    if not available b-prt-tree then
      leave inverse.
    if b-prt-tree.level > nd-level then do:
      if make-visible = ? then
        make-visible = not (b-prt-tree.visible).
      if not make-visible or
         b-prt-tree.level - nd-level = 1 then do:
        b-prt-tree.visible = make-visible.
        if not b-prt-tree.is-term then
          b-prt-tree.mark = "»".
      end.
    end.
    else
      leave inverse.
  end.
end.
else do:
  prt-tree.exp = yes.
  run cre-level (recid (prt-tree), prt-tree.level + 1).
  make-visible = yes.
end.
if not prt-tree.is-term then
  if make-visible then
    prt-tree.mark = " ".
  else
    prt-tree.mark = "»".
END PROCEDURE.
PROCEDURE exp-tree :
  define variable rid as recid no-undo.
  do
  on error undo, return error return-value
  :
    tree-level = prt-tree.level.
    run waitfram-show in this-procedure
      (input "Раскрывается шкала. Ждите..."
      ).
    tree:
    do while true:
      rid = recid (prt-tree).
      run exp-nd (yes).
      find prt-tree where rid = recid (prt-tree).
      find next prt-tree no-error.
      if not available prt-tree or
        prt-tree.level <= tree-level
        then
        leave tree.
    end.
    run waitfram-hide in this-procedure .
  end.
END PROCEDURE.
PROCEDURE cre-level:
def input param prt-tree-rec as recid   no-undo.
def input param cur-lev      as integer no-undo.
def buffer b-gds-prt  for  ub.gds-prt.
def buffer b-prt-tree for prt-tree.
define variable up-code like  ub.gds-prt.node-code no-undo.
find b-prt-tree where
     recid (b-prt-tree) = prt-tree-rec.
up-code = b-prt-tree.n-code.
for each b-gds-prt no-lock where
         b-gds-prt.upper-code = up-code
         by b-gds-prt.prt-num:
  run cre-nd (buffer b-gds-prt, buffer b-prt-tree, cur-lev).
end.
END PROCEDURE.
PROCEDURE cre-nd:
def param buffer b-gds-prt  for  ub.gds-prt.
def param buffer b-prt-tree for prt-tree.
def input param cur-lev as integer no-undo.
create b-prt-tree.
assign
  b-prt-tree.n-code   = b-gds-prt.node-code
  b-prt-tree.level    = cur-lev
  b-prt-tree.n-name   = b-gds-prt.node-name
  b-prt-tree.rid      = recid (b-gds-prt)
  b-prt-tree.visible  = yes
  b-prt-tree.is-term  = b-gds-prt.is-term
  b-prt-tree.is-root  = b-gds-prt.root
  .
if b-gds-prt.is-term then
  assign
    b-prt-tree.mark = " "
    b-prt-tree.exp = yes
    .
else
  assign
    b-prt-tree.mark = "»"
    b-prt-tree.exp = no
    .
run clc-nd (buffer b-prt-tree).
END PROCEDURE.
PROCEDURE clc-nd:
def param buffer b-prt-tree for prt-tree.
def buffer b-gds-prt for  ub.gds-prt.
find b-gds-prt no-lock where
     recid (b-gds-prt) = b-prt-tree.rid.
find  ub.prt-obj no-lock where
       ub.prt-obj.prt-code  = b-gds-prt.node-code and
       ub.prt-obj.obj-type  = store-type and
       ub.prt-obj.obj-code  = store-code and
       ub.prt-obj.artic     = ub.goods.artic and
       ub.prt-obj.prod-type = ub.goods.prod-type and
       ub.prt-obj.prod-code = ub.goods.prod-code no-error.
if available  ub.prt-obj then do:
  assign
    b-prt-tree.free-qnty  =  ub.prt-obj.free-qnty
    b-prt-tree.fact-qnty  =  ub.prt-obj.fact-qnty
    .
  b-prt-tree.price =  ub.prt-obj.price-sale.
end.
find  ub.gds-dtl no-lock where
      ub.gds-dtl.artic = ub.doc-line.artic and
      ub.gds-dtl.prod-code = ub.doc-line.prod-code and
      ub.gds-dtl.prod-type = ub.doc-line.prod-type and
      ub.gds-dtl.doc-code = ub.doc-line.doc-code and
      ub.gds-dtl.prt-code = b-gds-prt.node-code no-error.
if available  ub.gds-dtl then
  assign
    b-prt-tree.doc-amnt =  ub.gds-dtl.doc-qnty
    b-prt-tree.fac-amnt =  ub.gds-dtl.fact-qnty
    .
else
  assign
    b-prt-tree.fac-amnt = 0
    b-prt-tree.doc-amnt = 0
    .
find  ub.bar-code no-lock where
      ub.bar-code.gds-code  = ub.goods.gds-code and
      ub.bar-code.node-code = b-gds-prt.node-code and
      ub.bar-code.part-code = "" and
      ub.bar-code.in-code   = "" and
      ub.bar-code.unit-cli  = ub.goods.unit-base no-error.
if available ub.bar-code then
  b-prt-tree.bc = ub.bar-code.b-code.
else
  b-prt-tree.bc = ?.
END PROCEDURE.
PROCEDURE cre-code:
define variable is-new as log no-undo.
def buffer buf_bar-code for ub.bar-code.
  if not prt-tree.is-term and
     not prt-tree.is-root then do:
    message
      "Узел промежуточный. Работа с кодами запрещена."
      view-as alert-box error.
    return error.
  end.
  if prt-tree.bc = ? then do:
    g#log = no.
    message "Основной код для данного признака отсутствует. Создать код?"
            view-as alert-box question buttons YES-NO update g#log.
    if not g#log then
      return error.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_main-barcode_preparation':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if not g#log then do:
      return error.
    END.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  ub.goods.gds-code
  ,input  prt-tree.n-code
  ,input  ''
  ,input  ''
  ,input  ub.goods.unit-base
  ,input  1
  ,output is-new
  ,buffer buf_bar-code
  ) no-error .
    if error-status :error then do:
      message
        "Ошибка поиска / создания основного кода." skip
        "Код товара:"        ub.goods.gds-code skip
        "Код признака:"      prt-tree.n-code skip
        "Единица измерения:" ub.goods.unit-base skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      return error.
    end.
    prt-tree.bc = buf_bar-code.b-code.
    disp prt-tree.bc with browse br-gds-prt.
  end.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure local-gds_inf :
  for each tt-goods
  :
    delete tt-goods.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  create tt-goods.
  buffer-copy ub.goods to tt-goods.
  create tt-clients.
  assign
    tt-clients.obj-type = store-type
    tt-clients.obj-code = store-code
  .
  define variable v-ok as logical   no-undo .
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-clients.obj-type
  ,input  tt-clients.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_archive':U
    ,input  'firm':U
    ,input  v-chk-act-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok then do:
    run arc/gds_inf.w (parparentproc, tt-clients.obj-type, tt-clients.obj-code).
  end.
end procedure.
