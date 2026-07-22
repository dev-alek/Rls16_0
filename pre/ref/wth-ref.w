DEFINE BUFFER X_wealth FOR ub.wealth.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as char no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input-output parameter p-rid-list as char no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник материальных ценностей ".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.
end.
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.
procedure wth-lib_full-inf-shift:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-inter:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-period-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo.                        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                        define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo.                        define input parameter parfact-date like ub.wth-line.fact-date no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.
if avail buf_currency then
  RETURN buf_currency.curr-abbr.
else return "".
END FUNCTION.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable filter-label as character no-undo init "Материальные_ценности" .
define variable filter-label0 as character no-undo init "Материальные_ценности" .
define variable filter-point as character no-undo init "wth-ref" .
define variable filter-point0 as character no-undo init "wth-ref" .
define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable choice as log no-undo.
define variable mark as char no-undo.
define variable print-option as char no-undo.
define variable varwth-obj as decimal no-undo.
define variable v-doc-rec as recid no-undo .
define variable ser-wth  as logical   no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable v-rid-list as character no-undo .
DEFINE MENU MENU-B-print
       MENU-ITEM m_par          LABEL "С номиналами"
       MENU-ITEM m_wealth       LABEL "Без номиналов" .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-par
     LABEL "&Номиналы"
     SIZE 10 BY 1.
DEFINE BUTTON B-pobj
     LABEL "&Остатки"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE E-PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.75 NO-UNDO.
DEFINE VARIABLE F-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип"
      VIEW-AS TEXT
     SIZE 3.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rsfl-par AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 3,
"Удаленные", 1
     SIZE 31.5 BY 1 NO-UNDO.
DEFINE VARIABLE rstp-par AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 3,
"Серийные", 1,
"Несерийные", 0
     SIZE 32 BY .75 NO-UNDO.
DEFINE QUERY BR-wth FOR
      X_wealth SCROLLING.
