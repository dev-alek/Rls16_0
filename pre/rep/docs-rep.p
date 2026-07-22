block-level on error undo, throw.
define input  parameter p-title             as character no-undo .
define input  parameter p-sale-base         as logical   no-undo .
define input  parameter p-sale-rubl         as logical   no-undo .
define input  parameter p-crsa-base-doc    as logical   no-undo .
define input  parameter p-crsa-Rubl-doc    as logical   no-undo .
define input  parameter p-sale-base-doc    as logical   no-undo .
define input  parameter p-sale-rubl-doc    as logical   no-undo .
define input  parameter pVal-BruttoSaleSum  as logical   no-undo .
define input  parameter pRubl-BruttoSaleSum as logical   no-undo .
define input  parameter pVal-NettoSaleSum   as logical   no-undo .
define input  parameter pRubl-NettoSaleSum  as logical   no-undo .
define input  parameter pVal-DiscntSum      as logical   no-undo .
define input  parameter pRubl-DiscntSum     as logical   no-undo .
define input  parameter pVal-CostSum        as logical   no-undo .
define input  parameter pRubl-CostSum       as logical   no-undo .
define input  parameter pVal-Effect         as logical   no-undo .
define input  parameter pRubl-Effect        as logical   no-undo .
define input  parameter pDiscnt-PC          as logical   no-undo .
define input  parameter pTorgPred           as logical   no-undo .
define input  parameter pUp-PC              as logical   no-undo .
define input  parameter pOperator           as logical   no-undo .
define input  parameter pPayType            as logical   no-undo .
define input  parameter pKurs               as logical   no-undo .
define input  parameter pOur-Obj            as logical   no-undo .
define input  parameter pKladov             as logical   no-undo .
define input  parameter pIspName            as logical   no-undo .
define input  parameter pPayWaitDate        as logical   no-undo .
define input  parameter pNDS-Val            as logical   no-undo .
define input  parameter p-detal-NDS-Val     as logical   no-undo .
define input  parameter pNDS-Rubl           as logical   no-undo .
define input  parameter p-detal-NDS-Rubl    as logical   no-undo .
define input  parameter pNums               as logical   no-undo .
define input  parameter pNums-doc           as logical   no-undo .
define input  parameter p-ps                as logical   no-undo .
define input  parameter p-continue          as logical   no-undo .
define input  parameter g#report-num        as integer   no-undo .
define output parameter p-frame-width       as integer   no-undo .
def var vss-revision    as character no-undo init "$Revision: 16a79e67eba9, 1355, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri May 18 13:28:42 2018 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: docs-rep.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/docs-rep.p $":U .
def var vss-description as character no-undo init "Печать документов из списка документов".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
DEFINE  shared TEMP-TABLE wt-docs no-undo
  field ext-doc-type as character
  FIELD acc-date    AS DATE      COLUMN-LABEL "Дата проводки"
  FIELD agnt        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Исполнитель"
  FIELD base-rate   AS DECIMAL   FORMAT ">>,>>9.99" COLUMN-LABEL "Курс"
  FIELD base-scale  AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Масштаб"
  FIELD boss        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Менеджер"
  FIELD cli-code    AS INTEGER   FORMAT "99999" COLUMN-LABEL "Код"
  FIELD cli-name    AS CHARACTER FORMAT "X(40)" COLUMN-LABEL "Контрагент"
  FIELD cli-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент"
  FIELD creid       AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Создал"
  FIELD ctr-num     AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент! !"
  FIELD discnt-pc   AS DECIMAL   FORMAT "->9.9%" COLUMN-LABEL "Скидка"
  FIELD discnt-rubl AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка"
  FIELD discnt-type AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Скидка"
  FIELD doc-code    AS CHARACTER FORMAT "X(14)" COLUMN-LABEL "Номер"
  FIELD doc-date    AS DATE      COLUMN-LABEL "Дата"
  FIELD doc-qnty    AS DECIMAL   FORMAT "->>,>>>,>>9.<<<" COLUMN-LABEL "Заявлено"
  FIELD doc-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Тип"
  FIELD exch-code   AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Валюта"
  FIELD exch-date   AS DATE      COLUMN-LABEL "Таможня"
  FIELD exch-rate   AS DECIMAL   FORMAT ">>,>>9.99"
  COLUMN-LABEL "Курс"
  FIELD exch-scale  AS INTEGER   FORMAT ">>9"
  COLUMN-LABEL "Масштаб"
  FIELD fact-base   AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD fact-date   AS DATE
  COLUMN-LABEL "факт"
  FIELD fact-num    AS INTEGER
  FIELD fact-qnty   AS DECIMAL   FORMAT "->>,>>>,>>9.<<<"
  COLUMN-LABEL "Фактически"
  FIELD fact-rubl   AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD flag_       AS LOGICAL   COLUMN-LABEL "Закр"
  FIELD internal    AS LOGICAL   COLUMN-LABEL "Внутр"
  FIELD inv-num     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Инвойс"
  FIELD obj-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Код"
  FIELD obj-type    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "ПО ОБЪЕКТАМ"
  FIELD office      AS LOGICAL
  FIELD ord-num     AS CHAR FORMAT "x(14)"
  COLUMN-LABEL "заказ"
  FIELD out-code    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Номер РН"
  FIELD ov          AS LOGICAL   FORMAT "+/-"
  COLUMN-LABEL "Акт переоценки"
  FIELD pay-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Оплата"
  FIELD print-rubl  AS LOGICAL
  COLUMN-LABEL "Рублевая"
  FIELD PS          AS CHARACTER FORMAT "X(50)"
  COLUMN-LABEL "Примечание"
  FIELD ship-date   AS DATE      COLUMN-LABEL "Дата"
  FIELD ship-num    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Отгрузка"
  FIELD status_     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "статус"
  FIELD tot-calc    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "Расчет"
  FIELD tot-cli     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По ТТН"
  FIELD tot-doc     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-fact    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD tot-ov      AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По акту"
  FIELD tot-rubl    AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-sale    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD wrkr        AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Кладовщик"
  FIELD host-code AS INTEGER   FORMAT "99999" COLUMN-LABEL "Фирма"
    field vat-type      as character
    field vat-base      as decimal
    field vat-rubl      as decimal
    field vat18-base    as decimal
    field vat18-rubl    as decimal
    field vat10-base    as decimal
    field vat10-rubl    as decimal
    field vat-on        as logical
    field doc-attr      as character
    field OurObjectName like ub.clients.obj-name
    field pay-name      like ub.pay-type.obj-name
    field Oper_Name     as character
    field Mngr_Name     as character
    field Wrkr_name     as character
    field Course        as decimal
    field pay-waitdate  as date
    field Isp-Name      as character
    field SLT-base      like ub.trn-doc.SLT-base
    field SLT-rubl      like ub.trn-doc.SLT-rubl
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field doc-qnty               like ub.doc-line.doc-qnty
field sum-dsc-base-doc-acc   like ub.doc-line.price-base
field sum-dsc-rubl-doc-acc   like ub.doc-line.price-base
field sum-dsc-cli-doc-acc    like ub.doc-line.price-cli
field dsc-base-doc-acc       like ub.doc-line.price-base
field dsc-rubl-doc-acc       like ub.doc-line.price-base
field dsc-cli-doc-acc        like ub.doc-line.price-cli
field vat-base-doc-acc       like ub.doc-line.price-base
field vat-rubl-doc-acc       like ub.doc-line.price-base
field vat-cli-doc-acc        like ub.doc-line.price-cli
field sum-dsc-base-doc-cur   like ub.doc-line.price-base
field sum-dsc-rubl-doc-cur   like ub.doc-line.price-base
field sum-dsc-base-doc-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc-doc   like ub.doc-line.price-base
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field doc-qnty               like ub.doc-line.doc-qnty
field sum-dsc-base-doc-acc   like ub.doc-line.price-base
field sum-dsc-rubl-doc-acc   like ub.doc-line.price-base
field sum-dsc-cli-doc-acc    like ub.doc-line.price-cli
field dsc-base-doc-acc       like ub.doc-line.price-base
field dsc-rubl-doc-acc       like ub.doc-line.price-base
field dsc-cli-doc-acc        like ub.doc-line.price-cli
field vat-base-doc-acc       like ub.doc-line.price-base
field vat-rubl-doc-acc       like ub.doc-line.price-base
field vat-cli-doc-acc        like ub.doc-line.price-cli
field sum-dsc-base-doc-cur   like ub.doc-line.price-base
field sum-dsc-rubl-doc-cur   like ub.doc-line.price-base
field dsc-base-doc-cur       like ub.doc-line.price-base
field dsc-rubl-doc-cur       like ub.doc-line.price-base
field vat-base-doc-cur       like ub.doc-line.price-base
field vat-rubl-doc-cur       like ub.doc-line.price-base
field sum-dsc-base-doc-doc      as decimal
field sum-dsc-rubl-doc-doc      as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-doc-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.qnty)
  bf_tt-allsum.sum-dsc-rubl-doc-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.qnty)
  bf_tt-allsum.sum-dsc-base-doc-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.qnty)
  bf_tt-allsum.sum-dsc-rubl-doc-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
