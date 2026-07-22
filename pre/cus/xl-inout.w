define input  parameter parParentProc  as widget-handle no-undo.
define input parameter type-docs like ub.trn-doc.doc-type no-undo.
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num  in parParentProc ( output g#report-num ).
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable p-XL-delim as character no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input 'орг':U
  ,input v-cntxt-host-code-obj
  ,input 'report-firm':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'actuate'  then tmp-var1 = thbjattr_thbj-attr.property-value-character .
  end.
IF tmp-var1 = ""  then p-XL-delim = ";" .
else p-XL-delim = tmp-var1 .
define variable CliName like ub.clients.obj-name init "" no-undo.
define variable GrpName like ub.goods.grp-name init "" no-undo.
define variable str-et as char init "" no-undo.
define variable str-doc as char init "" no-undo.
define variable str-txt as char init "" no-undo.
define variable str-ret-sup as char init "" no-undo.
define variable str-discnt as char init "" no-undo.
define variable str-with-discnt as char init "" no-undo.
define variable counter as int no-undo.
define variable str-ind as int no-undo.
define variable i as int no-undo.
def stream OutStream.
define temp-table var-tbl no-undo
       field fact-num  like ub.trn-doc.fact-num
       field cli-type    like ub.trn-doc.cli-type
       field cli-code   like ub.trn-doc.cli-code
       field quant       as  dec
       field summa    as  dec
       index code is unique primary
           fact-num
           cli-type
           cli-code
       .
define temp-table doc-tbl no-undo
       field fact-date  as date
       field num-doc  like ub.trn-doc.doc-code
       field fact-num  like ub.trn-doc.fact-num
       field type-doc  like ub.trn-doc.doc-type
       field client       like ub.trn-doc.cli-name
       index num  is unique primary
          fact-num
       index code
           type-doc
           client.
define temp-table cli-tbl no-undo
       field cli-type    like ub.trn-doc.cli-type
       field cli-code   like ub.trn-doc.cli-code
       field cli-name  like ub.trn-doc.cli-name
       field quant       as  dec
       field summa    as  dec
     index code is unique primary
           cli-type
           cli-code
     index name
           cli-name
       .
define variable  with-discnt          as dec no-undo.
define variable  sum-with-discnt  as dec no-undo.
define variable  discnt                 as dec no-undo.
define variable  sum-discnt         as dec no-undo.
define variable  amount               as dec no-undo.
define variable  sum                    as dec no-undo.
DEFINE BUTTON b-help
     LABEL "Помо&щь "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print DEFAULT
     LABEL "Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE date-end AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE FRAME xl-inout
     b-quit AT ROW 1 COL 1
     b-print AT ROW 1 COL 11
     b-help AT ROW 1 COL 28.5
     date-beg AT ROW 3 COL 3.5 COLON-ALIGNED
     date-end AT ROW 3 COL 20.5 COLON-ALIGNED
     SPACE(5.24) SKIP(0.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет по расходу товара"
         DEFAULT-BUTTON b-print CANCEL-BUTTON b-quit.
ASSIGN
       FRAME xl-inout:SCROLLABLE       = FALSE.
ON CHOOSE OF b-print IN FRAME xl-inout
DO:
def buffer b-price-list for ub.price-list.
define variable d-price as decimal no-undo.
define variable t-d as char no-undo.
define variable i as int no-undo.
define variable pr-price  as log no-undo.
define variable pr-t-doc  as log no-undo.
assign
    date-beg
    date-end
    .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ReportFileName as character no-undo initial "report".
define variable was_OK_opened  as logical   no-undo.
system-dialog get-file          ReportFileName
              title             "Укажите путь"
              filters           "Текстовый файл (*.txt)" "*.txt"
              ask-overwrite
              create-test-file
              save-as
              use-filename
              default-extension "txt"
              update            was_OK_opened.
if was_OK_opened <> yes then do: return "Cancel". end.
assign ReportFileName = trim( string( ReportFileName ) ).
output stream OutStream to value ( ReportFileName ) page-size 0  .
if session:set-wait-state("COMPILER") then.
if type-docs = 'рас':U then do:
    create doc-tbl.
    assign
        doc-tbl.fact-num  = - 99
        doc-tbl.client       = "Со скидкой"
        doc-tbl.type-doc  = "Со скидкой".
    create doc-tbl.
    assign
        doc-tbl.fact-num  = - 999
        doc-tbl.client       = 'скидка':U
        doc-tbl.type-doc  = 'скидка':U.
end.
assign counter  = 0.
FOR EACH ub.trn-doc WHERE ub.trn-doc.obj-type = v-cntxt-obj-type
                                            AND ub.trn-doc.obj-code = v-cntxt-obj-code
                                            AND ub.trn-doc.fact-num <> 0
                                            AND ub.trn-doc.discnt-type <> 'касс':U
                                            AND ub.trn-doc.fact-date >= date-beg
                                            AND ub.trn-doc.fact-date <= date-end NO-LOCK:
    if type-docs = 'при':U and ub.trn-doc.doc-type = 'рас':U then next.
    else if type-docs = 'рас':U and ub.trn-doc.doc-type = 'при':U then next.
    else if type-docs = 'рас':U and ub.trn-doc.doc-type = 'возврат':U then next.
    create doc-tbl.
    assign
        doc-tbl.fact-num  = ub.trn-doc.fact-num
        doc-tbl.fact-date  = ub.trn-doc.fact-date
        doc-tbl.num-doc  = ub.trn-doc.doc-code
        doc-tbl.client       = ub.trn-doc.cli-name
        doc-tbl.type-doc  = ub.trn-doc.doc-type
    .
    if ub.trn-doc.doc-type = 'инв':U then doc-tbl.client = "Инвентаризация".
    else if ub.trn-doc.doc-type = 'возврат':U and type-docs = 'при':U then doc-tbl.client = 'возврат':U.
    else if ub.trn-doc.ext-doc-type = 'ep':U and type-docs = 'рас':U then doc-tbl.client = "Возврат поставщику".
    FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK,
            EACH ub.clients WHERE ub.clients.obj-type = ub.doc-line.prod-type
                                                AND ub.clients.obj-code = ub.doc-line.prod-code NO-LOCK:
           assign
               with-discnt          = 0
               sum-with-discnt  = 0
               discnt                  = 0
               sum-discnt          = 0
               amount                = 0
               sum                     = 0 .
            FOR EACH ub.gds-dtl WHERE
                              ub.gds-dtl.prod-type  = ub.doc-line.prod-type
                      AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
                      AND ub.gds-dtl.artic          = ub.doc-line.artic
                      AND ub.gds-dtl.doc-code   = ub.doc-line.doc-code
                  NO-LOCK:
                  if ub.trn-doc.doc-type =  'инв':U  THEN do:
                            if ( ( type-docs = 'рас':U AND ub.gds-dtl.doc-qnty >= 0 )
                                 OR ( type-docs = 'при':U AND ub.gds-dtl.doc-qnty <= 0 ) ) then
                                NEXT.
                            else
                               assign
                                  amount = amount + absolute( ub.gds-dtl.doc-qnty )
                                  sum      = sum      +
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  * absolute( ub.gds-dtl.doc-qnty ) .
                  end.
                  else do:
                      if  type-docs = 'рас':U then   do:
                          assign
                              amount = amount + ub.gds-dtl.fact-qnty
                              sum      = sum      + ( (
                               ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                -
                                ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                ) * ub.gds-dtl.fact-qnty ).
                          if   ub.trn-doc.ext-doc-type = 'ep':U   then
                            assign
                                doc-tbl.type-doc  = 'возврат':U
                                amount = amount + ub.gds-dtl.fact-qnty
                                sum      = sum      + (
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  -
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                   ) * ub.gds-dtl.fact-qnty  .
                          else
                             assign
                                 with-discnt          = with-discnt + ub.gds-dtl.fact-qnty
                                 sum-with-discnt  = sum-with-discnt + ( (
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  -
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                   ) * ub.gds-dtl.fact-qnty )
                                 discnt          = discnt + ub.gds-dtl.fact-qnty
                                 sum-discnt  = sum-discnt + (
                                   ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                   * ub.gds-dtl.fact-qnty ) .
                     end.
                     else
                          assign
                              amount = amount + ub.gds-dtl.fact-qnty
                              sum      = sum      + ( ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ).
                  end.
            end.
            find  cli-tbl where
                     cli-tbl.cli-type   = ub.doc-line.prod-type
              and cli-tbl.cli-code  = ub.doc-line.prod-code
            use-index code no-lock no-error.
            if not available cli-tbl then do:
                create cli-tbl.
                assign
                   cli-tbl.cli-type    = ub.doc-line.prod-type
                   cli-tbl.cli-code   = ub.doc-line.prod-code
                   cli-tbl.cli-name  = ub.clients.obj-name.
            end.
            find  var-tbl where
                     var-tbl.fact-num = ub.trn-doc.fact-num
              and var-tbl.cli-type   = ub.doc-line.prod-type
              and var-tbl.cli-code  = ub.doc-line.prod-code
            use-index code no-lock no-error.
            if not available var-tbl then do:
               create var-tbl.
               assign
                  var-tbl.cli-type    = ub.doc-line.prod-type
                  var-tbl.cli-code   = ub.doc-line.prod-code
                  var-tbl.fact-num  = ub.trn-doc.fact-num
                .
            end.
             assign
                  var-tbl.quant    = var-tbl.quant + amount
                  var-tbl.summa = var-tbl.summa +  sum.
              if type-docs = 'рас':U and ub.trn-doc.ext-doc-type <> 'ep':U then   do:
                  find  var-tbl where
                           var-tbl.fact-num = - 99
                    and var-tbl.cli-type   = ub.doc-line.prod-type
                    and var-tbl.cli-code  = ub.doc-line.prod-code
                  use-index code no-lock no-error.
                  if not available var-tbl then do:
                      create var-tbl.
                      assign
                          var-tbl.cli-type    = ub.doc-line.prod-type
                          var-tbl.cli-code   = ub.doc-line.prod-code
                          var-tbl.fact-num  = - 99.
                        .
                  end.
                  assign
                      var-tbl.quant    = var-tbl.quant    + with-discnt
                      var-tbl.summa = var-tbl.summa + sum-with-discnt.
                  find  var-tbl where
                           var-tbl.fact-num = - 999
                    and var-tbl.cli-type   = ub.doc-line.prod-type
                    and var-tbl.cli-code  = ub.doc-line.prod-code
                  use-index code no-lock no-error.
                  if not available var-tbl then do:
                      create var-tbl.
                      assign
                          var-tbl.cli-type    = ub.doc-line.prod-type
                          var-tbl.cli-code   = ub.doc-line.prod-code
                          var-tbl.fact-num  = - 999
                        .
                  end.
                  assign
                      var-tbl.quant    = var-tbl.quant    + discnt
                      var-tbl.summa = var-tbl.summa + sum-discnt.
              end.
    END.
    assign counter = counter + 1.
    if ( counter MODULO 10 ) = 0 then
        run waitfram-show ( string( "Обработано " + string( counter )  + " документов" ) ).
END.
assign counter = 0.
FOR EACH ub.price-doc WHERE ub.price-doc.obj-type = v-cntxt-obj-type
                                                AND ub.price-doc.obj-code = v-cntxt-obj-code
                                                AND ub.price-doc.fact-num <> 0
                                                AND ub.price-doc.fact-date >= date-beg
                                                AND ub.price-doc.fact-date <= date-end NO-LOCK:
    create doc-tbl.
    assign
        doc-tbl.fact-num  = ub.price-doc.fact-num
        doc-tbl.fact-date  = ub.price-doc.fact-date
        doc-tbl.num-doc  = ub.price-doc.doc-num
        doc-tbl.client       = 'переоценка':U
        doc-tbl.type-doc  = "пер"
        pr-price               = false
    .
    FOR EACH ub.price-list WHERE ub.price-list.doc-num = ub.price-doc.doc-num NO-LOCK,
            EACH ub.goods WHERE ub.goods.artic = ub.price-list.artic
                                               AND ub.goods.prod-type = ub.price-list.prod-type
                                               AND ub.goods.prod-code = ub.price-list.prod-code NO-LOCK,
            EACH ub.clients WHERE ub.clients.obj-type = ub.goods.prod-type
                                                AND ub.clients.obj-code = ub.goods.prod-code NO-LOCK:
        FIND LAST b-price-list WHERE b-price-list.obj-type = v-cntxt-obj-type
                                                           AND b-price-list.obj-code = v-cntxt-obj-code
                                                           AND b-price-list.b-code  = ub.price-list.b-code
                                                           AND b-price-list.fact-order < ub.price-list.fact-order
                                                           NO-LOCK NO-ERROR.
        if not available b-price-list  then do:
                FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
                FIND LAST b-price-list WHERE b-price-list.obj-type = v-cntxt-obj-type
                                                                  AND b-price-list.obj-code = v-cntxt-obj-code
                                                                  AND b-price-list.b-code  = ub.gds-prt.node-code
                                                                  AND b-price-list.fact-order < ub.price-list.fact-order
                                                                  NO-LOCK NO-ERROR.
        end.
        if not available b-price-list  then
            d-price = ub.price-list.price-sale * ub.price-list.doc-qnty.
        else
            d-price = ( ub.price-list.price-sale - b-price-list.price-sale ) * ub.price-list.doc-qnty.
        if ub.price-list.doc-qnty = ? then   NEXT.
        if ( ( type-docs = 'рас':U AND d-price >= 0 ) OR ( type-docs = 'при':U AND d-price <= 0 ) ) then
            NEXT.
            find  cli-tbl where
                     cli-tbl.cli-type   = ub.price-list.prod-type
              and cli-tbl.cli-code  = ub.price-list.prod-code
            use-index code no-lock no-error.
            if not available cli-tbl then do:
                create cli-tbl.
                assign
                   cli-tbl.cli-type    = ub.price-list.prod-type
                   cli-tbl.cli-code   = ub.price-list.prod-code
                   cli-tbl.cli-name  = ub.clients.obj-name.
            end.
            find  var-tbl where
                      var-tbl.fact-num = ub.price-doc.fact-num
               and var-tbl.cli-type   = ub.price-list.prod-type
               and var-tbl.cli-code  = ub.price-list.prod-code
            use-index code no-lock no-error.
            if not available var-tbl then do:
                create var-tbl.
                assign
                    var-tbl.cli-type    = ub.price-list.prod-type
                    var-tbl.cli-code   = ub.price-list.prod-code
                    var-tbl.fact-num  = ub.price-doc.fact-num
                 .
            end.
            assign
                var-tbl.quant    = var-tbl.quant    + ub.price-list.doc-qnty
                var-tbl.summa = var-tbl.summa + d-price.
                pr-price            = true
              .
    END.
    if pr-price = false then delete doc-tbl.
    assign counter = counter + 1.
    if ( counter MODULO 10 ) = 0 then
        run waitfram-show ( string( "Обработано " + string( counter )  + " актов переоценки" ) ).
END.
if type-docs = 'при':U then
    EXPORT stream OutStream
         "Отчет по приходу товара".
else
    EXPORT stream OutStream
        "Отчет по расходу товара".
find ub.clients where ub.clients.obj-type = v-cntxt-obj-type
                     AND ub.clients.obj-code = v-cntxt-obj-code NO-LOCK.
EXPORT stream OutStream
    "Магазин/Склад"  p-xl-delim ub.clients.obj-name .
EXPORT stream OutStream
    "Отчетный период" p-xl-delim
    string(date-beg,  "99/99/9999" ) p-xl-delim
    " - "  p-xl-delim
    string( date-end,  "99/99/9999" ) .
put stream OutStream unformatted " " skip.
str-doc =  "Дата" + p-xl-delim  + "N документа" + p-xl-delim.
if type-docs = 'при':U then
        str-doc = str-doc + "Отправитель"  + p-xl-delim.
else
        str-doc = str-doc + "Получатель"  + p-xl-delim.
str-txt =  p-xl-delim +  p-xl-delim +  p-xl-delim.
for each cli-tbl no-lock
   use-index name:
   assign
        str-doc = str-doc + cli-tbl.cli-name + p-xl-delim + p-xl-delim
        str-txt   = str-txt   + "шт." + p-xl-delim + "Стоимость РУБ" +  p-xl-delim.
end.
assign
     str-doc = str-doc + "ИТОГО" + p-xl-delim + p-xl-delim
     str-txt   = str-txt   + "шт." + p-xl-delim + "Стоимость РУБ" +  p-xl-delim.
EXPORT stream OutStream str-doc .
EXPORT stream OutStream str-txt .
do i = 1 to 6 :
    if i = 1 then do:
         if type-docs = 'при':U  then t-d =  'при':U.
         else t-d = 'рас':U.
    end.
    else if i = 4 then t-d = 'возврат':U.
    else if i = 2 then do:
         if type-docs = 'при':U  then next.
         else t-d = "Со скидкой".
    end.
    else if i = 3 then do:
         if type-docs = 'при':U  then next.
         else t-d = 'скидка':U.
    end.
    else if i = 5 then t-d =  "пер".
    else if i = 6 then t-d =  'инв':U.
    pr-t-doc = false.
    for each doc-tbl  where
            doc-tbl.type-doc = t-d
        use-index code  no-lock :
        if i = 2  or i = 3  then
           str-doc = p-xl-delim + p-xl-delim.
        else
            str-doc =  string(doc-tbl.fact-date, "99/99/9999") + p-xl-delim +
                            string(doc-tbl.num-doc) + p-xl-delim .
        assign
            amount = 0
            sum      = 0
            pr-t-doc = true
            str-doc =  str-doc +
                            string(doc-tbl.client)      + p-xl-delim.
        for each cli-tbl no-lock
            use-index name:
            find first var-tbl  WHERE
                     var-tbl.fact-num = doc-tbl.fact-num
              and var-tbl.cli-type   = cli-tbl.cli-type
              and var-tbl.cli-code   = cli-tbl.cli-code
            use-index code  no-lock no-error.
            if not available var-tbl then
                str-doc = str-doc + " "  + p-xl-delim
                                           + " "  + p-xl-delim.
            else  do:
                if i = 2 or i = 3 then
                    str-doc = str-doc +  p-xl-delim
                                               +  string(var-tbl.summa)   + p-xl-delim.
                else do:
                    if var-tbl.quant <> 0 then
                        str-doc = str-doc +  string(var-tbl.quant   )   + p-xl-delim.
                    else
                        str-doc = str-doc +  " "  + p-xl-delim.
                    if var-tbl.summa <> 0 then
                        str-doc = str-doc +  string(var-tbl.summa)   + p-xl-delim.
                    else
                        str-doc = str-doc +  " "  + p-xl-delim.
                    assign
                        cli-tbl.quant = cli-tbl.quant + var-tbl.quant
                        cli-tbl.summa = cli-tbl.summa + var-tbl.summa.
                end.
                assign
                    amount = amount + var-tbl.quant
                    sum      = sum      + var-tbl.summa.
             end.
        end.
        if i = 2 or i = 3 then
            str-doc = str-doc + p-xl-delim
                                       +  string(sum)   + p-xl-delim.
        else do:
            if amount <> 0 then
               str-doc = str-doc +  string(amount   )   + p-xl-delim.
            else
               str-doc = str-doc +  " "   + p-xl-delim.
            if sum <> 0 then
               str-doc = str-doc +  string(sum)   + p-xl-delim.
            else
               str-doc = str-doc +  " "   + p-xl-delim.
        end.
        EXPORT stream OutStream str-doc .
    end.
    if pr-t-doc = false then do:
        str-txt =  p-xl-delim +  p-xl-delim .
        if i = 4  and type-docs = 'рас':U then
             EXPORT stream OutStream  p-xl-delim
                    p-xl-delim "Возврат поставщику" .
        else if i = 4  and type-docs = 'при':U then
             EXPORT stream OutStream  p-xl-delim
                    p-xl-delim 'возврат':U .
        else if i = 2   and type-docs = 'рас':U  then
                 EXPORT stream OutStream p-xl-delim
                        p-xl-delim  "Со скидкой" .
        else if i = 3  and type-docs = 'рас':U  then
                 EXPORT stream OutStream
                        p-xl-delim   p-xl-delim   'скидка':U .
        else if i = 5 then
             EXPORT stream OutStream
                    p-xl-delim  p-xl-delim
                    'переоценка':U  p-xl-delim .
        else if i = 6 then
             EXPORT stream OutStream
                    p-xl-delim  p-xl-delim
                    "Инвентаризация"  p-xl-delim .
    end.
end.
str-txt =  p-xl-delim +  p-xl-delim  + "ИТОГО" +  p-xl-delim.
assign
  amount = 0
  sum = 0.
for each cli-tbl no-lock
    use-index name:
    if cli-tbl.quant <> 0 then
        str-txt = str-txt + string(cli-tbl.quant)    +  p-xl-delim .
    else
        str-txt = str-txt +  " "   + p-xl-delim.
    if cli-tbl.summa <> 0 then
        str-txt = str-txt + string(cli-tbl.summa) +  p-xl-delim .
    else
        str-txt = str-txt +  " "   + p-xl-delim.
    assign
        amount = amount + cli-tbl.quant
        sum      = sum      + cli-tbl.summa.
end.
str-txt = str-txt +  string(amount   )   + p-xl-delim
                        +  string(sum)           + p-xl-delim.
EXPORT stream OutStream str-txt .
run waitfram-hide.
put stream OutStream unformatted " " skip.
EXPORT stream OutStream p-xl-delim
    "Директор Магазина/Склада" p-xl-delim
    "Дата составления отчета " p-xl-delim
     string(TODAY,  "99/99/9999")   .
EXPORT stream OutStream p-xl-delim
    "Управляющий салоном/Старший товаровед"   .
if session:set-wait-state("") then.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream OutStream CLOSE.
message "Отчет выведен в файл:" SKIP
                ReportFileName
                view-as alert-box INFORMATION buttons OK TITLE " ".
END.
ON RETURN OF date-beg IN FRAME xl-inout
DO:
    APPLY "ENTRY" TO date-end IN FRAME xl-inout.
END.
ON RETURN OF date-end IN FRAME xl-inout
DO:
    APPLY "CHOOSE" TO b-print IN FRAME xl-inout.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME xl-inout:PARENT eq ?
THEN FRAME xl-inout:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME xl-inout APPLY "END-ERROR":U TO SELF.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame xl-inout
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
on choose of b-help in frame xl-inout
do:
  apply "help":u to frame xl-inout .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame xl-inout:width - 0.3
                fh            = frame xl-inout:first-child
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
  assign
      date-beg = date( month( TODAY ), 1, year( TODAY ) )
      date-end = TODAY
      .
  run enable_ui.
  if type-docs = 'при':U then
      FRAME xl-inout:TITLE = "Отчет по приходу товара".
  else
      FRAME xl-inout:TITLE = "Отчет по расходу товара".
  WAIT-FOR GO OF FRAME xl-inout.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME xl-inout.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date-beg date-end
      WITH FRAME xl-inout.
  ENABLE b-quit b-print b-help date-beg date-end
      WITH FRAME xl-inout.
END PROCEDURE.
PROCEDURE xl-io-get :
def input parameter d-t like ub.trn-doc.doc-type no-undo.
        if d-t = 'возврат':U then
            run waitfram-show ( "Обработка возвратных накладных" ).
        if d-t = 'инв':U then
            run waitfram-show ( "Обработка инвентаризаций" ).
        assign
            counter = 0
            str-doc = str-et
            .
        FOR EACH ub.trn-doc WHERE ub.trn-doc.obj-type = v-cntxt-obj-type
                                                    AND ub.trn-doc.obj-code = v-cntxt-obj-code
                                                    AND ub.trn-doc.status_ = 'факт':U
                                                    AND ub.trn-doc.doc-type = d-t
                                                    AND ub.trn-doc.discnt-type <> 'касс':U
                                                    AND ub.trn-doc.fact-date >= date-beg
                                                    AND ub.trn-doc.fact-date <= date-end NO-LOCK:
            FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK,
                    EACH ub.clients WHERE ub.clients.obj-type = ub.doc-line.prod-type
                                                        AND ub.clients.obj-code = ub.doc-line.prod-code NO-LOCK,
                    EACH ub.gds-dtl WHERE ub.gds-dtl.prod-type = ub.doc-line.prod-type
                                                        AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
                                                        AND ub.gds-dtl.artic = ub.doc-line.artic
                                                        AND ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK:
                assign
                    str-ind = lookup( ub.clients.obj-name, CliName, p-xl-delim )
                    .
                CASE d-t :
                    WHEN 'инв':U THEN
                        do:
                            if ( ( type-docs = 'рас':U AND ub.gds-dtl.doc-qnty >= 0 )
                                 OR ( type-docs = 'при':U AND ub.gds-dtl.doc-qnty <= 0 ) ) then
                                NEXT.
                            assign
                                entry( str-ind, str-doc , p-xl-delim ) =
                                    string(absolute( ub.gds-dtl.doc-qnty ) + decimal( entry( str-ind, str-doc , p-xl-delim ) ) )
                                entry( str-ind + 1, str-doc , p-xl-delim ) =
                                    string(
                                       ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                      * absolute( ub.gds-dtl.doc-qnty ) + decimal( entry( str-ind + 1, str-doc , p-xl-delim ) ) )
                                .
                       end.
                    OTHERWISE
                        do:
                            assign
                                entry( str-ind, str-doc , p-xl-delim ) =
                                    string(ub.gds-dtl.fact-qnty + decimal( entry( str-ind, str-doc , p-xl-delim ) ) )
                                entry( str-ind + 1, str-doc , p-xl-delim ) =
                                    string( (
                                        ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                        -
                                        ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                      ) * ub.gds-dtl.fact-qnty + decimal( entry( str-ind + 1, str-doc , p-xl-delim ) ) )
                                .
                        end.
                END CASE.
            END.
            assign counter = counter + 1.
            if ( counter MODULO 50 ) = 0 then
                do:
                    if d-t = 'возврат':U then
                        run waitfram-show ( string( "Обработано " + string( counter )  + " возвратных накладных" ) ).
                    if d-t = 'инв':U then
                        run waitfram-show ( string( "Обработано " + string( counter )  + " инвентаризаций" ) ).
                end.
        END.
        if d-t = 'возврат':U then
            assign entry( 4, str-doc, p-xl-delim ) = 'возврат':U .
        if d-t = 'инв':U then
            assign entry( 4, str-doc, p-xl-delim ) = "Инвентаризация" .
        EXPORT stream OutStream str-doc .
END PROCEDURE.
