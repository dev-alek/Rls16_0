block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-wth-doc-recid as recid.
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-w-inv.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-w-inv.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "печать документа инвентаризации материальных ценностей":U.
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable sym1 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym2 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym3 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym4 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym5 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable sym6 AS CHAR FORM "x(1)":U COLUMN-LABEL ":!:" INIT ":":U NO-UNDO.
define variable Line        AS CHAR NO-UNDO.
define variable v_wth-name  AS CHAR NO-UNDO FORM "x(40)":U.
define variable v_wth-place AS CHAR NO-UNDO FORM "x(20)":U.
define buffer buf_wth-doc   FOR ub.wth-doc.
define buffer buf-cmp FOR ub.clients.
define buffer buf-obj FOR ub.clients.
define buffer buf-pn1 FOR ub.clients.
define buffer buf-pn2 FOR ub.clients.
define buffer buf-pn3 FOR ub.clients.
define buffer buf-pn4 FOR ub.clients.
define buffer buf-pn5 FOR ub.clients.
DEF FRAME frm-print-w-inv-0
sym1 No-LABEL
v_wth-name           NO-LABEL FORM "x(40)":U
sym2 No-LABEL
v_wth-place          NO-LABEL FORM "x(20)":U
sym3 No-LABEL
ub.wth-line.bef-sum  NO-LABEL FORM "->>,>>>,>>9.99":U
sym4 No-LABEL
ub.wth-line.aft-sum  NO-LABEL FORM "->>,>>>,>>9.99":U
sym5 No-LABEL
ub.wth-line.fact-sum NO-LABEL FORM "->>>,>>>,>>9.99":U
sym6 No-LABEL
HEADER
SPACE( 7 ) "Страница:" PAGE-NUMBER(PrnLibStream) FORM ">>9":U SKIP
"-----------------------------------------------------------------------------------------------------------------------" SKIP
":                                          :                      :      Сумма     :      Сумма     :   Расхождение   :" SKIP
":               Наименование               :    Место хранения    :      План      :      Факт      :   План - Факт   :" SKIP
"-----------------------------------------------------------------------------------------------------------------------"
WITH WIDTH 136 DOWN stream-IO  NO-BOX NO-Underline No-LABELS.
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block
   ON STOP    UNDO Main-Block, LEAVE Main-Block :
  FIND FIRST buf_wth-doc where
            recid(buf_wth-doc) = p-wth-doc-recid No-ERROR.
  IF NOT AVAIL buf_wth-doc THEN DO:
    MESSAGE "Документ инвентаризации МЦ не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  ELSE DO:
    ASSIGN Line = FILL( "-":U, 136 ).
  END.
  FIND buf-cmp NO-LOCK WHERE
      buf-cmp.obj-type = 'орг':U          AND
      buf-cmp.obj-code = buf_wth-doc.host-code NO-ERROR.
  FIND buf-obj NO-LOCK WHERE
      buf-obj.obj-type = buf_wth-doc.obj-type AND
      buf-obj.obj-code = buf_wth-doc.obj-code NO-ERROR.
  FIND FIRST buf-pn1 NO-LOCK WHERE
      buf-pn1.obj-type = 'чел':U         AND
      buf-pn1.obj-code = buf_wth-doc.operator NO-ERROR.
  FIND buf-pn2 NO-LOCK WHERE
      buf-pn2.obj-type = 'чел':U         AND
      buf-pn2.obj-code = buf_wth-doc.deliver  NO-ERROR.
  FIND buf-pn3 NO-LOCK WHERE
      buf-pn3.obj-type = 'чел':U         AND
      buf-pn3.obj-code = buf_wth-doc.receiver NO-ERROR.
  FIND buf-pn4 NO-LOCK WHERE
      buf-pn4.obj-type = 'чел':U         AND
      buf-pn4.obj-code = buf_wth-doc.inv-prs4 NO-ERROR.
  FIND buf-pn5 NO-LOCK WHERE
      buf-pn5.obj-type = 'чел':U         AND
      buf-pn5.obj-code = buf_wth-doc.inv-prs5 NO-ERROR.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 62
                                              ,input yes
                                              ,input no
                                              ).
  PUT stream PrnLibStream UNFORMATTED
  buf-cmp.obj-name                           AT  6 SKIP
  buf-obj.obj-name                           AT  6 SKIP(1)
  "ИНВЕНТАРИЗАЦИОННАЯ ВЕДОМОСТЬ"             AT 30 SKIP
  "ДВИЖЕНИЕ МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ НА АЗК"   AT 20 SKIP
  "Смена:"                                   AT 43
  STRING( buf_wth-doc.shift-name, "X(2)":U ) " от "
  STRING( buf_wth-doc.shift-date, "99-99-9999":U ) SKIP(0)
  cur-time-print() at 57 format "X(35)" SKIP
  .
  FORM HEADER
  Line format "X(118)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width 136 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  stream PrnLibStream FRAME BottomFrame .
  FORM with FRAME frm-print-w-inv-0  .
  FOR EACH ub.wth-line NO-LOCK WHERE
           ub.wth-line.doc-code = buf_wth-doc.doc-code :
    FIND ub.wealth     NO-LOCK WHERE
         ub.wealth.wth-code   = ub.wth-line.wth-code NO-ERROR.
    FIND ub.wth-place  NO-LOCK WHERE
      ub.wth-place.host-code = buf_wth-doc.host-code      AND
      ub.wth-place.obj-type  = buf_wth-doc.obj-type       AND
      ub.wth-place.obj-code  = buf_wth-doc.obj-code       AND
      ub.wth-place.w-p-code  = ub.wth-line.w-p-code NO-ERROR.
    ASSIGN
    v_wth-name  = ( IF AVAIL ub.wealth    THEN ub.wealth.wth-name    ELSE "":U )
    v_wth-place = ( IF AVAIL ub.wth-place THEN ub.wth-place.w-p-name ELSE "":U )
    .
    ACCUMULATE
    ub.wth-line.bef-sum ( TOTAL )
    ub.wth-line.aft-sum ( TOTAL )
    ub.wth-line.fact-sum ( TOTAL )
    .
    DISP  stream PrnLibStream
    sym1 v_wth-name
    sym2 v_wth-place
    sym3 ub.wth-line.bef-sum
    sym4 ub.wth-line.aft-sum
    sym5 ub.wth-line.fact-sum
    Sym6
    WITH FRAME frm-print-w-inv-0.
    DOWN  stream PrnLibStream
    WITH FRAME frm-print-w-inv-0.
  END.
  UNDERLINE stream PrnLibStream
  sym1 v_wth-name
  sym2 v_wth-place
  sym3 ub.wth-line.bef-sum
  sym4 ub.wth-line.aft-sum
  sym5 ub.wth-line.fact-sum
  Sym6
  WITH FRAME frm-print-w-inv-0.
  DOWN  stream PrnLibStream
  WITH FRAME frm-print-w-inv-0.
  DISP  stream PrnLibStream
  sym1
  sym2
  sym3 (ACCUM TOTAL ub.wth-line.bef-sum ) @ ub.wth-line.bef-sum
  sym4 (ACCUM TOTAL ub.wth-line.aft-sum ) @ ub.wth-line.aft-sum
  sym5 (ACCUM TOTAL ub.wth-line.fact-sum) @ ub.wth-line.fact-sum
  Sym6
  WITH FRAME frm-print-w-inv-0.
  DOWN  stream PrnLibStream
  WITH FRAME frm-print-w-inv-0.
  UNDERLINE stream PrnLibStream
  sym1 v_wth-name
  sym2 v_wth-place
  sym3 ub.wth-line.bef-sum
  sym4 ub.wth-line.aft-sum
  sym5 ub.wth-line.fact-sum
  Sym6
  WITH FRAME frm-print-w-inv-0.
  DOWN  stream PrnLibStream
  WITH FRAME frm-print-w-inv-0.
  PUT  stream PrnLibStream UNFORMATTED
  SKIP( 2 ) "Члены Инвентаризационной комиссии"
  SKIP( 1 )
  SUBSTR( (if avail buf-pn1 then buf-pn1.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn2 then buf-pn2.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn3 then buf-pn3.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn4 then buf-pn4.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP( 1 )
  SUBSTR( (if avail buf-pn5 then buf-pn5.obj-name else '':U)  + FILL( "_", 60 ), 1, 60 ) + " подпись " + FILL( "_", 40 )
  SKIP
  .
  HIDE  stream PrnLibStream FRAME BottomFrame .
  HIDE  stream PrnLibStream FRAME frm-print-w-inv-0.
  OUTPUT  stream PrnLibStream CLOSE.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
END.
