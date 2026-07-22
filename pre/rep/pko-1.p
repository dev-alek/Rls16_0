block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: b285b6565daa, 3011, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pko-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/pko-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа приход наличные".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print   as logical      no-undo.
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
define variable Line              as character no-undo .
define variable v-str-podr-name   as character no-undo .
define variable v-payer-name-p1   as character no-undo .
define variable v-payer-name-p2   as character no-undo .
define variable v-naznach-plat-p1 as character no-undo .
define variable v-naznach-plat-p2 as character no-undo .
define variable v-naznach-plat-p3 as character no-undo .
define variable v-naznach-plat-p4 as character no-undo .
define variable v-naznach-plat-l1 as character no-undo .
define variable v-naznach-plat-l2 as character no-undo .
define variable v-date-create     as date      no-undo .
define variable v-doc-date-f      as character no-undo .
define variable num-lines         as integer   no-undo .
define variable v-fill            as character no-undo init "_".
define variable v-sum-doc-p1      as character no-undo .
define variable v-sum-doc-p2      as character no-undo .
define variable v-sum-doc-p3      as character no-undo .
define variable v-sum-doc-l1      as character no-undo .
define variable v-sum-doc-l2      as character no-undo .
define variable v-sum-kop-p       as character no-undo .
define variable v-dops            as character no-undo .
define variable v-rub             as character no-undo .
define variable v-kop             as character no-undo .
define variable v-title-rub       as character no-undo .
define variable v-line3           as integer   no-undo .
define variable v-line2           as integer   no-undo .
define variable v-okv-code        as character no-undo .
define variable v-chernovik       as character no-undo .
define variable v-including       as character no-undo .
define variable v-inn             as character no-undo .
define variable g#log             as logical   no-undo .
define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
define variable o-uchet as character no-undo .
define variable v-uchet as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable par-type as character no-undo .
define variable v-tth as handle no-undo .
define variable l-ok  as logical no-undo .
define variable v-hist-name            as character no-undo .
define variable v-hist-code            as character no-undo .
define variable p-report-id          as character no-undo .
define variable v-file-name-rep-html as character no-undo .
define variable ii                   as integer   no-undo .
define variable v-name               as character no-undo .
define variable v-name-report        as character no-undo .
define variable v-obj-name           as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define buffer buf_currency for ub.currency.
do
on error undo, return error return-value
:
  message "Печатать отрывной лист квитанции ? " skip
  view-as alert-box question
  buttons yes-no
  update l-ok .
  mCashBook = new ibs.th.ref.cashbookstorage () .
  o-uchet    = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "uchet") .
  if o-uchet = "0"
  then v-uchet = "cal" .
  else v-uchet = "smen" .
  delete object mCashBook no-error .
  run get-report-num  (output g#report-num).
  v-file-name-rep-html = session:temp-directory + string(g#report-num) + ".html".
  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.
 if p-format <> 1
 and p-format <> ?
 and p-append
 then do:
  assign
  p-format = ?
  .
  return.
 end.
  assign
  Line = fill("_":U, 198)
  .
  assign
  v-chernovik = if buf_fin-doc.status_ = 'новый':U
                then "Ч Е Р Н О В И К"
                else (fill( chr(32), 15))
  .
  if buf_fin-doc.curr-code = 0 then do:
    assign
    v-rub = " руб.":U
    v-kop = " коп.":U
    v-title-rub = fill(chr(32), 3) +  v-rub + v-kop + fill(chr(32), 4)
    .
  end.
  else do:
    find first buf_currency no-lock where
               buf_currency.curr-code = buf_fin-doc.curr-code .
    assign
    v-rub = chr(32) + buf_currency.curr-abbr + ".":U
    v-kop = chr(32) + buf_currency.part-abbr + ".":U
    v-title-rub = "    инвалюты     ":U
    v-okv-code = (if buf_currency.okv-code = 0
                  then "Код ОКВ?"
                  else string(buf_Currency.okv-code))
    .
  end.
  assign
  v-payer-name-p1 = Break-n-line(Buf_fin-doc.payer-name, "72,72", output num-lines)
  v-payer-name-p2 = if num-lines >=2
                   then entry(2, v-payer-name-p1, chr(4))
                   else "":U
  v-payer-name-p1 = entry(1, v-payer-name-p1, chr(4))
  .
  assign
  v-naznach-plat-p1 = Break-n-line(trim(Buf_fin-doc.naznach-plat), "28,35,35,35", output num-lines) .
  v-naznach-plat-p4 = if num-lines >=4
                      then entry(4, v-naznach-plat-p1, chr(4))
                      else "":U .
  v-naznach-plat-p3 = if num-lines >=3
                      then entry(3, v-naznach-plat-p1, chr(4))
                      else "":U .
  v-naznach-plat-p2 = if num-lines >=2
                      then entry(2, v-naznach-plat-p1, chr(4))
                      else "":U .
  v-naznach-plat-p1 = entry(1, v-naznach-plat-p1, chr(4))
  .
  assign
  v-naznach-plat-l1 = Break-n-line(Buf_fin-doc.naznach-plat, "95,106", output num-lines)
  v-naznach-plat-l2 = if num-lines >=2
                      then entry(2, v-naznach-plat-l1, chr(4))
                      else "":U
  v-naznach-plat-l1 = entry(1, v-naznach-plat-l1, chr(4))
  .
  assign
    v-date-create = buf_fin-doc.doc-date
    v-doc-date-f = string(buf_fin-doc.doc-date, "99.99.9999":U) + " г."
  .
  Case buf_fin-doc.str-podr-type :
    when 'маг':U then do:
      find first ub.shop
      where ub.shop.obj-code = buf_fin-doc.str-podr-code
        no-error.
        if available ub.shop then do:
          assign v-str-podr-name = buf_fin-doc.str-podr-name.
        end.
    end.
    when 'скл':U then do:
      find first ub.store
      where ub.store.obj-code = buf_fin-doc.str-podr-code
        no-error.
        if available ub.store then do:
          assign v-str-podr-name = buf_fin-doc.str-podr-name + " " + ub.store.addres1.
        end.
    end.
  end case.
  if v-str-podr-name = "" then v-str-podr-name = buf_fin-doc.str-podr-name .
  find first ub.firm where ub.firm.firm-code = buf_fin-doc.host-code no-error.
  if available ub.firm then do:
    assign v-inn = (if ub.firm.inn <> "" then (" ИНН " + ub.firm.inn) else "").
  end.
    assign
    v-dops = Sum-in-Words-Without-Dec(buf_fin-doc.sum-doc)
    v-sum-kop-p = string((buf_fin-doc.sum-doc - truncate(buf_fin-doc.sum-doc, 0)) * 100, "99":U)
    v-line3 = 41
    v-line2 = 66
    .
  assign
  v-sum-doc-p1 = Break-n-line(v-dops, ("41,41,":U + string(v-line3)), output num-lines)
  v-sum-doc-p3 = If num-lines >= 3
                 then entry(3, v-sum-doc-p1, chr(4))
                 else "":U
  v-sum-doc-p3 = v-sum-doc-p3 +  fill("-":U, 21 - length(v-sum-doc-p3))
  v-sum-doc-p2 = If num-lines >= 2
                 then entry(2, v-sum-doc-p1, chr(4))
                 else "":U
  v-sum-doc-p2 =  v-sum-doc-p2 +  fill("-":U, 41 - length(v-sum-doc-p2))
  v-sum-doc-p1 =  entry(1, v-sum-doc-p1, chr(4))
  v-sum-doc-p1 = v-sum-doc-p1 +  fill("-":U, 21 - length(v-sum-doc-p1))
  v-sum-doc-p1 = caps(substring(v-sum-doc-p1, 1, 1)) + substring(v-sum-doc-p1, 2)
  .
  assign
  v-sum-doc-l1 = Break-n-line(v-dops, ("66,":U + string(v-line2)), output num-lines)
  v-sum-doc-l2 = If num-lines >= 2
                 then entry(2, v-sum-doc-l1, chr(4))
                 else "":U
  v-sum-doc-l2 =  v-sum-doc-l2 +  fill("-":U, v-line2 - length(v-sum-doc-l2))
  v-sum-doc-l1 =  entry(1, v-sum-doc-l1, chr(4))
  v-sum-doc-l1 = v-sum-doc-l1 +  fill("-":U, 66 - length(v-sum-doc-l1))
  v-sum-doc-l1 = caps(substring(v-sum-doc-l1, 1, 1)) + substring(v-sum-doc-l1, 2)
  .
  assign
  v-including = replace(buf_fin-doc.including, "@":U, "":U)
  v-including = trim(v-including, chr(44))
  v-including = replace(v-including, "в том числе", "")
  v-including = replace(v-including, "в т.ч.:", "")
  v-including = replace(v-including, "в т.ч.", "")
  no-error .
    define variable v-sumRubKop         as character    no-undo.
    define variable v-kop-prop          as character    no-undo.
    define variable v-date-string       as character    no-undo.
    assign
        v-sumRubKop = ( if buf_fin-doc.curr-code = 0
                        then
                        trim( Sum-Rub-Kop-Digit (  INPUT buf_fin-doc.sum-doc
                                            ,INPUT 70
                                            ,INPUT 4
                                            ,INPUT " ":U
                                            ,INPUT "":U
                                            ,INPUT v-rub
                                            ,INPUT v-kop
                                            ) )
                        else
                        Sum-Invalut-Digit ( INPUT buf_fin-doc.sum-doc
                                            ,INPUT 40
                                            ,Input buf_fin-doc.curr-code
                                            ,INPUT " ":U
                                            ,INPUT "":U
                                            ))
    .
    assign
        v-kop-prop = ( if buf_fin-doc.curr-code = 0
                       then substitute( "&1 &2&3", v-rub, v-sum-kop-p, v-kop )
                       else "":U
                     )
    .
    assign
        v-date-string = substitute( '"&1" &2 &3 г.'
                                    , string( day( v-date-create ), "99":U )
                                    , MonthNameRusGen( Month( v-date-create ) )
                                    , string( Year( v-date-create ), "9999":U )
                                  )
    .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-code':U,OUTPUT v-hist-code ,OUTPUT par-type) .
if l-ok then do:
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
    '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="Отчет">'skip
    .
  put stream OutStr-html unformatted
    '<thead>' skip
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
    '<td style="width: 30px;"></td>' skip
    '<td style="width: 12px;"></td>' skip
    '<td style="width: 12px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
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
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Унифицированная форма № КО-1</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Утверждена постановлением Госкомстата</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">России от 18.08.98 №88</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + " " + v-inn + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="font-size: 10px; text-align: center;">(организация)</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="49" style="text-align: center;"></td>' skip
    '<td colspan="16" style="text-align: center; border: 1px solid black;">Код</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="35" style="text-align: center;"></td>' skip
    '<td colspan="13" style="text-align: right;">Форма по ОКУД</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">0310001</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">КВИТАНЦИЯ</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + '</td>' skip
    '<td colspan="9" style="text-align: right;">по ОКПО</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">' + string(buf_fin-doc.receiver-okpo) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; font-size: 10px;">(организация)</td>' skip
    '<td colspan="9" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td colspan="16" rowspan="2" style="text-align: center; border: 1px solid black;">' + string( v-hist-code ) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + v-str-podr-name + '</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="27" style="text-align: left;">к приходному кассовому ордеру № </td>' skip
    '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align:center; font-size: 10px;">(структурное подразделение)</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td colspan="16" style="text-align:center;"></td>' skip
    '<td></td>' skip
    '<td style="text-align: center; border-left: 1px solid black; border-right: 1px solid black;">л</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align:right;">от "</td>' skip
    '<td colspan="4" style="text-align:center; border-bottom: 1px solid black;">' + string(day(v-date-create), "99":U) + '</td>' skip
    '<td colspan="2" style="text-align:left;">"</td>' skip
    '<td colspan="15" style="text-align:center; border-bottom: 1px solid black;">' + MonthNameRusGen(Month(v-date-create)) + '</td>' skip
    '<td colspan="1" style="text-align:left;"></td>' skip
    '<td colspan="6" style="text-align:center; border-bottom: 1px solid black;">' + string(Year(v-date-create), "9999") + '</td>' skip
    '<td colspan="2" style="text-align:left;">г.</td>' skip
    '<td colspan="6" style="text-align:left;"></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align:center;"></td>' skip
    '<td colspan="10" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Номер</td>' skip
    '<td colspan="14" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Дата</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '<td colspan="10" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">документа</td>' skip
    '<td colspan="14" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">составления</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">и</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="9" style="text-align: left;">Принято от</td>' skip
    '<td colspan="32" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР</td>' skip
    '<td colspan="10" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '<td colspan="14" style="text-align: center; border: 1px solid black;">' + string(v-doc-date-f) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + v-payer-name-p2 + '</td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="14" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">н</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="9" style="text-align: left;">Основание:</td>' skip
    '<td colspan="32" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-p1 + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" rowspan="4" style="text-align: center; border: 1px solid black;">Дебет</td>' skip
    '<td text_wrap="true" colspan="33" style="text-align: center; border: 1px solid black;">Кредит</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="9" style="text-align: center; border: 1px solid black;">Сумма, руб. коп.</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="10" style="text-align: center; border: 1px solid black;">Код целевого назначения</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="7" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; height: 12px; border-bottom: 1px solid black;">' + v-naznach-plat-p2 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" rowspan="3" colspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">код структурного подразделения</td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">корреспондирующий счет, субсчет</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="3" style="text-align: center; border: 1px solid black;">код аналитического учета</td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">и</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; height: 12px; border-bottom: 1px solid black;">' + v-naznach-plat-p3 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; height: 12px; border-bottom: 1px solid black;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">я</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left;">' + v-naznach-plat-p4 + '</td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" colspan="6" rowspan="2" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.cor-acc1-value) + '</td>' skip
    '<td text_wrap="true" colspan="4" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + "-" + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cor-acc-value = "" then "-"  + '</td>' else buf_fin-doc.cor-acc-value + '</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.an-uchet-value = "" then "-"  + '</td>' else buf_fin-doc.an-uchet-value + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + Sum-delim-with-defis(buf_fin-doc.sum-doc, 14) + '</td>' skip
    '<td text_wrap="true" colspan="10" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cel-nazn-value = "" then "-"  + '</td>' else buf_fin-doc.cel-nazn-value + '</td>' skip
    '<td text_wrap="true" colspan="7" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="6" style="text-align: center;">Сумма</td>' skip
    '<td colspan="34" style="text-align:left; border-bottom: 1px solid black;">' + string(v-sumRubKop) + '</td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="6" style="text-align: center;"></td>' skip
    '<td colspan="34" style="text-align: center; font-size: 10px;">(цифрами)</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Принято от</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">о</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; border-bottom: 1px solid black;">' + string(v-sum-doc-p1) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="55" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Основание:</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-l1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">т</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-doc-p2) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: right; border-bottom: 1px solid black;">' + v-naznach-plat-l2 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">р</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-doc-p3) + '</td>' skip
    '<td colspan="5" style="text-align: left;">руб.</td>' skip
    '<td colspan="5" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="4" style="text-align: left;">коп.</td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;">Сумма</td>' skip
    '<td colspan="59" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-l1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">е</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="31" text_wrap="true" style="text-align: left; border-bottom: 1px solid black;">' + replace(v-including, "@":U, "":U) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;"></td>' skip
    '<td colspan="59" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">з</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="48" style="text-align: right; border-bottom: 1px solid black;">' + v-sum-doc-l2 + '</td>' skip
    '<td colspan="3" style="text-align: left;">руб.</td>' skip
    '<td colspan="7" style="text-align: right; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="7" style="text-align: left;">коп.</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">а</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="2" style="text-align: right;">"</td>' skip
    '<td colspan="4" style="text-align: center; border-bottom: 1px solid black;">' + string(day(v-date-create), "99":U) + '</td>' skip
    '<td colspan="2" style="text-align: left;">"</td>' skip
    '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;">' + MonthNameRusGen(Month(v-date-create)) + '</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="6" style="text-align: center; border-bottom: 1px solid black;">' + string(Year(v-date-create), "9999") + '</td>' skip
    '<td colspan="2" style="text-align: left;">г.</td>' skip
    '<td colspan="8" style="text-align: left;"></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-including + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip
    '<td colspan="13" rowspan="2" style="text-align: center;">М.П. (штампа)</td>' skip
    '<td colspan="15" style="text-align: center;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Приложение</td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: left; border-bottom: 1px solid black;">' + buf_fin-doc.enclosure + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip
    '<td colspan="15" style="text-align: center;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip   .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: left; border-bottom: 1px solid black;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
    '</tr>' skip            .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Получил кассир</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">Кассир</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: left; border-bottom: 1px solid black;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '</tr>' skip         .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
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
end.
else do:
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
    '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="Отчет">'skip
    .
  put stream OutStr-html unformatted
    '<thead>' skip
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
    '</tr>' skip
    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Унифицированная форма № КО-1</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Утверждена постановлением Госкомстата</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">России от 18.08.98 №88</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="49" style="text-align: center;"></td>' skip
    '<td colspan="16" style="text-align: center; border: 1px solid black;">Код</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="35" style="text-align: center;"></td>' skip
    '<td colspan="13" style="text-align: right;">Форма по ОКУД</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">0310001</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + '</td>' skip
    '<td colspan="9" style="text-align: right;">по ОКПО</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">' + string(buf_fin-doc.receiver-okpo) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; font-size: 10px;">(организация)</td>' skip
    '<td colspan="9" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td colspan="16" rowspan="2" style="text-align: center; border: 1px solid black;">' + string( v-hist-code ) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + v-str-podr-name + '</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align:center; font-size: 10px;">(структурное подразделение)</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td colspan="16" style="text-align:center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align:center;"></td>' skip
    '<td colspan="10" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Номер</td>' skip
    '<td colspan="14" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Дата</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '<td colspan="10" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">документа</td>' skip
    '<td colspan="14" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">составления</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР</td>' skip
    '<td colspan="10" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '<td colspan="14" style="text-align: center; border: 1px solid black;">' + string(v-doc-date-f) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="14" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" rowspan="4" style="text-align: center; border: 1px solid black;">Дебет</td>' skip
    '<td text_wrap="true" colspan="33" style="text-align: center; border: 1px solid black;">Кредит</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="9" style="text-align: center; border: 1px solid black;">Сумма, руб. коп.</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="10" style="text-align: center; border: 1px solid black;">Код целевого назначения</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="7" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" rowspan="3" colspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">код структурного подразделения</td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">корреспондирующий счет, субсчет</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="3" style="text-align: center; border: 1px solid black;">код аналитического учета</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" colspan="6" rowspan="2" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.cor-acc1-value) + '</td>' skip
    '<td text_wrap="true" colspan="4" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + "-" + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cor-acc-value = "" then "-"  + '</td>' else buf_fin-doc.cor-acc-value + '</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.an-uchet-value = "" then "-"  + '</td>' else buf_fin-doc.an-uchet-value + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + Sum-delim-with-defis(buf_fin-doc.sum-doc, 14) + '</td>' skip
    '<td text_wrap="true" colspan="10" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cel-nazn-value = "" then "-"  + '</td>' else buf_fin-doc.cel-nazn-value + '</td>' skip
    '<td text_wrap="true" colspan="7" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Принято от</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="55" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Основание:</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-l1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: right; border-bottom: 1px solid black;">' + v-naznach-plat-l2 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;">Сумма</td>' skip
    '<td colspan="59" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-l1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;"></td>' skip
    '<td colspan="59" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="48" style="text-align: right; border-bottom: 1px solid black;">' + v-sum-doc-l2 + '</td>' skip
    '<td colspan="3" style="text-align: left;">руб.</td>' skip
    '<td colspan="7" style="text-align: right; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="7" style="text-align: left;">коп.</td>' skip
    '<td></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-including + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Приложение</td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: left; border-bottom: 1px solid black;">' + buf_fin-doc.enclosure + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip   .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip            .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Получил кассир</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '<td colspan="3"></td>' skip
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
end.
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-html
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
