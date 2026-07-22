DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-thbj-rule FOR ub.dis-thbj-rule.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define INPUT PARAMETER bttn AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-curr-host-code as integer no-undo .
define INPUT PARAMETER p-curr-obj-type AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-curr-obj-code AS integer NO-UNDO.
define INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
define INPUT PARAMETER p-pos-type AS character NO-UNDO.
define INPUT PARAMETER p-discnt-role AS character NO-UNDO.
define input parameter p-rule-num as integer no-undo .
define INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список скидок на объекты TH".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
DEFINE VARIABLE gds-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "disthbjs" .
define variable filter-point0 as character no-undo init "disthbjs" .
define variable filter-label as character no-undo init "Скидки на объекты TH" .
define variable filter-label0 as character no-undo init "Скидки на объекты TH" .
define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE BUFFER par_dis-rule FOR ub.dis-rule.
DEFINE BUFFER par_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-dis-thbj-rule FOR X_dis-thbj-rule, X_clients SCROLLING.
DEFINE BROWSE BR-dis-thbj-rule
  QUERY BR-dis-thbj-rule NO-LOCK DISPLAY
      mark-string(recid(X_dis-thbj-rule), v-rid-list) COLUMN-LABEL '*' FORMAT "X(1)"
X_clients.obj-name COLUMN-LABEL 'Объект/Фирма' FORMAT "X(40)" WIDTH 20
X_dis-thbj-rule.templ-rl-root COLUMN-LABEL 'Тип правила' FORMAT ">>>>>>>>9"
X_dis-thbj-rule.pos-type COLUMN-LABEL 'Место использ.'
X_dis-thbj-rule.obj-type COLUMN-LABEL 'Тип объ' FORMAT "X(3)"
X_dis-thbj-rule.obj-code COLUMN-LABEL 'Код объ' FORMAT ">>>>9"
X_dis-thbj-rule.host-code COLUMN-LABEL 'Код фирмы' FORMAT ">>>>9"
entry (lookup (X_dis-thbj-rule.discnt-role, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u) COLUMN-LABEL 'Тип скидки' FORMAT "X(40)" WIDTH 20
X_dis-thbj-rule.rule-num COLUMN-LABEL '№ правила' FORMAT ">>>>>>>>9"
X_dis-thbj-rule.rl-root COLUMN-LABEL '№ корн.!правила' FORMAT ">>>>>>>>9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 10
     B-sch AT ROW 1 COL 86 WIDGET-ID 8
     B-print AT ROW 1 COL 89 WIDGET-ID 6
     b-history AT ROW 1 COL 92 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     BR-dis-thbj-rule AT ROW 3 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     SPACE(78.50) SKIP(21.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на объектах TH"
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
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
if not available X_dis-thbj-rule then return no-apply.
run ref/cclihist.w (
                      input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , input "subject":U
                    , input X_dis-thbj-rule.obj-type
                    , input X_dis-thbj-rule.obj-code
                    , input X_dis-thbj-rule.host-code
                    , input ?
                    , input "":U
                    , input 'dis-thbj-rule':U
                    , input v-cntxt-db-num
                    , input-output v-rid-list  ) no-error .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-dis-thbj-rule.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_dis-thbj-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-thbj-rule ) ) .
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-dis-thbj-rule :handle
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_dis-thbj-rule).  Run OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-dis-thbj-rule to recid v-doc-rec No-ERROR.               apply 'value-changed' to br-dis-thbj-rule.
    apply "VALUE-CHANGED" to BR-dis-thbj-rule.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-dis-thbj-rule in frame Dialog-Frame.
  return no-apply.
end.
on SHIFT-F9 of frame Dialog-Frame anywhere do:
  if not available X_dis-card then
    return no-apply.
  gds-rec = recid (X_dis-card).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-dis-thbj-rule in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-dis-thbj-rule   as character no-undo .
