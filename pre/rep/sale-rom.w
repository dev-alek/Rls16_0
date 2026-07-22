define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет о продажах".
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
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
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
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable varsum-vat-acc      like doc-line.price-rubl no-undo.
define variable varsum-vat-sale     like doc-line.price-rubl no-undo.
define variable varsum-acc-out-vat  like doc-line.price-rubl no-undo.
define variable varsum-sale-out-vat like doc-line.price-rubl no-undo.
define variable varsum-sale         like doc-line.price-rubl no-undo.
define variable varsum-income       like doc-line.price-rubl no-undo.
define variable varsum-road-tax     like doc-line.price-rubl no-undo.
define variable varsum-qnty         like doc-line.fact-qnty    no-undo.
define variable vargds-grp          like gds-grp.node-code     no-undo.
define variable varnum-line         as   integer               no-undo.
define variable varroot             like gds-grp.node-code     no-undo.
define temp-table tt-doc-line no-undo
field artic              like doc-line.artic
field prod-type          like doc-line.prod-type
field prod-code          like doc-line.prod-code
field gds-name           like goods.gds-name
field gds-type           like goods.gds-type
field gds-unit-base      like goods.unit-base
field grp-code           like goods.grp-code
field grp-name           like goods.grp-name
field vat-acc            like doc-line.vat-pc
field sum-road-tax       like doc-line.road-tax
field road-tax           like doc-line.road-tax
field qnty               like doc-line.fact-qnty
field sum-vat-acc        like gds-dtl.price-rubl
field price-acc          like gds-dtl.price-rubl
field price-acc-out-vat  like gds-dtl.price-rubl
field increase           like gds-dtl.price-rubl
field vat-sale           like doc-line.vat-pc
field sum-vat-sale       like gds-dtl.price-rubl
field price-sale         like gds-dtl.price-rubl
field price-sale-out-vat like gds-dtl.price-rubl
field sum-acc            like gds-dtl.price-rubl
field sum-acc-out-vat    like gds-dtl.price-rubl
field sum-sale           like gds-dtl.price-rubl
field sum-sale-out-vat   like gds-dtl.price-rubl
index pi is unique primary artic prod-type prod-code
index grp-code grp-code.
def var sym1  as char init ":" no-undo.
def var sym2  as char init ":" no-undo.
def var sym3  as char init ":" no-undo.
def var sym4  as char init ":" no-undo.
def var sym5  as char init ":" no-undo.
def var sym6  as char init ":" no-undo.
def var sym7  as char init ":" no-undo.
def var sym8  as char init ":" no-undo.
def var sym9  as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.
def var sym12 as char init ":" no-undo.
def var sym13 as char init ":" no-undo.
def var sym14 as char init ":" no-undo.
def var sym15 as char init ":" no-undo.
def var sym16 as char init ":" no-undo.
def var sym17 as char init ":" no-undo.
def var Line  as char          no-undo.
DEFINE FRAME gds-grp
      sym1                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.gds-type          COLUMN-LABEL "т"   format "x(1)" space(0)
      sym2                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.artic             COLUMN-LABEL "Артикул"           space(0)
      sym3                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.gds-name          COLUMN-label "Название"          space(0)
      sym4                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.vat-acc           COLUMN-LABEL "НДС"  format ">9.99" space(0)
      sym5                          column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.road-tax          COLUMN-LABEL "Дор.нал." format ">>>>9.99" space(0)
      sym6                          column-label ":!:" format "X(1)"          space(0)
      tt-doc-line.qnty              COLUMN-LABEL "Количество"                 space(0)
      sym7                          column-label ":!:" format "X(1)"          space(0)
      tt-doc-line.price-acc-out-vat COLUMN-LABEL "Уч. цена! без НДС" format ">>>>9.99" space(0)
      sym8                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-vat-acc       COLUMN-LABEL "Сумма!НДС" format ">>>>>>>9.99" space(0)
      sym9                          column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.price-acc         COLUMN-LABEL "Уч. цена! с НДС" format ">>>>9.99" space(0)
      sym10                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.increase          COLUMN-LABEL "Наценка" format "->>>>>9.99" space(0)
      sym11                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.vat-sale          COLUMN-LABEL "НДС" format ">9.99" space(0)
      sym12                         column-label ":!:" format "X(1)"  space(0)
      tt-doc-line.sum-vat-sale      COLUMN-LABEL "Сумма!НДС" format ">>>>>>>9.99" space(0)
      sym13                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.price-sale        COLUMN-LABEL "Розн.цена! с НДС" format ">>>>9.99" space(0)
      sym14                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-acc-out-vat   COLUMN-LABEL "Сумма по уч!цене без НДС" format ">>>>>>>9.99" space(0)
      sym15                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-sale-out-vat  column-label "Сумма прод.! без НДС" format ">>>>>>>9.99" space(0)
      sym16                         column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-sale          column-label "Сумма прод.! c НДС" format ">>>>>>>9.99" space(0)
      sym17                         column-label ":!:" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет о продажах: ") AT 45 format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(195)" AT 1
    with width 232 down stream-io.
