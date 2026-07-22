block-level on error undo, throw.
define input parameter iParam as ibs.th.ref.sobj.sParamObj no-undo .
define var parparentproc as widget-handle no-undo .
parparentproc = iParam:my-handle.
define var p-parent-handle          as handle                  no-undo .
define var p-rdbh                   as handle                  no-undo .
define var p-log-handle             as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-det-obj                as logical                 no-undo .
define input parameter p-det-oper               as logical                 no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .
define variable vss-revision    as character no-undo init "$Revision: 84c6c67137c5, 2693, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:05 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ddinam.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ddinam.p $":U .
define variable vss-description as character no-undo init "Движение денежных средств".
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
define   temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
define variable v-delim as character no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
iParam:get-obj-list(output table obj-list).
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info8 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable g#report-num as integer no-undo .
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE fostatok :
define input parameter p-host-code   as integer no-undo .
define input parameter x-store-code  like ub.clients.obj-code    no-undo.
define input parameter x-store-type  like ub.clients.obj-type    no-undo.
define input parameter x-tog-shift   as   logical             no-undo.
define input parameter x-date-start  as date        no-undo.
define input parameter x-date-end    as date        no-undo.
define input parameter x-shift-start as integer     no-undo.
define input parameter x-shift-end   as integer     no-undo.
define input parameter xTog-obj   as logical no-undo.
define input parameter p-curr-code as integer no-undo .
define input parameter p-cashbookid as integer  no-undo .
define output parameter sum       as decimal   no-undo.
define output parameter Fact-order  as decimal  no-undo.
define variable Fact-order#   as decimal  no-undo.
define variable Fact-orderS   as character  no-undo.
define variable x-date-start-t  as date   no-undo.
define variable x-sum-type as character no-undo .
    if x-tog-shift then do:
      assign
      x-sum-type = 'shift-obj':U.
    end.
    else do:
      x-sum-type = 'obj':U.
    end.
Assign
Fact-order   = 0
sum     = 0
x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
  Fact-order = 0 .
  For each obj-list no-lock
      WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type
              AND
              x-store-code = obj-list.obj-code))
  :
   fact-order# = 0.
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
          arh-fin-doc-schet-nal-obj.Fact-date <=  x-date-start
          USE-INDEX fact-date  no-error .
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   End.
   Else  DO :
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
           (arh-fin-doc-schet-nal-obj.shift-date  = x-date-start-t and
            arh-fin-doc-schet-nal-obj.shift-num  < x-shift-start or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-start-t  )
            and arh-fin-doc-schet-nal-obj.shift-num  > 0
            USE-INDEX Shift-num no-error .
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  no-lock WHERE
     (NOT xTog-obj
      OR
      (x-store-type = obj-list.obj-type
      AND
      x-store-code = obj-list.obj-code))
   :
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            arh-fin-doc-schet-nal-obj.Fact-date <= x-date-end
            and arh-fin-doc-schet-nal-obj.shift-num = 0
            USE-INDEX fact-date no-error.
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   END.
   Else DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            (arh-fin-doc-schet-nal-obj.shift-date  = x-date-end and
            arh-fin-doc-schet-nal-obj.shift-num  <= x-shift-end or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-end       ) and
            arh-fin-doc-schet-nal-obj.shift-num   > 0      use-index shift-num no-error.
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure reprumpr_print-plain-text :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define variable v-err-status as integer no-undo .
define variable v-err-mess as character no-undo .
v-file-name = p-dir-name + (if p-subdir-name <> ''
                            then (p-subdir-name + chr(47))
                            else '') +
              p-custom-name.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
os-copy
value(v-report-name)
value(v-file-name)
.
assign
v-err-status = os-error
.
if v-err-status <> 0 then do:
  run gbl/os-errnm.p ( input v-err-status
                      ,output v-err-mess).
  return error v-err-mess.
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'text':U
                                                ,input v-file-name
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
procedure reprumpr_print-printer :
define input parameter p-font-number as integer no-undo .
define input parameter p-flags as integer no-undo .
define variable v-quest-print as logical no-undo .
define variable lok as logical no-undo .
define variable v-report-name as character no-undo .
run get-quest-print in parparentproc ( output v-quest-print) .
if not v-quest-print then do:
    .
  run prn-lib-get-report-name  in this-procedure (
                                                    input parParentProc
                                                   ,output v-report-name
                                                  ).
  run adecomm/_osprint.p
    (input  ?
    ,input  v-report-name
    ,input  p-font-number
    ,input  p-flags
    ,input  0
    ,input  0
    ,output lok
    ).
  if not lok then do:
  end.
end.
end procedure.
procedure reprumpr_print-xls :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define buffer buf_sheetf for sheetf.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                 ,output v-report-name
                                                ).
v-file-name = p-dir-name +
             (if p-subdir-name <> ''
             then (p-subdir-name + chr(47))
             else '') +
             p-custom-name.
find first buf_sheetf where
         buf_sheetf.sheet-num = 1.
