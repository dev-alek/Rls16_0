block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code as integer no-undo .
define input parameter p-fin-doc-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: 074931e2893a, 3249, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/01/27 13:45:25 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pre-vedom.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/pre-vedom.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа расход наличные".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile: frmlib.i $ $Revision: aea5316774be, 0, rls $".
FUNCTION Break-n-line RETURNS CHARACTER
  ( INPUT p-ost as char,
    INPUT p-lengths  as character,
    OUTPUT output-num-lines as integer
    ) :
define variable ii as integer no-undo.
define variable jj as integer no-undo.
define variable linei as character no-undo extent 10.
define variable line-length as integer no-undo extent 10.
define variable num-line as integer no-undo .
define variable v-line as character no-undo .
do ii = 1 to MIN(num-entries(p-lengths), 10):
  assign
  line-length[ii] = integer(entry(ii, p-lengths))
  num-line = ii
  .
end.
do jj = 1 to num-line:
  if Length ( p-ost ) <= line-length[jj] then do:
    assign
    output-num-lines = jj
    v-line = v-line + (if jj = 1 then "":U else chr(4)) + p-ost
    .
    return v-line.
  end.
  assign
  ii = 1
  .
  if length( entry( ii, p-ost , chr(32)) ) > line-length[jj]
  then do:
    assign
    linei[jj] = substr( p-ost , 1 , line-length[jj] )
    p-ost = trim( substr( p-ost , line-length[jj] + 1 ) )
    .
  end.
  else do:
    DO WHILE length( linei[jj] + entry( ii, p-ost , chr(32)) ) < ( line-length[jj] + 1 ) :
      assign
      linei[jj] = linei[jj] + entry( ii, p-ost , chr(32)) + chr(32)
      ii = ii + 1
      .
      if length( entry( ii, p-ost, chr(32) ) ) > line-length[jj] then
      assign
      linei[jj] = linei[jj] + substr( p-ost , length( linei[jj] ) , line-length[jj] - length( linei[jj] ) + 1 )
      .
    END.
    assign
    p-ost = trim( substr( p-ost , length(linei[jj]) + 1  ))
    .
  end.
  assign
  v-line = v-line + (if jj = 1 then "":U else chr(4)) + linei[jj]
  .
  if p-ost = "":U then LEAVE.
end.
assign
output-num-lines = jj.
RETURN v-line.
END FUNCTION.
FUNCTION Center-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-left = (p-length - p-format )
  v-dop = (if v-left modulo 2 = 1
           then 1
           else 0)
  v-left = (if (v-left modulo 2 = 1)
           then (v-left - 1 ) / 2
           else v-left / 2)
  v-str =  fill(p-fill, v-left) +
           string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-left) + fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Left-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-dop =  p-length - p-format
  v-str =  string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Sum-Rub-Kop-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-rub-length as integer,
    INPUT p-kop-length as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character,
    INPUT p-rub-str  as character,
    INPUT p-kop-str  as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-rub-length or p-kop-length < 2 then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9":U
v-dopi = length(trim(string(truncate(p-sum, 0), v-format)))
.
assign
v-str = fill(p-fill, p-rub-length - v-dopi) +
        string(truncate(p-sum, 0), v-format) +
        p-rub-str +
        fill(p-fill, p-kop-length - 2) +
        string(truncate((ABS(p-sum) - ABS(truncate(p-sum, 0))), 2) * 100, "99":U) + p-kop-str
.
return v-str.
END FUNCTION.
FUNCTION Sum-Invalut-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-sum-length as integer,
    INPUT p-curr-code as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-curr-name as character no-undo .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not avail buf_currency
then v-curr-name = "неизвестная валюта".
else
assign
v-curr-name = buf_currency.curr-name
.
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-sum-length then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9.99":U
v-dopi = length(trim(string(p-sum, v-format)))
.
assign
v-str = "(":U + chr(32) + v-curr-name +  chr(32) + ")":U +
        fill(p-fill, p-sum-length - v-dopi - length(v-curr-name) - 4)  +
        trim(string(p-sum, v-format))
