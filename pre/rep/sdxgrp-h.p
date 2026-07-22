block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-xl-delim as character no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as char no-undo .
define input parameter byobject as logical no-undo .
define input parameter WHStart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter RETS as logical no-undo.
define input parameter TREE as logical no-undo.
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sdxgrp-h.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/sdxgrp-h.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по величинам сумм продаж вывод в  EXCEL  опция по чекам ".
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
def
 shared
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED temp-table grp-h no-undo
    field obj-code like ub.clients.obj-code
    field grp-code like ub.goods.grp-code
    field other-code as integer
    field num-chk   like ub.inkas.num-chk extent 24
    field sum1 like ub.chk-doc.netto
    INDEX pi IS PRIMARY obj-code grp-code other-code sum1 ASCENDING
 .
DEFINE SHARED temp-table sum-vals no-undo
    field sum1   like ub.chk-doc.netto
    field sum2   like ub.chk-doc.netto
    field num-chk   like ub.inkas.num-chk extent 24
    field tot like ub.inkas.num-chk
    INDEX pi IS PRIMARY sum1 ASCENDING .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE   temp-table full-grp no-undo
    field obj-code like ub.clients.obj-code
    field grp-code like ub.gds-grp.node-code
    field full-name like ub.goods.grp-name
    field other-code as integer
    INDEX i1 full-name ASCENDING
    INDEX i2
    obj-code
    grp-code other-code
      .
define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
define variable full-name as char.
define buffer for-grp for ub.gds-grp.
define variable LL AS INTEGER.
define variable tot-nc as integer no-undo.
define variable ii as integer     no-undo .
define variable kk as integer     no-undo .
define variable cycle as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-tot-nc as integer no-undo .
define variable accum-obj-list as integer no-undo .
define buffer cli-obj for ub.clients .
for each obj-list no-lock:
  assign
  accum-obj-list = accum-obj-list + 1.
  if accum-obj-list > 1 then LEAVE.
end.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT stream PrnLibStream
    "Почасовая статистика розничных продаж" format "x(80)" SKIP(0)
    ("( ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ - ЧЕКИ) ЗА ПЕРИОД c" +
    string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + ".")      format "x(80)" SKIP(0)
    IF RETS then "ВОЗВРАТЫ УЧТЕНЫ" ELSE "" format "x(80)" SKIP(0).
if t-dis-card then do:
  PUT stream PrnLibStream UNFORMATTED
  "Только покупки по дисконтным картам" skip.
  if rs-dis-card = 1 then do:
    for each temp-dis-card-type No-LOCK:
      PUT stream PrnLibStream UNFORMATTED
      temp-dis-card-type.type
      skip.
    END.
  end.