def var sort-clmnbr-dis-thbj-rule    as handle    no-undo .
def var cur-clmnbr-dis-thbj-rule     as handle    no-undo .
def var cur-clmn-locbr-dis-thbj-rule as integer   no-undo .
def var re-querybr-dis-thbj-rule     as logical   initial no no-undo .
on start-search, ctrl-o of br-dis-thbj-rule in frame Dialog-Frame do:
   run sort-brbr-dis-thbj-rule
     (input (if available X_dis-thbj-rule
             then recid(X_dis-thbj-rule)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-dis-thbj-rule :
  define input parameter p-recid as recid no-undo .
  if re-querybr-dis-thbj-rule = no then do:
    assign
       cur-clmnbr-dis-thbj-rule = br-dis-thbj-rule:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-dis-thbj-rule <> ? then sort-clmnbr-dis-thbj-rule:column-fgcolor = 0.
    if cur-clmnbr-dis-thbj-rule = sort-clmnbr-dis-thbj-rule then do:
      assign
         sort-labelbr-dis-thbj-rule = ""
         sort-clmnbr-dis-thbj-rule = ?
      .
     end.
     else do:
       assign
         sort-labelbr-dis-thbj-rule = cur-clmnbr-dis-thbj-rule:label
         sort-clmnbr-dis-thbj-rule  = cur-clmnbr-dis-thbj-rule
         sort-clmnbr-dis-thbj-rule:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-dis-thbj-rule = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-dis-thbj-rule:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-dis-thbj-rule then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-dis-thbj-rule = cur-clmn-locbr-dis-thbj-rule + 1
    .
  end.
  case sort-labelbr-dis-thbj-rule:
        when '*'  then DO:    assign       sort-column-name = "mark-string(recid(X_dis-thbj-rule), v-rid-list)"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Объект/Фирма'  then DO:    assign       sort-column-name = "X_clients.obj-name"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Тип правила'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.templ-rl-root"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Место использ.'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.pos-type"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Тип объ'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.obj-type"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Код объ'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.obj-code"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Код фирмы'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.host-code"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Тип скидки'  then DO:    assign       sort-column-name = "entry (lookup (X_dis-thbj-rule.discnt-role, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u)"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when '№ правила'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.rule-num"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when '№ корн.!правила'  then DO:    assign       sort-column-name = "X_dis-thbj-rule.rl-root"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no).
      if sort-labelbr-dis-thbj-rule <> "" then do:
        assign
          cur-clmnbr-dis-thbj-rule:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-dis-thbj-rule = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-dis-thbj-rule to recid p-recid no-error.
    apply "value-changed" to br-dis-thbj-rule in frame Dialog-Frame.
  end.
  apply "entry" to br-dis-thbj-rule in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-dis-thbj-rule:
if cur-clmnbr-dis-thbj-rule = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no).
end.
else do:
   assign re-querybr-dis-thbj-rule = yes.
   run sort-brbr-dis-thbj-rule
     (input (if available X_dis-thbj-rule
             then recid(X_dis-thbj-rule)
             else ?
            )
     ).
   assign re-querybr-dis-thbj-rule = no.
end.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-dis-thbj-rule :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    v-rid-list = p-rid-list.
  IF lookup(p-list-mode, ('все':U + chr(4) +
                          "pos" + chr(4) +
                          "templ-rl-root" + chr(4) +
                          "discnt-role" + chr(4) +
                          'объект':U + chr(4) +
                          ('объект':U + chr(44) + "pos-type":U) + chr(4) +
                          ('объект':U + chr(44) + "templ-rl-root":U) + chr(4) +
                          ('объект':U + chr(44) + "discnt-role":U) + chr(4) +
                          "rule-num":U + chr(4) +
                          "rl-root":U
                          ) , chr(4)) = 0
  THEN DO:
     MESSAGE
     vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова p-list-mode " p-list-mode
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  IF lookup('объект':U , p-list-mode) > 0 THEN DO:
    IF p-curr-obj-type <> 'скл':U
    AND p-curr-obj-type <> 'маг':U THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова p-curr-obj-type " p-curr-obj-type
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    FIND FIRST X_clients-obj NO-LOCK WHERE
              X_clients-obj.obj-type = p-curr-obj-type
         AND  X_clients-obj.obj-code = p-curr-obj-code NO-ERROR.
    IF NOT AVAILABLE X_clients-obj THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверные параметры вызова p-curr-obj-type p-curr-obj-code" p-curr-obj-type p-curr-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  IF LOOKUP( "templ-rl-root", p-list-mode) > 0 THEN DO:
      FIND FIRST PAR_dis-rule NO-LOCK WHERE
                par_dis-rule.rule-num = p-templ-rl-root no-error.
      IF NOT AVAILABLE par_Dis-rule THEN DO:
          MESSAGE
          vss-workfile vss-revision vss-description skip
          "Неверный параметр вызова p-templ-rl-root" p-templ-rl-root
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
      END.
  END.
  IF LOOKUP( "pos-type", p-list-mode) > 0
  AND lookup(p-pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) = 0  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-pos-type" p-pos-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF LOOKUP( "discnt-role", p-list-mode) > 0 THEN DO:
    FIND FIRST par_dis-cfg-rule NO-LOCK WHERE
              par_dis-cfg-rule.discnt-role = p-discnt-role
          AND par_dis-cfg-rule.TABLE-name = 'dis-thbj-rule':U NO-ERROR.
    IF NOT AVAILABLE par_dis-cfg-rule  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-discnt-role" p-discnt-role
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
  END.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-sch B-print b-history B-Help BR-dis-thbj-rule
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-dis-thbj-rule FOR EACH X_dis-thbj-rule NO-LOCK ,            FIRST X_clients NO-LOCK OUTER-JOIN where           X_clients.obj-type = X_dis-thbj-rule.obj-type       AND X_clients.obj-code = X_dis-thbj-rule.obj-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-h AS widget-handle NO-UNDO.
X_clients.obj-name:RESIZABLE IN BROWSE br-dis-thbj-rule = YES.
v-h = br-dis-thbj-rule:FIRST-COLUMN IN FRAME Dialog-Frame.
DO while valid-handle(v-h) :
  if v-h:LABEL = 'Тип скидки' then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
DISPLAY
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttn) > 0
B-sel WHEN LOOKUP("b-mark", bttn) > 0
B-sch
B-print
b-history
B-Help
BR-dis-thbj-rule
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
RUn Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Скидки на объекты TH".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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
if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output p-host-code
  )  .