DEFINE BROWSE BR-wth
  QUERY BR-wth NO-LOCK DISPLAY
      mark-string(recid(X_wealth), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_wealth.wth-code FORMAT "999999999":U
      (if X_wealth.stts = 0
 then X_wealth.wth-name
 else substring (X_wealth.wth-name, 1, 15) + '---  УДАЛЕН  ---':U) COLUMN-LABEL "Название" FORMAT "X(49)":U
      X_wealth.is-money COLUMN-LABEL "Денежн.!эквив." FORMAT "+/":U
      X_wealth.curr-code COLUMN-LABEL "Код!вал" FORMAT ">>9":U
      get-curr(buffer X_wealth) COLUMN-LABEL "Валюта/!Ед.изм."
      wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code) COLUMN-LABEL "На объекте" FORMAT "->>>,>>>,>>9.99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.25.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 13
     B-sel AT ROW 1 COL 16
     B-add AT ROW 1 COL 26
     B-chg AT ROW 1 COL 36
     b-lkp AT ROW 1 COL 46
     B-del AT ROW 1 COL 56
     B-pobj AT ROW 1 COL 66
     B-par AT ROW 1 COL 76
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     rsfl-par AT ROW 2.25 COL 10 NO-LABEL WIDGET-ID 2
     rstp-par AT ROW 3.25 COL 10 NO-LABEL WIDGET-ID 14
     BR-wth AT ROW 4.25 COL 1
     E-PS AT ROW 21 COL 1 NO-LABEL
     mark-num AT ROW 1 COL 11 NO-LABEL
     F-type AT ROW 3.25 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     "Статус" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2.42 COL 2 WIDGET-ID 12
          FGCOLOR 4
     SPACE(90.39) SKIP(20.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник материальных ценностей".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ASSIGN
       E-PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       rstp-par:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN save-position IN THIS-PROCEDURE NO-ERROR.
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wealth_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then return no-apply.
run ref/wth-form.w (
                 input parparentproc
               , input 0
               , input 'ДОБАВЛЕНИЕ':U
               , output rep-rec).
if rep-rec <> ? then do:
   v-doc-rec = rep-rec.
   RUn OpenBr in this-procedure  ( input yes, input no, input '':U).
  apply "entry" to br-wth in frame Dialog-Frame.
end.
else do:
  apply "entry" to br-wth in frame Dialog-Frame.
  return no-apply.
end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable rep-rec as recid no-undo .
define variable glog as logical no-undo .
  if not available X_wealth then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
if X_wealth.stts = 1 then do:
  message substitute("Изменение записи со статусом &1 невозможно!",'---  УДАЛЕН  ---':U).
  return no-apply.
end.
rep-rec = recid (X_wealth).
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wealth_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then return no-apply.
run ref/wth-form.w (
                 input parparentproc
               , input X_wealth.wth-code
               , input 'ИЗМЕНЕНИЕ':U
               , output rep-rec).
if rep-rec <> ? then do:
   RUn OpenBr in this-procedure  ( input yes, input no, input '':U).
   apply "entry" to br-wth in frame Dialog-Frame.
end.
else do:
  apply "entry" to br-wth in frame Dialog-Frame.
  return no-apply.
end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable del-rec as recid no-undo.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define buffer buf_wealth for ub.wealth.
if not available X_wealth then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wealth_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then return no-apply.
rep-rec = recid ( X_wealth).
glog = no.
FIND FIRST buf_wealth WHERE recid (buf_wealth) = rep-rec.
if buf_wealth.stts <> 0 then do:
    glog = no.
    message
    "МЦ" buf_wealth.wth-code buf_wealth.wth-name "уже удалена." skip
    "Восстановить ?"
    view-as alert-box question buttons Yes-No update glog.
    if not glog then do:
      apply "entry" to br-wth in frame Dialog-Frame.
      return no-apply.
    end.
    assign
    buf_wealth.stts = 0
    .
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    apply "entry" to br-wth in frame Dialog-Frame.
end.
else do:
      glog = no.
      message
      "Удалить МЦ :" skip
      buf_wealth.wth-code buf_wealth.wth-name skip
     "Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        apply "entry" to br-wth in frame Dialog-Frame.
        return no-apply.
      end.
      if wth-lib_cur-stock-host-func(p-curr-host-code,buf_wealth.wth-code ) <> 0 then do:
        message 'Удаление невозможно!' skip
       'МЦ имеется на остатках по фирме.' skip
       'Количество по фирме: ' wth-lib_cur-stock-host-func(p-curr-host-code,buf_wealth.wth-code )
       view-as alert-box error.
       apply "entry" to br-wth in frame Dialog-Frame.
       return no-apply.
      end.
      assign
      buf_wealth.stts = 1
      .
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    apply "entry" to br-wth in frame Dialog-Frame.
 end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_wealth THEN RETURN NO-APPLY.
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input        parparentproc
                 , input        p-curr-host-code
                 , input        p-curr-obj-type
                 , input        p-curr-obj-code
                 , input        "":U
                 , input        "one":U
                 , input        X_wealth.wth-code
                 , INPUT        0
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        "":U
                 , input        "":U
                 , input         v-cntxt-db-num
                 , input        ?
                 , input        ?
                 , input-output v-rid-list
                 ) no-error .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
    define variable rep-rec as recid no-undo .
    if not available X_wealth then do:
      message "Неправильно выбрана строка.".
      return no-apply.
    end.
    rep-rec = recid (X_wealth).
    run ref/wth-form.w (
                     input parparentproc
                   , input X_wealth.wth-code
                   , input 'ПРОСМОТР':U
                   , output rep-rec) NO-ERROR.
     apply "entry" to br-wth in frame Dialog-Frame.
     return no-apply.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
 define variable glog as logical no-undo .
  if available X_wealth then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid17 as character no-undo .
define variable v-num-entry17 as integer   no-undo .
assign
  v-str-recid17 = trim( string( recid( X_wealth ) , "->>>>>>>>>>>9":U ) )
  v-num-entry17 = lookup( v-str-recid17 , v-rid-list )