assign
buf_sheetf.file-name = v-file-name
buf_sheetf.silent-save = yes
.
release buf_sheetf.
run rep/runexcel.p ( input (v-report-name + ".txt")) no-error.
if error-status:error then do:
  return error return-value .
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'excel':U
                                                ,input v-file-name
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
define NEW SHARED variable is-rosneft as logical no-undo init NO.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-cntxt-obj-name as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define temp-table temp-fin-doc no-undo
    FIELD sheet-num     as integer
    FIELD host-code     as integer
    FIELD obj-code      as integer
    FIELD obj-type      as character
    FIELD obj-name      as character
    FIELD ost-begin     as decimal
    FIELD income-realiz as decimal
    FIELD income-ras    as decimal
    FIELD income-other  as decimal
    FIELD expense-bank  as decimal
    FIELD expense-ras   as decimal
    FIELD expense-other as decimal
    FIELD ost-end       as decimal
    FIELD ost-end-ras   as decimal
    FIELD staff-curr1   as character
    FIELD staff-curr2   as character
    FIELD staff-curr3   as character
    FIELD staff-curr4   as character
    FIELD staff-curr5   as character
    FIELD staff-next1   as character
    FIELD staff-next2   as character
    FIELD staff-next3   as character
    FIELD staff-next4   as character
    FIELD staff-next5   as character
        field cashbook      as character
        field cashbookid    as integer
  INDEX pi is primary unique host-code obj-code obj-type cashbookid
  .
define buffer buf_clients                   for ub.clients .
define buffer buf_obj-list                  for obj-list .
define buffer buf_fin-doc                   for ub.fin-doc .
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_clients-attr              for ub.clients-attr .
define buffer buf_shift-staff               for ub.shift-staff .
define buffer buf_sysconf                   for ub.sysconf .
define buffer buf_cashbook                  for ub.CashBook .
define buffer buf_chk-doc                   for ub.chk-doc .
define buffer buf_shift-obj                 for ub.shift-obj .
define buffer buf_cash-pay                  for ub.cash-pay .
define buffer buf_chk-pay                   for ub.chk-pay .
define buffer buf_chk-gds-pay               for ub.chk-gds-pay .
define buffer buf_chk-gds                   for ub.chk-gds .
define buffer buf_bar-code                  for ub.bar-code .
define buffer buf_goods-attr                for ub.goods-attr .
define variable v-cash              as integer   no-undo .
define variable v-count             as integer   no-undo .
define variable v-str               as integer   no-undo .
define variable v-firm              as character no-undo .
define variable v-object            as character no-undo .
define variable v-host-code         as integer   no-undo .
define variable v-sum-begin         as decimal   no-undo .
define variable sum1                as decimal   no-undo .
define variable f-ost-begin         as character no-undo .
define variable f-cashf-begin       as character no-undo .
define variable f-income-realiz     as character no-undo .
define variable f-income-other      as character no-undo .
define variable f-expense-bank      as character no-undo .
define variable f-expense-other     as character no-undo .
define variable f-ost-end           as character no-undo .
define variable f-cashf-end         as character no-undo .
define variable v-ost-begin         as decimal   no-undo .
define variable v-income-realiz     as decimal   no-undo .
define variable v-income-ras        as decimal   no-undo .
define variable v-income-other      as decimal   no-undo .
define variable v-expense-bank      as decimal   no-undo .
define variable v-expense-ras       as decimal   no-undo .
define variable v-expense-other     as decimal   no-undo .
define variable v-ost-end           as decimal   no-undo .
define variable v-ost-end-ras       as decimal   no-undo .
define variable v-sheet             as integer   no-undo .
define variable v-obj-name          as character no-undo .
define variable v-obj-type1         as character no-undo .
define variable v-obj-code1         as integer   no-undo .
define variable v-num-obj           as integer   no-undo .
define variable v-col1              as decimal   no-undo .
define variable v-col2              as decimal   no-undo .
define variable v-col3              as decimal   no-undo .
define variable v-col45             as decimal   no-undo .
define variable v-col4              as decimal   no-undo .
define variable v-col5              as decimal   no-undo .
define variable v-col6              as decimal   no-undo .
define variable v-col7              as decimal   no-undo .
define variable v-col31             as decimal   no-undo .
define variable v-col41             as decimal   no-undo .
define variable v-col1-propis       as character no-undo .
define variable v-col3-propis       as character no-undo .
define variable v-col45-propis      as character no-undo .
define variable v-col4-propis       as character no-undo .
define variable v-col5-propis       as character no-undo .
define variable v-col6-propis       as character no-undo .
define variable v-col7-propis       as character no-undo .
define variable abbr                as character no-undo .
define variable v-ost-begin-all     as decimal   no-undo .
define variable v-income-realiz-all as decimal   no-undo .
define variable v-income-ras-all    as decimal   no-undo .
define variable v-income-other-all  as decimal   no-undo .
define variable v-expense-bank-all  as decimal   no-undo .
define variable v-expense-ras-all   as decimal   no-undo .
define variable v-expense-other-all as decimal   no-undo .
define variable v-ost-end-all       as decimal   no-undo .
define variable v-ost-end-ras-all   as decimal   no-undo .
define variable x-store-code        like ub.clients.obj-code no-undo .
define variable x-store-type        like ub.clients.obj-type no-undo .
define variable Fact-order-1        like ub.stk-tot.Fact-order no-undo .
define variable Fact-order-2        like ub.stk-tot.Fact-order no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo init -1.
define variable Counter1            as integer   no-undo .
define variable v-date-name         as character no-undo .
define variable v-shift-on          as logical   no-undo .
define variable v-sheet-num         as integer   no-undo .
define variable v-user-action       as character no-undo .
define variable v-printed           as logical   no-undo .
define variable disabledoptions     as integer   no-undo .
define variable v-orient-page       as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-file-name-ind     as integer   no-undo .
define variable v-line              as character no-undo .
define variable v-underline         as character no-undo .
define variable v-fio-sign          as character no-undo .
define variable v-par-type          as character no-undo .
define variable v-cashbook          as character no-undo .
define variable v-cashbookid        as integer   no-undo .
define variable v-shift-date        as date      no-undo .
define variable v-shift-num         like ub.shift-obj.shift-name no-undo .
define variable v-shift-name        like ub.shift-obj.shift-name no-undo .
define variable v-curr-time         as character no-undo .
define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html .
define variable v-file-name-rep-htm as character no-undo .
FUNCTION fnc-cur-time-print returns character FORWARD.
run get-report-num (output p-report-id).
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
v-curr-time = fnc-cur-time-print().
for each obj-list by obj-list.obj-name :
    if v-obj-code = -1 then
    do:
        assign
            v-obj-type = obj-list.obj-type
            v-obj-code = obj-list.obj-code.
    end.
    else
    do:
        assign
            v-obj-type = ''
            v-obj-code = 0
            .
    end.
    assign
        v-shift-on = yes
        .
