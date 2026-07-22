block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-parts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-parts.p $":U .
define variable vss-description as character no-undo init "Отчет по остаткам товаров".
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
define new shared temp-table sup-gds no-undo
    field artic          like ub.goods.artic
    field prod-type      like ub.clients.obj-type
    field prod-code      like ub.clients.obj-code
    field gds-name       like ub.goods.gds-name
    field unit-base      like ub.goods.unit-base
    field s-pay-type     as character
    field in-qnty        like ub.parts.fact-qnty
    field in-nds0-rubl   like ub.parts.price-rubl
    field in-nds0-base   like ub.parts.price-base
    field in-sum0-rubl   like ub.parts.price-rubl
    field in-sum0-base   like ub.parts.price-base
    field in-nds-rubl    like ub.parts.price-rubl
    field in-nds-base    like ub.parts.price-base
    field in-sum-rubl    like ub.parts.price-rubl
    field in-sum-base    like ub.parts.price-base
    field out-qnty       like ub.parts.fact-qnty
    field out-nds0-rubl  like ub.parts.price-rubl
    field out-nds0-base  like ub.parts.price-base
    field out-sum0-rubl  like ub.parts.price-rubl
    field out-sum0-base  like ub.parts.price-base
    field out-nds-rubl   like ub.parts.price-rubl
    field out-nds-base   like ub.parts.price-base
    field out-sum-rubl   like ub.parts.price-rubl
    field out-sum-base   like ub.parts.price-base
    field free-qnty      like ub.parts.fact-qnty
    field free-nds0-rubl like ub.parts.price-rubl
    field free-nds0-base like ub.parts.price-base
    field free-sum0-rubl like ub.parts.price-rubl
    field free-sum0-base like ub.parts.price-base
    field free-nds-rubl  like ub.parts.price-rubl
    field free-nds-base  like ub.parts.price-base
    field free-sum-rubl  like ub.parts.price-rubl
    field free-sum-base  like ub.parts.price-base
    field price-sale     as decimal
    field qnty-sale      as integer
    field fs-date        as date
    field ls-date        as date
    index art is primary artic prod-type prod-code s-pay-type ascending
    .
define new shared buffer suppl-gds for sup-gds.
define new shared temp-table sup-parts no-undo
    field artic             like ub.goods.artic
    field prod-type         like ub.clients.obj-type
    field prod-code         like ub.clients.obj-code
    field gds-code          like ub.goods.gds-code
    field gds-name          like ub.goods.gds-name
    field doc-type          like ub.parts.doc-type
    field in-code           like ub.parts.in-code
    field out-code          like ub.parts.out-code
    field fact-date         like ub.parts.fact-date
    field price-cli         like ub.parts.price-cli
    field price0-base       like ub.parts.price-base
    field price0-rubl       like ub.parts.price-rubl
    field price-base        like ub.parts.price-base
    field price-rubl        like ub.parts.price-rubl
    field obj-type          like ub.parts.obj-type
    field obj-code          like ub.parts.obj-code
    field part-code         like ub.parts.part-code
    field in-qnty           like ub.parts.fact-qnty
    field in-sum-cli        like ub.parts.price-cli
    field in-nds0-rubl      like ub.parts.price-rubl
    field in-nds0-base      like ub.parts.price-base
    field in-sum0-rubl      like ub.parts.price-rubl
    field in-sum0-base      like ub.parts.price-base
    field in-nds-rubl       like ub.parts.price-rubl
    field in-nds-base       like ub.parts.price-base
    field in-sum-rubl       like ub.parts.price-rubl
    field in-sum-base       like ub.parts.price-base
    field out-qnty          like ub.parts.fact-qnty
    field out-sum-cli       like ub.parts.price-cli
    field out-nds0-rubl     like ub.parts.price-rubl
    field out-nds0-base     like ub.parts.price-base
    field out-sum0-rubl     like ub.parts.price-rubl
    field out-sum0-base     like ub.parts.price-base
    field out-nds-rubl      like ub.parts.price-rubl
    field out-nds-base      like ub.parts.price-base
    field out-sum-rubl      like ub.parts.price-rubl
    field out-sum-base      like ub.parts.price-base
    field free-qnty         like ub.parts.fact-qnty
    field free-sum-cli      like ub.parts.price-cli
    field free-nds0-rubl    like ub.parts.price-rubl
    field free-nds0-base    like ub.parts.price-base
    field free-sum0-rubl    like ub.parts.price-rubl
    field free-sum0-base    like ub.parts.price-base
    field free-nds-rubl     like ub.parts.price-rubl
    field free-nds-base     like ub.parts.price-base
    field free-sum-rubl     like ub.parts.price-rubl
    field free-sum-base     like ub.parts.price-base
    field p-in-qnty         like ub.parts.fact-qnty
    field p-in-sum-cli      like ub.parts.price-cli
    field p-in-nds0-rubl    like ub.parts.price-rubl
    field p-in-nds0-base    like ub.parts.price-base
    field p-in-sum0-rubl    like ub.parts.price-rubl
    field p-in-sum0-base    like ub.parts.price-base
    field p-in-nds-rubl     like ub.parts.price-rubl
    field p-in-nds-base     like ub.parts.price-base
    field p-in-sum-rubl     like ub.parts.price-rubl
    field p-in-sum-base     like ub.parts.price-base
    field qnty-sale         as integer
    field fs-date           as date
    field ls-date           as date
    field num-doc           as character
    index f-date is primary fact-date ascending
    .