assign
  bf_tt-allsum.doc-qnty                 =  cl_tt-clcparts.qnty
  bf_tt-allsum.sum-dsc-base-doc-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.qnty)
  bf_tt-allsum.sum-dsc-rubl-doc-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.qnty)
  bf_tt-allsum.sum-dsc-cli-doc-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.qnty)
  bf_tt-allsum.dsc-base-doc-acc         = 0
  bf_tt-allsum.dsc-rubl-doc-acc         = 0
  bf_tt-allsum.dsc-cli-doc-acc          = 0
  bf_tt-allsum.vat-base-doc-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.qnty)
  bf_tt-allsum.vat-rubl-doc-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.qnty)
  bf_tt-allsum.vat-cli-doc-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.qnty)
  .
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
    assign
    bfs_tt-allsum.sum-dsc-base-doc-acc    =  - bf_tt-allsum.sum-dsc-base-doc-acc
    bfs_tt-allsum.sum-dsc-rubl-doc-acc    =  - bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfs_tt-allsum.sum-dsc-cli-doc-acc     =  - bf_tt-allsum.sum-dsc-cli-doc-acc
    bfs_tt-allsum.dsc-base-doc-acc        =  - bf_tt-allsum.dsc-base-doc-acc
    bfs_tt-allsum.dsc-rubl-doc-acc        =  - bf_tt-allsum.dsc-rubl-doc-acc
    bfs_tt-allsum.dsc-cli-doc-acc         =  - bf_tt-allsum.dsc-cli-doc-acc
    bfs_tt-allsum.vat-base-doc-acc        =  - bf_tt-allsum.vat-base-doc-acc
    bfs_tt-allsum.vat-rubl-doc-acc        =  - bf_tt-allsum.vat-rubl-doc-acc
    bfs_tt-allsum.vat-cli-doc-acc         =  - bf_tt-allsum.vat-cli-doc-acc
    bfs_tt-allsum.sum-dsc-base-doc-cur    =  - bf_tt-allsum.sum-dsc-base-doc-cur
    bfs_tt-allsum.sum-dsc-rubl-doc-cur    =  - bf_tt-allsum.sum-dsc-rubl-doc-cur
    bfs_tt-allsum.sum-dsc-base-doc-doc    =  - bf_tt-allsum.sum-dsc-base-doc-doc
    bfs_tt-allsum.sum-dsc-rubl-doc-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc-doc
    .
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
assign
    bfpc_tt-allsum.sum-dsc-base-doc-doc    = bf_tt-allsum.sum-dsc-base-doc-doc    - bf_tt-allsum.sum-dsc-base-doc-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc-doc    = bf_tt-allsum.sum-dsc-rubl-doc-doc    - bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfpc_tt-allsum.sum-dsc-base-doc-cur    = bf_tt-allsum.sum-dsc-base-doc-cur - bf_tt-allsum.sum-dsc-base-doc-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc-cur    = bf_tt-allsum.sum-dsc-rubl-doc-cur - bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfpc_tt-allsum.sum-dsc-base-doc-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-doc-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-doc-acc     = 0
    bfpc_tt-allsum.dsc-base-doc-acc        = 0
    bfpc_tt-allsum.dsc-rubl-doc-acc        = 0
    bfpc_tt-allsum.dsc-cli-doc-acc         = 0
    bfpc_tt-allsum.vat-base-doc-acc        = 0
    bfpc_tt-allsum.vat-rubl-doc-acc        = 0
    bfpc_tt-allsum.vat-cli-doc-acc         = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
    assign
    bfspc_tt-allsum.sum-dsc-base-doc-doc    = bfs_tt-allsum.sum-dsc-base-doc-doc    - bfs_tt-allsum.sum-dsc-base-doc-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc-doc    = bfs_tt-allsum.sum-dsc-rubl-doc-doc    - bfs_tt-allsum.sum-dsc-rubl-doc-acc
    bfpc_tt-allsum.sum-dsc-base-doc-cur    = bf_tt-allsum.sum-dsc-base-doc-cur    - bf_tt-allsum.sum-dsc-base-doc-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc-cur    = bf_tt-allsum.sum-dsc-rubl-doc-cur    - bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfspc_tt-allsum.sum-dsc-base-doc-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-doc-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-doc-acc     = 0
    bfspc_tt-allsum.dsc-base-doc-acc        = 0
    bfspc_tt-allsum.dsc-rubl-doc-acc        = 0
    bfspc_tt-allsum.dsc-cli-doc-acc         = 0
    bfspc_tt-allsum.vat-base-doc-acc        = 0
    bfspc_tt-allsum.vat-rubl-doc-acc        = 0
    bfspc_tt-allsum.vat-cli-doc-acc         = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
assign
    bfacc_tt-allsum.sum-dsc-base-doc-doc    = bf_tt-allsum.sum-dsc-base-doc-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc-doc    = bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfacc_tt-allsum.sum-dsc-base-doc-cur    = bf_tt-allsum.sum-dsc-base-doc-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc-cur    = bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfacc_tt-allsum.sum-dsc-base-doc-acc    = bf_tt-allsum.sum-dsc-base-doc-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc-acc    = bf_tt-allsum.sum-dsc-rubl-doc-acc
    bfacc_tt-allsum.sum-dsc-cli-doc-acc     = bf_tt-allsum.sum-dsc-cli-doc-acc
    bfacc_tt-allsum.dsc-base-doc-acc        = bf_tt-allsum.dsc-base-doc-acc
    bfacc_tt-allsum.dsc-rubl-doc-acc        = bf_tt-allsum.dsc-rubl-doc-acc
    bfacc_tt-allsum.dsc-cli-doc-acc         = bf_tt-allsum.dsc-cli-doc-acc
    bfacc_tt-allsum.vat-base-doc-acc        = bf_tt-allsum.vat-base-doc-acc
    bfacc_tt-allsum.vat-rubl-doc-acc        = bf_tt-allsum.vat-rubl-doc-acc
    bfacc_tt-allsum.vat-cli-doc-acc         = bf_tt-allsum.vat-cli-doc-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
    assign
    bfsacc_tt-allsum.sum-dsc-base-doc-doc    = bfs_tt-allsum.sum-dsc-base-doc-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc-doc    = bfs_tt-allsum.sum-dsc-rubl-doc-acc
    bfsacc_tt-allsum.sum-dsc-base-doc-cur    = bfs_tt-allsum.sum-dsc-base-doc-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc-cur    = bfs_tt-allsum.sum-dsc-rubl-doc-acc
    bfsacc_tt-allsum.sum-dsc-base-doc-acc    = bfs_tt-allsum.sum-dsc-base-doc-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc-acc    = bfs_tt-allsum.sum-dsc-rubl-doc-acc
    bfsacc_tt-allsum.sum-dsc-cli-doc-acc     = bfs_tt-allsum.sum-dsc-cli-doc-acc
    bfsacc_tt-allsum.dsc-base-doc-acc        = bfs_tt-allsum.dsc-base-doc-acc
    bfsacc_tt-allsum.dsc-rubl-doc-acc        = bfs_tt-allsum.dsc-rubl-doc-acc
    bfsacc_tt-allsum.dsc-cli-doc-acc         = bfs_tt-allsum.dsc-cli-doc-acc
    bfsacc_tt-allsum.vat-base-doc-acc        = bfs_tt-allsum.vat-base-doc-acc
    bfsacc_tt-allsum.vat-rubl-doc-acc        = bfs_tt-allsum.vat-rubl-doc-acc
    bfsacc_tt-allsum.vat-cli-doc-acc         = bfs_tt-allsum.vat-cli-doc-acc
  .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
        assign
          bf_tt-allsum-line.sum-dsc-base-doc-doc     =  bf_tt-allsum-line.sum-dsc-base-doc-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-rubl-doc-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-base-doc-cur     =  bf_tt-allsum-line.sum-dsc-base-doc-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-rubl-doc-cur     =  bf_tt-allsum-line.sum-dsc-rubl-doc-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-base-doc-acc     =  bf_tt-allsum-line.sum-dsc-base-doc-acc + bf_doc-line.price-base * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-rubl-doc-acc     =  bf_tt-allsum-line.sum-dsc-rubl-doc-acc + bf_doc-line.price-rubl * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.sum-dsc-cli-doc-acc      =  ?
          bf_tt-allsum-line.vat-base-doc-acc         =  bf_tt-allsum-line.vat-base-doc-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.vat-rubl-doc-acc         =  bf_tt-allsum-line.vat-rubl-doc-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.doc-qnty
          bf_tt-allsum-line.vat-cli-doc-acc          =  ?
       .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
      assign
      bf_tt-allsum-line.dsc-base-doc-acc         =  0
      bf_tt-allsum-line.dsc-rubl-doc-acc         =  0
      bf_tt-allsum-line.dsc-cli-doc-acc          =  0
    .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
        assign
        bfs_tt-allsum-line.sum-dsc-base-doc-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc-doc
        bfs_tt-allsum-line.sum-dsc-base-doc-cur    =  - bf_tt-allsum-line.sum-dsc-base-doc-cur
        bfs_tt-allsum-line.sum-dsc-rubl-doc-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-doc-cur
        bfs_tt-allsum-line.sum-dsc-base-doc-acc    =  - bf_tt-allsum-line.sum-dsc-base-doc-acc
        bfs_tt-allsum-line.sum-dsc-rubl-doc-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc-acc
        bfs_tt-allsum-line.sum-dsc-cli-doc-acc     =  - bf_tt-allsum-line.sum-dsc-cli-doc-acc
        bfs_tt-allsum-line.dsc-base-doc-acc        =  - bf_tt-allsum-line.dsc-base-doc-acc
        bfs_tt-allsum-line.dsc-rubl-doc-acc        =  - bf_tt-allsum-line.dsc-rubl-doc-acc
        bfs_tt-allsum-line.dsc-cli-doc-acc         =  - bf_tt-allsum-line.dsc-cli-doc-acc
        bfs_tt-allsum-line.vat-base-doc-acc        =  - bf_tt-allsum-line.vat-base-doc-acc
        bfs_tt-allsum-line.vat-rubl-doc-acc        =  - bf_tt-allsum-line.vat-rubl-doc-acc
        bfs_tt-allsum-line.vat-cli-doc-acc         =  - bf_tt-allsum-line.vat-cli-doc-acc
      .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info15 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
      assign
      bf_tt-allsum-line.sum-dsc-base-doc-doc       = bf_tt-allsum-line.sum-dsc-base-doc-doc     + bf_tt-allsum.sum-dsc-base-doc-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc-doc     + bf_tt-allsum.sum-dsc-rubl-doc-doc
      bf_tt-allsum-line.sum-dsc-base-doc-cur       = bf_tt-allsum-line.sum-dsc-base-doc-cur     + bf_tt-allsum.sum-dsc-base-doc-cur
      bf_tt-allsum-line.sum-dsc-rubl-doc-cur       = bf_tt-allsum-line.sum-dsc-rubl-doc-cur     + bf_tt-allsum.sum-dsc-rubl-doc-cur
      bf_tt-allsum-line.sum-dsc-base-doc-acc       = bf_tt-allsum-line.sum-dsc-base-doc-acc     + bf_tt-allsum.sum-dsc-base-doc-acc
      bf_tt-allsum-line.sum-dsc-rubl-doc-acc       = bf_tt-allsum-line.sum-dsc-rubl-doc-acc     + bf_tt-allsum.sum-dsc-rubl-doc-acc
      bf_tt-allsum-line.sum-dsc-cli-doc-acc        = bf_tt-allsum-line.sum-dsc-cli-doc-acc      + bf_tt-allsum.sum-dsc-cli-doc-acc
      bf_tt-allsum-line.dsc-base-doc-acc           = bf_tt-allsum-line.dsc-base-doc-acc         + bf_tt-allsum.dsc-base-doc-acc
      bf_tt-allsum-line.dsc-rubl-doc-acc           = bf_tt-allsum-line.dsc-rubl-doc-acc         + bf_tt-allsum.dsc-rubl-doc-acc
      bf_tt-allsum-line.dsc-cli-doc-acc            = bf_tt-allsum-line.dsc-cli-doc-acc          + bf_tt-allsum.dsc-cli-doc-acc
      bf_tt-allsum-line.vat-base-doc-acc           = bf_tt-allsum-line.vat-base-doc-acc         + bf_tt-allsum.vat-base-doc-acc
      bf_tt-allsum-line.vat-rubl-doc-acc           = bf_tt-allsum-line.vat-rubl-doc-acc         + bf_tt-allsum.vat-rubl-doc-acc
      bf_tt-allsum-line.vat-cli-doc-acc            = bf_tt-allsum-line.vat-cli-doc-acc          + bf_tt-allsum.vat-cli-doc-acc
    .
  end.
