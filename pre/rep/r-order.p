block-level on error undo, throw.
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define input parameter parparentproc    as handle no-undo .
define input parameter p-docCode as integer no-undo .
define input parameter p-dbNum as integer no-undo .
define input parameter p-param as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-order.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-order.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов".
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
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define new shared temp-table tt-zakaz like ub.order-line
    field gds-name          as character
    field minZapas          as decimal
    field volMinZapas       as integer
    field ostatokDay        as decimal
    field qntyDaySale       as integer
    field qntyDayGoods      as integer
    field ostatokGoods      as decimal
    field qntyDay           as integer
    field contract-prn-code as character
    field contract-code     as integer
    index pi    gds-code          contract-code
    index artic artic             prod-type         prod-code
    index contr contract-prn-code.
define new shared temp-table temp-gds-qnty no-undo
    field day      as date
    field ost      as decimal
    field gds-code as integer
    index pi is unique primary day gds-code
    index by-ost               ost .
define buffer buf_order-doc  for ub.order-doc .
define buffer buf_order-line for ub.order-line .
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num        as integer   no-undo.
define variable v-report-name       as character no-undo.
define variable v-period            as character no-undo.
define variable vDaySale            as character no-undo .
define variable vGarantDay          as character no-undo .
define variable vDelDayGoods        as logical   no-undo .
define variable periodDay           as character no-undo .
define variable vDateOrder          as date      no-undo .
define stream OutStr-html.
define buffer buf_goods   for ub.goods .
define buffer buf_clients for ub.clients .
define buffer bf_clients  for ub.clients .
find first buf_order-doc no-lock where buf_order-doc.doc-code = p-docCode and
    buf_order-doc.db-num = p-dbNum no-error .
