define input parameter parparentproc as WIDGET-HANDLE NO-UNDO.
define input parameter inp-inkas-code like ub.trn-doc.doc-code.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по выручке".
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
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , chr(4)
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , chr(4)
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.
FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .
assign
  v-ps = fill( chr(32) +  chr(4), 9).
  v-str1 = ENTRY(1, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-chk-amount).
  ENTRY(1, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(2, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-gds-amount).
  ENTRY(2, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(3, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-out).
  ENTRY(3, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(4, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-out).
  ENTRY(4, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(5, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(6, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(7, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(8, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
return v-ps.
END FUNCTION.
FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, chr(4)) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, chr(4)), chr(32)))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, chr(4)), chr(32)))
  no-error .
end.
return not error-status:error .
END FUNCTION.
PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .
define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = 'trf':U
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable gds-amount    as integer   no-undo.
define variable chk-amount    as integer   no-undo.
define variable line-out      as integer   no-undo.
define variable line-ret      as integer   no-undo.
define variable dtl-out       as integer   no-undo.
define variable dtl-ret       as integer   no-undo.
define variable nf-chk-amount as integer   no-undo.
define variable nf-gds-amount as integer   no-undo.
define variable ps-where-rus  as character no-undo.
define variable glog          as logical   no-undo.
define variable v-doc-rec     as recid     no-undo .
define variable pay-tot-rubl  as decimal   no-undo .
define variable pay-desk-tot-rubl as decimal no-undo .
define variable pay-tot-rubl-return      as decimal no-undo .
define variable pay-desk-tot-rubl-return as decimal no-undo .
define variable v-exist-autotank         as logical no-undo .
define variable a-sum-return             as decimal no-undo .
define TEMP-TABLE temp-inkas-cash-desk no-undo
FIELD inkas-code as character
FIELD pay-desk   as integer
FIELD tot-base   as decimal
FIELD tot-rubl   as decimal
FIELD tot-rubl-return as decimal
    INDEX pi IS UNIQUE PRIMARY
inkas-code pay-desk.
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input p-pay-code as integer, input p-curr-code as integer )  FORWARD.
FUNCTION get-chk-type RETURNS CHARACTER
  ( input par-doc-type as character )  FORWARD.
FUNCTION get-currency RETURNS CHARACTER
  ( input p-curr-code as integer )  FORWARD.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .
define variable accumpay as decimal FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Выручка"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE autotank-sum-return AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "разн.по запр.за нал"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f% AS DECIMAL FORMAT "->>9.<%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-num-chk AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "фискальных"
     VIEW-AS FILL-IN
     SIZE 6.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fnetto AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Нетто"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE g-discnt AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "В т.ч. товарная"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 0  NO-UNDO.
DEFINE QUERY BR-cash-desk FOR
      temp-inkas-cash-desk SCROLLING.
DEFINE QUERY BR-INKAS-PAY FOR
      ub.inkas-pay,
      ub.cash-pay,
      ub.currency SCROLLING.
DEFINE QUERY BR-pay-desk FOR
      ub.inkas-pay-desk SCROLLING.
DEFINE BROWSE BR-cash-desk
  QUERY BR-cash-desk DISPLAY
      temp-inkas-cash-desk.pay-desk FORMAT ">>>9" WIDTH 5 COLUMN-LABEL "Касса"
temp-inkas-cash-desk.tot-rubl + temp-inkas-cash-desk.tot-rubl-return
          FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Выручка(руб.)"
temp-inkas-cash-desk.tot-rubl FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "abbr_rub_firstshift.эквивалент"
temp-inkas-cash-desk.tot-rubl-return
          FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Разн.по запр.за нал"