end.
end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE stream DocsStream .
def     buffer  b-wt-docs           for     wt-docs .
define variable DifferentTypes      as logical   no-undo .
define variable Line                as character no-undo .
define variable By-Opt              as character no-undo .
define variable sym1                as character no-undo init ":" .
define variable sym10               as character no-undo init ":" .
define variable i                   as integer   no-undo .
define variable Qnty                as decimal   no-undo .
define variable Val-BruttoSaleSum   as decimal   no-undo .
define variable Rubl-BruttoSaleSum  as decimal   no-undo .
define variable Val-NettoSaleSum    as decimal   no-undo .
define variable Rubl-NettoSaleSum   as decimal   no-undo .
define variable Val-DiscntSum       as decimal   no-undo .
define variable Rubl-DiscntSum      as decimal   no-undo .
define variable Val-CostSum         as decimal   no-undo .
define variable Rubl-CostSum        as decimal   no-undo .
define variable Val-Effect          as decimal   no-undo .
define variable Rubl-Effect         as decimal   no-undo .
define variable Discnt-PC           as character no-undo .
define variable TorgPred            as character no-undo .
define variable Up-PC               as character no-undo .
define variable Operator            as character no-undo .
define variable PayType             as character no-undo .
define variable Kurs                as decimal   no-undo .
define variable Our-Obj             as character no-undo .
define variable KladovName          as character no-undo .
define variable IspName             as character no-undo .
define variable PayWaitDate         as date      no-undo .
define variable NDS-Val             as decimal   no-undo .
define variable NDS18-Val           as decimal   no-undo .
define variable NDS10-Val           as decimal   no-undo .
define variable NDS-Rubl            as decimal   no-undo .
define variable NDS18-Rubl          as decimal   no-undo .
define variable NDS10-Rubl          as decimal   no-undo .
define variable v-ind               as integer   no-undo .
DEFINE VARIABLE for-doc-attr like   wt-docs.doc-attr no-undo .
DEFINE VARIABLE for-doc-date like   wt-docs.doc-date no-undo .
DEFINE VARIABLE for-fact-date like  wt-docs.fact-date no-undo .
DEFINE VARIABLE for-doc-code like   wt-docs.doc-code no-undo .
DEFINE VARIABLE for-cli-name like   wt-docs.cli-name no-undo .
define variable v-vat18-base    as logical      no-undo.
define variable v-vat10-base    as logical      no-undo.
define variable v-vat18-rubl    as logical      no-undo.
define variable v-vat10-rubl    as logical      no-undo.
define variable sale-base       as decimal   no-undo .
define variable sale-rubl       as decimal   no-undo .
define variable sale-base-doc as decimal   no-undo .
define variable sale-rubl-doc as decimal   no-undo .
define variable crsa-base-doc as decimal   no-undo .
define variable crsa-rubl-doc as decimal   no-undo .
define variable Qnty-doc      as decimal   no-undo .
define variable comm as character no-undo .
DEFINE VARIABLE fill8               as character no-undo .
DEFINE VARIABLE fill11              as character no-undo .
DEFINE VARIABLE fill12              as character no-undo .
DEFINE VARIABLE fill15              as character no-undo .
DEFINE VARIABLE fill18              as character no-undo .
DEFINE VARIABLE fill19              as character no-undo .
DEFINE VARIABLE fill21              as character no-undo .
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 5 NO-UNDO.
DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
cur-time-print() AT 5 format "x(35)"
string( "Страница" ) AT 45 PAGE-NUMBER( DOcsStream ) AT 55 FORMAT ">>>,>>9" SKIP
    with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME x1
with width 232 down stream-io use-text NO-BOX.
if p-detal-NDS-Val = yes
then do:
    assign
        v-vat18-base = yes
        v-vat10-base = yes
    .
end.
if p-detal-NDS-Rubl = yes
then do:
    assign
        v-vat18-rubl = yes
        v-vat10-rubl = yes
    .
end.
assign
  use-column[1] =  yes
  use-column[2] =  yes
  use-column[3] =  yes
  use-column[4] =  yes
  use-column[5] =  yes
  use-column[6] =  pNums
  use-column[7] =  pVal-BruttoSaleSum
  use-column[8] =  pRubl-BruttoSaleSum
  use-column[9] =  pVal-NettoSaleSum
  use-column[10] = pRubl-NettoSaleSum
  use-column[11] = pVal-DiscntSum
  use-column[12] = pRubl-DiscntSum
  use-column[13] = pVal-CostSum
  use-column[14] = pRubl-CostSum
  use-column[15] = pVal-Effect
  use-column[16] = pRubl-Effect
  use-column[17] = pNDS-VAL
  use-column[18] = v-vat18-base
  use-column[19] = v-vat10-base
  use-column[20] = pNDs-RUbl
  use-column[21] = v-vat18-rubl
  use-column[22] = v-vat10-rubl
  use-column[23] = PDiscnt-PC
  use-column[24] = pUP-pc
  use-column[25] = pTOrgPred
  use-column[26] = pOperator
  use-column[27] = PKladov
  use-column[28] = pIspName
  use-column[29] = pPayType
  use-column[30] = pKurs
  use-column[31] = pOur-Obj
  use-column[32] = pPayWaitDate
  use-column[33] = p-sale-base
  use-column[34] = p-sale-rubl
  use-column[35] = pNums-doc
  use-column[36] = p-sale-base-doc
  use-column[37] = p-sale-rubl-doc
  use-column[38] = p-crsa-base-doc
  use-column[39] = p-crsa-rubl-doc
  use-column[40] = p-ps
.
assign
  fill8  = fill("-", 8)
  fill11 = fill("-", 11)
  fill12 = fill("-", 12)
  fill15 = fill("-", 15)
  fill18 = fill("-", 18)
  fill19 = fill("-", 19)
  fill21 = fill("-", 21)