end.
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN 'все':U        THEN DO:
    ASSIGN
    frame Dialog-Frame:TITLE =
                                  substitute("&1"
                                  , title0
                                  )
    filter-label = substitute("&1", filter-label0)
                                  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-21  as logical   no-undo .
define variable  l-filter-open-21    as logical   .
define variable  flt-rec-21       as recid     no-undo .
define variable  filter-name-21      as character no-undo .
define variable  where-phrase-21     as character no-undo .
define variable  sort-phrase-21      as character no-undo .
define variable  where-phrase-rus-21 as character no-undo .
define variable  sort-phrase-rus-21  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-21
  ,output filter-name-21
  ,output where-phrase-21
  ,output sort-phrase-21
  ,output where-phrase-rus-21
  ,output sort-phrase-rus-21
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-21
      ) no-error .
  assign
    l-filter-open-21 = false
  .
  if flt-rec-21 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-21 =
        (
          if (" TRUE " + " " + where-phrase-21) <> ""
          then " TRUE " + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-21 =
          (" TRUE " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          )
      .
      assign
        l-filter-open-21 = true
      .
    end.
    if l-filter-open-21 = false then do:
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
  if l-filter-open-21 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  TRUE
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u + " TRUE " + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-21 =
        (
          if (" TRUE " + " " + where-phrase-21) <> ""
          then " TRUE " + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
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
  WHEN 'объект':U        THEN DO:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                    substitute("&1 по объекту &2 &3"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    )
      filter-label = substitute("&1 по объекту", filter-label0)
                                    .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-23  as logical   no-undo .
define variable  l-filter-open-23    as logical   .
define variable  flt-rec-23       as recid     no-undo .
define variable  filter-name-23      as character no-undo .
define variable  where-phrase-23     as character no-undo .
define variable  sort-phrase-23      as character no-undo .
define variable  where-phrase-rus-23 as character no-undo .
define variable  sort-phrase-rus-23  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-23
  ,output filter-name-23
  ,output where-phrase-23
  ,output sort-phrase-23
  ,output where-phrase-rus-23
  ,output sort-phrase-rus-23
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-23
      ) no-error .
  assign
    l-filter-open-23 = false
  .
  if flt-rec-23 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-23 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code " + " " + where-phrase-23) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3 ', chr(34), p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-23 =
          (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          )
      .
      assign
        l-filter-open-23 = true
      .
    end.
    if l-filter-open-23 = false then do:
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
  if l-filter-open-23 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u +  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3 ', chr(34), p-curr-obj-type, p-curr-obj-code) + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-23 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code " + " " + where-phrase-23) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3 ', chr(34), p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
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
  WHEN 'фирма':U        THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE =
                                      substitute("&1 по фирме &2"
                                      , title0
                                      , p-curr-host-code
                                      )
       filter-label = substitute("&1 по фирме", filter-label0)
                                      .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-25  as logical   no-undo .
define variable  l-filter-open-25    as logical   .
define variable  flt-rec-25       as recid     no-undo .
define variable  filter-name-25      as character no-undo .
define variable  where-phrase-25     as character no-undo .
define variable  sort-phrase-25      as character no-undo .
define variable  where-phrase-rus-25 as character no-undo .
define variable  sort-phrase-rus-25  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-25
  ,output filter-name-25
  ,output where-phrase-25
  ,output sort-phrase-25
  ,output where-phrase-rus-25
  ,output sort-phrase-rus-25
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-25
      ) no-error .
  assign
    l-filter-open-25 = false
  .
  if flt-rec-25 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-25 =
        (
          if (" X_dis-thbj-rule.host-code = p-curr-host-code " + " " + where-phrase-25) <> ""
          then  substitute('X_dis-thbj-rule.host-code = &1', p-curr-host-code ) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          (" X_dis-thbj-rule.host-code = p-curr-host-code " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          )
      .
      assign
        l-filter-open-25 = true
      .
    end.
    if l-filter-open-25 = false then do:
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
  if l-filter-open-25 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.host-code = p-curr-host-code
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u +  substitute('X_dis-thbj-rule.host-code = &1', p-curr-host-code ) + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-25 =
        (
          if (" X_dis-thbj-rule.host-code = p-curr-host-code " + " " + where-phrase-25) <> ""
          then  substitute('X_dis-thbj-rule.host-code = &1', p-curr-host-code ) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
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
  WHEN ('объект':U + chr(44) + "pos-type":U)       THEN DO:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                    substitute("&1 по объекту &2 &3 для &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-pos-type
                                    )
      filter-label = substitute("&1 по объекту для типа POS", filter-label0)
                                    .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-27
      ) no-error .
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-27 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-27) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.pos-type = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-pos-type) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
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
  if l-filter-open-27 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.pos-type = p-pos-type
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.pos-type = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-pos-type) + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-27 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-27) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.pos-type = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-pos-type) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
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
  WHEN ('объект':U + chr(44) + "templ-rl-root":U)       THEN DO:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                    substitute("&1 по объекту &2 &3 тип правила &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-templ-rl-root
                                    )
      filter-label = substitute("&1 по объекту для типа правила", filter-label0)
                                    .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-29
      ) no-error .
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-29 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-29) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.templ-rl-root = &4 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-templ-rl-root) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
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
  if l-filter-open-29 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.templ-rl-root = p-templ-rl-root
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u +  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.templ-rl-root = &4 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-templ-rl-root) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-29 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-29) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.templ-rl-root = &4 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-templ-rl-root) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
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
  WHEN ('объект':U + chr(44) + "discnt-role":U)       THEN DO:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                    substitute("&1 по объекту &2 &3 тип скидки &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-discnt-role
                                    )
                                    .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-31  as logical   no-undo .