temp-inkas-cash-desk.tot-base FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "В баз.вал."
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74.5 BY 5.46
         BGCOLOR 8 FONT 4
         TITLE BGCOLOR 8 "Выручка по кассам ОБЩАЯ" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE BROWSE BR-INKAS-PAY
  QUERY BR-INKAS-PAY NO-LOCK DISPLAY
      ub.cash-pay.obj-name FORMAT "X(25)":U
      ub.currency.curr-abbr FORMAT "X(3)":U
      pay-tot-rubl COLUMN-LABEL "Выручка(руб.)" FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-rubl COLUMN-LABEL "abbr_rub_firstshift.эквивалент" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 15
      pay-tot-rubl-return COLUMN-LABEL "Разн.по запр.за нал" FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-sum FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-base FORMAT "->>>,>>>,>>9.99":U
    WITH SEPARATORS SIZE 85 BY 8
         FONT 4
         TITLE "Выручка по типам  кассовых платежей" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE BROWSE BR-pay-desk
  QUERY BR-pay-desk DISPLAY
      ub.inkas-pay-desk.pay-desk FORMAT ">>>9":U
      ub.inkas-pay-desk.cashier FORMAT ">>>>9":U
      get-cash-pay(inkas-pay-desk.pay-code, inkas-pay-desk.curr-code) COLUMN-LABEL "Название" FORMAT "X(22)":U
      pay-desk-tot-rubl COLUMN-LABEL "Выручка(руб.)" FORMAT "->>>>>>>>9.99":U
      ub.inkas-pay-desk.tot-rubl COLUMN-LABEL "abbr_rub_firstshift.эквивалент" FORMAT "->>>,>>>,>>9.99":U
      get-currency(inkas-pay-desk.curr-code) COLUMN-LABEL "Вал" FORMAT "X(3)":U
      ub.inkas-pay-desk.tot-sum FORMAT "->>>,>>>,>>9.99":U
      get-chk-type(inkas-pay-desk.doc-type) COLUMN-LABEL "Операция" FORMAT "X(8)":U
      ub.inkas-pay-desk.tot-base FORMAT "->>>,>>>,>>9.99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4
         TITLE "Выручка по кассам по типам кассовых платежей" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     ub.inkas.tot-doc AT ROW 1 COL 42 COLON-ALIGNED
          LABEL "Сумма товарная"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     b-print AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     ub.inkas.num-chk AT ROW 2 COL 16 COLON-ALIGNED
          LABEL "Чеков"
          VIEW-AS FILL-IN
          SIZE 6.25 BY 1
          FGCOLOR 4
     ub.inkas.discnt AT ROW 2 COL 42 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     f% AT ROW 2 COL 76 COLON-ALIGNED NO-LABEL
     f-num-chk AT ROW 3 COL 16 COLON-ALIGNED
     g-discnt AT ROW 3 COL 42 COLON-ALIGNED
     ub.inkas.sub-discnt AT ROW 3 COL 76 COLON-ALIGNED
          LABEL "Списания"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 0
     autotank-sum-return AT ROW 4 COL 20 COLON-ALIGNED WIDGET-ID 2
     fnetto AT ROW 4 COL 42 COLON-ALIGNED
     accumpay AT ROW 4 COL 76 COLON-ALIGNED
     BR-INKAS-PAY AT ROW 5 COL 10
     BR-pay-desk AT ROW 13 COL 1
     BR-cash-desk AT ROW 19 COL 17 WIDGET-ID 100
     SPACE(8.09) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет о выручке":L.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       BR-INKAS-PAY:NUM-LOCKED-COLUMNS IN FRAME DIALOG-1     = 1.
ON CHOOSE OF b-print IN FRAME DIALOG-1
DO:
define variable sym1 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.
define variable sym6 as character init ":"   no-undo.
define variable sym8 as character init ":"   no-undo.
define variable Log-Res     as  logical      no-undo.
define variable Line        as  character    no-undo.
define variable date_string as  character    no-undo.
define variable v-base-code LIKE ub.sysconf.base-code no-undo.
define BUFFER buf_currency FOR ub.currency.
define buffer b-ink-pay    for ub.inkas-pay .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  inkas.host-code
  ,output v-base-code
  )  .
FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = v-base-code.
DEFINE FRAME Benefit-Tot
sym1 column-label ":" format "X(1)"
ub.cash-pay.obj-name column-label "Вид оплаты" format "X(30)"
sym3 column-label ":" format "X(1)"
ub.currency.curr-name column-label "Валюта" format "X(20)"
sym4 column-label ":" format "X(1)"
b-ink-pay.tot-sum column-label "Сумма (в валюте)" format "->,>>>,>>>,>>>,>>9.99"
sym5 column-label ":" format "X(1)"
b-ink-pay.tot-base column-label "Сумма (в Б.Вал.)" format "->,>>>>,>>>,>>9.99"
sym6 column-label ":" format "X(1)"
b-ink-pay.tot-rubl column-label "Сумма (в рублях)" format "->,>>>,>>>,>>>,>>9.99"
sym8 column-label ":" format "X(1)"
HEADER  date_string AT 5 format "X(35)"
string( "( Б.Вал. - " + caps( trim( buf_currency.curr-abbr ) ) + " )" ) format "X(20)" AT 42
string( "Страница " ) format "x(9)" AT 105 PAGE-NUMBER(Prnlibstream) AT 115 FORMAT ">>9" SKIP
Line format "X(126)" AT 1
with width 160 down stream-io use-text .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cur-obj-proceeds_print':U
    ,input  'firm':U
    ,input  inkas.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then return "NO".
if can-find( FIRST b-ink-pay WHERE b-ink-pay.inkas-code = inp-inkas-code ) then do:
  date_string = cur-time-print() .
  Line = fill( "-", 136 ).
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 62
                                              ,input yes
                                              ,input no
                                              ).
  FORM HEADER
      Line format "X(126)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibstream FRAME BottomFrame .
  PUT stream PrnLibstream
  space(15) string( "ВЫРУЧКА  по  отчету  о  продажах  N  " + inp-inkas-code )
  format "X(120)" SKIP(1) .
  FOR EACH b-ink-pay WHERE
           b-ink-pay.inkas-code = inp-inkas-code NO-LOCK
  BREAK
  BY b-ink-pay.inkas-code
  BY b-ink-pay.pay-code
  BY b-ink-pay.curr-code
  with frame Benefit-Tot :
  ACCUMULATE
  b-ink-pay.tot-sum ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-base ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-rubl ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-rubl ( TOTAL )
  b-ink-pay.tot-base ( TOTAL )
  b-ink-pay.curr-code ( COUNT ) .
  if last-of( b-ink-pay.curr-code ) then do:
    FIND FIRST ub.cash-pay WHERE
               ub.cash-pay.cdpay-code = b-ink-pay.pay-code AND
               ub.cash-pay.curr-code = b-ink-pay.curr-code NO-LOCK .
    FIND FIRST ub.currency WHERE
               ub.currency.curr-code = b-ink-pay.curr-code NO-LOCK.
    DISPLAY stream PrnLibstream
    sym1 ub.cash-pay.obj-name
    sym3 ub.currency.curr-name
    sym4 b-ink-pay.tot-sum
    sym5 b-ink-pay.tot-base
    sym6 b-ink-pay.tot-rubl
    sym8    .
    DOWN 1 stream PrnLibstream.
  end.
  if last( b-ink-pay.inkas-code ) then do:
    UNDERLINE stream PRnLibStream
    ub.cash-pay.obj-name
    b-ink-pay.tot-base
    b-ink-pay.tot-rubl .
    DISPLAY stream PrnLibstream
    sym1 " ИТОГО" @ ub.cash-pay.obj-name
                    ( ACCUM TOTAL b-ink-pay.tot-base ) @ b-ink-pay.tot-base
                    ( ACCUM TOTAL b-ink-pay.tot-rubl ) @ b-ink-pay.tot-rubl
                    sym8 .
   end.
 END.
 HIDE FRAME BottomFrame .
 PUT stream PrnLibstream
 Line format "X(126)" SKIP(2)
space(10) "Директор _______________" format "X(30)"
                "Старший продавец ______________" format "X(30)" SKIP(2)
space(10) "Бухгалтер ______________" format "X(30)"
                "Кассир ________________________" format "X(30)" SKIP .
 output stream PrnLibstream  CLOSE.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
end.
else
    message "Выручка НУЛЕВАЯ !" view-as alert-box information .