if p-det-oper and obj-list.db-num = g#db-num then do:
for first ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
                                     ub.shift-obj.obj-type = obj-list.obj-type and
                                     ub.shift-obj.status_ = 'зкр':U and
                                     ub.shift-obj.shift-date = iParam:X-date-end and
                                     ub.shift-obj.shift-num = iParam:X-shift-end:
                    if VALID-HANDLe(p-log-handle)    then do:                           if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1Оперативный отчет снимается ТОЛЬКО за открытую смену" +                                        chr(10)                                        , return-value                                          ,error-status:get-message(1) )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1Оперативный отчет снимается ТОЛЬКО за открытую смену" +                                        chr(10)                                        , return-value                                          ,error-status:get-message(1) )).    end.    end.    else do:       message substitute("&1Оперативный отчет снимается ТОЛЬКО за открытую смену" +                                        chr(10)                                        , return-value                                          ,error-status:get-message(1) ) view-as alert-box.    end.
         undo, return error .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
   if error-status:error then
   do:
   end.
   else
   do:
      run str/diallog.w (  input parparentproc
         , input this-procedure
         , input 'str/get-chkf.p':U
         , input (obj-list.obj-type + chr(4) + string(obj-list.obj-code) + chr(4) +
         string(0)  + chr(4) + string(0) + chr(4) + string(- 1) + chr(4) +
         string(v-shift-num) + chr(4) + replace(string(v-shift-date, "99/99/9999"), chr(47) , "":U)
         )
         , input no
         , input '':U
         , input 'Прием чеков с касс') no-error .
      IF error-status:error then
      do:
         return error "Ошибка при получении чеков с касс".
      end.
      run rep/rpychk0.p ( input "r-shft3f"
         ,input obj-list.obj-type
         ,input obj-list.obj-code
         ,input ?
         ,input ?
         ,input v-shift-date
         ,input v-shift-date
         ,input 1
         ,input 99
         ,input ?
         ) no-error.
      if error-status:error then
      do:
         message error-status:get-message(1) view-as alert-box.
      end.
   end.
end.
    if iparam:x-tog-shift then
    do :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
        if error-status :error
            then
        do:
                       if VALID-HANDLe(p-log-handle)    then do:                           if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1 &2 &3&4" +                                         "Невозможно определить тип сменный/не сменный&4" +                                        "для заданного объекта.&4" +                                        "Объект: &5&6&4&7&4&8"                                         ,vss-workfile                                         ,vss-revision                                         ,vss-description                                        ,chr(10)                                        ,obj-list.obj-type                                         ,obj-list.obj-code                                        , return-value                                          ,error-status:get-message(1) )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1 &2 &3&4" +                                         "Невозможно определить тип сменный/не сменный&4" +                                        "для заданного объекта.&4" +                                        "Объект: &5&6&4&7&4&8"                                         ,vss-workfile                                         ,vss-revision                                         ,vss-description                                        ,chr(10)                                        ,obj-list.obj-type                                         ,obj-list.obj-code                                        , return-value                                          ,error-status:get-message(1) )).    end.    end.    else do:       message substitute("&1 &2 &3&4" +                                         "Невозможно определить тип сменный/не сменный&4" +                                        "для заданного объекта.&4" +                                        "Объект: &5&6&4&7&4&8"                                         ,vss-workfile                                         ,vss-revision                                         ,vss-description                                        ,chr(10)                                        ,obj-list.obj-type                                         ,obj-list.obj-code                                        , return-value                                          ,error-status:get-message(1) ) view-as alert-box.    end.
            undo, return error .
        end.
        if v-shift-on = no
            then
        do:
                      if VALID-HANDLe(p-log-handle)    then do:                           if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Неверно задан тип объекта &1&2&3"  +                                       "Объект не сменный."                                       ,obj-list.obj-type                                       ,obj-list.obj-code                                       , chr(10) )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Неверно задан тип объекта &1&2&3"  +                                       "Объект не сменный."                                       ,obj-list.obj-type                                       ,obj-list.obj-code                                       , chr(10) )).    end.    end.    else do:       message substitute("Неверно задан тип объекта &1&2&3"  +                                       "Объект не сменный."                                       ,obj-list.obj-type                                       ,obj-list.obj-code                                       , chr(10) ) view-as alert-box.    end.
        end.
    end.
    if v-shift-on or iparam:x-tog-shift = no then
        if v-obj-name <> "" then
        do :
            assign
                v-obj-name = v-obj-name + ", " + obj-list.obj-name
                .
        end.
        else
        do :
            assign
                v-obj-name = obj-list.obj-name
                .
        end.
    end.
if session :set-wait-state( "compiler" ) then.
assign
  Counter1 = 0 .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
find first buf_clients
  where buf_clients.obj-type = 'орг':U
  and   buf_clients.obj-code = v-cntxt-host-code-obj
  no-lock
  .