if session:set-wait-state("COMPILER") then.
assign Line = fill("-", 195).
DEFINE BUTTON b-date
     LABEL "Сбор данных"
     SIZE 15.38 BY 1.08.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 9.5 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10.25 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Печать"
     SIZE 15.13 BY 1.08.
DEFINE BUTTON r-gds-grp
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3.13 BY .96.
DEFINE VARIABLE vargrp-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 55.38 BY 2.75 NO-UNDO.
DEFINE VARIABLE end-date AS DATE FORMAT "99/99/99":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1.08 NO-UNDO.
DEFINE VARIABLE start-date AS DATE FORMAT "99/99/99":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 14.13 BY 1.08 NO-UNDO.
DEFINE VARIABLE rb-gds-grp AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
     "По всему классификатору", 1,
     "Выборочно", 2
     SIZE 54.88 BY .96 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 1.75
     b-help AT ROW 1.17 COL 13.38
     start-date AT ROW 2.67 COL 2.25
     end-date AT ROW 2.67 COL 22.13
     b-date AT ROW 2.67 COL 42.13
     rb-gds-grp AT ROW 4 COL 2.38 NO-LABEL
     b-print AT ROW 5.25 COL 42.25
     r-gds-grp AT ROW 5.38 COL 37.13
     vargrp-name AT ROW 6.58 COL 1.63 NO-LABEL
     "   Уровень классификатора" VIEW-AS TEXT
          SIZE 28.13 BY 1.08 AT ROW 5.29 COL 1.88
     SPACE(27.98) SKIP(3.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет о продажах"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-date IN FRAME Dialog-Frame
DO:
  for each tt-doc-line:
      delete tt-doc-line.
  end.
  RUN calc-sale
  (INPUT p-curr-obj-type,
   INPUT p-curr-obj-code,
   INPUT input frame Dialog-Frame start-date,
   INPUT input frame Dialog-Frame end-date)
  .
  message "Сбор данных завершен" view-as alert-box.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM with FRAME gds-grp.
FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width 232
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .
PUT STREAM PrnLibStream
    string( "Отчет за период с: " + string(input frame Dialog-Frame start-date,"99/99/9999") + " по: " + string(input frame Dialog-Frame end-date,"99/99/9999"))
    AT 37 format "X(195)" SKIP(1).
  assign varroot = vargds-grp.
  RUN calc-gds-grp (input  1,
                    input  vargds-grp,
                    input  " ",
                    output varsum-vat-acc,
                    output varsum-vat-sale,
                    output varsum-acc-out-vat,
                    output varsum-sale-out-vat,
                    output varsum-sale,
                    output varsum-road-tax,
                    output varsum-qnty).
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
if session:set-wait-state("") then.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END.
ON CHOOSE OF r-gds-grp IN FRAME Dialog-Frame
DO:
  define variable ref-list as character no-undo.
  run ref/gds-grp.w (
                  input parparentproc
                 ,input "b-sel"
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input-output ref-list).
  IF REF-LIST <>  "":U then do:
    find first gds-grp where RECID(gds-grp) = integer(ref-list) no-lock.
    ASSIGN vargrp-name:SCREEN-VALUE in frame Dialog-Frame = gds-grp.node-name
          vargds-grp = gds-grp.node-code.
  end.
  else do:
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF rb-gds-grp IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame rb-gds-grp = 1 then do:
    find first gds-grp where gds-grp.upper-code = 0 no-lock.
    vargds-grp = gds-grp.node-code.
     ASSIGN vargrp-name:SCREEN-VALUE in frame Dialog-Frame = " "
            r-gds-grp:SENSITIVE      = no.
  end.
  else do:
       assign r-gds-grp:SENSITIVE      = yes.
       apply "choose" to r-gds-grp in frame Dialog-Frame.
       return no-apply.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of start-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if start-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      start-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      start-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = start-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to start-date in frame Dialog-Frame .
  END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of end-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if end-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      end-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      end-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = end-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to end-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-today
  )  .
  assign
      start-date = v-today
      end-date   = v-today
  .
  find first gds-grp where gds-grp.upper-code = 0 no-lock.
  vargds-grp = gds-grp.node-code.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-gds-grp :
  define input  parameter pardisp-all         as   integer               no-undo.
  define input  parameter parnode-code        like gds-grp.node-code     no-undo.
  define input  parameter pargrp-name         like goods.grp-name        no-undo.
  define output parameter parsum-vat-acc      like doc-line.price-rubl no-undo.
  define output parameter parsum-vat-sale     like doc-line.price-rubl no-undo.
  define output parameter parsum-acc-out-vat  like doc-line.price-rubl no-undo.
  define output parameter parsum-sale-out-vat like doc-line.price-rubl no-undo.
  define output parameter parsum-sale         like doc-line.price-rubl no-undo.
  define output parameter parsum-road-tax     like doc-line.price-rubl no-undo.
  define output parameter parsum-qnty         like doc-line.fact-qnty    no-undo.
  define variable vargrp-name-loc like goods.grp-name no-undo.
  find first gds-grp where gds-grp.node-code = parnode-code no-lock.
  vargrp-name-loc = pargrp-name + "\" + gds-grp.node-name.
  if length(vargrp-name-loc) > 37 then vargrp-name-loc = "..." +
                                       SUBSTRING(vargrp-name-loc, length(vargrp-name-loc) - 36, 37).
  if can-find(first gds-grp where gds-grp.upper-code = parnode-code no-lock) then do:
     for each gds-grp where gds-grp.upper-code = parnode-code no-lock:
         RUN calc-gds-grp (input  pardisp-all,
                           input  gds-grp.node-code,
                           input  vargrp-name-loc,
                           output varsum-vat-acc,
                           output varsum-vat-sale,
                           output varsum-acc-out-vat,
                           output varsum-sale-out-vat,
                           output varsum-sale,
                           output varsum-road-tax,
                           output varsum-qnty).
         ACCUMULATE varsum-vat-acc      (total)
                    varsum-vat-sale     (total)
                    varsum-acc-out-vat  (total)
                    varsum-sale-out-vat (total)
                    varsum-sale         (total)
                    varsum-road-tax     (total)
                    varsum-qnty         (total).
     end.
     ASSIGN
       parsum-vat-acc      = (ACCUM TOTAL varsum-vat-acc     )
       parsum-vat-sale     = (ACCUM TOTAL varsum-vat-sale    )
       parsum-acc-out-vat  = (ACCUM TOTAL varsum-acc-out-vat )
       parsum-sale-out-vat = (ACCUM TOTAL varsum-sale-out-vat)
       parsum-sale         = (ACCUM TOTAL varsum-sale        )
       parsum-road-tax     = (ACCUM TOTAL varsum-road-tax    )
       parsum-qnty         = (ACCUM TOTAL varsum-qnty        ).
       if parsum-vat-acc       > 0 OR
          parsum-vat-sale      > 0 OR
          parsum-acc-out-vat   > 0 OR
          parsum-sale-out-vat  > 0 OR
          parsum-sale          > 0 OR
          parsum-road-tax      > 0 OR
          parsum-qnty          > 0 THEN DO:
          if (pardisp-all <> 2 OR parnode-code = varroot) AND
             (pardisp-all <> 4 OR parnode-code = varroot) AND
             (pardisp-all <> 5 OR parnode-code = varroot) THEN
          run disp-total(input vargrp-name-loc    ,
                         input parsum-vat-acc     ,
                         input parsum-vat-sale    ,
                         input parsum-acc-out-vat ,
                         input parsum-sale-out-vat,
                         input parsum-sale        ,
                         input parsum-road-tax    ,
                         input parsum-qnty).
       END.
  end.
  else do:
       if can-find(first tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code) and
          pardisp-all <> 2 and
          pardisp-all <> 3 and
          pardisp-all <> 5 then run disp-grp-name(input vargrp-name-loc).
       for each tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code:
           if pardisp-all <> 3 and
              pardisp-all <> 5 then run disp-tt-doc-line.
           ACCUMULATE tt-doc-line.sum-vat-acc      (total)
                      tt-doc-line.sum-vat-sale     (total)
                      tt-doc-line.sum-acc-out-vat  (total)
                      tt-doc-line.sum-sale-out-vat (total)
                      tt-doc-line.sum-sale         (total)
                      tt-doc-line.sum-road-tax     (total)
                      tt-doc-line.qnty             (total).
       end.
       ASSIGN
       parsum-vat-acc      = (ACCUM TOTAL tt-doc-line.sum-vat-acc     )
       parsum-vat-sale     = (ACCUM TOTAL tt-doc-line.sum-vat-sale    )
       parsum-acc-out-vat  = (ACCUM TOTAL tt-doc-line.sum-acc-out-vat )
       parsum-sale-out-vat = (ACCUM TOTAL tt-doc-line.sum-sale-out-vat)
       parsum-sale         = (ACCUM TOTAL tt-doc-line.sum-sale        )
       parsum-road-tax     = (ACCUM TOTAL tt-doc-line.sum-road-tax    )
       parsum-qnty         = (ACCUM TOTAL tt-doc-line.qnty            ).
       find first tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code no-error.
       if available tt-doc-line then do:
           if pardisp-all <> 2       OR
              parnode-code = varroot then
           run disp-total(input vargrp-name-loc    ,
                          input parsum-vat-acc     ,
                          input parsum-vat-sale    ,
                          input parsum-acc-out-vat ,
                          input parsum-sale-out-vat,
                          input parsum-sale        ,
                          input parsum-road-tax    ,
                          input parsum-qnty).
      end.
  end.