.
if v-num-entry17 > 0 then do:
  assign
    entry( v-num-entry17, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid17
  .
end.
    br-wth:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-wth:select-next-row ().
            apply "iteration-changed" to br-wth in frame Dialog-Frame.
        end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-wth in frame Dialog-Frame.
END.
ON CHOOSE OF B-par IN FRAME Dialog-Frame
DO:
  if not avail X_wealth then return no-apply.
  define variable v-rid-list as character no-undo .
  run ref/wthp-ref.w (
                  input parparentproc
                 ,input (if lookup("b-add", bttns) > 0 then "b-add" else "")
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input 'МЦ':U
                 ,input X_wealth.wth-code
                 ,input-output v-rid-list).
END.
ON CHOOSE OF B-pobj IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
  if avail X_wealth then do:
    run ref/wthpobjr.w (
                    input parparentproc
                   ,input ('МЦ':U + chr(47) + 'объект':U)
                   ,input X_wealth.wth-code
                   ,input ?
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output v-rid-list
                   ) .
  end.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable doc-rec as recid no-undo .
  if print-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
  end.
    doc-rec = recid( X_wealth ).
    DO WHILE available X_wealth :
          GET prev br-wth.
    END.
    CASE print-option:
      when "wealth":U then do:
          run PrintProc.
      end.
      when "wth-par":U then do:
          run PrintProcPar.
      end.
    END CASE.
    print-option = "".
    reposition br-wth to recid doc-rec no-error.
    apply "entry" to br-wth in frame Dialog-Frame.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  assign
  tbl = 'wealth'
  join-tbl = 'X_wealth'
  fld = '':U
  spr = '':U
  lab = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('wth-name', 'Название', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', '', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-money', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        ,input filter-point
                        ,input tbl
                        ,input join-tbl
                        ,input fld
                        ,input lab
                        ,input spr
                        ,input dim).
      RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
  END .
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_wealth
        AND (v-rid-list = ""
            or
            b-mark:sensitive = no)
        ) then
        v-rid-list = string( recid( X_wealth ) ) .
END.
ON MOUSE-SELECT-DBLCLICK OF BR-wth IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.
ON RETURN OF BR-wth IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.
ON VALUE-CHANGED OF BR-wth IN FRAME Dialog-Frame
DO:
  if avail X_wealth then do:
    E-PS:screen-value = X_wealth.PS  .
    b-del:label = if X_wealth.stts = 1 then 'Восстанов' else 'Удалить'.
  end.
  else
  E-PS:screen-value = "".
END.
ON CHOOSE OF MENU-ITEM m_par
DO:
      print-option = "wth-par":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_wealth
DO:
        print-option = "wealth":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF rsfl-par IN FRAME Dialog-Frame
DO:
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
END.
ON VALUE-CHANGED OF rstp-par IN FRAME Dialog-Frame
DO:
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-wth :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-wth :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = ?. if available X_wealth then assign v-doc-rec = recid(X_wealth). run openbr in this-procedure  ( input yes, input no, input '':U).                reposition br-wth to recid v-doc-rec no-error. APPLY 'ENTRY' to br-wth. APPLY 'VALUe-CHANGED' to br-wth.
    apply "VALUE-CHANGED" to BR-wth.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ser-wth'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
  IF not error-status:error then
  assign
  ser-wth = (conf-par = "yes":U).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-rid-list = p-rid-list.
  RUN Myenable.
  if v-rid-list <> "":u then do:
    assign
    v-doc-rec = integer(v-rid-list)
    no-error .
  end.
  APPLY "ENTRY" to br-wth.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rsfl-par rstp-par E-PS mark-num F-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-chg b-lkp B-del B-pobj B-par B-print
         B-hist B-sch B-Help BR-wth E-PS mark-num F-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE load-position :