assign
  v-firm = buf_clients.obj-name  .
for each   temp-fin-doc :
  delete temp-fin-doc .
end .
assign
  v-ost-begin = 0
  .
run report-exec in this-procedure .
if iParam:x-TOG-Shift then do:
   if iParam:x-Shift-Alone = 1 then v-date-name = "По смене: №" +  string(iParam:x-Shift-Start) + " " + string(iParam:x-Date-Start,"99.99.9999").
   else v-date-name = "За смены: c №" +  string (iParam:x-Shift-Start) + " " + string (iParam:x-Date-Start,"99.99.9999") + " по №" + string (iParam:x-Shift-End) + " " + string (iParam:x-Date-End,"99.99.9999").
end.
else v-date-name = "За период с " +  string (iParam:x-Date-Start) + " по " + string (iParam:x-Date-End).
if is-rosneft then
do:
  assign
    temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + temp-fin-doc.income-other
    temp-fin-doc.income-other  = 0
    .
end.
run get-report-num (output p-report-id).
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
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
        .
put stream OutStr-html unformatted
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
if p-det-oper then do:
put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="font-size:16px;font-weight:bold; text-align: center;">Оперативный отчет о движении денежных средств</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="9" style="text-align: center;"> За период с ' + string(iparam:x-Date-Start) + ' по ' + string(iparam:x-Date-End) + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="9">' + v-curr-time + '</td>' skip
        '</tr>' skip
.
end.
else do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="9" style="font-weight: bold;">ДВИЖЕНИЕ ДЕНЕЖНЫХ СРЕДСТВ</td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="9" style="font-weight: bold;"> За период с ' + string(iparam:x-Date-Start) + ' по ' + string(iparam:x-Date-End) + '</td>' skip
    '</tr>' skip
        '<tr>' skip
    '<td colspan="9">' + v-curr-time + '</td>' skip
    '</tr>' skip
    .
end.
put stream OutStr-html unformatted
        '</thead>' skip .
    put stream OutStr-html unformatted
        '<thead>' skip
        .
if not p-det-obj then do:
     put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9">' + v-obj-name + '</td>' skip
        '</tr>' skip
        .
end.
    put stream OutStr-html unformatted
        '</thead>' skip
        '<tbody>' skip
        .
if p-det-oper then do:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Кассовая книга</th>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на начало смены</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Приход</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Расход</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на конец смены</TD>' skip
            '</TR>'skip
            '<TR>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '</TR>'skip
            '<tr>' skip
            '<td style="text-align: center;">1</td>' skip
            '<td colspan="2" style="text-align: center;">2</td>' skip
            '<td style="text-align: center;">3</td>' skip
            '<td style="text-align: center;">4</td>' skip
            '<td style="text-align: center;">5</td>' skip
            '<td style="text-align: center;">6</td>' skip
            '<td style="text-align: center;">7</td>' skip
            '<td style="text-align: center;">8</td>' skip
            '</tr>' skip
            .
    for each buf_obj-list:
if p-det-obj then do:
   put stream OutStr-html unformatted
   '<tr>' skip
   '<TD text_wrap="true" colspan="9" style="text-align: left; font-weight: bold;">' + buf_obj-list.obj-name + '</TD>' skip
   '</tr>' skip
   .
   end.
    for each temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
        temp-fin-doc.obj-type = buf_obj-list.obj-type:
      put stream OutStr-html unformatted
        '<tr>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.cashbook) + '</td>' skip
                '<TD colspan="2" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-begin),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-begin),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-realiz),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-realiz),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-bank),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-bank),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '</tr>' skip
.
      ASSIGN
        v-col1 = v-col1 + temp-fin-doc.ost-begin
        v-col2 = v-col2 + temp-fin-doc.income-realiz
        v-col3 = v-col3 + temp-fin-doc.income-ras
        v-col4 = v-col4 + temp-fin-doc.expense-bank
        v-col5 = v-col5 + temp-fin-doc.expense-ras
        v-col6 = v-col6 + temp-fin-doc.ost-end
        v-col7 = v-col7 + temp-fin-doc.ost-end-ras
        .
    end.
    put stream OutStr-html unformatted
        '<tr>' skip
            '<td num="#0.00" style="text-align: right; font-weight: bold;">Итого:</td>' skip
            '<TD colspan="2" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col1),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col1),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col2),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col2),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col3),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col3),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col4),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col4),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col5),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col5),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col6),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col6),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col7),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col7),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '</tr>' skip
.
end.
end.
else do:
put stream OutStr-html unformatted
        '<tr>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Кассовая книга</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на начало смены</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">в т.ч. кассовый фонд</th>' skip
        '<th colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Приход</th>' skip
        '<th colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Расход</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на конец смены</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">в т.ч. кассовый фонд</th>' skip
        '</tr>' skip
        '<tr>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Реализация</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Прочее</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Инкассация в банк</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Другие</th>' skip
        '</tr>' skip
        '<tr>' skip
        '<th style="text-align: center;">5.1</th>' skip
        '<th style="text-align: center;">5.2</th>' skip
        '<th style="text-align: center;">5.3</th>' skip
        '<th style="text-align: center;">5.4</th>' skip
        '<th style="text-align: center;">5.5</th>' skip
        '<th style="text-align: center;">5.6</th>' skip
        '<th style="text-align: center;">5.7</th>' skip
        '<th style="text-align: center;">5.8</th>' skip
        '<th style="text-align: center;">5.9</th>' skip
        '</tr>' skip
        .
    for each buf_obj-list:
