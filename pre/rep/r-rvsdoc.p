block-level on error undo, throw.
define input parameter parparentproc as handle no-undo.
define input parameter p-recid       as recid  no-undo.
define variable vss-revision    as character no-undo initial "$Revision: 31d98d0f4d05, 3289, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-rvsdoc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-rvsdoc.p $":U .
define variable vss-description as character no-undo initial "Протокол снятия показаний уровнемера".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-line  as character no-undo format "X(179)" .
define variable v-line1 as character no-undo format "X(179)" .
define variable sym1  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym2  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym3  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym4  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym5  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym6  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym7  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym8  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym9  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym10 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym11 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym12 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym13 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable v-header-name  as character no-undo.
define variable v-obj-name     as character no-undo.
define variable v-host-code    like ub.clients.obj-code no-undo.
define variable v-host-name    as character no-undo.
define variable v-water-qnty   like ub.rvs-line.measure-qnty no-undo.
define variable v-delta-el-cnt like ub.rvs-line-pump.state-el-cnt no-undo.
define buffer buf_clients        for ub.clients .
define buffer prev_shift-obj     for ub.shift-obj .
define buffer buf_rvs-doc        for ub.rvs-doc .
define buffer prev_rvs-doc       for ub.rvs-doc .
define buffer buf_rvs-line       for ub.rvs-line .
define buffer buf_rvs-line-pump  for ub.rvs-line-pump .
define buffer prev_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_goods          for ub.goods .
define frame rvs-line-frm
  sym1 space(0)  buf_rvs-line.pl-code            format "99999999999":C14   column-label "1":C14  space(0)
  sym2 space(0)  buf_goods.artic                 format "x(16)"             column-label "2":C16  space(0)
  sym3 space(0)  buf_goods.gds-name              format "x(30)"             column-label "3":C30  space(0)
  sym4 space(0)  buf_rvs-line.brutto-qnty        format ">>,>>>,>>9.999"    column-label "4":C14  space(0)
  sym5 space(0)  v-water-qnty                    format ">>,>>>,>>9.999"    column-label "5":C14  space(0)
  sym6 space(0)  buf_rvs-line.measure-qnty       format ">>,>>>,>>9.999"    column-label "6":C14  space(0)
  sym7 space(0)  buf_rvs-line.state-measure-qnty format ">>,>>>,>>9.999"    column-label "7":C14  space(0)
  sym8 space(0)  buf_rvs-line.density            format ">>>>,>>>,>>9.9<<<" column-label "8":C14  space(0)
  sym9 space(0)  buf_rvs-line.temperature        format "->>>>>>9.<<<"      column-label "9":C9   space(0)
  sym10 space(0) buf_rvs-line.level-total        format ">>,>>>,>>9.999"    column-label "10":C14 space(0)
  sym11 space(0) buf_rvs-line.level-petrol       format ">>,>>>,>>9.999"    column-label "11":C14 space(0)
  sym12 space(0)
  with width 232 down stream-io use-text no-box.
define frame rvs-line-pump-frm
  sym1 space(0)  buf_rvs-line-pump.pump-code     format ">9":C11                 column-label "1":C11  space(0)
  sym2 space(0)  buf_rvs-line-pump.nozzle-code   format ">9":C11                 column-label "2":C11  space(0)
  sym3 space(0)  buf_goods.gds-name              format "x(30)"                  column-label "3":C30  space(0)
  sym4 space(0)  buf_rvs-line-pump.state-el-cnt  format "->,>>>,>>>,>>>,>>9.999" column-label "4":C22  space(0)
  sym5 space(0)  v-delta-el-cnt                  format "->,>>>,>>>,>>>,>>9.999" column-label "5":C22  space(0)
  sym6 space(0)
  with width 232 down stream-io use-text no-box.
assign
  v-line  = fill("-", 179 )
  v-line1 = v-line
.
form header
  v-line skip
  "Продолжение на следующей странице" at 60 skip
  with frame bottomframe
  width 183 page-bottom no-labels no-box .
run waitfram-show in this-procedure
  ( input 'Подождите ...'
  ) .
find first buf_rvs-doc no-lock
  where recid(buf_rvs-doc) = p-recid .
