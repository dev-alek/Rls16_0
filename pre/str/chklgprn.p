block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.
define input parameter p-print-option as character no-undo .
define output parameter p-frame-width as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklgprn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklgprn.p $":U .
define variable vss-description as character no-undo init "Печать списка товаров чеков из механизма списка чеков в формате Excel".
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
DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-chk-type-gds as character no-undo .
DEFINE VARIABLE FOR-doc-code-gds like ub.chk-doc.doc-code NO-UNDO.
DEFINE VARIABLE FOR-OBJ-type-gds like ub.chk-doc.obj-type NO-UNDO.
DEFINE VARIABLE FOR-OBJ-code-gds like ub.chk-doc.obj-code NO-UNDO.
define variable for-chk-date-gds as character no-undo .
define variable for-chk-time-gds as character no-undo .
define variable for-chk-num like ub.chk-doc.chk-num no-undo .
define variable for-pay-desk like ub.chk-doc.pay-desk no-undo .
define variable for-cashier like ub.chk-doc.cashier no-undo .
define variable for-d-card like ub.chk-doc.d-card no-undo .
define variable for-out-code like ub.chk-doc.out-code no-undo .
define variable for-doc-num like ub.chk-doc.doc-num no-undo .
define variable for-netto as decimal no-undo .
define variable for-discnt as decimal no-undo .
define variable for-tot-doc as decimal no-undo .
define variable for-line-num as integer no-undo .
define variable for-b-code as integer no-undo .
define variable for-artic as character no-undo .
define variable for-gds-name as character no-undo .
define variable for-prt-name as character no-undo .
define variable for-err-gds as logical no-undo .
define variable for-src-code as character no-undo .
define variable for-pump as integer no-undo .
define variable for-prod-name as character no-undo .
define variable for-doc-qnty as decimal no-undo .
define variable for-unit-cli as character no-undo .
define variable for-price-base as decimal no-undo .
define variable for-gds-discnt as decimal no-undo .
define variable for-discnt-pcnt as decimal no-undo .
define variable for-price-netto as decimal no-undo .
define variable for-write-off as logical no-undo .
DEFINE VARIABLE fill2 as character no-undo.
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill4 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill6 as character no-undo.
DEFINE VARIABLE fill7 as character no-undo.
DEFINE VARIABLE fill8 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill10 as character no-undo.
DEFINE VARIABLE fill11 as character no-undo.
DEFINE VARIABLE fill13 as character no-undo.
DEFINE VARIABLE fill14 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill20 as character no-undo.
DEFINE VARIABLE fill27 as character no-undo.
DEFINE VARIABLE fill40 as character no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE ii as integer no-undo.
define variable g#report-num as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_gds-prt for ub.gds-prt.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
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
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
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
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table chk-list no-undo
field doc-code   like ub.chk-doc.doc-code
field obj-type   like ub.chk-doc.obj-type
field obj-code   like ub.chk-doc.obj-code
field out-code   like ub.chk-doc.out-code
field chk-date   like ub.chk-doc.chk-date
field chk-time   like ub.chk-doc.chk-time
field shift-date like ub.chk-doc.shift-date
field shift-num  like ub.chk-doc.shift-num
field shift-name  like ub.chk-doc.shift-name
field src-shift-date like ub.chk-doc.src-shift-date
field chk-num    like ub.chk-doc.chk-num
field pay-desk   like ub.chk-doc.pay-desk
field cashier    like ub.chk-doc.cashier
field cashier-psn-code    like ub.chk-doc.cashier-psn-code
field chk-type   like ub.chk-doc.chk-type
field d-card     like ub.chk-doc.d-card
field netto      like ub.chk-doc.netto
field discnt     like ub.chk-doc.discnt
field tot-doc    like ub.chk-doc.tot-doc
field is-wth     as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
field doc-num    as character label "№ док-та" format "X(22)"
field doc-num2   as character label "№ заказа" format "X(22)"
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared   temp-table chk-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
define variable v-dec-sep          as character no-undo init ? .
define variable v-th-sep           as character no-undo init ? .
define variable v-r-col-num        as integer no-undo .
define variable v-reg-replace      as logical no-undo .
define variable v-date-col-format  as character no-undo .
DEFINE VARIABLE last-col-num as integer no-undo.
run gbl/getlocal.p (
                  output v-dec-sep
                 ,output v-th-sep
                 ,output v-sdate
                 ,output v-shortdate
                 ) no-error .