.
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Without-Dec RETURNS CHARACTER
(input v-sum as decimal
):
define variable v-str as character no-undo .
run gbl/num-rus.p ( input absolute( v-sum ) , output v-str).
v-str = trim( caps( substring( v-str, 1, 1 ) ) ) + substring( v-str, 2 ).
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Invalut RETURNS CHARACTER
(input p-sum as decimal
 ,input p-curr-code as integer
):
define variable v-str as character no-undo .
define variable Copeck as character no-undo.
define variable Rouble as character no-undo.
define variable v-Word as character no-undo.
define variable ii as integer init 18 no-undo.
define variable v-str-rubl as character no-undo .
define variable v-kop as integer no-undo .
define buffer buf_currency for ub.currency.
assign
v-Word = string( absolute( p-sum ) , "999999999999999.99" ).
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not available buf_currency then return chr(63).
if decimal( substring(v-Word,1,ii - 3) ) <> 0 then do:
  CASE substring(v-Word, ii - 3,1):
    WHEN "1" THEN DO:
      if substring(v-Word, ii - 4,1) = "1" then
          Rouble = buf_currency.curr-name-five .
      else
          Rouble = buf_currency.curr-name-one .
    END.
    WHEN "2" OR WHEN "3" OR WHEN "4" THEN  DO:
      if substring(v-Word, ii - 4,1) = "1" then
         Rouble = buf_currency.curr-name-five .
         else
         Rouble = buf_currency.curr-name-three .
      END.
    WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN  DO:
       Rouble = buf_currency.curr-name-five .
    END.
  END CASE.
end.
CASE substring(v-Word, ii, 1):
  WHEN "1" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-one .
  END.
  WHEN "2" OR WHEN "3" OR WHEN "4" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-three .
  END.
  WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN DO:
    Copeck = buf_currency.part-name-five .
  END.
END CASE.
run gbl/num-rus.p ( input absolute( p-sum )
             , output v-str-rubl).
assign
v-kop = (absolute( p-sum ) - truncate(absolute(p-sum), 0)
        ) * 100
.
v-str = ( if p-Sum < 0 then "- " else "" ) +
            caps(substring(v-str-rubl, 1, 1)) +  substring(v-str-rubl, 2) + chr(32) + Rouble + chr(32) +
            string(v-kop, "99":U) + chr(32) + Copeck .
return v-str.
END FUNCTION.
FUNCTION Sum-delim-with-defis RETURNS CHARACTER
(input v-sum as decimal,
input v-razr as integer
):
define variable v-str as character no-undo .
define variable v-dec-separ as character no-undo .
case SESSION:NUMERIC-FORMAT:
  when "American":U then do:
    assign
    v-dec-separ = ".":U
    .
  end.
  when "European":U then do:
    assign
    v-dec-separ = ",":U
    .
  end.
END CASE.
assign
v-str = replace(string(v-sum, fill(">":U, v-razr - 1) + "9.99"), v-dec-separ, "-":U)
.
return v-str.
END FUNCTION.
FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-coins no-undo XML-NODE-NAME "coins" serialize-name "coins"
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id desc.
define temp-table tt-banknots no-undo XML-NODE-NAME "banknots" serialize-name "banknots"
  field id       as integer
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id .
define temp-table tt-monets no-undo
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id .
define dataset ds-banknots XML-NODE-NAME "money" serialize-name  "money" for tt-banknots,
  tt-coins .
