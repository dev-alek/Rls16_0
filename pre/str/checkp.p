block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER cdoc like chk-doc.doc-code.
define variable vss-revision    as character no-undo init "$Revision: 55e470c22f96, 3463, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:34 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/checkp.p $":U .
define variable vss-description as character no-undo init "Печать одного чека".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-chk-doc for ub.chk-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-chk-doc.shift-name.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-chk-doc.obj-type,
                       input  loc-chk-doc.obj-code,
                       input  loc-chk-doc.shift-date,
                       input  loc-chk-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
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
define variable sym1           as char      format "X(1)" init ":".
define variable sym10          as char      format "X(1)" init ":".
define variable date_string    as char      no-undo.
define variable Line           as char      no-undo.
define variable for-time       as char.
define variable for-gds-sum    like chk-doc.netto no-undo.
define variable for-gds-price  like chk-gds.price-base no-undo.
define variable fgds-discnt-pc as decimal   no-undo.
define variable accum-pay-r-b  as decimal   no-undo .
define variable v-curr-r-b     as character no-undo .
define variable v-is-write-off as logical   no-undo .
define variable itog-doc-qnty as decimal no-undo .
define variable itog-price-service as decimal no-undo .
define variable itog-discnt as decimal no-undo .
define variable itog-discnt-pc as decimal no-undo .
define variable itog-gds-sum as decimal no-undo .
define variable itog-gds-price as decimal no-undo .
define variable itog-tot-sum as decimal no-undo .
define variable itog-tot-base as decimal no-undo .
define variable itog-tot-rubl as decimal no-undo .
define variable v-attr-rnn as character no-undo .
define variable v-attr-sbprrn as character no-undo .
define variable v-fix   as character no-undo .
define variable v-fix-png  as character no-undo .
define variable v-arc as character no-undo .
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
FIND FIRST chk-doc NO-LOCK WHERE chk-doc.doc-code = cdoc NO-ERROR.
IF NOT avail chk-doc then return.
FOR EACH chk-pay No-LOCK where chk-pay.doc-code = chk-doc.doc-code:
   assign
      accum-pay-r-b = accum-pay-r-b +
              (if v-curr-r-b = 'base':U
                then chk-pay.tot-base
                else chk-pay.tot-rubl)
      .
END.
if NOT chk-doc.d-card = "" then
do:
   FIND FIRST dis-card NO-LOCK WHERE dis-card.d-card = chk-doc.d-card NO-ERROR.
   IF avail dis-card then
   do:
      FIND FIRST clients where clients.obj-type = dis-card.cli-type AND
         clients.obj-code = dis-card.cli-code No-ERROR.
   END.