define variable  l-filter-open-31    as logical   .
define variable  flt-rec-31       as recid     no-undo .
define variable  filter-name-31      as character no-undo .
define variable  where-phrase-31     as character no-undo .
define variable  sort-phrase-31      as character no-undo .
define variable  where-phrase-rus-31 as character no-undo .
define variable  sort-phrase-rus-31  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-31
  ,output filter-name-31
  ,output where-phrase-31
  ,output sort-phrase-31
  ,output where-phrase-rus-31
  ,output sort-phrase-rus-31
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-31
      ) no-error .
  assign
    l-filter-open-31 = false
  .
  if flt-rec-31 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-31 as character no-undo .
    define variable  parameter-3-31 as character no-undo .
    define variable  parameter-4-31 as character no-undo .
    define variable  parameter-5-31 as character no-undo .
    define variable  parameter-6-31 as character no-undo .
    define variable  parameter-7-31 as character no-undo .
      assign
      parameter-3-31 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-31 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-31) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.discnt-role = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-discnt-role) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          )
      .
      assign
        l-filter-open-31 = true
      .
    end.
    if l-filter-open-31 = false then do:
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
  if l-filter-open-31 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.discnt-role = p-discnt-role
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-4-31 =
        "where ":u +  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.discnt-role = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-discnt-role) + " ":u + where-phrase-31 + " ":u + p-find-condition + " " + ""
      parameter-5-31 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-3-31 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-31 =
        (
          if (" X_dis-thbj-rule.obj-type = p-curr-obj-type and X_dis-thbj-rule.obj-code = p-curr-obj-code                       AND X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-31) <> ""
          then  substitute('X_dis-thbj-rule.obj-type = &1&2&1 and X_dis-thbj-rule.obj-code = &3                       AND X_dis-thbj-rule.discnt-role = &1&4&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, p-discnt-role) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
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
  WHEN "templ-rl-root":U THEN DO:
    ASSIGN
    frame Dialog-Frame:TITLE =
                                  substitute("&1 по шаблону &2"
                                  , title0
                                  , p-templ-rl-root
                                  )
                                  .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-33 =
        (
          if (" X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-33) <> ""
          then  substitute('X_dis-thbj-rule.templ-rl-root = &1', p-templ-rl-root)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.templ-rl-root = p-templ-rl-root
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  substitute('X_dis-thbj-rule.templ-rl-root = &1', p-templ-rl-root)  + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-33 =
        (
          if (" X_dis-thbj-rule.templ-rl-root = p-templ-rl-root " + " " + where-phrase-33) <> ""
          then  substitute('X_dis-thbj-rule.templ-rl-root = &1', p-templ-rl-root)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
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
  WHEN "rule-num":U THEN DO:
    ASSIGN
    frame Dialog-Frame:TITLE =
                                  substitute("&1 с номером правила &2"
                                  , title0
                                  , p-rule-num
                                  )
                                  .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-35 =
        (
          if (" X_dis-thbj-rule.rule-num = p-rule-num " + " " + where-phrase-35) <> ""
          then  substitute('X_dis-thbj-rule.rule-num = &1', p-rule-num ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" X_dis-thbj-rule.rule-num = p-rule-num " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.rule-num = p-rule-num
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute('X_dis-thbj-rule.rule-num = &1', p-rule-num ) + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-35 =
        (
          if (" X_dis-thbj-rule.rule-num = p-rule-num " + " " + where-phrase-35) <> ""
          then  substitute('X_dis-thbj-rule.rule-num = &1', p-rule-num ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
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
  WHEN "rl-root":U THEN DO:
    ASSIGN
    frame Dialog-Frame:TITLE =
                                  substitute("&1 с номером корн.правила &2"
                                  , title0
                                  , p-rule-num
                                  )
                                  .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-37 =
        (
          if (" X_dis-thbj-rule.rl-root = p-rule-num " + " " + where-phrase-37) <> ""
          then  substitute('X_dis-thbj-rule.rl-root = &1', p-rule-num ) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" X_dis-thbj-rule.rl-root = p-rule-num " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.rl-root = p-rule-num
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute('X_dis-thbj-rule.rl-root = &1', p-rule-num ) + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-37 =
        (
          if (" X_dis-thbj-rule.rl-root = p-rule-num " + " " + where-phrase-37) <> ""
          then  substitute('X_dis-thbj-rule.rl-root = &1', p-rule-num ) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
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
  WHEN "pos":U THEN DO:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                    substitute("&1 пригодные для POS &2"
                                    , title0
                                    , p-pos-type)
                                    .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-39 =
        (
          if (" X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-39) <> ""
          then  substitute('X_dis-thbj-rule.pos-type = &1&2&1', chr(34), p-pos-type ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.pos-type = p-pos-type
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute('X_dis-thbj-rule.pos-type = &1&2&1', chr(34), p-pos-type ) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-39 =
        (
          if (" X_dis-thbj-rule.pos-type = p-pos-type " + " " + where-phrase-39) <> ""
          then  substitute('X_dis-thbj-rule.pos-type = &1&2&1', chr(34), p-pos-type ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
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
  WHEN "discnt-role":U THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE =   substitute("&1 тип &2"
                                      , title0
                                      , entry (lookup (p-discnt-role, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u)) .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH X_dis-thbj-rule"
      parameter-4-41 =
        (
          if (" X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-41) <> ""
          then  substitute('X_dis-thbj-rule.discnt-role = &1&2&1', chr(34), p-discnt-role ) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U))
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          (" X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-dis-thbj-rule FOR EACH X_dis-thbj-rule
      where  X_dis-thbj-rule.discnt-role = p-discnt-role
    ,FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = 'орг':U                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-thbj-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-thbj-rule:handle:get-buffer-handle(1) = (buffer X_dis-thbj-rule:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute('X_dis-thbj-rule.discnt-role = &1&2&1', chr(34), p-discnt-role ) + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input rowid(X_dis-thbj-rule)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer X_dis-thbj-rule:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH X_dis-thbj-rule"
      parameter-4-41 =
        (
          if (" X_dis-thbj-rule.discnt-role = p-discnt-role " + " " + where-phrase-41) <> ""
          then  substitute('X_dis-thbj-rule.discnt-role = &1&2&1', chr(34), p-discnt-role ) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + substitute(',FIRST X_clients OUTER-JOIN NO-LOCK where ((X_dis-thbj-rule.obj-code = 0 AND                                                                          X_clients.obj-type = &1&2&1                                                                       and X_clients.obj-code = X_Dis-thbj-rule.host-code)                                                                      OR (X_dis-thbj-rule.obj-code > 0                                                                       AND X_clients.obj-type = X_dis-thbj-rule.obj-type                                                                       and X_clients.obj-code = X_dis-thbj-rule.obj-code))', chr(34), 'орг':U) + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-thbj-rule:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
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
REPOSITION br-dis-thbj-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-thbj-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-thbj-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-thbj-rule in frame Dialog-Frame.
APPLY "ENTRY" TO br-dis-thbj-rule.
END PROCEDURE.
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
if available X_dis-thbj-rule then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid43 as character no-undo .
define variable v-num-entry43 as integer   no-undo .
assign
  v-str-recid43 = trim( string( recid( X_dis-thbj-rule ) , "->>>>>>>>>>>9":U ) )
  v-num-entry43 = lookup( v-str-recid43 , v-rid-list )
.
if v-num-entry43 > 0 then do:
  assign
    entry( v-num-entry43, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid43
  .
end.
  loc#log = br-dis-thbj-rule:refresh() IN FRAME Dialog-Frame .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dis-thbj-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-thbj-rule in frame Dialog-Frame.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame Dialog-Frame.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
end.
apply "entry" to br-dis-thbj-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable Line                as char         no-undo.
define variable v-rec as recid no-undo .
define variable ii as integer no-undo .
define variable v-mark as character no-undo .
define variable v-prod as character no-undo .
define variable v-d-name as character no-undo .
Line = fill( "-" , 140 ) .
define frame list
v-mark COLUMN-LABEL '*' FORMAT "X(1)"
X_clients.obj-name COLUMN-LABEL 'Объект/Фирма' FORMAT "X(40)"
X_dis-thbj-rule.templ-rl-root COLUMN-LABEL 'Тип правила' FORMAT ">>>>>>>>9"
X_dis-thbj-rule.pos-type COLUMN-LABEL 'Место использ.'
X_dis-thbj-rule.obj-type COLUMN-LABEL 'Тип объ' FORMAT "X(3)"
X_dis-thbj-rule.obj-code COLUMN-LABEL 'Код объ' FORMAT ">>>>9"
X_dis-thbj-rule.host-code COLUMN-LABEL 'Код фирмы' FORMAT ">>>>9"
v-d-name COLUMN-LABEL 'Тип скидки' FORMAT "X(20)"
X_dis-thbj-rule.rule-num COLUMN-LABEL '№ правила' FORMAT ">>>>>>>>9"
X_dis-thbj-rule.rl-root COLUMN-LABEL '№ корн.!правила' FORMAT ">>>>>>>>9"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width 235 down use-text stream-io no-box .
v-rec = recid(X_dis-thbj-rule).
DO WHILE available X_dis-thbj-rule :
  GET prev br-dis-thbj-rule NO-LOCK .
END.
GET next br-dis-thbj-rule NO-LOCK .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(30)
frame Dialog-Frame:title format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_dis-thbj-rule :
  DISPLAY stream PrnLibStream
  mark-string(recid(X_dis-thbj-rule), v-rid-list) @ v-mark
  X_clients.obj-name
  X_dis-thbj-rule.templ-rl-root
  X_dis-thbj-rule.pos-type
  X_dis-thbj-rule.obj-type
  X_dis-thbj-rule.obj-code
  X_dis-thbj-rule.host-code
  entry (lookup (p-discnt-role, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u) @ v-d-name
  X_dis-thbj-rule.rule-num
  X_dis-thbj-rule.rl-root
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
  GET next br-dis-thbj-rule .
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME BottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
reposition br-dis-thbj-rule to recid v-rec no-error.
if error-status:error then do:
  reposition br-dis-thbj-rule to row 1 no-error.
end.
APPLy "ENTRY" to br-dis-thbj-rule.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-thbj-rule'
  join-tbl = 'X_dis-thbj-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rule-num', '№ правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rl-root', '№ корн.правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pos-type', 'Место использ.', 'cd-types-discnt',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('discnt-role', 'Тип скидки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                     ,INPUT filter-point + chr(4) + filter-label
                     ,INPUT tbl
                     ,INPUT join-tbl
                     ,INPUT fld
                     ,INPUT lab
                     ,INPUT spr
                     ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