define variable hQueryCoins           as handle    no-undo .
define variable hQueryBanknot         as handle    no-undo .
define variable g#report-num          as integer   no-undo .
define variable g#quest-print         as logical   no-undo.
define variable Line                  as character no-undo .
define variable g#log                 as logical   no-undo .
define variable v-okud                as character no-undo .
define variable p-report-id           as character no-undo .
define variable v-file-name-rep-html  as character no-undo .
define variable v-file-name-rep-html1 as character no-undo .
define variable CSJson                as longchar  no-undo .
define variable CShtt                 as handle    no-undo .
define variable v-num-bag             as character no-undo .
define variable v-fin-doc-list        as character no-undo .
define variable v-shift-date          as date      no-undo .
define variable v-firm                as character no-undo .
define variable v-obj-name            as character no-undo .
define variable v-total-sum           as decimal   no-undo .
define variable ii                    as integer   no-undo .
define variable jj                    as integer   no-undo .
define variable v-debt-schet          as character no-undo .
define variable v-credit-schet        as character no-undo .
define variable v-inn                 as character no-undo .
define variable v-schet               as character no-undo .
define variable v-bank-code           as character no-undo .
define variable v-deposit-bank        as character no-undo .
define variable v-deposit-bank_name   as character no-undo .
define variable v-deposit-bank_bik    as character no-undo .
define variable v-recip-bank          as character no-undo .
define variable v-recip-bank_name1    as character no-undo .
define variable v-recip-bank_bik1     as character no-undo .
define variable v-schet1              as character no-undo .
define variable v-recip-bank_name2    as character no-undo .
define variable v-recip-bank_bik2     as character no-undo .
define variable v-schet2              as character no-undo .
define variable v-schetUB             as character no-undo .
define variable v-source              as character no-undo .
define variable v-source1             as character no-undo .
define variable v-total-rubl          as character no-undo .
define variable v-total-kop           as character no-undo .
define variable v-ii                  as character no-undo .
define variable name-page-obor        as character no-undo .
define variable name-page             as character no-undo .
define variable v-ok-cashGB           as logical   no-undo .
define variable v-ok-cashUB           as logical   no-undo .
define variable v-sum-cashGB          as decimal   no-undo .
define variable v-sum-cashUB          as decimal   no-undo .
define variable v-sum                 as character no-undo .
define variable v-simvol              as character no-undo .
define variable v-name-titul          as character no-undo .
define variable v-name-titul1         as character no-undo .
define variable v-cashier             as character no-undo .
define variable v-decimal             as decimal   no-undo .
define variable v-pin                 as character no-undo .
define variable v-qr-code             as integer   no-undo .
define variable v-hist-name           as character no-undo .
define variable v-hist-code           as character no-undo .
define variable v-bank-kredit         as logical   no-undo .
define variable par-type              as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define buffer buf_fin-doc      for ub.fin-doc .
define buffer buf_fin-doc-attr for ub.fin-doc-attr .
define buffer buf_clients      for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_fin-bank     for ub.fin-bank .
do
  on error undo, return error return-value
  :
  find first ub.fin-doc no-lock where ub.fin-doc.fin-doc-code = p-fin-doc-code and ub.fin-doc.host-code = p-host-code no-error .
  v-shift-date = ub.fin-doc.shift-date .
  for first ub.fin-doc-attr no-lock where ub.fin-doc-attr.attr-code = "pre-vedom"
    and ub.fin-doc-attr.fin-doc-code = p-fin-doc-code and ub.fin-doc-attr.host-code = p-host-code:
    assign
      v-num-bag      = entry(1,ub.fin-doc-attr.attr-value,";")
      v-deposit-bank = entry (2,ub.fin-doc-attr.attr-value,";")
      v-recip-bank   = entry (3,ub.fin-doc-attr.attr-value,";")
      .
    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(v-recip-bank) and ub.fin-bank.host-code = ub.fin-doc-attr.host-code:
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and
        ub.fin-bank-attr.attr-code = "collect-qrcode" no-error .
      if available (ub.fin-bank-attr) then v-qr-code = integer(ub.fin-bank-attr.attr-value) .
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and
        ub.fin-bank-attr.attr-code = "collect-debt" no-error .
      if available (ub.fin-bank-attr) then v-debt-schet = ub.fin-bank-attr.attr-value .
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and
        ub.fin-bank-attr.attr-code = "collect-credit" no-error .
      if available (ub.fin-bank-attr) then v-credit-schet = ub.fin-bank-attr.attr-value .
    end.
    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(v-deposit-bank) and ub.fin-bank.host-code = ub.fin-doc-attr.host-code:
      assign
        v-deposit-bank_name = ub.fin-bank.bank-name
        v-deposit-bank_bik  = ub.fin-bank.bik .
    end.
    for each buf_fin-doc no-lock where buf_fin-doc.host-code = ub.fin-doc.host-code and buf_fin-doc.shift-date = ub.fin-doc.shift-date and buf_fin-doc.shift-name = ub.fin-doc.shift-name
      and buf_fin-doc.obj-code = ub.fin-doc.obj-code and buf_fin-doc.obj-type = ub.fin-doc.obj-type,
      first buf_fin-doc-attr no-lock where buf_fin-doc-attr.attr-code = "pre-vedom" and buf_fin-doc-attr.host-code = buf_fin-doc.host-code and entry(1,buf_fin-doc-attr.attr-value,";") = v-num-bag and
      buf_fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code:
      if buf_fin-doc.CashBookId <> 0 then
      do:
        v-ok-cashUB = yes .
        v-decimal =  buf_fin-doc.sum-doc .
        v-sum-cashUB = v-sum-cashUB + v-decimal .
        v-pin = if v-pin = " " then entry(4,buf_fin-doc-attr.attr-value,";") else v-pin + "/" + entry(4,buf_fin-doc-attr.attr-value,";") .
        for first ub.CashBook no-lock where ub.CashBook.id = buf_fin-doc.CashBookId:
          for each ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
            ub.CashBookRule.Code = "BankRecip-acct" and ub.CashBookRule.Status_ = 0:
            v-schet2 = ub.CashBookRule.RuleValue .
          end.
        end.
      end.
      else
      do:
        v-ok-cashGB = yes .
        v-decimal =  buf_fin-doc.sum-doc .
        v-sum-cashGB = v-sum-cashGB + v-decimal .
        v-pin = if v-pin = " " then entry(4,buf_fin-doc-attr.attr-value,";") else v-pin + "/" + entry(4,buf_fin-doc-attr.attr-value,";") .
        for first ub.CashBook no-lock where ub.CashBook.id = buf_fin-doc.CashBookId:
          for each ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
            ub.CashBookRule.Code = "BankRecip-acct" and ub.CashBookRule.Status_ = 0:
            v-schet1 = ub.CashBookRule.RuleValue .
          end.
        end.
      end.
      v-fin-doc-list = v-fin-doc-list + ";" + string(buf_fin-doc-attr.fin-doc-code) .
      v-total-sum = v-total-sum + buf_fin-doc.sum-doc .
      v-ii = entry(3,buf_fin-doc-attr.attr-value,";") .
      if lookup (v-ii,v-bank-code,";") = 0 then
      do:
        v-bank-code = v-bank-code + ";" + entry(3,buf_fin-doc-attr.attr-value,";") .
      end.
    end.
    if v-ok-cashGB then v-source = "Поступления от продажи товаров" .
    if v-ok-cashUB then v-source1 = "Прочие поступления" .
    v-source = v-source + ", " + v-source1 .
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error .
    assign
      v-cashier = if available ub.user-account then string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) else "".
  end.
  v-schet = v-schet1 + "," + v-schet2 .
  v-schet = trim(v-schet,",") .
  if v-debt-schet = "" then v-credit-schet = v-schet .
  v-bank-code = trim (v-bank-code,";") .
  v-fin-doc-list = trim(v-fin-doc-list,";") .
  v-source = trim(v-source,", ") .
  do ii = 1 to num-entries (v-bank-code,";"):
    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(entry (ii,v-bank-code,";")) and ub.fin-bank.host-code = p-host-code:
      do jj = 1 to num-entries (v-schet,","):
        for first ub.fin-schet no-lock where ub.fin-schet.code-bank = ub.fin-bank.code-bank and ub.fin-schet.status_ = 'тек':U and
          ub.fin-schet.r-schet = entry (jj,v-schet,","):
          if v-recip-bank_name1 <> "" then
          do:
            v-recip-bank_name2 = ub.fin-bank.bank-name .
          end.
          else v-recip-bank_name1 = ub.fin-bank.bank-name .
          if v-recip-bank_bik1 <> "" then
          do:
            v-recip-bank_bik2 = ub.fin-bank.bik .
          end.
          else v-recip-bank_bik1 = ub.fin-bank.bik .
        end.
      end.
    end.
  end.
  v-total-rubl = Sum-in-Words-Without-Dec(v-total-sum) .
  v-total-kop = string((v-total-sum - truncate(v-total-sum, 0)) * 100, "99":U) .
  do ii = 1 to num-entries(v-fin-doc-list,";"):
    empty temp-table tt-banknots .
    empty temp-table tt-coins .
    for first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = integer(entry(ii,v-fin-doc-list,";")) and buf_fin-doc-attr.host-code = p-host-code
      and buf_fin-doc-attr.attr-code = "cover_sheet":
      CSJson = buf_fin-doc-attr.attr-value .
      if CSJson <> "" and CSJson <> ? then
      do:
        dataset ds-banknots:handle:read-json ("longchar",CSJson) .
        for each tt-banknots no-lock where tt-banknots.qnty <> 0:
          find first tt-monets exclusive-lock where tt-monets.id = tt-banknots.id no-error .
          if not available (tt-monets) then
          do:
            create tt-monets .
            tt-monets.id = tt-banknots.id .
          end.
          assign
            tt-monets.qnty     = tt-monets.qnty + tt-banknots.qnty
            tt-monets.sum-qnty = tt-monets.sum-qnty + tt-banknots.sum-qnty
            .
        end.
        for each tt-coins no-lock where tt-coins.qnty <> 0:
          find first tt-monets exclusive-lock where tt-monets.id = tt-coins.id no-error .
          if not available (tt-monets) then
          do:
            create tt-monets .
            tt-monets.id = tt-coins.id .
          end.
          assign
            tt-monets.qnty     = tt-monets.qnty + tt-coins.qnty
            tt-monets.sum-qnty = tt-monets.sum-qnty + tt-coins.sum-qnty
            .
        end.
      end.
    end.
  end.
  find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = ub.fin-doc.host-code no-error .
  if available (buf_clients) then v-firm = buf_clients.obj-name .
  find first ub.firm no-lock where ub.firm.firm-code = ub.fin-doc.host-code no-error .
  v-inn = ub.firm.inn .
  find first buf_clients no-lock where buf_clients.obj-type = ub.fin-doc.obj-type and buf_clients.obj-code = ub.fin-doc.obj-code no-error .
  if available (buf_clients) then v-obj-name = buf_clients.obj-name .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-code':U,OUTPUT v-hist-code ,OUTPUT par-type) .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-name':U,OUTPUT v-hist-name ,OUTPUT par-type) .
  if v-hist-name = "" then v-hist-name = v-obj-name .
  if v-qr-code = 1 then
  do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure base64-encode :
  define input  parameter v-string        as character no-undo .
  define output parameter v-base64-encode as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-raw     as raw       no-undo .
    define variable v-raw-str as character no-undo .
    if v-string = ?
    then do:
      undo, return error "base64-encode: строка имеет неопределенное значение" .
    end.
    assign
      length(v-raw) = length(v-string) + 1
    .
    assign
      put-string(v-raw, 1) = v-string
    .
    assign
      v-raw-str = string(v-raw)
    .
    assign
      length(v-raw) = 0
    .
    assign
      v-base64-encode = substring(v-raw-str, 7)
    .
  end.
