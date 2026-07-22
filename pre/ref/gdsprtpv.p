block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-node-code like ub.gds-prt.node-code no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gdsprtpv.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/gdsprtpv.p $":U .
def var vss-description as character no-undo init "Печать шкалы".
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
DEFINE VARIABLE line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-found as logical no-undo .
define variable v-node-code like ub.gds-prt.node-code no-undo.
define variable v-lvl-num like ub.gds-prt.lvl-num no-undo.
DEFINE VARIABLE lvl as character no-undo extent 10.
DEFINE VARIABLE lvl-name as character no-undo extent 10.
DEFINE VARIABLE v-current-page as integer no-undo .
DEFINE VARIABLE v-first-page as logical no-undo init yes.
define buffer buf_gds-prt for ub.gds-prt .
define buffer upper_gds-prt for ub.gds-prt .
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
define temp-table tt-level no-undo
FIELD level like ub.lvl-name.level
FIELD lvl-name like ub.lvl-name.lvl-name
index pi is primary unique
level
.
define temp-table tt-prt no-undo
FIELD node-code like ub.gds-prt.node-code
FIELD node-name like ub.gds-prt.node-name
FIELD level like ub.lvl-name.level
FIELD line-num as integer
index pi is PRIMARY UNIQUE
level
node-code
index line is unique
line-num level
.
DEFINE FRAME PRT-FRAME
lvl[1]  column-label "Уровень 1" FORMAT "x(18)"       space(1)
lvl[2]  column-label "Уровень 2" FORMAT "x(18)"       space(1)
lvl[3]  column-label "Уровень 3" FORMAT "x(18)"       space(1)
lvl[4]  column-label "Уровень 4" FORMAT "x(18)"       space(1)
lvl[5]  column-label "Уровень 5" FORMAT "x(18)"       space(1)
lvl[6]  column-label "Уровень 6" FORMAT "x(18)"       space(1)
lvl[7]  column-label "Уровень 7" FORMAT "x(18)"       space(1)
lvl[8]  column-label "Уровень 8" FORMAT "x(18)"       space(1)
lvl[9]  column-label "Уровень 9" FORMAT "x(18)"       space(1)
lvl[10]  column-label "Уровень 10" FORMAT "x(18)"       space(1)
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text NO-BOX.
find first buf_gds-prt no-lock where
           buf_gds-prt.node-code = p-node-code no-error.
if not available buf_gds-prt then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найден узел шкалы" skip
  "node-code" p-node-code
  view-as alert-box error .
  return error.
end.
if can-find(first upper_gds-prt no-lock where
                  upper_gds-prt.node-code = buf_gds-prt.upper-code) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Узел шкалы не корневой"
  "node-code" p-node-code "upper-code" buf_gds-prt.upper-code
  view-as alert-box error .
  return error.