run get-full-path-RepViewer(output v-full-path-RepView).
run get-report-num in parParentProc(output g#report-num).
run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
run create-file(v-file-name-rep-htm).
run waitfram-show in this-procedure ("Подождите ...").
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="zakaz"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .
find first bf_clients no-lock where bf_clients.obj-code = buf_order-doc.obj-code and
    bf_clients.obj-type = buf_order-doc.obj-type no-error .
find first buf_clients no-lock where buf_clients.obj-code = buf_order-doc.cli-code and
    buf_clients.obj-type = buf_order-doc.cli-type no-error .
vDateOrder = date(entry(1,p-param,chr(4))) no-error .
vDaySale = entry(3,p-param,chr(4)) no-error .
vGarantDay = entry(4,p-param,chr(4)) no-error .
periodDay = entry(8,p-param,chr(4)) no-error.
v-period = entry(9,p-param,chr(4)) no-error.
vDelDayGoods = logical(entry(5,p-param,chr(4))) no-error.
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="13" style="text-align: left; font-weight:bold;">Отчет по планированию заказа товаров Магазина и готовой продукции Кафе</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">на ' + string(vDateOrder,"99/99/9999") + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Остаток товара, шт (О)</b> Количество товара на остатке в штуках на текущий момент (4).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">объект: ' + bf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Продажи за период, шт (Vпр)</b> Количество продаж товара (с учетом возвратов) за выбранный период (5).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">контрагент: ' + buf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Среднесуточные продажи за период, шт (Тпр)</b> Среднесуточное количество проданного товара за выбранный период времени Тпр = Vпр / P, где Р – период продаж в днях (6).</td>' skip
    '</tr>' skip
    .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">заказ формируется на : ' + string(vDaySale) + ' дней(дня), с учетом гарантийного запаса на ' + string(vGarantDay) + ' дней(дня)</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт (Vзг)</b> Vзг = Vз + М + G  (7).</td>' skip
    '</tr>' skip .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">период анализа : ' + string(periodDay) + ' дней(дня) ' + v-period + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Запас товара, в днях (Од)</b> Количество дней, на которое должно хватить остатков товара на текущий момент с учетом среднесуточных продаж за период Од = О / Тпр (8).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    .
if vDelDayGoods then
do:
    put stream OutStr-html unformatted
        '<td colspan="5" text_wrap="true" style="text-align: left;">исключены дни, когда товара не было на остатках</td>' skip
        .
end.
else
do:
    put stream OutStr-html unformatted
        '<td colspan="5" style="text-align: left;"></td>' skip
        .
end.
put stream OutStr-html unformatted
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Расчетный объем заказа с учетом темпа продаж, шт (Vз)</b> Vз = Тпр * Q - Ост, где Q – период, на который формируется заказ в днях,</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">если Ост < 0, то при расчете Ост не учитывается. Ост – Остаток товара на день заказа: Ост = О - (Dз-D) * Тпр, где Dз – дата заказа, D – текущая дата (9).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><strong>Расчетный объем заказа с учетом минимального запаса,шт (Vзм)</strong> Vзм = Vз + М  (10).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Минимальный запас, шт (М)</b> Количество товара, необходимое для выкладки (11). </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Гарантийный запас, шт (G)</b> G = S * Тпр, где   S – гарантийный запас в днях (12).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Товар участвует в промоакции</b> Участие товара в промоакции в статусе «Активная» в ТН на момент формирования отчета. </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">Информация справочная, необходимо учитывать при подтверждении заказа (13).</td>' skip
    '</tr>' skip
    '<tr height:15px;  style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left;"></td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>* При расчете не учитываются сроки годности и движение рецептурных товаров</b></td>' skip
    '</tr>' skip
    .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
    .
put stream OutStr-html unformatted
    '     <tbody>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Код ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Артикул ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование товара</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Остаток товара, шт.<br>(О)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Продажи за период, шт.<br>(Vпр)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Среднесуточные продажи за период, шт.<br>(Тпр)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px; background-color: silver;">Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт.<br>(Vзг)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Запас товара, в днях<br>(Од)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом темпа продаж, шт.<br>(Vз)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом минимального запаса, шт.<br>(Vзм)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Минимальный запас, шт.<br>(М)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Гарантийный запас, шт.<br>(G)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Товар участвует в промоакции</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th colspan="3" style="text-align: center;  font-weight:bold; background-color: silver;">ФАКТИЧЕСКИЕ ДАННЫЕ</th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;">ЗАКАЗ</th>' skip
    '         <th colspan="6" style="text-align: center;  font-weight:bold; background-color: silver;">СПРАВОЧНАЯ ИНФОРМАЦИЯ</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">9</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">10</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">11</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">12</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">13</th>' skip
    '       </tr>' skip
    .
put stream OutStr-html unformatted
    '     <tbody>' skip
    .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="13" style="text-align: left; font-weight:bold;"><br>' + if buf_order-doc.contract-prn-code = "" then '   БЕЗ ДОГОВОРА</td>' else '   ' + buf_order-doc.contract-prn-code + '<br></td>' skip
    '</tr>' skip
    .
for each buf_order-line no-lock where buf_order-line.doc-code = buf_order-doc.doc-code and
    buf_order-line.db-num = buf_order-line.db-num:
    find first tt-zakaz no-lock where tt-zakaz.gds-code = buf_order-line.gds-code no-error .
    if available (tt-zakaz) then next .
    find first buf_goods no-lock where buf_goods.gds-code = buf_order-line.gds-code no-error .
    put stream OutStr-html unformatted
        '       <tr style="font-size:11px;">' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.gds-code) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.artic) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_goods.gds-name) + '</td>' skip
        '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(buf_order-line.rest,"->>>>>>>>>>>>>9",0) + '"  style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.rest,"->>>>>>>>>>>9",0) + '</td>' skip
        '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(buf_order-line.sales,"->>>>>>>>>>>>>9.",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.sales,"->>>>>>>>>>>>>9",0) + '</td>' skip
        '         <td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(buf_order-line.average-sales,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.average-sales,"->>>>>>>>>>>>>9.9",1) + '</TD>' skip
        '         <td text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px;">' + string(buf_order-line.order-qnty) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.stock-goods) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.volume-goods) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.volume-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.min-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.garant-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + (if buf_order-line.promo then "да" else "нет") + '</td>' skip
        '       </tr>' skip
        .
end.
run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
    os-command no-wait value(p-full-path-RepView + " " + search(p-file-name-rep-htm)).
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