define variable v-current-stts-string       as character    no-undo.
define variable v-current-type-string       as character    no-undo.
define variable v-void-logical              as logical      no-undo.
define variable v-void-character            as character    no-undo.
define variable v-found                     as logical      no-undo.
do   with frame Dialog-Frame
on error undo, return error
:
    run uf-get (
          input 'wthref-stts':U
        , input v-cntxt-userid
        , output v-current-stts-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error then rsfl-par:screen-value =  v-current-stts-string.
        run uf-get (
              input 'wthref-type':U
            , input v-cntxt-userid
            , output v-current-type-string
            , output v-void-character
            , output v-void-logical
            , output v-void-logical
            , output v-void-logical
            , output v-void-logical
    ) no-error.
    if not error-status :error then  rstp-par:screen-value = v-current-type-string  .
 end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable glog as logical no-undo .
DISPLAY E-PS mark-num
WITH FRAME Dialog-Frame.
ENABLE
br-wth
b-quit
b-mark WHEN LOOKUP("b-mark":U, bttns) > 0
b-sel  WHEN LOOKUP("b-sel":U, bttns) > 0
b-pobj
b-print
b-sch
b-lkp
b-help
b-add WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-del WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-chg WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-par
b-hist
rsfl-par
rstp-par
f-type
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if not ser-wth then hide   rstp-par f-type
IN FRAME Dialog-Frame.
else f-type:screen-value = 'Тип'.
if not p-mode = 'все':U then
disable
 rstp-par
WITH FRAME Dialog-Frame.
run load-position in this-procedure.
if p-mode = 'wth-ser':U then rstp-par:screen-value = '1'.
else if p-mode = 'wth-nser':U then rstp-par:screen-value = '0'.
apply 'value-changed':U to rstp-par.
if available X_wealth then
glog = br-wth:select-focused-row( ).
ASSIGN b-print:MENU-MOUSE = 1.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
ASSIGN FRAME Dialog-Frame rsfl-par.
ASSIGN FRAME Dialog-Frame rstp-par.
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
CASE p-mode:
    when 'все':U then do:
        ASSIGN frame Dialog-Frame:TITLE = "Материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH X_wealth"
      parameter-4-33 =
        (
          if (" (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par) and (if rstp-par = 3 then true else x_wealth.is-ser = rstp-par) " + " " + where-phrase-33) <> ""
          then  substitute('(if &1 = 3 then true else x_wealth.stts = &1) and (if &2 = 3 then true else x_wealth.is-ser = &2) '                                ,rsfl-par, rstp-par ) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par) and (if rstp-par = 3 then true else x_wealth.is-ser = rstp-par) " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-wth:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-33 = false then do:
    OPEN QUERY br-wth FOR EACH X_wealth
      where  (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par) and (if rstp-par = 3 then true else x_wealth.is-ser = rstp-par)
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'wth-ser':U then do:
        ASSIGN frame Dialog-Frame:TITLE = "Серийные материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH X_wealth"
      parameter-4-35 =
        (
          if (" X_wealth.is-ser = 1 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  " + " " + where-phrase-35) <> ""
          then  substitute('X_wealth.is-ser = 1 and (if &1 = 3 then true else x_wealth.stts = &1)  ', rsfl-par) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_wealth.wth-code  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" X_wealth.is-ser = 1 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-wth:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-35 = false then do:
    OPEN QUERY br-wth FOR EACH X_wealth
      where  X_wealth.is-ser = 1 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)
       by X_wealth.wth-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'wth-nser':U then do:
        ASSIGN frame Dialog-Frame:TITLE = "Несерийные материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH X_wealth"
      parameter-4-37 =
        (
          if (" X_wealth.is-ser = 0 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  " + " " + where-phrase-37) <> ""
          then  substitute('X_wealth.is-ser = 0 and (if &1 = 3 then true else x_wealth.stts = &1)  ', rsfl-par) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_wealth.wth-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" X_wealth.is-ser = 0 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-wth:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-37 = false then do:
    OPEN QUERY br-wth FOR EACH X_wealth
      where  X_wealth.is-ser = 0 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)
       by X_wealth.wth-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
END CASE.
if v-doc-rec <> ? then reposition br-wth to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wth:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  reposition br-wth to row 1 no-error.
end.
apply "entry" to br-wth in frame Dialog-Frame.
if avail X_wealth then
APPLY "VALUE-CHANGED":U to br-wth.
END PROCEDURE.
PROCEDURE PrintProc :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable var-on-obj as decimal no-undo.
DEFINE FRAME Wth-List
X_wealth.wth-code     column-label "Код"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив."
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
var-on-obj          column-label "Остаток!на объекте" format "->>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width 160 down stream-io use-text    .
Line = fill("-", 70).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dialog-Frame:title )
    format "x(90)" SKIP(1) .
    FORM HEADER
    Line AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME Wth-List  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-wth.
     DO WHILE available X_wealth :
        var-on-obj = wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code).
        Display STREAM PrnLibStream
        X_wealth.wth-code
        X_wealth.wth-name
        X_wealth.is-money
        X_wealth.curr-code
        X_wealth.unit-base
        var-on-obj
        with FRAME Wth-List .
        DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
        GET next br-wth.
      END.
      UNDERLINE  STREAM PrnLibStream
        X_wealth.wth-code
        X_wealth.wth-name
        X_wealth.is-money
        X_wealth.curr-code
        X_wealth.unit-base
        var-on-obj
        with FRAME Wth-List .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE PrintProcpar :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable var-on-obj as decimal no-undo.