end.
do
on error undo, return error
:
  for each tt-level:
    delete tt-level.
  end.
  for each tt-prt:
    delete tt-prt.
  END.
  assign
  v-node-code = buf_gds-prt.node-code
  v-lvl-num = 1
  v-found = yes
  .
  do while v-found = yes:
    assign
    v-found = yes
    .
    run create-level in this-procedure (
                                         input-output v-node-code
                                        ,input buf_gds-prt.upper-code
                                        ,input-output v-lvl-num
                                        ,output v-found
                                                        ) no-error.
    if error-status:error then  LEAVE.
  END.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
  Line = fill("-", 198).
  date_string = cur-time-print() .
  FOR EACH tt-level no-lock:
    assign
    lvl-name[tt-level.level + 1] = substr(tt-level.lvl-name, 1, 18)
    .
  END.
  FORM HEADER
  Line format "X(198)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  FORM with FRAME PRT-FRAME.
  FOR EACH tt-prt No-LOCK
  BREAK
  by tt-prt.line-num
  by tt-prt.level:
    if first-of(tt-prt.line-num) then do:
      assign
      lvl[1] = "":U
      lvl[2] = "":U
      lvl[3] = "":U
      lvl[4] = "":U
      lvl[5] = "":U
      lvl[6] = "":U
      lvl[7] = "":U
      lvl[8] = "":U
      lvl[9] = "":U
      lvl[10] = "":U
      .
      DOWN stream PrnLibStream
      with FRAME PRT-FRAME.
    end.
    assign
    lvl[tt-prt.level + 1] = tt-prt.node-name
    .
    if LAST-of(tt-prt.line-num) then do:
      if v-first-page = yes then do:
        PUT STREAM PrnLibStream UNFORMATTED
        "Шкала:" chr(32) buf_gds-prt.node-name
        skip.
        PUT stream PrnLibStream unformatted
        skip(2).
        DISPLAY STREAM PrnLibStream
        lvl-name[1] @   lvl[1]
        lvl-name[2] @   lvl[2]
        lvl-name[3] @   lvl[3]
        lvl-name[4] @   lvl[4]
        lvl-name[5] @   lvl[5]
        lvl-name[6] @   lvl[6]
        lvl-name[7] @   lvl[7]
        lvl-name[8] @   lvl[8]
        lvl-name[9]  @  lvl[9]
        lvl-name[10] @  lvl[10]
        with frame prt-frame.
        assign
        v-first-page = no
        v-current-page = page-number(PrnLibStream)
        .
        DOWN stream PrnLibStream
        with frame prt-frame.
        underline stream PrnLibStream
        lvl[1]
        lvl[2]
        lvl[3]
        lvl[4]
        lvl[5]
        lvl[6]
        lvl[7]
        lvl[8]
        lvl[9]
        lvl[10]
        with frame prt-frame.
        DOWN stream PrnLibStream
        with frame prt-frame.
      end.
      display stream PrnLibStream
      lvl[1]
      lvl[2]
      lvl[3]
      lvl[4]
      lvl[5]
      lvl[6]
      lvl[7]
      lvl[8]
      lvl[9]
      lvl[10]
      with frame prt-frame.
    END.
  END.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  output  STREAM PrnLibStream CLOSE.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
procedure create-level :
define input-output parameter p-node-code like ub.gds-prt.node-code no-undo.
define input parameter p-upper-code like ub.gds-prt.upper-code no-undo .
define input-output  parameter p-lvl-num like ub.gds-prt.lvl-num no-undo.
DEFINE output parameter p-found as logical no-undo.
DEFINE VARIABLE v-line-num as integer no-undo .
define buffer bf_gds-prt for ub.gds-prt.
define buffer bf_lvl-name for ub.lvl-name.
  do
  on error undo, return error
  :
  if can-find(first bf_gds-prt no-lock where
                      bf_gds-prt.upper-code = p-node-code) then do:
      find first bf_lvl-name no-lock where
                 bf_lvl-name.level = p-lvl-num - 1 and
                 bf_lvl-name.upper-code = p-upper-code no-error .
      find first tt-level where
                 tt-level.level = p-lvl-num - 1  no-error .
      if not available tt-level then do:
        create tt-level.
        assign
        tt-level.level = p-lvl-num - 1
        tt-level.lvl-name = if available bf_lvl-name then bf_lvl-name.lvl-name else "":U
        .
      end.
      for each bf_gds-prt no-lock where
                  bf_gds-prt.upper-code = p-node-code:
        assign
        v-line-num = v-line-num + 1
        .
        find first tt-prt where
                   tt-prt.node-code = bf_gds-prt.node-code no-error .
        if not available tt-prt then do:
          create tt-prt.
          assign
          tt-prt.node-code = bf_gds-prt.node-code
          tt-prt.level = p-lvl-num - 1
          .
        end.
        assign
        tt-prt.node-name = substr(bf_gds-prt.node-name, 1, 10)
        tt-prt.line-num = v-line-num
        .
      end.
      assign
      p-lvl-num = p-lvl-num + 1
      .
      find first bf_gds-prt no-lock where
                  bf_gds-prt.upper-code = p-node-code.
        assign
        p-node-code = bf_gds-prt.node-code
        p-found = yes
        .
  end.
  else do:
      assign
      p-found = no
      .
  end.
    end.
end procedure.
