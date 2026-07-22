define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.goods.gds-code .
define input parameter p-b-code   like ub.bar-code.b-code .
define parameter buffer p-ink-doc for ub.inkas.
define output parameter p-to-reserv as logical no-undo .
define variable v-sum-chk-gds-doc-qnty as decimal no-undo.
define variable v-TOTAL-pl-gds-fact-qnty as decimal no-undo.
define variable v-TOTAL-rvs-stt-msr-qnty as decimal no-undo.
define variable v-TOTAL-chk-gds-doc-qnty as decimal no-undo.
define variable v-TOTAL-distrib-selling   as decimal no-undo.
define variable v-TOTAL-realize as decimal no-undo.
define variable v-tmp-dec as decimal no-undo .
define variable v-order   as integer no-undo.
define variable v-cur-row as rowid no-undo.
define variable v-rvs-rec as recid no-undo.
define temp-table tt-places
    field pump-code         like ub.pl-pump.pump-code
    field pl-code           like ub.place.pl-code
    field pl-name           like ub.place.pl-name
    field loc1              like ub.place.loc1
    field pl-gds-fact-qnty  like ub.pl-gds.fact-qnty
    field chk-gds-doc-qnty  like ub.chk-gds.doc-qnty
    field rvs-stt-msr-qnty  like ub.rvs-line.state-measure-qnty
    field distrib-selling   as   decimal
    field order             as   integer
    index pi as primary unique
        pl-code
    index order
        order
.
define temp-table tt-pl-pump
    field pump-code          like ub.pl-pump.pump-code
    field pl-gds-fact-qnty   as decimal
    field rvs-stt-msr-qnty   as decimal
    field chk-gds-doc-qnty   as decimal
    index pi as primary unique
        pump-code
.
define temp-table tt-chk-to-reload
    field doc-code like ub.chk-doc.doc-code
    index pi as primary unique
        doc-code
.
define temp-table tt-chk-gds-change-pl
    field doc-code      like ub.chk-gds.doc-code
    field line-num      like ub.chk-gds.line-num
    field new-pl-code   like ub.chk-gds.pl-code
    field new-loc1      like ub.chk-gds.loc1
    field new-loc2      like ub.chk-gds.loc2
    field new-loc3      like ub.chk-gds.loc3
    field new-loc4      like ub.chk-gds.loc4
    field order         as integer
    index pi as primary unique
        doc-code line-num
    index order
        order
.
define buffer buf_rvs-doc for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_pl-gds-pump for ub.pl-gds-pump .
define buffer buf_chk-gds for ub.chk-gds .
define buffer buf_chk-doc for ub.chk-doc .
DEFINE NEW SHARED BUFFER X_chk-doc FOR chk-doc.
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.
define stream OutStr-html.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
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
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-rvs
     LABEL "&Сверка :"
     SIZE 10 BY 1.
define variable txt-rvs as character format "X(18)"
     view-as text
     size 18 by 1
     fgcolor 4 no-undo.
DEFINE BUTTON b-sel-rvs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.88 BY 1.
DEFINE QUERY br-places FOR
      tt-places   SCROLLING.
define browse br-places
query br-places no-lock display
    tt-places.pl-code          COLUMN-LABEL "Скл.место" FORMAT "999999999":U
    tt-places.pl-name          COLUMN-LABEL "Наименование резервуара" FORMAT "X(25)"
    tt-places.loc1             COLUMN-LABEL "Номер!резервуара"  FORMAT "X(8)"
    tt-places.pl-gds-fact-qnty COLUMN-LABEL "Расчетно-книжный!остаток" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.chk-gds-doc-qnty COLUMN-LABEL "Текущее распреде-!ление продажи" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.rvs-stt-msr-qnty COLUMN-LABEL "Фактический остаток" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.distrib-selling  COLUMN-LABEL " Распределение !реализации" FORMAT "->>,>>>,>>9.<<<":U