if p-det-obj then do:
   put stream OutStr-html unformatted
   '<tr>' skip
   '<TD text_wrap="true" colspan="9" style="text-align: left; font-weight: bold;">' + buf_obj-list.obj-name + '</TD>' skip
   '</tr>' skip
   .
end.
    for each temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
        temp-fin-doc.obj-type = buf_obj-list.obj-type:
      put stream OutStr-html unformatted
        '<tr>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.cashbook) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.ost-begin) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.income-realiZ) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.income-other) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.expense-bank) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.expense-other) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.ost-end) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
            '</tr>' skip
.
      ASSIGN
        v-col1  = v-col1 + temp-fin-doc.ost-begin
        v-col3  = v-col3 + (temp-fin-doc.income-realiZ + temp-fin-doc.income-other)
        v-col45 = v-col45 + (temp-fin-doc.expense-bank + temp-fin-doc.expense-other)
        v-col4  = v-col4 + temp-fin-doc.expense-bank
        v-col5  = v-col5 + temp-fin-doc.expense-other
        v-col6  = v-col6 + temp-fin-doc.ost-end
        v-col31 = v-col31 + temp-fin-doc.income-realiz
        v-col41 = v-col41 + temp-fin-doc.income-other
        .
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
                '<td num="#0.00" style="text-align: right;">Итого:</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col1) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col31) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col41) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col4) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col5) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col6) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
            '</tr>' skip
.
end.
end.
    run rep/wp-rub.p ( input (v-col1), output v-col1-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col3), output v-col3-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col45), output v-col45-propis, output abbr ).
    run rep/wp-rub.p ( input (v-col4), output v-col4-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col5), output v-col5-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col6), output v-col6-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col7), output v-col7-propis,  output abbr ).
if p-det-oper then do:
    put stream OutStr-html unformatted
        '<tfoot>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true" style=></TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true">Остаток фактический:</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="border-bottom: 1px solid black;">' + string(v-col6-propis) + '</TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="text-align: center;">(прописью)</TD>' skip
        '</TR>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true" style=></TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true">Остаток расчетный:</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="border-bottom: 1px solid black;">' + string(v-col7-propis) + '</TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="text-align: center;">(прописью)</TD>' skip
        '</TR>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true"></TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true" colspan="2">Отчет составили:</TD>' skip
        '<TD text_wrap="true" colspan="2" style="border-bottom: 1px solid black;"></TD>' skip //' + string(temp-fin-doc.staff-curr1) + '
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true">Отчет приняли:</TD>' skip
        '<TD text_wrap="true" colspan="2" style="border-bottom: 1px solid black;"></TD>' skip //' + string(temp-fin-doc.staff-next1) + '
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true" colspan="2"></TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Ф.И.О.   (подписи)</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Ф.И.О.   (подписи)</TD>' skip
        '</TR>' skip
        .
end.
else do:
    if is-rosneft then
    do:
      put stream OutStr-html unformatted
        '<tfoot>' skip
       '<tr style="height:30px;">' skip
                '<td colspan="9"></td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Принято по смене</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col1-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Выручка за смену</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="6" style="text-align: left;">' + v-col3-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Сдано: в банк</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="6" style="text-align: left;">' + v-col45-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Сдано: в офис</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col4-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Итого инкассировано</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col5-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Передано по смене: наличных денег</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col6-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
.
      put stream OutStr-html unformatted
                  '<tr> <!--Подвал-->' skip
                    '<td colspan="9"></td>' skip
                  '</tr>' skip
                    '<tr>' skip
                    '<td colspan="3" style="height:30px;"> Отчет составил и смену сдал:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip   // temp-fin-doc.staff-curr1
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip /// temp-fin-doc.staff-curr1
                  '</tr>' skip
                  '<tr>' skip
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                    '<tr>' skip
                    '<td colspan="3" style="height:30px;"> Смену принял:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip    // temp-fin-doc.staff-curr2
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip  // temp-fin-doc.staff-next2
                  '</tr>' skip
                  '<tr>' skip
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px;  text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px;  text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                    '<tr>' skip
                    '<td colspan="3" style="height:30px;"> Отчет проверил:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                  '</tr>' skip
                  '<tr>' skip
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                  '</tfoot>' skip
                  .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tfoot>' skip
       '<tr style="height:30px;">' skip
                '<td colspan="7"></td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;">Принято по смене</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: left;">' + v-col1-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;">Передано по смене: наличных денег</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: left;">' + v-col6-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip
.
      put stream OutStr-html unformatted
                  '<tr>' skip //<!--Подвал-->
                    '<td colspan="8" style="height:30px;"></td>' skip
                  '</tr>' skip
                    '<tr>' skip
                    '<td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  __________________</td>' skip //temp-fin-doc.staff-curr1
                  '</tr>' skip
                  '<tr>' skip
                    '<td colspan="8"> СМЕНУ ПРИНЯЛ: </td>' skip
                  '</tr>' skip
            '</tfoot>' skip
.
    end.
end.
    put stream OutStr-html unformatted
        '</tbody>' skip
        '</table>' skip
        '</body>' skip
        '</html>' skip
.
    output stream OutStr-html close.
run prn-lib-reportviewer-report-name in this-procedure (
  input parParentProc
  ,input v-file-name-rep-htm
  ).
