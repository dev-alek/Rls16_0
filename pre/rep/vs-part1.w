define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter from-date as date no-undo .
define input parameter to-date as date no-undo .
define input parameter gds-art as char no-undo.
define input parameter num-doc as char no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define   shared temp-table sup-gds no-undo
    field artic          like ub.goods.artic
    field prod-type      like ub.clients.obj-type
    field prod-code      like ub.clients.obj-code
    field gds-name       like ub.goods.gds-name
    field unit-base      like ub.goods.unit-base
    field s-pay-type     as character
    field in-qnty        like ub.parts.fact-qnty
    field in-nds0-rubl   like ub.parts.price-rubl
    field in-nds0-base   like ub.parts.price-base
    field in-sum0-rubl   like ub.parts.price-rubl
    field in-sum0-base   like ub.parts.price-base
    field in-nds-rubl    like ub.parts.price-rubl
    field in-nds-base    like ub.parts.price-base
    field in-sum-rubl    like ub.parts.price-rubl
    field in-sum-base    like ub.parts.price-base
    field out-qnty       like ub.parts.fact-qnty
    field out-nds0-rubl  like ub.parts.price-rubl
    field out-nds0-base  like ub.parts.price-base
    field out-sum0-rubl  like ub.parts.price-rubl
    field out-sum0-base  like ub.parts.price-base
    field out-nds-rubl   like ub.parts.price-rubl
    field out-nds-base   like ub.parts.price-base
    field out-sum-rubl   like ub.parts.price-rubl
    field out-sum-base   like ub.parts.price-base
    field free-qnty      like ub.parts.fact-qnty
    field free-nds0-rubl like ub.parts.price-rubl
    field free-nds0-base like ub.parts.price-base
    field free-sum0-rubl like ub.parts.price-rubl
    field free-sum0-base like ub.parts.price-base
    field free-nds-rubl  like ub.parts.price-rubl
    field free-nds-base  like ub.parts.price-base
    field free-sum-rubl  like ub.parts.price-rubl
    field free-sum-base  like ub.parts.price-base
    field price-sale     as decimal
    field qnty-sale      as integer
    field fs-date        as date
    field ls-date        as date
    index art is primary artic prod-type prod-code s-pay-type ascending
    .
define   shared buffer suppl-gds for sup-gds.
define new shared temp-table sup-parts no-undo
    field artic             like ub.goods.artic
    field prod-type         like ub.clients.obj-type
    field prod-code         like ub.clients.obj-code
    field gds-code          like ub.goods.gds-code
    field gds-name          like ub.goods.gds-name
    field doc-type          like ub.parts.doc-type
    field in-code           like ub.parts.in-code
    field out-code          like ub.parts.out-code
    field fact-date         like ub.parts.fact-date
    field price-cli         like ub.parts.price-cli
    field price0-base       like ub.parts.price-base
    field price0-rubl       like ub.parts.price-rubl
    field price-base        like ub.parts.price-base
    field price-rubl        like ub.parts.price-rubl
    field obj-type          like ub.parts.obj-type
    field obj-code          like ub.parts.obj-code
    field part-code         like ub.parts.part-code
    field in-qnty           like ub.parts.fact-qnty
    field in-sum-cli        like ub.parts.price-cli
    field in-nds0-rubl      like ub.parts.price-rubl
    field in-nds0-base      like ub.parts.price-base
    field in-sum0-rubl      like ub.parts.price-rubl
    field in-sum0-base      like ub.parts.price-base
    field in-nds-rubl       like ub.parts.price-rubl
    field in-nds-base       like ub.parts.price-base
    field in-sum-rubl       like ub.parts.price-rubl
    field in-sum-base       like ub.parts.price-base
    field out-qnty          like ub.parts.fact-qnty
    field out-sum-cli       like ub.parts.price-cli
    field out-nds0-rubl     like ub.parts.price-rubl
    field out-nds0-base     like ub.parts.price-base
    field out-sum0-rubl     like ub.parts.price-rubl
    field out-sum0-base     like ub.parts.price-base
    field out-nds-rubl      like ub.parts.price-rubl
    field out-nds-base      like ub.parts.price-base
    field out-sum-rubl      like ub.parts.price-rubl
    field out-sum-base      like ub.parts.price-base
    field free-qnty         like ub.parts.fact-qnty
    field free-sum-cli      like ub.parts.price-cli
    field free-nds0-rubl    like ub.parts.price-rubl
    field free-nds0-base    like ub.parts.price-base
    field free-sum0-rubl    like ub.parts.price-rubl
    field free-sum0-base    like ub.parts.price-base
    field free-nds-rubl     like ub.parts.price-rubl
    field free-nds-base     like ub.parts.price-base
    field free-sum-rubl     like ub.parts.price-rubl
    field free-sum-base     like ub.parts.price-base
    field p-in-qnty         like ub.parts.fact-qnty
    field p-in-sum-cli      like ub.parts.price-cli
    field p-in-nds0-rubl    like ub.parts.price-rubl
    field p-in-nds0-base    like ub.parts.price-base
    field p-in-sum0-rubl    like ub.parts.price-rubl
    field p-in-sum0-base    like ub.parts.price-base
    field p-in-nds-rubl     like ub.parts.price-rubl
    field p-in-nds-base     like ub.parts.price-base
    field p-in-sum-rubl     like ub.parts.price-rubl
    field p-in-sum-base     like ub.parts.price-base
    field qnty-sale         as integer
    field fs-date           as date
    field ls-date           as date
    field num-doc           as character
    index f-date is primary fact-date ascending
    .
define new shared buffer suppl-parts for sup-parts.
define   shared buffer supplier    for ub.clients.
define   shared buffer b-parts     for ub.parts.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable  fr-title as char no-undo.
define variable  prev-exch-code like ub.parts.exch-code init ? no-undo.
define variable  cli-val as char init "руб" no-undo.
define variable var-report-r-b as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
DEFINE SUB-MENU m-cycle
       MENU-ITEM m-cycle-rubl   LABEL "в abbr_rublyah"
       MENU-ITEM m-cycle-base   LABEL "в базовой валюте"
       MENU-ITEM m-cycle-cli    LABEL "в валюте поставщика".
DEFINE MENU POPUP-MENU-b-print
       SUB-MENU  m-cycle        LABEL "Оборот по поставщику"
       MENU-ITEM m-order        LABEL "Отчет для заказа товаров".
DEFINE BUTTON b-docs DEFAULT
     LABEL "&Обороты"
     SIZE 10 BY 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помощь"
     SIZE 10 BY 1.