define buffer buf_wth-par for ub.wth-par.
DEFINE FRAME Wth-List
X_wealth.wth-code     column-label "Код"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив."
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
var-on-obj          column-label "Остаток!на объекте" format "->>>,>>>,>>9.99"
buf_wth-par.par-code     column-label "Код!номинала"
buf_wth-par.par-val     column-label "Номинал"
buf_wth-par.par-unit     column-label "Ед.изм.!номинала"
buf_wth-par.par-rate     column-label "Коэфф."
buf_wth-par.par-feat     column-label "Доп. признак"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width 160 down stream-io use-text    .
Line = fill("-", 122).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-wth.
DO WHILE available X_wealth :
  var-on-obj = wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code).
  Display STREAM PrnLibStream
  X_wealth.wth-code
  X_wealth.wth-name
  X_wealth.is-money
  X_wealth.curr-code
  X_wealth.unit-base
  var-on-obj
  with FRAME Wth-List .
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  FOR EACH buf_wth-par No-LOCK WHERE
            buf_wth-par.wth-code = X_wealth.wth-code:
      Display STREAM PrnLibStream
      buf_wth-par.par-code
      buf_wth-par.par-val
      buf_wth-par.par-unit
      buf_wth-par.par-rate
      buf_wth-par.par-feat
      with FRAME Wth-List .
      DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  END.
  UNDERLINE  STREAM PrnLibStream
  X_wealth.wth-code
  X_wealth.wth-name
  X_wealth.is-money
  X_wealth.curr-code
  X_wealth.unit-base
  var-on-obj
  buf_wth-par.par-code
  buf_wth-par.par-val
  buf_wth-par.par-unit
  buf_wth-par.par-rate
  buf_wth-par.par-feat
  with FRAME Wth-List .
  GET next br-wth.
END.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE save-position :
do
with frame Dialog-Frame
on error undo, return error
:
assign rsfl-par rstp-par.
        run uf-set (
              input 'wthref-stts':U
            , input v-cntxt-userid
            , input string( rsfl-par )
            , input 'wthref-stts':U
            , input no
            , input no
            , input no
            , input no
        ) no-error .
        run uf-set (
              input 'wthref-type':U
            , input v-cntxt-userid
            , input string( rstp-par )
            , input 'wthref-type':U
            , input no
            , input no
            , input no
            , input no
        ) no-error.
end.
END PROCEDURE.