procedure report-exec :
    for each buf_obj-list no-lock :
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,output v-host-code
  )  .
            if p-det-oper then
            do:
               find first buf_cash-pay no-lock where buf_cash-pay.is-cash = true no-error .
               if available (buf_cash-pay) then v-cash = buf_cash-pay.cdpay-code .
                  for each buf_chk-doc no-lock where buf_chk-doc.obj-code = buf_obj-list.obj-code and
                     buf_chk-doc.obj-type = buf_obj-list.obj-type and
                     buf_chk-doc.shift-date = v-shift-date and
                     buf_chk-doc.shift-name = string(v-shift-name) and
                     buf_chk-doc.shift-num = integer(v-shift-num):
                     for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code and buf_chk-gds-pay.pay-code = v-cash:
                        find first buf_goods-attr where buf_goods-attr.gds-code = buf_chk-gds-pay.gds-code
                                    and buf_goods-attr.attr-code = "cash-book-id" no-lock no-error.
                        if available (buf_goods-attr) then
                        do:
                           find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                              temp-fin-doc.obj-type = buf_obj-list.obj-type and
                              temp-fin-doc.cashbookid = integer(buf_goods-attr.attr-value) no-error .
                           if not available (temp-fin-doc) then
                           do:
                              create temp-fin-doc.
                              assign
                                 temp-fin-doc.obj-code   = buf_obj-list.obj-code
                                 temp-fin-doc.obj-type   = buf_obj-list.obj-type
                                 temp-fin-doc.obj-name   = buf_obj-list.obj-name
                                 temp-fin-doc.cashbookid = integer(buf_goods-attr.attr-value)
                                 .
                           end.
                        end.
                        else
                        do:
                           find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                              temp-fin-doc.obj-type = buf_obj-list.obj-type and
                              temp-fin-doc.cashbookid = 0 no-error .
                           if not available (temp-fin-doc) then
                           do:
                              create temp-fin-doc.
                              assign
                                 temp-fin-doc.obj-code   = buf_obj-list.obj-code
                                 temp-fin-doc.obj-type   = buf_obj-list.obj-type
                                 temp-fin-doc.obj-name   = buf_obj-list.obj-name
                                 temp-fin-doc.cashbookid = 0
                                 .
                           end.
                        end.
                            if buf_chk-doc.chk-type = integer('1':U) then
                            do:
                                assign
                                   temp-fin-doc.income-ras = temp-fin-doc.income-ras + buf_chk-gds-pay.tot-r-b .
                            end.
                            else if buf_chk-doc.chk-type = integer('6':U) or buf_chk-doc.chk-type = integer('96':U) then
                            do:
                                  find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
                                                    and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
                                                    and ub.chk-gds-attr.attr-code = "cstype"
                                  no-lock no-error.
                                  if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then do:
                                     temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras  - buf_chk-gds-pay.tot-r-b .
                                  end.
                                  else
                                  assign
                                      temp-fin-doc.income-ras = temp-fin-doc.income-ras + buf_chk-gds-pay.tot-r-b .
                            end.
                     end.
                  end.
            end.
      find first ub.cashbook no-lock where ub.cashbook.Status_ = 0 no-error .
      if not available (ub.cashbook) then
      do:
         assign
            v-ost-begin         = 0
            v-ost-begin-all     = 0
            v-income-realiZ-all = 0
            v-income-other-all  = 0
            v-expense-bank-all  = 0
            v-expense-other-all = 0
            v-ost-end-all       = 0
            v-income-ras-all    = 0
            v-expense-ras-all   = 0
            v-ost-end-ras-all   = 0
            .
         assign
            fact-order-1    = 0
            fact-order-2    = 0
            v-ost-begin     = 0
            v-income-realiZ = 0
            v-income-ras    = 0
            v-income-other  = 0
            v-expense-bank  = 0
            v-expense-ras   = 0
            v-expense-other = 0
            v-ost-end       = 0
            v-ost-end-ras   = 0
            .
         run fostatok in this-procedure (
            input   v-host-code
            ,input   buf_obj-list.obj-code
            ,input   buf_obj-list.obj-type
            ,input   iparam:x-tog-shift
            ,input   iparam:x-date-start - 1
            ,input   date('')
            ,input   iparam:x-shift-start
            ,input   iparam:X-shift-end
            ,input   yes
            ,input   0
            ,input   0
            ,output  v-sum-begin
            ,output  Fact-order-1)
            no-error .
         run fostatok in this-procedure (
            input   v-host-code
            ,input   buf_obj-list.obj-code
            ,input   buf_obj-list.obj-type
            ,input   iparam:x-tog-shift
            ,input   iparam:x-date-end
            ,input   iparam:x-date-end
            ,input   iparam:X-shift-end
            ,input   iparam:X-shift-end
            ,input   yes
            ,input   0
            ,input   0
            ,output  sum1
            ,output  Fact-order-2)
            no-error .
         for each buf_arh-fin-doc-schet-nal-obj no-lock
            where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
            and buf_arh-fin-doc-schet-nal-obj.obj-type          = buf_obj-list.obj-type
            and buf_arh-fin-doc-schet-nal-obj.obj-code          = buf_obj-list.obj-code
            and buf_arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U
            and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
            and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
            and buf_arh-fin-doc-schet-nal-obj.cashbookid        = 0
            and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
            and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
            and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
            and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if iparam:x-tog-shift then 'shift-obj':U else 'obj':U )
            and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
            and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
            :
            find first buf_fin-doc
               where buf_fin-doc.host-code         = v-host-code
               and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
               and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
               and buf_fin-doc.obj-type          = buf_obj-list.obj-type
               and buf_fin-doc.obj-code          = buf_obj-list.obj-code
               and buf_fin-doc.status_           = 'факт':U
               and (buf_fin-doc.fin-ext-doc-type = 'пко':U
               or buf_fin-doc.fin-ext-doc-type   = 'рко':U )
               no-error.
            if available buf_fin-doc then
            do :
                                         if buf_fin-doc.trn-doc-code = (if buf_fin-doc.obj-code > 0 then substitute('&1&2', buf_fin-doc.obj-type, string(buf_fin-doc.obj-code, '99999')) else '') then
               do:
                  assign
                     Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
                  if buf_fin-doc.fin-ext-doc-type = 'пко':U then
                  do :
                     find first buf_sysconf no-lock
                        where buf_sysconf.host-code = v-host-code
                        no-error.
                     if available buf_sysconf
                        and buf_fin-doc.payer-type = buf_sysconf.sale-type
                        and buf_fin-doc.payer-code = buf_sysconf.sale-code
                        then
                     do:
                        assign
                           v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                           v-income-ras    = v-income-ras + buf_fin-doc.sum-doc
                           .
                     end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:
                        find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId and
                        ub.CashBookRule.Code = "Avanscli-code" and ub.CashBookRule.RuleValue = string(buf_fin-doc.payer-code) no-error .
                        if available (ub.CashBookRule) and buf_fin-doc.payer-type = 'орг':U then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                        end.
                      end.
                  end.
                  else
                  do :
                     find first buf_clients-attr
                        where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                        and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                        and buf_clients-attr.attr-code = 'is-inkassator':U
                        and buf_clients-attr.attr-value = "yes"
                        use-index pi no-error.
                     if available buf_clients-attr then
                     do :
                        assign
                           v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                           .
                     end.
                     else
                     do :
                        if p-det-oper then v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc .
                        assign
                           v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                           .
                     end.
                  end.
               end.
            end.
         end.
         assign
            v-ost-begin = v-ost-begin + v-sum-begin
            .
            find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
               temp-fin-doc.obj-type = buf_obj-list.obj-type and
               temp-fin-doc.cashbookid = 0 no-error .
            if not available (temp-fin-doc) then
            do:
               create temp-fin-doc.
               assign
                  temp-fin-doc.obj-code   = buf_obj-list.obj-code
                  temp-fin-doc.obj-type   = buf_obj-list.obj-type
                  temp-fin-doc.obj-name   = buf_obj-list.obj-name
                  temp-fin-doc.cashbookid = 0
                  .
            end.
               assign
                  temp-fin-doc.cashbook      = "Основная деятельность"
                  temp-fin-doc.ost-begin     = temp-fin-doc.ost-begin + v-ost-begin
                  temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + v-income-realiZ
                  temp-fin-doc.income-other  = temp-fin-doc.income-other + v-income-other
                  temp-fin-doc.income-ras    = temp-fin-doc.income-ras + v-income-ras
                  temp-fin-doc.expense-bank  = temp-fin-doc.expense-bank + v-expense-bank
                  temp-fin-doc.expense-other = temp-fin-doc.expense-other + v-expense-other
                  temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras + v-expense-ras
                  temp-fin-doc.ost-end-ras   = temp-fin-doc.ost-end-ras + (temp-fin-doc.ost-begin + temp-fin-doc.income-ras - temp-fin-doc.expense-ras)
                  .