.
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = p-title
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
Make-Excel = yes.
.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=4 l-col-format= "x(4)"            l-col-lable="Док. атр.".
  define variable ed1 as handle no-undo.
  define variable l-1 as handle no-undo.
  define variable ll-1 as handle no-undo.
  define variable c-for-doc-attr as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-attr IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"            l-col-lable="Дата создания".
  define variable ed2 as handle no-undo.
  define variable l-2 as handle no-undo.
  define variable ll-2 as handle no-undo.
  define variable c-for-doc-date as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-date IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"            l-col-lable="Дата закрытия".
  define variable ed3 as handle no-undo.
  define variable l-3 as handle no-undo.
  define variable ll-3 as handle no-undo.
  define variable c-for-fact-date as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-fact-date IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"            l-col-lable="Номер документа".
  define variable ed4 as handle no-undo.
  define variable l-4 as handle no-undo.
  define variable ll-4 as handle no-undo.
  define variable c-for-doc-code as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="CHARACTER" l-col-len=30 l-col-format= "x(30)"            l-col-lable="Контрагент".
  define variable ed5 as handle no-undo.
  define variable l-5 as handle no-undo.
  define variable ll-5 as handle no-undo.
  define variable c-for-cli-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-cli-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
  assign l-col-type="CHARACTER" l-col-len=50 l-col-format= "x(70)".
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество".
  define variable ed6 as handle no-undo.
  define variable l-6 as handle no-undo.
  define variable ll-6 as handle no-undo.
  define variable c-Qnty as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма прод. цен (без скидки) (б.вал.)".
  define variable ed7 as handle no-undo.
  define variable l-7 as handle no-undo.
  define variable ll-7 as handle no-undo.
  define variable c-Val-BruttoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-BruttoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма прод. цен (без скидки) (РУБ)".
  define variable ed8 as handle no-undo.
  define variable l-8 as handle no-undo.
  define variable ll-8 as handle no-undo.
  define variable c-Rubl-BruttoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-BruttoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма прод. цен (со скидкой) (б.вал.)".
  define variable ed9 as handle no-undo.
  define variable l-9 as handle no-undo.
  define variable ll-9 as handle no-undo.
  define variable c-Val-NettoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-NettoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма прод. цен (со скидкой) (РУБ)".
  define variable ed10 as handle no-undo.
  define variable l-10 as handle no-undo.
  define variable ll-10 as handle no-undo.
  define variable c-Rubl-NettoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-NettoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок (б.вал.)".
  define variable ed11 as handle no-undo.
  define variable l-11 as handle no-undo.
  define variable ll-11 as handle no-undo.
  define variable c-Val-DiscntSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-DiscntSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок (РУБ)".
  define variable ed12 as handle no-undo.
  define variable l-12 as handle no-undo.
  define variable ll-12 as handle no-undo.
  define variable c-Rubl-DiscntSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-DiscntSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма учетных цен (б.вал.)".
  define variable ed13 as handle no-undo.
  define variable l-13 as handle no-undo.
  define variable ll-13 as handle no-undo.
  define variable c-Val-CostSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-CostSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=19 l-col-format= "->>>,>>>,>>>,>>9.99"     l-col-lable="Сумма учетных цен (РУБ)".
  define variable ed14 as handle no-undo.
  define variable l-14 as handle no-undo.
  define variable ll-14 as handle no-undo.
  define variable c-Rubl-CostSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[14] = true then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-CostSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность (б.вал.)".
  define variable ed15 as handle no-undo.
  define variable l-15 as handle no-undo.
  define variable ll-15 as handle no-undo.
  define variable c-Val-Effect as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[15] = true then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-Effect IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность (РУБ)".
  define variable ed16 as handle no-undo.
  define variable l-16 as handle no-undo.
  define variable ll-16 as handle no-undo.
  define variable c-Rubl-Effect as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[16] = true then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-Effect IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС (б.вал.)".
  define variable ed17 as handle no-undo.
  define variable l-17 as handle no-undo.
  define variable ll-17 as handle no-undo.
  define variable c-NDS-val as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[17] = true then DO:
        CREATE EDITOR LL-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS-val IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 18% (б.вал.)".
  define variable ed18 as handle no-undo.
  define variable l-18 as handle no-undo.
  define variable ll-18 as handle no-undo.
  define variable c-NDS18-val as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[18] = true then DO:
        CREATE EDITOR LL-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS18-val IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 10% (б.вал.)".
  define variable ed19 as handle no-undo.
  define variable l-19 as handle no-undo.
  define variable ll-19 as handle no-undo.
  define variable c-NDS10-val as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[19] = true then DO:
        CREATE EDITOR LL-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS10-val IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС (РУБ)".
  define variable ed20 as handle no-undo.
  define variable l-20 as handle no-undo.
  define variable ll-20 as handle no-undo.
  define variable c-NDS-Rubl as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[20] = true then DO:
        CREATE EDITOR LL-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS-Rubl IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 18% (РУБ)".
  define variable ed21 as handle no-undo.
  define variable l-21 as handle no-undo.
  define variable ll-21 as handle no-undo.
  define variable c-NDS18-Rubl as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[21] = true then DO:
        CREATE EDITOR LL-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS18-Rubl IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 10% (РУБ)".
  define variable ed22 as handle no-undo.
  define variable l-22 as handle no-undo.
  define variable ll-22 as handle no-undo.
  define variable c-NDS10-Rubl as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[22] = true then DO:
        CREATE EDITOR LL-22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS10-Rubl IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[22] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 22
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
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент скидки".
  define variable ed23 as handle no-undo.
  define variable l-23 as handle no-undo.
  define variable ll-23 as handle no-undo.
  define variable c-Discnt-Pc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[23] = true then DO:
        CREATE EDITOR LL-23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Discnt-Pc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[23] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 23
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
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент фактич. наценки".
  define variable ed24 as handle no-undo.
  define variable l-24 as handle no-undo.
  define variable ll-24 as handle no-undo.
  define variable c-Up-Pc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[24] = true then DO:
        CREATE EDITOR LL-24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Up-Pc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[24] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 24
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Торговый представитель".
  define variable ed25 as handle no-undo.
  define variable l-25 as handle no-undo.
  define variable ll-25 as handle no-undo.
  define variable c-TorgPred as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[25] = true then DO:
        CREATE EDITOR LL-25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-TorgPred IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[25] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 25
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Оператор".
  define variable ed26 as handle no-undo.
  define variable l-26 as handle no-undo.
  define variable ll-26 as handle no-undo.
  define variable c-Operator as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[26] = true then DO:
        CREATE EDITOR LL-26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Operator IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[26] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 26
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Кладовщик".
  define variable ed27 as handle no-undo.
  define variable l-27 as handle no-undo.
  define variable ll-27 as handle no-undo.
  define variable c-KladovName as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[27] = true then DO:
        CREATE EDITOR LL-27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-KladovName IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[27] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 27
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Исполнитель".
  define variable ed28 as handle no-undo.
  define variable l-28 as handle no-undo.
  define variable ll-28 as handle no-undo.
  define variable c-IspName as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[28] = true then DO:
        CREATE EDITOR LL-28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-IspName IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[28] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 28
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Вид оплаты".
  define variable ed29 as handle no-undo.
  define variable l-29 as handle no-undo.
  define variable ll-29 as handle no-undo.
  define variable c-PayType as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[29] = true then DO:
        CREATE EDITOR LL-29 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed29 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-29 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-PayType IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[29] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 29
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
Assign l-col-type="DECIMAL" l-col-len=11 l-col-format= "->>>,>>9.<<"             l-col-lable="Курс".
  define variable ed30 as handle no-undo.
  define variable l-30 as handle no-undo.
  define variable ll-30 as handle no-undo.
  define variable c-Kurs as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[30] = true then DO:
        CREATE EDITOR LL-30 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed30 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-30 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Kurs IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[30] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 30
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
Assign l-col-type="CHARACTER" l-col-len=18 l-col-format= "x(18)"                 l-col-lable="Свой объект".
  define variable ed31 as handle no-undo.
  define variable l-31 as handle no-undo.
  define variable ll-31 as handle no-undo.
  define variable c-Our-Obj as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[31] = true then DO:
        CREATE EDITOR LL-31 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed31 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-31 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Our-Obj IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[31] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 31
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
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"                 l-col-lable="Дата ожид-мой оплаты".
  define variable ed32 as handle no-undo.
  define variable l-32 as handle no-undo.
  define variable ll-32 as handle no-undo.
  define variable c-PayWaitDate as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[32] = true then DO:
        CREATE EDITOR LL-32 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed32 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-32 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-PayWaitDate IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[32] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 32
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В ценах документа(баз.в.)".
  define variable ed33 as handle no-undo.
  define variable l-33 as handle no-undo.
  define variable ll-33 as handle no-undo.
  define variable c-sale-base as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[33] = true then DO:
        CREATE EDITOR LL-33 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed33 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-33 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-sale-base IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[33] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 33
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В ценах документа(РУБ)".
  define variable ed34 as handle no-undo.
  define variable l-34 as handle no-undo.
  define variable ll-34 as handle no-undo.
  define variable c-sale-rubl as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[34] = true then DO:
        CREATE EDITOR LL-34 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed34 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-34 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-sale-rubl IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[34] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 34
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество (док)".
  define variable ed35 as handle no-undo.
  define variable l-35 as handle no-undo.
  define variable ll-35 as handle no-undo.
  define variable c-Qnty-doc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[35] = true then DO:
        CREATE EDITOR LL-35 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed35 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-35 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Qnty-doc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[35] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 35
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В учетн.ценах (баз.в.) (док) ".
  define variable ed36 as handle no-undo.
  define variable l-36 as handle no-undo.
  define variable ll-36 as handle no-undo.
  define variable c-sale-base-doc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[36] = true then DO:
        CREATE EDITOR LL-36 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed36 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-36 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-sale-base-doc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[36] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 36
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В учетн.ценах(РУБ) (док)".
  define variable ed37 as handle no-undo.
  define variable l-37 as handle no-undo.
  define variable ll-37 as handle no-undo.
  define variable c-sale-rubl-doc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[37] = true then DO:
        CREATE EDITOR LL-37 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed37 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-37 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-sale-rubl-doc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[37] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 37
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В прод.ценах(баз.в.) (док) ".
  define variable ed38 as handle no-undo.
  define variable l-38 as handle no-undo.
  define variable ll-38 as handle no-undo.
  define variable c-crsa-base-doc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[38] = true then DO:
        CREATE EDITOR LL-38 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed38 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-38 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-crsa-base-doc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[38] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 38
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В прод.ценах(РУБ) (док)".
  define variable ed39 as handle no-undo.
  define variable l-39 as handle no-undo.
  define variable ll-39 as handle no-undo.
  define variable c-crsa-rubl-doc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[39] = true then DO:
        CREATE EDITOR LL-39 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed39 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-39 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-crsa-rubl-doc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[39] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 39
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
Assign l-col-type="CHARACTER" l-col-len=80 l-col-format= "x(80)"            l-col-lable="Примечание".
  define variable ed40 as handle no-undo.
  define variable l-40 as handle no-undo.
  define variable ll-40 as handle no-undo.
  define variable c-comm as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[40] = true then DO:
        CREATE EDITOR LL-40 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed40 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-40 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-comm IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
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
if use-column[40] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 40
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
assign
p-frame-width = l-col-pos - 1
Line = fill("-", p-frame-width)
.
if p-frame-width > 137 and p-frame-width <= 232  then do:
output stream DocsStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
end.
else do:
output stream DocsStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
end.
if Make-Excel then
run openforexcel in this-procedure .
FORM with FRAME x1 .
FORM HEADER
Line format "X(76)" AT 1 SKIP
"Продолжение на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream DocsStream FRAME BottomFrame .
PUT stream DocsStream SPACE(10) p-title format "X(125)" SKIP(2).
display STREAM DOcsStream
with frame top-Frame .
run rep/extitle.p (1).
FIND FIRST wt-docs NO-LOCK .
if can-find( first b-wt-docs where b-wt-docs.doc-type <> wt-docs.doc-type ) then do:
  assign
    DifferentTypes = TRUE
  .