find last prev_shift-obj no-lock
  where prev_shift-obj.obj-type = buf_rvs-doc.obj-type
    and prev_shift-obj.obj-code = buf_rvs-doc.obj-code
    and prev_shift-obj.status_  = 'зкр':U
    and ( prev_shift-obj.shift-date < buf_rvs-doc.shift-date
          or ( prev_shift-obj.shift-date = buf_rvs-doc.shift-date
                and prev_shift-obj.shift-num  < buf_rvs-doc.shift-num
              )
        )
  use-index stts
  no-error.
if available prev_shift-obj then do:
  find first prev_rvs-doc no-lock
    where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
      and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
      and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
      and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
      and prev_rvs-doc.status_    = 'факт':U
      and prev_rvs-doc.rvs-type   = 'смена':U
    no-error.
end.
find first buf_clients no-lock
  where buf_clients.obj-type = buf_rvs-doc.obj-type
    and buf_clients.obj-code = buf_rvs-doc.obj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_rvs-doc.obj-type
  ,input  buf_rvs-doc.obj-code
  ,output v-host-code
  )  .
find first buf_clients no-lock
  where buf_clients.obj-type = 'орг':U
    and buf_clients.obj-code = v-host-code
  .
assign
  v-host-name = buf_clients.obj-name
.
run prn-lib-open-stream in this-procedure
  ( input parparentproc
   ,input 45
   ,input yes
   ,input no
  ).
view stream PrnLibStream frame bottomframe .
assign
  v-header-name = substitute( "П Р О Т О К О Л  С Н Я Т И Я  П О К А З А Н И Й  У Р О В Н Е М Е Р А  № &1", buf_rvs-doc.rvs-code )
.
form header
  "Наименование предприятия:" space(2) v-host-name format "x(120)" skip "АЗС          :" space(2) v-obj-name format "x(120)" skip "Дата смены   :" space(2) buf_rvs-doc.shift-date format "99/99/9999" space(26) v-header-name format "x(120)" skip "Номер смены  :" space(2) buf_rvs-doc.shift-name skip "Порядок смены:" space(2) buf_rvs-doc.shift-num skip "Тип замера   :" space(2) buf_rvs-doc.rvs-type format "x(20)" skip
  "Стр." at 160 string( page-number(PrnLibStream), ">>>9" )  skip
  "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip ":              :                :                              :              :              :    Объем     :              :              :         :   Уровень    :              :" skip ":    Номер     :    Артикул     :      Название товара         :    Объем     :    Объем     : нефтепродукта:    Объем     :   Плотность  :t нефте- :   жидкости   :   Уровень    :" skip ":  резервуара  :                :                              :    общий     : подтоварной  :     факт     : нефтепродукта: нефтепродукта:продукта : в резервуаре : нефтепродукта:" skip ":              :                :                              :     л.       :     воды     :  по приборам : факт. остаток:    г/куб.см  :    С    :    общий     : в резервуаре :" skip ":              :                :                              :              :      л.      :      л.      :      л.      :              :         :      см.     :     см.      :" skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  with frame topframe1
  width 183 page-top no-labels no-box .
form with frame rvs-line-frm .
view stream PrnLibStream frame topframe1 .
for each buf_rvs-line no-lock
  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
:
  find first buf_goods no-lock
    where buf_goods.gds-code = buf_rvs-line.gds-code
  .
  assign
    v-water-qnty = buf_rvs-line.brutto-qnty - buf_rvs-line.measure-qnty
  .
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
          and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
          and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
          and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
          and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
          and rvs-line-attr.attr-code = "pokmi-water-qnty"
  :
    v-water-qnty = decimal(rvs-line-attr.attr-value) .
  end .
  if v-water-qnty = ? then v-water-qnty = 0 .
  if line-counter( PrnLibStream ) + 1 > page-size( PrnLibStream ) then do:
    put stream PrnLibStream v-line1 .
    page stream PrnLibStream .
  end.
  display stream PrnLibStream
    sym1  buf_rvs-line.pl-code
    sym2  buf_goods.artic
    sym3  buf_goods.gds-name
    sym4  buf_rvs-line.brutto-qnty
    sym5  v-water-qnty
    sym6  buf_rvs-line.measure-qnty
    sym7  buf_rvs-line.state-measure-qnty
    sym8  buf_rvs-line.density
    sym9  buf_rvs-line.temperature
    sym10 buf_rvs-line.level-total
    sym11 buf_rvs-line.level-petrol
    sym12
    with frame rvs-line-frm.
  down stream PrnLibStream 1 with frame rvs-line-frm .