define new shared buffer suppl-parts for sup-parts.
define new shared buffer supplier    for ub.clients.
define new shared buffer b-parts     for ub.parts.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUFFER buf-parts FOR ub.parts.
DEFINE BUFFER b-trn-doc FOR ub.trn-doc.
DEFINE BUFFER b-clients FOR ub.clients.
define variable counter as int init 0 no-undo.
define variable s-pay as char init "" no-undo.
define variable CliAll as log init NO no-undo.
define variable ri-list as char init "" no-undo.
define variable v-date AS CHARACTER NO-UNDO.
define variable rest-date AS DATE NO-UNDO.
define variable in-sum0 AS decimal no-undo.
define variable out-sum0 AS decimal no-undo.
define variable free-noNDS0 AS decimal no-undo.
define variable free-NDS0 AS decimal no-undo.
define variable free-sum0 AS decimal no-undo.
define variable in-sum AS decimal no-undo.
define variable out-sum AS decimal no-undo.
define variable free-sum AS decimal no-undo.
define variable avrg-price-rubl AS decimal no-undo.
define variable avrg-price-base AS decimal no-undo.
define variable sale-price-rubl AS decimal no-undo.
define variable sale-price-base AS decimal no-undo.
define variable fact-order1 like ub.stk-tot.fact-order no-undo .
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable Line as char no-undo.
define variable v-today as date      no-undo.
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable base-type as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable glog as logical no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
find first buf_rep_currency no-lock
where buf_rep_currency.curr-code = v-base-code
no-error .
if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
            else base-type = "б.в." .
DEFINE FRAME supp-gds
sym1 column-label ":!:" format "X(1)"
s-pay column-label " ! " format "X(20)"
sym2 column-label ":!:" format "X(1)"
suppl-gds.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<"
sym3 column-label ":!:" format "X(1)"
in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99"
sym4 column-label ":!:" format "X(1)"
in-sum COLUMN-LABEL "Приход сумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
sym5 column-label ":!:" format "X(1)"
suppl-gds.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<"
sym6 column-label ":!:" format "X(1)"
free-noNDS0 COLUMN-LABEL "Остаток сумма!уч. цен без НДС" FORMAT "->>>,>>>,>>9.99"
sym7 column-label ":!:" format "X(1)"
free-NDS0 COLUMN-LABEL "Остаток сумма!НДС" FORMAT "->>>,>>>,>>9.99"
sym8 column-label ":!:" format "X(1)"
free-sum0 COLUMN-LABEL "Остаток сумма!уч. цен c НДС" FORMAT "->>>,>>>,>>9.99"
sym9 column-label ":!:" format "X(1)"
free-sum COLUMN-LABEL "Остаток cумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
sym10 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Отчет по остаткам товаров" ) AT 45 format "X(95)"
string( "Cуммы указаны в " + (if PrintRubl then "руб" else base-type) ) AT 145 format "X(20)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io.
assign PrintRubl = yes .
run gbl/get-per.w (output glog, input-output v-from-date, input-output v-to-date) .
if NOT glog then  return.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
assign v-date = string( v-today ) .
define variable v-curr-r-b as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
run gbl/d-prompt.w ( 'title=Введите дату\'
                             + 'text1=на которую требуется получить остаток\'
                             + 'format=99/99/9999\'
                             + 'type=date\'
                             + 'fillin_row=2.5\'
                             + 'fillin_col=17\'
                             ,input-output v-date
                           ).