END PROCEDURE.
PROCEDURE calc-sale :
DEFINE INPUT PARAMETER parobj-type   LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER parobj-code   LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT PARAMETER parstart-date AS   DATE       NO-UNDO.
DEFINE INPUT PARAMETER parend-date   AS   DATE       NO-UNDO.
define variable varr-b as character no-undo.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
run waitfram-show in this-procedure ("Сбор данных о продажах").
for each trn-doc where trn-doc.obj-type    = parobj-type   and
                       trn-doc.obj-code    = parobj-code   and
                       trn-doc.status_     = 'факт':U       and
                       trn-doc.fact-date  >= parstart-date and
                       trn-doc.fact-date  <= parend-date   and
                       trn-doc.internal    = no            and
                       trn-doc.doc-type    = 'рас':U    and
                       trn-doc.discnt-type = 'касс':U no-lock ,
  each doc-line where doc-line.doc-code = trn-doc.doc-code and
                      doc-line.doc-qnty <> 0 no-lock,
  first goods where goods.artic     = doc-line.artic     and
                    goods.prod-type = doc-line.prod-type and
                    goods.prod-code = doc-line.prod-code no-lock:
    run calc-in-out in this-procedure.
    run cr-tt-doc-line in this-procedure.
    if varr-b = "rubl":u then do:
      run as1-tt-doc-line in this-procedure.
    end.
    else do:
      run as2-tt-doc-line in this-procedure.
    end.
