block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rpp-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/rpp-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа расход безнал".
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define variable v-rpp1xl-current-data-row     as integer      no-undo.
define variable v-rpp1xl-cell-file-name       as character    no-undo.
procedure rpp1xl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-rpp1xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rpp1xl-cell-file-name
    ).
    output stream excel-cell to value( v-rpp1xl-cell-file-name ).
    if printrubl = yes
    then do:
        run rpp1xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run rpp1xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run rpp1xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "0":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "0":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
        input "subtotalPropisList":U
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
        input "subtotalPropisAmount":U
        , input "0":U
    ).
end.
end procedure.
procedure rpp1xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/pp.xlt":U.
        export "exe/t_97.bas":U.
        export v-rpp1xl-cell-file-name.
        export "":U.
    output close.
end.
end procedure.
procedure rpp1xl-write-cell-data :
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
define variable Line as character no-undo .
define variable v-doc-date-f      as character no-undo .
define variable v-pay-date-f      as character no-undo .
define variable v-fact-date-f      as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-sum-doc as character no-undo extent 3.
define variable v-payer-name as character no-undo extent 5.
define variable v-payer-bank-name as character no-undo extent 3.
define variable v-receiver-name as character no-undo extent 5.
define variable v-receiver-bank-name as character no-undo extent 3.
define variable v-dops as character no-undo .
define variable v-naznach-pl as character no-undo extent 3.
define variable ii as integer no-undo .
define variable v-chernovik as character no-undo .
define variable v-receiver-bank-name-full     as character    no-undo.
define variable v-receiver-name-full          as character    no-undo.
define variable v-payer-bank-name-full        as character    no-undo.
define variable v-payer-name-full             as character    no-undo.
define variable v-naznach-pl-full             as character    no-undo.
define variable g#log as logical no-undo .
define buffer buf_currency for ub.currency.
do
on error undo, return error return-value
:
   run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run rpp1xl-init in this-procedure .
 if p-format <> 0
 and p-format <> ?
 and p-append
 then do:
    assign
    p-format = ?
    .
   return.
 end.
  assign
  v-chernovik = if buf_fin-doc.status_ = 'новый':U
                then "Ч Е Р Н О В И К"
                else (fill( chr(32), 15))
  .
  assign
  v-doc-date-f = string(buf_fin-doc.doc-date, "99.99.9999":U)
  v-pay-date-f = if buf_fin-doc.pay-date <> ?
                 then string(buf_fin-doc.pay-date, "99.99.9999":U)
                 else "":U
  v-fact-date-f = if buf_fin-doc.fact-date <> ?
                  then string(buf_fin-doc.pay-date, "99.99.9999":U)
                  else "":U
  .
  assign
  v-dops = Sum-in-Words-Invalut(buf_fin-doc.sum-doc, buf_fin-doc.curr-code)
  v-sum-doc[1] =  Break-n-line(v-dops, "76,76,76", output num-lines)
  .
  do ii = 3 to 1 by -1 :
    assign
    v-sum-doc[ii] = If num-lines >= ii
                      then entry(ii, v-sum-doc[1], chr(4))
                      else "":U
    v-sum-doc[ii] =  v-sum-doc[ii] +  fill(chr(32), 76 - length(v-sum-doc[ii]))
    .
  end.
  assign
  v-sum-doc[1] = caps(substring(v-sum-doc[1], 1, 1)) + substring(v-sum-doc[1], 2)
  .
  assign
    v-payer-name-full = buf_fin-doc.payer-name
                        + ( if buf_fin-doc.payer-dop1 = "":U
                            then "":U
                            else ( chr(44)
                                    + chr(32) ) )
                        + buf_Fin-doc.payer-dop1
    v-payer-name[1]   = Break-n-line( v-payer-name-full, "53,53,53,53,53":U, output num-lines)
  .
  do ii = 5 to 1 by -1 :
    assign
    v-payer-name[ii] = If num-lines >= ii
                      then entry(ii, v-payer-name[1], chr(4))
                      else "":U
    v-payer-name[ii] =  v-payer-name[ii] +  fill(chr(32), 53 - length(v-payer-name[ii]))
    .
  end.
  assign
    v-payer-bank-name-full = (buf_fin-doc.payer-bank-name + chr(44) + chr(32) + buf_fin-doc.payer-bank-city)
                                + ( if buf_fin-doc.payer-dop2 = "":U
                                    then "":U
                                    else ( chr(44)
                                            + chr(32)))
                                + buf_fin-doc.payer-dop2
    v-payer-bank-name[1]   = Break-n-line( v-payer-bank-name-full, "53,53,53":U, output num-lines)
  .
  do ii = 3 to 1  by -1:
    assign
    v-payer-bank-name[ii] = If num-lines >= ii
                      then entry(ii, v-payer-bank-name[1], chr(4))
                      else "":U
    v-payer-bank-name[ii] =  v-payer-bank-name[ii] +  fill(chr(32), 53 - length(v-payer-bank-name[ii]))
    .
  end.
  assign
    v-receiver-name-full = buf_fin-doc.receiver-name
                            + ( if buf_fin-doc.receiver-dop1 = "":U
                                then "":U
                                else ( chr(44)
                                        + chr(32) ) )
                            + buf_Fin-doc.receiver-dop1
    v-receiver-name[1]   = Break-n-line( v-receiver-name-full
                                         , "53,53,53,53,53":U
                                         , output num-lines )
  .
  do ii = 5 to 1  by -1:
    assign
    v-receiver-name[ii] = If num-lines >= ii
                      then entry(ii, v-receiver-name[1], chr(4))
                      else "":U
    v-receiver-name[ii] =  v-receiver-name[ii] +  fill(chr(32), 53 - length(v-receiver-name[ii]))
    .
  end.
  assign
    v-receiver-bank-name-full = (buf_fin-doc.receiver-bank-name + chr(44) + chr(32) + buf_fin-doc.receiver-bank-city)
                                + ( if buf_fin-doc.receiver-dop2 = "":U
                                    then "":U
                                    else ( chr(44)
                                           + chr(32) ) )
                                + buf_Fin-doc.receiver-dop2
    v-receiver-bank-name[1]   = Break-n-line( v-receiver-bank-name-full, "53,53,53":U, output num-lines)
  .
  do ii = 3 to 1  by -1:
    assign
    v-receiver-bank-name[ii] = If num-lines >= ii
                      then entry(ii, v-receiver-bank-name[1], chr(4))
                      else "":U
    v-receiver-bank-name[ii] =  v-receiver-bank-name[ii] +  fill(chr(32), 53 - length(v-receiver-bank-name[ii]))
    .
  end.
  assign
    v-naznach-pl-full = replace( buf_fin-doc.naznach-plat, "@", "":U )
    v-naznach-pl[1]   = Break-n-line( v-naznach-pl-full, "76,76,76":U, output num-lines)
  .
  do ii = 3 to 1  by -1:
    assign
    v-naznach-pl[ii] = If num-lines >= ii
                      then entry(ii, v-naznach-pl[1], chr(4))
                      else "":U
    v-naznach-pl[ii] =  v-naznach-pl[ii] +  fill(chr(32), 76 - length(v-naznach-pl[ii]))
    .
  end.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 62
                                              ,input yes
                                              ,input p-append
                                              ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_payDate":U            , input v-pay-date-f                                                ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_factDate":U           , input v-fact-date-f                                               ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_docDate":U            , input v-doc-date-f                                                ).
    run rpp1xl-write-cell-data in this-procedure ( input "vidPlat":U              , input buf_fin-doc.vid-plat                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input "prnDocCode":U           , input "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N " + buf_fin-doc.prn-doc-code         ).
    run rpp1xl-write-cell-data in this-procedure ( input "statPl":U               , input buf_fin-doc.stat-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input "sumDocPropis":U         , input v-dops                                                      ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerInn":U             , input "ИНН " + buf_fin-doc.payer-inn                              ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerKpp":U             , input "КПП " + buf_fin-doc.payer-kpp                              ).
    run rpp1xl-write-cell-data in this-procedure ( input "sumDoc":U               , input trim( Sum-delim-with-defis(buf_fin-doc.sum-doc, 13) )       ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerName":U            , input v-payer-name-full                                           ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerRSchet":U          , input payer-r-schet                                               ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerBankName":U        , input v-payer-bank-name-full                                      ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerBik":U             , input buf_Fin-doc.payer-bik                                       ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerCSchet":U          , input buf_fin-doc.payer-c-schet                                   ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverBankName":U     , input v-receiver-bank-name-full                                   ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverBik":U          , input buf_fin-doc.receiver-bik                                    ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverCSchet":U       , input buf_fin-doc.receiver-c-schet                                ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverRSchet":U       , input buf_fin-doc.receiver-r-schet                                ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverInn":U          , input "ИНН " + buf_fin-doc.receiver-inn                           ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverKpp":U          , input "КПП " + buf_fin-doc.receiver-kpp                           ).
    run rpp1xl-write-cell-data in this-procedure ( input "receiverName":U         , input v-receiver-name-full                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input "vidOpl":U               , input buf_fin-doc.vid-opl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input "srokPl":U               , input buf_fin-doc.srok-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input "naznPlat":U             , input buf_fin-doc.nazn-pl                                         ).
    run rpp1xl-write-cell-data in this-procedure ( input "ocherPl":U              , input buf_fin-doc.ocher-pl                                        ).
    run rpp1xl-write-cell-data in this-procedure ( input "kodPoluchat":U          , input buf_fin-doc.f22                                             ).
    run rpp1xl-write-cell-data in this-procedure ( input "rezPole":U              , input buf_fin-doc.f23                                             ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f104":U               , input buf_fin-doc.f104                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f105":U               , input buf_fin-doc.f105                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f106":U               , input buf_fin-doc.f106                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f107":U               , input buf_fin-doc.f107                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f108":U               , input buf_fin-doc.f108                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f109":U               , input buf_fin-doc.f109                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "h_f110":U               , input buf_fin-doc.f110                                            ).
    run rpp1xl-write-cell-data in this-procedure ( input "naznachPl":U            , input v-naznach-pl-full                                           ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerSign1":U           , input buf_fin-doc.payer-sign1                                     ).
    run rpp1xl-write-cell-data in this-procedure ( input "payerSign2":U           , input buf_fin-doc.payer-sign2                                     ).
PUT  STREAM PrnLibStream unformatted
v-chernovik    "                                                              -----------"  skip
"                                                                             | 0401060 |"  skip
chr(32) chr(32) center-field(v-pay-date-f, 22, 22, v-fill)
                fill(chr(32), 12) center-field(v-fact-date-f, 22, 22, v-fill) fill(chr(32), 19)
                                                                             "-----------"  skip
"   Поступ. в банк плат.              Списано со сч. плат.                               "  skip
"                                                                                        "  skip
"                                          " center-field(v-doc-date-f, 12, 12, chr(32))
                                 fill(chr(32), 7)
                                   center-field(buf_fin-doc.vid-plat, 13, 13, chr(32))
                                                                      "      -----"  skip
"  ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N " center-field(buf_fin-doc.prn-doc-code, 16,16, chr(32))
                                "  ------------       -------------      |"
                                                                                   center-field(buf_fin-doc.stat-pl, 3,3, chr(32))
                                                                                       "|"  skip
"                                              Дата            Вид платежа       -----"  skip
"                                                                                        "  skip
"  Сумма    |" v-sum-doc[1]
                                                                                            skip
"  прописью |" v-sum-doc[2]
                                                                                            skip
string(if v-sum-doc[3] <> "":U
then ("           |" + v-sum-doc[3] + chr(10))
else "":U)
"  --------------------------------------------------------------------------------------"  skip
.
PUT  STREAM PrnLibStream unformatted
"  ИНН " string(buf_fin-doc.payer-inn, "X(24)")
                    "|КПП " string(buf_fin-doc.payer-kpp, "X(20)")
                                   "|Сумма   |" chr(32) trim(Sum-delim-with-defis(buf_fin-doc.sum-doc, 13))
                                                                                            skip
"  -----------------------------------------------------|        |                       "  skip
.
PUT  STREAM PrnLibStream unformatted
chr(32) chr(32) v-payer-name[1]
                                                       "|        |                       "  skip
chr(32) chr(32) v-payer-name[2]
                                                       "|        |                       "  skip
chr(32) chr(32) v-payer-name[3]
                                                       "|--------+-----------------------"  skip
chr(32) chr(32) v-payer-name[4]
                                                       "|Сч. N   |" chr(32) buf_fin-doc.payer-r-schet
                                                                                            skip
chr(32) chr(32) v-payer-name[5]
                                                       "|        |                       "  skip
"  Плательщик                                           |        |                       "  skip
"  -----------------------------------------------------+--------|                       "  skip
.
PUT  STREAM PrnLibStream unformatted
chr(32) chr(32) v-payer-bank-name[1]
                                                       "|БИК     |" chr(32) buf_Fin-doc.payer-bik
                                                                                            skip
chr(32) chr(32) v-payer-bank-name[2]
                                                       "|--------|                       "  skip
chr(32) chr(32) v-payer-bank-name[3]
                                                       "|Сч. N   |" chr(32) buf_fin-doc.payer-c-schet
                                                                                            skip
"  Банк плательщика                                     |        |                       "  skip
"  -----------------------------------------------------+--------+-----------------------"  skip
chr(32) chr(32) v-receiver-bank-name[1]
                                                       "|БИК     |" chr(32) buf_fin-doc.receiver-bik
                                                                                             skip
chr(32) chr(32) v-receiver-bank-name[2]
                                                        "|--------|                       "  skip
chr(32) chr(32) v-receiver-bank-name[3]
                                                        "|Сч. N   |" chr(32) buf_fin-doc.receiver-c-schet
                                                                                            skip
"  Банк получателя                                      |        |                       "  skip
"  -----------------------------------------------------+--------|                       "  skip
"  ИНН " string(buf_fin-doc.receiver-inn, "X(24)")
                              "|КПП " string(buf_fin-doc.receiver-kpp, "X(20)")
                                                       "|Сч. N   |" chr(32) buf_fin-doc.receiver-r-schet
                                                                                            skip
"  -----------------------------------------------------|        |                       "  skip
chr(32) chr(32) v-receiver-name[1]
                                                       "|--------+-----------------------"  skip
chr(32) chr(32) v-receiver-name[2]
                                                       "|Вид оп. |" CeNter-field(buf_FIN-DOC.VID-OPL, 6, 6, chr(32))
                                                                           "|Срок плат. |"
                                                                                          CeNter-field(buf_FIN-DOC.srok-pl, 4, 4, chr(32))
                                                                                             skip
chr(32) chr(32) v-receiver-name[3]
                                                        "|--------|      |-----------|    "  skip
chr(32) chr(32) v-receiver-name[4]
                                                        "|Наз. пл.|" CeNter-field(buf_FIN-DOC.nazn-pl, 6, 6, chr(32))
                                                                         "|Очер. плат.|"
                                                                                       CeNter-field(buf_FIN-DOC.ocher-pl, 6, 6, chr(32))
                                                                                            skip
chr(32) chr(32) v-receiver-name[5]
                                                       "|--------|      |-----------|    "  skip
"  Получатель                                           |Код     |"
                                                                    CeNter-field(buf_FIN-DOC.f22, 6, 6, chr(32))
                                                                          "|Рез. поле  |"
                                                                                       buf_FIN-DOC.f23
                                                                                            skip
"  --------------------------------------------------------------------------------------"  skip
.
PUT  STREAM PrnLibStream unformatted
chr(32) chr(32) CeNter-field(buf_FIN-DOC.f104, 13, 13, chr(32))
          "|"
             CeNter-field(buf_FIN-DOC.f105, 16, 16, chr(32))
                          "|"  CeNter-field(buf_FIN-DOC.f106, 8, 8, chr(32))
                                "|" CeNter-field(buf_FIN-DOC.f107, 14, 14, chr(32))
                                          "|" CeNter-field(buf_FIN-DOC.f108, 14, 14, chr(32))
                                                      "|" CeNter-field(buf_FIN-DOC.f109, 12, 12, chr(32))
                                                                 "|" buf_FIN-DOC.f110
                                                                                            skip
"  --------------------------------------------------------------------------------------"  skip
chr(32) chr(32) v-naznach-pl[1]
                                                                                            skip
chr(32) chr(32) v-naznach-pl[2]
                                                                                            skip
chr(32) chr(32) v-naznach-pl[3]
                                                                                            skip
"  Назначение платежа                                                                    "  skip
"  --------------------------------------------------------------------------------------"  skip
"                               Подписи                                Отметки банка     "  skip
"                    "
                 CeNter-field(buf_FIN-DOC.payer-sign1, 50, 50, chr(32))
                                                                        "                  "  skip
"                    _____________________________________________                         "  skip
"      М.П.          "
                 CeNter-field(buf_FIN-DOC.payer-sign2, 50, 50, chr(32))
                                                                        "                  "  skip
"                    _____________________________________________                         "  skip
.
  if p-append and not p-is-last then Page stream PrnLibStream .
  output  STREAM PrnLibStream CLOSE.
  assign
  p-format = 0
  .
    run rpp1xl-close in this-procedure .
    if p-from-forms then do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
    end.
    else do:
    if not p-append
    then do:
        os-delete
            value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
        os-rename
            value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
        run prn-lib-prn-file in this-procedure (
              input parParentProc
            , input 0
        ).
        os-delete
            value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
        os-delete
            value( v-rpp1xl-cell-file-name )
        .
    end.
    end.
end.