end.
hide frame rvs-line-frm .
hide stream PrnLibStream frame Topframe1 .
hide stream PrnLibStream frame bottomframe .
put stream PrnLibStream v-line1 skip(2).
find first buf_rvs-line-pump no-lock
  where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  no-error .
if available buf_rvs-line-pump then do:
  form header
    "Наименование предприятия:" space(2) v-host-name format "x(120)" skip "АЗС          :" space(2) v-obj-name format "x(120)" skip "Дата смены   :" space(2) buf_rvs-doc.shift-date format "99/99/9999" space(26) v-header-name format "x(120)" skip "Номер смены  :" space(2) buf_rvs-doc.shift-name skip "Порядок смены:" space(2) buf_rvs-doc.shift-num skip "Тип замера   :" space(2) buf_rvs-doc.rvs-type format "x(20)" skip
    "Стр." at 90 string( page-number(PrnLibStream), ">>>9" )  skip
    "------------------------------------------------------------------------------------------------------" skip ":   Номер   :   Номер   :      Название товара         :      Показания       :        Оборот        :" skip ":    ТРК    : пистолета :                              :     электронного     :       за смену       :" skip ":           :           :                              :       счетчика       :                      :" skip "------------------------------------------------------------------------------------------------------"
    with frame topframe2
    width 183 page-top no-labels no-box .
  form with frame rvs-line-pump-frm .
  view stream PrnLibStream frame topframe2 .
  view stream PrnLibStream frame bottomframe .
  assign
    v-header-name = substitute( "П Р О Т О К О Л  С Н Я Т И Я  П О К А З А Н И Й  С Ч Е Т Ч И К О В  Т Р К  № &1", buf_rvs-doc.rvs-code )
    v-line1 = fill("-", 102 )
  .
  if line-counter( PrnLibStream ) + 10 > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.
  else do:
    put stream PrnLibStream unformatted
      space (26) v-header-name skip(1)
      "------------------------------------------------------------------------------------------------------" skip ":   Номер   :   Номер   :      Название товара         :      Показания       :        Оборот        :" skip ":    ТРК    : пистолета :                              :     электронного     :       за смену       :" skip ":           :           :                              :       счетчика       :                      :" skip "------------------------------------------------------------------------------------------------------"
      .
  end.
  for each buf_rvs-line-pump no-lock
    where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_rvs-line-pump.gds-code
    .
    assign
      v-delta-el-cnt = ?
    .
    if available prev_rvs-doc then do:
      find first prev_rvs-line-pump no-lock
        where prev_rvs-line-pump.rvs-code    = prev_rvs-doc.rvs-code
          and prev_rvs-line-pump.obj-type    = buf_rvs-line-pump.obj-type
          and prev_rvs-line-pump.obj-code    = buf_rvs-line-pump.obj-code
          and prev_rvs-line-pump.pl-code     = buf_rvs-line-pump.pl-code
          and prev_rvs-line-pump.gds-code    = buf_rvs-line-pump.gds-code
          and prev_rvs-line-pump.pump-code   = buf_rvs-line-pump.pump-code
          and prev_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
        no-error .
      if available prev_rvs-line-pump then do:
        assign
          v-delta-el-cnt = buf_rvs-line-pump.state-el-cnt - prev_rvs-line-pump.state-el-cnt
        .
      end.
    end.
    if line-counter( PrnLibStream ) + 1 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream v-line1 .
      page stream PrnLibStream .
    end.
    display stream PrnLibStream
      sym1  buf_rvs-line-pump.pump-code
      sym2  buf_rvs-line-pump.nozzle-code
      sym3  buf_goods.gds-name
      sym4  buf_rvs-line-pump.state-el-cnt
      sym5  v-delta-el-cnt
      sym6
      with frame rvs-line-pump-frm.
    down stream PrnLibStream 1 with frame rvs-line-pump-frm .
  end.
  hide stream PrnLibStream frame Topframe2 .
  hide stream PrnLibStream frame bottomframe .
  put stream PrnLibStream v-line1 skip.
  hide frame rvs-line-pump-frm .
end.
put stream PrnLibStream unformatted skip space(3) "Оператор___________________________(подпись)".
output stream PrnLibStream close.
run waitfram-hide in this-procedure  .
run prn-lib-prn-file in this-procedure
  ( input parparentproc
   ,input 8
  ).