end .
run as3-tt-doc-line in this-procedure.
run waitfram-hide in this-procedure .
END PROCEDURE.
procedure calc-in-out :
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not trn-doc.internal and
           trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if doc-line.transport-base = ? then 0 else doc-line.transport-base)
        transport-rubl-loc = (if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if doc-line.other-base     = ? then 0 else doc-line.other-base)
        other-rubl-loc     = (if doc-line.other-rubl     = ? then 0 else doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if doc-line.vat-pc         = ? then 0 else doc-line.vat-pc)
        slt-pc-loc         = (if doc-line.slt-pc         = ? then 0 else doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = doc-line.obj-code  and
                                      in-vatp-parts.artic     = doc-line.artic     and
                                      in-vatp-parts.prod-type = doc-line.prod-type and
                                      in-vatp-parts.prod-code = doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-base-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-rubl-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-base-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-rubl-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
                                        vat-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
                vat-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
                                                                                     ~
if trn-doc.ext-doc-type = 'ot':U or
   trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = doc-line.artic     and
                                   out-vatp_goods.prod-type = doc-line.prod-type and
                                   out-vatp_goods.prod-code = doc-line.prod-code no-lock.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / trn-doc.base-rate * trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * trn-doc.base-rate / trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = trn-doc.doc-code
                               and out-vatp_parts.obj-type   = trn-doc.obj-type
                               and out-vatp_parts.obj-code   = trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale ) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
                                                                                     ~