DEFINE BUTTON b-print DEFAULT
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE tot-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-free-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-free-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-in-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     LABEL "кол-во"
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-in-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     LABEL "сумма (б.вал)"
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-in-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     LABEL "сумма (abbr_rub)"
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-out-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-out-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-out-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY br-parts FOR
      suppl-parts,
      ub.goods SCROLLING.
DEFINE BROWSE br-parts
  QUERY br-parts DISPLAY
      suppl-parts.gds-name COLUMN-LABEL "Название товара! "
suppl-parts.in-code COLUMN-LABEL "№ ПН! "
suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/9999"
suppl-parts.in-qnty COLUMN-LABEL "Приход! количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.in-sum0-rubl COLUMN-LABEL "Приход сумма!уч. цен (руб)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.in-sum0-base COLUMN-LABEL "Приход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.in-sum0-base COLUMN-LABEL "Приход сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-qnty COLUMN-LABEL "Расход!количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.out-sum0-rubl COLUMN-LABEL "Расход сумма!уч. цен (руб)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-sum0-base COLUMN-LABEL "Расход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-sum-cli COLUMN-LABEL "Расход сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-qnty COLUMN-LABEL "Остаток!количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.free-sum0-rubl COLUMN-LABEL "Остаток сумма!уч. цен (руб)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-sum0-base COLUMN-LABEL "Остаток сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-sum-cli COLUMN-LABEL "Остаток сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.price0-rubl COLUMN-LABEL "Учетная!цена (руб)"
suppl-parts.price0-base COLUMN-LABEL "Учетная!цена (б.вал)"
suppl-parts.qnty-sale COLUMN-LABEL "Кол-во дней!продаж" FORMAT "->,>>>,>>9"
(suppl-parts.ls-date - suppl-parts.fs-date) COLUMN-LABEL "Период!продаж" FORMAT "->,>>>,>>9"
(suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date) ) COLUMN-LABEL "Средние!продажи" FORMAT "->>>>>9.<<<"
(suppl-parts.free-qnty / (suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date))) COLUMN-LABEL "Обеспе-!ченность" FORMAT "->>>>>9."
(if suppl-parts.part-code = "" then "------" else suppl-parts.part-code) COLUMN-LABEL "Партия! " FORMAT "x(14)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 17.17.
DEFINE FRAME vs-parts
     b-quit AT ROW 1.17 COL 2
     b-print AT ROW 1.17 COL 12
     b-docs AT ROW 1.17 COL 22
     b-help AT ROW 1.17 COL 88.5
     br-parts AT ROW 2.5 COL 2
     tot-in-qnty AT ROW 20.83 COL 18.5 COLON-ALIGNED
     tot-out-qnty AT ROW 20.83 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-qnty AT ROW 20.83 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-rubl AT ROW 22 COL 18.5 COLON-ALIGNED
     tot-out-sum0-rubl AT ROW 22 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-rubl AT ROW 22 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-base AT ROW 23.17 COL 18.5 COLON-ALIGNED
     tot-out-sum0-base AT ROW 23.17 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-base AT ROW 23.17 COL 72.5 COLON-ALIGNED NO-LABEL
     "Приход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 25.5
     "Остаток" VIEW-AS TEXT
          SIZE 10 BY .63 AT ROW 20 COL 77.5
     "Расход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 51
     SPACE(40.36) SKIP(4.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "отчет по поставщику".
ASSIGN
       FRAME vs-parts:SCROLLABLE       = FALSE
       FRAME vs-parts:HIDDEN           = TRUE.
ASSIGN
       b-print:MANUAL-HIGHLIGHT IN FRAME vs-parts = TRUE
       b-print:POPUP-MENU IN FRAME vs-parts       = MENU POPUP-MENU-b-print:HANDLE.
ON WINDOW-CLOSE OF FRAME vs-parts
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-docs IN FRAME vs-parts
DO:
  if available suppl-parts then
      run rep/vs-cust1.w (
                     input parparentproc
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input from-date
                    ,input to-date).
  APPLY "ENTRY" TO BROWSE br-parts.
END.
ON CHOOSE OF b-print IN FRAME vs-parts
DO:
    run gbl/pop-up.p (self:handle, no) NO-ERROR.
END.
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME vs-parts
DO:
  APPLY "CHOOSE" TO b-docs IN FRAME vs-parts.
END.
ON RETURN OF br-parts IN FRAME vs-parts
DO:
  APPLY "CHOOSE" TO b-docs IN FRAME vs-parts.
END.
ON CHOOSE OF MENU-ITEM m-cycle-base
DO:
  RUN print-cycle ("base").
END.
ON CHOOSE OF MENU-ITEM m-cycle-cli
DO:
  if prev-exch-code = ? then
      message "Отчет не может быть напечатан!" SKIP
                      "Т.к. были приходы от данного поставщика" SKIP
                      "за данный период в разных валютах." view-as alert-box ERROR.
  else
      do:
          FIND ub.currency WHERE ub.currency.curr-code = prev-exch-code NO-LOCK.
          assign cli-val = ub.currency.curr-abbr.
          RUN print-cycle ("cli").
      end.
END.
ON CHOOSE OF MENU-ITEM m-cycle-rubl
DO:
  RUN print-cycle ("rubl").
END.
ON CHOOSE OF MENU-ITEM m-order
DO:
  run print-order.
  APPLY "ENTRY" TO BROWSE br-parts.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME vs-parts:PARENT eq ?
THEN FRAME vs-parts:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame vs-parts
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
on choose of b-help in frame vs-parts
do:
  apply "help":u to frame vs-parts .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame vs-parts:width - 0.3
                fh            = frame vs-parts:first-child
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame vs-parts :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame vs-parts :height-chars)
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
    if frame vs-parts :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame vs-parts :height-chars)
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
            frame vs-parts :height = v-frame-height
          .
          if frame vs-parts :scrollable = true
          then do:
            assign
              frame vs-parts :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame vs-parts :scrollable = true
          then do:
            assign
              frame vs-parts :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame vs-parts :height = v-frame-height
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
      v-frame-height = frame vs-parts :height
      v-frame-virtual-height = frame vs-parts :virtual-height
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
      v-field-group-handle = frame vs-parts :first-child
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
    do with frame vs-parts
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame vs-parts :scrollable = true
      then do:
        assign
          frame vs-parts :virtual-height = frame vs-parts :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame vs-parts :height = frame vs-parts :height + p-change-value
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
        frame vs-parts :height = frame vs-parts :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame vs-parts :scrollable = true
      then do:
        assign
          frame vs-parts :virtual-height = frame vs-parts :virtual-height + p-change-value
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
          ,input  string(frame vs-parts :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame vs-parts :height)
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
    if frame vs-parts :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame vs-parts :width
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
    if frame vs-parts :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame vs-parts :width
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
            frame vs-parts :width = v-frame-width
          .
          if frame vs-parts :scrollable = true
          then do:
            assign
              frame vs-parts :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame vs-parts :scrollable = true
          then do:
            assign
              frame vs-parts :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame vs-parts :width = v-frame-width
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
      v-frame-width = frame vs-parts :width
      v-frame-virtual-width = frame vs-parts :virtual-width
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
      v-field-group-handle = frame vs-parts :first-child
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
    do with frame vs-parts
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame vs-parts :scrollable = true
      then do:
        assign
          frame vs-parts :virtual-width = frame vs-parts :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame vs-parts :width = v-frame-width + p-change-value
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
        frame vs-parts :width = frame vs-parts :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame vs-parts :scrollable = true
      then do:
        assign
          frame vs-parts :virtual-width = frame vs-parts :virtual-width + p-change-value
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
          ,input  string(frame vs-parts :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame vs-parts :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame vs-parts
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame vs-parts :height - v-diasize-resize-button :height
                  - 1
                  - (frame vs-parts :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame vs-parts :width - v-diasize-resize-button :width
                  - 1
                  - (frame vs-parts :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame vs-parts
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
      v-row-delta = v-new-row - frame vs-parts :height
      v-col-delta = v-new-col - frame vs-parts :width
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
            - frame vs-parts :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame vs-parts :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame vs-parts :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame vs-parts :height-chars
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
      v-diasize-current-frame-width  = frame vs-parts :width
      v-diasize-current-frame-height = frame vs-parts :height
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
    do with frame vs-parts
    :
      assign
        v-diasize-orig-frame-height = frame vs-parts :height
        v-diasize-orig-frame-width  = frame vs-parts :width
        v-diasize-browse-handle     = browse br-parts :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame vs-parts :first-child
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
  RUN calc.
  assign
  MENU-ITEM m-cycle-rubl:label in menu m-cycle = "в рублях"
  tot-in-sum0-rubl:label = "сумма (руб)"
  .
  RUN enable_UI.
  assign b-print:MENU-MOUSE = 1.
  if gds-art = "" then
      FRAME vs-parts:TITLE = string( "Приходные партии товара: " +
                                                                        suppl-gds.artic + " " + suppl-gds.gds-name ).
  else
      do:
          if num-doc = "" then
              FRAME vs-parts:TITLE = string( "Поставки с: " + string(from-date,"99/99/9999") +
                                                                                " по: " + string(to-date,"99/99/9999") +
                                                                                " Поставщик: " + supplier.obj-name +
                                                                                " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" ).
          else
              do:
                  find ub.trn-doc where ub.trn-doc.doc-code = num-doc no-lock.
                  FRAME vs-parts:TITLE = string( "Поставки по документу: " + num-doc + " от " + string( ub.trn-doc.fact-date, "99/99/9999" ) ).
              end.
      end.
  apply "entry" to br-parts in frame vs-parts.
  WAIT-FOR GO OF FRAME vs-parts.
END.
RUN disable_UI.
PROCEDURE calc :
define buffer    b-parts    for ub.parts.
define variable  out-qnty  like ub.parts.fact-qnty no-undo.
define variable  free-qnty like ub.parts.fact-qnty no-undo.
define variable  qnty_sale like suppl-gds.qnty-sale no-undo.
define variable  f-date as date no-undo.
define variable  l-date as date no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure ("Подождите...").
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
if gds-art = "" then do:
    for each ub.parts where ub.parts.host-code = v-host-code
        and ub.parts.artic = suppl-gds.artic
        and ub.parts.prod-type = suppl-gds.prod-type
        and ub.parts.prod-code = suppl-gds.prod-code
        and ub.parts.supp-type = supplier.obj-type
        and ub.parts.supp-code = supplier.obj-code
        and ub.parts.status_ = yes
        and ub.parts.fact-date >= from-date
        and ub.parts.fact-date <= to-date
        and ub.parts.out-code = ub.parts.in-code
        no-lock break by ub.parts.fact-date:
  find ub.goods where
      ub.goods.artic = ub.parts.artic
  and ub.goods.prod-type = ub.parts.prod-type
  and ub.goods.prod-code = ub.parts.prod-code
  no-lock.
assign
    l-date = ub.parts.fact-date
    qnty_sale = 0
    .
if FIRST( ub.parts.fact-date ) then
    assign prev-exch-code = ub.parts.exch-code.
if prev-exch-code <> ? and prev-exch-code <> ub.parts.exch-code then
    assign prev-exch-code = ?.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = yes
                                            AND b-parts.doc-type = 'рас':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
     EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = no NO-LOCK
                                            BREAK BY b-parts.fact-date:
    if LAST-OF( b-parts.fact-date ) then
        assign qnty_sale = qnty_sale + 1.
    if LAST( b-parts.fact-date ) AND l-date - 1 < b-parts.fact-date then
        assign l-date = b-parts.fact-date + 1.
END.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                     AND b-parts.prod-type = ub.parts.prod-type
                     AND b-parts.prod-code = ub.parts.prod-code
                     AND b-parts.out-code = 'out-zone':U
                     NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                     :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign out-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                       AND b-parts.prod-type = ub.parts.prod-type
                       AND b-parts.prod-code = ub.parts.prod-code
                       AND b-parts.rsrv-free = yes
                       NO-LOCK  ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                       :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'при':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'возврат':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
if free-qnty > 0 then
    assign l-date = TODAY + 1.
assign
  price-rubl-with-tax-loc = ub.parts.price-rubl
  price-base-with-tax-loc = ub.parts.price-base
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = ub.parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = ub.parts.price-cli
   cli-base-rate          = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc  = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc     = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc     = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc         = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc         = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (ub.parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / ub.parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
ACCUMULATE
    ub.parts.fact-qnty (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-rubl (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-base (TOTAL)
    out-qnty (TOTAL)
    out-qnty * ub.parts.price-rubl (TOTAL)
    out-qnty * ub.parts.price-base (TOTAL)
    free-qnty (TOTAL)
    free-qnty * vat-rubl-loc (TOTAL)
    free-qnty * vat-base-loc (TOTAL)
    free-qnty * price-rubl-with-tax-loc (TOTAL)
    free-qnty * price-base-with-tax-loc (TOTAL)
    .
CREATE suppl-parts.
assign
    suppl-parts.num-doc = num-doc
    suppl-parts.artic = ub.parts.artic
    suppl-parts.prod-type = ub.parts.prod-type
    suppl-parts.prod-code = ub.parts.prod-code
    suppl-parts.gds-code = ub.goods.gds-code
    suppl-parts.gds-name = ub.goods.gds-name
    suppl-parts.doc-type = ub.parts.doc-type
    suppl-parts.in-code = ub.parts.in-code
    suppl-parts.out-code = ub.parts.out-code
    suppl-parts.fact-date = ub.parts.fact-date
    suppl-parts.price0-base = ub.parts.price-base
    suppl-parts.price0-rubl = ub.parts.price-rubl
    suppl-parts.price-cli = ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.obj-type = ub.parts.obj-type
    suppl-parts.obj-code = ub.parts.obj-code
    suppl-parts.part-code = ub.parts.part-code
    suppl-parts.in-qnty = ub.parts.fact-qnty
    suppl-parts.in-sum0-rubl = ub.parts.fact-qnty * ub.parts.price-rubl
    suppl-parts.in-sum0-base = ub.parts.fact-qnty * ub.parts.price-base
    suppl-parts.in-sum-cli = ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * ub.parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * ub.parts.price-base
    suppl-parts.out-sum-cli = out-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-NDS0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-NDS0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = ub.parts.fact-date
    suppl-parts.ls-date = l-date
    .
    end.
end.
else do:
    if num-doc = "" then do:
        FOR EACH ub.parts WHERE ub.parts.host-code = v-host-code
              AND ub.parts.supp-type = supplier.obj-type
              AND ub.parts.supp-code = supplier.obj-code
              AND ub.parts.status_ = yes
              AND ub.parts.fact-date >= from-date
              AND ub.parts.fact-date <= to-date
              AND ub.parts.out-code = ub.parts.in-code
              NO-LOCK BREAK BY ub.parts.fact-date:
  find ub.goods where
      ub.goods.artic = ub.parts.artic
  and ub.goods.prod-type = ub.parts.prod-type
  and ub.goods.prod-code = ub.parts.prod-code
  no-lock.
assign
    l-date = ub.parts.fact-date
    qnty_sale = 0
    .
if FIRST( ub.parts.fact-date ) then
    assign prev-exch-code = ub.parts.exch-code.
if prev-exch-code <> ? and prev-exch-code <> ub.parts.exch-code then
    assign prev-exch-code = ?.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = yes
                                            AND b-parts.doc-type = 'рас':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
     EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = no NO-LOCK
                                            BREAK BY b-parts.fact-date:
    if LAST-OF( b-parts.fact-date ) then
        assign qnty_sale = qnty_sale + 1.
    if LAST( b-parts.fact-date ) AND l-date - 1 < b-parts.fact-date then
        assign l-date = b-parts.fact-date + 1.
END.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                     AND b-parts.prod-type = ub.parts.prod-type
                     AND b-parts.prod-code = ub.parts.prod-code
                     AND b-parts.out-code = 'out-zone':U
                     NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                     :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign out-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                       AND b-parts.prod-type = ub.parts.prod-type
                       AND b-parts.prod-code = ub.parts.prod-code
                       AND b-parts.rsrv-free = yes
                       NO-LOCK  ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                       :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'при':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'возврат':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
if free-qnty > 0 then
    assign l-date = TODAY + 1.
assign
  price-rubl-with-tax-loc = ub.parts.price-rubl
  price-base-with-tax-loc = ub.parts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = ub.parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = ub.parts.price-cli
   cli-base-rate          = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc  = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc     = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc     = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc         = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc         = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (ub.parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / ub.parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
ACCUMULATE
    ub.parts.fact-qnty (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-rubl (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-base (TOTAL)
    out-qnty (TOTAL)
    out-qnty * ub.parts.price-rubl (TOTAL)
    out-qnty * ub.parts.price-base (TOTAL)
    free-qnty (TOTAL)
    free-qnty * vat-rubl-loc (TOTAL)
    free-qnty * vat-base-loc (TOTAL)
    free-qnty * price-rubl-with-tax-loc (TOTAL)
    free-qnty * price-base-with-tax-loc (TOTAL)
    .
CREATE suppl-parts.
assign
    suppl-parts.num-doc = num-doc
    suppl-parts.artic = ub.parts.artic
    suppl-parts.prod-type = ub.parts.prod-type
    suppl-parts.prod-code = ub.parts.prod-code
    suppl-parts.gds-code = ub.goods.gds-code
    suppl-parts.gds-name = ub.goods.gds-name
    suppl-parts.doc-type = ub.parts.doc-type
    suppl-parts.in-code = ub.parts.in-code
    suppl-parts.out-code = ub.parts.out-code
    suppl-parts.fact-date = ub.parts.fact-date
    suppl-parts.price0-base = ub.parts.price-base
    suppl-parts.price0-rubl = ub.parts.price-rubl
    suppl-parts.price-cli = ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.obj-type = ub.parts.obj-type
    suppl-parts.obj-code = ub.parts.obj-code
    suppl-parts.part-code = ub.parts.part-code
    suppl-parts.in-qnty = ub.parts.fact-qnty
    suppl-parts.in-sum0-rubl = ub.parts.fact-qnty * ub.parts.price-rubl
    suppl-parts.in-sum0-base = ub.parts.fact-qnty * ub.parts.price-base
    suppl-parts.in-sum-cli = ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * ub.parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * ub.parts.price-base
    suppl-parts.out-sum-cli = out-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-NDS0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-NDS0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = ub.parts.fact-date
    suppl-parts.ls-date = l-date
    .
        end.
    end.
    else do:
        for each ub.parts where
                  ub.parts.host-code = v-host-code
              and ub.parts.supp-type = supplier.obj-type
              and ub.parts.supp-code = supplier.obj-code
              and ub.parts.status_   = yes
              and ub.parts.out-code  = ub.parts.in-code
              and ub.parts.out-code  = num-doc
            no-lock break by ub.parts.fact-date:
  find ub.goods where
      ub.goods.artic = ub.parts.artic
  and ub.goods.prod-type = ub.parts.prod-type
  and ub.goods.prod-code = ub.parts.prod-code
  no-lock.
assign
    l-date = ub.parts.fact-date
    qnty_sale = 0
    .
if FIRST( ub.parts.fact-date ) then
    assign prev-exch-code = ub.parts.exch-code.
if prev-exch-code <> ? and prev-exch-code <> ub.parts.exch-code then
    assign prev-exch-code = ?.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = yes
                                            AND b-parts.doc-type = 'рас':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
     EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = no NO-LOCK
                                            BREAK BY b-parts.fact-date:
    if LAST-OF( b-parts.fact-date ) then
        assign qnty_sale = qnty_sale + 1.
    if LAST( b-parts.fact-date ) AND l-date - 1 < b-parts.fact-date then
        assign l-date = b-parts.fact-date + 1.
END.
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                     AND b-parts.prod-type = ub.parts.prod-type
                     AND b-parts.prod-code = ub.parts.prod-code
                     AND b-parts.out-code = 'out-zone':U
                     NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                     :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign out-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                       AND b-parts.prod-type = ub.parts.prod-type
                       AND b-parts.prod-code = ub.parts.prod-code
                       AND b-parts.rsrv-free = yes
                       NO-LOCK  ,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock
                       :
    ACCUMULATE b-parts.fact-qnty (TOTAL).
END.
assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'при':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
FOR EACH b-parts WHERE b-parts.artic = ub.parts.artic
                                            AND b-parts.prod-type = ub.parts.prod-type
                                            AND b-parts.prod-code = ub.parts.prod-code
                                            AND b-parts.status_ = no
                                            AND b-parts.doc-type = 'возврат':U NO-LOCK,
    each  ub.parts-attr where
          ub.parts-attr.gds-code  = ub.goods.gds-code and
          ub.parts-attr.in-code   = b-parts.in-code and
          ub.parts-attr.part-code = b-parts.part-code and
          ub.parts-attr.income-in-code = num-doc no-lock ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = b-parts.out-code
                                            AND ub.trn-doc.internal = yes NO-LOCK:
    ACCUMULATE b-parts.qnty (TOTAL).
END.
assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
if free-qnty > 0 then
    assign l-date = TODAY + 1.
assign
  price-rubl-with-tax-loc = ub.parts.price-rubl
  price-base-with-tax-loc = ub.parts.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = ub.parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = ub.parts.price-cli
   cli-base-rate          = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc  = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc     = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc     = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc         = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc         = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (ub.parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / ub.parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
ACCUMULATE
    ub.parts.fact-qnty (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-rubl (TOTAL)
    ub.parts.fact-qnty * ub.parts.price-base (TOTAL)
    out-qnty (TOTAL)
    out-qnty * ub.parts.price-rubl (TOTAL)
    out-qnty * ub.parts.price-base (TOTAL)
    free-qnty (TOTAL)
    free-qnty * vat-rubl-loc (TOTAL)
    free-qnty * vat-base-loc (TOTAL)
    free-qnty * price-rubl-with-tax-loc (TOTAL)
    free-qnty * price-base-with-tax-loc (TOTAL)
    .
CREATE suppl-parts.
assign
    suppl-parts.num-doc = num-doc
    suppl-parts.artic = ub.parts.artic
    suppl-parts.prod-type = ub.parts.prod-type
    suppl-parts.prod-code = ub.parts.prod-code
    suppl-parts.gds-code = ub.goods.gds-code
    suppl-parts.gds-name = ub.goods.gds-name
    suppl-parts.doc-type = ub.parts.doc-type
    suppl-parts.in-code = ub.parts.in-code
    suppl-parts.out-code = ub.parts.out-code
    suppl-parts.fact-date = ub.parts.fact-date
    suppl-parts.price0-base = ub.parts.price-base
    suppl-parts.price0-rubl = ub.parts.price-rubl
    suppl-parts.price-cli = ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.obj-type = ub.parts.obj-type
    suppl-parts.obj-code = ub.parts.obj-code
    suppl-parts.part-code = ub.parts.part-code
    suppl-parts.in-qnty = ub.parts.fact-qnty
    suppl-parts.in-sum0-rubl = ub.parts.fact-qnty * ub.parts.price-rubl
    suppl-parts.in-sum0-base = ub.parts.fact-qnty * ub.parts.price-base
    suppl-parts.in-sum-cli = ub.parts.fact-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * ub.parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * ub.parts.price-base
    suppl-parts.out-sum-cli = out-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-NDS0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-NDS0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * ub.parts.price-cli / ub.parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = ub.parts.fact-date
    suppl-parts.ls-date = l-date
    .
        end.
    end.
end.
assign
    tot-in-qnty = (ACCUM TOTAL ub.parts.fact-qnty)
    tot-in-sum0-rubl = (ACCUM TOTAL ub.parts.fact-qnty * ub.parts.price-rubl)
    tot-in-sum0-base = (ACCUM TOTAL ub.parts.fact-qnty * ub.parts.price-base)
    tot-out-qnty = (ACCUM TOTAL out-qnty)
    tot-out-sum0-rubl = (ACCUM TOTAL out-qnty * ub.parts.price-rubl)
    tot-out-sum0-base = (ACCUM TOTAL out-qnty * ub.parts.price-base)
    tot-free-qnty = (ACCUM TOTAL free-qnty)
    tot-free-sum0-rubl = (ACCUM TOTAL free-qnty * price-rubl-with-tax-loc)
    tot-free-sum0-base = (ACCUM TOTAL free-qnty * price-base-with-tax-loc)
    .
if session:set-wait-state("") then.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME vs-parts.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tot-in-qnty tot-out-qnty tot-free-qnty tot-in-sum0-rubl
          tot-out-sum0-rubl tot-free-sum0-rubl tot-in-sum0-base
          tot-out-sum0-base tot-free-sum0-base
      WITH FRAME vs-parts.
  ENABLE b-quit b-print b-docs b-help br-parts
      WITH FRAME vs-parts.
  VIEW FRAME vs-parts.
  OPEN QUERY br-parts FOR EACH suppl-parts NO-LOCK,            EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic                      AND ub.goods.prod-type = suppl-parts.prod-type                      AND ub.goods.prod-code = suppl-parts.prod-code NO-LOCK     BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY ub.goods.grp-name BY suppl-parts.in-code.
END PROCEDURE.
PROCEDURE print-cycle :
    define input parameter val-type as char no-undo.
    define variable  object as char no-undo.
    define variable  PartCode LIKE ub.parts.part-code no-undo.
    define variable  price0 LIKE ub.parts.price-rubl no-undo.
    define variable  in-sum0 LIKE ub.parts.price-rubl no-undo.
    define variable  out-sum0 LIKE ub.parts.price-rubl no-undo.
    define variable  free-sum0 LIKE ub.parts.price-rubl no-undo.
    define variable  sym1 as char init ":"   no-undo.
    define variable  sym2 as char init ":"   no-undo.
    define variable  sym3 as char init ":"   no-undo.
    define variable  sym4 as char init ":"   no-undo.
    define variable  sym5 as char init ":"   no-undo.
    define variable  sym6 as char init ":"   no-undo.
    define variable  sym7 as char init ":"   no-undo.
    define variable  sym8 as char init ":"   no-undo.
    define variable  sym9 as char init ":"   no-undo.
    define variable  sym10 as char init ":"   no-undo.
    define variable  sym11 as char init ":"   no-undo.
    define variable  sym12 as char init ":"   no-undo.
    define variable  sym13 as char init ":"   no-undo.
    define variable  Line as char no-undo.
    define variable base-type as character no-undo .
    define variable v-base-code like ub.sysconf.base-code no-undo .
    define variable v-host-code like ub.sysconf.host-code no-undo .
    define buffer buf_rep_currency for ub.currency.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    find first buf_rep_currency no-lock
    where buf_rep_currency.curr-code = v-base-code
    no-error .
    if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
                else base-type = "б.в." .
    DEFINE FRAME supp-gds
          sym1 column-label ":!:" format "X(1)" space(0)
          suppl-parts.gds-name COLUMN-LABEL "Наименование!товара" FORMAT "x(40)" space(0)
          sym2 column-label ":!:" format "X(1)" space(0)
          suppl-parts.in-code COLUMN-LABEL "№ ПН! " FORMAT "x(16)" space(0)
          sym3 column-label ":!:" format "X(1)" space(0)
          suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/99" space(0)
          sym4 column-label ":!:" format "X(1)" space(0)
          price0 COLUMN-LABEL "Учетная!цена" FORMAT "->>,>>9.99"  space(0)
          sym5 column-label ":!:" format "X(1)" space(0)
          suppl-parts.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym6 column-label ":!:" format "X(1)" space(0)
          in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym7 column-label ":!:" format "X(1)" space(0)
          suppl-parts.out-qnty COLUMN-LABEL "Расход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym8 column-label ":!:" format "X(1)" space(0)
          out-sum0 COLUMN-LABEL "Расход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym9 column-label ":!:" format "X(1)" space(0)
          suppl-parts.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym10 column-label ":!:" format "X(1)" space(0)
          free-sum0 COLUMN-LABEL "Остаток сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym11 column-label ":!:" format "X(1)" space(0)
          object COLUMN-LABEL "Объект! " FORMAT "x(10)"  space(0)
          sym12 column-label ":!:" format "X(1)" space(0)
          PartCode COLUMN-LABEL "Партия! " FORMAT "x(14)" space(0)
          sym13 column-label ":!:" format "X(1)" space(0)
        HEADER
            string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
            string( "Отчет по поставщику: " + supplier.obj-name ) AT 45 format "X(71)"
            string( "Cуммы указаны в " + (if val-type = "rubl" then "руб" else (if val-type = "base" then base-type else cli-val ) ) ) AT 145 format "X(20)"
            string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
            Line format "X(198)" AT 1
        with width 232 down stream-io.
    if session:set-wait-state("COMPILER") then.
    assign Line = fill("-", 232).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input 43
                                                ,input yes
                                                ,input no
                                                ).
    FORM with FRAME supp-gds.
    FORM HEADER
        Line format "X(198)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 60 SKIP
        with FRAME BottomFrame width 232
        PAGE-BOTTOM no-labels no-box.
    VIEW STREAM PrnLibStream FRAME BottomFrame .
    PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   за период с: " + string(from-date,"99/99/9999") +
                                                          " по: " + string(to-date,"99/99/9999") )
                                                   AT 62 format "X(198)"
                                               SKIP(1)
                                               string( "ПОСТАВЩИК: " + supplier.obj-name +
                                                          " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" )
                                                   AT 10 format "X(198)"
                                               SKIP.
    if gds-art = "" then
        PUT STREAM PrnLibStream string( "ТОВАР: " + suppl-gds.artic + ' "' + suppl-gds.gds-name + '"' )
                                                       AT 14 format "X(198)"
                                                   SKIP.
    PUT STREAM PrnLibStream " " SKIP.
    FOR EACH suppl-parts NO-LOCK BREAK BY suppl-parts.artic BY suppl-parts.prod-type BY suppl-parts.prod-code BY suppl-parts.in-code:
        CASE val-type:
            WHEN "rubl" THEN
                assign
                    price0 = suppl-parts.price0-rubl
                    in-sum0 = suppl-parts.in-sum0-rubl
                    out-sum0 = suppl-parts.out-sum0-rubl
                    free-sum0 = suppl-parts.free-sum0-rubl
                    .
            WHEN "base" THEN
                assign
                    price0 = suppl-parts.price0-base
                    in-sum0 = suppl-parts.in-sum0-base
                    out-sum0 = suppl-parts.out-sum0-base
                    free-sum0 = suppl-parts.free-sum0-base
                    .
            WHEN "cli" THEN
                assign
                    price0 = suppl-parts.price-cli
                    in-sum0 = suppl-parts.in-sum-cli
                    out-sum0 = suppl-parts.out-sum-cli
                    free-sum0 = suppl-parts.free-sum-cli
                    .
        END CASE.
        DISPLAY STREAM PrnLibStream
            sym1 suppl-parts.in-code
            sym2 string( suppl-parts.artic + " " + suppl-parts.gds-name ) @ suppl-parts.gds-name
            sym3 suppl-parts.fact-date
            sym4 price0
            sym5 suppl-parts.in-qnty
            sym6 in-sum0
            sym7 suppl-parts.out-qnty
            sym8 out-sum0
            sym9 suppl-parts.free-qnty
            sym10 free-sum0
            sym11 (suppl-parts.obj-type + " " + STRING (suppl-parts.obj-code)) @ object
            sym12 (if suppl-parts.part-code = "" then "------" else suppl-parts.part-code) @ PartCode
            sym13
            with FRAME supp-gds .
        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
        ACCUMULATE
            suppl-parts.in-qnty (TOTAL)
            in-sum0 (TOTAL)
            suppl-parts.out-qnty (TOTAL)
            out-sum0 (TOTAL)
            suppl-parts.free-qnty (TOTAL)
            free-sum0 (TOTAL)
            suppl-parts.prod-code (SUB-COUNT BY suppl-parts.prod-code)
            suppl-parts.in-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            in-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            suppl-parts.out-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            out-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            suppl-parts.free-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            free-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            .
        if LAST-OF( suppl-parts.prod-code ) then
            do:
                if (ACCUM SUB-COUNT BY suppl-parts.prod-code suppl-parts.prod-code) > 1 then
                    do:
                        DISPLAY STREAM PrnLibStream
                            sym1
                            sym2 string( "  Итого по товару" ) @ suppl-parts.gds-name
                            sym3 sym4
                            sym5 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.in-qnty) @ suppl-parts.in-qnty
                            sym6 (ACCUM SUB-TOTAL BY suppl-parts.prod-code in-sum0) @ in-sum0
                            sym7 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.out-qnty) @ suppl-parts.out-qnty
                            sym8 (ACCUM SUB-TOTAL BY suppl-parts.prod-code out-sum0) @ out-sum0
                            sym9 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.free-qnty) @ suppl-parts.free-qnty
                            sym10 (ACCUM SUB-TOTAL BY suppl-parts.prod-code free-sum0) @ free-sum0
                            sym11 sym12 sym13
                            with FRAME supp-gds .
                        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
                    end.
                DISPLAY STREAM PrnLibStream
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13
                    with FRAME supp-gds .
                DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
            end.
    END.
    PUT STREAM PrnLibStream Line format "X(198)" SKIP.
    DISPLAY STREAM PrnLibStream
        "Итого" @ price0
        (ACCUM TOTAL suppl-parts.in-qnty) @ suppl-parts.in-qnty
        (ACCUM TOTAL in-sum0) @ in-sum0
        (ACCUM TOTAL suppl-parts.out-qnty) @ suppl-parts.out-qnty
        (ACCUM TOTAL out-sum0) @ out-sum0
        (ACCUM TOTAL suppl-parts.free-qnty) @ suppl-parts.free-qnty
        (ACCUM TOTAL free-sum0) @ free-sum0
        with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
    HIDE STREAM PrnLibStream FRAME BottomFrame .
    OUTPUT STREAM PrnLibStream CLOSE.
    if session:set-wait-state("") then.
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 8
                                              ).
    APPLY "ENTRY" TO BROWSE br-parts.
END PROCEDURE.
PROCEDURE print-order :
  define variable  tb-code as char no-undo.
  define variable  price0 LIKE ub.parts.price-rubl no-undo.
  define variable  in-sum0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-noNDS0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-NDS0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-sum0 LIKE ub.parts.price-rubl no-undo.
  define variable  resource as int init ? no-undo.
  define variable  avrg-sale as decimal no-undo.
  define variable  sum-price-s as decimal no-undo.
  define variable  UpFact as decimal no-undo.
  define variable  sym1 as char init ":"   no-undo.
  define variable  sym2 as char init ":"   no-undo.
  define variable  sym3 as char init ":"   no-undo.
  define variable  sym4 as char init ":"   no-undo.
  define variable  sym5 as char init ":"   no-undo.
  define variable  sym6 as char init ":"   no-undo.
  define variable  sym7 as char init ":"   no-undo.
  define variable  sym8 as char init ":"   no-undo.
  define variable  sym9 as char init ":"   no-undo.
  define variable  sym10 as char init ":"   no-undo.
  define variable  sym11 as char init ":"   no-undo.
  define variable  sym12 as char init ":"   no-undo.
  define variable  sym13 as char init ":"   no-undo.
  define variable  sym14 as char init ":"   no-undo.
  define variable  Line as char no-undo.
  define variable base-type as character no-undo .
  define variable v-base-code like ub.sysconf.base-code no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define buffer buf_rep_currency for ub.currency.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
  find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = v-base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
              else base-type = "б.в." .
  DEFINE FRAME supp-gds
        sym1 column-label ":!:" format "X(1)" space(0)
        suppl-parts.in-code COLUMN-LABEL "№ ПН! " FORMAT "x(16)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/9999" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        suppl-parts.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        price0 COLUMN-LABEL "Учетная!цена" FORMAT "->>>,>>9.99"  space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        resource COLUMN-LABEL "Обеспе-!ченность" FORMAT "->>>>>>9" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        avrg-sale COLUMN-LABEL "Средние!продажи" FORMAT "->>>>>9"
        sym8 column-label ":!:" format "X(1)"
        suppl-parts.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<"
        sym9 column-label ":!:" format "X(1)"
        free-noNDS0 COLUMN-LABEL "Остаток сумма!уч. цен без НДС" FORMAT "->>>,>>>,>>9.99"
        sym10 column-label ":!:" format "X(1)"
        free-NDS0 COLUMN-LABEL "Остаток сумма!НДС" FORMAT "->>>,>>>,>>9.99"
        sym11 column-label ":!:" format "X(1)"
        free-sum0 COLUMN-LABEL "Остаток сумма!уч. цен c НДС" FORMAT "->>>,>>>,>>9.99"
        sym12 column-label ":!:" format "X(1)"
        sum-price-s COLUMN-LABEL "Остаток cумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
        sym13 column-label ":!:" format "X(1)"
        UpFact COLUMN-LABEL "Наценка! " FORMAT "->>>,>>>,>>9.99%"
        sym14 column-label ":!:" format "X(1)" space(0)
      HEADER
          string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
          string( "Отчет для заказа товаров от поставщика: " + supplier.obj-name ) AT 45 format "X(95)"
          string( "Cуммы указаны в " + (if PrintRubl then "руб" else base-type) ) AT 145 format "X(20)"
          string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
          Line format "X(198)" AT 1
      with width 232 down stream-io.
  assign PrintRubl = yes .
  if v-base-code <> 0 and var-report-r-b = "base" then
      assign PrintRubl = no .
  if session:set-wait-state("COMPILER") then.
  assign Line = fill("-", 232).
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
  FORM with FRAME supp-gds.
  FORM HEADER
      Line format "X(198)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 60 SKIP
      with FRAME BottomFrame width 232
      PAGE-BOTTOM no-labels no-box.
  VIEW STREAM PrnLibStream FRAME BottomFrame .
  if num-doc = "" then
      PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   за период с: " + string(from-date,"99/99/9999") +
                                                            " по: " + string(to-date,"99/99/9999") )
                                                     AT 62 format "X(198)"
                                                 SKIP(1)
                                                 .
  else
      PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   по документу: " + num-doc + " от " + string( ub.trn-doc.fact-date, "99/99/9999" ) )
                                                     AT 62 format "X(198)"
                                                 SKIP(1)
                                                 .
  PUT STREAM PrnLibStream string( "ПОСТАВЩИК: " + supplier.obj-name +
                                                        " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" )
                                                 AT 10 format "X(198)"
                                               SKIP.
  if gds-art = "" then
      PUT STREAM PrnLibStream string( "ТОВАР: " + suppl-gds.artic + ' "' + suppl-gds.gds-name + '"' )
                                                     AT 14 format "X(198)"
                                                 SKIP.
  PUT STREAM PrnLibStream " " SKIP.
  FOR EACH suppl-parts NO-LOCK,
          EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic
                                             AND ub.goods.prod-type = suppl-parts.prod-type
                                             AND ub.goods.prod-code = suppl-parts.prod-code
                                             NO-LOCK
                                             BREAK BY ub.goods.grp-name BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY suppl-parts.in-code:
      FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
      FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                      AND ub.bar-code.unit-cli = ub.goods.unit-base
                      AND ub.bar-code.node-code = ub.gds-prt.node-code
                      AND ub.bar-code.part-code = ""
                      AND ub.bar-code.in-code = ""
                      NO-LOCK.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return no-apply.
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      assign
          price0 = (if PrintRubl then suppl-parts.price0-rubl else suppl-parts.price0-base)
          in-sum0 = (if PrintRubl then suppl-parts.in-sum0-rubl else suppl-parts.in-sum0-base)
          free-sum0 = (if PrintRubl then suppl-parts.free-sum0-rubl else suppl-parts.free-sum0-base)
          free-NDS0 = (if PrintRubl then suppl-parts.free-NDS0-rubl else suppl-parts.free-NDS0-base)
          free-noNDS0 = free-sum0 - free-NDS0
          avrg-sale = suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date)
          resource = suppl-parts.free-qnty / avrg-sale
          .
      if FIRST-OF (ub.goods.grp-name) then
          do:
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
              PUT STREAM PrnLibStream SPACE(20) string("Группа: " + ub.goods.grp-name) format "X(100)".
          end.
      if FIRST-OF (ub.goods.prod-code) then
          do:
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
              PUT STREAM PrnLibStream
                  SPACE(5)
                  "Артикул: " ub.goods.artic format "X(16)"
                  SPACE
                  "Код: " string( ub.bar-code.b-code ) format "x(13)"
                  SPACE
                  suppl-parts.gds-name format "x(50)"
                  .
          end.
      DISPLAY STREAM PrnLibStream
          sym1 suppl-parts.in-code
          sym2 suppl-parts.fact-date
          sym3 suppl-parts.in-qnty
          sym4 price0
          sym5 in-sum0
          sym6 resource
          sym7 suppl-parts.free-qnty
          sym8 avrg-sale
          sym9 free-noNDS0
          sym10 free-NDS0
          sym11 free-sum0
          sym12 sum-price-s
          sym13 ( ( sum-price-s - free-sum0 ) / free-sum0 * 100 ) @ UpFact
          sym14
          with FRAME supp-gds .
      DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
      ACCUMULATE
          suppl-parts.in-qnty (TOTAL)
          in-sum0 (TOTAL)
          suppl-parts.free-qnty (TOTAL)
          free-noNDS0 (TOTAL)
          free-NDS0 (TOTAL)
          free-sum0 (TOTAL)
          sum-price-s (TOTAL)
          suppl-parts.prod-code (SUB-COUNT BY ub.goods.prod-code)
          suppl-parts.in-qnty (SUB-TOTAL BY ub.goods.prod-code)
          in-sum0 (SUB-TOTAL BY ub.goods.prod-code)
          suppl-parts.free-qnty (SUB-TOTAL BY ub.goods.prod-code)
          free-noNDS0 (SUB-TOTAL BY ub.goods.prod-code)
          free-NDS0 (SUB-TOTAL BY ub.goods.prod-code)
          free-sum0 (SUB-TOTAL BY ub.goods.prod-code)
          sum-price-s (SUB-TOTAL BY ub.goods.prod-code)
          .
      if LAST-OF( ub.goods.prod-code ) AND (ACCUM SUB-COUNT BY ub.goods.prod-code suppl-parts.prod-code) > 1 then
          do:
              DISPLAY STREAM PrnLibStream
                  sym1 string( "Итого по товару" ) @ suppl-parts.in-code
                  sym2
                  sym3 (ACCUM SUB-TOTAL BY ub.goods.prod-code suppl-parts.in-qnty) @ suppl-parts.in-qnty
                  sym4
                  sym5 (ACCUM SUB-TOTAL BY ub.goods.prod-code in-sum0) @ in-sum0
                  sym6
                  sym7
                  sym8 (ACCUM SUB-TOTAL BY ub.goods.prod-code suppl-parts.free-qnty) @ suppl-parts.free-qnty
                  sym9 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-noNDS0) @ free-noNDS0
                  sym10 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-NDS0) @ free-NDS0
                  sym11 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) @ free-sum0
                  sym12 (ACCUM SUB-TOTAL BY ub.goods.prod-code sum-price-s) @ sum-price-s
                  sym13 ( ( (ACCUM SUB-TOTAL BY ub.goods.prod-code sum-price-s) - (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) ) /
                                    (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) * 100 ) @ UpFact
                  sym14
                  with FRAME supp-gds .
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
          end.
  END.
  PUT STREAM PrnLibStream Line format "X(198)" SKIP.
  DISPLAY STREAM PrnLibStream
      "Итого" @ suppl-parts.in-code
      (ACCUM TOTAL suppl-parts.in-qnty) @ suppl-parts.in-qnty
      (ACCUM TOTAL in-sum0) @ in-sum0
      (ACCUM TOTAL suppl-parts.free-qnty) @ suppl-parts.free-qnty
      (ACCUM TOTAL free-noNDS0) @ free-noNDS0
      (ACCUM TOTAL free-NDS0) @ free-NDS0
      (ACCUM TOTAL free-sum0) @ free-sum0
      (ACCUM TOTAL sum-price-s) @ sum-price-s
      with FRAME supp-gds .
  DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
  HIDE STREAM PrnLibStream FRAME BottomFrame .
  OUTPUT STREAM PrnLibStream CLOSE.
  if session:set-wait-state("") then.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
END PROCEDURE.