END.
ON ROW-DISPLAY OF BR-INKAS-PAY IN FRAME DIALOG-1
DO:
  assign
      pay-tot-rubl = 0
      pay-tot-rubl-return = 0
      .
  IF available ub.inkas-pay THEN
  DO:
      pay-tot-rubl = inkas-pay.tot-rubl .
      RUN autotank-inkas-pay(input ub.inkas-pay.inkas-code  ,
                           input ub.inkas-pay.pay-code    ,
                           input ub.inkas-pay.curr-code   ,
                           input "autotank-sum-return" ,
                           output a-sum-return) .
         assign
             pay-tot-rubl = pay-tot-rubl - a-sum-return
             pay-tot-rubl-return = pay-tot-rubl-return - a-sum-return
             .
  END.
END.
ON VALUE-CHANGED OF BR-INKAS-PAY IN FRAME DIALOG-1
DO:
  OPEN QUERY BR-pay-desk FOR EACH ub.inkas-pay-desk       WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code  AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code  AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK     BY ub.inkas-pay-desk.pay-code.
END.
ON ROW-DISPLAY OF BR-pay-desk IN FRAME DIALOG-1
DO:
    assign
      pay-desk-tot-rubl = 0
      .
  IF available ub.inkas-pay-desk THEN
  DO:
      pay-desk-tot-rubl = ub.inkas-pay-desk.tot-rubl .
      RUN autotank-inkas-pay-desk( input ub.inkas-pay-desk.inkas-code,
                                 input ub.inkas-pay-desk.pay-code ,
                                 input ub.inkas-pay-desk.curr-code ,
                                 input ub.inkas-pay-desk.pay-desk ,
                                 input ub.inkas-pay-desk.cashier ,
                                 input "autotank-sum-return":U    ,
                                 output a-sum-return)
       .
         assign
             pay-desk-tot-rubl = pay-desk-tot-rubl - a-sum-return
             .
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame DIALOG-1 anywhere
do:
  V-DOC-REC  = recid(inkas-pay).                reposition br-inkas-pay to recid v-doc-rec no-error. OPEN QUERY BR-pay-desk FOR EACH ub.inkas-pay-desk       WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code  AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code  AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK     BY ub.inkas-pay-desk.pay-code.
    apply "VALUE-CHANGED" to BR-cash-desk.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame DIALOG-1 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DIALOG-1 :height-chars)
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
    if frame DIALOG-1 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DIALOG-1 :height-chars)
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
            frame DIALOG-1 :height = v-frame-height
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
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
      v-frame-height = frame DIALOG-1 :height
      v-frame-virtual-height = frame DIALOG-1 :virtual-height
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
      v-field-group-handle = frame DIALOG-1 :first-child
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
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
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
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
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
          ,input  string(frame DIALOG-1 :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame DIALOG-1 :height)
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
    if frame DIALOG-1 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DIALOG-1 :width
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
    if frame DIALOG-1 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DIALOG-1 :width
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
            frame DIALOG-1 :width = v-frame-width
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
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
      v-frame-width = frame DIALOG-1 :width
      v-frame-virtual-width = frame DIALOG-1 :virtual-width
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
      v-field-group-handle = frame DIALOG-1 :first-child
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
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DIALOG-1 :width = v-frame-width + p-change-value
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
        frame DIALOG-1 :width = frame DIALOG-1 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
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
          ,input  string(frame DIALOG-1 :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame DIALOG-1 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DIALOG-1
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DIALOG-1 :height - v-diasize-resize-button :height
                  - 1
                  - (frame DIALOG-1 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DIALOG-1 :width - v-diasize-resize-button :width
                  - 1
                  - (frame DIALOG-1 :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame DIALOG-1
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
      v-row-delta = v-new-row - frame DIALOG-1 :height
      v-col-delta = v-new-col - frame DIALOG-1 :width
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
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DIALOG-1 :height-chars
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
      v-diasize-current-frame-width  = frame DIALOG-1 :width
      v-diasize-current-frame-height = frame DIALOG-1 :height
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
    do with frame DIALOG-1
    :
      assign
        v-diasize-orig-frame-height = frame DIALOG-1 :height
        v-diasize-orig-frame-width  = frame DIALOG-1 :width
        v-diasize-browse-handle     = browse BR-cash-desk :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DIALOG-1 :first-child
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
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame DIALOG-1 anywhere do:
  if b-EXIT :sensitive then DO: apply "CHOOSE":U to b-EXIT in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame DIALOG-1 anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame DIALOG-1. END.
  return no-apply.
end.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find ub.inkas where ub.inkas.inkas-code = inp-inkas-code no-lock no-error.
    if not available ub.inkas then
        do:
            message "Отчет по выручке пустой!" view-as alert-box WARNING.
            return.
        end.
        IF CAN-FIND(FIRST ub.cash-desk WHERE ub.cash-desk.db-num >=0
                       AND ub.cash-desk.obj-code = ub.inkas.obj-code
                       AND ub.cash-desk.pos-type = 'Autotank':U) THEN
            v-exist-autotank = YES .
        define variable v-curr-r-b as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
        FOR EACH ub.inkas-pay where ub.inkas-pay.inkas-code = ub.inkas.inkas-code no-lock:
            accumpay = accumpay + ROUND(if v-curr-r-b = 'base':U
                             then ub.inkas-pay.tot-base
                             else ub.inkas-pay.tot-rubl, 2) .
            RUN autotank-inkas-pay(input ub.inkas-pay.inkas-code  ,
                                   input ub.inkas-pay.pay-code    ,
                                   input ub.inkas-pay.curr-code   ,
                                   input "autotank-sum-return" ,
                                   output a-sum-return) .
            assign
                  accumpay = accumpay - a-sum-return
                  autotank-sum-return = autotank-sum-return - a-sum-return
                .
        END.
        assign
        f% = ub.inkas.discnt / ub.inkas.tot-doc * 100
        fnetto = ub.inkas.netto
        frame DIALOG-1:title =
            "Отчет о выручке: " + inp-inkas-code + ". Дата: " + string( ub.inkas.doc-date )
        g-discnt = ub.inkas.discnt .
        run get-inkas-ps in this-procedure (
                                            buffer ub.inkas
                                          , output chk-amount
                                          , output gds-amount
                                          , output line-out
                                          , output dtl-out
                                          , output line-ret
                                          , output dtl-ret
                                          , output nf-chk-amount
                                          , output nf-gds-amount
                                          , output ps-where-rus
                                          ).
  RUN fill-inkas-cash-desk IN THIS-PROCEDURE.
  RUN MYenable IN THIS-PROCEDURE.
  APPLY "VALUE-CHANGED" to BR-INKAS-PAY.
  WAIT-FOR GO OF FRAME DIALOG-1.
END.
RUN disable_UI.
PROCEDURE autotank-inkas-pay :
define input  PARAMETER i-code    as CHARACTER no-undo .
define input  parameter p-code    as INTEGER   no-undo .
define input  parameter c-code    as INTEGER   no-undo .
define input  PARAMETER a-code    as CHARacter no-undo .
define output PARAMETER a-return  as DECImal   no-undo .
define BUFFER buf_inkas        FOR ub.inkas .
define BUFFER buf_chk-pay      FOR ub.chk-pay .
define BUFFER buf_chk-pay-attr FOR ub.chk-pay-attr .
assign
    a-return = 0
    .
FIND FIRST buf_inkas NO-LOCK WHERE buf_inkas.inkas-code = i-code NO-ERROR.
IF available buf_inkas THEN
DO:
    FOR EACH buf_chk-pay NO-LOCK where buf_chk-pay.out-code = buf_inkas.inkas-code
                               AND  buf_chk-pay.pay-code = p-code
                               AND  buf_chk-pay.curr-code = c-code,
        FIRST buf_chk-pay-attr NO-LOCK WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                 AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                 AND buf_chk-pay-attr.attr-code = a-code :
       a-return = a-return + decimal(buf_chk-pay-attr.attr-value) .
    END.
END.
END PROCEDURE.
PROCEDURE autotank-inkas-pay-desk :
define input  parameter i-code   as character no-undo .
define input  parameter p-code   as integer   no-undo .
define input  parameter c-code   as integer   no-undo .
define input  parameter p-desk   as integer   no-undo .
define input  parameter ccashier as integer   no-undo .
define input  parameter a-code   as character no-undo .
define output parameter a-return as decimal   no-undo .
define BUFFER buf_inkas        FOR ub.inkas .
define BUFFER buf_chk-pay      FOR ub.chk-pay .
define BUFFER buf_chk-pay-attr FOR ub.chk-pay-attr .
define BUFFER buf_chk-doc      FOR ub.chk-doc .
assign
    a-return = 0
    .
FIND FIRST buf_inkas NO-LOCK WHERE buf_inkas.inkas-code = i-code NO-ERROR.
IF available buf_inkas THEN
DO:
    FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas.inkas-code
                              AND buf_chk-doc.pay-desk = p-desk
                              AND buf_chk-doc.cashier = ccashier,
        EACH buf_chk-pay NO-LOCK where buf_chk-pay.doc-code = buf_chk-doc.doc-code
                               AND  buf_chk-pay.pay-code = p-code
                               AND  buf_chk-pay.curr-code = c-code,
        FIRST buf_chk-pay-attr NO-LOCK WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                 AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                 AND buf_chk-pay-attr.attr-code = a-code:
       a-return = a-return + DECI(buf_chk-pay-attr.attr-value) .
    END.
END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f% f-num-chk g-discnt autotank-sum-return fnetto accumpay
      WITH FRAME DIALOG-1.
  IF AVAILABLE ub.inkas THEN
    DISPLAY ub.inkas.tot-doc ub.inkas.num-chk ub.inkas.discnt ub.inkas.sub-discnt
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-print B-help BR-INKAS-PAY BR-pay-desk BR-cash-desk
      WITH FRAME DIALOG-1.
  OPEN QUERY BR-cash-desk FOR EACH temp-inkas-cash-desk.    OPEN QUERY BR-INKAS-PAY FOR EACH ub.inkas-pay       WHERE ub.inkas-pay.inkas-code = inp-inkas-code NO-LOCK,       FIRST ub.cash-pay WHERE ub.cash-pay.cdpay-code = ub.inkas-pay.pay-code AND ub.cash-pay.curr-code = ub.inkas-pay.curr-code NO-LOCK,       FIRST ub.currency WHERE ub.currency.curr-code = ub.inkas-pay.curr-code NO-LOCK.    OPEN QUERY BR-pay-desk FOR EACH ub.inkas-pay-desk       WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code  AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code  AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK     BY ub.inkas-pay-desk.pay-code.
END PROCEDURE.
PROCEDURE fill-inkas-cash-desk :
define BUFFER buf_temp-inkas-cash-desk FOR temp-inkas-cash-desk .
define BUFFER buf_inkas-pay-desk       FOR ub.inkas-pay-desk .
define BUFFER buf_inkas-pay-desk-attr  FOR ub.inkas-pay-desk-attr .
for each buf_temp-inkas-cash-desk :
  delete buf_temp-inkas-cash-desk .
end.
FOR EACH buf_inkas-pay-desk NO-LOCK WHERE
buf_inkas-pay-desk.inkas-code = inp-inkas-code
BREAK BY buf_inkas-pay-desk.pay-desk:
  FIND FIRST buf_temp-inkas-cash-desk WHERE
        buf_temp-inkas-cash-desk.inkas-code = buf_inkas-pay-desk.inkas-code
    AND buf_temp-inkas-cash-desk.pay-desk = buf_inkas-pay-desk.pay-desk NO-ERROR.
  IF NOT AVAILABLE buf_temp-inkas-cash-desk THEN DO:
      CREATE buf_temp-inkas-cash-desk.
      assign
          buf_temp-inkas-cash-desk.inkas-code = buf_inkas-pay-desk.inkas-code
          buf_temp-inkas-cash-desk.pay-desk = buf_inkas-pay-desk.pay-desk.
  END.
  assign
  buf_temp-inkas-cash-desk.tot-base = buf_temp-inkas-cash-desk.tot-base + buf_inkas-pay-desk.tot-base
  buf_temp-inkas-cash-desk.tot-rubl = buf_temp-inkas-cash-desk.tot-rubl + buf_inkas-pay-desk.tot-rubl
  .
  IF buf_inkas-pay-desk.doc-type <> '':U THEN
   RUN autotank-inkas-pay-desk( input buf_inkas-pay-desk.inkas-code,
                                input buf_inkas-pay-desk.pay-code ,
                                input buf_inkas-pay-desk.curr-code ,
                                input buf_inkas-pay-desk.pay-desk ,
                                input buf_inkas-pay-desk.cashier ,
                                input "autotank-sum-return":U    ,
                                output a-sum-return)
      .
      assign
      buf_temp-inkas-cash-desk.tot-rubl-return = buf_temp-inkas-cash-desk.tot-rubl-return
          - a-sum-return
      .
END.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer buf_sale-doc for ub.sale-doc.
define variable v-hdl as HANDLE no-undo .
find first BUF_sale-doc no-lock where
          buf_sale-doc.inkas-code = inp-inkas-code
      and buf_sale-doc.doc-kind = 'trf':U no-error .
assign
f-num-chk = inkas.num-chk - nf-chk-amount - (if available buf_sale-doc
                                             then buf_sale-doc.chk-amount
                                             else 0).
find first BUF_sale-doc no-lock where
          buf_sale-doc.inkas-code = inp-inkas-code
      and buf_sale-doc.doc-kind = 'swo':U no-error .
assign
f-num-chk = inkas.num-chk - nf-chk-amount - (if available buf_sale-doc
                                             then buf_sale-doc.chk-amount
                                             else 0).
assign
temp-inkas-cash-desk.tot-rubl:LABEL IN BROWSE br-cash-desk = 'Руб.эквивалент'
ub.inkas-pay.tot-rubl:LABEL IN BROWSE br-inkas-pay = 'Руб.эквивалент'
ub.inkas-pay-desk.tot-rubl:LABEL IN BROWSE br-pay-desk = 'Руб.эквивалент'
.
DISPLAY
f%
f-num-chk
g-discnt
autotank-sum-return
fnetto
accumpay
WITH FRAME DIALOG-1.
IF AVAILABLE ub.inkas THEN
DISPLAY
ub.inkas.num-chk
ub.inkas.tot-doc
ub.inkas.discnt
ub.inkas.sub-discnt
WITH FRAME DIALOG-1.
IF v-exist-autotank = NO THEN
DO:
 assign
  autotank-sum-return:HIDDEN = YES
  autotank-sum-return:VISIBLE = NO
     .
  v-hdl = br-inkas-pay:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
  v-hdl = br-pay-desk:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
  v-hdl = br-cash-desk:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
END.
ENABLE
b-exit
b-print
B-help
BR-INKAS-PAY
BR-pay-desk
BR-cash-desk
WITH FRAME DIALOG-1.
OPEN QUERY BR-cash-desk FOR EACH temp-inkas-cash-desk.    OPEN QUERY BR-INKAS-PAY FOR EACH ub.inkas-pay       WHERE ub.inkas-pay.inkas-code = inp-inkas-code NO-LOCK,       FIRST ub.cash-pay WHERE ub.cash-pay.cdpay-code = ub.inkas-pay.pay-code AND ub.cash-pay.curr-code = ub.inkas-pay.curr-code NO-LOCK,       FIRST ub.currency WHERE ub.currency.curr-code = ub.inkas-pay.curr-code NO-LOCK.    OPEN QUERY BR-pay-desk FOR EACH ub.inkas-pay-desk       WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code  AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code  AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK     BY ub.inkas-pay-desk.pay-code.
END PROCEDURE.
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input p-pay-code as integer, input p-curr-code as integer ) :
define buffer buf_cash-pay for ub.cash-pay.
find first buf_cash-pay no-lock where
            buf_cash-pay.curr-code = p-curr-code
        AND buf_cash-pay.cdpay-code  = p-pay-code
            no-error.
  if available buf_cash-pay then do:
      return buf_cash-pay.obj-name.
  end.
  RETURN chr(63).
END FUNCTION.
FUNCTION get-chk-type RETURNS CHARACTER
  ( input par-doc-type as character ) :
 if par-doc-type = 'при':U then return "Продажа".
 RETURN "Возврат".
END FUNCTION.
FUNCTION get-currency RETURNS CHARACTER
  ( input p-curr-code as integer ) :
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
if available buf_currency then do:
    return buf_currency.curr-abbr.
end.
  RETURN chr(63).
END FUNCTION.