end.
run waitfram-show in this-procedure  ( "Печать списка документов " ) .
assign
  v-ind = 0
.
FOR EACH wt-docs with frame x1
:
  assign
    v-ind = v-ind + 1
  .
  if v-ind modulo 10 = 0
  then do:
    run waitfram-show in this-procedure  ( "Печать списка документов " + string( v-ind ) ) .
  end.
  if wt-docs.status_ <> 'факт':U then do:
    for each doc-line no-lock
      where doc-line.doc-code = wt-docs.doc-code
    :
        accumulate
          doc-line.doc-qnty * doc-line.price-base ( total )
          doc-line.doc-qnty * doc-line.price-rubl ( total )
        .
    end.
  end.
  run calc-line-doc in this-procedure .
  assign
    wt-docs.VAT18-base = NDS18-Val
    wt-docs.VAT10-base = NDS10-Val
    wt-docs.VAT18-rubl = NDS18-Rubl
    wt-docs.VAT10-rubl = NDS10-Rubl
  .
  assign
        Qnty        = ( if can-do( 'факт':U, wt-docs.status_ )
                        then wt-docs.fact-qnty
                        else wt-docs.doc-qnty )
        Qnty-doc    = wt-docs.doc-qnty
        NDS-Val     = wt-docs.VAT-base
        NDS-Rubl    = wt-docs.VAT-rubl
        TorgPred    = wt-docs.Mngr_Name
        Operator    = wt-docs.Oper_Name
        PayType     = wt-docs.pay-name
        Kurs        = wt-docs.Course
        Our-Obj     = wt-docs.OurObjectName
        KladovName  = wt-docs.Wrkr_name
        IspName     = wt-docs.Isp-Name
        PayWaitDate = wt-docs.pay-waitdate
        comm        = wt-docs.ps
        Val-BruttoSaleSum  =  Val-NettoSaleSum  +  Val-DiscntSum
        Rubl-BruttoSaleSum =  Rubl-NettoSaleSum +  Rubl-DiscntSum