if return-value = 'false':u then do:
  return .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input v-cntxt-obj-type ,
   input v-cntxt-obj-code )
   .
assign rest-date = date( v-date ).
define variable tmp#var  like ub.stk-tot.fact-qnty   no-undo.
Run ostatok  (
    input  v-cntxt-obj-code ,
    input  v-cntxt-obj-type ,
    input  false   ,
    input  rest-date ,
    input  ""        ,
    input  ?          ,
    input  ?           ,
    input  'crsa':U ,
    input  '##,##':U ,
    input  false     ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  Fact-order1 ).
message
"Печатать по всем поставщикам?"
view-as alert-box QUESTION BUTTONS YES-NO TITLE "" UPDATE CliAll.
if NOT CliAll then do:
  run ref/cli-all.w ( input parparentproc
                ,input "b-sel"
                ,input 'все':U
                ,input 'все':U
                ,input 'текущие':U
                ,input ?
                ,input "yes,yes,yes,,,,ИЛИ"
                ,input ?
                ,output ri-list ) .
  if ri-list = "" then assign CliAll = no.
  else do:
      find b-clients where recid ( b-clients ) = integer( ri-list ) no-lock .
  end.
end.
run waitfram-show in this-procedure ( "Подождите..." ).
FOR EACH ub.trn-doc WHERE
        ub.trn-doc.host-code = v-cntxt-host-code-obj
    AND ub.trn-doc.status_ = 'факт':U
    AND ub.trn-doc.fact-date >= v-from-date
    AND ub.trn-doc.fact-date <= v-to-date
    AND ub.trn-doc.doc-type = 'при':U
    AND
        ( ub.trn-doc.internal = no
          OR ( ub.trn-doc.internal = yes AND ub.trn-doc.discnt-type = 'прво':U )
        )
    OR
        ub.trn-doc.host-code = v-cntxt-host-code-obj
    AND ub.trn-doc.status_ = 'факт':U
    AND ub.trn-doc.fact-date >= v-from-date
    AND ub.trn-doc.fact-date <= v-to-date
    AND ub.trn-doc.doc-type = 'инв':U
    NO-LOCK:
  if NOT CliAll AND NOT( ub.trn-doc.cli-type = b-clients.obj-type AND ub.trn-doc.cli-code = b-clients.obj-code ) then
        NEXT.
  FOR EACH ub.doc-line WHERE
          ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK:
    if ub.trn-doc.doc-type = 'инв':U and ub.doc-line.fact-qnty <= 0 then next.
    FIND ub.goods WHERE ub.goods.artic = ub.doc-line.artic
                                      AND ub.goods.prod-type = ub.doc-line.prod-type
                                      AND ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK.
    FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    assign
    sale-price-rubl = 0
    sale-price-base = 0
    .
    FIND LAST ub.price-list WHERE ub.price-list.obj-type = ub.trn-doc.obj-type
                                                    AND ub.price-list.obj-code = ub.trn-doc.obj-code
                                                    AND ub.price-list.artic = ub.goods.artic
                                                    AND ub.price-list.prod-type =  ub.goods.prod-type
                                                    AND ub.price-list.prod-code = ub.goods.prod-code
                                                    AND ub.price-list.b-code = ub.goods.gds-code
                                                    AND ub.price-list.fact-order <= fact-order1
                                                    USE-INDEX fact-close
                                                    NO-LOCK NO-ERROR.
    if available ub.price-list then do:
      if v-curr-r-b = 'rubl':U then do:
          assign sale-price-rubl = ub.price-list.price-sale.
      end.
      else do:
          assign sale-price-base = ub.price-list.price-sale.
      end.
    end.
    FOR EACH ub.gds-dtl WHERE
            ub.gds-dtl.doc-code = ub.trn-doc.doc-code
        AND ub.gds-dtl.artic = ub.doc-line.artic
        AND ub.gds-dtl.prod-type = ub.doc-line.prod-type
        AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
        NO-LOCK:
      ACCUMULATE
      ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty (TOTAL)
      ub.gds-dtl.fact-qnty (TOTAL)
      .
    END.
    if v-curr-r-b = 'rubl':U then do:
      assign
      avrg-price-rubl = ( ACCUM TOTAL ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ) / ( ACCUM TOTAL ub.gds-dtl.fact-qnty )
      avrg-price-base = avrg-price-rubl / ( ub.trn-doc.base-rate * ub.trn-doc.base-scale )
      .
    end.
    else do:
      assign
      avrg-price-base = ( ACCUM TOTAL ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ) / ( ACCUM TOTAL ub.gds-dtl.fact-qnty )
      avrg-price-rubl = avrg-price-base * ( ub.trn-doc.base-rate * ub.trn-doc.base-scale )
      .
    end.
    FOR EACH ub.parts WHERE
            ub.parts.obj-type = ub.trn-doc.obj-type
          AND ub.parts.obj-code = ub.trn-doc.obj-code
          AND ub.parts.artic = ub.doc-line.artic
          AND ub.parts.prod-type = ub.doc-line.prod-type
          AND ub.parts.prod-code = ub.doc-line.prod-code
          AND ub.parts.in-code = ub.trn-doc.doc-code
          AND ub.parts.out-code = ub.trn-doc.doc-code
          NO-LOCK:
      if ub.trn-doc.discnt-type = 'прво':U then
      assign s-pay = 'производство':U.
      else do:
        if ub.parts.pay-code = integer('2':U) then
            assign s-pay = "консигнация".
        else
            assign s-pay = "выкуп".
      end.
