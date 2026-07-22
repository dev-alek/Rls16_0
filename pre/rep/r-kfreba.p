block-level on error undo, throw.
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-is-schedule as logical   no-undo .
define input  parameter p-report-dir  as character no-undo .
define input  parameter p-db-num      as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-kfreba.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-kfreba.p $":U .
define variable vss-description as character no-undo init "Отчет реализация и остатки (Кедр)".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable g#report-num  as integer    no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name                  as character
    field xl-line-id                  as integer
    field pump-code                   like ub.rvs-line-pump.pump-code
    field gds-name                    as character
    field prev-state-measure-qnty     as decimal
    field fact-qnty                   as decimal
    field end-state-el-cnt            as decimal
    field begin-state-el-cnt          as decimal
    field sale-state-el-cnt           as decimal
    field end-state-mh-cnt            as decimal
    field begin-state-mh-cnt          as decimal
    field sale-state-mh-cnt           as decimal
    field state-divergence            as decimal
    field sale-state                  as decimal
    field sale-techfuel               as decimal
    field sale-total                  as decimal
    field place-loc1                  like ub.place.loc1
    field fact-ost-measure-qnty       as decimal
    field fact-ost-state-measure-qnty as decimal
    field end-system-qnty             as decimal
    field fact-divergence             as decimal
index pi is primary unique
        xl-line-id
