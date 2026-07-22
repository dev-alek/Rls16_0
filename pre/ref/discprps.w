DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-propf FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_ FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_host FOR ub.dis-card-property.
DEFINE BUFFER X_dis-prop_obj FOR ub.dis-card-property.
DEFINE BUFFER X_prop-map_ FOR ub.prop-map.
DEFINE BUFFER X_prop-map_host FOR ub.prop-map.
DEFINE BUFFER X_prop-map_obj FOR ub.prop-map.
DEFINE BUFFER X_prop-ref_ FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_host FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_obj FOR ub.prop-ref.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-curr-host-code as integer no-undo .
define input parameter p-curr-obj-type as character no-undo .
define input parameter p-curr-obj-code as integer no-undo .
define input parameter p-list-mode as character no-undo .
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define input parameter p-dtm-code as integer no-undo .
define input parameter p-dt-code as integer no-undo .
define input-output parameter p-rid-list as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список dis-card-property".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Свойства ДК" .
define variable filter-point0 as character no-undo init "discprps" .
define variable filter-point as character no-undo init "discprps" .
define variable v-list-mode as character no-undo .
define variable v-short-mode as logical no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
DEFINE VARIABLE v-ch_ AS WIDGET-HANDLE NO-UNDO EXTENT 5.
DEFINE VARIABLE v-ch_host AS WIDGET-HANDLE NO-UNDO EXTENT 5.
DEFINE VARIABLE v-ch_obj AS WIDGET-HANDLE NO-UNDO EXTENT 5.
FUNCTION display-character RETURNS CHARACTER
  (  INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER)  FORWARD.
DEFINE BUTTON b-card
     LABEL "Карта"
     SIZE 10 BY 1.
DEFINE BUTTON b-dt-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.
DEFINE BUTTON b-dtm-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE BUTTON b-node-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE VARIABLE f-dt-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код среза"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-dtm-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код объекта"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-dtm-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-node-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код св-ва"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-node-label AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 31.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE rs-region AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты", "1",
"Фирмы", "2",
"Глобально", "3"
     SIZE 30 BY 1 NO-UNDO.
DEFINE QUERY br-dis-prop_ FOR
                X_dis-prop_,
                X_prop-ref_,
                X_prop-map_ SCROLLING.
DEFINE QUERY br-dis-prop_host FOR
                X_dis-prop_host,
                X_prop-ref_host,
                X_prop-map_host SCROLLING.
DEFINE QUERY br-dis-prop_obj FOR
                X_dis-prop_obj,
                X_prop-ref_obj,
                X_prop-map_obj SCROLLING.
DEFINE BROWSE br-dis-prop_
  QUERY br-dis-prop_ NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_prop-map_.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_.node-value-type) = 'character':U