assign
  price-rubl-with-tax-loc = parts.price-rubl
  price-base-with-tax-loc = parts.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if parts.out-code = 'free-zone':U     or
     parts.out-code = 'out-zone':U   or
     parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = parts.price-cli
   cli-base-rate          = parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if parts.road-tax-base  = ? then 0 else parts.road-tax-base)
           road-tax-rubl-loc  = (if parts.road-tax-rubl  = ? then 0 else parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if parts.transport-base = ? then 0 else parts.transport-base)
          transport-rubl-loc = (if parts.transport-rubl = ? then 0 else parts.transport-rubl)
          other-base-loc     = (if parts.other-base     = ? then 0 else parts.other-base)
          other-rubl-loc     = (if parts.other-rubl     = ? then 0 else parts.other-rubl)
          vat-pc-loc         = (if parts.vat-pc         = ? then 0 else parts.vat-pc)
          slt-pc-loc         = (if parts.slt-pc         = ? then 0 else parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      FIND suppl-gds WHERE
           suppl-gds.artic = ub.doc-line.artic
        AND suppl-gds.prod-type = ub.doc-line.prod-type
        AND suppl-gds.prod-code = ub.doc-line.prod-code
        AND suppl-gds.s-pay-type = s-pay NO-LOCK NO-ERROR.
      if NOT available suppl-gds then do:
        CREATE suppl-gds.
        assign
        suppl-gds.artic = ub.goods.artic
        suppl-gds.prod-type = ub.goods.prod-type
        suppl-gds.prod-code = ub.goods.prod-code
        suppl-gds.gds-name = ub.goods.gds-name
        suppl-gds.unit-base = ub.goods.unit-base
        suppl-gds.s-pay-type = s-pay
        suppl-gds.in-qnty = ub.parts.fact-qnty
        suppl-gds.in-NDS0-rubl = ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.in-NDS0-base = ub.parts.fact-qnty * vat-base-loc
        suppl-gds.in-sum0-rubl = ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.in-sum0-base = ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.out-qnty = 0
        suppl-gds.out-NDS0-rubl = 0
        suppl-gds.out-NDS0-base = 0
        suppl-gds.out-sum0-rubl = 0
        suppl-gds.out-sum0-base = 0
        suppl-gds.free-qnty = ub.parts.fact-qnty
        suppl-gds.free-NDS0-rubl = ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.free-NDS0-base = ub.parts.fact-qnty * vat-base-loc
        suppl-gds.free-sum0-rubl = ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.free-sum0-base = ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.in-sum-rubl = ub.parts.fact-qnty * avrg-price-rubl
        suppl-gds.in-sum-base = ub.parts.fact-qnty * avrg-price-base
        suppl-gds.out-sum-rubl = 0
        suppl-gds.out-sum-base = 0
        suppl-gds.price-sale = (if v-curr-r-b = 'base':U then sale-price-base else sale-price-rubl)
        .
      end.
      else do:
        assign
        suppl-gds.in-qnty = suppl-gds.in-qnty + ub.parts.fact-qnty
        suppl-gds.in-NDS0-rubl = suppl-gds.in-NDS0-rubl + ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.in-NDS0-base = suppl-gds.in-NDS0-base + ub.parts.fact-qnty * vat-base-loc
        suppl-gds.in-sum0-rubl = suppl-gds.in-sum0-rubl + ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.in-sum0-base = suppl-gds.in-sum0-base + ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.free-qnty = suppl-gds.free-qnty + ub.parts.fact-qnty
        suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl + ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base + ub.parts.fact-qnty * vat-base-loc
        suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl + ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.free-sum0-base = suppl-gds.free-sum0-base + ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.in-sum-rubl = suppl-gds.in-sum-rubl + ub.parts.fact-qnty * avrg-price-rubl
        suppl-gds.in-sum-base = suppl-gds.in-sum-base + ub.parts.fact-qnty * avrg-price-base
        .
      end.
      FOR EACH buf-parts WHERE
              buf-parts.artic = ub.parts.artic
          AND buf-parts.prod-type = ub.parts.prod-type
          AND buf-parts.prod-code = ub.parts.prod-code
          AND buf-parts.in-code = ub.parts.in-code
          AND buf-parts.out-code <> ub.parts.out-code
          AND buf-parts.part-code = ub.parts.part-code
          AND buf-parts.rsrv-free = ?
          AND buf-parts.doc-type <> 'акт':U
          AND buf-parts.status_ = yes
          NO-LOCK:
        FIND b-trn-doc WHERE b-trn-doc.doc-code = buf-parts.out-code NO-LOCK.
        if ( b-trn-doc.internal = no
             OR ( b-trn-doc.doc-type = 'спи':U
                 AND b-trn-doc.internal = yes
                 AND b-trn-doc.discnt-type = 'прво':U ) )
            AND b-trn-doc.fact-date < rest-date then  do:
assign
  price-rubl-with-tax-loc = buf-parts.price-rubl
  price-base-with-tax-loc = buf-parts.price-base
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf-parts.out-code = 'free-zone':U     or
     buf-parts.out-code = 'out-zone':U   or
     buf-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf-parts.price-cli
   cli-base-rate          = buf-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf-parts.road-tax-base  = ? then 0 else buf-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf-parts.road-tax-rubl  = ? then 0 else buf-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf-parts.transport-base = ? then 0 else buf-parts.transport-base)
          transport-rubl-loc = (if buf-parts.transport-rubl = ? then 0 else buf-parts.transport-rubl)
          other-base-loc     = (if buf-parts.other-base     = ? then 0 else buf-parts.other-base)
          other-rubl-loc     = (if buf-parts.other-rubl     = ? then 0 else buf-parts.other-rubl)
          vat-pc-loc         = (if buf-parts.vat-pc         = ? then 0 else buf-parts.vat-pc)
          slt-pc-loc         = (if buf-parts.slt-pc         = ? then 0 else buf-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            CASE b-trn-doc.doc-type:
              WHEN 'рас':U
              OR WHEN 'спи':U
              THEN do:
                  assign
                  suppl-gds.out-qnty = suppl-gds.out-qnty + buf-parts.fact-qnty
                  suppl-gds.out-NDS0-rubl = suppl-gds.out-NDS0-rubl + buf-parts.fact-qnty * vat-rubl-loc
                  suppl-gds.out-NDS0-base = suppl-gds.out-NDS0-base + buf-parts.fact-qnty * vat-base-loc
                  suppl-gds.out-sum0-rubl = suppl-gds.out-sum0-rubl + buf-parts.fact-qnty * price-rubl-with-tax-loc
                  suppl-gds.out-sum0-base = suppl-gds.out-sum0-base + buf-parts.fact-qnty * price-base-with-tax-loc
                  suppl-gds.free-qnty = suppl-gds.free-qnty - buf-parts.fact-qnty
                  suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl - buf-parts.fact-qnty * vat-rubl-loc
                  suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base - buf-parts.fact-qnty * vat-base-loc
                  suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl - buf-parts.fact-qnty * price-rubl-with-tax-loc
                  suppl-gds.free-sum0-base = suppl-gds.free-sum0-base - buf-parts.fact-qnty * price-base-with-tax-loc
                  .
              end.
              WHEN 'при':U
              OR
              WHEN 'возврат':U
              OR
              WHEN 'инв':U
              THEN do:
                assign
                suppl-gds.out-qnty = suppl-gds.out-qnty - buf-parts.fact-qnty
                suppl-gds.out-NDS0-rubl = suppl-gds.out-NDS0-rubl - buf-parts.fact-qnty * vat-rubl-loc
                suppl-gds.out-NDS0-base = suppl-gds.out-NDS0-base - buf-parts.fact-qnty * vat-base-loc
                suppl-gds.out-sum0-rubl = suppl-gds.out-sum0-rubl - buf-parts.fact-qnty * price-rubl-with-tax-loc
                suppl-gds.out-sum0-base = suppl-gds.out-sum0-base - buf-parts.fact-qnty * price-base-with-tax-loc
                suppl-gds.free-qnty = suppl-gds.free-qnty + buf-parts.fact-qnty
                suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl + buf-parts.fact-qnty * vat-rubl-loc
                suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base + buf-parts.fact-qnty * vat-base-loc
                suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl + buf-parts.fact-qnty * price-rubl-with-tax-loc
                suppl-gds.free-sum0-base = suppl-gds.free-sum0-base + buf-parts.fact-qnty * price-base-with-tax-loc
                .
              end.
            END CASE.
          end.
        END.
      END.
    END.
    assign counter = counter + 1.
    run waitfram-show in this-procedure ( string( "Просмотрено документов: " + string( counter ) ) ).
  END.
if session:set-wait-state("COMPILER") then.
assign Line = fill("-", 232).
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM with FRAME supp-gds.
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width 232
PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .
PUT STREAM PrnLibStream
string( "О Т Ч Е Т   П О   О С Т А Т К А М  на: " + string(rest-date,"99/99/9999") ) AT 62 format "X(198)"
SKIP
string( "Период поставок с: " + string(v-from-date,"99/99/9999") + " по: " + string(v-to-date,"99/99/9999") )
            AT 62 format "X(198)"
SKIP(1)
.
PUT STREAM PrnLibStream " " SKIP.
FOR EACH suppl-gds NO-LOCK,
        EACH ub.goods WHERE
            ub.goods.artic = suppl-gds.artic
        AND ub.goods.prod-type = suppl-gds.prod-type
        AND ub.goods.prod-code = suppl-gds.prod-code
        NO-LOCK
BREAK
BY ub.goods.grp-name
BY suppl-gds.s-pay-type:
  if FIRST-OF (ub.goods.grp-name) then do:
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
    PUT STREAM PrnLibStream SPACE(20) string("Группа: " + ub.goods.grp-name) format "X(100)".
  end.
  ACCUMULATE
  suppl-gds.in-qnty (TOTAL)
  suppl-gds.in-NDS0-rubl (TOTAL)
  suppl-gds.in-NDS0-base (TOTAL)
  suppl-gds.in-sum0-rubl (TOTAL)
  suppl-gds.in-sum0-base (TOTAL)
  suppl-gds.in-sum-rubl (TOTAL)
  suppl-gds.in-sum-base (TOTAL)
  suppl-gds.out-qnty (TOTAL)
  suppl-gds.out-NDS0-rubl (TOTAL)
  suppl-gds.out-NDS0-base (TOTAL)
  suppl-gds.out-sum0-rubl (TOTAL)
  suppl-gds.out-sum0-base (TOTAL)
  suppl-gds.free-qnty (TOTAL)
  suppl-gds.free-NDS0-rubl (TOTAL)
  suppl-gds.free-NDS0-base (TOTAL)
  suppl-gds.free-sum0-rubl (TOTAL)
  suppl-gds.free-sum0-base (TOTAL)
  (suppl-gds.free-qnty * suppl-gds.price-sale) (TOTAL)
  suppl-gds.in-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  (suppl-gds.free-qnty * suppl-gds.price-sale) (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  (suppl-gds.free-qnty * suppl-gds.price-sale) (SUB-TOTAL BY suppl-gds.s-pay-type )
  .
  if LAST-OF (suppl-gds.s-pay-type) then do:
    if PrintRubl then do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum0-rubl)
      in-sum = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum-rubl)
      out-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.out-sum0-rubl)
      free-NDS0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-NDS0-rubl)
      free-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-sum0-rubl)
      free-sum = if v-curr-r-b = 'rubl':U
                  then  (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    else do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum0-base)
      in-sum = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum-base)
      out-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.out-sum0-base)
      free-NDS0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-NDS0-base)
      free-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-sum0-base)
      free-sum = if v-curr-r-b = 'base':U
                  then (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    DISPLAY STREAM PrnLibStream
    sym1
    suppl-gds.s-pay-type @ s-pay
    sym2
    (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-qnty) @ suppl-gds.in-qnty
    sym3
    in-sum0
    sym4
    in-sum
    sym5
    (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-qnty) @ suppl-gds.free-qnty
    sym6
    free-noNDS0
    sym7
    free-NDS0
    sym8
    free-sum0
    sym9
    free-sum
    sym10
    with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
  end.
  if LAST-OF (ub.goods.grp-name) then do:
    if PrintRubl then do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum0-rubl)
      in-sum = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum-rubl)
      out-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.out-sum0-rubl)
      free-NDS0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-NDS0-rubl)
      free-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-sum0-rubl)
      free-sum = if v-curr-r-b = 'rubl':U
                  then (ACCUM SUB-TOTAL BY ub.goods.grp-name (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    else do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum0-base)
      in-sum = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum-base)
      out-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.out-sum0-base)
      free-NDS0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-NDS0-base)
      free-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-sum0-base)
      free-sum = (if v-curr-r-b = 'base':U
                  then (ACCUM SUB-TOTAL BY ub.goods.grp-name (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0)
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    DISPLAY STREAM PrnLibStream
    "Итого" @ s-pay
    (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-qnty) @ suppl-gds.in-qnty
    in-sum0
    in-sum
    (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-qnty) @ suppl-gds.free-qnty
    free-noNDS0
    free-NDS0
    free-sum0
    free-sum
    with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
  end.
END.
if PrintRubl then do:
  assign
  in-sum0 = (ACCUM TOTAL suppl-gds.in-sum0-rubl)
  in-sum = (ACCUM TOTAL suppl-gds.in-sum-rubl)
  out-sum0 = (ACCUM TOTAL suppl-gds.out-sum0-rubl)
  free-NDS0 = (ACCUM TOTAL suppl-gds.free-NDS0-rubl)
  free-sum0 = (ACCUM TOTAL suppl-gds.free-sum0-rubl)
  free-sum = (if v-curr-r-b = 'rubl':U
              then (ACCUM TOTAL (suppl-gds.free-qnty * suppl-gds.price-sale) )
              else 0)
  free-noNDS0 = free-sum0 - free-NDS0
  .
end.
else do:
  assign
  in-sum0 = (ACCUM TOTAL suppl-gds.in-sum0-base)
  in-sum = (ACCUM TOTAL suppl-gds.in-sum-base)
  out-sum0 = (ACCUM TOTAL suppl-gds.out-sum0-base)
  free-NDS0 = (ACCUM TOTAL suppl-gds.free-NDS0-base)
  free-sum0 = (ACCUM TOTAL suppl-gds.free-sum0-base)
  free-sum = (if v-curr-r-b = 'base':U
                  then (ACCUM TOTAL (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0)
  free-noNDS0 = free-sum0 - free-NDS0
  .
end.
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
DISPLAY STREAM PrnLibStream
"Итого по всем" @ s-pay
(ACCUM TOTAL suppl-gds.in-qnty) @ suppl-gds.in-qnty
in-sum0
in-sum
(ACCUM TOTAL suppl-gds.free-qnty) @ suppl-gds.free-qnty
free-noNDS0
free-NDS0
free-sum0
free-sum
with FRAME supp-gds .
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
OUTPUT STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