end procedure.
procedure cr-tt-doc-line:
find first tt-doc-line where tt-doc-line.artic     = doc-line.artic     and
                             tt-doc-line.prod-type = doc-line.prod-type and
                             tt-doc-line.prod-code = doc-line.prod-code no-error.
if not available tt-doc-line then do:
     create tt-doc-line.
     ASSIGN tt-doc-line.artic             =  doc-line.artic
            tt-doc-line.prod-type         =  doc-line.prod-type
            tt-doc-line.prod-code         =  doc-line.prod-code
            tt-doc-line.gds-type          =  goods.gds-type
            tt-doc-line.grp-code          =  goods.grp-code
            tt-doc-line.gds-name          =  goods.gds-name
            tt-doc-line.gds-unit-base     =  goods.unit-base.
end.
end procedure.
procedure as1-tt-doc-line:
ASSIGN    tt-doc-line.vat-acc            = tt-doc-line.vat-acc          + doc-line.fact-qnty * vat-pc-loc
          tt-doc-line.vat-sale           = tt-doc-line.vat-sale         + doc-line.fact-qnty * doc-line.vat-pc
          tt-doc-line.sum-road-tax       = tt-doc-line.sum-road-tax     + doc-line.fact-qnty * road-tax-rubl-sale
          tt-doc-line.qnty               = tt-doc-line.qnty             + doc-line.fact-qnty
          tt-doc-line.sum-vat-acc        = tt-doc-line.sum-vat-acc      + doc-line.fact-qnty * vat-rubl-loc
          tt-doc-line.sum-vat-sale       = tt-doc-line.sum-vat-sale     + doc-line.fact-qnty * vat-rubl-sale
          tt-doc-line.sum-acc            = tt-doc-line.sum-acc          + doc-line.fact-qnty * price-rubl-with-tax-loc
          tt-doc-line.sum-sale           = tt-doc-line.sum-sale         + doc-line.fact-qnty * price-rubl-with-tax-sale.
end procedure.
procedure as2-tt-doc-line :
ASSIGN    tt-doc-line.vat-acc            = tt-doc-line.vat-acc          + doc-line.fact-qnty * vat-pc-loc
          tt-doc-line.vat-sale           = tt-doc-line.vat-sale         + doc-line.fact-qnty * doc-line.vat-pc
          tt-doc-line.sum-road-tax       = tt-doc-line.sum-road-tax     + doc-line.fact-qnty * road-tax-base-sale
          tt-doc-line.qnty               = tt-doc-line.qnty             + doc-line.fact-qnty
          tt-doc-line.sum-vat-acc        = tt-doc-line.sum-vat-acc      + doc-line.fact-qnty * vat-base-loc
          tt-doc-line.sum-vat-sale       = tt-doc-line.sum-vat-sale     + doc-line.fact-qnty * vat-base-sale
          tt-doc-line.sum-acc            = tt-doc-line.sum-acc          + doc-line.fact-qnty * price-base-with-tax-loc
          tt-doc-line.sum-sale           = tt-doc-line.sum-sale         + doc-line.fact-qnty * price-base-with-tax-sale.