end.
PUT stream PrnLibStream UNFORMATTED SelectObject  skip(0)
(if byobject then "С разбивкой по объектам" else '':U) skip(1)
.
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.
PUT stream PrnLibStream  UNFORMATTED
"Сумма_чека"  p-XL-delim
"0.00-0.59" p-XL-delim
"1.00-1.59" p-XL-delim
"2.00-2.59" p-XL-delim
"3.00-3.59" p-XL-delim
"4.00-4.59" p-XL-delim
"5.00-5.59" p-XL-delim
"6.00-6.59" p-XL-delim
"7.00-7.59" p-XL-delim
"8.00-8.59" p-XL-delim
"9.00-9.59" p-XL-delim
"0.00-10.59" p-XL-delim
"11.00-11.59" p-XL-delim
"12.00-12.59" p-XL-delim
"13.00-13.59" p-XL-delim
"14.00-14.59" p-XL-delim
"15.00-15.59" p-XL-delim
"16.00-16.59" p-XL-delim
"17.00-17.59" p-XL-delim
"18.00-18.59" p-XL-delim
"19.00-19.59" p-XL-delim
"20.00-20.59" p-XL-delim
"21.00-21.59" p-XL-delim
"22.00-22.59" p-XL-delim
"23.00-23.59" p-XL-delim
"Итого_по_строке" p-XL-delim skip.
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
    assign
    tot-nc = 0
    accum-num-chk[1] =  0
    accum-num-chk[2] =  0
    accum-num-chk[3] =  0
    accum-num-chk[4] =  0
    accum-num-chk[5] =  0
    accum-num-chk[6] =  0
    accum-num-chk[7] =  0
    accum-num-chk[8] =  0
    accum-num-chk[9] =  0
    accum-num-chk[10] = 0
    accum-num-chk[11] = 0
    accum-num-chk[12] = 0
    accum-num-chk[13] = 0
    accum-num-chk[14] = 0
    accum-num-chk[15] = 0
    accum-num-chk[16] = 0
    accum-num-chk[17] = 0
    accum-num-chk[18] = 0
    accum-num-chk[19] = 0
    accum-num-chk[20] = 0
    accum-num-chk[21] = 0
    accum-num-chk[22] = 0
    accum-num-chk[23] = 0
    accum-num-chk[24] = 0
    accum-tot-nc = 0
    .
    if cycle = 1 then do:
      FIND FIRST ub.clients NO-LOCK WHERE
                ub.clients.obj-code = v-obj-code AND
                ub.clients.obj-type = 'маг':U NO-ERROR.
      if available ub.clients then do:
        v-obj-name = replace(ub.clients.obj-name, chr(32) , "_").
      end.
      else v-obj-name = string(v-obj-code).
    end.
    if byobject and cycle = 0 then do:
      v-obj-name = "ПО_ВСЕМ_ОБЪЕКТАМ".
    end.
    PUT stream PrnLibStream UNFORMATTED
    v-obj-name p-XL-delim
    SKIP.
    _sum-vals:
    for each sum-vals:
       find first grp-h WHERE
                 grp-h.obj-code = v-obj-code
            AND  grp-h.sum = sum-vals.sum1 no-error .
      if not available grp-h and v-obj-code > 0 and accum-obj-list > 1 then next.
      if available grp-h then do:
        tot-nc =  grp-h.num-chk[1] + grp-h.num-chk[2] + grp-h.num-chk[3] +
                      grp-h.num-chk[4] + grp-h.num-chk[5] + grp-h.num-chk[6] + grp-h.num-chk[7] +
                      grp-h.num-chk[8] + grp-h.num-chk[9] + grp-h.num-chk[10] + grp-h.num-chk[11] +
                      grp-h.num-chk[12] + grp-h.num-chk[13] + grp-h.num-chk[14] + grp-h.num-chk[15] +
                      grp-h.num-chk[16] + grp-h.num-chk[17] + grp-h.num-chk[18] + grp-h.num-chk[19] +
                      grp-h.num-chk[20] + grp-h.num-chk[21] + grp-h.num-chk[22] + grp-h.num-chk[23] +
                      grp-h.num-chk[24].
        PUT STREAM PrnLibStream UNFORMATTED
        (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim
        grp-h.num-chk[1] p-XL-delim
        grp-h.num-chk[2] p-XL-delim
        grp-h.num-chk[3] p-XL-delim
        grp-h.num-chk[4] p-XL-delim
        grp-h.num-chk[5] p-XL-delim
        grp-h.num-chk[6] p-XL-delim
        grp-h.num-chk[7] p-XL-delim
        grp-h.num-chk[8] p-XL-delim
        grp-h.num-chk[9] p-XL-delim
        grp-h.num-chk[10] p-XL-delim
        grp-h.num-chk[11] p-XL-delim
        grp-h.num-chk[12] p-XL-delim
        grp-h.num-chk[13] p-XL-delim
        grp-h.num-chk[14] p-XL-delim
        grp-h.num-chk[15] p-XL-delim
        grp-h.num-chk[16] p-XL-delim
        grp-h.num-chk[17] p-XL-delim
        grp-h.num-chk[18] p-XL-delim
        grp-h.num-chk[19] p-XL-delim
        grp-h.num-chk[20] p-XL-delim
        grp-h.num-chk[21] p-XL-delim
        grp-h.num-chk[22] p-XL-delim
        grp-h.num-chk[23] p-XL-delim
        grp-h.num-chk[24] p-XL-delim
        tot-nc
        skip.
        ASSIGN
        accum-num-chk[1] = accum-num-chk[1] + grp-h.num-chk[1]
        accum-num-chk[2] = accum-num-chk[2] + grp-h.num-chk[2]
        accum-num-chk[3] = accum-num-chk[3] + grp-h.num-chk[3]
        accum-num-chk[4] = accum-num-chk[4] + grp-h.num-chk[4]
        accum-num-chk[5] = accum-num-chk[5] + grp-h.num-chk[5]
        accum-num-chk[6] = accum-num-chk[6] + grp-h.num-chk[6]
        accum-num-chk[7] = accum-num-chk[7] + grp-h.num-chk[7]
        accum-num-chk[8] = accum-num-chk[8] + grp-h.num-chk[8]
        accum-num-chk[9] = accum-num-chk[9] + grp-h.num-chk[9]
        accum-num-chk[10] = accum-num-chk[10] + grp-h.num-chk[10]
        accum-num-chk[11] = accum-num-chk[11] + grp-h.num-chk[11]
        accum-num-chk[12] = accum-num-chk[12] + grp-h.num-chk[12]
        accum-num-chk[13] = accum-num-chk[13] + grp-h.num-chk[13]
        accum-num-chk[14] = accum-num-chk[14] + grp-h.num-chk[14]
        accum-num-chk[15] = accum-num-chk[15] + grp-h.num-chk[15]
        accum-num-chk[16] = accum-num-chk[16] + grp-h.num-chk[16]
        accum-num-chk[17] = accum-num-chk[17] + grp-h.num-chk[17]
        accum-num-chk[18] = accum-num-chk[18] + grp-h.num-chk[18]
        accum-num-chk[19] = accum-num-chk[19] + grp-h.num-chk[19]
        accum-num-chk[20] = accum-num-chk[20] + grp-h.num-chk[20]
        accum-num-chk[21] = accum-num-chk[21] + grp-h.num-chk[21]
        accum-num-chk[22] = accum-num-chk[22] + grp-h.num-chk[22]
        accum-num-chk[23] = accum-num-chk[23] + grp-h.num-chk[23]
        accum-num-chk[24] = accum-num-chk[24] + grp-h.num-chk[24]
        accum-tot-nc = accum-tot-nc + tot-nc
        .
      end.
      else do:
        PUT STREAM PrnLibStream UNFORMATTED
        (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0
        skip.
      end.
    end.
    PUT stream PrnLibStream UNFORMATTED
    substitute("Итого_&1", v-obj-name) p-XL-delim
    accum-num-chk[1]  p-XL-delim
    accum-num-chk[2]  p-XL-delim
    accum-num-chk[3]  p-XL-delim
    accum-num-chk[4]  p-XL-delim
    accum-num-chk[5]  p-XL-delim
    accum-num-chk[6]  p-XL-delim
    accum-num-chk[7]  p-XL-delim
    accum-num-chk[8]  p-XL-delim
    accum-num-chk[9]  p-XL-delim
    accum-num-chk[10] p-XL-delim
    accum-num-chk[11] p-XL-delim
    accum-num-chk[12] p-XL-delim
    accum-num-chk[13] p-XL-delim
    accum-num-chk[14] p-XL-delim
    accum-num-chk[15] p-XL-delim
    accum-num-chk[16] p-XL-delim
    accum-num-chk[17] p-XL-delim
    accum-num-chk[18] p-XL-delim
    accum-num-chk[19] p-XL-delim
    accum-num-chk[20] p-XL-delim
    accum-num-chk[21] p-XL-delim
    accum-num-chk[22] p-XL-delim
    accum-num-chk[23] p-XL-delim
    accum-num-chk[24] p-XL-delim
    accum-tot-nc
    skip
    .
    if byobject and cycle = 0 then LEAVE _obj-list.
  end.
END .
output stream PrnLibStream CLOSE .