if p-det-oper then temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + temp-fin-doc.income-realiZ - temp-fin-doc.expense-bank) .
else temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + ( temp-fin-doc.income-realiZ + temp-fin-doc.income-other ) - ( temp-fin-doc.expense-bank + temp-fin-doc.expense-other )) .
         end.
         for each buf_cashbook no-lock where buf_cashbook.Status_ = 0:
         assign
            v-ost-begin         = 0
            v-ost-begin-all     = 0
            v-income-realiZ-all = 0
            v-income-other-all  = 0
            v-expense-bank-all  = 0
            v-expense-other-all = 0
            v-ost-end-all       = 0
            v-income-ras-all    = 0
            v-expense-ras-all   = 0
            v-ost-end-ras-all   = 0
            .
         assign
            fact-order-1    = 0
            fact-order-2    = 0
            v-ost-begin     = 0
            v-income-realiZ = 0
            v-income-ras    = 0
            v-income-other  = 0
            v-expense-bank  = 0
            v-expense-ras   = 0
            v-expense-other = 0
            v-ost-end       = 0
            v-ost-end-ras   = 0
            .
            run fostatok in this-procedure (
               input   v-host-code
               ,input   buf_obj-list.obj-code
               ,input   buf_obj-list.obj-type
               ,input   iparam:x-tog-shift
               ,input   iparam:x-date-start - 1
               ,input   date('')
               ,input   iparam:x-shift-start
               ,input   iparam:X-shift-end
               ,input   yes
               ,input   0
               ,input   buf_cashbook.id
               ,output  v-sum-begin
               ,output  Fact-order-1)
               no-error .
            run fostatok in this-procedure (
               input   v-host-code
               ,input   buf_obj-list.obj-code
               ,input   buf_obj-list.obj-type
               ,input   iparam:x-tog-shift
               ,input   iparam:x-date-end
               ,input   iparam:x-date-end
               ,input   iparam:X-shift-end
               ,input   iparam:X-shift-end
               ,input   yes
               ,input   0
               ,input   buf_cashbook.id
               ,output  sum1
               ,output  Fact-order-2)
               no-error .
            for each buf_arh-fin-doc-schet-nal-obj no-lock
               where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
               and buf_arh-fin-doc-schet-nal-obj.obj-type          = buf_obj-list.obj-type
               and buf_arh-fin-doc-schet-nal-obj.obj-code          = buf_obj-list.obj-code
               and buf_arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U
               and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
               and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
               and buf_arh-fin-doc-schet-nal-obj.cashbookid        = buf_cashbook.id
               and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
               and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
               and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
               and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if iparam:x-tog-shift then 'shift-obj':U else 'obj':U )
               and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
               and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
               :
               find first buf_fin-doc
                  where buf_fin-doc.host-code         = v-host-code
                  and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
                  and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
                  and buf_fin-doc.obj-type          = buf_obj-list.obj-type
                  and buf_fin-doc.obj-code          = buf_obj-list.obj-code
                  and buf_fin-doc.status_           = 'факт':U
                  and (buf_fin-doc.fin-ext-doc-type = 'пко':U
                  or buf_fin-doc.fin-ext-doc-type   = 'рко':U )
                  no-error.
               if available buf_fin-doc then
               do :
                                            if buf_fin-doc.trn-doc-code = (if buf_fin-doc.obj-code > 0 then substitute('&1&2', buf_fin-doc.obj-type, string(buf_fin-doc.obj-code, '99999')) else '') then
                  do:
                     assign
                        Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
                     if buf_fin-doc.fin-ext-doc-type = 'пко':U then
                     do :
                        find first buf_sysconf no-lock
                           where buf_sysconf.host-code = v-host-code
                           no-error.
                        if available buf_sysconf
                           and buf_fin-doc.payer-type = buf_sysconf.sale-type
                           and buf_fin-doc.payer-code = buf_sysconf.sale-code
                           then
                        do:
                           assign
                              v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                              v-income-ras    = v-income-ras + buf_fin-doc.sum-doc
                              .
                        end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:
                        find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId and
                        ub.CashBookRule.Code = "Avanscli-code" and ub.CashBookRule.RuleValue = string(buf_fin-doc.payer-code) no-error .
                        if available (ub.CashBookRule) and buf_fin-doc.payer-type = 'орг':U then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                        end.
                      end.
                     end.
                     else
                     do :
                        find first buf_clients-attr
                           where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                           and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                           and buf_clients-attr.attr-code = 'is-inkassator':U
                           and buf_clients-attr.attr-value = "yes"
                           use-index pi no-error.
                        if available buf_clients-attr then
                        do :
                           assign
                              v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                              .
                        end.
                        else
                        do :
                           if p-det-oper then v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc .
                           assign
                              v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                              .
                        end.
                        v-expense-ras = v-expense-ras + buf_fin-doc.sum-doc.
                     end.
                  end.
               end.
            end.
            assign
               v-ost-begin = v-ost-begin + v-sum-begin
               .
               find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                  temp-fin-doc.obj-type = buf_obj-list.obj-type and
                  temp-fin-doc.cashbookid = buf_cashbook.id no-error .
               if not available (temp-fin-doc) then
               do:
                  create temp-fin-doc.
                  assign
                     temp-fin-doc.obj-code   = buf_obj-list.obj-code
                     temp-fin-doc.obj-type   = buf_obj-list.obj-type
                     temp-fin-doc.obj-name   = buf_obj-list.obj-name
                     temp-fin-doc.cashbookid = buf_cashbook.id
                     .
                end.
                  assign
                     temp-fin-doc.ost-begin     = temp-fin-doc.ost-begin + v-ost-begin
                     temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + v-income-realiZ
                     temp-fin-doc.income-other  = temp-fin-doc.income-other + v-income-other
                     temp-fin-doc.income-ras    = temp-fin-doc.income-ras + v-income-ras
                     temp-fin-doc.expense-bank  = temp-fin-doc.expense-bank + v-expense-bank
                     temp-fin-doc.expense-other = temp-fin-doc.expense-other + v-expense-other
                     temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras + v-expense-ras
                  temp-fin-doc.ost-end-ras   = temp-fin-doc.ost-end-ras + (temp-fin-doc.ost-begin + temp-fin-doc.income-ras - temp-fin-doc.expense-ras)
                     .
               if p-det-oper then temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + temp-fin-doc.income-realiZ - temp-fin-doc.expense-bank) .
               else temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + ( temp-fin-doc.income-realiZ + temp-fin-doc.income-other ) - ( temp-fin-doc.expense-bank + temp-fin-doc.expense-other )) .
                  if buf_cashbook.id = 0 then temp-fin-doc.cashbook       = "Основная деятельность" .
                  else temp-fin-doc.cashbook = buf_cashbook.CashBookName .
      end.
      end.
      end procedure .
PROCEDURE get-report-num :
   define output parameter p-report-num as integer no-undo .
   do
      on error undo, return error return-value
      :
      run gbl/getrpnum.p (output p-report-num).
   end.
END PROCEDURE.
PROCEDURE proc-cur-time :
do on error undo, return error:
        define output parameter p-today as date no-undo.
        define output parameter p-time as integer no-undo.
        define variable v-date1 as date no-undo.
        define variable v-date2 as date no-undo.
        define variable v-time as integer no-undo.
        assign
          v-date1 = today
          v-time = time
          v-date2 = today
        .
        if v-date1 <> v-date2 then
            do:
                assign
                    v-date1 = today
                    v-time  = v-time
                    v-date2 = today
                .
            end.
        assign
            p-today = v-date1
            p-time  = v-time
        .
    end.
end procedure.
FUNCTION fnc-cur-time-print returns character:
    define variable v-date as date no-undo.
    define variable v-time as integer no-undo.
    run proc-cur-time(output v-date, output v-time).
    return "Дата печати: " + string(v-date, "99.99.9999":U) + " " + string(v-time, "HH:MM":U).
end function.