end procedure.
procedure as3-tt-doc-line:
for each tt-doc-line:
   ASSIGN
   tt-doc-line.sum-acc-out-vat    = tt-doc-line.sum-acc            - tt-doc-line.sum-vat-acc
   tt-doc-line.sum-sale-out-vat   = tt-doc-line.sum-sale           - tt-doc-line.sum-vat-sale
   tt-doc-line.increase           = tt-doc-line.sum-sale-out-vat   - tt-doc-line.sum-road-tax
   tt-doc-line.vat-acc            = tt-doc-line.vat-acc            / tt-doc-line.qnty
   tt-doc-line.vat-sale           = tt-doc-line.vat-sale           / tt-doc-line.qnty
   tt-doc-line.road-tax           = tt-doc-line.sum-road-tax       / tt-doc-line.qnty
   tt-doc-line.price-acc          = tt-doc-line.sum-acc            / tt-doc-line.qnty
   tt-doc-line.price-acc-out-vat  = tt-doc-line.sum-acc-out-vat    / tt-doc-line.qnty
   tt-doc-line.price-sale         = tt-doc-line.sum-sale           / tt-doc-line.qnty
   tt-doc-line.price-sale-out-vat = tt-doc-line.sum-sale-out-vat   / tt-doc-line.qnty
   .
end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY start-date end-date rb-gds-grp vargrp-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help start-date end-date b-date rb-gds-grp b-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-tt-doc-line:
    display stream PrnLibStream
           sym1
           tt-doc-line.gds-type
           sym2
           tt-doc-line.artic
           sym3
           tt-doc-line.gds-name
           sym4
           tt-doc-line.vat-acc
           sym5
           tt-doc-line.road-tax
           sym6
           tt-doc-line.qnty
           sym7
           tt-doc-line.price-acc-out-vat
           sym8
           tt-doc-line.sum-vat-acc
           sym9
           tt-doc-line.price-acc
           sym10
           tt-doc-line.increase
           sym11
           tt-doc-line.vat-sale
           sym12
           tt-doc-line.sum-vat-sale
           sym13
           tt-doc-line.price-sale
           sym14
           tt-doc-line.sum-acc-out-vat
           sym15
           tt-doc-line.sum-sale-out-vat
           sym16
           tt-doc-line.sum-sale
           sym17
           with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
           PUT STREAM PrnLibStream Line format "X(195)" SKIP.
END PROCEDURE.
PROCEDURE disp-total:
define input parameter pardispgrp-name         as   character           no-undo.
define input parameter pardispsum-vat-acc      like doc-line.price-rubl no-undo.
define input parameter pardispsum-vat-sale     like doc-line.price-rubl no-undo.
define input parameter pardispsum-acc-out-vat  like doc-line.price-rubl no-undo.
define input parameter pardispsum-sale-out-vat like doc-line.price-rubl no-undo.
define input parameter pardispsum-sale         like doc-line.price-rubl no-undo.
define input parameter pardispsum-road-tax     like doc-line.price-rubl no-undo.
define input parameter pardispsum-qnty         like doc-line.fact-qnty  no-undo.
display stream PrnLibStream
sym1
">" @ tt-doc-line.gds-type
sym2
"Итого " @ tt-doc-line.artic
sym3
pardispgrp-name @ tt-doc-line.gds-name
sym4
sym5
sym6
sym7
sym8
pardispsum-vat-acc        @ tt-doc-line.sum-vat-acc
sym9
sym10
sym11
sym12
pardispsum-vat-sale       @ tt-doc-line.sum-vat-sale
sym13
sym14
pardispsum-acc-out-vat    @ tt-doc-line.sum-acc-out-vat
sym15
pardispsum-sale-out-vat   @ tt-doc-line.sum-sale-out-vat
sym16
pardispsum-sale           @ tt-doc-line.sum-sale
sym17
with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
           PUT STREAM PrnLibStream Line format "X(195)" SKIP.
END PROCEDURE.
procedure disp-grp-name:
define input parameter pargrp-name like goods.grp-name no-undo.
end procedure.