assign
v-reg-replace = NOT (v-dec-sep = ".":U and v-th-sep = chr(44))
                AND (v-dec-sep <> ? and v-th-sep <> ?)
.
  FUNCTION supress-null RETURNS CHARACTER ( INPUT p-string  AS CHARACTER,
                                            INPUT p-dec-sep AS CHARACTER  ) :
    DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.
    IF TRIM( p-string ) = "0"                    OR
       TRIM( p-string ) = "0" + p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "0"  OR
       TRIM( p-string ) = "0" + p-dec-sep + "0"  THEN DO: ASSIGN v-string = "":U.     END.
                                                 ELSE DO: ASSIGN v-string = p-string. END.
    RETURN ( TRIM( v-string ) ).
  END FUNCTION.
FUNCTION reg-output returns character( input p-string as character
                                      ,input p-private-data as character
                                      ,input p-replace as logical
                                      ,input p-supress as logical
                                      ,input p-dec-sep as character
                                      ,input p-th-sep as character
                                      ):
DEFINE VARIABLE v-reg-output as character no-undo .
DEFINE VARIABLE v-data-type as character no-undo .
DEFINE VARIABLE v-progress-format as character no-undo .
assign
v-progress-format = entry(1, p-private-data, chr(4))
v-data-type = entry(2, p-private-data, chr(4))
.
if p-string = ? then return chr(63).
if (v-data-type = "INTEGER"
    OR v-data-type = "DECIMAL" ) THEN DO:
  IF p-replace THEN DO:
    assign
      v-reg-output = replace( p-string
                                      ,chr(44)
                                      ,"":U
                                    )
      v-reg-output = trim(v-reg-output)
    .
  END.
  else do:
    v-reg-output = p-string.
  end.
  IF p-supress THEN DO: ASSIGN v-reg-output = supress-null( TRIM( v-reg-output ), p-dec-sep ). END.
  return v-reg-output.
end.
  return p-string.
END FUNCTION.
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
FUNCTION get-chk-type RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as integer,
    input loc-is-wth as logical)  FORWARD.
DEFINE STREAM PrnLibStream.
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.
DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width 232 down stream-io use-text NO-BOX.
 DEFINE FRAME Doc
   with width 232 down stream-io use-text NO-BOX.
CASE pReportOption:
  when "excel":U then do:
    Make-excel = yes.
  end.
  when "":U then do:
  end.
