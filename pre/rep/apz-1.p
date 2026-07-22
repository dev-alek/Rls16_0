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
define variable vss-workfile    as character no-undo init "$Workfile: apz-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/apz-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа приход-расход АПЗ".
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
define variable g#quest-print   as logical      no-undo.
define variable g#report-num  as integer no-undo .
define variable Line as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-sum-doc-v1 as character no-undo .
define variable v-sum-doc-v2 as character no-undo .
define variable v-sum-doc-n1 as character no-undo .
define variable v-sum-doc-n2 as character no-undo .
define variable v-sum-kop-p  as character no-undo .
define variable v-dops as character no-undo .
define variable v-head-position as character no-undo .
define variable v-payer-sign1 as character no-undo .
define variable v-receiver-sign1 as character no-undo .
define variable v-rub as character no-undo .
define variable v-kop as character no-undo .
define variable v-title-rub as character no-undo .
define variable v-line3 as integer no-undo .
define variable v-line2 as integer no-undo .
define variable v-okv-code as character no-undo .
define variable v-chernovik as character no-undo .
define variable v-naznach-plat-1 as character no-undo .
define variable v-naznach-plat-2  as character no-undo .
define variable acc as decimal no-undo .
define variable v-exist as logical no-undo .
define variable date_string     as      char    no-undo.
define variable g#log as logical no-undo .
define buffer buf_currency for ub.currency.
define buffer buf_contract for ub.contract.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-ob for ub.fin-ob .
define buffer buf_fin-gds-part for ub.fin-gds-part.
define temp-table temp-trn-doc no-undo
field fin-ob-code like ub.fin-gds-part.fin-ob-code
field in-code like ub.fin-gds-part.in-code
field prn-doc-code like ub.fin-ob.prn-doc-code
field sum-doc like ub.fin-ob.sum-doc
field PS like ub.fin-connect.PS
index pi is unique primary
fin-ob-code
in-code
.
define buffer buf_temp-trn-doc for temp-trn-doc.
DEFINE FRAME doc-list
buf_temp-trn-doc.in-code COLUMN-LABEL "Документ основания"
buf_temp-trn-doc.prn-doc-code "Номер ФО"
buf_temp-trn-doc.sum-doc "Сумма погашения"
buf_temp-trn-doc.PS "Примечания!(причины, условия погашения и т.д.)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
do
on error undo, return error
:
 run waitfram-show in this-procedure ("Ждите...").
  run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
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
  Line = fill("_":U, 136)
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
    .
  end.
  else do:
    find first buf_currency no-lock where
               buf_currency.curr-code = buf_fin-doc.curr-code .
    assign
    v-rub = chr(32) + buf_currency.curr-abbr + ".":U
    v-kop = chr(32) + buf_currency.part-abbr + ".":U
    v-title-rub = "       инвалюты       ":U
    v-okv-code = (if buf_currency.okv-code = 0
                  then "Код ОКВ?"
                  else string(buf_Currency.okv-code))
    .
  end.
  assign
  v-naznach-plat-1 = Break-n-line(buf_fin-doc.naznach-plat, "102,136":U, output num-lines)
  v-naznach-plat-2 = (if num-lines >=2
                      then entry(2, v-naznach-plat-1, chr(4))
                      else "":U
                      )
  v-naznach-plat-1 = entry(1, v-naznach-plat-1, chr(4))
  .
  if buf_fin-doc.curr-code = 0 then do:
    assign
    v-dops = Sum-in-Words-Without-Dec(buf_fin-doc.sum-doc)
    .
    assign
    v-sum-kop-p = string((buf_fin-doc.sum-doc - truncate(buf_fin-doc.sum-doc, 0)) * 100, "99":U)
    v-dops = v-dops + chr(32) + v-rub +  chr(32)  + v-sum-kop-p + v-kop
    .
    v-line2 = 98.
  end.
  else do:
    assign
    v-dops = Sum-in-Words-Invalut(buf_fin-doc.sum-doc, buf_fin-doc.curr-code)
    v-line2 = 98
    .
  end.
  assign
  v-sum-doc-v1 = Break-n-line(v-dops, ("76,136":U + string(v-line2)), output num-lines)
  v-sum-doc-v2 = If num-lines >= 2
                 then entry(2, v-sum-doc-v1, chr(4))
                 else "":U
  v-sum-doc-v2 =  v-sum-doc-v2 +  fill( chr(32) , v-line2 - length(v-sum-doc-v2))
  v-sum-doc-v1 =  entry(1, v-sum-doc-v1, chr(4))
  v-sum-doc-v1 = v-sum-doc-v1 +  fill( chr(32) , 76 - length(v-sum-doc-v1))
  v-sum-doc-v1 = caps(substring(v-sum-doc-v1, 1, 1)) + substring(v-sum-doc-v1, 2)
  .
  assign
  v-sum-doc-n1 = Break-n-line(v-dops, ("98,136":U + string(v-line2)), output num-lines)
  v-sum-doc-n2 = If num-lines >= 2
                 then entry(2, v-sum-doc-n1, chr(4))
                 else "":U
  v-sum-doc-n2 = v-sum-doc-n2 +  fill( chr(32) , v-line2 - length(v-sum-doc-n2))
  v-sum-doc-n1 = entry(1, v-sum-doc-n1, chr(4))
  v-sum-doc-n1 = v-sum-doc-n1 +  fill( chr(32) , 98 - length(v-sum-doc-n1))
  v-sum-doc-n1 = caps(substring(v-sum-doc-n1, 1, 1)) + substring(v-sum-doc-n1, 2)
  .
  assign
  v-head-position = string(if num-entries(buf_fin-doc.payer-sign1, chr(4))  > 1
                            then entry(1, buf_fin-doc.payer-sign1, chr(4))
                            else "Директор", "X(25)")
  v-payer-sign1         = string(if num-entries(buf_fin-doc.payer-sign1, chr(4))  > 1
                            then entry(2, buf_fin-doc.payer-sign1, chr(4))
                            else entry(1, buf_fin-doc.payer-sign1, chr(4))
                            , "X(25)")
  v-receiver-sign1         = string(if num-entries(buf_fin-doc.payer-sign1, chr(4))  > 1
                            then entry(2, buf_fin-doc.payer-sign1, chr(4))
                            else entry(1, buf_fin-doc.payer-sign1, chr(4)), "X(25)")
  .
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 62
                                              ,input yes
                                              ,input p-append
                                              ).
  PUT  STREAM PrnLibStream unformatted
  skip(1)
  v-chernovik
  skip(2)
  fill(chr(32), 20) "Акт погашения задолженности № "  buf_fin-doc.prn-doc-code
  "     от " string(day(buf_fin-doc.doc-date))
  chr(32) MonthNameRusGen(Month(buf_fin-doc.doc-date))
  chr(32) string(Year(buf_fin-doc.doc-date)) chr(32) "г."
  skip(1).
  if buf_fin-doc.contract-code <> 0 then do:
    find first buf_contract no-lock where
              buf_Contract.host-code = buf_fin-doc.host-code
          AND buf_Contract.contract-code = buf_fin-doc.contract-code.
    Put Stream PrnLibStream unformatted
    fill(chr(32), 20) "по договору № " buf_contract.contract-prn-code
    "     от " string(day(buf_contract.contract-date))
    chr(32) MonthNameRusGen(Month(buf_contract.contract-date))
    chr(32) string(Year(buf_contract.contract-date)) chr(32) "г."
    skip(2).
  end.
  PUT  STREAM PrnLibStream unformatted
  fill(chr(32), 10) "ФИРМA:          " (if buf_fin-doc.fin-ext-doc-type = 'апп':U
                                              then buf_fin-doc.receiver-name
                                              else buf_fin-doc.payer-name)
  skip(2)
  fill(chr(32), 10) "КОНТРАГЕНТ:     " (if buf_fin-doc.fin-ext-doc-type = 'апп':U
                                              then buf_fin-doc.payer-name
                                              else buf_fin-doc.receiver-name)
  skip(3).
  PUT  STREAM PrnLibStream unformatted
  fill(chr(32), 20) "Представители " skip(0)
  fill(chr(32), 20) "ФИРМЫ - "
  (if buf_fin-doc.fin-ext-doc-type = 'апп':U
    then buf_fin-doc.receiver-name
    else buf_fin-doc.payer-name)
    " и " skip(0)
  fill(chr(32), 20) "КОНТРАГЕНТА - "
  (if buf_fin-doc.fin-ext-doc-type = 'апп':U
    then buf_fin-doc.payer-name
    else buf_fin-doc.receiver-name)
    skip(1)
    "на основании произведенных сверок по суммам поставок и суммам платежей "
    (if buf_fin-doc.contract-code <> 0
    then "согласно данного Договора "
    else "":U) skip(1)
    substitute("подтвердили расхождения в выполнении &1 финансовых обязательств на сумму "
              , (if buf_fin-doc.fin-ext-doc-type = 'апп':U
                 then "Контрагентом"
                 else "Фирмой"
                 )
              ) v-sum-doc-v1 skip(0)
    (if v-sum-doc-v2 <> "":U then v-sum-doc-v2 else "":U)
    skip(1).
  PUT  STREAM PrnLibStream unformatted
  "По соглашению сторон выявленная сумма " v-sum-doc-n1 skip(0)
  (if v-sum-doc-n2 <> "":U then v-sum-doc-n2 else "":U)
  "считается погашенной на основании " v-naznach-plat-1 skip(0)
  (if v-naznach-plat-2 <> "":U
  then (v-naznach-plat-2 + chr(10))
  else "":U)
  skip(2).
  PUT  STREAM PrnLibStream unformatted
  fill(chr(32), 20) "Данный Акт составлен в двух экземплярах, каждый из которых имеет одинаковую юридическую силу."
  skip(5).
  PUT  STREAM PrnLibStream unformatted
  fill(chr(32), 20) "ФИРМА" fill(chr(32), 70) "КОНТРАГЕНТ" skip(2)
  v-head-position
  v-payer-sign1 AT 40
  v-receiver-sign1 AT 80 skip(2)
  fill("-", 25) fill(chr(32), 2)
  fill("-", 10) fill(chr(32), 2)
  fill("-", 25) fill(chr(32), 2)
  fill(chr(32), 5)
  fill("-", 25) fill(chr(32), 2)
  fill("-", 10) fill(chr(32), 2)
  fill("-", 25) fill(chr(32), 2)
  skip(0)
  fill(chr(32), 8) "должность" fill(chr(32), 8)  fill(chr(32), 2)
  fill(chr(32), 1) "подпись"   fill(chr(32), 2)  fill(chr(32), 2)
  fill(chr(32), 4) "расшифровка подписи" fill(chr(32), 4)  fill(chr(32), 2)
  fill(chr(32), 3)
  fill(chr(32), 8) "должность" fill(chr(32), 8)  fill(chr(32), 2)
  fill(chr(32), 1) "подпись"   fill(chr(32), 2)  fill(chr(32), 2)
  fill(chr(32), 4) "расшифровка подписи" fill(chr(32), 4)  fill(chr(32), 2)
  skip(2)
  fill(chr(32), 10) "МП"
  fill(chr(32), 70) "МП"
  skip
  .
  for each buf_temp-trn-doc:
    delete buf_temp-trn-doc.
  end.
  assign
  v-exist = no
  .
  if v-exist then do:
    Page stream PrnLibStream .
    PUT  STREAM PrnLibStream
    SPACE(25)
    "Спецификация к акту  погашения задолженности №" buf_fin-doc.prn-doc-code " от "
    "     от " string(day(buf_fin-doc.doc-date))
    chr(32) MonthNameRusGen(Month(buf_fin-doc.doc-date))
    chr(32) string(Year(buf_fin-doc.doc-date)) chr(32) "г."
    skip(1).
    if buf_fin-doc.contract-code <> 0 then do:
      Put Stream PrnLibStream unformatted
      fill(chr(32), 20) "по договору № " buf_contract.contract-prn-code
      "     от " string(day(buf_contract.contract-date))
      chr(32) MonthNameRusGen(Month(buf_contract.contract-date))
      chr(32) string(Year(buf_contract.contract-date)) chr(32) "г."
      skip(2).
    end.
    PUT  STREAM PrnLibStream unformatted
    fill(chr(32), 10) "ФИРМA:          " (if buf_fin-doc.fin-ext-doc-type = 'апп':U
                                                then buf_fin-doc.receiver-name
                                                else buf_fin-doc.payer-name)
    skip(2)
    fill(chr(32), 10) "КОНТРАГЕНТ:     " (if buf_fin-doc.fin-ext-doc-type = 'апп':U
                                                then buf_fin-doc.payer-name
                                                else buf_fin-doc.receiver-name)
    skip(3).
    FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME doc-list  .
    for each buf_temp-trn-doc :
      Display STREAM PrnLibStream
      buf_temp-trn-doc.in-code
      buf_temp-trn-doc.prn-doc-code
      buf_temp-trn-doc.sum-doc
      buf_temp-trn-doc.PS
      with FRAME doc-list .
      DOWN STREAM PrnLibStream 1
      with FRAME fin-doc-list  .
    end.
    assign
    acc = acc + buf_temp-trn-doc.sum-doc
    .
    UNDERLINE  STREAM PrnLibStream
    buf_temp-trn-doc.in-code
    buf_temp-trn-doc.prn-doc-code
    buf_temp-trn-doc.sum-doc
    buf_temp-trn-doc.PS
    with FRAME doc-list .
    PUT STREAM PrnLibStream UNFORMATTED
    "ИТОГО СУММА ПРОПИСЬЮ " v-dops skip(1) .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME doc-List.
  end.
  run waitfram-hide in this-procedure .
  if p-append and not p-is-last then Page stream PrnLibStream .
  output  STREAM PrnLibStream CLOSE.
  assign
  p-format = 0
  .
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
  if not p-append then
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
  end.
end.