end.
      assign
        v-arc = search( "exe/qrgen.exe":U )
        .
      if v-arc = ? then
      do:
        message "Не найдена программа qrgen.exe"
        view-as alert-box.
         return error .
      end.
      define variable v-date as character no-undo .
      v-date = "20" + entry(3,string(chk-doc.chk-date),"/") + entry(2,string(chk-doc.chk-date),"/") + entry(1,string(chk-doc.chk-date),"/").
      v-fix = "t=" + v-date + "T" + replace(string(chk-doc.chk-time,"HH:MM"),":","") + "&i=" + string(chk-doc.chk-num) + "&n=" + string(chk-doc.chk-type) .
      os-command silent value (v-arc + ' -size=128 -content="' + v-fix + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_fix"') .
      v-fix-png = string(session :temp-directory) + "qr-code_fix" + ".png" .
find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "sbprrn" and
                                          buf_chk-pay-attr.doc-code = chk-doc.doc-code
                                          and buf_chk-pay-attr.attr-value <> "" no-error .
if available (buf_chk-pay-attr) then do:
      os-command silent value (v-arc + ' -size=128 -content="' + buf_chk-pay-attr.attr-value + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_sbprrn"') .
      v-attr-sbprrn = string(session :temp-directory) + "qr-code_sbprrn" + ".png" .
end.
find first buf_chk-pay-attr no-lock where (buf_chk-pay-attr.attr-code = "RRN" or buf_chk-pay-attr.attr-code = "cpdoc") and
                                          buf_chk-pay-attr.doc-code = chk-doc.doc-code
                                          and buf_chk-pay-attr.attr-value <> "" no-error .
if available (buf_chk-pay-attr) then do:
      os-command silent value (v-arc + ' -size=128 -content="' + buf_chk-pay-attr.attr-value + '"' + ' -filename="' + string(session :temp-directory) + 'qr-code_rrn"') .
      v-attr-rnn = string(session :temp-directory) + "qr-code_rrn" + ".png" .
end.
date_string = cur-time-print() .
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
   '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
   '<thead>' skip
   .
put stream OutStr-html unformatted
   '<tr class="set_columns">' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 15px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 30px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 120px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 20px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 60px;"></td>' skip
   '<td style="width: 80px;"></td>' skip
   '<td style="width: 40px;"></td>' skip
   '</tr>' skip
   .
put stream OutStr-html unformatted
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">' + string(date_string) + '</TD>' skip
   '<TD colspan="4" style="text-align: center;">Для поиска чека на кассе</TD>' skip
   '<TD colspan="3" style="text-align: center;">RRN</TD>' skip
   '<TD colspan="3" style="text-align: center;">SBPRRN</TD>' skip
   '</TR>' skip
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Чек N ' + string(chk-doc.doc-code) + ' Магазин N ' + string(chk-doc.obj-code) + ' Дата: ' + string(chk-doc.chk-date, "99/99/9999") + ' Время: ' + string(chk-doc.chk-time, "HH:MM") + ' Дата смены: ' + string(chk-doc.shift-date, "99/99/9999") + ' Номер смены: ' + shift-name-no-err(buffer chk-doc) + '</TD>' skip
   .
     if search(v-fix-png) <> ? then
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" rowspan="5" colspan="4" style="text-align: center;"><img src="' + string(v-fix-png)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<TD rowspan="5" colspan="4"></TD>' skip
      .
  end.
     if search(v-attr-rnn) <> ? then
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" rowspan="5" colspan="3" style="text-align: center;"><img src="' + string(v-attr-rnn)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<TD rowspan="5" colspan="3"></TD>' skip
      .
  end.
     if search(v-attr-sbprrn) <> ? then
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" rowspan="5" colspan="3" style="text-align: center;"><img src="' + string(v-attr-sbprrn)+ '" width="130" height="130" alt=""/></TD>' skip
      .
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<TD rowspan="5" colspan="3"></TD>' skip
      .
  end.
put stream OutStr-html unformatted
   '</TR>' skip
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Касса N ' + string(chk-doc.pay-desk) + ' Номер по кассе ' + string(chk-doc.chk-num) + ' Кассир: ' + if chk-doc.cashier <> ? then string(chk-doc.cashier) else "" + ' Продавец: ' + if chk-doc.sales-man <> ? then string(chk-doc.sales-man) else "" + '</TD>' skip
   '</TR>' skip
   .
if NOT chk-doc.d-card = "" then
do:
   if available (clients) then
   do:
      put stream OutStr-html unformatted
         '<TR>'skip
         '<TD colspan="14" style="font-weight: bold;">Дисконтная карта №: ' + string(chk-doc.d-card) + ' Клиент: ' + string(clients.obj-name) + ' Сумма товарная: ' + string(chk-doc.tot-doc,"->>>,>>>,>>9.99") + '</TD>'
         '</TR>' skip
         .
   end.
   else
   do:
      put stream OutStr-html unformatted
         '<TR>'skip
         '<TD colspan="14" style="font-weight: bold;">Дисконтная карта №: ' + string(chk-doc.d-card) + ' Сумма товарная: ' + string(chk-doc.tot-doc,"->>>,>>>,>>9.99") + '</TD>'
         '</TR>' skip
         .
   end.
end.
if chk-doc.sub-discnt <> 0 then
do:
   put stream OutStr-html unformatted
      '<TR>'skip
      '<TD colspan="14" text_wrap="true" style="text-align: left; font-weight: bold;">Скидка общая: ' + string((chk-doc.discnt),"->>>>>>>>>>>9.99") + ' Списание: ' + string(chk-doc.sub-discnt, "->>>,>>>,>>9.99") + ' Процент скидки: ' + string((if chk-doc.tot-doc = 0 then 0 else ( chk-doc.discnt / chk-doc.tot-doc * 100 ) ), "->9.99%") + '</TD>' skip
      '</TR>' skip
      .
end.
else
do:
   put stream OutStr-html unformatted
      '<TR>'skip
      '<TD colspan="14" text_wrap="true" style="text-align: left; font-weight: bold;">Скидка общая: ' + string((chk-doc.discnt),"->>>>>>>>>>>9.99") + ' Списание: ' + string(chk-doc.sub-discnt, "->>>,>>>,>>9.99") + ' Процент скидки: ' + string((if chk-doc.tot-doc = 0 then 0 else ( chk-doc.discnt / chk-doc.tot-doc * 100 ) ), "->9.99%") + '</TD>' skip
      '</TR>' skip
      .
end.
put stream OutStr-html unformatted
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">Сумма нетто: ' + string(chk-doc.netto, "->>>,>>>,>>9.99") + ' Сумма оплат: ' + string(ACCUM-pay-r-b, "->>>,>>>,>>9.99") + '</TD>' skip
   '</TR>' skip
   '<TR>'skip
   '<TD colspan="14" style="font-weight: bold;">ТОВАРЫ ПО ЧЕКУ:</TD>' skip
   '</TR>' skip
   '<TR height: 14px;>'skip
   '<TD colspan="14" style="font-weight: bold; border-bottom: 1px solid black;"></TD>' skip
   '</TR>' skip
   .
put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">NN</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Артикул</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border-top: 1px solid black;">Название/</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Ош</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код в спул-файле</TD>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border-top 1px solid black;">ТРК</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Количество</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Изм</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Цена</TD>' skip
   '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Скидка</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">% ск</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Цена нетто</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма по строке</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Дорожный налог</TD>' skip
   '<TD text_wrap="true" rowspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Спи</TD>' skip
   '</TR>'skip
   '<TR>'skip
   '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; font-weight: bold; background-color: silver; border-bottom: 1px solid black;">Производитель</TD>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Пист</TD>' skip
   '</TR>'skip
   '<TR>'skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border-bottom: 1px solid black;">Рез</TD>' skip
   '</TR>'skip
   .
FOR EACH chk-gds No-LOCK where
   chk-gds.doc-code = chk-doc.doc-code
   by abs(CHk-gds.line-num ):
   FIND FIRST bar-code No-LOCK WHERE bar-code.b-code = chk-gds.b-code NO-ERROR.
   IF AVAIL bar-code then
   do:
      FIND FIRST goods NO-LOCK WHERE
         goods.gds-code = bar-code.gds-code NO-ERROR.
      FIND FIRST  clients NO-LOCK WHERE
         clients.obj-type = goods.prod-type AND
         clients.obj-code = goods.prod-code NO-ERROR.
      FIND FIRST gds-prt No-LOCK where gds-prt.upper-code = goods.prt-root NO-ERROR.
   end.
   assign
      fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
      for-gds-sum    = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
      for-gds-price  = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
      .
   put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.line-num) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.b-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then goods.artic + '</TD>' else "" + '</td>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then goods.gds-name + '</TD>' else "" + '</td>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: center; border: 1px solid black;">' + if chk-gds.is-error then "yes" + '</TD>' else "no" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: center; border: 1px solid black;">' + string(chk-gds.src-code) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; border-top: 1px solid black;">' + string(chk-gds.pump) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.doc-qnty,"->>>>>>>>>>>9.999") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: center; border: 1px solid black;">' + if avail bar-code then string(bar-code.unit-cli) + '</TD>' else "" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string((chk-gds.price-base + chk-gds.price-service),"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="2" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.discnt,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(fgds-discnt-pc,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(for-gds-price,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(for-gds-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-gds.road-tax,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" rowspan="3" style="text-align: right; border: 1px solid black;">' + if chk-gds.write-off-code <> ? and chk-gds.write-off-code <> 0 then "yes" + '</TD>' else "no" + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
      .
      if avail bar-code then do:
         put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + IF ub.gds-prt.node-name <> '_Пустая шкала':U then string(gds-prt.f-name) + '</TD>' else "" + '</td>' skip .
      end.
      else do:
         put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;"></TD>'
      .
      end.
      put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="2" rowspan="2" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + if avail bar-code then clients.obj-name + '</TD>' else "" + '</td>' skip
    '<TD text_wrap="true" style="text-align: center;">' +  if chk-gds.nozzle-code <> 0 then string(chk-gds.nozzle-code) + '</TD>' else "" + '</TD>' skip
    '</TR>' skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + if chk-gds.loc1 <> "" then string(chk-gds.loc1) + '</TD>' else "" + '</TD>' skip
    '</TR>' skip
      .
assign
itog-doc-qnty = itog-doc-qnty + chk-gds.doc-qnty
itog-price-service = itog-price-service + ((chk-gds.price-base + chk-gds.price-service) * chk-gds.doc-qnty)
itog-discnt = itog-discnt + (chk-gds.discnt * chk-gds.doc-qnty)
itog-gds-sum = itog-gds-sum + ((chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty)
.
END.
put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="12" style="font-weight: bold; text-align: right;"></TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-doc-qnty,"->>>>>>>>>>>9.999") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-price-service,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="2" style="font-weight: bold; text-align: right;">' + string(itog-discnt,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" style="font-weight: bold; text-align: right;">' + string((itog-discnt / (itog-price-service * 100)),"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" style="font-weight: bold; text-align: right;">' + string(itog-gds-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="2"></TD>' skip
   '</TR>'skip
   .
put stream OutStr-html unformatted
   '<TR>'skip
   '<TD text_wrap="true" colspan="18" style="font-weight: bold;">ОПЛАТЫ ПО ЧЕКУ</TD>' skip
   '<TD colspan="6"></TD>' skip
   '</TR>'skip
   '<TR height: 14px;>'skip
   '<TD colspan="18" style="font-weight: bold;"></TD>' skip
   '<TD colspan="6" style="font-weight: bold; 0px solid white;"></TD>' skip
   '</TR>' skip
   '<TR>' skip
   '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">NN</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код. вал</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Валюта</TD>' skip
   '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Код платежа</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Платеж</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в вал. платежа</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в баз.вал</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: center; font-weight: bold; background-color: silver; border: 1px solid black;">Сумма в рублях</TD>' skip
   '<TD text_wrap="true" style="border-top: 0px solid white;"></TD>' skip .
   put stream OutStr-html unformatted
   '<TD text_wrap="true" colspan="4" style="border-top: 0px solid white;"></TD>' skip
   '</TR>'skip
   .
FOR EACH chk-pay No-LOCK WHERE
   chk-pay.doc-code = chk-doc.doc-code
   by CHk-pay.line-num :
   FIND FIRST currency No-LOCK WHERE currency.curr-code = chk-pay.curr-code NO-ERROR.
   FIND FIRST cash-pay No-LOCK WHERE
      cash-pay.cdpay-code = chk-pay.pay-code AND
      cash-pay.curr-code = chk-pay.curr-code No-ERROR.
   assign
      itog-tot-sum = itog-tot-sum + chk-pay.tot-sum
      itog-tot-base = itog-tot-base + chk-pay.tot-base
      itog-tot-rubl = itog-tot-rubl + chk-pay.tot-rubl
      .
   put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(chk-pay.line-num) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + string(chk-pay.curr-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + if available (currency) then currency.curr-name + '</TD>' else "НЕОПОЗНАННАЯ ВАЛЮТА" + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center; border: 1px solid black;">' + string(chk-pay.pay-code) + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: center; border: 1px solid black;">' + if available (cash-pay) then cash-pay.obj-name + '</TD>' else "НЕОПОЗНАННАЯ ОПЛАТА" + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-base,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true" colspan="3" style="text-align: right; border: 1px solid black;">' + string(chk-pay.tot-rubl,"->>>>>>>>>>>9.99") + '</TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true" colspan="4"></TD>' skip
      '</TR>'skip
      .
END.
define variable NumberFN as character no-undo .
define variable FiscalDocNumber as character no-undo .
define variable FiscalDocSign as character no-undo .
find first chk-doc-attr where chk-doc-attr.attr-code = 'CHNumberFN' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO:
NumberFN = chk-doc-attr.attr-value.
end.
find first chk-doc-attr where chk-doc-attr.attr-code = 'CHFiscalDocNumber' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO:
FiscalDocNumber = chk-doc-attr.attr-value.
end.
find first chk-doc-attr where chk-doc-attr.attr-code = 'CHFiscalDocSign' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
IF AVAILABLE chk-doc-attr THEN DO:
FiscalDocSign = chk-doc-attr.attr-value.
end.
put stream OutStr-html unformatted
   '<TR>' skip
   '<TD text_wrap="true" colspan="10" style="text-align: right; font-weight: bold;"></TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-sum,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-base,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true" colspan="3" style="text-align: right; font-weight: bold;">' + string(itog-tot-rubl,"->>>>>>>>>>>9.99") + '</TD>' skip
   '<TD text_wrap="true"></TD>' skip
   '<TD text_wrap="true" colspan="4"></TD>' skip
   '</TR>'skip
   '<TR>' skip
   '<TD text_wrap="true" colspan="18" style="font-weight: bold;"> ФИСКАЛЬНЫЕ ДАННЫЕ </TD>' skip
   '</TR>' skip
   '<TR>' skip
   '<TD ><BR></TD>' skip
   '</TR>' skip
   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФН </TD>' skip
   '<TD text_wrap="true" colspan="10">' NumberFN '</TD>' skip
   '</TR>' skip
   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФД </TD>' skip
   '<TD text_wrap="true" colspan="10">' FiscalDocNumber '</TD>' skip
   '</TR>' skip
   '<TR>' skip
   '<TD text_wrap="true" colspan="2"> ФПД </TD>' skip
   '<TD text_wrap="true" colspan="10">' FiscalDocSign '</TD>' skip
   '</TR>'skip
   '</thead>' skip
   '</table>' skip
   '</body>' skip
   '</html>' skip
   .
output stream OutStr-html close.
run prn-lib-reportviewer-report-name in this-procedure (
   input this-procedure
   ,input v-file-name-rep-htm
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.
PROCEDURE get-report-num :
    define output parameter p-report-num as integer no-undo .
    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.
END PROCEDURE.