end.
assign
fill2 = fill("-", 2)
fill3 = fill("-", 3)
fill4 = fill("-", 4)
fill5 = fill("-", 5)
fill6 = fill("-", 6)
fill7 = fill("-", 7)
fill8 = fill("-", 8)
fill9 = fill("-", 9)
fill10 = fill("-", 10)
fill11 = fill("-", 11)
fill13 = fill("-", 13)
fill14 = fill("-", 14)
fill16 = fill("-", 16)
fill19 = fill("-", 19)
fill20 = fill("-", 20)
fill40 = fill("-", 40)
.
ReportName = "Строки списка чеков ".
assign
use-column[1] = yes
use-column[2] = yes
use-column[3] = yes
use-column[4] = yes
use-column[5] = yes
use-column[6] = yes
use-column[7] = yes
use-column[8] = yes
use-column[9] = yes
use-column[10] = yes
use-column[11] = yes
use-column[12] = yes
use-column[13] = yes
use-column[14] = yes
use-column[15] = yes
use-column[16] = yes
use-column[17] = yes
use-column[18] = yes
use-column[19] = yes
use-column[20] = yes
use-column[21] = yes
.
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"     l-col-lable="Номер чека в БД".
  define variable ed1 as handle no-undo.
  define variable l-1 as handle no-undo.
  define variable ll-1 as handle no-undo.
  define variable c-for-doc-code-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-doc-code-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[1] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 1
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"     l-col-lable="Тип чека".
  define variable ed2 as handle no-undo.
  define variable l-2 as handle no-undo.
  define variable ll-2 as handle no-undo.
  define variable c-for-chk-type-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-chk-type-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[2] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 2
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="INTEGER" l-col-len=5 l-col-format= "99999"       l-col-lable="Код объекта".
  define variable ed3 as handle no-undo.
  define variable l-3 as handle no-undo.
  define variable ll-3 as handle no-undo.
  define variable c-for-obj-code-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-obj-code-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[3] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 3
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"       l-col-lable="Дата чека".
  define variable ed4 as handle no-undo.
  define variable l-4 as handle no-undo.
  define variable ll-4 as handle no-undo.
  define variable c-for-chk-date-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-chk-date-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[4] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 4
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "X(8)"       l-col-lable="Время чека".
  define variable ed5 as handle no-undo.
  define variable l-5 as handle no-undo.
  define variable ll-5 as handle no-undo.
  define variable c-for-chk-time-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-chk-time-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[5] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 5
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="integer" l-col-len=5 l-col-format= ">>>>9"       l-col-lable="№№".
  define variable ed6 as handle no-undo.
  define variable l-6 as handle no-undo.
  define variable ll-6 as handle no-undo.
  define variable c-for-line-num as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-line-num IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[6] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 6
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="integer" l-col-len=9 l-col-format= ">>>>>>>>9"       l-col-lable="Код".
  define variable ed7 as handle no-undo.
  define variable l-7 as handle no-undo.
  define variable ll-7 as handle no-undo.
  define variable c-for-b-code as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-b-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[7] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 7
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=16 l-col-format= "X(16)"       l-col-lable="Артикул".
  define variable ed8 as handle no-undo.
  define variable l-8 as handle no-undo.
  define variable ll-8 as handle no-undo.
  define variable c-for-artic as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-artic IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[8] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 8
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=27 l-col-format= "X(27)"       l-col-lable="Название".
  define variable ed9 as handle no-undo.
  define variable l-9 as handle no-undo.
  define variable ll-9 as handle no-undo.
  define variable c-for-gds-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-gds-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[9] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 9
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=10 l-col-format= "X(10)"       l-col-lable="Признак".
  define variable ed10 as handle no-undo.
  define variable l-10 as handle no-undo.
  define variable ll-10 as handle no-undo.
  define variable c-for-prt-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-prt-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[10] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 10
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="logical" l-col-len=2 l-col-format= "+/"       l-col-lable="Ош".
  define variable ed11 as handle no-undo.
  define variable l-11 as handle no-undo.
  define variable ll-11 as handle no-undo.
  define variable c-for-err-gds as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-err-gds IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[11] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 11
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=19 l-col-format= "X(19)"       l-col-lable="Код в спул-файле".
  define variable ed12 as handle no-undo.
  define variable l-12 as handle no-undo.
  define variable ll-12 as handle no-undo.
  define variable c-for-src-code as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-src-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[12] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 12
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="integer" l-col-len=3 l-col-format= ">>9"       l-col-lable="ТРК".
  define variable ed13 as handle no-undo.
  define variable l-13 as handle no-undo.
  define variable ll-13 as handle no-undo.
  define variable c-for-pump as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-pump IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[13] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 13
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=20 l-col-format= "X(20)"       l-col-lable="Производитель".
  define variable ed14 as handle no-undo.
  define variable l-14 as handle no-undo.
  define variable ll-14 as handle no-undo.
  define variable c-for-prod-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[14] = true then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-prod-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[14] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 14
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="decimal" l-col-len=11 l-col-format= "->>,>>9.999"       l-col-lable="Кол-во".
  define variable ed15 as handle no-undo.
  define variable l-15 as handle no-undo.
  define variable ll-15 as handle no-undo.
  define variable c-for-doc-qnty as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[15] = true then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-doc-qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[15] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 15
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="character" l-col-len=3 l-col-format= "X(3)"       l-col-lable="Ед.изм".
  define variable ed16 as handle no-undo.
  define variable l-16 as handle no-undo.
  define variable ll-16 as handle no-undo.
  define variable c-for-unit-cli as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[16] = true then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-unit-cli IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[16] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 16
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="decimal" l-col-len=9 l-col-format= ">>,>>9.99"       l-col-lable="Цена".
  define variable ed17 as handle no-undo.
  define variable l-17 as handle no-undo.
  define variable ll-17 as handle no-undo.
  define variable c-for-price-base as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[17] = true then DO:
        CREATE EDITOR LL-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-price-base IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[17] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 17
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="decimal" l-col-len=10 l-col-format= "->>,>>9.99"       l-col-lable="Скидка".
  define variable ed18 as handle no-undo.
  define variable l-18 as handle no-undo.
  define variable ll-18 as handle no-undo.
  define variable c-for-gds-discnt as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[18] = true then DO:
        CREATE EDITOR LL-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-gds-discnt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[18] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 18
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="decimal" l-col-len=6 l-col-format= "->9.99"       l-col-lable="% Ск.".
  define variable ed19 as handle no-undo.
  define variable l-19 as handle no-undo.
  define variable ll-19 as handle no-undo.
  define variable c-for-discnt-pcnt as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[19] = true then DO:
        CREATE EDITOR LL-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-discnt-pcnt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[19] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 19
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="decimal" l-col-len=9 l-col-format= ">>,>>9.99"       l-col-lable="Цена нетто".
  define variable ed20 as handle no-undo.
  define variable l-20 as handle no-undo.
  define variable ll-20 as handle no-undo.
  define variable c-for-price-netto as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[20] = true then DO:
        CREATE EDITOR LL-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-price-netto IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[20] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 20
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="logical" l-col-len=2 l-col-format= "+/"       l-col-lable="Сп".
  define variable ed21 as handle no-undo.
  define variable l-21 as handle no-undo.
  define variable ll-21 as handle no-undo.
  define variable c-for-write-off as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[21] = true then DO:
        CREATE EDITOR LL-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-for-write-off IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME Doc:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[21] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 21
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Line = fill( "-" , 60 ) .
p-frame-width = l-col-pos - 1.
run get-report-num  in parParentProc ( output g#report-num).
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
if Make-Excel then
RUN OpenForExcel in this-procedure .
FORM with FRAME Doc .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream UNFORMATTED
SPACE(10)
Reportname chr(10)
SKIP(1).
display STREAM PrnLibStream with frame top-Frame .
run rep/extitle.p ( input 1).
run waitfram-show in this-procedure ( input "Ждите...").
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR EACH chk-list No-LOCK,
    each buf_chk-gds no-lock where
        buf_chk-gds.doc-code = chk-list.doc-code
BREAK
BY chk-list.doc-code :
    for-chk-type-gds = get-chk-type(chk-list.doc-code, chk-list.chk-type, chk-list.is-wth).
  FIND FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.b-code = buf_chk-gds.b-code NO-ERROR.
  IF AVAIL buf_bar-code then do:
    FIND FIRST buf_goods NO-LOCK WHERE
                buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
    FIND FIRST  buf_clients NO-LOCK WHERE
                buf_clients.obj-type = buf_goods.prod-type AND
                buf_clients.obj-code = buf_goods.prod-code NO-ERROR.
    FIND FIRST buf_gds-prt No-LOCK where
                buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
  end.
  else do:
    release buf_goods.
    release buf_clients.
    release buf_gds-prt.
  end.
  assign
  accum-count = accum-count + 1
  .
  if use-column[1]
  then  C-for-doc-code-gds:screen-value = string(chk-list.doc-code, entry(1, c-for-doc-code-gds:private-data, chr(4))).
  if use-column[2]
  then  C-for-chk-type-gds:screen-value = string(get-chk-type(chk-list.doc-code, chk-list.chk-type, chk-list.is-wth ), entry(1, c-for-chk-type-gds:private-data, chr(4))).
  if use-column[3]
  then  C-for-obj-code-gds:screen-value = string(chk-list.obj-code, entry(1, c-for-obj-code-gds:private-data, chr(4))).
  if use-column[4]
  then  C-for-chk-date-gds:screen-value = string(string(chk-list.chk-date, '99/99/9999'), entry(1, c-for-chk-date-gds:private-data, chr(4))).
  if use-column[5]
  then  C-for-chk-time-gds:screen-value = string(string(chk-list.chk-time, 'hh:mm:ss'), entry(1, c-for-chk-time-gds:private-data, chr(4))).
  if use-column[6]
  then  C-for-line-num:screen-value = string(buf_chk-gds.line-num, entry(1, c-for-line-num:private-data, chr(4))).
  if use-column[7]
  then  C-for-b-code:screen-value = string(buf_chk-gds.b-code, entry(1, c-for-b-code:private-data, chr(4))).
  if use-column[8]
  then  C-for-artic:screen-value = string((if available buf_goods then buf_goods.artic else '':U), entry(1, c-for-artic:private-data, chr(4))).
  if use-column[9]
  then  C-for-gds-name:screen-value = string((if available buf_goods then buf_goods.gds-name else 'НЕИЗВЕСТНЫЙ ТОВАР':U), entry(1, c-for-gds-name:private-data, chr(4))).
  if use-column[10]
  then  C-for-prt-name:screen-value = string((if available buf_gds-prt then buf_gds-prt.f-name else '':U), entry(1, c-for-prt-name:private-data, chr(4))).
  if use-column[11]
  then  C-for-err-gds:screen-value = string(buf_chk-gds.is-error, entry(1, c-for-err-gds:private-data, chr(4))).
  if use-column[12]
  then  C-for-src-code:screen-value = string(buf_chk-gds.src-code, entry(1, c-for-src-code:private-data, chr(4))).
  if use-column[13]
  then  C-for-pump:screen-value = string(buf_chk-gds.pump, entry(1, c-for-pump:private-data, chr(4))).
  if use-column[14]
  then  C-for-prod-name:screen-value = string((if available buf_Clients then buf_clients.obj-name else '':U), entry(1, c-for-prod-name:private-data, chr(4))).
  if use-column[15]
  then  C-for-doc-qnty:screen-value = string(buf_chk-gds.doc-qnty, entry(1, c-for-doc-qnty:private-data, chr(4))).
  if use-column[16]
  then  C-for-unit-cli:screen-value = string((if available buf_bar-code then buf_bar-code.unit-cli else '':U), entry(1, c-for-unit-cli:private-data, chr(4))).
  if use-column[17]
  then  C-for-price-base:screen-value = string(buf_chk-gds.price-base, entry(1, c-for-price-base:private-data, chr(4))).
  if use-column[18]
  then  C-for-gds-discnt:screen-value = string(buf_chk-gds.discnt, entry(1, c-for-gds-discnt:private-data, chr(4))).
  if use-column[19]
  then  C-for-discnt-pcnt:screen-value = string((buf_chk-gds.discnt / (buf_chk-gds.price-base * 100)), entry(1, c-for-discnt-pcnt:private-data, chr(4))).
  if use-column[20]
  then  C-for-price-netto:screen-value = string((buf_chk-gds.price-base - buf_chk-gds.discnt), entry(1, c-for-price-netto:private-data, chr(4))).
  if use-column[21]
  then  C-for-write-off:screen-value = string((if buf_chk-gds.write-off-code <> ?                   and buf_chk-gds.write-off-code <> 0                   then yes                   else no) , entry(1, c-for-write-off:private-data, chr(4))).
  DISPLAY stream  PrnLibStream with frame Doc.                                      DOWN 1 stream PrnLibStream with frame Doc.
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (reg-output(
                    string(chk-list.doc-code, entry(1, c-for-doc-code-gds:private-data, chr(4)))
                   ,c-for-doc-code-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 1 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[2]
  then (reg-output(
                    string(get-chk-type(chk-list.doc-code, chk-list.chk-type, chk-list.is-wth ), entry(1, c-for-chk-type-gds:private-data, chr(4)))
                   ,c-for-chk-type-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 2 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[3]
  then (reg-output(
                    string(chk-list.obj-code, entry(1, c-for-obj-code-gds:private-data, chr(4)))
                   ,c-for-obj-code-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[4]
  then (reg-output(
                    string(string(chk-list.chk-date, '99/99/9999'), entry(1, c-for-chk-date-gds:private-data, chr(4)))
                   ,c-for-chk-date-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 4 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[5]
  then (reg-output(
                    string(string(chk-list.chk-time, 'hh:mm:ss'), entry(1, c-for-chk-time-gds:private-data, chr(4)))
                   ,c-for-chk-time-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 5 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[6]
  then (reg-output(
                    string(buf_chk-gds.line-num, entry(1, c-for-line-num:private-data, chr(4)))
                   ,c-for-line-num:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 6 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[7]
  then (reg-output(
                    string(buf_chk-gds.b-code, entry(1, c-for-b-code:private-data, chr(4)))
                   ,c-for-b-code:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 7 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[8]
  then (reg-output(
                    string((if available buf_goods then buf_goods.artic else '':U), entry(1, c-for-artic:private-data, chr(4)))
                   ,c-for-artic:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 8 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[9]
  then (reg-output(
                    string((if available buf_goods then buf_goods.gds-name else 'НЕИЗВЕСТНЫЙ ТОВАР':U), entry(1, c-for-gds-name:private-data, chr(4)))
                   ,c-for-gds-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 9 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[10]
  then (reg-output(
                    string((if available buf_gds-prt then buf_gds-prt.f-name else '':U), entry(1, c-for-prt-name:private-data, chr(4)))
                   ,c-for-prt-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 10 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[11]
  then (reg-output(
                    string(buf_chk-gds.is-error, entry(1, c-for-err-gds:private-data, chr(4)))
                   ,c-for-err-gds:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 11 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[12]
  then (reg-output(
                    string(buf_chk-gds.src-code, entry(1, c-for-src-code:private-data, chr(4)))
                   ,c-for-src-code:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 12 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[13]
  then (reg-output(
                    string(buf_chk-gds.pump, entry(1, c-for-pump:private-data, chr(4)))
                   ,c-for-pump:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 13 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[14]
  then (reg-output(
                    string((if available buf_Clients then buf_clients.obj-name else '':U), entry(1, c-for-prod-name:private-data, chr(4)))
                   ,c-for-prod-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 14 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[15]
  then (reg-output(
                    string(buf_chk-gds.doc-qnty, entry(1, c-for-doc-qnty:private-data, chr(4)))
                   ,c-for-doc-qnty:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 15 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[16]
  then (reg-output(
                    string((if available buf_bar-code then buf_bar-code.unit-cli else '':U), entry(1, c-for-unit-cli:private-data, chr(4)))
                   ,c-for-unit-cli:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 16 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[17]
  then (reg-output(
                    string(buf_chk-gds.price-base, entry(1, c-for-price-base:private-data, chr(4)))
                   ,c-for-price-base:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 17 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[18]
  then (reg-output(
                    string(buf_chk-gds.discnt, entry(1, c-for-gds-discnt:private-data, chr(4)))
                   ,c-for-gds-discnt:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 18 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[19]
  then (reg-output(
                    string((buf_chk-gds.discnt / (buf_chk-gds.price-base * 100)), entry(1, c-for-discnt-pcnt:private-data, chr(4)))
                   ,c-for-discnt-pcnt:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 19 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[20]
  then (reg-output(
                    string((buf_chk-gds.price-base - buf_chk-gds.discnt), entry(1, c-for-price-netto:private-data, chr(4)))
                   ,c-for-price-netto:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 20 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[21]
  then (reg-output(
                    string((if buf_chk-gds.write-off-code <> ?                                       and buf_chk-gds.write-off-code <> 0                                       then yes                                       else no) , entry(1, c-for-write-off:private-data, chr(4)))
                   ,c-for-write-off:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 21 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  skip.
  IF LAST(chk-list.doc-code) then do:
  if use-column[1]
  then  C-for-doc-code-gds:screen-value = string(string(accum-count), entry(1, c-for-doc-code-gds:private-data, chr(4))).
  if use-column[2]
  then  C-for-chk-type-gds:screen-value = string( 'строк' , entry(1, c-for-chk-type-gds:private-data, chr(4))).
    DISPLAY stream  PrnLibStream with frame Doc.                                      DOWN 1 stream PrnLibStream with frame Doc.
  end.
END.
if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
sheetf.sizes = "9,9,9,12,155"
.
run rep/extitle.p ( input 2).
for each chk-list-hist:
  if Make-Excel then  put   stream ForExcel unformatted
  (if chk-list-hist.line = 0
   then string(chk-list-hist.id, ">>>>>>>>9")
   else '':U)
  CHR(9)
  (if chk-list-hist.item_ <> '':U
   then chk-list-hist.hist-mode
   else '':U)  CHR(9)
   (if chk-list-hist.item_ <> '':U
   then string(chk-list-hist.num-add, "->>>>>>>>9")
   else '':U)  CHR(9)
  (if chk-list-hist.item_ <> '':U
  then string(chk-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  CHR(9)
  chk-list-hist.des
  skip.
end.
HIDE STREAM PrnLibStream FRAME DOc .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".
if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         "rpt" +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.
if Make-Excel then
RUN CLoseForExcel in this-procedure .
FUNCTION get-chk-type RETURNS CHARACTER
  ( LOC-DOC-CODE AS CHARACTER, loc-chk-type as integer, loc-is-wth as logical ) :
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-str as character no-undo.
CASE loc-is-wth:
    when yes then do:
    assign
    v-str = entry (lookup (string(loc-chk-type),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U)
    no-error
    .
  end.
  when no then do:
      if loc-chk-type = ?
      or loc-chk-type = 0
      then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = loc-doc-code no-error .
        if available buf_chk-doc then do:
          assign
          loc-chk-type = integer(if buf_chk-doc.netto >= 0
                  then '1':U
                  else '6':U)
          .
        end.
        if loc-chk-type = integer('6':U) then do:
          for each buf_chk-gds no-lock where
                  buf_Chk-gds.doc-code = buf_chk-doc.doc-code:
            if not (buf_Chk-gds.write-off-code < 0 and
                    (buf_Chk-gds.write-off-code = integer('-9':U)
                    or
                    buf_Chk-gds.write-off-code = integer('-4':U)
                    )
                    )
            then do:
              leave.
            end.
          end.
        end.
        if not available buf_chk-gds then
        loc-chk-type = integer('96':U).
      end.
      assign
      v-str = entry (lookup (string(loc-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
      no-error
      .
  end.
END CASE.
RETURN v-str.
END FUNCTION.
