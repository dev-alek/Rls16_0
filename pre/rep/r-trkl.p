block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-trkl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-trkl.p $":U .
define variable vss-description as character no-undo init "Требование в кладовую.".
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
do
on error undo, return error return-value
:
define variable v-doc-code                          as character        no-undo.
define variable v-doc-date                          as date             no-undo.
define variable v-counter                           as integer          no-undo.
define variable v-line-string                       as character        no-undo.
define variable v-host-code                         as integer          no-undo.
define variable v-base-code                         as integer          no-undo.
define variable v-units-okei                        as integer          no-undo.
define variable v-sum-qnty                          as decimal          no-undo.
define variable v-prim                              as character     no-undo.
define variable v-artic                             as character     no-undo.
define variable v-gds-name                          as character     no-undo.
define variable v-unit-base                         as character     no-undo.
define variable v-barcode                           as character     no-undo.
define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.
define buffer buf_fbr-doc   for fbr-doc.
define buffer buf_fbr-line  for fbr-line.
define buffer buf_goods     for goods.
define buffer buf_units     for units.
define variable sym1 as character init ":"   no-undo.
define variable sym2 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.
define variable sym6 as character init ":"   no-undo.
define variable sym7 as character init ":"   no-undo.
define variable sym8 as character init ":"   no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define frame fbr-not-in-rb
    sym1                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-counter               column-label "!п/п  ! ! !------!1  !"                        format ">>9"            space(0)
    sym2                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-gds-name              column-label "                   Продукты        и !-----------------------------------------!           Наименование!-----------------------------------------!              2" format "X(41)"          space(0)
    sym3                    column-label "!|!|!|!"                                 format "X(1)"           space(0)
    v-barcode               column-label "товары    !-----------!    Код!-----------!   3  "                 format "X(10)" space(0)
    sym4                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-unit-base             column-label "   Единица!-------------!    Наиме-!   нование!-------------!      4"                   format "X(3)"           space(0)
    sym5                    column-label "!|!|!|!|"                                format "X(1)"           space(0)
    v-units-okei            column-label "измерения  !-------------!Код по  ! ОКЕИ   !-------------!5      "       format ">>>"          space(0)
    sym6                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-sum-qnty              column-label " !Количество !--------------!6       "                   format ">>,>>9.999"     space(0)
    sym7                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
    v-prim                  column-label " !    Примечание!---------------------!        7"                   format "X(4)"          space(0)
    sym8                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
    HEADER
    skip v-line-string format  "X(127)" AT 1
    with width 136 down stream-io NO-BOX.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock
     where recid(buf_trn-doc) = p-trn-doc-recid
no-error.
if not available buf_trn-doc
then do:
    message
        "Не найден документ для печати."
    view-as alert-box error.
    return error.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
run prn-lib-open-stream in this-procedure ( input p-mainmenu-handle, input 62, input yes, input no ).
session :set-wait-state( "COMPILER":U ).
 assign
    v-line-string = fill( "-", 127 )
.
assign
    v-doc-code      = buf_trn-doc.doc-code
    v-doc-date      = ( if buf_trn-doc.status_ = 'факт':U then buf_trn-doc.fact-date else buf_trn-doc.doc-date )
 .
find first clients no-lock
     where clients.obj-type = buf_trn-doc.obj-type
       and clients.obj-code = buf_trn-doc.obj-code
.
put stream PrnLibStream
    "Унифицированная форма №ОП-3"
    skip
    "Утверждена постановлением Госкомстата" space (63) "_ _ _ _ _ _ _ _ _ _ _ _"
    skip
    "России от 25.12.98 № 132" space (75)  "|_ _ _ _ _ Код _ _ _ _ _|"
    skip
                           "Форма по ОКУД|_ _ _ _ _0330503_ _ _ _|" at 87
    skip
                                                      "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
    skip
    string(  '"' + trim(clients.obj-name) + '"' ) format "X(40)"  at 35    "по ОКПО |_ _ _ _ _ _ _ _ _ _ _ _|" at 92
    skip
         "____________________________________"   at 29   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
    skip
        "предприятие (организация)" at 31       "Вид деятельности по ОКДП|_ _ _ _ _ _ _ _ _ _ _ _|" at 76
    skip
    string(  buf_trn-doc.obj-type + " " + string(buf_trn-doc.obj-code)  ) format "X(40)" at 10   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
    skip
     "____________________________________"    "Вид операции|_ _ _ _ _ _ _ _ _ _ _ _|" at 88
     skip
    "подразделение"
    skip
    string(  string(buf_trn-doc.cli-name) ) format "X(40)"  at 10
    skip
                 "___________________________"
    skip
          "подразделение получатель "
     skip
     "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"   at 90
     skip
     "|           Номер |Дата             |" at 89
     skip
     "|_ _ _ _документа |составления _ _ _|"   at 89
     skip
            "Требование в кладовую" at 50 space(18) "|_ _ _ _ _" (string(v-doc-code)) format "X(8)" at 99 "|_"   string( v-doc-date, "99/99/9999" ) format "x(10)"  at 110 "_ _ _|"
     skip(1)
     "Через кого___________________________________________________________" at 55
      skip
      "фамилия, имя, отчество" at 80
  .
    form with frame fbr-not-in-rb.
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
                :
        assign
            v-counter = v-counter + 1
        .
        run print-doc-line in this-procedure (
              input recid( buf_doc-line )
            , input v-counter
            , input buf_doc-line.fact-qnty
            , input v-prim
            ).
    end.
    put stream PrnLibStream
        v-line-string format "X(127)"
         skip (2)
        "Затребовал заведующий производством:                ____________________                   //_________________"
         skip
        "подпись" at 60 "расшифровка подписи" at 95
        skip(1)
        "Отпуск разрешил:                                    ____________________ "
                skip(1)
        "Руководитель организации:         _____________              _________                    //_________________ "
         skip
          "должность" at 36  "подпись" at 64     "расшифровка подписи"  at 95
        skip(1)
           .
    hide   stream PrnLibStream frame Bottomframe .
    output stream PrnLibStream close.
    session :set-wait-state( "":U ).
    run prn-lib-prn-file in this-procedure ( input p-mainmenu-handle, input 0 ).
  end.
procedure print-doc-line :
do
on error undo, return error
:
define input parameter p-doc-line-recid     as recid        no-undo.
define input parameter p-counter            as integer      no-undo.
define input parameter p-fact-qnty          as decimal      no-undo.
define input parameter p-prim               as character      no-undo.
define variable v-bar-code                  as character        no-undo.
define buffer buf_doc-line  for doc-line.
define buffer buf_goods     for goods.
find first buf_doc-line no-lock
    where recid( buf_doc-line ) = p-doc-line-recid
.
find first buf_goods no-lock
     where buf_goods.artic      = buf_doc-line.artic
       and buf_goods.prod-type  = buf_doc-line.prod-type
       and buf_goods.prod-code  = buf_doc-line.prod-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
display stream PrnLibStream
  sym1 p-counter                                                  @ v-counter
  sym2 buf_goods.gds-name                                         @ v-gds-name
  sym3 string( v-bar-code )                                       @ v-barcode
  sym4 buf_goods.unit-base                                        @ v-unit-base
  sym5
  sym6 p-fact-qnty                                                @ v-sum-qnty
  sym7 p-prim                                                     @ v-prim
  sym8
with frame fbr-not-in-rb.
down    stream PrnLibStream 1 with frame fbr-not-in-rb.
if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream )
then do:
  page stream PrnLibStream .
end.
end.
end procedure.