THEN display-character(X_dis-prop_.property-value-character, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(строковое)" format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_.node-value-type) = 'date':U
THEN STRING(X_dis-prop_.property-value-date,  X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Дата)" format "X(10)"
(IF entry(1, X_prop-map_.node-value-type) = 'decimal':U
THEN STRING(X_dis-prop_.property-value-decimal, X_prop-map_.node-format)
ELSE '':U)  COLUMN-LABEL "Значение!(Десятичное)" format "X(24)"
(IF entry(1, X_prop-map_.node-value-type) = 'integer':U
THEN STRING(X_dis-prop_.property-value-integer, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Целое)" format "X(14)"
(IF entry(1, X_prop-map_.node-value-type) = 'logical':U
THEN STRING(X_dis-prop_.property-value-logical, X_prop-map_.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Логическое)" FORMAT "X(2)"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.
DEFINE BROWSE br-dis-prop_host
  QUERY br-dis-prop_host NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_host), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_prop-map_host.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_host.node-value-type) = 'character':U
THEN display-character(X_dis-prop_host.property-value-character, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(строковое)" format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_host.node-value-type) = 'date':U
THEN STRING(X_dis-prop_host.property-value-date,  X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Дата)" format "X(10)"
(IF entry(1, X_prop-map_host.node-value-type) = 'decimal':U
THEN STRING(X_dis-prop_host.property-value-decimal, X_prop-map_host.node-format)
ELSE '':U)  COLUMN-LABEL "Значение!(Десятичное)" format "X(24)"
(IF entry(1, X_prop-map_host.node-value-type) = 'integer':U
THEN STRING(X_dis-prop_host.property-value-integer, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Целое)" format "X(14)"
(IF entry(1, X_prop-map_host.node-value-type) = 'logical':U
THEN STRING(X_dis-prop_host.property-value-logical, X_prop-map_host.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Логическое)" FORMAT "X(2)"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.
DEFINE BROWSE br-dis-prop_obj
  QUERY br-dis-prop_obj NO-LOCK DISPLAY
      mark-string(recid(X_dis-prop_obj), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-prop_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_prop-map_obj.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
(IF entry(1, X_prop-map_obj.node-value-type) = 'character':U
THEN display-character(X_dis-prop_obj.property-value-character, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(строковое)" format "X(255)" WIDTH 40
(IF entry(1, X_prop-map_obj.node-value-type) = 'date':U
THEN STRING(X_dis-prop_obj.property-value-date,  X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Дата)" format "X(10)"
(IF entry(1, X_prop-map_obj.node-value-type) = 'decimal':U
THEN STRING(X_dis-prop_obj.property-value-decimal, X_prop-map_obj.node-format)
ELSE '':U)  COLUMN-LABEL "Значение!(Десятичное)" format "X(24)"
(IF entry(1, X_prop-map_obj.node-value-type) = 'integer':U
THEN STRING(X_dis-prop_obj.property-value-integer, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Целое)" format "X(14)"
(IF entry(1, X_prop-map_obj.node-value-type) = 'logical':U
THEN STRING(X_dis-prop_obj.property-value-logical, X_prop-map_obj.node-format)
ELSE '':U) COLUMN-LABEL "Значение!(Логическое)" FORMAT "X(2)"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.87
         FONT 4 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 12
     b-sel AT ROW 1 COL 25 WIDGET-ID 10
     rs-region AT ROW 1 COL 35 NO-LABEL WIDGET-ID 26
     b-lkp AT ROW 1 COL 66 WIDGET-ID 6
     b-card AT ROW 1 COL 76 WIDGET-ID 16
     b-sch AT ROW 1 COL 86 WIDGET-ID 2
     B-print AT ROW 1 COL 89 WIDGET-ID 20
     b-history AT ROW 1 COL 92 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     f-dtm-code AT ROW 2 COL 1 WIDGET-ID 34
     b-dtm-code AT ROW 2 COL 22.5 WIDGET-ID 32
     f-dtm-name AT ROW 2 COL 25.5 NO-LABEL WIDGET-ID 30
     f-dt-code AT ROW 3 COL 3 WIDGET-ID 36
     b-dt-code AT ROW 3 COL 22.5 WIDGET-ID 38
     f-sum-id AT ROW 3 COL 25.5 NO-LABEL WIDGET-ID 40
     f-node-code AT ROW 4 COL 3 WIDGET-ID 44
     b-node-code AT ROW 4 COL 22.5 WIDGET-ID 42
     f-node-label AT ROW 4 COL 25.5 NO-LABEL WIDGET-ID 46
     br-dis-prop_obj AT ROW 5 COL 1.5 WIDGET-ID 100
     br-dis-prop_host AT ROW 5 COL 1.5 WIDGET-ID 200
     br-dis-prop_ AT ROW 5 COL 1.5 WIDGET-ID 300
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(78.50) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-card IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
  WHEN 'объект':U THEN DO:
    IF NOT AVAILABLE X_dis-prop_obj THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_obj.d-card.
  END.
  WHEN 'фирма':U THEN DO:
    IF NOT AVAILABLE X_dis-prop_host THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_host.d-card.
  END.
  WHEN "global" THEN DO:
    IF NOT AVAILABLE X_dis-prop_ THEN RETURN NO-APPLY.
    v-d-card = X_dis-prop_.d-card.
  END.
END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  run ref/dcardi.w (
                input parparentproc
              , input 'ПРОСМОТР':U
              , input buf_dis-card.emitent-host-code
              , input p-curr-host-code
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input ?
              , input-output v-ri ) .
END.
END.
ON CHOOSE OF b-dt-code IN FRAME Dialog-Frame
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input (if f-dtm-code = ?
                      then 'dis-card-property':U
                      else "dtm-code")
              ,input (if f-dtm-code = ? then 0 else f-dtm-code)
              ,input '':U
              ,input '':U
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  v-list-mode = p-list-mode.
  assign
  f-dt-code = ?
  f-sum-id = '':U.
  DISPLAY
  f-sum-id
  f-dt-code
  WITH FRAME Dialog-Frame.
  run openbr in this-procedure ( input yes, input no, input '':U).
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
if buf_prop-ref.dt-code = f-dt-code then return no-apply.
ASSIGN
f-dt-code = buf_prop-ref.dt-code
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
f-dt-code
WITH FRAME Dialog-Frame.
if f-node-code = ? then do:
  v-list-mode ="dt-code".
end.
else do:
  v-list-mode ="dt-node-code".
end.
run openbr in this-procedure ( input yes, input no, input '':U).
END.
ON CHOOSE OF b-dtm-code IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
 run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,input "general-view"
                         ,input 'dc-prop':U
                         ,input-output v-rid-list ) NO-ERROR.
 IF ERROR-STATUS:error OR v-rid-list = '':U THEN DO:
    UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_prop-head NO-LOCK WHERE
           recid(buf_prop-head) = INTEGER(v-rid-list) NO-ERROR.
 IF NOT AVAILABLE buf_prop-head  THEN DO:
    assign
    f-dt-code = ?
    f-sum-id = '':U
    f-dtm-code = ?
    f-dtm-name = '':U
    f-node-code = ?
    f-node-label = '':U
    .
    DISABLE
    b-node-code
    WITH FRAME Dialog-Frame.
    DISPLAY
    f-sum-id
    f-dtm-code
    f-dtm-name
    f-dt-code
    f-node-code
    f-node-label
    WITH FRAME Dialog-Frame.
   v-list-mode = p-list-mode.
   run openbr in this-procedure ( input yes, input no, input '':U).
   RETURN.
 END.
 if buf_prop-head.dtm-code = f-dtm-code then return no-apply.
 assign
 f-dtm-code = buf_prop-head.dtm-code
 f-dtm-name = buf_prop-head.prop-label
 .
 display
 f-dtm-code
 f-dtm-name
 with frame Dialog-Frame .
 ENABLE
 b-node-code
 WITH FRAME Dialog-Frame.
 v-list-mode = "dtm-code".
 run openbr in this-procedure ( input yes, input no, input '':U).
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
define variable parref-list as character no-undo .
CASE rs-region:
  when 'объект':U then do:
    if available X_dis-prop_obj  then do:
      run ref/cdchist.w (
                        INPUT parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input "":U
                        ,input "subject":U
                        ,input X_dis-prop_obj.d-card
                        ,input ?
                        ,input X_dis-prop_obj.obj-type
                        ,input X_dis-prop_obj.obj-code
                        ,input X_dis-prop_obj.host-code
                        ,input ?
                        ,input "":U
                        ,input 'dis-card-property':U
                        ,input ?
                        ,input-output parref-list
                    ) no-error .
        apply "entry" to br-dis-prop_obj.
     end.
   end.
   when 'фирма':U then do:
     if available X_dis-prop_host then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-prop_host.d-card
                          ,input ?
                          ,input '':U
                          ,input 0
                          ,input X_dis-prop_host.host-code
                          ,input ?
                          ,input "":U
                          ,input 'dis-card-property':U
                          ,input ?
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-prop_host.
      end.
    end.
    when "global" then do:
     if available X_dis-prop_ then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-prop_.d-card
                          ,input ?
                          ,input '':U
                          ,input 0
                          ,input 0
                          ,input ?
                          ,input "":U
                          ,input 'dis-card-property':U
                          ,input ?
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-prop_host.
      end.
    END.
  END CASE.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable v-rec as recid no-undo.
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define variable v-update-attr as logical no-undo .
define variable v-is-error as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
    WHEN 'объект':U THEN DO:
      IF NOT AVAILABLE X_dis-prop_obj THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_obj.d-card.
    END.
    WHEN 'фирма':U THEN DO:
      IF NOT AVAILABLE X_dis-prop_host THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_host.d-card.
    END.
    WHEN "global" THEN DO:
      IF NOT AVAILABLE X_dis-prop_ THEN RETURN NO-APPLY.
      v-d-card = X_dis-prop_.d-card.
    END.
 END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  if buf_dis-card.emitent-host-code = p-curr-host-code
  or buf_dis-card.emitent-host-code = 0 then do:
      run ref/dc-propr.p ( input parparentproc
                    ,input 'ПРОСМОТР':U
                    ,input buf_dis-card.d-card
                    ,input buf_dis-card.emitent-host-code
                    ,input buf_dis-card.type
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input no
                    ,output v-update-attr
                    ,output v-is-error
                    ) no-error .
  end.
  else do:
      message "Данная дисконтная карта принадлежит другой фирме - просмотр запрещен!"
      view-as alert-box ERROR.
  end.
end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
    define variable glog as logical no-undo .
  if available X_dis-prop_obj then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid13 as character no-undo .
define variable v-num-entry13 as integer   no-undo .
assign
  v-str-recid13 = trim( string( recid( X_dis-prop_obj ) , "->>>>>>>>>>>9":U ) )
  v-num-entry13 = lookup( v-str-recid13 , v-rid-list )
.
if v-num-entry13 > 0 then do:
  assign
    entry( v-num-entry13, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid13
  .
end.
  glog = br-dis-prop_obj:refresh() .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-dis-prop_obj:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-prop_obj in frame Dialog-Frame.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame Dialog-Frame.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
end.
apply "entry" to br-dis-prop_obj in frame Dialog-Frame.
END.
ON CHOOSE OF b-node-code IN FRAME Dialog-Frame
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
IF f-dtm-code = ?
OR f-dtm-code = 0  THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.
run rul/prop-map-s.w (
                input parparentproc
              ,input 'b-sel'
              ,input "dtm-code"
              ,input f-dtm-code
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  v-list-mode = p-list-mode.
  assign
  f-node-code = ?
  f-node-label = '':U.
  DISPLAY
  f-node-code
  f-node-label
  WITH FRAME Dialog-Frame.
  run openbr in this-procedure ( input yes, input no, input '':U).
  return.
end.
find first buf_prop-map no-lock where
          recid(buf_prop-map) = integer(v-ref-list) no-error.
if not available buf_prop-map then return.
if buf_prop-map.dtm-code = f-dtm-code
AND buf_prop-map.node-code = f-node-code then return no-apply.
ASSIGN
f-node-code = buf_prop-map.node-code
f-node-label = buf_prop-map.node-label.
DISPLAY
f-node-code
f-node-label
WITH FRAME Dialog-Frame.
IF f-dt-code = ?
THEN DO:
  v-list-mode ="node-code".
END.
ELSE DO:
  v-list-mode ="dt-node-code".
END.
run openbr in this-procedure ( input yes, input no, input '':U).
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
 CASE rs-region:
     WHEN 'объект':U THEN DO:
      v-doc-rec = recid( X_dis-prop_obj ).
      DO WHILE available X_dis-prop_obj :
        GET prev br-dis-prop_obj.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_obj to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_obj in frame Dialog-Frame.
   END.
   WHEN 'фирма':U THEN DO:
      v-doc-rec = recid( X_dis-prop_host ).
      DO WHILE available X_dis-prop_host :
          GET prev br-dis-prop_host.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_host to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_host in frame Dialog-Frame.
  END.
  WHEN "global" THEN DO:
      v-doc-rec = recid( X_dis-prop_ ).
      DO WHILE available X_dis-prop_ :
          GET prev br-dis-prop_.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-prop_ to recid v-doc-rec no-error.
      apply "entry" to br-dis-prop_ in frame Dialog-Frame.
  END.
 END CASE.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE (INPUT rs-region) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if available X_dis-prop_obj then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_dis-prop_obj ) ) .
  end.
END.
ON VALUE-CHANGED OF rs-region IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-region.
  v-list-mode = p-list-mode.
  RUN Openbr IN THIS-PROCEDURE ( input YES, INPUT NO, INPUT '':U).
END.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_dis-prop_obj).    RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-dis-prop_obj to recid v-doc-rec No-ERROR.   apply 'value-changed' to br-dis-prop_obj.
    apply "VALUE-CHANGED" to br-dis-prop_.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-dis-prop_ :handle
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
ON ROW-DISPLAY OF br-dis-prop_ IN frame Dialog-Frame
DO:
  IF AVAIL X_dis-prop_ THEN DO:
    RUN set-row-color_ IN THIS-PROCEDURE ( INPUT X_prop-map_.node-value-type).
  END.
END.
ON ROW-DISPLAY OF br-dis-prop_host IN frame Dialog-Frame
DO:
  IF AVAIL X_dis-prop_host THEN DO:
    RUN set-row-color_host IN THIS-PROCEDURE ( INPUT X_prop-map_host.node-value-type).
  END.
END.
ON ROW-DISPLAY OF br-dis-prop_obj IN frame Dialog-Frame
DO:
  IF AVAIL X_dis-prop_obj THEN DO:
    RUN set-row-color_obj IN THIS-PROCEDURE ( INPUT X_prop-map_obj.node-value-type).
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(p-list-mode, 'все':U + chr(44) + "dtm-code" + chr(44) + "dt-code") = 0  THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description SKIP
    "Неверное значение параметра p-list-mode" p-list-mode
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
  if lookup(p-region, 'объект':U + chr(44) + 'фирма':U + chr(44) + "global")  = 0 then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-region" p-region SKIP
        "Нет хранилища данных"  p-region
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
  end.
  IF p-list-mode = "dtm-code" THEN DO:
    FIND FIRST buf_prop-head NO-LOCK WHERE
              buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-head THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dtm-code" p-dtm-code SKIP
        "Нет объекта-операнда c кодом"  p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
  END.
  IF p-list-mode = "dt-code"
  OR (p-list-mode = "dtm-code" AND p-dt-code > 0) THEN DO:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dt-code = p-dt-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-ref THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Нет среза c кодом"  p-dt-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
    IF p-list-mode = "dtm-code"
    AND p-dtm-code <> buf_prop-ref.dtm-code THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        substitute("Код среза &1 соответствует  коду объекта &2, хотя p-dtm-code = &3"
                   , p-dt-code
                   , buf_prop-ref.dtm-code
                   , p-dtm-code)
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
    FIND FIRST buf_prop-head NO-LOCK WHERE
              buf_prop-head.dtm-code = buf_prop-ref.dtm-code NO-ERROR.
  END.
  v-list-mode = p-list-mode.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-region f-dtm-code f-dtm-name f-dt-code f-sum-id f-node-code
          f-node-label mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel rs-region b-lkp b-card b-sch B-print b-history
         B-Help b-dtm-code b-dt-code br-dis-prop_obj br-dis-prop_host
         br-dis-prop_ mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOCK,            FIRST X_prop-ref_ NO-LOCK WHERE          X_prop-ref_.dt-code = X_dis-prop_.dt-code,            FIRST X_prop-map_  WHERE          X_prop-map_.dtm-code = X_dis-prop_.dtm-code     AND X_prop-map_.node-code = X_dis-prop_.node-code INDEXED-REPOSITION.    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOCK,            FIRST X_prop-ref_host NO-LOCK WHERE          X_prop-ref_host.dt-code = X_dis-prop_host.dt-code ,            FIRST X_prop-map_host WHERE          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code     AND X_prop-map_host.node-code = X_dis-prop_host.node-code INDEXED-REPOSITION.    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOCK,            FIRST X_prop-ref_obj NO-LOCK WHERE          X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code ,            FIRST X_prop-map_obj  WHERE           X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code       AND X_prop-map_obj.node-code = X_dis-prop_obj.node-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
if p-list-mode =  "dtm-code"
or p-list-mode = "dt-code"
or p-list-mode = "dt-node-code"
or p-list-mode = "node-code" then do:
  assign
  X_prop-ref_.dtm-code:visible in browse br-dis-prop_ = no
  X_prop-ref_host.dtm-code:visible in browse br-dis-prop_host = no
  X_prop-ref_obj.dtm-code:visible in browse br-dis-prop_obj = no
  .
end.
ASSIGN
v-ch0 = br-dis-prop_:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN
   v-ch_[1] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN
   v-ch_[2] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN
   v-ch_[3] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN
   v-ch_[4] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN
   v-ch_[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
v-ch0 = br-dis-prop_host:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN
   v-ch_host[1] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN
   v-ch_host[2] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN
   v-ch_host[3] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN
   v-ch_host[4] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN
   v-ch_host[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
v-ch0 = br-dis-prop_obj:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN
   v-ch_obj[1] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN
   v-ch_obj[2] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN
   v-ch_obj[3] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN
   v-ch_obj[4] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN
   v-ch_obj[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
rs-region:RADIO-BUTTONS IN FRAME Dialog-Frame  = "Объекты" + chr(44) + 'объект':U + chr(44) +
                        "Фирмы" + chr(44) + 'фирма':U + chr(44) +
                        "Глобально" + chr(44) + "global"
rs-region = (IF p-region = '':U
             THEN 'объект':U
             ELSE p-region)
.
if p-list-mode = "dtm-code"
or p-list-mode = "dt-code"
then do:
  assign
  f-dtm-code  = buf_prop-head.dtm-code
  f-dtm-name  = buf_prop-head.prop-label
  .
end.
else do:
  f-dtm-code = ?.
end.
if p-list-mode = "dt-code"
or (p-list-mode = "dtm-code" and p-dt-code > 0)
then do:
  assign
  f-dt-code  = buf_prop-ref.dtm-code
  f-sum-id   = buf_prop-ref.sum-id
  .
end.
else do:
  f-dt-code = ?.
end.
f-node-code = ?.
display
f-dtm-code
f-dtm-name
f-dt-code
f-sum-id
with frame Dialog-Frame .
ENABLE
rs-region
b-quit
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-card
b-sch
b-print
b-history
b-dtm-code WHEN (p-list-mode <> "dtm-code")
b-dt-code WHEN (p-list-mode <> "dt-code"
                AND NOT (p-list-mode = "dtm-code" AND p-dt-code > 0)
                and NOT (p-list-mode = "dtm-code" AND p-dtm-code = 1)
                )
b-node-code WHEN (f-dtm-code <> 0 AND f-dtm-code <> ?)
br-dis-prop_obj
br-dis-prop_host
br-dis-prop_
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if available buf_prop-head then do:
  if buf_prop-head.storage-place = '':U
  or buf_prop-head.storage-place = chr(63)
  or buf_prop-head.storage-place = ? then do:
    rs-region:disable(radio-label("global", rs-region:radio-buttons)).
  end.
  if buf_prop-head.storage-place-host = '':U
  or buf_prop-head.storage-place-host = chr(63)
  or buf_prop-head.storage-place-host = ? then do:
    rs-region:disable(radio-label('фирма':U, rs-region:radio-buttons)).
  end.
  if buf_prop-head.storage-place-obj = '':U
  or buf_prop-head.storage-place-obj = chr(63)
  or buf_prop-head.storage-place-obj = ? then do:
    rs-region:disable(radio-label('объект':U, rs-region:radio-buttons)).
  end.
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable v-datatype as logical no-undo extent 5.
define buffer buf_prop-map for ub.prop-map.
CASE rs-region:
  WHEN 'объект':U THEN DO:
    RUN Openbr_obj ( INPUT p-open-query
                    ,INPUT p-find-next
                    ,INPUT p-find-condition).
    br-dis-prop_obj:move-to-top() in frame Dialog-Frame .
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = 'character':U then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'date':U then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'decimal':U then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'integer':U then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'logical':U then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_obj[1]:visible = v-datatype[1]
      v-ch_obj[2]:visible = v-datatype[2]
      v-ch_obj[3]:visible = v-datatype[3]
      v-ch_obj[4]:visible = v-datatype[4]
      v-ch_obj[5]:visible = v-datatype[5]
      .
    end.
    else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .
    end.
    apply "ENTRY" to br-dis-prop_obj.
    apply "VALUE-CHANGED" to br-dis-prop_obj.
  END.
  WHEN 'фирма':U THEN DO:
    RUN Openbr_host ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
    br-dis-prop_host:move-to-top().
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = 'character':U then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'date':U then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'decimal':U then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'integer':U then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'logical':U then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_host[1]:visible = v-datatype[1]
      v-ch_host[2]:visible = v-datatype[2]
      v-ch_host[3]:visible = v-datatype[3]
      v-ch_host[4]:visible = v-datatype[4]
      v-ch_host[5]:visible = v-datatype[5]
      .
    end.
    else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .
    end.
    apply "ENTRY" to br-dis-prop_host.
    apply "VALUE-CHANGED" to br-dis-prop_host.
  END.
  WHEN "global" THEN DO:
    RUN Openbr_ ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
    br-dis-prop_:move-to-top().
    if f-dtm-code > 0 then do:
      for each buf_prop-map no-lock where
              buf_prop-map.dtm-code = f-dtm-code:
        if entry(1, buf_prop-map.node-value-type) = 'character':U then do:
          v-datatype[1] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'date':U then do:
          v-datatype[2] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'decimal':U then do:
          v-datatype[3] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'integer':U then do:
          v-datatype[4] = yes.
        end.
        if entry(1, buf_prop-map.node-value-type) = 'logical':U then do:
          v-datatype[5] = yes.
        end.
      end.
      assign
      v-ch_[1]:visible = v-datatype[1]
      v-ch_[2]:visible = v-datatype[2]
      v-ch_[3]:visible = v-datatype[3]
      v-ch_[4]:visible = v-datatype[4]
      v-ch_[5]:visible = v-datatype[5]
      .
     end.
     else do:
      assign
      v-ch_obj[1]:visible = yes
      v-ch_obj[2]:visible = yes
      v-ch_obj[3]:visible = yes
      v-ch_obj[4]:visible = yes
      v-ch_obj[5]:visible = yes
      .
    end.
    apply "ENTRY" to br-dis-prop_.
    apply "VALUE-CHANGED" to br-dis-prop_.
  END.
END CASE.
END PROCEDURE.
PROCEDURE Openbr_ :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + v-list-mode.
CASE v-list-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по фирмам")
    frame Dialog-Frame:title = filter-point-label
    .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-22  as logical   no-undo .
define variable  l-filter-open-22    as logical   .
define variable  flt-rec-22       as recid     no-undo .
define variable  filter-name-22      as character no-undo .
define variable  where-phrase-22     as character no-undo .
define variable  sort-phrase-22      as character no-undo .
define variable  where-phrase-rus-22 as character no-undo .
define variable  sort-phrase-rus-22  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-22
  ,output filter-name-22
  ,output where-phrase-22
  ,output sort-phrase-22
  ,output where-phrase-rus-22
  ,output sort-phrase-rus-22
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-22
      ) no-error .
  assign
    l-filter-open-22 = false
  .
  if flt-rec-22 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-22 as character no-undo .
    define variable  parameter-3-22 as character no-undo .
    define variable  parameter-4-22 as character no-undo .
    define variable  parameter-5-22 as character no-undo .
    define variable  parameter-6-22 as character no-undo .
    define variable  parameter-7-22 as character no-undo .
      assign
      parameter-3-22 =
                              "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-22 =
        (
          if (" X_dis-prop_.host-code = 0 " + " " + where-phrase-22) <> ""
          then " X_dis-prop_.host-code = 0 " + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", FIRST X_prop-ref_ NO-LOCK WHERE X_prop-ref_.dt-code = X_dis-prop_.dt-code                                     , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code and                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code")
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-22
        )
      parameter-7-22 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-22 =
          (" X_dis-prop_.host-code = 0 " + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input parameter-3-22
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ,input parameter-6-22
                          ,input parameter-7-22
                          )
      .
      assign
        l-filter-open-22 = true
      .
    end.
    if l-filter-open-22 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-22 = false then do:
    OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK
      where  X_dis-prop_.host-code = 0
    , FIRST X_prop-ref_ NO-LOCK WHERE X_prop-ref_.dt-code = X_dis-prop_.dt-code                                     , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code and                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code
       by X_dis-prop_.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_ )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_:handle:get-buffer-handle(1) = (buffer X_dis-prop_:handle) then do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-4-22 =
        "where ":u + " X_dis-prop_.host-code = 0 " + " ":u + where-phrase-22 + " ":u + p-find-condition + " " + ""
      parameter-5-22 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input rowid(X_dis-prop_)
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input (buffer X_dis-prop_:handle)
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-3-22 =  "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-22 =
        (
          if (" X_dis-prop_.host-code = 0 " + " " + where-phrase-22) <> ""
          then " X_dis-prop_.host-code = 0 " + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", FIRST X_prop-ref_ NO-LOCK WHERE X_prop-ref_.dt-code = X_dis-prop_.dt-code                                     , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code and                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code" + " " + p-find-condition)
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-22
        )
      parameter-7-22 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input parameter-3-22
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ,input parameter-6-22
                          ,input parameter-7-22
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&2)"
                                         , f-dtm-code
                                         , buf_prop-head.prop-label
                                         )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-24  as logical   no-undo .
define variable  l-filter-open-24    as logical   .
define variable  flt-rec-24       as recid     no-undo .
define variable  filter-name-24      as character no-undo .
define variable  where-phrase-24     as character no-undo .
define variable  sort-phrase-24      as character no-undo .
define variable  where-phrase-rus-24 as character no-undo .
define variable  sort-phrase-rus-24  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-24
  ,output filter-name-24
  ,output where-phrase-24
  ,output sort-phrase-24
  ,output where-phrase-rus-24
  ,output sort-phrase-rus-24
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-24
      ) no-error .
  assign
    l-filter-open-24 = false
  .
  if flt-rec-24 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-24 as character no-undo .
    define variable  parameter-3-24 as character no-undo .
    define variable  parameter-4-24 as character no-undo .
    define variable  parameter-5-24 as character no-undo .
    define variable  parameter-6-24 as character no-undo .
    define variable  parameter-7-24 as character no-undo .
      assign
      parameter-3-24 =
                              "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-24 =
        (
          if (" X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = f-dtm-code" + " " + where-phrase-24) <> ""
          then  substitute('X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = &1', f-dtm-code) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + ", FIRST X_prop-ref_ NO-LOCK WHERE                                           X_prop-ref_.dt-code = X_dis-prop_.dt-code                                      , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code")
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-24
        )
      parameter-7-24 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-24 =
          (" X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = f-dtm-code" + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input parameter-3-24
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ,input parameter-6-24
                          ,input parameter-7-24
                          )
      .
      assign
        l-filter-open-24 = true
      .
    end.
    if l-filter-open-24 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-24 = false then do:
    OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK
      where  X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = f-dtm-code
    , FIRST X_prop-ref_ NO-LOCK WHERE                                           X_prop-ref_.dt-code = X_dis-prop_.dt-code                                      , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code
       by X_dis-prop_.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_ )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_:handle:get-buffer-handle(1) = (buffer X_dis-prop_:handle) then do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-4-24 =
        "where ":u +  substitute('X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = &1', f-dtm-code) + " ":u + where-phrase-24 + " ":u + p-find-condition + " " + ""
      parameter-5-24 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input rowid(X_dis-prop_)
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input (buffer X_dis-prop_:handle)
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-3-24 =  "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-24 =
        (
          if (" X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = f-dtm-code" + " " + where-phrase-24) <> ""
          then  substitute('X_dis-prop_.host-code = 0                          and X_dis-prop_.dtm-code = &1', f-dtm-code) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + ", FIRST X_prop-ref_ NO-LOCK WHERE                                           X_prop-ref_.dt-code = X_dis-prop_.dt-code                                      , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                       X_prop-map_.dtm-code = X_dis-prop_.dtm-code" + " " + p-find-condition)
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-24
        )
      parameter-7-24 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input parameter-3-24
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ,input parameter-6-24
                          ,input parameter-7-24
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-26  as logical   no-undo .
define variable  l-filter-open-26    as logical   .
define variable  flt-rec-26       as recid     no-undo .
define variable  filter-name-26      as character no-undo .
define variable  where-phrase-26     as character no-undo .
define variable  sort-phrase-26      as character no-undo .
define variable  where-phrase-rus-26 as character no-undo .
define variable  sort-phrase-rus-26  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-26
  ,output filter-name-26
  ,output where-phrase-26
  ,output sort-phrase-26
  ,output where-phrase-rus-26
  ,output sort-phrase-rus-26
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-26
      ) no-error .
  assign
    l-filter-open-26 = false
  .
  if flt-rec-26 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-26 as character no-undo .
    define variable  parameter-3-26 as character no-undo .
    define variable  parameter-4-26 as character no-undo .
    define variable  parameter-5-26 as character no-undo .
    define variable  parameter-6-26 as character no-undo .
    define variable  parameter-7-26 as character no-undo .
      assign
      parameter-3-26 =
                              "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-26 =
        (
          if ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code " + " " + where-phrase-26) <> ""
          then  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1', f-dt-code)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code")
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-26 =
          ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
                          )
      .
      assign
        l-filter-open-26 = true
      .
    end.
    if l-filter-open-26 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-26 = false then do:
    OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK
      where X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code
    , FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code
      by X_dis-prop_.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_ )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_:handle:get-buffer-handle(1) = (buffer X_dis-prop_:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1', f-dt-code)  + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input rowid(X_dis-prop_)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer X_dis-prop_:handle)
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-3-26 =  "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-26 =
        (
          if ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code " + " " + where-phrase-26) <> ""
          then  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1', f-dt-code)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2: &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-28  as logical   no-undo .
define variable  l-filter-open-28    as logical   .
define variable  flt-rec-28       as recid     no-undo .
define variable  filter-name-28      as character no-undo .
define variable  where-phrase-28     as character no-undo .
define variable  sort-phrase-28      as character no-undo .
define variable  where-phrase-rus-28 as character no-undo .
define variable  sort-phrase-rus-28  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-28
  ,output filter-name-28
  ,output where-phrase-28
  ,output sort-phrase-28
  ,output where-phrase-rus-28
  ,output sort-phrase-rus-28
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-28
      ) no-error .
  assign
    l-filter-open-28 = false
  .
  if flt-rec-28 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-28 as character no-undo .
    define variable  parameter-3-28 as character no-undo .
    define variable  parameter-4-28 as character no-undo .
    define variable  parameter-5-28 as character no-undo .
    define variable  parameter-6-28 as character no-undo .
    define variable  parameter-7-28 as character no-undo .
      assign
      parameter-3-28 =
                              "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-28 =
        (
          if ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code                             and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-28) <> ""
          then  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1                             and X_dis-prop_.node-code = &2 ', f-dt-code, f-node-code) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code")
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-28 =
          ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code                             and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
                          )
      .
      assign
        l-filter-open-28 = true
      .
    end.
    if l-filter-open-28 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-28 = false then do:
    OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK
      where X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code                             and X_dis-prop_.node-code = f-node-code
    , FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code
      by X_dis-prop_.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_ )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_:handle:get-buffer-handle(1) = (buffer X_dis-prop_:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1                             and X_dis-prop_.node-code = &2 ', f-dt-code, f-node-code) + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input rowid(X_dis-prop_)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer X_dis-prop_:handle)
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-3-28 =  "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-28 =
        (
          if ("X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = f-dt-code                             and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-28) <> ""
          then  substitute('X_dis-prop_.host-code = 0 and X_dis-prop_.dt-code = &1                             and X_dis-prop_.node-code = &2 ', f-dt-code, f-node-code) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                            X_prop-ref_.dt-code = X_dis-prop_.dt-code                                    , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                     X_prop-map_.dtm-code = X_dis-prop_.dtm-code" + " " + p-find-condition)
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "node-code" then do:
            assign
            filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&3): &2"
                                            , f-dtm-code
                                            , f-node-label
                                            , buf_prop-head.prop-label
                                            )
            frame Dialog-Frame:title = filter-point-label
            .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-30  as logical   no-undo .
define variable  l-filter-open-30    as logical   .
define variable  flt-rec-30       as recid     no-undo .
define variable  filter-name-30      as character no-undo .
define variable  where-phrase-30     as character no-undo .
define variable  sort-phrase-30      as character no-undo .
define variable  where-phrase-rus-30 as character no-undo .
define variable  sort-phrase-rus-30  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-30
  ,output filter-name-30
  ,output where-phrase-30
  ,output sort-phrase-30
  ,output where-phrase-rus-30
  ,output sort-phrase-rus-30
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-30
      ) no-error .
  assign
    l-filter-open-30 = false
  .
  if flt-rec-30 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-30 as character no-undo .
    define variable  parameter-3-30 as character no-undo .
    define variable  parameter-4-30 as character no-undo .
    define variable  parameter-5-30 as character no-undo .
    define variable  parameter-6-30 as character no-undo .
    define variable  parameter-7-30 as character no-undo .
      assign
      parameter-3-30 =
                              "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-30 =
        (
          if ("X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = f-dtm-code                       and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-30) <> ""
          then  substitute( 'X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = &1                       and X_dis-prop_.node-code = &2 ', f-dtm-code, f-node-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                                X_prop-ref_.dt-code = X_dis-prop_.dt-code                                            , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                         X_prop-map_.dtm-code = X_dis-prop_.dtm-code")
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-30 =
          ("X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = f-dtm-code                       and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          )
      .
      assign
        l-filter-open-30 = true
      .
    end.
    if l-filter-open-30 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-30 = false then do:
    OPEN QUERY br-dis-prop_ FOR EACH X_dis-prop_ NO-LOcK
      where X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = f-dtm-code                       and X_dis-prop_.node-code = f-node-code
    , FIRST X_prop-ref_ no-lock WHERE                                                X_prop-ref_.dt-code = X_dis-prop_.dt-code                                            , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                         X_prop-map_.dtm-code = X_dis-prop_.dtm-code
      by X_dis-prop_.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_ )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_:handle:get-buffer-handle(1) = (buffer X_dis-prop_:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute( 'X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = &1                       and X_dis-prop_.node-code = &2 ', f-dtm-code, f-node-code) + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input rowid(X_dis-prop_)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer X_dis-prop_:handle)
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-3-30 =  "FOR EACH X_dis-prop_ NO-LOcK"
      parameter-4-30 =
        (
          if ("X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = f-dtm-code                       and X_dis-prop_.node-code = f-node-code " + " " + where-phrase-30) <> ""
          then  substitute( 'X_dis-prop_.host-code = 0                        and X_dis-prop_.dtm-code = &1                       and X_dis-prop_.node-code = &2 ', f-dtm-code, f-node-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + ", FIRST X_prop-ref_ no-lock WHERE                                                X_prop-ref_.dt-code = X_dis-prop_.dt-code                                            , FIRST X_prop-map_ no-lock where X_prop-map_.node-code = X_dis-prop_.node-code AND                                                                         X_prop-map_.dtm-code = X_dis-prop_.dtm-code" + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "by X_dis-prop_.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_:handle
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
END CASE.
if not p-open-query then
REPOSITION br-dis-prop_ to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_.
APPLY "VALUE-CHANGED" TO br-dis-prop_ in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr_host :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + v-list-mode + "_host".
CASE v-list-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по фирмам")
    frame Dialog-Frame:title = filter-point-label
    .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-32
      ) no-error .
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-32 =
        (
          if (" X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = '':U and X_dis-prop_host.obj-code = 0" + " " + where-phrase-32) <> ""
          then  substitute('X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = &1&1 and X_dis-prop_host.obj-code = 0 ', chr(34)) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", FIRST X_prop-ref_host NO-LOCK WHERE X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          (" X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = '':U and X_dis-prop_host.obj-code = 0" + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-32 = false then do:
    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK
      where  X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = '':U and X_dis-prop_host.obj-code = 0
    , FIRST X_prop-ref_host NO-LOCK WHERE X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
       by X_dis-prop_host.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_host )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_host:handle:get-buffer-handle(1) = (buffer X_dis-prop_host:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = &1&1 and X_dis-prop_host.obj-code = 0 ', chr(34)) + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input rowid(X_dis-prop_host)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer X_dis-prop_host:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-32 =
        (
          if (" X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = '':U and X_dis-prop_host.obj-code = 0" + " " + where-phrase-32) <> ""
          then  substitute('X_dis-prop_host.host-code > 0  and X_dis-prop_host.obj-type = &1&1 and X_dis-prop_host.obj-code = 0 ', chr(34)) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", FIRST X_prop-ref_host NO-LOCK WHERE X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&2)"
                                      , f-dtm-code
                                      , buf_prop-head.prop-label
                                      )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-34  as logical   no-undo .
define variable  l-filter-open-34    as logical   .
define variable  flt-rec-34       as recid     no-undo .
define variable  filter-name-34      as character no-undo .
define variable  where-phrase-34     as character no-undo .
define variable  sort-phrase-34      as character no-undo .
define variable  where-phrase-rus-34 as character no-undo .
define variable  sort-phrase-rus-34  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-34
  ,output filter-name-34
  ,output where-phrase-34
  ,output sort-phrase-34
  ,output where-phrase-rus-34
  ,output sort-phrase-rus-34
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-34
      ) no-error .
  assign
    l-filter-open-34 = false
  .
  if flt-rec-34 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-34 as character no-undo .
    define variable  parameter-3-34 as character no-undo .
    define variable  parameter-4-34 as character no-undo .
    define variable  parameter-5-34 as character no-undo .
    define variable  parameter-6-34 as character no-undo .
    define variable  parameter-7-34 as character no-undo .
      assign
      parameter-3-34 =
                              "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-34 =
        (
          if (" X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = '':U                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-34) <> ""
          then  substitute('X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = &1&1                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = &2', chr(34), f-dtm-code ) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_prop-ref_host NO-LOCK WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-34 =
          (" X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = '':U                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          )
      .
      assign
        l-filter-open-34 = true
      .
    end.
    if l-filter-open-34 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-34 = false then do:
    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK
      where  X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = '':U                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = f-dtm-code
    , FIRST X_prop-ref_host NO-LOCK WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
       by X_dis-prop_host.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_host )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_host:handle:get-buffer-handle(1) = (buffer X_dis-prop_host:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = &1&1                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = &2', chr(34), f-dtm-code ) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input rowid(X_dis-prop_host)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_dis-prop_host:handle)
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-3-34 =  "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-34 =
        (
          if (" X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = '':U                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-34) <> ""
          then  substitute('X_dis-prop_host.host-code > 0                        and X_dis-prop_host.obj-type = &1&1                        and X_dis-prop_host.obj-code = 0                        and X_dis-prop_host.dtm-code = &2', chr(34), f-dtm-code ) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_prop-ref_host NO-LOCK WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                          X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-36  as logical   no-undo .
define variable  l-filter-open-36    as logical   .
define variable  flt-rec-36       as recid     no-undo .
define variable  filter-name-36      as character no-undo .
define variable  where-phrase-36     as character no-undo .
define variable  sort-phrase-36      as character no-undo .
define variable  where-phrase-rus-36 as character no-undo .
define variable  sort-phrase-rus-36  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-36
  ,output filter-name-36
  ,output where-phrase-36
  ,output sort-phrase-36
  ,output where-phrase-rus-36
  ,output sort-phrase-rus-36
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-36
      ) no-error .
  assign
    l-filter-open-36 = false
  .
  if flt-rec-36 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-36 as character no-undo .
    define variable  parameter-3-36 as character no-undo .
    define variable  parameter-4-36 as character no-undo .
    define variable  parameter-5-36 as character no-undo .
    define variable  parameter-6-36 as character no-undo .
    define variable  parameter-7-36 as character no-undo .
      assign
      parameter-3-36 =
                              "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-36 =
        (
          if (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = f-dt-code " + " " + where-phrase-36) <> ""
          then  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = &2', chr(34), f-dt-code ) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-36 =
          (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = f-dt-code " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          )
      .
      assign
        l-filter-open-36 = true
      .
    end.
    if l-filter-open-36 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-36 = false then do:
    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK
      where  X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = f-dt-code
    , FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
       by X_dis-prop_host.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_host )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_host:handle:get-buffer-handle(1) = (buffer X_dis-prop_host:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = &2', chr(34), f-dt-code ) + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input rowid(X_dis-prop_host)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_dis-prop_host:handle)
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-3-36 =  "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-36 =
        (
          if (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = f-dt-code " + " " + where-phrase-36) <> ""
          then  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0 and  X_dis-prop_host.dt-code = &2', chr(34), f-dt-code ) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по фирмам по объекту-операнду &2: &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-38
  ,output filter-name-38
  ,output where-phrase-38
  ,output sort-phrase-38
  ,output where-phrase-rus-38
  ,output sort-phrase-rus-38
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-38
      ) no-error .
  assign
    l-filter-open-38 = false
  .
  if flt-rec-38 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-38 as character no-undo .
    define variable  parameter-3-38 as character no-undo .
    define variable  parameter-4-38 as character no-undo .
    define variable  parameter-5-38 as character no-undo .
    define variable  parameter-6-38 as character no-undo .
    define variable  parameter-7-38 as character no-undo .
      assign
      parameter-3-38 =
                              "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-38 =
        (
          if (" X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = f-dt-code                           and X_dis-prop_host.node-code = f-node-code " + " " + where-phrase-38) <> ""
          then  substitute('X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = &2                           and X_dis-prop_host.node-code = &3 ', chr(34), f-dt-code , f-node-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-38 =
          (" X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = f-dt-code                           and X_dis-prop_host.node-code = f-node-code " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          )
      .
      assign
        l-filter-open-38 = true
      .
    end.
    if l-filter-open-38 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-38 = false then do:
    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK
      where  X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = f-dt-code                           and X_dis-prop_host.node-code = f-node-code
    , FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
       by X_dis-prop_host.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_host )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_host:handle:get-buffer-handle(1) = (buffer X_dis-prop_host:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute('X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = &2                           and X_dis-prop_host.node-code = &3 ', chr(34), f-dt-code , f-node-code) + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input rowid(X_dis-prop_host)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer X_dis-prop_host:handle)
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-3-38 =  "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-38 =
        (
          if (" X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = '':U                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = f-dt-code                           and X_dis-prop_host.node-code = f-node-code " + " " + where-phrase-38) <> ""
          then  substitute('X_dis-prop_host.host-code > 0                           and X_dis-prop_host.obj-type = &1&1                           and X_dis-prop_host.obj-code = 0                            and X_dis-prop_host.dt-code = &2                           and X_dis-prop_host.node-code = &3 ', chr(34), f-dt-code , f-node-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                           X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                     , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                         X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "node-code" then do:
      assign
      filter-point-label = substitute("Все срезы по ДК по фирмам по объекту-операнду &1 (&3): &2"
                                      , f-dtm-code
                                      , f-node-label
                                      , buf_prop-head.prop-label
                                      )
      frame Dialog-Frame:title = filter-point-label
      .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-40 =
        (
          if (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = f-node-code                         and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-40) <> ""
          then  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = &2                         and X_dis-prop_host.dtm-code = &3', chr(34), f-node-code, f-dtm-code ) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                         X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                   , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                       X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = f-node-code                         and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-40 = false then do:
    OPEN QUERY br-dis-prop_host FOR EACH X_dis-prop_host NO-LOcK
      where  X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = f-node-code                         and X_dis-prop_host.dtm-code = f-dtm-code
    , FIRST X_prop-ref_host WHERE                                         X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                   , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                       X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code
       by X_dis-prop_host.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_host )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_host:handle:get-buffer-handle(1) = (buffer X_dis-prop_host:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = &2                         and X_dis-prop_host.dtm-code = &3', chr(34), f-node-code, f-dtm-code ) + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input rowid(X_dis-prop_host)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_dis-prop_host:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH X_dis-prop_host NO-LOcK"
      parameter-4-40 =
        (
          if (" X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = '':U                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = f-node-code                         and X_dis-prop_host.dtm-code = f-dtm-code " + " " + where-phrase-40) <> ""
          then  substitute('X_dis-prop_host.host-code > 0 and X_dis-prop_host.obj-type = &1&1                         and X_dis-prop_host.obj-code = 0                         and X_dis-prop_host.node-code = &2                         and X_dis-prop_host.dtm-code = &3', chr(34), f-node-code, f-dtm-code ) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + ", FIRST X_prop-ref_host WHERE                                         X_prop-ref_host.dt-code = X_dis-prop_host.dt-code                                   , FIRST X_prop-map_host no-lock where X_prop-map_host.node-code = X_dis-prop_host.node-code AND                                                                       X_prop-map_host.dtm-code = X_dis-prop_host.dtm-code" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_host.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_host:handle
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
END CASE.
if not p-open-query then
REPOSITION br-dis-prop_host to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_host:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_host.
APPLY "VALUE-CHANGED" TO br-dis-prop_host in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr_obj :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + v-list-mode + "_obj".
CASE v-list-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-point-label = substitute("Все срезы по ДК по объектам")
    frame Dialog-Frame:title = filter-point-label
    .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-42
  ,output filter-name-42
  ,output where-phrase-42
  ,output sort-phrase-42
  ,output where-phrase-rus-42
  ,output sort-phrase-rus-42
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-42
      ) no-error .
  assign
    l-filter-open-42 = false
  .
  if flt-rec-42 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-42 as character no-undo .
    define variable  parameter-3-42 as character no-undo .
    define variable  parameter-4-42 as character no-undo .
    define variable  parameter-5-42 as character no-undo .
    define variable  parameter-6-42 as character no-undo .
    define variable  parameter-7-42 as character no-undo .
      assign
      parameter-3-42 =
                              "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-42 =
        (
          if (" X_dis-prop_obj.obj-type > '':U " + " " + where-phrase-42) <> ""
          then " X_dis-prop_obj.obj-type > '':U " + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + ", FIRST X_prop-ref_obj NO-LOCK WHERE X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                          X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          (" X_dis-prop_obj.obj-type > '':U " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          )
      .
      assign
        l-filter-open-42 = true
      .
    end.
    if l-filter-open-42 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-42 = false then do:
    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK
      where  X_dis-prop_obj.obj-type > '':U
    , FIRST X_prop-ref_obj NO-LOCK WHERE X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                          X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
       by X_dis-prop_obj.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_obj )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_obj:handle:get-buffer-handle(1) = (buffer X_dis-prop_obj:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u + " X_dis-prop_obj.obj-type > '':U " + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input rowid(X_dis-prop_obj)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer X_dis-prop_obj:handle)
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-3-42 =  "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-42 =
        (
          if (" X_dis-prop_obj.obj-type > '':U " + " " + where-phrase-42) <> ""
          then " X_dis-prop_obj.obj-type > '':U " + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + ", FIRST X_prop-ref_obj NO-LOCK WHERE X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                          X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все срезы по ДК по объектам по объекту-операнду &1 (&2)"
                                       , f-dtm-code
                                       , buf_prop-head.prop-label
                                       )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-44
  ,output filter-name-44
  ,output where-phrase-44
  ,output sort-phrase-44
  ,output where-phrase-rus-44
  ,output sort-phrase-rus-44
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-44
      ) no-error .
  assign
    l-filter-open-44 = false
  .
  if flt-rec-44 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-44 as character no-undo .
    define variable  parameter-3-44 as character no-undo .
    define variable  parameter-4-44 as character no-undo .
    define variable  parameter-5-44 as character no-undo .
    define variable  parameter-6-44 as character no-undo .
    define variable  parameter-7-44 as character no-undo .
      assign
      parameter-3-44 =
                              "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-44 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                        AND X_dis-prop_obj.dtm-code = f-dtm-code " + " " + where-phrase-44) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                        AND X_dis-prop_obj.dtm-code = &2', chr(34), f-dtm-code ) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + ", FIRST X_prop-ref_obj NO-LOCK WHERE                                           X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where                                            X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                          AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          (" X_dis-prop_obj.obj-type > '':U                        AND X_dis-prop_obj.dtm-code = f-dtm-code " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          )
      .
      assign
        l-filter-open-44 = true
      .
    end.
    if l-filter-open-44 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-44 = false then do:
    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK
      where  X_dis-prop_obj.obj-type > '':U                        AND X_dis-prop_obj.dtm-code = f-dtm-code
    , FIRST X_prop-ref_obj NO-LOCK WHERE                                           X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where                                            X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                          AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
       by X_dis-prop_obj.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_obj )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_obj:handle:get-buffer-handle(1) = (buffer X_dis-prop_obj:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute('X_dis-prop_obj.obj-type > &1&1                        AND X_dis-prop_obj.dtm-code = &2', chr(34), f-dtm-code ) + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input rowid(X_dis-prop_obj)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_dis-prop_obj:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-44 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                        AND X_dis-prop_obj.dtm-code = f-dtm-code " + " " + where-phrase-44) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                        AND X_dis-prop_obj.dtm-code = &2', chr(34), f-dtm-code ) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + ", FIRST X_prop-ref_obj NO-LOCK WHERE                                           X_prop-ref_obj.dt-code = X_dis-prop_obj.dt-code                                     , FIRST X_prop-map_obj no-lock where                                            X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                          AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по объектам по объекту-операнду &2 (&3)"
                                        , f-sum-id
                                        , f-dtm-code
                                        , buf_prop-head.prop-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-46  as logical   no-undo .
define variable  l-filter-open-46    as logical   .
define variable  flt-rec-46       as recid     no-undo .
define variable  filter-name-46      as character no-undo .
define variable  where-phrase-46     as character no-undo .
define variable  sort-phrase-46      as character no-undo .
define variable  where-phrase-rus-46 as character no-undo .
define variable  sort-phrase-rus-46  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-46
  ,output filter-name-46
  ,output where-phrase-46
  ,output sort-phrase-46
  ,output where-phrase-rus-46
  ,output sort-phrase-rus-46
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-46
      ) no-error .
  assign
    l-filter-open-46 = false
  .
  if flt-rec-46 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-46 as character no-undo .
    define variable  parameter-3-46 as character no-undo .
    define variable  parameter-4-46 as character no-undo .
    define variable  parameter-5-46 as character no-undo .
    define variable  parameter-6-46 as character no-undo .
    define variable  parameter-7-46 as character no-undo .
      assign
      parameter-3-46 =
                              "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-46 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                   and X_dis-prop_obj.dt-code = f-dt-code " + " " + where-phrase-46) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                   and X_dis-prop_obj.dt-code = &2', chr(34), f-dt-code ) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                 X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" X_dis-prop_obj.obj-type > '':U                   and X_dis-prop_obj.dt-code = f-dt-code " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          )
      .
      assign
        l-filter-open-46 = true
      .
    end.
    if l-filter-open-46 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-46 = false then do:
    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK
      where  X_dis-prop_obj.obj-type > '':U                   and X_dis-prop_obj.dt-code = f-dt-code
    , FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                 X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
       by X_dis-prop_obj.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_obj )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_obj:handle:get-buffer-handle(1) = (buffer X_dis-prop_obj:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute('X_dis-prop_obj.obj-type > &1&1                   and X_dis-prop_obj.dt-code = &2', chr(34), f-dt-code ) + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input rowid(X_dis-prop_obj)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer X_dis-prop_obj:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-46 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                   and X_dis-prop_obj.dt-code = f-dt-code " + " " + where-phrase-46) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                   and X_dis-prop_obj.dt-code = &2', chr(34), f-dt-code ) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                 X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
  when "dt-node-code" then do:
        assign
        filter-point-label = substitute("Срез &1 по ДК по объектам по объекту-операнду &2 (&4): &3"
                                        , f-sum-id
                                        , f-dtm-code
                                        , f-node-label
                                        , buf_prop-head.prop-label
                                        )
        frame Dialog-Frame:title = filter-point-label
        .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-48  as logical   no-undo .
define variable  l-filter-open-48    as logical   .
define variable  flt-rec-48       as recid     no-undo .
define variable  filter-name-48      as character no-undo .
define variable  where-phrase-48     as character no-undo .
define variable  sort-phrase-48      as character no-undo .
define variable  where-phrase-rus-48 as character no-undo .
define variable  sort-phrase-rus-48  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-48
  ,output filter-name-48
  ,output where-phrase-48
  ,output sort-phrase-48
  ,output where-phrase-rus-48
  ,output sort-phrase-rus-48
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-48
      ) no-error .
  assign
    l-filter-open-48 = false
  .
  if flt-rec-48 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-48 as character no-undo .
    define variable  parameter-3-48 as character no-undo .
    define variable  parameter-4-48 as character no-undo .
    define variable  parameter-5-48 as character no-undo .
    define variable  parameter-6-48 as character no-undo .
    define variable  parameter-7-48 as character no-undo .
      assign
      parameter-3-48 =
                              "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-48 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                        and X_dis-prop_obj.dt-code = f-dt-code                       and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-48) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                        and X_dis-prop_obj.dt-code = &2                       and X_dis-prop_obj.node-code = &3', chr(34), f-dt-code, f-node-code) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where                                                X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                            AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          (" X_dis-prop_obj.obj-type > '':U                        and X_dis-prop_obj.dt-code = f-dt-code                       and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          )
      .
      assign
        l-filter-open-48 = true
      .
    end.
    if l-filter-open-48 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-48 = false then do:
    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK
      where  X_dis-prop_obj.obj-type > '':U                        and X_dis-prop_obj.dt-code = f-dt-code                       and X_dis-prop_obj.node-code = f-node-code
    , FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where                                                X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                            AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
       by X_dis-prop_obj.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_obj )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_obj:handle:get-buffer-handle(1) = (buffer X_dis-prop_obj:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute('X_dis-prop_obj.obj-type > &1&1                        and X_dis-prop_obj.dt-code = &2                       and X_dis-prop_obj.node-code = &3', chr(34), f-dt-code, f-node-code) + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input rowid(X_dis-prop_obj)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer X_dis-prop_obj:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-48 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                        and X_dis-prop_obj.dt-code = f-dt-code                       and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-48) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                        and X_dis-prop_obj.dt-code = &2                       and X_dis-prop_obj.node-code = &3', chr(34), f-dt-code, f-node-code) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                            X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                            , FIRST X_prop-map_obj no-lock where                                                X_prop-map_obj.node-code = X_dis-prop_obj.node-code                                            AND X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  END.
    when "node-code" then do:
          assign
          filter-point-label = substitute("Все срезы по ДК по объектам по объекту-операнду &1 (&3): &2"
                                          , f-dtm-code
                                          , f-node-label
                                          , buf_prop-head.prop-label
                                          )
          frame Dialog-Frame:title = filter-point-label
          .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-50  as logical   no-undo .
define variable  l-filter-open-50    as logical   .
define variable  flt-rec-50       as recid     no-undo .
define variable  filter-name-50      as character no-undo .
define variable  where-phrase-50     as character no-undo .
define variable  sort-phrase-50      as character no-undo .
define variable  where-phrase-rus-50 as character no-undo .
define variable  sort-phrase-rus-50  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-50
  ,output filter-name-50
  ,output where-phrase-50
  ,output sort-phrase-50
  ,output where-phrase-rus-50
  ,output sort-phrase-rus-50
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-50
      ) no-error .
  assign
    l-filter-open-50 = false
  .
  if flt-rec-50 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-50 as character no-undo .
    define variable  parameter-3-50 as character no-undo .
    define variable  parameter-4-50 as character no-undo .
    define variable  parameter-5-50 as character no-undo .
    define variable  parameter-6-50 as character no-undo .
    define variable  parameter-7-50 as character no-undo .
      assign
      parameter-3-50 =
                              "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-50 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                          AND X_dis-prop_obj.dtm-code = f-dtm-code                         and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-50) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                          AND X_dis-prop_obj.dtm-code = &2                         and X_dis-prop_obj.node-code = &3 ', chr(34), f-dtm-code, f-node-code) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                              X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                              , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                   X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          (" X_dis-prop_obj.obj-type > '':U                          AND X_dis-prop_obj.dtm-code = f-dtm-code                         and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          )
      .
      assign
        l-filter-open-50 = true
      .
    end.
    if l-filter-open-50 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-50 = false then do:
    OPEN QUERY br-dis-prop_obj FOR EACH X_dis-prop_obj NO-LOcK
      where  X_dis-prop_obj.obj-type > '':U                          AND X_dis-prop_obj.dtm-code = f-dtm-code                         and X_dis-prop_obj.node-code = f-node-code
    , FIRST X_prop-ref_obj WHERE                                              X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                              , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                   X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code
       by X_dis-prop_obj.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-prop_obj )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-prop_obj:handle:get-buffer-handle(1) = (buffer X_dis-prop_obj:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute('X_dis-prop_obj.obj-type > &1&1                          AND X_dis-prop_obj.dtm-code = &2                         and X_dis-prop_obj.node-code = &3 ', chr(34), f-dtm-code, f-node-code) + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input rowid(X_dis-prop_obj)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer X_dis-prop_obj:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH X_dis-prop_obj NO-LOcK"
      parameter-4-50 =
        (
          if (" X_dis-prop_obj.obj-type > '':U                          AND X_dis-prop_obj.dtm-code = f-dtm-code                         and X_dis-prop_obj.node-code = f-node-code " + " " + where-phrase-50) <> ""
          then  substitute('X_dis-prop_obj.obj-type > &1&1                          AND X_dis-prop_obj.dtm-code = &2                         and X_dis-prop_obj.node-code = &3 ', chr(34), f-dtm-code, f-node-code) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + ", FIRST X_prop-ref_obj WHERE                                              X_prop-ref_Obj.dt-code = X_dis-prop_obj.dt-code                                              , FIRST X_prop-map_obj no-lock where X_prop-map_obj.node-code = X_dis-prop_obj.node-code AND                                                                                   X_prop-map_obj.dtm-code = X_dis-prop_obj.dtm-code" + " " + p-find-condition)
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-prop_obj.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-prop_obj:handle
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
END CASE.
if not p-open-query then
REPOSITION br-dis-prop_obj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-prop_obj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-prop_obj.
APPLY "VALUE-CHANGED" TO br-dis-prop_obj in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE PrintProc :
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable  date_string        as character no-undo.
define variable  Line               as character no-undo.
define variable  for-time           as character no-undo .
define variable  accum-count        as integer   no-undo .
define variable v-character as character no-undo .
Line = fill("-", 198).
date_string = cur-time-print() .
define frame dis-prop_
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_prop-map_.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
DEFINE frame dis-prop_host
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_prop-map_host.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_host.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_host.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_host.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_host.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_host.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
DEFINE frame dis-prop_obj
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-prop_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-prop_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-prop_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_prop-map_obj.node-name COLUMN-LABEL "Свойство" FORMAT "X(20)"
X_dis-prop_obj.property-value-character COLUMN-LABEL "Значение" format "X(44)"
X_dis-prop_obj.property-value-date COLUMN-LABEL "Значение" format "99/99/9999"
X_dis-prop_obj.property-value-decimal COLUMN-LABEL "Значение" format "->>,>>>,>>>,>>>,>>>.99"
X_dis-prop_obj.property-value-integer COLUMN-LABEL "Значение" format "->,>>>,>>>,>>9"
X_dis-prop_obj.property-value-logical COLUMN-LABEL "Знач" format "+/"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream unformatted
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(0)
(if f-dtm-code <> 0 then f-dtm-name else '':U) skip(0)
(if f-dt-code <> ? then f-sum-id else '':U)
.
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
CASE p-region:
  WHEN "global" THEN DO:
    FORM with FRAME dis-prop_ .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_  no-lock.
    DO WHILE available X_dis-prop_:
      Display STREAM PrnLibStream
      X_prop-ref_.sum-id
      X_prop-ref_.caller_id
      X_prop-ref_.dtm-code
      X_dis-prop_.d-card
      X_prop-map_.node-name
      X_dis-prop_.property-value-character when entry(1, X_prop-map_.node-value-type) = 'character':U
      X_dis-prop_.property-value-date when entry(1, X_prop-map_.node-value-type) = 'date':U
      X_dis-prop_.property-value-decimal when entry(1, X_prop-map_.node-value-type) = 'decimal':U
      X_dis-prop_.property-value-integer when entry(1, X_prop-map_.node-value-type) = 'integer':U
      X_dis-prop_.property-value-logical when entry(1, X_prop-map_.node-value-type) = 'logical':U
      with FRAME dis-prop_ .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_ .
      assign
      accum-count = accum-count + 1 .
      GET next br-dis-prop_ no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_.sum-id
    X_prop-ref_.caller_id
    X_prop-ref_.dtm-code
    X_dis-prop_.d-card
    X_prop-map_.node-name
    X_dis-prop_.property-value-character
    X_dis-prop_.property-value-date
    X_dis-prop_.property-value-decimal
    X_dis-prop_.property-value-integer
    X_dis-prop_.property-value-logical
    with FRAME dis-prop_ .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_.sum-id
    accum-count @ X_dis-prop_.d-card
    with frame dis-prop_.
  END.
  WHEN 'фирма':U THEN DO:
    FORM with FRAME dis-prop_host .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_host  no-lock.
    DO WHILE available X_dis-prop_host:
      Display STREAM PrnLibStream
      X_prop-ref_host.sum-id
      X_prop-ref_host.caller_id
      X_prop-ref_host.dtm-code
      X_dis-prop_host.d-card
      X_prop-map_host.node-name
      X_dis-prop_host.property-value-character when entry(1, X_prop-map_host.node-value-type) = 'character':U
      X_dis-prop_host.property-value-date when entry(1, X_prop-map_host.node-value-type) = 'date':U
      X_dis-prop_host.property-value-decimal when entry(1, X_prop-map_host.node-value-type) = 'decimal':U
      X_dis-prop_host.property-value-integer when entry(1, X_prop-map_host.node-value-type) = 'integer':U
      X_dis-prop_host.property-value-logical when entry(1, X_prop-map_host.node-value-type) = 'logical':U
      with FRAME dis-prop_host .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_host .
      assign
      accum-count = accum-count + 1.
      GET next br-dis-prop_host no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_host.sum-id
    X_prop-ref_host.caller_id
    X_prop-ref_host.dtm-code
    X_dis-prop_host.d-card
    X_prop-map_host.node-name
    X_dis-prop_host.property-value-character
    X_dis-prop_host.property-value-date
    X_dis-prop_host.property-value-decimal
    X_dis-prop_host.property-value-integer
    X_dis-prop_host.property-value-logical
    with FRAME dis-prop_host .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_host.sum-id
    accum-count @ X_dis-prop_host.d-card
    with frame dis-prop_host.
  END.
  WHEN 'объект':U THEN DO:
    FORM with FRAME dis-prop_obj .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-prop_obj  no-lock.
    DO WHILE available X_dis-prop_obj:
      Display STREAM PrnLibStream
      X_prop-ref_obj.sum-id
      X_prop-ref_obj.caller_id
      X_prop-ref_obj.dtm-code
      X_dis-prop_obj.d-card
      X_prop-map_obj.node-name
      X_dis-prop_obj.property-value-character when entry(1, X_prop-map_obj.node-value-type) = 'character':U
      X_dis-prop_obj.property-value-date when entry(1, X_prop-map_obj.node-value-type) = 'date':U
      X_dis-prop_obj.property-value-decimal when entry(1, X_prop-map_obj.node-value-type) = 'decimal':U
      X_dis-prop_obj.property-value-integer when entry(1, X_prop-map_obj.node-value-type) = 'integer':U
      X_dis-prop_obj.property-value-logical when entry(1, X_prop-map_obj.node-value-type) = 'logical':U
      with FRAME dis-prop_obj .
      DOWN STREAM PrnLibStream 1 with FRAME dis-prop_obj .
      assign
      accum-count = accum-count + 1.
      GET next br-dis-prop_obj no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_obj.sum-id
    X_prop-ref_obj.caller_id
    X_prop-ref_obj.dtm-code
    X_dis-prop_obj.d-card
    X_prop-map_obj.node-name
    X_dis-prop_obj.property-value-character
    X_dis-prop_obj.property-value-date
    X_dis-prop_obj.property-value-decimal
    X_dis-prop_obj.property-value-integer
    X_dis-prop_obj.property-value-logical
    with FRAME dis-prop_obj .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_obj.sum-id
    accum-count @ X_dis-prop_obj.d-card
    with frame dis-prop_obj.
  END.
end case.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid-list AS CHARACTER NO-undo.
CASE p-option:
END CASE.
END PROCEDURE.
PROCEDURE proc-b-sch :
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable loc-point as character no-undo .
define variable loc-label as character no-undo .
CASE p-region:
  WHEN 'объект':U THEN DO:
    run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('host-code', 'Фирма', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    assign
      tbl = 'dis-card-property'
      join-tbl = 'X_dis-prop_obj'
      fld = ""
      lab = ""
      spr = ""
      dim = '0'
      loc-point = substitute('&1_obj', filter-point)
      loc-label = substitute('&1 ОБъект', filter-point-label)
      .
  END.
  WHEN 'фирма':U THEN DO:
     run fltfield-add in this-procedure('host-code', 'Фирма', '',
     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
     assign
       tbl = 'dis-card-property'
       join-tbl = 'X_dis-prop_host'
       fld = ""
       lab = ""
       spr = ""
       dim = '0'
      loc-point = substitute('&1_host', filter-point)
      loc-label = substitute('&1 Фирма', filter-point-label)
       .
  END.
  WHEN "global" THEN DO:
      assign
        tbl = 'dis-card-property'
        join-tbl = 'X_dis-prop_'
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
      loc-point = substitute('&1', filter-point)
      loc-label = substitute('&1', filter-point-label)
        .
  END.
END CASE.
run fltfield-add in this-procedure('d-card', '№ карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('node-code', 'Свойство', 'dcp-node-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-character', 'Значение(строковое)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-date', 'Значение(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-decimal', 'Значение(десятичное)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-integer', 'Значение(целое)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('property-value-logical', 'Значение(логич)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (loc-point + chr(4) + loc-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE set-row-color_ :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
PROCEDURE set-row-color_host :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_host[1]:FGCOLOR = GREY_COLOR
v-ch_host[1]:BGCOLOR = GREY_Color
v-ch_host[1]:PFCOLOR = GREY_Color
v-ch_host[2]:FGCOLOR = GREY_COLOR
v-ch_host[2]:BGCOLOR = GREY_Color
v-ch_host[2]:PFCOLOR = GREY_Color
v-ch_host[3]:FGCOLOR = GREY_COLOR
v-ch_host[3]:BGCOLOR = GREY_Color
v-ch_host[3]:PFCOLOR = GREY_Color
v-ch_host[4]:FGCOLOR = GREY_COLOR
v-ch_host[4]:BGCOLOR = GREY_Color
v-ch_host[4]:PFCOLOR = GREY_Color
v-ch_host[5]:FGCOLOR = GREY_COLOR
v-ch_host[5]:BGCOLOR = GREY_Color
v-ch_host[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch_host[1]:FGCOLOR = BLACK_COLOR
      v-ch_host[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch_host[3]:FGCOLOR = BLACK_COLOR
      v-ch_host[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch_host[4]:FGCOLOR = BLACK_COLOR
      v-ch_host[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch_host[2]:FGCOLOR = BLACK_COLOR
      v-ch_host[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch_host[5]:FGCOLOR = BLACK_COLOR
       v-ch_host[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
PROCEDURE set-row-color_obj :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
FUNCTION display-character RETURNS CHARACTER
  (  INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER) :
DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.
IF trim(p-format, "*") = "" THEN
v-string = string(p-character, p-format).
ELSE DO:
v-string = p-character.
END.
RETURN v-string.
END FUNCTION.