.
        if Qnty = ? then Qnty = 0 .
        if Qnty-doc = ? then Qnty-doc = 0 .
        if Val-BruttoSaleSum = ? then Val-BruttoSaleSum = 0 .
        if Rubl-BruttoSaleSum = ? then Rubl-BruttoSaleSum = 0 .
        if Val-NettoSaleSum = ? then Val-NettoSaleSum = 0 .
        if Rubl-NettoSaleSum = ? then Rubl-NettoSaleSum = 0 .
        if Val-DiscntSum = ? then Val-DiscntSum = 0 .
        if Rubl-DiscntSum = ? then Rubl-DiscntSum = 0 .
        if Val-CostSum = ? then Val-CostSum = 0 .
        if Rubl-CostSum = ? then Rubl-CostSum = 0 .
        if NDS-Val    = ? then NDS-Val    = 0 .
        if NDS18-Val  = ? then NDS18-Val  = 0 .
        if NDS10-Val  = ? then NDS10-Val  = 0 .
        if NDS-Rubl   = ? then NDS-Rubl   = 0 .
        if NDS18-Rubl = ? then NDS18-Rubl = 0 .
        if NDS10-Rubl = ? then NDS10-Rubl = 0 .
        if sale-rubl  = ? then sale-Rubl  = 0 .
        if sale-base  = ? then sale-base  = 0 .
        if sale-rubl-doc  = ? then sale-Rubl-doc  = 0 .
        if sale-base-doc  = ? then sale-base-doc  = 0 .
        if crsa-rubl-doc  = ? then crsa-Rubl-doc  = 0 .
        if crsa-base-doc  = ? then crsa-base-doc  = 0 .
        if DifferentTypes AND can-do( 'рас,спи':U, wt-docs.doc-type ) then do:
            assign
                Qnty = - Qnty
                Qnty-doc = - Qnty-doc
                Val-BruttoSaleSum = - Val-BruttoSaleSum
                Rubl-BruttoSaleSum = - Rubl-BruttoSaleSum
                Val-NettoSaleSum = - Val-NettoSaleSum
                Rubl-NettoSaleSum = - Rubl-NettoSaleSum
                Val-DiscntSum = - Val-DiscntSum
                Rubl-DiscntSum = - Rubl-DiscntSum
                Val-CostSum = - Val-CostSum
                Rubl-CostSum = - Rubl-CostSum
                NDS-Val = - NDS-Val
                NDS18-Val = - NDS18-Val
                NDS10-Val = - NDS10-Val
                NDS-Rubl = - NDS-Rubl
                NDS18-Rubl = - NDS18-Rubl
                NDS10-Rubl = - NDS10-Rubl
                sale-rubl  = - sale-rubl
                sale-base  = - sale-base
                sale-rubl-doc  = - sale-rubl-doc
                sale-base-doc  = - sale-base-doc
                crsa-rubl-doc  = - crsa-rubl-doc
                crsa-base-doc  = - crsa-base-doc
            .
        end.
        if DifferentTypes then do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when 'рас':U OR when 'возврат':U then
                        assign
                            Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                    when 'спи':U then
                        assign
                            Val-Effect = Val-CostSum
                            Rubl-Effect = Rubl-CostSum .
                    when 'инв':U then
                        if can-do( 'факт':U, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                            assign
                                Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        else
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    otherwise
                        assign     Val-Effect = 0    Rubl-Effect = 0 .
                END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.
        else do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when 'рас':U then
                        assign
                            Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when 'спи':U then
                            assign
                                Val-Effect = - Val-CostSum
                                Rubl-Effect = - Rubl-CostSum .
                        when 'возврат':U then
                            assign
                                Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when 'инв':U then
                            if can-do( 'факт':U, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                                assign
                                    Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                    Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                            else
                                assign     Val-Effect = 0    Rubl-Effect = 0 .
                        otherwise
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.
        if Val-BruttoSaleSum <> 0 then do:
            if ( ( Val-DiscntSum / Val-BruttoSaleSum ) < 100 ) AND
               ( ( Val-DiscntSum / Val-BruttoSaleSum ) > -100 ) then
                Discnt-PC =
                    string( Val-DiscntSum / Val-BruttoSaleSum * 100 , "->>>9.9" ) + "%" .
            else
                if ( Val-DiscntSum / Val-BruttoSaleSum < -99.99 ) then
                    Discnt-PC = string( -9999.9 , "->>>9.9" ) + "%" .
                else
                    Discnt-PC = string( 9999.9 , "->>>9.9" ) + "%" .
        end.
        else do:
            Discnt-PC = string( 0, "->>>9.9" ) + "%" .
        end.
        if Val-CostSum <> 0 then do:
          if  ( Val-Effect / abs( Val-CostSum ) ) < 100
          AND ( Val-Effect / abs( Val-CostSum ) ) > -100 then do:
            assign
              Up-PC = string( Val-Effect / abs( Val-CostSum ) * 100 , "->>>9.9" ) + "%"
            .
          end.
          else do:
            if ( Val-Effect / abs( Val-CostSum ) ) < -99.99 then do:
              assign
                Up-PC = string( -9999.9 , "->>>9.9" ) + "%"
              .
            end.
            else do:
              assign
                Up-PC = string( 9999.9 , "->>>9.9" ) + "%"
              .
            end.
          end.
        end.
        else do:
          assign
            Up-PC = string( 0 , "->>>9.9" ) + "%"
          .
        end.
        ACCUMULATE
          Qnty               ( TOTAL )
          Qnty-doc           ( TOTAL )
          Val-BruttoSaleSum  ( TOTAL )
          Rubl-BruttoSaleSum ( TOTAL )
          Val-NettoSaleSum   ( TOTAL )
          Rubl-NettoSaleSum  ( TOTAL )
          Val-DiscntSum      ( TOTAL )
          Rubl-DiscntSum     ( TOTAL )
          Val-CostSum        ( TOTAL )
          Rubl-CostSum       ( TOTAL )
          NDS-Val            ( TOTAL )
          NDS18-Val          ( TOTAL )
          NDS10-Val          ( TOTAL )
          NDS-Rubl           ( TOTAL )
          NDS18-Rubl         ( TOTAL )
          NDS10-Rubl         ( TOTAL )
          Val-Effect         ( TOTAL )
          Rubl-Effect        ( TOTAL )
          sale-rubl          ( TOTAL )
          sale-base          ( TOTAL )
          sale-rubl-doc          ( TOTAL )
          sale-base-doc          ( TOTAL )
          crsa-rubl-doc          ( TOTAL )
          crsa-base-doc          ( TOTAL )
          for-doc-code       ( count )
          .
  if use-column[1]
  then  C-for-doc-attr:screen-value = string(wt-docs.doc-attr, entry(1, c-for-doc-attr:private-data, chr(4))).
  if use-column[2]
  then  C-for-doc-date:screen-value = string(wt-docs.doc-date, entry(1, c-for-doc-date:private-data, chr(4))).
  if use-column[3]
  then  C-for-fact-date:screen-value = string(wt-docs.fact-date, entry(1, c-for-fact-date:private-data, chr(4))).
  if use-column[4]
  then  C-for-doc-code:screen-value = string(wt-docs.doc-code, entry(1, c-for-doc-code:private-data, chr(4))).
  if use-column[5]
  then  C-for-cli-name:screen-value = string(wt-docs.cli-name, entry(1, c-for-cli-name:private-data, chr(4))).
  if use-column[6]
  then  C-Qnty:screen-value = string(Qnty, entry(1, c-Qnty:private-data, chr(4))).
  if use-column[7]
  then  C-Val-BruttoSaleSum:screen-value = string(Val-BruttoSaleSum, entry(1, c-Val-BruttoSaleSum:private-data, chr(4))).
  if use-column[8]
  then  C-Rubl-BruttoSaleSum:screen-value = string(Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4))).
  if use-column[9]
  then  C-Val-NettoSaleSum:screen-value = string(Val-NettoSaleSum, entry(1, c-Val-NettoSaleSum:private-data, chr(4))).
  if use-column[10]
  then  C-Rubl-NettoSaleSum:screen-value = string(Rubl-NettoSaleSum, entry(1, c-Rubl-NettoSaleSum:private-data, chr(4))).
  if use-column[11]
  then  C-Val-DiscntSum:screen-value = string(Val-DiscntSum, entry(1, c-Val-DiscntSum:private-data, chr(4))).
  if use-column[12]
  then  C-RUbl-DiscntSum:screen-value = string(Rubl-DiscntSum, entry(1, c-RUbl-DiscntSum:private-data, chr(4))).
  if use-column[13]
  then  C-Val-CostSum:screen-value = string(Val-CostSum, entry(1, c-Val-CostSum:private-data, chr(4))).
  if use-column[14]
  then  C-RUbl-CostSum:screen-value = string(Rubl-CostSum, entry(1, c-RUbl-CostSum:private-data, chr(4))).
  if use-column[15]
  then  C-Val-Effect:screen-value = string(Val-Effect, entry(1, c-Val-Effect:private-data, chr(4))).
  if use-column[16]
  then  C-RUbl-Effect:screen-value = string(Rubl-Effect, entry(1, c-RUbl-Effect:private-data, chr(4))).
  if use-column[17]
  then  C-Nds-Val:screen-value = string(Nds-Val, entry(1, c-Nds-Val:private-data, chr(4))).
  if use-column[18]
  then  C-Nds18-Val:screen-value = string(Nds18-Val, entry(1, c-Nds18-Val:private-data, chr(4))).
  if use-column[19]
  then  C-Nds10-Val:screen-value = string(Nds10-Val, entry(1, c-Nds10-Val:private-data, chr(4))).
  if use-column[20]
  then  C-Nds-Rubl:screen-value = string(Nds-Rubl, entry(1, c-Nds-Rubl:private-data, chr(4))).
  if use-column[21]
  then  C-Nds18-Rubl:screen-value = string(Nds18-Rubl, entry(1, c-Nds18-Rubl:private-data, chr(4))).
  if use-column[22]
  then  C-Nds10-Rubl:screen-value = string(Nds10-Rubl, entry(1, c-Nds10-Rubl:private-data, chr(4))).
  if use-column[23]
  then  C-Discnt-PC:screen-value = string(if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' , entry(1, c-Discnt-PC:private-data, chr(4))).
  if use-column[24]
  then  C-Up-Pc:screen-value = string(if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' , entry(1, c-Up-Pc:private-data, chr(4))).
  if use-column[25]
  then  C-TorgPred:screen-value = string(TorgPred, entry(1, c-TorgPred:private-data, chr(4))).
  if use-column[26]
  then  C-Operator:screen-value = string(Operator, entry(1, c-Operator:private-data, chr(4))).
  if use-column[27]
  then  C-KladovName:screen-value = string(KladovName, entry(1, c-KladovName:private-data, chr(4))).
  if use-column[28]
  then  C-IspName:screen-value = string(IspName, entry(1, c-IspName:private-data, chr(4))).
  if use-column[29]
  then  C-PayType:screen-value = string(PayType, entry(1, c-PayType:private-data, chr(4))).
  if use-column[30]
  then  C-Kurs:screen-value = string(Kurs, entry(1, c-Kurs:private-data, chr(4))).
  if use-column[31]
  then  C-Our-Obj:screen-value = string(Our-Obj, entry(1, c-Our-Obj:private-data, chr(4))).
  if use-column[32]
  then  C-PayWaitDAte:screen-value = string(PayWaitDate, entry(1, c-PayWaitDAte:private-data, chr(4))).
  if use-column[33]
  then  C-sale-base:screen-value = string(sale-base, entry(1, c-sale-base:private-data, chr(4))).
  if use-column[34]
  then  C-sale-rubl:screen-value = string(sale-rubl, entry(1, c-sale-rubl:private-data, chr(4))).
  if use-column[35]
  then  C-Qnty-doc:screen-value = string(Qnty-doc, entry(1, c-Qnty-doc:private-data, chr(4))).
  if use-column[36]
  then  C-sale-base-doc:screen-value = string(sale-base-doc, entry(1, c-sale-base-doc:private-data, chr(4))).
  if use-column[37]
  then  C-sale-rubl-doc:screen-value = string(sale-rubl-doc, entry(1, c-sale-rubl-doc:private-data, chr(4))).
  if use-column[38]
  then  C-crsa-base-doc:screen-value = string(crsa-base-doc, entry(1, c-crsa-base-doc:private-data, chr(4))).
  if use-column[39]
  then  C-crsa-rubl-doc:screen-value = string(crsa-rubl-doc, entry(1, c-crsa-rubl-doc:private-data, chr(4))).
  if use-column[40]
  then  C-comm:screen-value = string(comm, entry(1, c-comm:private-data, chr(4))).
  IF (line-counter(DocsStream)  modulo page-size(DocsStream)= 0) AND
     (line-counter(DocsStream) >= page-size(DocsStream)) then DO:
      display STREAM DocsStream    with frame top-frame .
  End.
  DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (reg-output(
                    string(wt-docs.doc-attr, entry(1, c-for-doc-attr:private-data, chr(4)))
                   ,c-for-doc-attr:private-data
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
                    string(wt-docs.doc-date, entry(1, c-for-doc-date:private-data, chr(4)))
                   ,c-for-doc-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 2 < last-col-num
         then CHR(9)
         else ""))
  else "":U
   if wt-docs.fact-date <> ?
    then
     (
  if use-column[3]
  then (reg-output(
                    string(wt-docs.fact-date, entry(1, c-for-fact-date:private-data, chr(4)))
                   ,c-for-fact-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  )
    else
     (
  if use-column[3]
  then (reg-output(
                    string('', entry(1, c-for-fact-date:private-data, chr(4)))
                   ,c-for-fact-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  )
  if use-column[4]
  then (reg-output(
                    string(wt-docs.doc-code, entry(1, c-for-doc-code:private-data, chr(4)))
                   ,c-for-doc-code:private-data
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
                    string(wt-docs.cli-name, entry(1, "x(70)", chr(4)))
                   ,c-for-cli-name:private-data
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
                    string(Qnty, entry(1, c-Qnty:private-data, chr(4)))
                   ,c-Qnty:private-data
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
                    string(Val-BruttoSaleSum, entry(1, c-Val-BruttoSaleSum:private-data, chr(4)))
                   ,c-Val-BruttoSaleSum:private-data
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
                    string(Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4)))
                   ,c-Rubl-BruttoSaleSum:private-data
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
                    string(Val-NettoSaleSum, entry(1, c-Val-NettoSaleSum:private-data, chr(4)))
                   ,c-Val-NettoSaleSum:private-data
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
                    string(Rubl-NettoSaleSum, entry(1, c-Rubl-NettoSaleSum:private-data, chr(4)))
                   ,c-Rubl-NettoSaleSum:private-data
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
                    string(Val-DiscntSum, entry(1, c-Val-DiscntSum:private-data, chr(4)))
                   ,c-Val-DiscntSum:private-data
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
                    string(Rubl-DiscntSum, entry(1, c-RUbl-DiscntSum:private-data, chr(4)))
                   ,c-RUbl-DiscntSum:private-data
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
                    string(Val-CostSum, entry(1, c-Val-CostSum:private-data, chr(4)))
                   ,c-Val-CostSum:private-data
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
                    string(Rubl-CostSum, entry(1, c-RUbl-CostSum:private-data, chr(4)))
                   ,c-RUbl-CostSum:private-data
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
                    string(Val-Effect, entry(1, c-Val-Effect:private-data, chr(4)))
                   ,c-Val-Effect:private-data
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
                    string(Rubl-Effect, entry(1, c-RUbl-Effect:private-data, chr(4)))
                   ,c-RUbl-Effect:private-data
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
                    string(Nds-Val, entry(1, c-Nds-Val:private-data, chr(4)))
                   ,c-Nds-Val:private-data
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
                    string(Nds18-Val, entry(1, c-Nds18-Val:private-data, chr(4)))
                   ,c-Nds18-Val:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 18 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[19]
  then (reg-output(
                    string(Nds10-Val, entry(1, c-Nds10-Val:private-data, chr(4)))
                   ,c-Nds10-Val:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 19 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[20]
  then (reg-output(
                    string(Nds-Rubl, entry(1, c-Nds-Rubl:private-data, chr(4)))
                   ,c-Nds-Rubl:private-data
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
                    string(Nds18-Rubl, entry(1, c-Nds18-Rubl:private-data, chr(4)))
                   ,c-Nds18-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 21 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[22]
  then (reg-output(
                    string(Nds10-Rubl, entry(1, c-Nds10-Rubl:private-data, chr(4)))
                   ,c-Nds10-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 22 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[23]
  then (reg-output(
                    string(if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' , entry(1, c-Discnt-PC:private-data, chr(4)))
                   ,c-Discnt-PC:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 23 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[24]
  then (reg-output(
                    string(if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' , entry(1, c-Up-Pc:private-data, chr(4)))
                   ,c-Up-Pc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 24 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[25]
  then (reg-output(
                    string(TorgPred, entry(1, c-TorgPred:private-data, chr(4)))
                   ,c-TorgPred:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 25 < last-col-num
         then CHR(9)
         else ""))
  else "":U
                  .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[26]
  then (reg-output(
                    string(Operator, entry(1, c-Operator:private-data, chr(4)))
                   ,c-Operator:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 26 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[27]
  then (reg-output(
                    string(KladovName, entry(1, c-KladovName:private-data, chr(4)))
                   ,c-KladovName:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 27 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[28]
  then (reg-output(
                    string(IspName, entry(1, c-IspName:private-data, chr(4)))
                   ,c-IspName:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 28 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[29]
  then (reg-output(
                    string(PayType, entry(1, c-PayType:private-data, chr(4)))
                   ,c-PayType:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 29 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[30]
  then (reg-output(
                    string(Kurs, entry(1, c-Kurs:private-data, chr(4)))
                   ,c-Kurs:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 30 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[31]
  then (reg-output(
                    string(Our-Obj, entry(1, c-Our-Obj:private-data, chr(4)))
                   ,c-Our-Obj:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 31 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[32]
  then (reg-output(
                    string(PayWaitDate, entry(1, c-PayWaitDAte:private-data, chr(4)))
                   ,c-PayWaitDAte:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 32 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[33]
  then (reg-output(
                    string(sale-base, entry(1, c-sale-base:private-data, chr(4)))
                   ,c-sale-base:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 33 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[34]
  then (reg-output(
                    string(sale-rubl, entry(1, c-sale-rubl:private-data, chr(4)))
                   ,c-sale-rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 34 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[35]
  then (reg-output(
                    string(Qnty-doc, entry(1, c-Qnty-doc:private-data, chr(4)))
                   ,c-Qnty-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 35 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[36]
  then (reg-output(
                    string(sale-base-doc, entry(1, c-sale-base-doc:private-data, chr(4)))
                   ,c-sale-base-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 36 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[37]
  then (reg-output(
                    string(sale-rubl-doc, entry(1, c-sale-rubl-doc:private-data, chr(4)))
                   ,c-sale-rubl-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 37 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[38]
  then (reg-output(
                    string(crsa-base-doc, entry(1, c-crsa-base-doc:private-data, chr(4)))
                   ,c-crsa-base-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 38 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[39]
  then (reg-output(
                    string(crsa-rubl-doc, entry(1, c-crsa-rubl-doc:private-data, chr(4)))
                   ,c-crsa-rubl-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 39 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[40]
  then (reg-output(
                    string(comm, entry(1, c-comm:private-data, chr(4)))
                   ,c-comm:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 40 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  skip.
END.
c-for-cli-name:screen-value =  line .
if use-column[6]  then  C-Qnty:screen-value = line .
if use-column[7]  then  C-Val-BruttoSaleSum:screen-value = line .
if use-column[8]  then  C-Rubl-BruttoSaleSum:screen-value = line .
if use-column[9]  then  C-Val-NettoSaleSum:screen-value = line .
if use-column[10]  then  C-Rubl-NettoSaleSum:screen-value = line .
if use-column[11]  then  C-Val-DiscntSum:screen-value = line .
if use-column[12]  then  C-Rubl-DiscntSum:screen-value = line .
if use-column[13]  then  C-Val-CostSum:screen-value = line .
if use-column[14]  then  C-Rubl-CostSum:screen-value = line .
if use-column[15]  then  C-Val-Effect:screen-value = line .
if use-column[16]  then  C-Rubl-Effect:screen-value = line .
if use-column[17]  then  C-NDS-Val:screen-value = line .
if use-column[18]  then  C-NDS18-Val:screen-value = line .
if use-column[19]  then  C-NDS10-Val:screen-value = line .
if use-column[20]  then  C-NDS-Rubl:screen-value = line .
if use-column[21]  then  C-NDS18-Rubl:screen-value = line .
if use-column[22]  then  C-NDS10-Rubl:screen-value = line .
if use-column[33]  then  C-sale-base:screen-value = line .
if use-column[34]  then  C-sale-rubl:screen-value = line .
if use-column[35]  then  C-Qnty-doc:screen-value = line .
if use-column[36]  then  C-sale-base-doc:screen-value = line .
if use-column[37]  then  C-sale-rubl-doc:screen-value = line .
if use-column[38]  then  C-crsa-base-doc:screen-value = line .
if use-column[39]  then  C-crsa-rubl-doc:screen-value = line .
if use-column[40]  then  C-comm:screen-value = line .
DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
  c-for-cli-name:screen-value =  "ИТОГО " + trim(string( ACCUM COUNT for-doc-code )) + " по док-м " .
  if use-column[6]
  then  C-Qnty:screen-value = string(ACCUM TOTAL Qnty, entry(1, c-Qnty:private-data, chr(4))).
  if use-column[7]
  then  C-Val-BruttoSaleSum:screen-value = string(ACCUM TOTAL Val-BruttoSaleSum , entry(1, c-Val-BruttoSaleSum:private-data, chr(4))).
  if use-column[8]
  then  C-Rubl-BruttoSaleSum:screen-value = string(ACCUM TOTAL Rubl-BruttoSaleSum , entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4))).
  if use-column[9]
  then  C-Val-NettoSaleSum:screen-value = string(ACCUM TOTAL Val-NettoSaleSum  , entry(1, c-Val-NettoSaleSum:private-data, chr(4))).
  if use-column[10]
  then  C-Rubl-NettoSaleSum:screen-value = string(ACCUM TOTAL Rubl-NettoSaleSum , entry(1, c-Rubl-NettoSaleSum:private-data, chr(4))).
  if use-column[11]
  then  C-Val-DiscntSum:screen-value = string(ACCUM TOTAL Val-DiscntSum     , entry(1, c-Val-DiscntSum:private-data, chr(4))).
  if use-column[12]
  then  C-Rubl-DiscntSum:screen-value = string(ACCUM TOTAL Rubl-DiscntSum    , entry(1, c-Rubl-DiscntSum:private-data, chr(4))).
  if use-column[13]
  then  C-Val-CostSum:screen-value = string(ACCUM TOTAL Val-CostSum       , entry(1, c-Val-CostSum:private-data, chr(4))).
  if use-column[14]
  then  C-Rubl-CostSum:screen-value = string(ACCUM TOTAL Rubl-CostSum      , entry(1, c-Rubl-CostSum:private-data, chr(4))).
  if use-column[15]
  then  C-Val-Effect:screen-value = string(ACCUM TOTAL Val-Effect        , entry(1, c-Val-Effect:private-data, chr(4))).
  if use-column[16]
  then  C-Rubl-Effect:screen-value = string(ACCUM TOTAL Rubl-Effect       , entry(1, c-Rubl-Effect:private-data, chr(4))).
  if use-column[17]
  then  C-NDS-Val:screen-value = string(ACCUM TOTAL NDS-Val           , entry(1, c-NDS-Val:private-data, chr(4))).
  if use-column[18]
  then  C-NDS18-Val:screen-value = string(ACCUM TOTAL NDS18-Val         , entry(1, c-NDS18-Val:private-data, chr(4))).
  if use-column[19]
  then  C-NDS10-Val:screen-value = string(ACCUM TOTAL NDS10-Val         , entry(1, c-NDS10-Val:private-data, chr(4))).
  if use-column[20]
  then  C-NDS-Rubl:screen-value = string(ACCUM TOTAL NDS-Rubl          , entry(1, c-NDS-Rubl:private-data, chr(4))).
  if use-column[21]
  then  C-NDS18-Rubl:screen-value = string(ACCUM TOTAL NDS18-Rubl        , entry(1, c-NDS18-Rubl:private-data, chr(4))).
  if use-column[22]
  then  C-NDS10-Rubl:screen-value = string(ACCUM TOTAL NDS10-Rubl        , entry(1, c-NDS10-Rubl:private-data, chr(4))).
  if use-column[33]
  then  C-sale-base:screen-value = string(ACCUM TOTAL sale-base         , entry(1, c-sale-base:private-data, chr(4))).
  if use-column[34]
  then  C-sale-rubl:screen-value = string(ACCUM TOTAL sale-rubl         , entry(1, c-sale-rubl:private-data, chr(4))).
  if use-column[35]
  then  C-Qnty-doc:screen-value = string(ACCUM TOTAL Qnty-doc        , entry(1, c-Qnty-doc:private-data, chr(4))).
  if use-column[36]
  then  C-sale-base-doc:screen-value = string(ACCUM TOTAL sale-base-doc   , entry(1, c-sale-base-doc:private-data, chr(4))).
  if use-column[37]
  then  C-sale-rubl-doc:screen-value = string(ACCUM TOTAL sale-rubl-doc   , entry(1, c-sale-rubl-doc:private-data, chr(4))).
  if use-column[38]
  then  C-crsa-base-doc:screen-value = string(ACCUM TOTAL crsa-base-doc   , entry(1, c-crsa-base-doc:private-data, chr(4))).
  if use-column[39]
  then  C-crsa-rubl-doc:screen-value = string(ACCUM TOTAL crsa-rubl-doc   , entry(1, c-crsa-rubl-doc:private-data, chr(4))).
  DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
 if Make-Excel then  put   stream ForExcel unformatted
  CHR(9) CHR(9) CHR(9) CHR(9)
  if use-column[5]
  then (reg-output(
                    string('ИТОГО ' + trim(string( ACCUM COUNT for-doc-code )) + ' по док-м ', entry(1, c-for-cli-name:private-data, chr(4)))
                   ,c-for-cli-name:private-data
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
                    string(ACCUM TOTAL Qnty, entry(1, c-Qnty:private-data, chr(4)))
                   ,c-Qnty:private-data
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
                    string(ACCUM TOTAL Val-BruttoSaleSum , entry(1, c-Val-BruttoSaleSum:private-data, chr(4)))
                   ,c-Val-BruttoSaleSum:private-data
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
                    string(ACCUM TOTAL Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4)))
                   ,c-Rubl-BruttoSaleSum:private-data
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
                    string(ACCUM TOTAL Val-NettoSaleSum  , entry(1, c-Val-NettoSaleSum:private-data, chr(4)))
                   ,c-Val-NettoSaleSum:private-data
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
                    string(ACCUM TOTAL Rubl-NettoSaleSum , entry(1, c-Rubl-NettoSaleSum:private-data, chr(4)))
                   ,c-Rubl-NettoSaleSum:private-data
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
                    string(ACCUM TOTAL Val-DiscntSum     , entry(1, c-Val-DiscntSum:private-data, chr(4)))
                   ,c-Val-DiscntSum:private-data
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
                    string(ACCUM TOTAL Rubl-DiscntSum    , entry(1, c-Rubl-DiscntSum:private-data, chr(4)))
                   ,c-Rubl-DiscntSum:private-data
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
                    string(ACCUM TOTAL Val-CostSum       , entry(1, c-Val-CostSum:private-data, chr(4)))
                   ,c-Val-CostSum:private-data
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
                    string(ACCUM TOTAL Rubl-CostSum      , entry(1, c-Rubl-CostSum:private-data, chr(4)))
                   ,c-Rubl-CostSum:private-data
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
                    string(ACCUM TOTAL Val-Effect        , entry(1, c-Val-Effect:private-data, chr(4)))
                   ,c-Val-Effect:private-data
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
                    string(ACCUM TOTAL Rubl-Effect       , entry(1, c-Rubl-Effect:private-data, chr(4)))
                   ,c-Rubl-Effect:private-data
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
                    string(ACCUM TOTAL NDS-Val           , entry(1, c-NDS-Val:private-data, chr(4)))
                   ,c-NDS-Val:private-data
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
                    string(ACCUM TOTAL NDS18-Val         , entry(1, c-NDS18-Val:private-data, chr(4)))
                   ,c-NDS18-Val:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 18 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[19]
  then (reg-output(
                    string(ACCUM TOTAL NDS10-Val         , entry(1, c-NDS10-Val:private-data, chr(4)))
                   ,c-NDS10-Val:private-data
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
                    string(ACCUM TOTAL NDS-Rubl          , entry(1, c-NDS-Rubl:private-data, chr(4)))
                   ,c-NDS-Rubl:private-data
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
                    string(ACCUM TOTAL NDS18-Rubl        , entry(1, c-NDS18-Rubl:private-data, chr(4)))
                   ,c-NDS18-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 21 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[22]
  then (reg-output(
                    string(ACCUM TOTAL NDS10-Rubl        , entry(1, c-NDS10-Rubl:private-data, chr(4)))
                   ,c-NDS10-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 22 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[33]
  then (reg-output(
                    string(ACCUM TOTAL sale-base         , entry(1, c-sale-base:private-data, chr(4)))
                   ,c-sale-base:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 33 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[34]
  then (reg-output(
                    string(ACCUM TOTAL sale-rubl         , entry(1, c-sale-rubl:private-data, chr(4)))
                   ,c-sale-rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 34 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[35]
  then (reg-output(
                    string(ACCUM TOTAL qnty-doc        , entry(1, c-qnty-doc:private-data, chr(4)))
                   ,c-qnty-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 35 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[36]
  then (reg-output(
                    string(ACCUM TOTAL sale-base-doc   , entry(1, c-sale-base-doc:private-data, chr(4)))
                   ,c-sale-base-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 36 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[37]
  then (reg-output(
                    string(ACCUM TOTAL sale-rubl-doc   , entry(1, c-sale-rubl-doc:private-data, chr(4)))
                   ,c-sale-rubl-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 37 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[38]
  then (reg-output(
                    string(ACCUM TOTAL crsa-base-doc   , entry(1, c-crsa-base-doc:private-data, chr(4)))
                   ,c-crsa-base-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 38 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[39]
  then (reg-output(
                    string(ACCUM TOTAL crsa-rubl-doc   , entry(1, c-crsa-rubl-doc:private-data, chr(4)))
                   ,c-crsa-rubl-doc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 39 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  .
HIDE stream DocsStream FRAME BottomFrame .
HIDE stream DocsStream FRAME x1 .
HIDE stream DocsStream FRAME top-frame .
delete widget-pool "My-pool".
output stream DocsStream CLOSE.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 8 .
if l-col-pos >= 195 then DisabledOptions = 20.
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .
procedure calc-line-doc :
 define buffer buf_parts     for parts.
 do
 for buf_parts
 on error undo, return error return-value
 :
 assign
    Val-BruttoSaleSum  = 0
    Rubl-BruttoSaleSum = 0
    Val-NettoSaleSum   = 0
    Rubl-NettoSaleSum  = 0
    Val-DiscntSum      = 0
    Rubl-DiscntSum     = 0
    Val-CostSum        = 0
    Rubl-CostSum       = 0
    NDS18-Val          = 0
    NDS10-Val          = 0
    NDS18-Rubl         = 0
    NDS10-Rubl         = 0
    sale-rubl          = 0
    sale-base          = 0
    sale-rubl-doc      = 0
    sale-base-doc      = 0
    crsa-rubl-doc      = 0
    crsa-base-doc      = 0
 .
 for each doc-line no-lock
    where doc-line.doc-code = wt-docs.doc-code
 :
    run clcprtsl_calc-line in this-procedure (
        input recid( doc-line )
    ).
    find first tt-allsum-line
         where tt-allsum-line.sum-type = 'основная_сумма':U
    no-error.
    if not available tt-allsum-line
    then do:
    end.
    else do:
        if ( wt-docs.doc-type = 'при':U  and wt-docs.internal = false ) or
           ( wt-docs.ext-doc-type = 'ep':U  )
            then do:
                assign
                    Val-NettoSaleSum   = Val-NettoSaleSum   +  tt-allsum-line.sum-dsc-base-cur
                    Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-cur
                    Val-DiscntSum      = Val-DiscntSum      +  tt-allsum-line.dsc-base-cur
                    Rubl-DiscntSum     = Rubl-DiscntSum     +  tt-allsum-line.dsc-rubl-cur
                    crsa-base-doc      = crsa-base-doc      +  tt-allsum-line.sum-dsc-base-doc-cur
                    crsa-rubl-doc      = crsa-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-cur
                .
            end.
            else do:
                assign
                    Val-NettoSaleSum   = Val-NettoSaleSum   +  tt-allsum-line.sum-dsc-base-doc
                    Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-doc
                    Val-DiscntSum      = Val-DiscntSum      +  tt-allsum-line.dsc-base-doc
                    Rubl-DiscntSum     = Rubl-DiscntSum     +  tt-allsum-line.dsc-rubl-doc
                    crsa-base-doc      = crsa-base-doc      +  tt-allsum-line.sum-dsc-base-doc-doc
                    crsa-rubl-doc      = crsa-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-doc
                .
            end.
        assign
            Val-CostSum   = Val-CostSum        +  tt-allsum-line.sum-dsc-base-acc
            Rubl-CostSum  = Rubl-CostSum       +  tt-allsum-line.sum-dsc-rubl-acc
            sale-base     = sale-base          +  tt-allsum-line.sum-dsc-base-doc
            sale-rubl     = sale-rubl          +  tt-allsum-line.sum-dsc-rubl-doc
            sale-base-doc = sale-base-doc      +  tt-allsum-line.sum-dsc-base-doc-acc
            sale-rubl-doc = sale-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-acc
        .
    end.
    if p-detal-NDS-Val  = yes
    or p-detal-NDS-Rubl = yes
    then do:
        for each buf_parts no-lock
           where buf_parts.out-code   = wt-docs.doc-code
             and buf_parts.obj-type   = doc-line.obj-type
             and buf_parts.obj-code   = doc-line.obj-code
             and buf_parts.prod-type  = doc-line.prod-type
             and buf_parts.prod-code  = doc-line.prod-code
             and buf_parts.artic      = doc-line.artic
        on error undo, return error return-value
        :
            if round( buf_parts.VAT-pc, 0 ) = 18
            then do:
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
                assign
                    NDS18-Val          = NDS18-Val          + ( vat-base-loc * buf_parts.fact-qnty )
                    NDS18-Rubl         = NDS18-Rubl         + ( vat-rubl-loc * buf_parts.fact-qnty )
                .
            end.
            if round( buf_parts.VAT-pc, 0 ) = 10
            then do:
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
                assign
                    NDS10-Val          = NDS10-Val          + ( vat-base-loc * buf_parts.fact-qnty )
                    NDS10-Rubl         = NDS10-Rubl         + ( vat-rubl-loc * buf_parts.fact-qnty )
                .
            end.
        end.
    end.
end.
 end.
end procedure.