end.
    define variable qr-code     as character no-undo.
    define variable qr-code-out as character no-undo.
    qr-code = '<?xml version="1.0" encoding="windows-1251" standalone="yes"?>
<client_info><client_info_row>
<client_ink>8598123368358741900012</client_ink>
<client_ino>156885</client_ino>
<client_name>АЗС№02-136 БашнефтьРозница</client_name>
<client_organization_name>Общество с ограниченной ответственностью "Башнефть-Розница"</client_organization_name>
<client_address xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">Чишмы, Железнодорожная,1-1</client_address>
<client_inn>1831090630</client_inn>
<client_kpp>027801001</client_kpp>
<client_accounts>
<acc_num>40702810306000008673</acc_num>
<bic>048073601</bic>
<bank_name>БАШКИРСКОЕ ОТДЕЛЕНИЕ N8598 ПАО СБЕРБАНК Г.Уфа</bank_name>
</client_accounts>
<client_accounts>
<acc_num>40821810200000000015</acc_num>
<bic>044525880</bic>
<bank_name>БАНК "ВБРР" (АО) Г.Москва</bank_name>
</client_accounts>
<bank_name>БАШКИРСКОЕ ОТДЕЛЕНИЕ N8598 ПАО СБЕРБАНК Г.УФА</bank_name>
<bank_bic>048073601</bank_bic>
<debet_account xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
</client_info_row></client_info>'.
    run base64-encode (qr-code,output qr-code-out).
    define variable v-arc as character no-undo .
    define variable v-cmd as character no-undo .
    assign
      v-arc = search( "exe/qrgen.exe":U )
      .
    if v-arc = ? then
    do:
      return error "Не найдена программа qrgen.exe" .
    end.
    os-command silent value (v-arc + ' -size=128 -content="' + qr-code-out + '"' + ' -filename="c:\temp\qr-code"') .
  end.
  run get-report-num  (output g#report-num).
  do jj = 1 to 3:
    v-file-name-rep-html = session:temp-directory + string(g#report-num) + "_" + string (jj) + ".html".
    output stream OutStr-html to value(v-file-name-rep-html) convert target 'UTF-8'.
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
      '<body>' skip
      .
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Ведомость_1">'skip
      .
    put stream OutStr-html unformatted
      '<thead>' skip.
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '</tr>' skip
      .
    case jj:
      when 1 then
        do:
          v-name-titul = "Препроводительная ведомость к сумке" .
          v-name-titul1 = "ВЕДОМОСТЬ К СУМКЕ" .
        end.
      when 2 then
        do:
          v-name-titul = "" .
          v-name-titul1 = "НАКЛАДНАЯ К СУМКЕ" .
        end.
      when 3 then
        do:
          v-name-titul = "" .
          v-name-titul1 = "КВИТАНЦИЯ К СУМКЕ" .
        end.
    end case .
    if jj = 1 then
    do:
      if v-pin <> "" then
      do:
        put stream OutStr-html unformatted
          '<tr style="height: 45px;">' skip
          '<td></td>' skip
          '<td colspan="52" style="font-weight: bold;">ПИН ' + v-pin + '</td>' skip
          .
        if search( "C:\Temp\qr-code.png":U ) <> ? and v-qr-code = 1 then
        do:
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"><img src="C:\Temp\qr-code.png" width="130" height="130" alt=""/></td>'.
        end.
        else
        do:
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"></td>'.
        end.
        put stream OutStr-html unformatted
          '<td colspan="31"></td>' skip
          '</tr>' skip
          '<tr><td colspan="53"></td>' skip
          '<td colspan="31"></td>' skip
          '</tr>' skip .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td></td>' skip
          '<td colspan="52"></td>' skip
          .
        if search( "C:\Temp\qr-code.png":U ) <> ? and v-qr-code = 1 then
        do:
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"><img src="C:\Temp\qr-code.png" width="130" height="130" alt=""/></td>'.
        end.
        else
        do:
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"></td>'.
        end.
        put stream OutStr-html unformatted
          '<td colspan="31"></td>' skip
          '</tr>' skip
          '<tr><td colspan="53"></td>' skip
          '<td colspan="31"></td>' skip
          '</tr>' skip .
      end.
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="52"></td>' skip
        '<td rowspan="2" colspan="74" style="text-align: right;"></td>'
        '<td colspan="31"></td>' skip
        '</tr>' skip
        '<tr><td colspan="53"></td>' skip
        '<td colspan="31"></td>' skip
        '</tr>' skip .
    end.
    if jj <> 1 then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="52"></td>' skip
        '<td rowspan="2" colspan="74" style="text-align: right;"></td>'
        '<td colspan="31"></td>' skip
        '</tr>' skip.
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="52" style="text-align: center; font-weight: bold;">' + v-name-titul + '</td>' skip
      '<td colspan="31" style="text-align: center; border: 1px solid black;">Код формы документа по ОКУД 0402300</td>' skip
      '</tr>' skip
      '<tr><td colspan="158"></td></tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="32" style="text-align: left; font-weight: bold;">' + v-name-titul1 + '</td>' skip
      '<td colspan="4"></td>' skip
      '<td colspan="5">№</td>' skip
      '<td colspan="15" style="text-align: center; border: 1px solid black;">' + if v-num-bag <> ? then v-num-bag + '</td>' else ""  + '</td>' skip
      '<td colspan="8"></td>' skip
      '<td colspan="50" style="text-align: center; border-bottom: 1px solid black;">' + if v-shift-date <> ? then string(v-shift-date) + '</td>' else ""  + '</td>' skip
      '<td colspan="12"></td>' skip
      '<td colspan="14" style="text-align: right; border-left: 1px solid black; border-top: 1px solid black;">Сумка №</td>' skip
      '<td colspan="16" style="text-align: center; border-top: 1px solid black; border-bottom: 1px solid black;">' + if v-num-bag <> ? then v-num-bag + '</td>' else ""  + '</td>' skip
      '<td colspan="1" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="32" style="text-align: center;"></td>' skip
      '<td colspan="4"></td>' skip
      '<td colspan="5"></td>' skip
      '<td colspan="15"></td>' skip
      '<td colspan="8"></td>' skip
      '<td colspan="50" style="text-align: center; font-size: 8px;">Дата</td>' skip
      '<td colspan="12"></td>' skip
      '<td colspan="31" style="text-align: right; border-left: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="69"></td>'
      '<td colspan="52" style="text-align: center;">ДЕБЕТ</td>' skip
      '<td colspan="36"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="10" style="text-align: left;">От кого</td>' skip
      '<td colspan="57" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + v-hist-name + " " + v-firm + '</td>' skip
      '<td style="border-bottom: 1px solid black; border-top: 1px solid black;"></td>' skip
      '<td colspan="9" style="border-bottom: 1px solid black; border-top: 1px solid black;">счет №</td>' skip
      '<td colspan="43" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">' + v-debt-schet + '</td>' skip
      '<td colspan="37" style="text-align: right; border-left: 1px solid black; border-top: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="67" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="52" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">КРЕДИТ</td>' skip
      '<td colspan="37" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; font-weight: bold;">' + string(v-total-sum) + '</td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: left;">Получатель</td>' skip
      '<td></td>' skip
      '<td colspan="52" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + v-firm + '</td>' skip
      '<td style="border-bottom: 1px solid black; border-top: 1px solid black;"></td>' skip
      '<td colspan="9" style="border-bottom: 1px solid black;">счет №</td>' skip
      '<td colspan="43" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">' + v-credit-schet + '</td>' skip
      '<td colspan="37" style="text-align: right; border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="6" style="text-align: left;">ИНН</td>' skip
      '<td></td>' skip
      '<td colspan="36" style="text-align: center; border-bottom: 1px solid black;">' + v-inn + '</td>' skip
      '<td colspan="11" style="text-align: center;">Счет№</td>' skip
      '<td colspan="66" style="text-align: center; border-bottom: 1px solid black;">' + v-schet + '</td>' skip
      '<td colspan="37" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;">Сумма цифрами</td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="36" style="text-align: left;">Наименование банка-вносителя</td>' skip
      '<td></td>' skip
      '<td colspan="51" style="text-align: center; border-bottom: 1px solid black;">' + v-deposit-bank_name + '</td>' skip
      '<td></td>' skip
      '<td colspan="10">БИК</td>' skip
      '<td colspan="21" style="text-align: center; border-bottom: 1px solid black;">' + v-deposit-bank_bik + '</td>' skip
      '<td colspan="37" style="text-align: center; border: 1px solid black;">в том числе по символам:</td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">Наименование банка-получателя</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">БИК</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">Счет№</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">символ</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">сумма</td>' skip
      '</tr>' skip .
    if v-ok-cashGB then
    do:
      v-sum = string(v-sum-cashGB) .
      v-simvol = "02" .
      v-schetUB = v-schet1 .
    end.
    else
    do:
      v-sum = string(v-sum-cashUB) .
      v-simvol = "32" .
      v-schetUB = v-schet2 .
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">' + v-recip-bank_name1 + '</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">' + v-recip-bank_bik1 + '</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">' + v-schetUB + '</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">' + v-simvol + '</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">' + string(v-sum) + '</td>' skip
      '</tr>' skip .
    if v-ok-cashUB and v-simvol <> "32" then
    do:
      v-sum = string(v-sum-cashUB) .
      v-simvol = "32" .
      v-schetUB = v-schet2 .
    end.
    else
    do:
      v-sum = "" .
      v-simvol = "" .
      v-schetUB = "" .
    end.
    put stream OutStr-html unformatted
      '<tr style="height: 20px;">' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">' + v-recip-bank_name2 + '</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">' + v-recip-bank_bik2 + '</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">' + v-schetUB + '</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">' + v-simvol + '</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">' + string(v-sum) + '</td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="25" style="text-align: left;">Сумма прописью</td>' skip
      '<td></td>' skip
      '<td colspan="94" style="border-bottom: 1px solid black;">' + v-total-rubl + '</td>' skip
      .
    if jj <> 2 then
    do:
      put stream OutStr-html unformatted
        '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
        '<td colspan="21" style="text-align: center; border: 1px solid black;"></td>' skip
        '</tr>' skip .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<td colspan="27" style="text-align: center; border: 1px solid black;">Шифр документа</td>' skip
        '<td colspan="10" style="text-align: center; border: 1px solid black;"></td>' skip
        '</tr>' skip .
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="130" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td colspan="6">руб.</td>' skip
      '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;">' + v-total-kop + '</td>' skip
      '<td colspan="6">коп.</td>' skip
      '<td></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="20"></td>' skip
      '<td></td>' skip
      '<td colspan="108" style="text-align: center;"></td>' skip
      '<td colspan="6"></td>' skip
      '<td colspan="15" style="text-align: center; font-size: 8px;">(цифрами)</td>' skip
      '<td colspan="6"></td>' skip
      '<td></td>' skip
      '</tr>' skip .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="34" style="text-align: center;">Источник поступления</td>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="122" style="border-bottom: 1px solid black;">' + v-source + '</td>' skip
      '</tr>' skip
      '<tr><td colspan="158" style="height:17px;"></td></tr>' skip
      '<tr><td colspan="158" style="height:17px;"></td></tr>' skip.
    if jj <> 3 then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9">Клиент</td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;">' + v-cashier + '</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9"></td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '</tr>'
        .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9">Клиент</td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;">' + v-cashier + '</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9"></td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '</tr>'
        .
      put stream OutStr-html unformatted
        '<tr><td colspan="158" style="text-align: center; border-bottom: 1px solid black;"></td></tr>'
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="25">Опломбированную сумку №</td>' skip
        '<td></td>' skip
        '<td colspan="6" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;">инкассаторский работник</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" rowspan="2" style="text-align: center;">место печати (штампа)</td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="25">без пересчета принял</td>' skip
        '<td></td>' skip
        '<td colspan="6" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center;">дата</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td></td>' skip
        '</tr>'
        .
      put stream OutStr-html unformatted
        '<tr><td colspan="158" style="text-align: center; height: 25px;"></td></tr>'
        '<tr>' skip
        '<td colspan="28" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="24" rowspan="2" style="text-align: center;">Сумка с объявленной суммой принята</td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="18" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="21" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '</tr>' skip.
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="28" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td colspan="18" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="21" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '</tr>' skip.
    end.
    if jj = 2 then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="49">Сумка с объявленной суммой принята</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td colspan="15"></td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="49"></td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="15"></td>' skip
        '</tr>' skip.
    end.
    put stream OutStr-html unformatted
      '</thead>' skip
      '<tbody>' skip
      .
    put stream OutStr-html unformatted
      '</tbody>' skip
      '</table>' skip
      .
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Ведомость_2">'skip
      .
    put stream OutStr-html unformatted
      '<thead>' skip.
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '</tr>' skip
      .
    if jj <> 3 then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="158" style="text-align: center;">Опись сдаваемых наличных денег</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="158" ></td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">Номинал банкнот, монеты</th>' skip
        '<th colspan="52" style="text-align: center; font-weight: bold;">Количество сдаваемых банкнот, монеты (в листах, штуках)</th>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">Сумма цифрами</th>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">1</th>' skip
        '<th colspan="52" style="text-align: center; font-weight: bold;">2</th>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">3</th>' skip
        '</tr>' skip
        .
      for each tt-monets by tt-monets.id:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="53" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-monets.id,"->>>>>>>>>>>9.99",2) + '" style="text-align: center; border: 1px solid black; font-size: 9px;">' + fnc-convert-dot-to-colon(tt-monets.id,"->>>>>>>>>>>9.99",2) + '</td>' skip
          '<td colspan="52" style="text-align: center; border: 1px solid black; font-size: 9px;">' + string(tt-monets.qnty) + '</td>' skip
          '<td colspan="53" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-monets.sum-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: center; border: 1px solid black; font-size: 9px;">' + fnc-convert-dot-to-colon(tt-monets.sum-qnty,"->>>>>>>>>>>9.99",2) + '</td>' skip
          '</tr>' skip
          .
      end.
    end.
    put stream OutStr-html unformatted
      '<tr><td colspAN="158"></td></tr>' skip
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="92">Акт вскрытия сумки и пересчета вложенных наличных денег</td>' skip
      '<td colspan="23"></td>' skip
      '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td colspan="12"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="72"></td>' skip
      '<td colspan="43"></td>' skip
      '<td colspan="30" style="text-align: center; font-size: 8px;">Дата</td>' skip
      '<td colspan="12"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr style="height: 80px;">' skip
      '<td colspan="21" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Фактическая сумма цифрами</td>' skip
      '<td colspan="17" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сумма недостачи цифрами</td>' skip
      '<td colspan="21" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сумма излишка цифрами</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сомнительные денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold; border: 1px solid black;">Неплатежеспособные не имеющие признаков подделки денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold; border: 1px solid black;">Имеющие признаки подделки денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<th colspan="21" style="text-align: center; font-weight: bold; border: 1px solid black;">1</th>' skip
      '<th colspan="17" style="text-align: center; font-weight: bold; border: 1px solid black;">2</th>' skip
      '<th colspan="21" style="text-align: center; font-weight: bold; border: 1px solid black;">3</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">4</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">5</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">6</th>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="21" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="21" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="10">Клиент</td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="19" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '</tr>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '<td colspan="10"></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="19" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '</tr>' skip
      '</thead>' skip
      '<tbody>' skip
      .
    put stream OutStr-html unformatted
      '</tbody>' skip
      '</table>' skip
      .
    put stream OutStr-html unformatted
      '</body>' skip
      '</html>' skip
      .
    output stream OutStr-html close.
    if v-file-name-rep-html1 = "" then v-file-name-rep-html1 = v-file-name-rep-html .
    else v-file-name-rep-html1 =  v-file-name-rep-html1 + " " + v-file-name-rep-html .
  end.
  run prn-lib-reportviewer in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-html1
    ,input "EXCEL:TRUE"
    ).
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
end.