.
define variable v-kfrebaxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-kfrebaxl-cell-file-name       as character    no-undo.
define variable v-kfrebaxl-data-file-name       as character    no-undo.
procedure kfrebaxl-init :
do
on error undo, return error
:
    assign
        v-kfrebaxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-kfrebaxl-data-file-name
    ).
    output stream excel-line to value( v-kfrebaxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-kfrebaxl-cell-file-name
    ).
    output stream excel-cell to value( v-kfrebaxl-cell-file-name ).
    run kfrebaxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Лист1":U
    ).
    if printrubl
    then do:
        run kfrebaxl-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run kfrebaxl-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "1":U
        ).
    end.
    run kfrebaxl-write-cell-data in this-procedure (
          input "Лист1_columnList":U
        , input "gds_name,prev_state_measure_qnty,fact_qnty,pump_code,end_state_el_cnt,begin_state_el_cnt,sale_state_el_cnt,end_state_mh_cnt,begin_state_mh_cnt,sale_state_mh_cnt,state_divergence,sale_state,sale_techfuel,sale_total,place_loc1,fact_ost_measure_qnty,fact_ost_state_measure_qnty,end_system_qnty,fact_divergence":U
    ).
    run kfrebaxl-write-cell-data in this-procedure (
          input "Лист1_columnType":U
        , input "S,D,D,I,D,D,D,D,D,D,D,D,D,D,S,D,D,D,D":U
    ).
    run kfrebaxl-write-cell-data in this-procedure (
          input "Лист1_subtotalList":U
        , input "":U
    ).
    run kfrebaxl-write-cell-data in this-procedure (
          input "Лист1_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure kfrebaxl-sheet1-write-line-data :
  define input  parameter p-pump-code                   like ub.rvs-line-pump.pump-code no-undo .
  define input  parameter p-gds-name                    as character                    no-undo .
  define input  parameter p-prev-state-measure-qnty     as decimal                      no-undo .
  define input  parameter p-fact-qnty                   as decimal                      no-undo .
  define input  parameter p-end-state-el-cnt            as decimal                      no-undo .
  define input  parameter p-begin-state-el-cnt          as decimal                      no-undo .
  define input  parameter p-sale-state-el-cnt           as decimal                      no-undo .
  define input  parameter p-end-state-mh-cnt            as decimal                      no-undo .
  define input  parameter p-begin-state-mh-cnt          as decimal                      no-undo .
  define input  parameter p-sale-state-mh-cnt           as decimal                      no-undo .
  define input  parameter p-state-divergence            as decimal                      no-undo .
  define input  parameter p-sale-state                  as decimal                      no-undo .
  define input  parameter p-sale-techfuel               as decimal                      no-undo .
  define input  parameter p-sale-total                  as decimal                      no-undo .
  define input  parameter p-place-loc1                  like ub.place.loc1              no-undo .
  define input  parameter p-fact-ost-measure-qnty       as decimal                      no-undo .
  define input  parameter p-fact-ost-state-measure-qnty as decimal                      no-undo .
  define input  parameter p-end-system-qnty             as decimal                      no-undo .
  define input  parameter p-fact-divergence             as decimal                      no-undo .
define buffer buf_temp_sheet1_line-data  for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-kfrebaxl-sheet1-cur-data-row                        = v-kfrebaxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name                  = "Лист1":U
        buf_temp_sheet1_line-data.xl-line-id                  = v-kfrebaxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.pump-code                   = p-pump-code
        buf_temp_sheet1_line-data.gds-name                    = p-gds-name
        buf_temp_sheet1_line-data.prev-state-measure-qnty     = p-prev-state-measure-qnty
        buf_temp_sheet1_line-data.fact-qnty                   = p-fact-qnty
        buf_temp_sheet1_line-data.end-state-el-cnt            = p-end-state-el-cnt
        buf_temp_sheet1_line-data.begin-state-el-cnt          = p-begin-state-el-cnt
        buf_temp_sheet1_line-data.sale-state-el-cnt           = p-sale-state-el-cnt
        buf_temp_sheet1_line-data.end-state-mh-cnt            = p-end-state-mh-cnt
        buf_temp_sheet1_line-data.begin-state-mh-cnt          = p-begin-state-mh-cnt
        buf_temp_sheet1_line-data.sale-state-mh-cnt           = p-sale-state-mh-cnt
        buf_temp_sheet1_line-data.state-divergence            = p-state-divergence
        buf_temp_sheet1_line-data.sale-state                  = p-sale-state
        buf_temp_sheet1_line-data.sale-techfuel               = p-sale-techfuel
        buf_temp_sheet1_line-data.sale-total                  = p-sale-total
        buf_temp_sheet1_line-data.place-loc1                  = p-place-loc1
        buf_temp_sheet1_line-data.fact-ost-measure-qnty       = p-fact-ost-measure-qnty
        buf_temp_sheet1_line-data.fact-ost-state-measure-qnty = p-fact-ost-state-measure-qnty
        buf_temp_sheet1_line-data.end-system-qnty             = p-end-system-qnty
        buf_temp_sheet1_line-data.fact-divergence             = p-fact-divergence
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        chr(9)   "DTA":U
        chr(9)   buf_temp_sheet1_line-data.gds-name
        chr(9)    buf_temp_sheet1_line-data.prev-state-measure-qnty
        chr(9)    buf_temp_sheet1_line-data.fact-qnty
        chr(9)   buf_temp_sheet1_line-data.pump-code
        chr(9)     buf_temp_sheet1_line-data.end-state-el-cnt
        chr(9)     buf_temp_sheet1_line-data.begin-state-el-cnt
        chr(9)     buf_temp_sheet1_line-data.sale-state-el-cnt
        chr(9)     buf_temp_sheet1_line-data.end-state-mh-cnt
        chr(9)     buf_temp_sheet1_line-data.begin-state-mh-cnt
        chr(9)     buf_temp_sheet1_line-data.sale-state-mh-cnt
        chr(9)     buf_temp_sheet1_line-data.state-divergence
        chr(9)     buf_temp_sheet1_line-data.sale-state
        chr(9)     buf_temp_sheet1_line-data.sale-techfuel
        chr(9)     buf_temp_sheet1_line-data.sale-total
        chr(9)   buf_temp_sheet1_line-data.place-loc1
        chr(9)     buf_temp_sheet1_line-data.fact-ost-measure-qnty
        chr(9)     buf_temp_sheet1_line-data.fact-ost-state-measure-qnty
        chr(9)     buf_temp_sheet1_line-data.end-system-qnty
        chr(9)     buf_temp_sheet1_line-data.fact-divergence
        chr(10)
    .
end.
end procedure.
procedure kfrebaxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Лист1":U
        chr(9)   "FMT":U
        chr(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure kfrebaxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure kfrebaxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-Template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-Template-file-name    = search( "exe/kfsale.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-Template-file-name = ?
    or v-Template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-Template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure kfrebaxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/kfreba.xlt":U.
        export "exe/t_form.bas":U.
        export v-kfrebaxl-cell-file-name.
        export v-kfrebaxl-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define stream sout.
define stream in-stream.
define temp-table tt-obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field shift-date-str          as character
  field report-name             as character
  field cre-report              as logical
index pi is primary unique
  obj-type
  obj-code
index name
  obj-name
index cr
  cre-report
.
define temp-table tt-gds no-undo like ub.goods
  field id      as integer
  field b-code  like ub.bar-code.b-code
index pi is primary unique
  id
  gds-code
index gds
  gds-code
index bcode
  b-code
index art
  artic
  prod-type
  prod-code
.
define temp-table tt-report no-undo
  field obj-type                    like ub.rvs-line-pump.obj-type
  field obj-code                    like ub.rvs-line-pump.obj-code
  field pump-code                   like ub.rvs-line-pump.pump-code
  field gds-code                    like ub.rvs-line-pump.gds-code
  field pl-code                     like ub.rvs-line-pump.pl-code
  field obj-name                    as character
  field gds-name                    as character
  field prev-state-measure-qnty     as decimal
  field fact-qnty                   as decimal
  field end-state-el-cnt            as decimal
  field begin-state-el-cnt          as decimal
  field sale-state-el-cnt           as decimal
  field end-state-mh-cnt            as decimal
  field begin-state-mh-cnt          as decimal
  field sale-state-mh-cnt           as decimal
  field state-divergence            as decimal
  field sale-state                  as decimal
  field sale-techfuel               as decimal
  field sale-total                  as decimal
  field place-loc1                  like ub.place.loc1
  field fact-ost-measure-qnty       as decimal
  field fact-ost-state-measure-qnty as decimal
  field end-system-qnty             as decimal
  field fact-divergence             as decimal
index pi is unique primary
  obj-type
  obj-code
  gds-code descending
  pl-code
  pump-code
index rep
  obj-type
  obj-code
  gds-code
  place-loc1
  pump-code
index place
  place-loc1
  pump-code
.
define temp-table tt-pump-pl no-undo
  field obj-type                    like ub.rvs-line-pump.obj-type
  field obj-code                    like ub.rvs-line-pump.obj-code
  field gds-code                    like ub.goods.gds-code
  field pump-code                   like ub.rvs-line-pump.pump-code
  field pl-code                     like ub.rvs-line-pump.pl-code
index pi is unique primary
  obj-type
  obj-code
  gds-code
  pl-code
  pump-code
index pump
  obj-type
  obj-code
  gds-code
  pump-code
.
define variable v-err-message as character no-undo .
do
on error undo, return error return-value
:
  run write-log in this-procedure ( input substitute("Запуск отчета 'Реализация и остатки' для БД &1 " , p-db-num ) ) .
  run clear-tt in this-procedure .
  run write-log in this-procedure ( input "Расчет данных для отчета":U  ) .
  run fill-tt in this-procedure .
  run write-log in this-procedure ( input "Вывод отчета в Excel":U  ) .
  run print-report in this-procedure ( output v-err-message ).
  run clear-tt in this-procedure .
  run write-log in this-procedure ( input "Формирование отчета завершено":U ) .
  if v-err-message <> ''
  then do:
    return error v-err-message.
  end.
end.
procedure clear-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-report.
  empty temp-table tt-obj-list.
  empty temp-table tt-gds.
  empty temp-table tt-pump-pl.
end.
end procedure.
procedure fill-tt :
do
on error undo, return error return-value
:
  run fill-tt-obj-list in this-procedure .
  run fill-tt-gds in this-procedure .
  run fill-tt-report in this-procedure .
end.
end procedure.
procedure fill-tt-obj-list :
  define buffer buf_clients     for ub.clients.
  define buffer buf_db          for ub.db.
  define buffer buf_tt-obj-list for tt-obj-list.
  define variable v-cur-db-num  as integer   no-undo .
do for buf_clients
     , buf_tt-obj-list
on error undo, return error return-value
:
  if p-is-schedule = no
  then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find first buf_clients no-lock
      where buf_clients.obj-type = v-cntxt-obj-type
        and buf_clients.obj-code = v-cntxt-obj-code
    no-error .
    if not available buf_clients
    then do:
      message
        "Не найден текущий объект" skip
      view-as alert-box information.
      undo, return error.
    end.
    create buf_tt-obj-list .
    assign
      buf_tt-obj-list.obj-type = buf_clients.obj-type
      buf_tt-obj-list.obj-code = buf_clients.obj-code
      buf_tt-obj-list.obj-name = buf_clients.obj-name
    .
  end.
  else do:
    assign
      v-cur-db-num = p-db-num
    .
    _cli-cycle:
    for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.stts = 0
    :
      if v-cur-db-num <> 0 and buf_clients.db-num <> v-cur-db-num
      then do:
        run write-log in this-procedure ( input substitute( 'Объект &1 &2 - "&3" УБД &4 текущая БД &5.':u
                                                          , buf_clients.obj-type
                                                          , buf_clients.obj-code
                                                          , buf_clients.obj-name
                                                          , buf_clients.db-num
                                                          , v-cur-db-num
                                                          )
                                        ) .
        next _cli-cycle.
      end.
      find first buf_db no-lock
        where buf_db.db-num = buf_clients.db-num
      no-error .
      if buf_db.send-check = no
      then do:
        run write-log in this-procedure ( input substitute( 'Чеки с объекта &1 &2 - "&3" БД &4 не отсылаются. Объект исключен из списка.':u
                                                          , buf_clients.obj-type
                                                          , buf_clients.obj-code
                                                          , buf_clients.obj-name
                                                          , buf_clients.db-num
                                                          )
                                        ) .
        next _cli-cycle.
      end.
      find first buf_tt-obj-list
        where buf_tt-obj-list.obj-type = buf_clients.obj-type
          and buf_tt-obj-list.obj-code = buf_clients.obj-code
      no-error.
      if not available buf_tt-obj-list
      then do:
        create buf_tt-obj-list .
        assign
          buf_tt-obj-list.obj-type = buf_clients.obj-type
          buf_tt-obj-list.obj-code = buf_clients.obj-code
          buf_tt-obj-list.obj-name = buf_clients.obj-name
        .
      end.
    end.
  end.
end.
end procedure.
procedure fill-tt-gds :
  define buffer buf_prod-bc   for ub.prod-bc.
  define buffer buf_bar-code  for ub.bar-code.
  define buffer buf_goods     for ub.goods.
  define buffer buf_tt-gds    for tt-gds.
  define variable v-sort-list as character no-undo .
  define variable v-sort-type as character no-undo .
  define variable v-i         as integer   no-undo .
  define variable v-str       as character no-undo .
  define variable v-is-petrol as logical   no-undo .
  define variable v-is-pieces as logical   no-undo .
do for buf_prod-bc
     , buf_bar-code
     , buf_goods
     , buf_tt-gds
on error undo, return error return-value
:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'report-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  _thbjattr_thbj-attr:
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'rep-sort'
      then do:
        assign
          v-sort-list  = thbjattr_thbj-attr.property-value-character
        .
        leave _thbjattr_thbj-attr.
      end.
  end.
  if v-sort-list = ? or v-sort-list = "":U
  then do:
    if p-is-schedule = no
    then do:
      message
        "Параметр rep-sort не найден, либо не заполнен.":U
      view-as alert-box error.
    end.
    undo , return error "Параметр rep-sort не найден, либо в нем отсутствуют бар-коды.":U .
  end.
  _rep-sort-cycle:
  do v-i = 1 to num-entries(v-sort-list)
  :
    assign
      v-str = entry( v-i , v-sort-list)
    .
    _gds-cycle:
    for each buf_goods no-lock
      where buf_goods.artic = v-str
    :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
        find first buf_tt-gds
          where buf_tt-gds.gds-code = buf_goods.gds-code
        no-error .
        if not available buf_tt-gds
        then do:
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code no-error .
          create buf_tt-gds.
          buffer-copy buf_goods to buf_tt-gds
          assign
            buf_tt-gds.id     = v-i
            buf_tt-gds.b-code = buf_bar-code.b-code
          .
          next _rep-sort-cycle.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure fill-tt-report :
  define buffer buf_tt-obj-list             for tt-obj-list.
  define buffer buf_tt-gds                  for tt-gds.
  define buffer buf_tt-report               for tt-report.
  define buffer buf_tt-pump-pl              for tt-pump-pl.
  define buffer buf_shift-obj_previous      for ub.shift-obj.
  define buffer buf_shift-obj_begin         for ub.shift-obj.
  define buffer buf_shift-obj_end           for ub.shift-obj.
  define buffer buf_rvs-doc_previous        for ub.rvs-doc.
  define buffer buf_rvs-line_previous       for ub.rvs-line.
  define buffer buf_rvs-line_end            for ub.rvs-line.
  define buffer buf_place                   for ub.place.
  define buffer buf_rvs-doc_begin           for ub.rvs-doc.
  define buffer buf_rvs-doc_end             for ub.rvs-doc.
  define buffer buf_rvs-doc                 for ub.rvs-doc.
  define buffer buf_rvs-line-pump_previous  for ub.rvs-line-pump.
  define buffer buf_rvs-line-pump_begin     for ub.rvs-line-pump.
  define buffer buf_rvs-line-pump_end       for ub.rvs-line-pump.
  define buffer buf_rvs-line-pump           for ub.rvs-line-pump.
  define buffer buf_chk-doc                 for ub.chk-doc.
  define buffer buf_chk-gds                 for ub.chk-gds.
  define buffer buf_trn-doc                 for ub.trn-doc.
  define buffer buf_doc-line                for ub.doc-line.
  define buffer buf_doc-pl                  for ub.doc-pl.
  define buffer buf_pl-pump                 for ub.pl-pump.
  define variable v-date                    as date      no-undo .
  define variable v-time                    as integer   no-undo .
  define variable v-begin-date              as date      no-undo .
  define variable v-end-date                as date      no-undo .
  define variable v-prev-state-measure-qnty as decimal   no-undo .
  define variable v-prev-shift-exist        as logical   no-undo .
  define variable v-varshift-name-begin     as character no-undo .
  define variable v-varshift-name-end       as character no-undo .
  define variable v-varshift-name-num-begin as character no-undo .
  define variable v-varshift-name-num-end   as character no-undo .
  define variable v-rcpt-tech-refuell       as integer   no-undo .
  define variable v-pump                    as integer   no-undo .
  define variable v-qnty                    as decimal   no-undo .
  define variable v-valid-pl                as logical   no-undo .
  define variable v-message                 as character no-undo .
  define variable v-prev-fo                 as decimal   no-undo .
  define variable v-fo                      as decimal   no-undo .
  define variable v-month-list as character no-undo extent 12 initial
    ["января"
    ,"февраля"
    ,"марта"
    ,"апреля"
    ,"мая"
    ,"июня"
    ,"июля"
    ,"августа"
    ,"сентября"
    ,"октября"
    ,"ноября"
    ,"декабря"
    ] .
do for buf_tt-obj-list
     , buf_tt-gds
     , buf_tt-report
     , buf_tt-pump-pl
     , buf_shift-obj_begin
     , buf_shift-obj_end
     , buf_rvs-doc_begin
     , buf_rvs-doc_end
     , buf_rvs-doc
     , buf_rvs-line-pump_previous
     , buf_rvs-line-pump_begin
     , buf_rvs-line-pump_end
     , buf_rvs-line-pump
     , buf_rvs-doc_previous
     , buf_rvs-line_previous
     , buf_rvs-line_end
     , buf_chk-doc
     , buf_chk-gds
     , buf_place
     , buf_trn-doc
     , buf_doc-line
     , buf_doc-pl
     , buf_pl-pump
on error undo, return error return-value
:
  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .
  assign
    v-begin-date        = date ( month(v-date) , 1 , year(v-date) )
    v-end-date          = v-date
    v-rcpt-tech-refuell = integer('17':U)
  .
  _obj-list:
  for each buf_tt-obj-list
  :
    assign
      v-message = "Расчет для " + buf_tt-obj-list.obj-name
    .
    run waitfram-show in this-procedure ( input v-message ) .
    find first buf_shift-obj_begin no-lock
      where buf_shift-obj_begin.obj-type    = buf_tt-obj-list.obj-type
        and buf_shift-obj_begin.obj-code    = buf_tt-obj-list.obj-code
        and buf_shift-obj_begin.shift-date >= v-begin-date
        and buf_shift-obj_begin.status_     = 'зкр':U
    use-index pi
    no-error .
    if not available buf_shift-obj_begin then do:
      run proc-message in this-procedure ( input substitute( "По объекту &1 &2 не найдена первая закрытая смена на &3"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            , string(v-begin-date,"99/99/9999")
                                                            )
                                          ) .
      next _obj-list.
    end.
    find last buf_shift-obj_end no-lock
      where buf_shift-obj_end.obj-type    = buf_tt-obj-list.obj-type
        and buf_shift-obj_end.obj-code    = buf_tt-obj-list.obj-code
        and buf_shift-obj_end.shift-date <= v-end-date
        and buf_shift-obj_end.status_     = 'зкр':U
    use-index pi
    no-error .
    if not available buf_shift-obj_end then do:
      run proc-message in this-procedure ( input substitute( "По объекту &1 &2 не найдена последняя закрытая смена на &3"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            , string(v-end-date,"99/99/9999")
                                                            )
                                          ) .
      next _obj-list.
    end.
    find last buf_shift-obj_previous no-lock
      where buf_shift-obj_previous.obj-type = buf_tt-obj-list.obj-type
        and buf_shift-obj_previous.obj-code = buf_tt-obj-list.obj-code
        and ((    buf_shift-obj_previous.shift-date = buf_shift-obj_begin.shift-date
              and buf_shift-obj_previous.shift-num  < buf_shift-obj_begin.shift-num
             )
             or buf_shift-obj_previous.shift-date < buf_shift-obj_begin.shift-date
            )
    use-index pi no-error.
    if available buf_shift-obj_previous
    then do:
      find first buf_rvs-doc_previous no-lock
        where buf_rvs-doc_previous.obj-type   = buf_tt-obj-list.obj-type
          and buf_rvs-doc_previous.obj-code   = buf_tt-obj-list.obj-code
          and buf_rvs-doc_previous.shift-date = buf_shift-obj_previous.shift-date
          and buf_rvs-doc_previous.shift-num  = buf_shift-obj_previous.shift-num
          and buf_rvs-doc_previous.status_    = 'факт':U
          and buf_rvs-doc_previous.rvs-type   = 'смена':U
      no-error.
      if not available buf_rvs-doc_previous
      then do:
        assign
          v-prev-shift-exist = no
        .
      end.
      else do:
        assign
          v-prev-shift-exist = yes
        .
      end.
    end.
    else do:
      assign
        v-prev-shift-exist = no
      .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input buf_shift-obj_begin.obj-type
  ,  input buf_shift-obj_begin.obj-code
  ,  input buf_shift-obj_begin.shift-date
  ,  input buf_shift-obj_begin.shift-num
  , output v-varshift-name-begin
  , output v-varshift-name-num-begin
  )        no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input buf_shift-obj_end.obj-type
  ,  input buf_shift-obj_end.obj-code
  ,  input buf_shift-obj_end.shift-date
  ,  input buf_shift-obj_end.shift-num
  , output v-varshift-name-end
  , output v-varshift-name-num-end
  )        no-error .
    assign
      v-prev-fo = if available buf_shift-obj_previous then buf_shift-obj_previous.fact-order else 0
      v-fo      = buf_shift-obj_end.fact-order
    .
    empty temp-table buf_tt-pump-pl.
    _rvs-doc-cycle:
    for each buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type   = buf_tt-obj-list.obj-type
        and buf_rvs-doc.obj-code   = buf_tt-obj-list.obj-code
        and buf_rvs-doc.fact-order >= v-prev-fo
        and buf_rvs-doc.fact-order <= v-fo
        and buf_rvs-doc.status_    = 'факт':U
        and buf_rvs-doc.rvs-type   = 'смена':U
    :
      if buf_rvs-doc.shift-date = buf_shift-obj_begin.shift-date
        and buf_rvs-doc.shift-num < buf_shift-obj_begin.shift-num
      then do:
        next _rvs-doc-cycle.
      end.
      if buf_rvs-doc.shift-date = buf_shift-obj_end.shift-date
        and buf_rvs-doc.shift-num > buf_shift-obj_end.shift-num
      then do:
        next _rvs-doc-cycle.
      end.
      for each buf_rvs-line-pump no-lock
        where buf_rvs-line-pump.rvs-code  = buf_rvs-doc.rvs-code
      , first buf_tt-gds
        where buf_tt-gds.gds-code = buf_rvs-line-pump.gds-code
      :
        find first buf_tt-pump-pl
          where buf_tt-pump-pl.obj-type  = buf_tt-obj-list.obj-type
            and buf_tt-pump-pl.obj-code  = buf_tt-obj-list.obj-code
            and buf_tt-pump-pl.gds-code  = buf_tt-gds.gds-code
            and buf_tt-pump-pl.pl-code   = buf_rvs-line-pump.pl-code
            and buf_tt-pump-pl.pump-code = buf_rvs-line-pump.pump-code
        no-error .
        if not available buf_tt-pump-pl
        then do:
          create buf_tt-pump-pl.
          assign
            buf_tt-pump-pl.obj-type  = buf_tt-obj-list.obj-type
            buf_tt-pump-pl.obj-code  = buf_tt-obj-list.obj-code
            buf_tt-pump-pl.gds-code  = buf_tt-gds.gds-code
            buf_tt-pump-pl.pl-code   = buf_rvs-line-pump.pl-code
            buf_tt-pump-pl.pump-code = buf_rvs-line-pump.pump-code
          .
        end.
      end.
    end.
    _chk-doc-cycle:
    for each buf_chk-doc no-lock
      where buf_chk-doc.obj-type    = buf_tt-obj-list.obj-type
        and buf_chk-doc.obj-code    = buf_tt-obj-list.obj-code
        and buf_chk-doc.shift-date >= buf_shift-obj_begin.shift-date
        and buf_chk-doc.shift-date <= buf_shift-obj_end.shift-date
    :
      if buf_chk-doc.shift-date = buf_shift-obj_begin.shift-date and
         buf_chk-doc.shift-num < buf_shift-obj_begin.shift-num
      then do:
        next _chk-doc-cycle.
      end.
      if buf_chk-doc.shift-date = buf_shift-obj_end.shift-date and
         buf_chk-doc.shift-num > buf_shift-obj_end.shift-num
      then do:
        next _chk-doc-cycle.
      end.
      if buf_chk-doc.chk-type <> v-rcpt-tech-refuell
      then do:
        next _chk-doc-cycle.
      end.
      _chk-gds-cycle:
      for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      , first buf_tt-gds no-lock
          where buf_tt-gds.b-code = buf_chk-gds.b-code
      :
        assign
          v-pump = buf_chk-gds.pump
          v-qnty = buf_chk-gds.doc-qnty
        .
        _pl-pump-cycle:
        for each buf_tt-pump-pl
            where buf_tt-pump-pl.obj-type   = buf_tt-obj-list.obj-type
              and buf_tt-pump-pl.obj-code   = buf_tt-obj-list.obj-code
              and buf_tt-pump-pl.gds-code   = buf_tt-gds.gds-code
              and buf_tt-pump-pl.pump-code  = v-pump
        :
          find first buf_tt-report
            where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
              and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
              and buf_tt-report.gds-code  = buf_tt-gds.gds-code
              and buf_tt-report.pl-code   = buf_tt-pump-pl.pl-code
              and buf_tt-report.pump-code = v-pump
          no-error .
          if not available buf_tt-report
          then do:
            create buf_tt-report.
            assign
              buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
              buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
              buf_tt-report.gds-code  = buf_tt-gds.gds-code
              buf_tt-report.pump-code = v-pump
              buf_tt-report.pl-code   = buf_tt-pump-pl.pl-code
              buf_tt-report.gds-name  = buf_tt-gds.gds-name
            .
          end.
          assign
            buf_tt-report.sale-techfuel = buf_tt-report.sale-techfuel + v-qnty
          .
        end.
      end.
    end.
    _trn-doc-cycle:
    for each buf_trn-doc no-lock
      where buf_trn-doc.obj-type    = buf_tt-obj-list.obj-type
        and buf_trn-doc.obj-code    = buf_tt-obj-list.obj-code
        and buf_trn-doc.fact-order >= v-prev-fo
        and buf_trn-doc.fact-order <= v-fo
        and buf_trn-doc.internal    = no
        and buf_trn-doc.status_     = 'факт':U
        and buf_trn-doc.doc-type    = 'при':U
    use-index fact-order
    :
      if buf_trn-doc.shift-date = buf_shift-obj_begin.shift-date
         and buf_trn-doc.shift-num < buf_shift-obj_begin.shift-num
      then do:
        next _trn-doc-cycle.
      end.
      if buf_trn-doc.shift-date = buf_shift-obj_end.shift-date
         and buf_trn-doc.shift-num > buf_shift-obj_end.shift-num
      then do:
        next _trn-doc-cycle.
      end.
      _doc-line-cycle:
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code   = buf_trn-doc.doc-code
      , first buf_tt-gds
        where buf_doc-line.artic      = buf_tt-gds.artic
          and buf_doc-line.prod-type  = buf_tt-gds.prod-type
          and buf_doc-line.prod-code  = buf_tt-gds.prod-code
      :
        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = buf_tt-obj-list.obj-type
            and buf_doc-pl.obj-code = buf_tt-obj-list.obj-code
            and buf_doc-pl.out-code = buf_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_tt-gds.gds-code
        , each buf_pl-pump no-lock
            where buf_pl-pump.obj-type  = buf_doc-pl.obj-type
              and buf_pl-pump.obj-code  = buf_doc-pl.obj-code
              and buf_pl-pump.pl-code   = buf_doc-pl.pl-code
        :
          find first buf_tt-report
            where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
              and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
              and buf_tt-report.gds-code  = buf_tt-gds.gds-code
              and buf_tt-report.pl-code   = buf_doc-pl.pl-code
              and buf_tt-report.pump-code = buf_pl-pump.pump-code
          no-error .
          if not available buf_tt-report
          then do:
            create buf_tt-report.
            assign
              buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
              buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
              buf_tt-report.gds-code  = buf_tt-gds.gds-code
              buf_tt-report.pl-code   = buf_doc-pl.pl-code
              buf_tt-report.pump-code = buf_pl-pump.pump-code
              buf_tt-report.gds-name  = buf_tt-gds.gds-name
            .
          end.
          assign
            buf_tt-report.fact-qnty = buf_tt-report.fact-qnty + buf_doc-pl.fact-qnty
          .
        end.
      end.
    end.
    if v-prev-shift-exist = yes
    then do:
      for each buf_rvs-line-pump_previous no-lock
        where buf_rvs-line-pump_previous.rvs-code = buf_rvs-doc_previous.rvs-code
      , first buf_tt-gds
          where buf_tt-gds.gds-code = buf_rvs-line-pump_previous.gds-code
      :
        find first buf_tt-report
          where buf_tt-report.obj-type  = buf_rvs-line-pump_previous.obj-type
            and buf_tt-report.obj-code  = buf_rvs-line-pump_previous.obj-code
            and buf_tt-report.gds-code  = buf_rvs-line-pump_previous.gds-code
            and buf_tt-report.pl-code   = buf_rvs-line-pump_previous.pl-code
            and buf_tt-report.pump-code = buf_rvs-line-pump_previous.pump-code
        no-error .
        if not available buf_tt-report
        then do:
          create buf_tt-report.
          assign
            buf_tt-report.obj-type  = buf_rvs-line-pump_previous.obj-type
            buf_tt-report.obj-code  = buf_rvs-line-pump_previous.obj-code
            buf_tt-report.gds-code  = buf_rvs-line-pump_previous.gds-code
            buf_tt-report.pump-code = buf_rvs-line-pump_previous.pump-code
            buf_tt-report.gds-name  = buf_tt-gds.gds-name
            buf_tt-report.pl-code   = buf_rvs-line-pump_previous.pl-code
          .
        end.
       find first buf_rvs-line_previous no-lock
          where buf_rvs-line_previous.rvs-code  = buf_rvs-doc_previous.rvs-code
            and buf_rvs-line_previous.obj-type  = buf_rvs-line-pump_previous.obj-type
            and buf_rvs-line_previous.obj-code  = buf_rvs-line-pump_previous.obj-code
            and buf_rvs-line_previous.pl-code   = buf_rvs-line-pump_previous.pl-code
            and buf_rvs-line_previous.gds-code  = buf_tt-gds.gds-code
        no-error .
        assign
          buf_tt-report.begin-state-el-cnt      = buf_tt-report.begin-state-el-cnt + buf_rvs-line-pump_previous.state-el-cnt
          buf_tt-report.begin-state-mh-cnt      = buf_tt-report.begin-state-mh-cnt + buf_rvs-line-pump_previous.state-mh-cnt
          buf_tt-report.prev-state-measure-qnty = if available buf_rvs-line_previous then buf_rvs-line_previous.state-measure-qnty else 0.0
        .
      end.
    end.
    else do:
      find first buf_rvs-doc_begin no-lock
        where buf_rvs-doc_begin.obj-type   = buf_tt-obj-list.obj-type
          and buf_rvs-doc_begin.obj-code   = buf_tt-obj-list.obj-code
          and buf_rvs-doc_begin.shift-date = buf_shift-obj_begin.shift-date
          and buf_rvs-doc_begin.shift-num  = buf_shift-obj_begin.shift-num
          and buf_rvs-doc_begin.status_    = 'факт':U
          and buf_rvs-doc_begin.rvs-type   = 'смена':U
      no-error.
      if not available buf_rvs-doc_begin
      then do:
        run proc-message in this-procedure ( input substitute( "Для объекта &1 &2 не найдена сменная сверка для смены &3 &4"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            , buf_shift-obj_begin.shift-date
                                                            , buf_shift-obj_begin.shift-num
                                                            )
                                          ) .
        next _obj-list.
      end.
      for each buf_rvs-line-pump_begin no-lock
        where buf_rvs-line-pump_begin.rvs-code = buf_rvs-doc_begin.rvs-code
      , first buf_tt-gds
          where buf_tt-gds.gds-code = buf_rvs-line-pump_begin.gds-code
      :
        find first buf_tt-report
          where buf_tt-report.obj-type  = buf_rvs-line-pump_begin.obj-type
            and buf_tt-report.obj-code  = buf_rvs-line-pump_begin.obj-code
            and buf_tt-report.gds-code  = buf_rvs-line-pump_begin.gds-code
            and buf_tt-report.pl-code   = buf_rvs-line-pump_begin.pl-code
            and buf_tt-report.pump-code = buf_rvs-line-pump_begin.pump-code
        no-error .
        if not available buf_tt-report
        then do:
          create buf_tt-report.
          assign
            buf_tt-report.obj-type  = buf_rvs-line-pump_begin.obj-type
            buf_tt-report.obj-code  = buf_rvs-line-pump_begin.obj-code
            buf_tt-report.gds-code  = buf_rvs-line-pump_begin.gds-code
            buf_tt-report.pump-code = buf_rvs-line-pump_begin.pump-code
            buf_tt-report.gds-name  = buf_tt-gds.gds-name
            buf_tt-report.pl-code   = buf_rvs-line-pump_begin.pl-code
          .
        end.
        assign
          buf_tt-report.begin-state-el-cnt      = buf_tt-report.begin-state-el-cnt + buf_rvs-line-pump_begin.state-el-cnt
          buf_tt-report.begin-state-mh-cnt      = buf_tt-report.begin-state-mh-cnt + buf_rvs-line-pump_begin.state-mh-cnt
          buf_tt-report.prev-state-measure-qnty = 0.0
        .
      end.
    end.
    find first buf_rvs-doc_end no-lock
      where buf_rvs-doc_end.obj-type   = buf_tt-obj-list.obj-type
        and buf_rvs-doc_end.obj-code   = buf_tt-obj-list.obj-code
        and buf_rvs-doc_end.shift-date = buf_shift-obj_end.shift-date
        and buf_rvs-doc_end.shift-num  = buf_shift-obj_end.shift-num
        and buf_rvs-doc_end.status_    = 'факт':U
        and buf_rvs-doc_end.rvs-type   = 'смена':U
    no-error.
    if not available buf_rvs-doc_end
    then do:
      next _obj-list.
    end.
    for each buf_rvs-line-pump_end no-lock
      where buf_rvs-line-pump_end.rvs-code = buf_rvs-doc_end.rvs-code
    , first buf_tt-gds
        where buf_tt-gds.gds-code = buf_rvs-line-pump_end.gds-code
    :
      find first buf_tt-report
        where buf_tt-report.obj-type  = buf_rvs-line-pump_end.obj-type
          and buf_tt-report.obj-code  = buf_rvs-line-pump_end.obj-code
          and buf_tt-report.gds-code  = buf_rvs-line-pump_end.gds-code
          and buf_tt-report.pl-code   = buf_rvs-line-pump_end.pl-code
          and buf_tt-report.pump-code = buf_rvs-line-pump_end.pump-code
      no-error .
      if not available buf_tt-report
      then do:
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_rvs-line-pump_end.obj-type
          buf_tt-report.obj-code  = buf_rvs-line-pump_end.obj-code
          buf_tt-report.gds-code  = buf_rvs-line-pump_end.gds-code
          buf_tt-report.pump-code = buf_rvs-line-pump_end.pump-code
          buf_tt-report.gds-name  = buf_tt-gds.gds-name
          buf_tt-report.pl-code   = buf_rvs-line-pump_end.pl-code
        .
      end.
      assign
        buf_tt-report.end-state-el-cnt = buf_tt-report.end-state-el-cnt + buf_rvs-line-pump_end.state-el-cnt
        buf_tt-report.end-state-mh-cnt = buf_tt-report.end-state-mh-cnt + buf_rvs-line-pump_end.state-mh-cnt
      .
      find first buf_rvs-line_end no-lock
        where buf_rvs-line_end.rvs-code  = buf_rvs-doc_end.rvs-code
          and buf_rvs-line_end.obj-type  = buf_rvs-line-pump_end.obj-type
          and buf_rvs-line_end.obj-code  = buf_rvs-line-pump_end.obj-code
          and buf_rvs-line_end.pl-code   = buf_rvs-line-pump_end.pl-code
          and buf_rvs-line_end.gds-code  = buf_tt-gds.gds-code
      no-error .
      assign
        buf_tt-report.fact-ost-measure-qnty       = if available buf_rvs-line_end then buf_rvs-line_end.measure-qnty        else 0.0
        buf_tt-report.fact-ost-state-measure-qnty = if available buf_rvs-line_end then buf_rvs-line_end.state-measure-qnty  else 0.0
        buf_tt-report.end-system-qnty             = if available buf_rvs-line_end then buf_rvs-line_end.system-qnty         else 0.0
      .
    end.
    assign
      buf_tt-obj-list.cre-report      = yes
      buf_tt-obj-list.shift-date-str  = substitute( "с: &1 от &2 &3 по: &4 от &5 &6 закрыта &7 &8"
                                                  , string( v-varshift-name-begin                         )
                                                  , string( buf_shift-obj_begin.open-date , "99/99/9999"  )
                                                  , string( buf_shift-obj_begin.open-time , "hh:mm"       )
                                                  , string( v-varshift-name-end                           )
                                                  , string( buf_shift-obj_end.open-date , "99/99/9999"    )
                                                  , string( buf_shift-obj_end.open-time , "hh:mm"         )
                                                  , string( buf_shift-obj_end.close-date,"99/99/9999"     )
                                                  , string( buf_shift-obj_end.close-time,"hh:mm"          )
                                                  )
      buf_tt-obj-list.report-name     = substitute( "Реализация_и_остатки_с_начала_месяца_&1_по_&2_&3_&4-&5"
                                                  , v-month-list[month(v-date)]
                                                  , string(year(buf_shift-obj_end.shift-date)  , "9999")
                                                  , string(month(buf_shift-obj_end.shift-date) , "99"  )
                                                  , string(day(buf_shift-obj_end.shift-date)   , "99"  )
                                                  , v-varshift-name-end
                                                  )
    .
    empty temp-table buf_tt-pump-pl.
  end.
  run waitfram-show in this-procedure ( input "Расчет данных..." ) .
  for each buf_tt-report
  :
    find first buf_place no-lock
      where buf_place.obj-type = buf_tt-report.obj-type
        and buf_place.obj-code = buf_tt-report.obj-code
        and buf_place.pl-code  = buf_tt-report.pl-code
    no-error .
    assign
      buf_tt-report.place-loc1        = if available buf_place then buf_place.loc1 else ''
      buf_tt-report.sale-state-el-cnt = buf_tt-report.end-state-el-cnt  - buf_tt-report.begin-state-el-cnt
      buf_tt-report.sale-state-mh-cnt = buf_tt-report.end-state-mh-cnt  - buf_tt-report.begin-state-mh-cnt
      buf_tt-report.state-divergence  = buf_tt-report.sale-state-mh-cnt - buf_tt-report.sale-state-el-cnt
      buf_tt-report.sale-state        = buf_tt-report.sale-state-mh-cnt
      buf_tt-report.sale-total        = buf_tt-report.sale-state - buf_tt-report.sale-techfuel
      buf_tt-report.fact-divergence   = buf_tt-report.fact-ost-state-measure-qnty - buf_tt-report.end-system-qnty
    .
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure print-report :
  define output parameter p-error-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run print-schedule in this-procedure ( output p-error-message).
  end.
  else do:
    run print-no-schedule in this-procedure .
  end.
end.
end procedure.
procedure print-schedule :
  define output parameter p-error-message as character no-undo .
  define buffer buf_temp-param for temp-param .
  define variable v-report-dir            as character    no-undo .
  define variable v-filename              as character    no-undo .
  define variable v-obj-dir               as character    no-undo .
  define variable v-report-filename       as character    no-undo .
  define variable v-home-dir-filename     as character    no-undo .
  define variable v-error-num             as integer      no-undo .
  define variable v-template-file-name    as character    no-undo .
  define variable v-vb-file-name          as character    no-undo .
  define variable v-data-header-filename  as character    no-undo .
  define variable v-data-filename         as character    no-undo .
  define variable v-excel-file-name       as character    no-undo .
  define variable v-err-message           as character    no-undo .
  define variable v-obj-errors            as character    no-undo .
  define variable v-os-err-str            as character    no-undo .
  define variable v-message               as character    no-undo .
do for buf_temp-param
on error undo, return error return-value
:
  assign
    v-report-dir  = trim( replace( p-report-dir, '/' , '\' ) , '\' )
  .
  _obj-cycle:
  for each tt-obj-list
    where tt-obj-list.cre-report = yes
  by tt-obj-list.obj-type
  by tt-obj-list.obj-code
  :
    assign
      v-message = "Выгрузка отчета для " + tt-obj-list.obj-name
    .
    run waitfram-show in this-procedure ( input v-message ) .
    run write-log in this-procedure ( input v-message  ) .
    run paramls-clear in this-procedure .
    run kfrebaxl-init in this-procedure.
    run kfrebaxl-write-cell-data in this-procedure ( input "h_date":U , input tt-obj-list.shift-date-str ).
    run kfrebaxl-write-cell-data in this-procedure ( input "h_obj":U  , input tt-obj-list.obj-name       ).
    for each tt-gds
    , each tt-report
      where tt-report.obj-type = tt-obj-list.obj-type
        and tt-report.obj-code = tt-obj-list.obj-code
        and tt-report.gds-code = tt-gds.gds-code
    by tt-gds.id descending
    by tt-report.place-loc1
    by tt-report.pump-code
    :
      run kfrebaxl-sheet1-write-line-data in this-procedure
            ( input tt-report.pump-code
            , input tt-report.gds-name
            , input tt-report.prev-state-measure-qnty
            , input tt-report.fact-qnty
            , input tt-report.end-state-el-cnt
            , input tt-report.begin-state-el-cnt
            , input tt-report.sale-state-el-cnt
            , input tt-report.end-state-mh-cnt
            , input tt-report.begin-state-mh-cnt
            , input tt-report.sale-state-mh-cnt
            , input tt-report.state-divergence
            , input tt-report.sale-state
            , input tt-report.sale-techfuel
            , input tt-report.sale-total
            , input tt-report.place-loc1
            , input tt-report.fact-ost-measure-qnty
            , input tt-report.fact-ost-state-measure-qnty
            , input tt-report.end-system-qnty
            , input tt-report.fact-divergence
            ).
    end .
    run kfrebaxl-close in this-procedure.
    assign
      v-filename          = string( session:temp-directory ) + "rpt" + string( g#report-num )
      v-obj-dir           = v-report-dir + '/' + tt-obj-list.obj-name
      v-excel-file-name   = string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".xls"
      v-home-dir-filename = v-obj-dir +  "/" + tt-obj-list.report-name + ".xls"
    .
    os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( v-filename + ".txl" )
    .
    assign
      v-filename = search( v-filename + ".txl" )
    .
    if v-filename = "" or v-filename = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Не найден файл &1 для формирования Excel-файла по объекту &2 &3&4&4"
                                                 , string( session:temp-directory ) + "rpt" + string( g#report-num )
                                                 , tt-obj-list.obj-type
                                                 , tt-obj-list.obj-code
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
      next _obj-cycle.
    end.
    input stream in-stream from value( v-filename ).
    import stream in-stream v-template-file-name   no-error .
    import stream in-stream v-vb-file-name         no-error .
    import stream in-stream v-data-header-filename no-error .
    import stream in-stream v-data-filename        no-error .
    input stream in-stream close.
    if search( v-template-file-name ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Не найден шаблон Excel для вывода данных.&2Указан файл шаблона:&1&2&2"
                                                 , v-template-file-name
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if search( v-vb-file-name ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors +  substitute( "Не найден текст программы заполнения шаблона Excel.&3Файл шаблона:&1&3Указан файл программы:&2&3&3"
                                                  , v-template-file-name
                                                  , v-vb-file-name
                                                  , chr(10)
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if v-data-header-filename <> "":U
    and search( v-data-header-filename ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors +  substitute( "Не найден файл шапки.&3Файл шаблона:&1&3Указан файл шапки:&2&3&3"
                                                  , v-template-file-name
                                                  , v-data-header-filename
                                                  , chr(10)
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if v-data-filename <> "":U
    and search( v-data-filename )   = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Не найден файл строк данных.&3Файл шаблона:&1&3Указан файл строк данных:&2&3&3"
                                                 , v-template-file-name
                                                 , v-data-filename
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    create buf_temp-param.
    assign
      v-template-file-name = search( v-template-file-name )
      file-info :file-name = v-template-file-name
      v-template-file-name = file-info :full-pathname
      v-vb-file-name       = search( v-vb-file-name )
      file-info :file-name = v-vb-file-name
      v-vb-file-name       = file-info :full-pathname
    .
    if v-template-file-name = ? or v-template-file-name = "":U
    then do:
      next _obj-cycle.
    end.
    run paramls-write in this-procedure ( input "template":U
                                        , input "template-file-name":U
                                        , input v-template-file-name
                                        ).
    run paramls-write in this-procedure ( input "template":U
                                        , input "vb-file-name":U
                                        , input v-vb-file-name
                                        ).
    run paramls-write in this-procedure ( input "data":U
                                        , input "data-header-filename":U
                                        , input v-data-header-filename
                                        ).
    run paramls-write in this-procedure ( input "data":U
                                        , input "data-filename":U
                                        , input v-data-filename
                                        ).
    run paramls-write in this-procedure ( input "saveas":U
                                        , input "excel-file-name":U
                                        , input v-excel-file-name
                                        ).
    run paramls-write in this-procedure ( input "file":U
                                        , input "file-no-open":U
                                        , input "yes":U
                                        ).
    run gbl/macroxlt.p ( input-output table buf_temp-param ) no-error.
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "&1&2&3&4Ошибка создания файла Excel.&4&5&4&6&4&7&4&8&4&4"
                                                 , vss-workfile
                                                 , vss-revision
                                                 , vss-description
                                                 , chr(10)
                                                 , return-value
                                                 , trim(error-status :get-message(1))
                                                 , trim(error-status :get-message(2))
                                                 , trim(error-status :get-message(3))
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run gbl/del-file.p ( input v-filename ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors +  substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                  , v-filename
                                                  , return-value
                                                  , chr(10)
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run gbl/dir-cre.p ( input v-obj-dir ) no-error  .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Ошибка создания директории &1: &2&4&3&4&4"
                                                 , v-filename
                                                 , return-value
                                                 , trim(error-status :get-message(1))
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run gbl/del-file.p ( input v-home-dir-filename ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                 , v-home-dir-filename
                                                 , return-value
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run gbl/ren-file.p ( input v-excel-file-name
                       , input v-home-dir-filename
                       ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors + substitute( "Ошибка перемещения файла &1 -> &2: &3&4&4"
                                                 , v-excel-file-name
                                                 , v-home-dir-filename
                                                 , return-value
                                                 , chr(10)
                                                 )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run write-log in this-procedure ( input v-obj-errors ) .
    assign
      v-obj-errors = ''
    .
  end.
  run waitfram-hide in this-procedure .
  assign
    p-error-message = v-err-message
  .
end.
end procedure.
procedure print-no-schedule :
do
on error undo, return error return-value
:
  run get-report-num in parparentproc (output g#report-num).
output stream sout to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  put stream sout unformatted "Отчет формируется только в Excel." skip(2).
  output stream sout close.
  run kfrebaxl-init in this-procedure.
  for each tt-obj-list
  :
    run kfrebaxl-write-cell-data in this-procedure ( input "h_date":U , input tt-obj-list.shift-date-str ).
    run kfrebaxl-write-cell-data in this-procedure ( input "h_obj":U  , input tt-obj-list.obj-name       ).
    for each tt-gds
    , each tt-report
      where tt-report.obj-type = tt-obj-list.obj-type
        and tt-report.obj-code = tt-obj-list.obj-code
        and tt-report.gds-code = tt-gds.gds-code
    by tt-gds.id descending
    by tt-report.place-loc1
    by tt-report.pump-code
    :
      run kfrebaxl-sheet1-write-line-data in this-procedure
            ( input tt-report.pump-code
            , input tt-report.gds-name
            , input tt-report.prev-state-measure-qnty
            , input tt-report.fact-qnty
            , input tt-report.end-state-el-cnt
            , input tt-report.begin-state-el-cnt
            , input tt-report.sale-state-el-cnt
            , input tt-report.end-state-mh-cnt
            , input tt-report.begin-state-mh-cnt
            , input tt-report.sale-state-mh-cnt
            , input tt-report.state-divergence
            , input tt-report.sale-state
            , input tt-report.sale-techfuel
            , input tt-report.sale-total
            , input tt-report.place-loc1
            , input tt-report.fact-ost-measure-qnty
            , input tt-report.fact-ost-state-measure-qnty
            , input tt-report.end-system-qnty
            , input tt-report.fact-divergence
            ).
    end .
  end.
  run kfrebaxl-close in this-procedure.
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable ReportFontNum   as integer   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
end procedure.
procedure write-log :
  define input  parameter p-str as character no-undo .
do
on error undo, return error return-value
:
  if p-str = ""
  then do:
    return.
  end.
  if p-is-schedule = yes
  then do:
    if parparentproc :get-signature("write-to-log") <> "":u
    then do:
      run write-to-log in parparentproc ( input p-str ) .
    end.
    assign
      p-str = substitute("&1 &2&3", cur-time-string-sec() , p-str, chr(10))
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    run gbl/fileapnd.p
      ( input "r-kfreba.log"
       ,input p-str
       ,input 10
      ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
end.
end procedure.
procedure proc-message :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run write-log in this-procedure ( input p-message ) .
  end.
  else do:
    message
      p-message
    view-as alert-box information.
  end.
end.
end procedure.