enable
    tt-places.distrib-selling
    WITH NO-ROW-MARKERS SEPARATORS SIZE 117 BY 8.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1 WIDGET-ID 2
     b-cancel AT ROW 1 COL 11 WIDGET-ID 4
     b-print AT ROW 1 COL 114 WIDGET-ID 6
     b-rvs at row 2 col 1 widget-id 10
     txt-rvs at row 2 col 11 no-label  widget-id 12
     b-sel-rvs at row 2 col 29 widget-id 14
     br-places at row 3 col 1 widget-id 8
     SPACE(0.00) SKIP(0.1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Распределение продажи по местам хранения"
         CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
  return "cancell":U .
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
    run PrintProc.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
    browse br-places:refresh ().
    for each tt-pl-pump no-lock :
        assign v-TOTAL-distrib-selling = 0.0 .
        for each tt-places  no-lock
           where tt-places.pump-code = tt-pl-pump.pump-code
        :
            if tt-places.distrib-selling = ? then assign tt-places.distrib-selling = 0.0 .
            assign
                v-TOTAL-distrib-selling = v-TOTAL-distrib-selling + tt-places.distrib-selling
            .
        end.
        if tt-pl-pump.chk-gds-doc-qnty <> v-TOTAL-distrib-selling then do :
            message "Распределение реализации не соответствует сумме по чекам (в разрезе ТРК)"
                    view-as alert-box
            .
            return no-apply.
        end.
    end.
    define variable v-CUR-chk-gds-qnty as decimal no-undo.
    define variable v-CUR-distrib as decimal no-undo.
    define variable v-CUR-tt-chk as integer no-undo init 0.
    for each tt-pl-pump no-lock :
        assign
            v-CUR-distrib = 0.0
            v-CUR-chk-gds-qnty = 0.0
        .
        places :
        for each tt-places  no-lock
           where tt-places.pump-code = tt-pl-pump.pump-code
           use-index order
           by order
            :
                if tt-places.distrib-selling = 0 then next places .
                assign v-CUR-distrib = v-CUR-distrib + tt-places.distrib-selling .
                for each tt-chk-gds-change-pl where tt-chk-gds-change-pl.order > v-CUR-tt-chk
                    use-index order
                    by order
                :
                    find first buf_chk-gds no-lock
                         where buf_chk-gds.doc-code = tt-chk-gds-change-pl.doc-code
                           and buf_chk-gds.line-num = tt-chk-gds-change-pl.line-num .
                    if (v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty) >= v-CUR-distrib then do :
                        if ABS(v-CUR-distrib - v-CUR-chk-gds-qnty) <=
                           ABS(v-CUR-distrib - v-CUR-chk-gds-qnty - buf_chk-gds.doc-qnty) then do :
                               assign v-CUR-tt-chk = tt-chk-gds-change-pl.order - 1 .
                               next places .
                        end.
                        assign
                            v-CUR-tt-chk = tt-chk-gds-change-pl.order
                            v-CUR-chk-gds-qnty = v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty
                        .
                        if buf_chk-gds.pl-code = tt-places.pl-code then do :
                            delete tt-chk-gds-change-pl .
                        end.
                        else do :
                            find first buf_place no-lock
                                 where buf_place.obj-type = p-ink-doc.obj-type
                                   and buf_place.obj-code = p-ink-doc.obj-code
                                   and buf_place.pl-code  = tt-places.pl-code .
                            assign
                                tt-chk-gds-change-pl.new-pl-code = buf_place.pl-code
                                tt-chk-gds-change-pl.new-loc1    = buf_place.loc1
                                tt-chk-gds-change-pl.new-loc2    = buf_place.loc2
                                tt-chk-gds-change-pl.new-loc3    = buf_place.loc3
                                tt-chk-gds-change-pl.new-loc4    = buf_place.loc4
                            .
                            find first tt-chk-to-reload where tt-chk-to-reload.doc-code = buf_chk-gds.doc-code no-error.
                            if not available tt-chk-to-reload then do:
                                create tt-chk-to-reload .
                                assign tt-chk-to-reload.doc-code = buf_chk-gds.doc-code .
                            end.
                        end.
                        next places .
                    end.
                    else do :
                        assign v-CUR-chk-gds-qnty = v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty .
                        if buf_chk-gds.pl-code = tt-places.pl-code then do :
                            delete tt-chk-gds-change-pl .
                        end.
                        else do :
                            find first buf_place no-lock
                                 where buf_place.obj-type = p-ink-doc.obj-type
                                   and buf_place.obj-code = p-ink-doc.obj-code
                                   and buf_place.pl-code  = tt-places.pl-code .
                            assign
                                tt-chk-gds-change-pl.new-pl-code = buf_place.pl-code
                                tt-chk-gds-change-pl.new-loc1    = buf_place.loc1
                                tt-chk-gds-change-pl.new-loc2    = buf_place.loc2
                                tt-chk-gds-change-pl.new-loc3    = buf_place.loc3
                                tt-chk-gds-change-pl.new-loc4    = buf_place.loc4
                            .
                            find first tt-chk-to-reload where tt-chk-to-reload.doc-code = buf_chk-gds.doc-code no-error.
                            if not available tt-chk-to-reload then do:
                                create tt-chk-to-reload .
                                assign tt-chk-to-reload.doc-code = buf_chk-gds.doc-code .
                            end.
                        end.
                    end.
                end.
        end.
    end.
    if can-find(first tt-chk-gds-change-pl) and can-find(first tt-chk-to-reload)
    then do :
        run waitfram-show in this-procedure ( input "Ждите... " ) .
        run MainProc .
        run waitfram-hide in this-procedure .
    end.
    else do :
        message "Нет строк чеков для смены в них резервуара!" view-as alert-box .
        return "cancell":U .
    end.
END.
ON CHOOSE OF b-rvs IN FRAME Dialog-Frame
DO:
    assign v-rvs-rec = recid( buf_rvs-doc ).
    run str/rvs-doc.w
      ( input        parparentproc
       ,input        'ПРОСМОТР':U
       ,input        buf_rvs-doc.rvs-type
       ,input        no
       ,input-output v-rvs-rec
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
END.
ON CHOOSE OF b-sel-rvs IN FRAME Dialog-Frame
DO:
    run str/all-rvs.w (input parparentproc, input "choose-control", input ?, output v-rvs-rec).
    find first buf_rvs-doc no-lock where recid(buf_rvs-doc) = v-rvs-rec no-error.
    if available buf_rvs-doc then do :
        run upd-rvs-stt-msr-qnty.
        run calc-distrib-selling.
        run disp-rvs.
        open query br-places for each tt-places.
        APPLY "ENTRY" to br-places.
    end.
END.
on value-changed of br-places in frame Dialog-Frame
do:
    assign
        v-cur-row = rowid(tt-places)
    .
    for first tt-pl-pump no-lock where tt-pl-pump.pump-code = tt-places.pump-code :
        assign
            v-TOTAL-realize = tt-pl-pump.chk-gds-doc-qnty
            v-tmp-dec = 0.0
        .
        for each tt-places no-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            if rowid(tt-places) <> v-cur-row then
                assign v-TOTAL-realize = v-Total-realize - (if tt-places.distrib-selling <> ? then tt-places.distrib-selling else 0) .
        end.
        find first tt-places exclusive-lock where rowid(tt-places) = v-cur-row.
        assign tt-places.distrib-selling = v-TOTAL-realize.
    end.
    browse br-places:refresh ().
    open query br-places for each tt-places.
    reposition br-places to rowid v-cur-row.
    APPLY "ENTRY" to br-places.
end.
on leave of tt-places.distrib-selling in browse br-places
do:
    for first tt-pl-pump no-lock where tt-pl-pump.pump-code = tt-places.pump-code :
        assign tt-places.distrib-selling = if decimal(tt-places.distrib-selling:screen-value in browse br-places) = ?
                                           then tt-places.chk-gds-doc-qnty
                                           else if decimal(tt-places.distrib-selling:screen-value in browse br-places) <= tt-pl-pump.chk-gds-doc-qnty
                                           then decimal(tt-places.distrib-selling:screen-value in browse br-places)
                                           else tt-pl-pump.chk-gds-doc-qnty .
    end.
    browse br-places:refresh ().
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
  run find-rvs.
  run fill-tt.
  run upd-rvs-stt-msr-qnty.
  run calc-distrib-selling.
  run disp-rvs.
  RUN enable_UI.
  open query br-places for each tt-places.
  APPLY "ENTRY" to br-places.
  WAIT-FOR GO OF FRAME Dialog-Frame .
END.
RUN disable_UI.
Procedure find-rvs:
    for each buf_rvs-doc no-lock
       where buf_rvs-doc.obj-type   = p-ink-doc.obj-type
         and buf_rvs-doc.obj-code   = p-ink-doc.obj-code
         and buf_rvs-doc.shift-date = p-ink-doc.shift-date
         and buf_rvs-doc.shift-num  = p-ink-doc.shift-num
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.rvs-type   = 'контроль':U
         use-index shift-type
         by buf_rvs-doc.fact-order descending
         :
             find first buf_rvs-line no-lock
                  where buf_rvs-line.gds-code = p-gds-code
                    and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code no-error.
             if not available buf_rvs-line then next.
             else leave.
    end.
    if not available buf_rvs-line then do :
        message "      Для данного топлива не было контрольной сверки в этой смене.
                 Выберите другую сверку или заполните данные по распределению вручную."
                 view-as alert-box.
    end.
end procedure.
Procedure disp-rvs :
    if available buf_rvs-doc then do :
        display (" № " + buf_rvs-doc.rvs-code) @ txt-rvs with frame Dialog-Frame.
        enable b-rvs with frame Dialog-Frame.
    end.
end procedure.
Procedure fill-tt:
    assign
        v-TOTAL-pl-gds-fact-qnty = 0.0
        v-TOTAL-chk-gds-doc-qnty = 0.0
        v-order = 0
    .
    for each buf_pl-gds no-lock
       where buf_pl-gds.gds-code = p-gds-code
         and buf_pl-gds.obj-type = p-ink-doc.obj-type
         and buf_pl-gds.obj-code = p-ink-doc.obj-code
        ,
       first buf_place no-lock
       where buf_place.obj-type = buf_pl-gds.obj-type
         and buf_place.obj-code = buf_pl-gds.obj-code
         and buf_place.pl-code  = buf_pl-gds.pl-code
        ,
       first buf_pl-gds-pump no-lock
       where buf_pl-gds-pump.obj-type = buf_pl-gds.obj-type
         and buf_pl-gds-pump.obj-code = buf_pl-gds.obj-code
         and buf_pl-gds-pump.pl-code  = buf_pl-gds.pl-code
         and buf_pl-gds-pump.gds-code = buf_pl-gds.gds-code
         :
             find first tt-pl-pump where tt-pl-pump.pump-code = buf_pl-gds-pump.pump-code no-error.
             if not available tt-pl-pump then do :
                 create tt-pl-pump no-error.
                 assign tt-pl-pump.pump-code = buf_pl-gds-pump.pump-code.
             end.
             assign v-sum-chk-gds-doc-qnty = 0.0 .
             for each buf_chk-gds no-lock
                where buf_chk-gds.b-code   = p-b-code
                  and buf_chk-gds.pl-code  = buf_pl-gds.pl-code
                  and buf_chk-gds.out-code = p-ink-doc.inkas-code
                  :
                      assign
                        v-sum-chk-gds-doc-qnty = v-sum-chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                        v-TOTAL-chk-gds-doc-qnty = v-TOTAL-chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                        tt-pl-pump.chk-gds-doc-qnty = tt-pl-pump.chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                      .
                      assign v-order = v-order + 1 .
                      create tt-chk-gds-change-pl .
                      assign tt-chk-gds-change-pl.doc-code    = buf_chk-gds.doc-code
                             tt-chk-gds-change-pl.line-num    = buf_chk-gds.line-num
                             tt-chk-gds-change-pl.order       = v-order
                      .
             end.
             create tt-places no-error.
             assign tt-places.pump-code = buf_pl-gds-pump.pump-code
                    tt-places.pl-code   = buf_place.pl-code
                    tt-places.pl-name   = buf_place.pl-name
                    tt-places.loc1      = buf_place.loc1
                    tt-places.pl-gds-fact-qnty = buf_pl-gds.fact-qnty
                    tt-places.chk-gds-doc-qnty = v-sum-chk-gds-doc-qnty
                    tt-places.order     = if buf_pl-gds-pump.status_ = 'тек':U then 1 else 2
             .
             assign
                v-TOTAL-pl-gds-fact-qnty = v-TOTAL-pl-gds-fact-qnty + tt-places.pl-gds-fact-qnty
                tt-pl-pump.pl-gds-fact-qnty = tt-pl-pump.pl-gds-fact-qnty + tt-places.pl-gds-fact-qnty
             .
             release tt-places no-error.
    end.
End procedure.
Procedure upd-rvs-stt-msr-qnty :
    if available buf_rvs-doc then do :
        assign
            v-TOTAL-rvs-stt-msr-qnty = 0.0
        .
        for each tt-pl-pump exclusive-lock :
            assign tt-pl-pump.rvs-stt-msr-qnty = 0.0 .
            for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code  :
               assign tt-places.rvs-stt-msr-qnty = 0.0 .
               find first buf_rvs-line no-lock
                    where buf_rvs-line.gds-code = p-gds-code
                      and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                      and buf_rvs-line.pl-code  = tt-places.pl-code no-error.
               if available buf_rvs-line then
                   assign
                       tt-places.rvs-stt-msr-qnty = buf_rvs-line.state-measure-qnty
                       v-TOTAL-rvs-stt-msr-qnty = v-TOTAL-rvs-stt-msr-qnty + buf_rvs-line.state-measure-qnty
                       tt-pl-pump.rvs-stt-msr-qnty = tt-pl-pump.rvs-stt-msr-qnty + buf_rvs-line.state-measure-qnty
                   .
            end.
        end.
    end.
end procedure.
Procedure calc-distrib-selling :
    for each tt-pl-pump no-lock :
        v-tmp-dec = 0.0 .
        for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            assign
                tt-places.distrib-selling = tt-places.pl-gds-fact-qnty - ((tt-places.rvs-stt-msr-qnty / tt-pl-pump.rvs-stt-msr-qnty) *
                                                                          (tt-pl-pump.pl-gds-fact-qnty - tt-pl-pump.chk-gds-doc-qnty))
                tt-places.distrib-selling = if tt-places.distrib-selling <> ?
                                             then tt-places.distrib-selling else tt-places.chk-gds-doc-qnty
            .
            if tt-places.distrib-selling < 0 then v-tmp-dec = tt-places.distrib-selling .
        end.
        if v-tmp-dec <> 0.0 then
        for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            assign
                tt-places.distrib-selling = abs(tt-places.distrib-selling) - v-tmp-dec
            .
        end.
    end.
end procedure.
PROCEDURE PrintProc :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + "rpt" +  "sale-plc1.html".
    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:210px"></td>
                        <td style="width:70px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Распределение топлива по местам хранения</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Складское место</th>
                <th>Наименование резервуара</th>
                <th>Номер резервуара</th>
                <th>Расчетно-книжный остаток</th>
                <th>Текущее распределение продажи</th>
                <th>Фактический остаток</th>
                <th>Распределение реализации</th>
                </tr>').
    get first br-places.
    do while available  tt-places:
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',
            tt-places.pl-code,
            tt-places.pl-name,
            tt-places.loc1,
            tt-places.pl-gds-fact-qnty,
            tt-places.chk-gds-doc-qnty,
            tt-places.rvs-stt-msr-qnty,
            tt-places.distrib-selling
            ).
        get next br-places.
    end.
    run waitfram-hide in this-procedure.
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
END PROCEDURE.
Procedure MainProc :
    define  variable old-netto as decimal no-undo.
    define  variable old-tot-doc as decimal no-undo.
    define  variable old-discnt as decimal no-undo.
    define variable v-curr-r-b as character no-undo .
    define buffer buf_sysconf for ub.sysconf.
    DEFINE                BUFFER ret-doc    FOR trn-doc.
    DEFINE                BUFFER r-doc      FOR chk-doc.
    DEFINE                BUFFER r-gds      FOR chk-gds.
    define variable v-ref-rec  as recid no-undo .
    define variable v-base-code  like ub.sysconf.base-code no-undo .
    define variable v-cash-pay   like ub.sysconf.cash-pay  no-undo .
    define variable temp-qnty like gds-dtl.fact-qnty no-undo .
    define variable temp-qnty-prts like gds-dtl.fact-qnty no-undo .
    define variable prev-code like chk-gds.doc-code no-undo .
    define variable for-shift-name AS character.
    define variable for-shift-num like chk-doc.shift-num.
    define variable for-shift-date like chk-doc.shift-date.
    define variable serv-elm as logical no-undo init no.
    define variable cas-shft as logical no-undo init no.
    define variable one-sale-per-day as logical no-undo .
    define variable l-shift-on as logical no-undo init no.
    define variable one-curs as logical no-undo init no.
    define variable cas-curs as logical no-undo init no.
    define variable prcl-spl as logical no-undo init no.
    define variable pay-gds-algo as character no-undo .
    define variable rdtaxcd  as INTEGER                  no-undo.
    define variable exctaxcd  as INTEGER                  no-undo.
    define variable factorrt as decimal no-undo.
    define variable btltaxcd  as INTEGER                  no-undo.
    define variable conf-attr as char no-undo.
    define variable conf-par as char no-undo.
    define variable par-type as char no-undo.
    define variable cursh like curr-shop.exch-rate init 0.
    define variable cursh-scale like curr-shop.exch-rate.
    define variable v-rid-list as character no-undo init "".
    define buffer buf_inkas for ub.inkas .
    define variable ps-where-rus as character no-undo .
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    assign v-tth = buffer thbjattr_thbj-attr:table-handle .
    DEFINE VARIABLE gds-amount AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE chk-amount AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE dtl-out AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE dtl-ret AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE line-out AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE line-ret AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE nf-chk-amount AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE nf-gds-amount AS INTEGER INITIAL 0 NO-UNDO.
    define variable v-ii     as integer no-undo .
    define variable v-ii-ok  as integer no-undo .
    define variable v-rc-ii as integer no-undo .
    define variable v-rc-max as integer no-undo .
    define variable v-error-status as logical no-undo .
    define variable v-error-status-message as character no-undo .
    assign
        rdtaxcd  = integer('3':U)
        exctaxcd = integer('4':U)
        btltaxcd = integer('3':U)
    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'factorrt'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
    if NOT error-status:error then
    factorrt = decimal(conf-par).
    if rdtaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = rdtaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден дорожный налог!" view-as alert-box ERROR.
          return error.
      end.
    end.
    if exctaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = exctaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден акциз!" view-as alert-box ERROR.
          return error.
      end.
    end.
    if btltaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = btltaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
          return error.
      end.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'serv-elm'
  ,input  p-ink-doc.host-code
  ,input  p-ink-doc.obj-type
  ,input  p-ink-doc.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
    IF not error-status:error then
    assign
    serv-elm = (conf-par = "yes").
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
      input "get":U
     ,input  p-ink-doc.obj-type
     ,input  p-ink-doc.obj-code
     ,input  'get-chk':U
     ,input  "":U
     , output v-value-character
     , output v-value-date
     , output v-value-decimal
     , output v-value-integer
     , output v-value-logical
     , output v-param-type
     , INPUT-OUTPUT table-handle v-tth
    ) no-error .
    IF error-status:error then do:
       message
       substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
       , p-ink-doc.obj-type
       , p-ink-doc.obj-code
       , chr(10)
       , error-status:get-message(1)
       , return-value )
       view-as alert-box error .
       undo, return error .
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
           and thbjattr_thbj-attr.prop-code = 'cas-shft':U no-error.
    if available thbjattr_thbj-attr then do:
        cas-shft = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
           and thbjattr_thbj-attr.prop-code = 'cas-curs':U no-error.
    if available thbjattr_thbj-attr then do:
        cas-curs = thbjattr_thbj-attr.property-value-logical.
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-ink-doc.obj-type
  ,input  p-ink-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on and not cas-shft then do:
            message "Внимание! На текущем объекте требуется использование смен" skip
         "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
              view-as alert-box ERROR.
      return ERROR.
    end.
    run adm/shattri.p (
      input "get":U
      ,input  p-ink-doc.obj-type
      ,input  p-ink-doc.obj-code
      ,input  'autosale':U
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
    IF error-status:error then do:
       message
       substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
       , p-ink-doc.obj-type
       , p-ink-doc.obj-code
       , chr(10)
       , error-status:get-message(1)
       , return-value )
       view-as alert-box error .
       undo, return error .
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
           and thbjattr_thbj-attr.prop-code = 'prcl-spl':U no-error.
    if available thbjattr_thbj-attr then do:
        prcl-spl = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
           and thbjattr_thbj-attr.prop-code = 'one-curs':U no-error.
    if available thbjattr_thbj-attr then do:
      one-curs = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
        and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'one-sale-per-day':U no-error.
    if available thbjattr_thbj-attr then do:
        assign
          one-sale-per-day = thbjattr_thbj-attr.property-value-logical
        .
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
           and thbjattr_thbj-attr.prop-code = 'pay-gds-algo':U no-error.
    if available thbjattr_thbj-attr then do:
        assign
          pay-gds-algo = thbjattr_thbj-attr.property-value-character
        .
    end.
    find first buf_sysconf no-lock where buf_sysconf.host-code = p-ink-doc.host-code.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-ink-doc.host-code
  ,output v-base-code
  )  .
    FIND FIRST shop WHERE shop.obj-code = p-ink-doc.obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = p-ink-doc.inkas-code.
    FIND FIRST ret-doc no-lock WHERE ret-doc.doc-code = trn-doc.out-code no-error .
    assign
        cursh = trn-doc.exch-rate
        cursh-scale = trn-doc.exch-scale
    .
    run get-inkas-ps in this-procedure (
                                        buffer p-ink-doc
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
    for each tt-chk-to-reload no-lock :
        find first buf_chk-doc where buf_chk-doc.doc-code = tt-chk-to-reload.doc-code .
        assign
           v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + string(recid(buf_chk-doc))
        .
        FIND FIRST buf_inkas No-LOCK WHERE
                          buf_inkas.inkas-code = buf_chk-doc.out-code No-ERROR.
        assign
            old-netto = buf_inkas.netto
            old-tot-doc = buf_inkas.tot-doc
            old-discnt = buf_inkas.discnt
        .
        run str/excl-chk.p (
                             input parparentproc
                           , input v-curr-r-b
                           , buffer buf_chk-doc) no-error.
        if error-status:error OR
          buf_inkas.netto <> old-netto  - buf_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - buf_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - buf_chk-doc.discnt then do:
            message
            substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,buf_chk-doc.doc-code
                     ,p-ink-doc.inkas-code
                     , chr(10)
                     ,error-status:get-message(1)
                     ,return-value
                     )
            view-as alert-box ERROR.
            undo, NEXT.
        end.
    end.
    for each tt-chk-gds-change-pl no-lock :
        find first buf_chk-gds exclusive-lock
             where buf_chk-gds.doc-code = tt-chk-gds-change-pl.doc-code
               and buf_chk-gds.line-num = tt-chk-gds-change-pl.line-num .
        assign
            buf_chk-gds.pl-code = tt-chk-gds-change-pl.new-pl-code
            buf_chk-gds.loc1    = tt-chk-gds-change-pl.new-loc1
            buf_chk-gds.loc2    = tt-chk-gds-change-pl.new-loc2
            buf_chk-gds.loc3    = tt-chk-gds-change-pl.new-loc3
            buf_chk-gds.loc4    = tt-chk-gds-change-pl.new-loc4
        .
        release buf_chk-gds .
    end.
    assign
        v-rc-max = num-entries(v-rid-list)
    .
    _v-rc:
    do while v-rc-ii < v-rc-max:
        assign
        v-rc-ii = v-rc-ii + 1
        .
        find first X_chk-doc exclusive-lock where
                  recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
        if locked X_chk-doc or not available X_chk-doc then do:
           next _v-rc.
        end.
        else leave _v-rc.
    end.
    if not available X_chk-doc
    or locked(X_chk-doc) then do:
        message
        "Ни один из чеков не может быть сейчас перезакачан в продажу" skip
        "Возможно они заняты другим пользователем"
        view-as alert-box Warning.
        return.
    end.
    run str/inc-salr.p (
                 input  parparentproc
                ,input  this-procedure
                ,input-output v-ii
                ,input-output v-ii-ok
                ,input  no
                ,input  ""
                ,INPUT  v-rid-list
                ,input  p-ink-doc.obj-type
                ,input  p-ink-doc.obj-code
                ,input  v-curr-r-b
                ,input  no
                ,input  cas-shft
                ,input  one-curs
                ,input  cas-curs
                ,input  cursh
                ,input  cursh-scale
                ,input  prcl-spl
                ,input  pay-gds-algo
                ,input  rdtaxcd
                ,input  exctaxcd
                ,input  factorrt
                ,input  btltaxcd
                ,input  gds-amount
                ,input  chk-amount
                ,input  line-out
                ,input  line-ret
                ,input  dtl-out
                ,input  dtl-ret
                ,input  nf-chk-amount
                ,input  nf-gds-amount
                ,input  shop.day-only
                ,input  p-ink-doc.doc-date
                ,input  p-ink-doc.shift-date
                ,input  p-ink-doc.shift-num
                ,input  p-ink-doc.doc-date
                ,input  p-ink-doc.shift-date
                ,input  p-ink-doc.shift-num
                ,buffer p-ink-doc
                ,buffer trn-doc
                ,buffer ret-doc
                ,buffer buf_sysconf
    ) NO-ERROR.
    assign
        v-error-status = error-status:error
        v-error-status-message = error-status:get-message(1)
    .
    if v-ii = 0 then do:
        if v-error-status then
        message
        "Произошла ошибка при перезакачке чеков в продажу" skip
        v-error-status-message skip
        return-value
        view-as alert-box .
        else
        message
        "Нет чеков, удовлетворяющих условиям перезакачки в продажу" skip
        view-as alert-box WARNING .
        assign p-to-reserv = no .
    end.
    else do:
        message
        substitute("Просмотрено &1 чеков, успешно перезакачано в продажу &2", v-ii, v-ii-ok)
        view-as alert-box WARNING .
        assign p-to-reserv = yes .
    end.
end procedure.
procedure display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .
end procedure.
PROCEDURE display-ink-doc :
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-save b-cancel b-print br-places b-sel-rvs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
