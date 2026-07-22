using ibs.th.gbl.env.prmtrs.edo.
using ibs.th.str.marking.sts.*.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE BUFFER buf_cash-desk FOR cash-desk.
DEFINE BUFFER buf_cashier FOR clients.
DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_dis-card FOR dis-card.
DEFINE BUFFER buf_obj FOR clients.
DEFINE BUFFER buf_sales-man FOR clients.
DEFINE BUFFER cashier FOR person.
DEFINE BUFFER gds_bar-code FOR bar-code.
DEFINE BUFFER gds_goods FOR goods.
DEFINE BUFFER gds_parts FOR parts.
DEFINE BUFFER gds_prod-bc FOR prod-bc.
DEFINE BUFFER locked_chk-discnt FOR chk-discnt.
DEFINE BUFFER locked_chk-doc FOR chk-doc.
DEFINE BUFFER locked_chk-doc-attr FOR chk-doc-attr.
DEFINE BUFFER locked_chk-gds FOR chk-gds.
DEFINE BUFFER locked_chk-pay FOR chk-pay.
DEFINE BUFFER pay_cash-pay FOR cash-pay.
DEFINE BUFFER pay_currency FOR currency.
DEFINE BUFFER sales-man FOR person.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-doc-attr for ub.chk-doc-attr .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .
define variable v-corr-osnov1 as integer no-undo .
define variable v-susp as character no-undo .
DEFINE NEW SHARED TEMP-TABLE tt-chk-discnt NO-UNDO LIKE chk-discnt
       field  real-value-abs as decimal
       field  real-value-pcnt as decimal.
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE chk-doc
       field real-subdiscnt as decimal.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-gds NO-UNDO LIKE chk-gds.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE chk-pay.
define input parameter parParentProc as Widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-doc-rec as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character NO-UNDO.
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "чек : добавление, изменение, просмотр":U.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
return round-m-sum.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
procedure print-xml:
define input parameter p-dsh as handle no-undo .
define input parameter p-file-name-without-ext as character no-undo .
define variable glog as logical no-undo .
define variable v-rowid as rowid no-undo.
define variable v-rowid-list as character no-undo .
define variable v-rowid-list2 as character no-undo .
define variable v-ii as integer no-undo .
define variable v-th as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-dsh  as handle no-undo .
do
on error undo, return error
:
  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        v-rowid-list = v-rowid-list +
                        (if v-ii = 1 then '' else chr(44)) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
      v-dsh = p-dsh.
    end.
    when "temp-table" then do:
      if p-dsh:default-buffer-handle:available then do:
        v-rowid-list = string(p-dsh:default-buffer-handle:rowid).
      end.
      v-dsh = p-dsh.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        if p-dsh:available then do:
          create temp-table v-th  .
          v-th:create-like(p-dsh).
          v-th:temp-table-prepare(p-dsh:table).
          create buffer v-bh for table v-th.
          v-bh:buffer-create().
          v-bh:buffer-copy(p-dsh).
          v-bh:buffer-release().
          v-dsh = v-bh.
        end.
      end.
      else do:
        v-dsh = p-dsh.
      end.
    end.
  end case.
  glog = v-dsh:WRITE-XML("FILE"
                        , substitute("&1.xml", p-file-name-without-ext)
                        , yes
                        , "windows-1251"
                        , ''
                        , no
                        , no  ) no-error.
  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        if entry(v-ii,v-rowid-list) <> '' then do:
           glog = p-dsh:get-buffer-handle(v-ii):find-by-rowid(TO-ROWID(entry(v-ii,v-rowid-list)))  .
        end.
        v-rowid-list2 = v-rowid-list2 +
                        (if v-ii = 1 then '' else chr(44)) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
    end.
    when "temp-table" then do:
      if v-rowid-list <> '' then do:
        p-dsh:default-buffer-handle:find-by-rowid(to-rowid(v-rowid-list)).
      end.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        delete object v-bh.
        delete object v-th.
      end.
    end.
  end case.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
 define  temp-table tmprecid
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid
 .
define variable fSelect as logical no-undo format "*/" column-label "".
function isSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.
function setSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.
 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
function ChkType returns character
        (input p-chk-type as integer):
define variable result as character no-undo.
result = entry(lookup(string(p-chk-type),'1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U), 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Приход_Корр,Расход_Корр':U ) no-error .
return result.
end function.
function PayType returns character
        (input p-pay-code as integer):
define variable result as character no-undo.
find first ub.pay-type where ub.pay-type.obj-code = p-pay-code no-error .
if available (ub.pay-type) then result = ub.pay-type.obj-name .
else result = "" .
return result.
end function.
function OsnovCorr returns character
        (input p-corr-osnov as integer):
define variable result as character no-undo.
find first ub.Code no-lock where ub.Code.code = string(p-corr-osnov) and ub.Code.parent = "OsnovCorr" no-error .
if available (ub.Code) then result = ub.Code.CodeName .
else result = "" .
return result.
end function.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
DEFINE VARIABLE var-mode as character no-undo.
DEFINE VARIABLE ch-bc-ck as logical no-undo init no.
DEFINE VARIABLE is-prt as logical no-undo init no.
define variable hnum as logical no-undo init no.
define variable ibmgroup as logical no-undo init yes.
define variable lll as int no-undo initial 0.
define variable v-is-top as logical no-undo .
DEFINE VARIABLE v-shift-date as date no-undo.
DEFINE VARIABLE v-shift-num as integer no-undo.
DEFINE VARIABLE conf-attr as char no-undo.
DEFINE VARIABLE conf-par as char no-undo.
DEFINE VARIABLE par-type as char no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE varcurr-name like ub.currency.curr-name no-undo.
DEFINE VARIABLE vargds-name like ub.goods.gds-name no-undo.
DEFINE VARIABLE varprt-name like ub.goods.gds-name no-undo.
define variable discnt-option as character no-undo.
DEFINE VARIABLE v-is-sub-d as logical no-undo .
define variable v-pay-name as character no-undo label "Назв. платежа" FORMAT "X(18)".
define variable v-pay-card like ub.chk-pay.pay-card no-undo.
define variable v-global-err as logical no-undo .
define variable glog as logical no-undo .
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-is-update as logical no-undo .
define variable exch-date_ like ub.curr-shop.exch-date no-undo .
define variable exch-time_ like ub.curr-shop.exch-time no-undo .
define variable v-exch-time-str as character no-undo.
define variable dc-change as logical no-undo .
DEFINE VARIABLE v-br-discnt-current-type AS INTEGER NO-UNDO.
define variable v-tax-type as character no-undo label "Вид налога" FORMAT "X(10)".
define variable v-OVDtax-type as character no-undo label "Вид налога ОФД" FORMAT "X(14)".
define buffer buf_shop for ub.shop.
define variable v-host-code as integer   no-undo .
define variable v-gds-attr-value as character no-undo .
define variable v-gds-attr-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
define variable actn#log as logical no-undo .
define variable actn#log_bonus as logical no-undo .
define variable p-view-log as logical no-undo.
define variable  charKey_one as character no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable log-file-name as character no-undo init "get-chkf.log".
define stream ChkStream .
define stream InvStream.
DEFINE VARIABLE ss                         as   character             no-undo .
DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE ii                         as   integer               no-undo .
DEFINE VARIABLE bc-buf                     as   character             no-undo .
DEFINE VARIABLE b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-base-code                like ub.sysconf.base-code  no-undo .
DEFINE VARIABLE shop-type                  as   character             no-undo .
DEFINE VARIABLE shop-code                  as   integer               no-undo .
DEFINE VARIABLE chk-type_                  like ub.chk-doc.chk-type   no-undo .
DEFINE VARIABLE chk-date_                  like ub.chk-doc.chk-date   no-undo .
DEFINE VARIABLE chk-time_                  like ub.chk-doc.chk-time   no-undo .
DEFINE VARIABLE shift-date_                like ub.chk-doc.shift-date no-undo .
DEFINE VARIABLE shift-num_                 like ub.chk-doc.shift-num  no-undo .
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable shift-open-time_           as integer no-undo .
DEFINE VARIABLE z-num_                     like ub.chk-doc.z-number   no-undo.
DEFINE VARIABLE cash-rate_                 as decimal                 no-undo .
DEFINE VARIABLE cash-scale_                like ub.chk-doc.cash-scale no-undo .
DEFINE VARIABLE chk-num_                   like ub.chk-doc.chk-num    no-undo .
DEFINE VARIABLE AuthType_                  as integer  no-undo .
DEFINE VARIABLE qr-alchol_                 like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE CBCType_                   as integer  no-undo .
DEFINE VARIABLE CBCString_                 like ub.chk-gds-attr.line-num  no-undo .
DEFINE VARIABLE CBCBarcode_                like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE pay-desk_                  like ub.chk-doc.pay-desk   no-undo .
DEFINE VARIABLE cashier_                   like ub.chk-doc.cashier    no-undo .
DEFINE VARIABLE sales-man_                 like ub.chk-doc.sales-man  no-undo .
DEFINE VARIABLE d-card_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE cli-type_                  like ub.chk-doc.cli-type   no-undo .
DEFINE VARIABLE cli-code_                  like ub.chk-doc.cli-code   no-undo .
DEFINE VARIABLE d-mask_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE tot-d-pcnt                 like ub.chk-doc.src-d-pcnt no-undo .
DEFINE VARIABLE doc-num_                   like ub.chk-doc.doc-num    no-undo .
DEFINE VARIABLE doc-num2_                   like ub.chk-doc.doc-num2  no-undo .
DEFINE VARIABLE num-str_                   as   integer               no-undo .
DEFINE VARIABLE gbl-type                   as   character             no-undo .
DEFINE VARIABLE prev-gbl-type              as   character             no-undo .
define variable dflt-cd                    as   character             no-undo .
DEFINE VARIABLE split-check                as   logical               no-undo init no .
DEFINE VARIABLE current-pay-desk           as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
DEFINE VARIABLE time-oper_                 like ub.chk-gds.time-oper  no-undo .
DEFINE VARIABLE t-c-d                      as   decimal               no-undo .
DEFINE VARIABLE pass-gds_                  like ub.chk-gds.pass-gds   no-undo .
DEFINE VARIABLE pump_                      like ub.chk-gds.pump       no-undo .
DEFINE VARIABLE nozzle_                    as   integer               no-undo .
DEFINE VARIABLE place_                     as   integer               no-undo .
DEFINE VARIABLE pl-code_                   as   integer               no-undo .
DEFINE VARIABLE road-tax_                  as   decimal               no-undo .
DEFINE VARIABLE curr-string-qnty           as   decimal               no-undo .
DEFINE VARIABLE sum-from-check             as   decimal               no-undo .
DEFINE VARIABLE discnt-from-check          as   decimal               no-undo .
DEFINE VARIABLE units-rate                 as   decimal               no-undo .
DEFINE VARIABLE units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE cass-rate                  as   decimal               no-undo .
DEFINE VARIABLE rate-por                   as   integer               no-undo .
DEFINE VARIABLE bank-rate_                 as   decimal               no-undo .
DEFINE VARIABLE bank-scale_                as   integer               no-undo .
DEFINE VARIABLE pass-pay_                  like ub.chk-pay.pass-pay   no-undo .
DEFINE VARIABLE pay-card_                  like ub.chk-pay.pay-card   no-undo .
DEFINE VARIABLE exist                      as   logical init TRUE     no-undo .
DEFINE VARIABLE mc-exist                   as   logical init TRUE     no-undo .
DEFINE VARIABLE price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE sub-d                      like ub.chk-doc.sub-discnt    no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE mc-for-chk-type            as   character             no-undo init "".
DEFINE VARIABLE prev-code                  like ub.chk-doc.doc-code      no-undo init "".
DEFINE VARIABLE mc-prev-code               like ub.chk-doc.doc-code    no-undo init "".
DEFINE VARIABLE pay_code                   like ub.cash-pay.cdpay-code     no-undo .
DEFINE VARIABLE curr_code                  like ub.cash-pay.curr-code    no-undo .
DEFINE VARIABLE pay-type                   as   character             no-undo .
DEFINE VARIABLE cstCode                    as   character             no-undo .
DEFINE VARIABLE cstValue                   as   decimal               no-undo .
DEFINE VARIABLE tot_sum                    as   decimal               no-undo .
DEFINE VARIABLE curr-chk-type              as   character             no-undo .
DEFINE VARIABLE mc-curr-chk-type           like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .
define variable v-curr-r-b                as character               no-undo .
DEFINE VARIABLE lng                        as   integer               no-undo .
DEFINE VARIABLE lnp                        as   integer               no-undo .
DEFINE VARIABLE lnc                        as   integer               no-undo .
DEFINE VARIABLE netto-for-sub-d           as    decimal               no-undo .
DEFINE VARIABLE accum-src-for-sub-d       as    decimal               no-undo .
define variable netto-sum_                as    decimal               no-undo .
define variable brutto-sum_               as    decimal               no-undo .
DEFINE VARIABLE lng-sub-d                 as   integer               no-undo .
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
define variable v-src-tot-doc             as decimal                 no-undo .
define variable chk-id_                   as character               no-undo .
DEFINE VARIABLE v-path                    as character               no-undo .
DEFINE VARIABLE v-full-path               as character               no-undo .
DEFINE VARIABLE v-file-name               as character               no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character               no-undo .
DEFINE VARIABLE v-file-name-ext           as character               no-undo .
DEFINE VARIABLE v-error-message           as longchar                no-undo .
define buffer buf_shift-cash for ub.shift-cash .
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define temp-table tt-wd no-undo
field doc-code like ub.chk-doc.doc-code
field record-type like ub.chk-discnt.record-type
field line-type like ub.chk-discnt.line-type
field discnt-id like ub.chk-discnt.discnt-id
field line-num like ub.chk-gds.line-num
field wd-sum   like ub.chk-doc.netto
index pi is primary
line-num
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table get-chkc_context  no-undo
field parparentproc       as widget-handle
field p-log-handle        as handle
field p-log-file-name     as character
field view-log            as logical
field ll                  as integer
field tt-wd-bh            as handle
field pos-type            as character
field cash-num            as integer
field obj-type            as character init 'маг':U
field obj-code            as integer
field db-num              as integer
field r-b                 as character
field host-code           as integer
field base-code           as integer
field cre-pay             as integer
field is-catering         as logical
field is-cdinv            as logical
field is-ptrl             as logical
field is-wth              as logical
field process-sale        as logical
field dc-mask             as logical
field card-by-mask        as logical
field sclspref            as character
field scpgpref            as character
field scpgpref-pre        as character
field doc-prt             as logical
field shift-on            as logical
field cas-shft            as logical
field t-shft              as integer
field v-shft              as integer
field ptrl-check          as logical
field annu-check          as logical
field z-check             as logical
field hnum                as logical
field is-100-discnt       as logical
field zero-cashier        as integer
field rnd-znak            as integer
field cas-curs            as logical
field nam-2str            as logical
field nam-artc            as logical
field cod-pcod            as logical
field name-2cd            as character
field how-temp-disc       as character
field nalc                as integer
field rmethod-type        as character
field rmethod-coeff       as decimal
field serial-code         as character
field salesman-mandatory  as integer
field sales-man           as integer
field salesman-psn-code   as integer
field pos-type-for-discnt as character
field manual-discnt       as integer
field is-grp-totals       as logical
field is-gds-totals       as logical
field cash-counter        as decimal
field pre-cash-counter    as decimal
field qnty-change         as logical
field log-level           as integer
field chk-discnt-table    as handle
help 'cntxt_chk-discnt-table':U
field chk-gds-table       as handle
help 'cntxt_chk-gds-table':U
field chk-pay-table       as handle
help  'cntxt_chk-pay-table':U
field z-number            as integer
field shift-num           as integer
field shift-date          as date
field shift-name          as character
field emulator-mode       as integer
field ibmgroup            as logical
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable p-pos-type as character no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable paycardv as character no-undo .
FUNCTION f-paycardv RETURNS CHARACTER(input p-pay-card as character, p-cash-pay-obj-code as integer, p-cash-pay-curr-code as integer):
define variable kk as integer no-undo .
define variable pay-card-num as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
find first buf_cash-pay no-lock where
           buf_cash-pay.cdpay-code = p-cash-pay-obj-code
       AND buf_cash-pay.curr-code = p-cash-pay-curr-code no-error .
if not avail buf_cash-pay then return "":U.
if p-pay-card = "":u
or p-pay-card = ? then return "":U.
assign
pay-card-num = "":U
.
_kk:
do kk = 1 to num-entries(buf_cash-pay.pay-card-view):
  if p-pay-card begins entry(kk, buf_cash-pay.pay-card-view) then do:
    assign
    pay-card-num = p-pay-card
    .
    return pay-card-num.
  end.
end.
if pay-card-num = "":u then do:
  if length(p-pay-card) > 4 then
  assign
  pay-card-num = fill("*":U, length(p-pay-card) - 4) +
                  substr(p-pay-card, (length(p-pay-card) - 3), 4)
  .
  else
  return fill("*":U, length(p-pay-card)).
end.
return pay-card-num.
END FUNCTION.
define buffer buf_marking-chk for ub.marking-chk .
def var Marking as class mark no-undo .
define variable EDOParSec as class edo.
DEFINE NEW SHARED TEMp-TABLE tt-gds-info no-undo
field doc-code as character
FIELD gds-code LIKE ub.goods.gds-code
FIELD line-num like ub.chk-gds.line-num
FIELD artic like ub.goods.artic
FIELD gds-name like ub.goods.gds-name
FIELD salesman-name like ub.clients.obj-name
FIELD prt-name like ub.gds-prt.f-name
FIELD src-d-pcnt like ub.chk-doc.d-pcnt
FIELD src-price-netto like ub.chk-gds.price-base
FIELD src-sum-netto like ub.chk-doc.netto
FIELD d-pcnt like ub.chk-doc.d-pcnt
FIELD price-netto like ub.chk-gds.price-base
FIELD sum-netto like ub.chk-doc.netto
index pi is unique PRIMARY
doc-code
line-num
.
DEFINE NEW SHARED TEMp-TABLE tt-pay-info no-undo
field doc-code as character
FIELD line-num like ub.chk-pay.line-num
field calc-rate like ub.curr-shop.exch-rate
field exch-date like ub.curr-shop.exch-date
field exch-time like ub.curr-shop.exch-time
field exch-time-str as character
field exch-rate like ub.curr-shop.exch-rate
field exch-scale like ub.curr-shop.exch-scale
index pi is unique PRIMARY
doc-code
line-num
.
define dataset superchk for
tt-chk-doc,
tt-chk-gds,
tt-gds-info,
tt-chk-pay,
tt-pay-info,
tt-chk-discnt
data-relation line-gds for tt-chk-doc, tt-chk-gds relation-fields (doc-code, doc-code) nested
data-relation line-gds2 for tt-chk-doc, tt-gds-info relation-fields (doc-code, doc-code) nested
data-relation line-pay for tt-chk-doc, tt-chk-pay relation-fields (doc-code, doc-code) nested
data-relation line-pay2 for tt-chk-doc, tt-pay-info relation-fields (doc-code, doc-code) nested
data-relation line-discnt for tt-chk-doc, tt-chk-discnt relation-fields (doc-code, doc-code) nested
.
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
FUNCTION get-good RETURNS CHARACTER
  (
    input  parb-code as integer
  , output pargds-code AS integer
  , output pargds-name as character
  , output parprt-name as character
  , output paris-error as logical)  FORWARD.
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.
FUNCTION get-tax-type RETURNS CHARACTER
  ( input p-tax-code as integer) :
case p-tax-code :
  when 1 then return "18%" .
  when 2 then return "10%" .
  when 3 then return "0%" .
  when 4 then return "Б/Н" .
  when 5 then return "18/118" .
  when 6 then return "10/110" .
  otherwise return "Неизвестн." .
end case .
END FUNCTION.
FUNCTION get-OVDtax-type RETURNS CHARACTER
  ( input p-tax-code as integer) :
case p-tax-code :
  when 1102 then return "18%" .
  when 1103 then return "10%" .
  when 1104 then return "0%" .
  when 1105 then return "Б/Н" .
  when 1106 then return "18/118" .
  when 1107 then return "10/110" .
  otherwise return "Неизвестн." .
end case .
END FUNCTION.
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer)  FORWARD.
FUNCTION get-templ-rl-name RETURNS CHARACTER
  ( INPUT p-templ-rl-root AS INTEGER )  FORWARD.
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
DEFINE MENU m-prt
       MENU-ITEM m-gds          LABEL "Товар"
       MENU-ITEM m-prt-1        LABEL "Признаки"
       MENU-ITEM m-prt-2        LABEL "Партии"
       MENU-ITEM m-write-off    LABEL "Код списания"
       MENU-ITEM m-modificator  LABEL "Признак модификатора с нулевой ценой"
       MENU-ITEM m-sales-man    LABEL "Продавец или официант".
DEFINE MENU MENU-b-addbonus
       MENU-ITEM m_cash-abs-bon LABEL "На подитог"
       MENU-ITEM m_gds-abs-bon  LABEL "На товар"      .
DEFINE MENU MENU-B-adddiscnt
       MENU-ITEM m_cash-abs     LABEL "На подитог абсолютная"
       MENU-ITEM m_cash-pcnt    LABEL "На подитог процентная"
       MENU-ITEM m_gds-abs      LABEL "На товар абсолютная"
       MENU-ITEM m_without      LABEL "Товар без скидки на итог".
DEFINE MENU MENU-BR-pay
       MENU-ITEM m-pay          LABEL "Оплата"        .
DEFINE MENU m_marks
       MENU-ITEM m_marks-utd    LABEL "Марки по чеку"
       MENU-ITEM m_marks-lines  LABEL "Марки по линии".
DEFINE MENU m-func
       MENU-ITEM m-add-blocked-marks       LABEL "Автозаполнение по заблок. маркам".
DEFINE BUTTON b-addbonus
     LABEL "Бонусы"
     SIZE 14 BY 1.
DEFINE BUTTON B-adddiscnt
     LABEL "Скидки"
     SIZE 14 BY 1.
DEFINE BUTTON B-addgds
     LABEL "Доб. товар"
     SIZE 14 BY 1.
DEFINE BUTTON B-addpay
     LABEL "Оплата"
     SIZE 10 BY 1.
DEFINE BUTTON B-card
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-cd
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-cf
     LABEL "&Фиск"
     SIZE 10 BY 1.
DEFINE BUTTON b-choose-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date"
     SIZE 3 BY .88.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 3 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON br-attr
     LABEL "Атр"
     SIZE 4 BY 1.
define button b-func
    label "функ."
    size 6 by 1 .
DEFINE BUTTON Btn_sht-from
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.63 BY 1 TOOLTIP "Выбор оснований".
DEFINE BUTTON BUTTON-susp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.63 BY 1 TOOLTIP "Выбор причин".
DEFINE BUTTON B_mark
     LABEL "Марки"
     SIZE 9.13 BY 1.
DEFINE BUTTON b-slip-chk
     LABEL "Просмотр слипов"
     SIZE 15.75 BY 2.
DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 27 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-susp-chk AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 250 SCROLLBAR-VERTICAL
     SIZE 94.38 BY 1.71 NO-UNDO.
DEFINE VARIABLE corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-cashier AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-cause-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Описание корректировки"
     VIEW-AS FILL-IN
     SIZE 64 BY 1 TOOLTIP "Краткое описание причины проведения корректировки" NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Клиент"
      VIEW-AS TEXT
     SIZE 20.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE F-salesman AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.63 BY 1 NO-UNDO.
DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Основание корректировки"
     VIEW-AS FILL-IN
     SIZE 24 BY .75 NO-UNDO.
DEFINE VARIABLE text-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Причина подозрительного чека"
     VIEW-AS FILL-IN
     SIZE 30 BY .75 NO-UNDO.
DEFINE VARIABLE v-corr-osnov AS CHARACTER FORMAT "X(80)"
     LABEL "Основание"
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1 NO-UNDO.
DEFINE VARIABLE v-corr-type AS CHARACTER FORMAT "X(15)"
     LABEL "Тип коррекции"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE v-doc-osnov AS CHARACTER FORMAT "X(256)":U
     LABEL "Документ"
     VIEW-AS FILL-IN
     SIZE 32.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-link-chk AS CHARACTER FORMAT "X(256)":U
     LABEL "Ссылка на ~"корректный~" чек"
     VIEW-AS FILL-IN
     SIZE 66.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-src-d-card AS CHARACTER FORMAT "x(8)"
     LABEL "ДК в чеке"
     VIEW-AS FILL-IN
     SIZE 20.13 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 100.5 BY 3.5 TOOLTIP "Основание корректировки".
DEFINE QUERY BR-discnt FOR
      tt-chk-discnt SCROLLING.
DEFINE QUERY BR-gds FOR
      tt-chk-gds,
      tt-gds-info SCROLLING.
DEFINE QUERY BR-corr FOR
      tt-chk-gds SCROLLING.
DEFINE QUERY BR-pay FOR
      tt-chk-pay,
      tt-pay-info SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-chk-doc SCROLLING.
DEFINE BROWSE BR-discnt
  QUERY BR-discnt SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-discnt.line-num COLUMN-LABEL "N строки!начисления"
entry (lookup (string(tt-chk-discnt.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) COLUMN-LABEL "Тип!знач"
tt-chk-discnt.object-line-num COLUMN-LABEL "N строки!товара!-объекта"
entry (lookup (string(tt-chk-discnt.line-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) COLUMN-LABEL "Объект!скидки/!бонуса" FORMAT "X(15)"
(IF tt-chk-discnt.record-type < 4
 THEN entry (lookup (string(tt-chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)
 ELSE STRING(tt-chk-discnt.discnt-type)) COLUMN-LABEL "Тип скидки/!код схемы" FORMAT "X(20)"
tt-chk-discnt.real-value-abs COLUMN-LABEL "abs!Знач.скидки/!бонуса"
tt-chk-discnt.real-value-pcnt COLUMN-LABEL "% Знач.скидки/!бонуса" FORMAT "->>9.99"
tt-chk-discnt.src-d-card COLUMN-LABEL "№ Карты!для начисления"
tt-chk-discnt.discnt-id COLUMN-LABEL "ID!транзакц" FORMAT ">>>>>>>>9"
tt-chk-discnt.kateg COLUMN-LABEL "Код !валюты" FORMAT "->>>9"
tt-chk-discnt.d-card COLUMN-LABEL "№ карты" FORMAT "X(20)"
get-templ-rl-name( INPUT tt-chk-discnt.templ-rl-root) COLUMN-LABEL "Шаблон скидки" FORMAT "X(255)" WIDTH 50
tt-chk-discnt.promo-id COLUMN-LABEL "Промо" FORMAT "X(20)"
ENABLE
tt-chk-discnt.real-value-abs
tt-chk-discnt.real-value-pcnt
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 6.67
         FONT 4.
DEFINE BROWSE BR-gds
  QUERY BR-gds SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.src-code COLUMN-LABEL "Исходный код" format "X(19)" width 14
      tt-chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      tt-chk-gds.b-code FORMAT "99999999999":U
      tt-gds-info.artic COLUMN-LABEL "Артикул" FORMAT "X(16)"
      tt-gds-info.gds-name COLUMN-LABEL "Название товара" FORMAT "X(48)" width 20
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt
      tt-gds-info.src-d-pcnt COLUMN-LABEL "%" FORMAT "->>9.99%"
      tt-gds-info.src-price-netto  COLUMN-LABEL "Цена нетто в чеке" FORMAT "->>>,>>>,>>9.99"
      tt-gds-info.src-sum-netto COLUMN-LABEL "Итого в чеке" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-gds-info.prt-name COLUMN-LABEL "Признак/!шкала" FORMAT "X(40)" width 20
      tt-chk-gds.doc-qnty COLUMN-LABEL "Количество БД"
      tt-chk-gds.price-base COLUMN-LABEL "Цена БД"
      tt-chk-gds.discnt COLUMN-LABEL "Скидка БД"
      tt-gds-info.d-pcnt COLUMN-LABEL "%" FORMAT "->>9.99%"
      tt-gds-info.price-netto COLUMN-LABEL "Цена нетто БД" FORMAT "->>>,>>>,>>9.99"
      tt-gds-info.sum-netto COLUMN-LABEL "Итого БД" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-chk-gds.pump COLUMN-LABEL  "ТРК" FORMAT ">>9"
      tt-chk-gds.nozzle-code COLUMN-LABEL  "Пист" FORMAT ">>9"
      tt-chk-gds.loc1 COLUMN-LABEL  "Рез." FORMAT "X(3)"
      tt-chk-gds.src-pl-code COLUMN-LABEL  "Скл.!место!в чеке" FORMAT ">>>>>>>>9"
      tt-chk-gds.pl-code COLUMN-LABEL  "Скл.!место!БД" FORMAT ">>>>>>>>>>9"
      if (tt-chk-gds.write-off-code = 1 and can-do("14,15,16,17,36", string(tt-chk-doc.chk-type))) then "Пролито"
      else entry (lookup (STRING(if tt-chk-gds.write-off-code = ? then 0 else tt-chk-gds.write-off-code),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U) COLUMN-LABEL "Код спис" FORMAT "X(20)"
      tt-chk-gds.depart-id COLUMN-LABEL "Объект!кухни!в чеке" FORMAT ">>>>9"
      tt-chk-gds.depart-code COLUMN-LABEL "Объект!кухни!в БД" FORMAT ">>>>9"
      tt-chk-gds.sales-man COLUMN-LABEL "Код!продавца"
      tt-gds-info.salesman-name COLUMN-LABEL "Продавец" FORMAT "X(16)"
      tt-chk-gds.road-tax COLUMN-LABEL "Дор. налог/! или тара"
      tt-chk-gds.src-sum COLUMN-LABEL "Сумма в чеке"
      tt-chk-gds.density COLUMN-LABEL "Плотность"
      tt-chk-gds.pass-gds COLUMN-LABEL "Тип!ввода"
      tt-chk-gds.vat-pc COLUMN-LABEL "% НДС" format "->9.9<%"
      tt-chk-gds.vat-sum-rubl COLUMN-LABEL "Сумма!НДС"
  ENABLE
      tt-chk-gds.src-code
      tt-chk-gds.b-code
      tt-chk-gds.doc-qnty
      tt-chk-gds.pump
      tt-chk-gds.nozzle-code
      tt-chk-gds.loc1
      tt-chk-gds.pl-code
      tt-chk-gds.depart-id
      tt-chk-gds.depart-code
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt
      tt-chk-gds.road-tax
      tt-chk-gds.vat-pc
      tt-chk-gds.vat-sum-rubl
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 6.67
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE BR-corr
  QUERY BR-corr SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.b-code column-label "Номер!налога" format "9"
      get-tax-type(tt-chk-gds.b-code) @ v-tax-type
      tt-chk-gds.src-sum COLUMN-LABEL "Сумма" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-chk-gds.depart-type COLUMN-LABEL "Номер!налога ОФД" format "X(4)"
      get-OVDtax-type(integer(tt-chk-gds.depart-type)) @ v-OVDtax-type
      tt-chk-gds.road-tax COLUMN-LABEL "Налог ОФД"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 6.67
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE BR-pay
  QUERY BR-pay SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-pay.line-num COLUMN-LABEL "NN"
      tt-chk-pay.pay-code COLUMN-LABEL "Платеж"
      tt-chk-pay.curr-code COLUMN-LABEL "Валюта"
      tt-chk-pay.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
      varcurr-name COLUMN-LABEL "Валюта"
      tt-chk-pay.tot-sum COLUMN-LABEL "Сумма платежа"
      tt-chk-pay.tot-base COLUMN-LABEL "Баз.вал."
      tt-chk-pay.tot-rubl COLUMN-LABEL "Рубли"
      tt-chk-pay.pay-card COLUMN-LABEL "№ плат.карты/!или № талона"
      tt-pay-info.calc-rate COLUMN-LABEL "Рассчит.курс!вал.пл-жа в БД"
      tt-pay-info.exch-date COLUMN-LABEL "Дата курса!маг-на" format "99/99/9999"
      tt-pay-info.exch-time-str COLUMN-LABEL "Время курса!маг-на" format "X(8)"
      tt-pay-info.exch-rate COLUMn-LABEL "Курс маг-на!вал.пл-жа"
      tt-pay-info.exch-scale COLUMn-LABEL "Масштаб маг-на!вал. пл-жа"
      tt-chk-pay.cash-rate COLUMN-LABEL "Курс вал. пл-жа!/к б.в.кассы"
      tt-chk-pay.src-val COLUMN-LABEL "Номинал!в чеке"
      tt-chk-pay.src-qnty COLUMN-LABEL "Кол-во!в чеке" FORMAT "->>>,>>9.99"
      tt-chk-pay.par-val COLUMN-LABEL "Номинал!в БД"
      tt-chk-pay.doc-qnty COLUMN-LABEL "Кол-во!в БД" FORMAT "->>>,>>9.99"
      tt-chk-pay.bank-rate
      tt-chk-pay.bank-scale
  ENABLE
      tt-chk-pay.pay-code
      tt-chk-pay.curr-code
      tt-chk-pay.tot-sum
      tt-chk-pay.pay-card
      tt-chk-pay.cash-rate
      tt-chk-pay.src-val
      tt-chk-pay.src-qnty
      tt-chk-pay.par-val
      tt-chk-pay.doc-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 4.21
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 21
     B-next AT ROW 1 COL 25
     Cb-chk-type AT ROW 1 COL 36 COLON-ALIGNED NO-LABEL
     b-func AT ROW 1 COL 83.5
     br-attr AT ROW 1 COL 89.75 WIDGET-ID 8
     B-print AT ROW 1 COL 93.75
     B-hist AT ROW 1 COL 96.75
     B-help AT ROW 1 COL 99.75
     tt-chk-doc.src-tot-doc AT ROW 1.04 COL 75.63 COLON-ALIGNED WIDGET-ID 2
          LABEL "Брутто-чек" FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 11.88 BY 1 TOOLTIP "Брутто-чек"
          FGCOLOR 11
     tt-chk-doc.chk-date AT ROW 2.08 COL 11.63 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11.38 BY 1
     tt-chk-doc.cashier AT ROW 2.08 COL 35.75 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     fhour AT ROW 3.21 COL 11.75 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.21 COL 16 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.21 COL 20 COLON-ALIGNED NO-LABEL
     tt-chk-doc.sales-man AT ROW 3.21 COL 35.75 COLON-ALIGNED
          LABEL "Продавец"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.obj-code AT ROW 4.42 COL 11.63 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN
          SIZE 11.38 BY 1
     tt-chk-doc.d-card AT ROW 4.42 COL 35.75 COLON-ALIGNED
          LABEL "Карта"
          VIEW-AS FILL-IN
          SIZE 17.38 BY 1
     B-card AT ROW 4.42 COL 55.5
     tt-chk-doc.pay-desk AT ROW 5.58 COL 11.63 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.63 BY 1
     b-cd AT ROW 5.58 COL 19.63 WIDGET-ID 6
     v-corr-osnov AT ROW 6.75 COL 11.63 COLON-ALIGNED
     tt-chk-doc.doc-num AT ROW 6.75 COL 28.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 24.88 BY 1
     tt-chk-doc.doc-num2 AT ROW 6.75 COL 64.63 COLON-ALIGNED WIDGET-ID 6
          LABEL "№ заказа"
          VIEW-AS FILL-IN
          SIZE 36.38 BY 1
     v-corr-type AT ROW 6.75 COL 81 COLON-ALIGNED
     text-4 AT ROW 7.75 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     text-1 AT ROW 7.75 COL 40 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     v-susp-chk AT ROW 8.54 COL 3 NO-LABEL WIDGET-ID 86
     v-doc-osnov AT ROW 8.75 COL 12.13 COLON-ALIGNED WIDGET-ID 56
     corr-date AT ROW 8.75 COL 55.5 COLON-ALIGNED WIDGET-ID 24
     f-num-corr AT ROW 8.75 COL 100.5 RIGHT-ALIGNED WIDGET-ID 30
     BUTTON-1 AT ROW 8.79 COL 47 WIDGET-ID 54
     b-choose-date AT ROW 8.79 COL 69.5 WIDGET-ID 36
     BUTTON-susp AT ROW 8.79 COL 98.38 WIDGET-ID 88
     v-link-chk AT ROW 10.30 COL 28.88 COLON-ALIGNED WIDGET-ID 92
     f-cause-corr AT ROW 10.25 COL 100.5 RIGHT-ALIGNED WIDGET-ID 32
     tt-chk-doc.chk-num AT ROW 11.58 COL 12.13 COLON-ALIGNED
          LABEL "N по кассе" FORMAT "->>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 12.63 BY 1
     tt-chk-doc.z-number AT ROW 11.58 COL 36.25 COLON-ALIGNED
          LABEL "Z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.63 BY 1
     tt-chk-doc.src-d-pcnt AT ROW 11.58 COL 65.13 COLON-ALIGNED
          LABEL "Скидка клиен.(%)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.src-shift-date AT ROW 12.71 COL 12.13 COLON-ALIGNED
          LABEL "&Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11.38 BY 1
     tt-chk-doc.cash-rate AT ROW 12.71 COL 65.13 COLON-ALIGNED
          LABEL "Курс нац вал."
          VIEW-AS FILL-IN
          SIZE 19.75 BY 1
     tt-chk-doc.cash-scale AT ROW 12.71 COL 94.63 COLON-ALIGNED
          LABEL "Масштаб"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     tt-chk-doc.shift-name AT ROW 13.88 COL 12 COLON-ALIGNED
          LABEL "№ смены"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-chk-doc.shift-num AT ROW 13.88 COL 16.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.25 BY 1
     v-src-d-card AT ROW 13.88 COL 36.13 COLON-ALIGNED
     b-addbonus AT ROW 13.88 COL 61.63
     B-adddiscnt AT ROW 13.88 COL 75.5
     B-addgds AT ROW 13.88 COL 89.5
     Btn_sht-from AT ROW 13.96 COL 23.13 WIDGET-ID 34
     BR-corr AT ROW 14.96 COL 1
     BR-gds AT ROW 14.96 COL 1
     BR-discnt AT ROW 14.96 COL 1
     BR-pay AT ROW 21.67 COL 1
     tt-chk-doc.PS AT ROW 26 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 69.38 BY 2
     b-slip-chk AT ROW 26.04 COL 71.38
     B-addpay AT ROW 26.04 COL 88.5
     B_mark AT ROW 27 COL 97.51 RIGHT-ALIGNED WIDGET-ID 80
     b-cf AT ROW 27.04 COL 88.63 WIDGET-ID 4
     F-cashier AT ROW 2.08 COL 43.13 COLON-ALIGNED NO-LABEL
     tt-chk-doc.tot-doc AT ROW 2.08 COL 81 COLON-ALIGNED
          LABEL "Сумма брутто"
           VIEW-AS TEXT
          SIZE 20 BY 1
     F-salesman AT ROW 3.21 COL 43.13 COLON-ALIGNED NO-LABEL
     tt-chk-doc.discnt AT ROW 3.21 COL 81 COLON-ALIGNED
          LABEL "Скидка общ."
           VIEW-AS TEXT
          SIZE 20 BY 1
     tt-chk-doc.sub-discnt AT ROW 4.42 COL 81 COLON-ALIGNED
          LABEL "Сумма списаний"
           VIEW-AS TEXT
          SIZE 20 BY 1
     f-cli-name AT ROW 5.58 COL 35.75 COLON-ALIGNED
     tt-chk-doc.netto AT ROW 5.58 COL 81 COLON-ALIGNED
          LABEL "Сумма оплат(нетто)"
           VIEW-AS TEXT
          SIZE 20 BY 1
     tt-chk-doc.d-pcnt AT ROW 11.58 COL 94.63 COLON-ALIGNED
          LABEL "Скидка итоговая(%)"
           VIEW-AS TEXT
          SIZE 6.75 BY 1
     tt-chk-doc.shift-date AT ROW 12.71 COL 36.25 COLON-ALIGNED
          LABEL "Дата учета" FORMAT "99/99/9999"
           VIEW-AS TEXT
          SIZE 10.63 BY 1
          FGCOLOR 12
     "Тип чека" VIEW-AS TEXT
          SIZE 8.63 BY 1.04 AT ROW 1 COL 29
          FGCOLOR 4
     "Время:" VIEW-AS TEXT
          SIZE 6.63 BY 1 AT ROW 3 COL 5.63
     RECT-1 AT ROW 8 COL 2 WIDGET-ID 26
     SPACE(1.24) SKIP(16.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-addbonus:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-addbonus:HANDLE.
ASSIGN
       B-adddiscnt:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-adddiscnt:HANDLE.
ASSIGN
       BR-gds:POPUP-MENU IN FRAME Dialog-Frame             = MENU m-prt:HANDLE.
ASSIGN
       BR-pay:POPUP-MENU IN FRAME Dialog-Frame             = MENU MENU-BR-pay:HANDLE.
ASSIGN
       B_mark:POPUP-MENU IN FRAME Dialog-Frame       = MENU m_marks:HANDLE.
ASSIGN b_mark:MENU-MOUSE = 1.
assign b-func:popup-menu IN FRAME Dialog-Frame       = MENU m-func:HANDLE.
ASSIGN b-func:MENU-MOUSE = 1.
ASSIGN
       text-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       text-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON ANy-key OF FRAME Dialog-Frame
DO:
      return no-apply.
END.
ON END-ERROR OF FRAME Dialog-Frame
DO:
      apply "choose" to B-quit in frame Dialog-Frame.
    return no-apply.
END.
ON STOP OF FRAME Dialog-Frame
DO:
   apply "choose" to b-quit in frame Dialog-Frame.
    return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-addbonus IN FRAME Dialog-Frame
DO:
  run proc-b-addbonus in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-adddiscnt IN FRAME Dialog-Frame
DO:
  run proc-b-adddiscnt in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-addgds IN FRAME Dialog-Frame
DO:
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-b-addgds in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-addpay IN FRAME Dialog-Frame
DO:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-b-addpay in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-slip-chk IN FRAME Dialog-Frame
DO:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-b-slip in this-procedure  (input "chk")  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-card IN FRAME Dialog-Frame
DO:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  DEFINE VARIABLE cli-list as character no-undo .
    run ref/discards.w (
                     input parparentproc
                    ,input "b-sel":U
                    ,input 'все':U
                    ,input get-chkc_context.host-code
                    ,input tt-chk-doc.obj-type
                    ,input tt-chk-doc.obj-code
                    ,input '':U
                    ,input ?
                    ,output cli-list ) no-error.
    if not cli-list  = "" then do:
      FIND FIRST buf_dis-card no-lock where
                  recid(buf_dis-card) = integer(cli-list).
      if buf_dis-card.status_ = 'неисп':U
      or buf_dis-card.status_ = 'смкли':U
      then do:
        message
        substitute("Нельзя создать чек с картой &1&2" +
                  "Карта имеет статус &3, &4"
                  , buf_dis-card.d-card
                  , chr(10)
                  , buf_dis-card.status_
                  , (if buf_dis-card.status_ = 'неисп':U
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца")
                   )
        view-as alert-box error .
        return no-apply.
      end.
      DISPLAY
      buf_dis-card.d-card @ tt-chk-doc.d-card
      with frame Dialog-Frame.
      find first buf_clients no-lock where
                  buf_clients.obj-type = buf_dis-card.cli-type
            AND  buf_clients.obj-code = buf_dis-card.cli-code.
      display
      buf_clients.obj-name @ f-cli-name
      with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-cd IN FRAME Dialog-Frame
DO:
  run sel-cd in this-procedure no-error.
  if error-status:error then return no-apply.
  else do:
    assign
    tt-chk-doc.pay-desk = buf_cash-desk.cash-num
    .
    display
    tt-chk-doc.pay-desk
    with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-cf IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run str/cf-cdtrs.w ( INPUT parparentproc
                      ,INPUT '':U
                       ,INPUT 'chk-id'
                       ,INPUT 0
                       ,INPUT tt-chk-doc.obj-type
                       ,INPUT tt-chk-doc.obj-code
                       ,INPUT ?
                       ,INPUT ?
                       ,INPUT ''
                       ,INPUT tt-chk-doc.chk-id
                       ,OUTPUT v-rid-list ) NO-ERROR.
END.
ON CHOOSE OF b-choose-date IN FRAME Dialog-Frame
DO:
  run sel-date in this-procedure
    (input corr-date :handle
    ,input ""
    ) .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  if par-mode <>  "susp-type" then do:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if par-mode = 'ПРОСМОТР':U then.
  else do:
    run check-this-check in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  end.
  end.
  else do:
      v-is-update = true .
  end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
    if available locked_chk-doc THEN
    run str/cchkdocs.w (
                        input parparentproc
                       , "":U
                       , "one":U
                       , locked_chk-doc.doc-code
                       , p-obj-type
                       , p-obj-code
                       , input-output v-rid-list
                    ).
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run reposition-chk-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run reposition-chk-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
or Right-Mouse-CLICK OF b-print IN FRAME Dialog-Frame
DO:
define variable v-normal-call as logical no-undo .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if last-event:lABEL = "CHOOSE"
  or last-event:lABEL = "ENTER" then do:
    v-normal-call = yes.
  end.
  if v-normal-call then do:
    run str/checkp.p ( input parparentproc, input tt-chk-doc.doc-code).
  end.
  else do:
    run print-xml in this-procedure ( input (dataset superchk:handle)
                                        ,input tt-chk-doc.doc-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при выводе в XML"
      error-status:get-message(1)
      return-value
      view-as alert-box .
    end.
    else do:
      message
      "Чек напечатан в XML"
      view-as alert-box .
    end.
  end.
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  case par-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
       p-doc-rec = ?.
    end.
  END CASE.
  p-next-prev = "quit".
END.
ON CHOOSE OF br-attr IN FRAME Dialog-Frame
DO:
  if available locked_chk-doc then
  run str\superchk-attr.w( input parparentproc,
                            input locked_chk-doc.doc-code).
END.
ON DELETE-CHARACTER OF BR-discnt IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-line-num like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE v-value-type like ub.chk-discnt.value-type no-undo .
DEFINE VARIABLE v-line-type  like ub.chk-discnt.line-type no-undo .
define variable v-record-type as integer no-undo .
define variable v-discnt-type like ub.chk-discnt.discnt-type no-undo .
define buffer loc-tt-chk-discnt for tt-chk-discnt.
 if par-mode <> 'ДОБАВЛЕНИЕ':U then return no-apply.
 glog = yes.
 if dflt-cd <> 'NCR-GM':U
 and dflt-cd <> 'NCR-AS@R':U
 and tt-chk-discnt.record-type = 0
 then do:
  if tt-chk-discnt.object-line-num <> 0 then do:
    message
    "Нельзя удалить скидку/бонус"
    view-as alert-box .
    return no-apply.
  end.
 end.
  message
  "Удалить скидку/бонус из чека ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
  assign
  v-line-num = tt-chk-discnt.line-num
  v-value-type = tt-chk-discnt.value-type
  v-line-type  = tt-chk-discnt.line-type
  v-record-type = tt-chk-discnt.record-type
  v-discnt-type = tt-chk-discnt.discnt-type
  .
  find first locked_chk-discnt where
           locked_chk-discnt.doc-code = tt-chk-doc.doc-code
      AND locked_chk-discnt.line-num = tt-chk-discnt.line-num
      AND locked_chk-discnt.object-line-num = tt-chk-discnt.object-line-num
      AND locked_chk-discnt.discnt-id = tt-chk-discnt.discnt-id.
  delete locked_chk-discnt.
  delete tt-chk-discnt.
  CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
  if v-record-type < 4 then do:
  run get-discnt in this-procedure (
                                          input v-line-num
                                          ,input v-value-type
                                          ,input v-line-type
                                          ,input v-discnt-type
                                          ).
  v-is-sub-d = no.
  for each loc-tt-chk-discnt:
    if loc-tt-chk-discnt.line-type = integer('2':U) then do:
      assign
      v-is-sub-d = yes
      .
    end.
  end.
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame Dialog-Frame.
  end.
END.
ON DELETE-CHARACTER OF BR-gds IN FRAME Dialog-Frame
DO:
if par-mode <> 'ДОБАВЛЕНИЕ':U then return no-apply.
 glog = yes.
  message
  "Удалить товар из чека ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
 find first locked_chk-gds where
          locked_chk-gds.doc-code= tt-chk-gds.doc-code
      AND locked_chk-gds.line-num = tt-chk-gds.line-num.
  for each locked_chk-discnt where
                locked_chk-discnt.doc-code = tt-chk-doc.doc-code and
                locked_chk-discnt.line-num = tt-chk-gds.line-num,
        each tt-chk-discnt where
                tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
                tt-chk-discnt.line-num = tt-chk-gds.line-num:
        if tt-chk-discnt.line-type = integer('2':U)  OR
           TT-chk-discnt.line-type = INTEGER('3':U)
        then
        tt-chk-discnt.line-num = tt-chk-discnt.line-num - 1.
        else
        delete tt-chk-discnt.
        delete locked_chk-discnt.
    end.
  delete locked_chk-gds.
  delete tt-chk-gds.
  delete tt-gds-info.
  CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame Dialog-Frame.
END.
ON DELETE-CHARACTER OF BR-pay IN FRAME Dialog-Frame
DO:
if par-mode <> 'ДОБАВЛЕНИЕ':U then return no-apply.
   glog = yes.
  message
  "Удалить оплату из чека ?"
  view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  delete locked_chk-pay.
  delete tt-chk-pay.
  delete tt-pay-info.
 CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
END.
ON ENTRY OF BR-pay IN FRAME Dialog-Frame
DO:
  APPLY "VALUE-CHANGED" TO br-pay.
END.
ON VALUE-CHANGED OF BR-pay IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
IF par-mode = 'ИЗМЕНЕНИЕ':U  THEN do:
IF AVAILABLE tt-chk-pay
AND tt-chk-pay.pay-card <> ''
AND tt-chk-pay.pay-card <> '0' THEN DO:
  RUN cp-attr-value IN THIS-PROCEDURE (
                                         input tt-chk-pay.pay-code
                                        ,INPUT tt-chk-pay.curr-code
                                        ,INPUT 0
                                        ,INPUT ''
                                         ,INPUT 0
                                        ,INPUT 'paycard-edit-prefix':U
                                         ,OUTPUT v-value
                                         ,OUTPUT v-type) no-ERROR.
    DO v-ii = 1 TO NUM-ENTRIES(v-value):
       IF tt-chk-pay.pay-card BEGINS ENTRY(v-ii, v-value) THEN DO:
           tt-chk-pay.pay-card:READ-ONLY IN BROWSE br-pay = NO.
       END.
    END.
  END.
  ELSE DO:
   tt-chk-pay.pay-card:READ-ONLY IN BROWSE br-pay = YES.
  END.
END.
END.
ON CHOOSE OF Btn_sht-from IN FRAME Dialog-Frame
DO:
  define variable c_shift-list   as character no-undo.
    run str/sht-all.w (parparentproc,
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    tt-chk-doc.src-shift-date:screen-value = string(buf_shift-obj.shift-date) no-error.
    tt-chk-doc.shift-name:screen-value = string(buf_shift-obj.shift-name) no-error.
    tt-chk-doc.shift-num:screen-value = string(buf_shift-obj.shift-num) no-error.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  def var p-corr-osnov as character no-undo.
  def var rid# as character no-undo .
  do with frame Dialog-Frame:
    run ref/codelayout.p(parparentproc,'ВЫБОР':U,"","OsnovCorr", "Основание коррекции",output table tmprecid).
    for first tmprecid where tmprecid.fTable = "code" no-lock:
      find first ub.Code no-lock where recid (ub.Code) = integer(tmprecid.Frecid) no-error .
      v-doc-osnov = ub.Code.CodeName.
      v-corr-osnov1 = integer(ub.Code.code) .
      display v-doc-osnov with frame Dialog-Frame .
      apply "LEAVE":U to v-doc-osnov.
    end.
  end.
END.
ON CHOOSE OF BUTTON-susp IN FRAME Dialog-Frame
DO:
  define variable v-code as character no-undo .
  define buffer buf_reason for ub.code .
  do with frame Dialog-Frame:
    run ref/reasonSuspCheck.w(parparentproc,'ВЫБОР':U,output v-code).
    find first buf_reason no-lock where buf_reason.parent = 'reasons-suspicious-check':U and
    buf_reason.code = v-code no-error .
    if available (buf_reason) then do:
        if buf_reason.code = "0" then do:
            charKey_one = buf_reason.code .
            v-susp = "Иная: " .
            v-susp-chk = "" .
            display v-susp-chk .
            enable v-susp-chk with frame Dialog-Frame .
            v-susp-chk:read-only = false .
        end.
        else do:
            v-susp = "".
            charKey_one = buf_reason.code .
            v-susp-chk = buf_reason.CodeName .
            display v-susp-chk .
            enable v-susp-chk with frame Dialog-Frame .
            v-susp-chk:read-only = true .
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                assign
                ub.susp-chk.reason-name = v-susp-chk
                .
            end.
        end.
    end.
  end.
END.
ON LEAVE OF tt-chk-doc.cashier IN FRAME Dialog-Frame
DO:
  assign
    tt-chk-doc.cashier.
  run get-staff in this-procedure ( input tt-chk-doc.cashier, input 'C':U, input tt-chk-doc.chk-date ) no-error.
END.
ON RETURN OF tt-chk-doc.cashier IN FRAME Dialog-Frame
DO:
  assign
    tt-chk-doc.cashier.
  run get-staff in this-procedure ( input tt-chk-doc.cashier, input 'C':U, input tt-chk-doc.chk-date) no-error.
END.
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
DO:
DEFINE variable old-chk-type AS CHARACTER NO-UNDO.
  IF CAN-FIND(FIRST tt-chk-gds WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code)
  OR CAN-FIND(FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
      THEN DO:
      MESSAGE
      "Установить тип чека можно только в самом начале процесса создания чека" SKIP
      "когда еще не созданы товарные строки и строк оплаты"
      VIEW-AS ALERT-BOX ERROR.
      display cb-chk-type
      with frame Dialog-Frame .
      RETURN NO-APPLY.
  END.
  ASSIGN
  old-chk-type = cb-chk-type
  CB-chk-type
  .
  if cb-chk-type = '8':U then do:
    if get-chkc_context.annu-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать аннулированные чеки>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , entry (lookup (cb-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                , chr(10)
                )
      view-as alert-box error .
      assign
      cb-chk-type = '1':U.
      display
      cb-chk-type
      with frame Dialog-Frame .
      return no-apply.
    end.
    if get-chkc_context.z-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать чеки z-отчета>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , entry (lookup (cb-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                , chr(10)
                )
      view-as alert-box error .
      assign
      cb-chk-type = '1':U.
      display
      cb-chk-type
      with frame Dialog-Frame .
      return no-apply.
    end.
  end.
  if lookup(cb-chk-type, '14,15,16,17,36':U) > 0 then do:
    if ptrl-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать специф.чеки АЗК>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , entry (lookup (cb-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                , chr(10)
                )
      view-as alert-box error .
      assign
      cb-chk-type = '1':U.
      display
      cb-chk-type
      with frame Dialog-Frame .
      return no-apply.
    end.
  end.
  if cb-chk-type = '69':U
  or cb-chk-type = '96':U then do:
    if not get-chkc_context.is-catering then do:
      message
      substitute("Чек типа &1 можно получить только на объекте, на котором включена опция РЕСТОРАН&2"
                , entry (lookup (cb-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
      view-as alert-box error .
      assign
      cb-chk-type = '1':U.
      display
      cb-chk-type
      with frame Dialog-Frame .
      return no-apply.
    end.
  end.
  assign
  tt-chk-doc.chk-type = integer(CB-chk-type).
  if par-mode = 'ДОБАВЛЕНИЕ':U and available locked_chk-doc then
  locked_chk-doc.chk-type = integer(CB-chk-type).
  case CB-chk-type:
    when '96':U
    or when '69':U
    then do:
      menu-item m-write-off:sensitive in menu M-prt = no.
      menu-item m-modificator:sensitive in menu M-prt = YES.
      ASSIGN
      b-adddiscnt:SENSITIVE IN FRAME Dialog-Frame = YES
      b-addbonus:SENSITIVE IN FRAME Dialog-Frame = YES
      b-addpay:SENSITIVE IN FRAME Dialog-Frame = YES
      .
    end.
    WHEN  '14':U
    OR
    WHEN  '16':U
    OR
    WHEN  '15':U
    OR
    WHEN  '17':U
    or
    when '11':U
    or
    when '36':U
    THEN DO:
         assign
         menu-item m-write-off:sensitive in menu M-prt = NO
         menu-item m-modificator:sensitive in menu M-prt = NO
         b-adddiscnt:SENSITIVE IN FRAME Dialog-Frame = NO
         b-addbonus:SENSITIVE IN FRAME Dialog-Frame = NO
         b-addpay:SENSITIVE IN FRAME Dialog-Frame = NO
         .
    end.
    otherwise do:
        if get-chkc_context.is-catering then
         assign
         menu-item m-write-off:sensitive in menu M-prt = yes
         menu-item m-modificator:sensitive in menu M-prt = yes
         .
        ASSIGN
        b-adddiscnt:SENSITIVE IN FRAME Dialog-Frame = YES
        b-addbonus:SENSITIVE IN FRAME Dialog-Frame = YES
        b-addpay:SENSITIVE IN FRAME Dialog-Frame = YES
        .
    END.
  END CASE.
 if CB-chk-type = '12':U then do:
    assign
    tt-chk-pay.tot-sum:read-only in browse br-pay = no
    tt-chk-pay.pay-code:read-only in browse br-pay = yes
    tt-chk-pay.pay-code:visible in browse br-pay = no
    tt-chk-pay.curr-code:visible in browse br-pay = no
    tt-chk-pay.pay-card:visible in browse br-pay = no
    tt-chk-pay.tot-sum:label in browse br-pay = "Сумма"
    b-addpay:visible = no
    .
    RUN create-z-rep IN THIS-PROCEDURE NO-ERROR.
  end.
  else do:
    assign
    tt-chk-pay.tot-sum:read-only in browse br-pay = no
    tt-chk-pay.pay-code:visible in browse br-pay = yes
    tt-chk-pay.curr-code:visible in browse br-pay = yes
    tt-chk-pay.pay-card:visible in browse br-pay = yes
    tt-chk-pay.tot-sum:label in browse br-pay = "Сумма платежа"
    b-addpay:visible = yes
    .
    IF old-chk-type = '12':U THEN DO:
       RUN delete-z-rep IN THIS-PROCEDURE NO-ERROR.
    END.
  end.
END.
ON value-changed OF tt-chk-doc.chk-num IN FRAME Dialog-Frame
DO:
  assign
  tt-chk-doc.chk-num.
END.
ON LEAVE OF tt-chk-doc.chk-date IN FRAME Dialog-Frame
DO:
  assign
  tt-chk-doc.chk-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF v-src-d-card IN FRAME Dialog-Frame
DO:
  assign
  v-src-d-card .
  tt-chk-doc.src-d-card = v-src-d-card .
  if par-l-mask and tt-chk-doc.src-d-card <> "" then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
  else v-src-d-card = tt-chk-doc.src-d-card .
      display
      v-src-d-card
      with frame Dialog-Frame .
END.
ON LEAVE OF corr-date IN FRAME Dialog-Frame
DO:
  assign corr-date.
END.
ON LEAVE OF tt-chk-doc.d-card IN FRAME Dialog-Frame
DO:
  assign
  tt-chk-doc.d-card
  .
  find first buf_dis-card no-lock where
              buf_dis-card.d-card = trim(tt-chk-doc.d-card) no-error.
  if avail buf_dis-card then do:
    if buf_dis-card.status_ = 'неисп':U
    or buf_dis-card.status_ = 'смкли':U
    then do:
      message
      substitute("Нельзя создать чек с картой &1&2" +
                  "Карта имеет статус &3, &4"
                  , buf_dis-card.d-card
                  , chr(10)
                  , buf_dis-card.status_
                  , (if buf_dis-card.status_ = 'неисп':U
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца" )
                   )
      view-as alert-box error .
      assign
      tt-chk-doc.d-card = '':U
      .
      display
      tt-chk-doc.d-card
      with frame Dialog-Frame .
      return no-apply.
    end.
    find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-card.cli-type
           AND buf_clients.obj-code = buf_dis-card.cli-code no-error.
    if available buf_clients then do:
        display
        buf_clients.obj-name @ f-cli-name
        with frame Dialog-Frame.
    end.
    else do:
        release buf_clients.
        display
        chr(63) @ f-cli-name
        with frame Dialog-Frame.
    end.
  end.
  else do:
        release buf_clients.
        display
        chr(63) @ f-cli-name
        with frame Dialog-Frame.
  end.
END.
ON LEAVE OF f-cause-corr IN FRAME Dialog-Frame
DO:
  assign f-cause-corr.
END.
ON LEAVE OF f-num-corr IN FRAME Dialog-Frame
DO:
  assign f-num-corr.
END.
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure ( input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure ( input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure ( input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.
END.
find first user-login where user-login.user-id = ibs.th.gbl.gbl-var:g#userid
                        and user-login.db-num  = ibs.th.gbl.gbl-var:g#db-num
                        no-lock no-error.
  if user-login.user-administrator = no then do:
    menu-item m-gds:sensitive   in menu M-prt = no.
    menu-item m-prt-1:sensitive in menu M-prt = no.
    menu-item m-prt-2:sensitive in menu M-prt = no.
  end.
ON CHOOSE OF MENU-ITEM m-gds
DO:
  if not avail tt-chk-gds then return no-apply.
  run proc-chg-gds in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-modificator
DO:
 DEFINE VARIABLE choice AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-chk-gds FOR tt-chk-gds.
    if not avail tt-chk-gds then return.
  run gbl/d-askw.w ( input "Выбор кода списания",
                      input "Установить признак МОДИФИКАТОРА С 0 ЦЕНОЙ на текущую товарную позицию",
                      input "|",
                      input "Нет|Да|Да+СПИСАНИЕ|Отказ",
                      input "Не  установлен|МОДИФИКАТОР С 0-ЦЕНОЙ"
                            + (if tt-chk-doc.chk-type = integer('96':U)
                               or tt-chk-doc.chk-type = integer('69':U)
                               then "^disable":U
                               else "":U)
                            + "|МОДИФИКАТОР С 0-ценой+КОД СПИСАНИЯ|Отказ от установки кода списания",
                      input 1,
                      input 4,
                      output choice).
 IF choice = 4  THEN RETURN NO-APPLY.
 FIND FIRST buf_tt-chk-gds EXCLUSIVE-LOCK WHERE
        RECID(buf_tt-chk-gds) = recid(tt-chk-gds).
 CASE choice:
     WHEN 1 THEN DO:
       ASSIGN
       buf_tt-chk-gds.write-off-code = 0.
     END.
     WHEN 2 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER('1':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('2':U).
            END.
            WHEN INTEGER('6':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-2':U).
            END.
            WHEN INTEGER('96':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-4':U).
            END.
            WHEN INTEGER('69':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('3':U).
            END.
        END CASE.
     END.
     WHEN 3 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER('1':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('3':U).
            END.
            WHEN INTEGER('6':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-3':U).
            END.
            WHEN INTEGER('96':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-4':U).
            END.
        END CASE.
   END.
 END CASE.
 run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame Dialog-Frame.
 br-gds:REFRESH()  IN FRAME Dialog-Frame.
 apply "entry" to br-gds in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-pay
DO:
if not available tt-chk-pay then return no-apply.
  run proc-chg-pay in this-procedure ( input yes, input tt-chk-pay.curr-code) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-prt-1
DO:
 DEFINE BUFFER b_goods for ub.goods.
  DEFINE BUFFER b_bar-code for ub.bar-code.
 if not avail tt-chk-gds then return.
 FIND FIRST b_bar-code No-LOCK WHERE
                   b_bar-code.b-code = tt-chk-gds.b-code No-ERROR.
  if not avail b_bar-code then return no-apply.
 FIND FIRST b_Goods No-LOCK WHERE
                    b_goods.gds-code = b_bar-code.gds-code No-ERROR.
  if not avail b_goods then return no-apply.
  run setprts in this-procedure ( input recid(b_goods), input recid(b_bar-code), input b_goods.prt-root, input yes) no-error.
  if error-status:error then return no-apply.
  apply "entry" to br-gds in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-prt-2
DO:
  DEFINE BUFFER b_goods for ub.goods.
  DEFINE BUFFER b_bar-code for ub.bar-code.
 if not avail tt-chk-gds then return.
 FIND FIRST b_bar-code No-LOCK WHERE
                   b_bar-code.b-code = tt-chk-gds.b-code No-ERROR.
  if not avail b_bar-code then return no-apply.
 FIND FIRST b_Goods No-LOCK WHERE
                    b_goods.gds-code = b_bar-code.gds-code No-ERROR.
  if not avail b_goods then return no-apply.
    run setparts in this-procedure ( input b_goods.gds-code, input b_bar-code.unit-cli, input b_bar-code.node-code) no-error.
    if error-status:error then return no-apply.
    apply "entry" to br-gds in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-sales-man
DO:
  define variable sale-list as character no-undo .
  define buffer buf_person  for ub.person.
  if not avail tt-chk-gds then return no-apply.
  define buffer buf_staff  for ub.staff.
  run ref/staffs.w (
                 input parparentproc
                ,input "b-sel"
                ,input 'S':U
                ,input get-chkc_context.db-num
                ,input 0
                ,output sale-list ) .
  if sale-list = '':u then return no-apply.
  find first buf_staff no-lock where
            recid(buf_staff) = integer(sale-list) no-error .
  if not available buf_staff then return no-apply.
  assign
  tt-chk-gds.sales-man = buf_staff.staff-code + (if dflt-cd = 'MAGIA-XML':U then 10000 else 0)
  tt-gds-info.salesman-name = get-salesman (input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code)
  .
  assign
  tt-chk-doc.sales-man = 0
  .
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input 'S':U, input tt-chk-doc.chk-date) no-error.
  DISPLAY
  tt-chk-gds.sales-man
  tt-gds-info.salesman-name
  with browse br-gds.
  apply "entry" to br-gds in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-write-off
DO:
 DEFINE VARIABLE choice AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-chk-gds FOR tt-chk-gds.
    if not avail tt-chk-gds then return.
  run gbl/d-askw.w (input "Выбор кода списания",
                      input "Установить признак СПИСАНИЕ на текущую товарную позицию",
                      input "|",
                      input "Нет|Да|Отказ",
                      input "Не  установлен|Установлен|Отказ от установки кода списания",
                      input 1,
                      input 3,
                      output choice).
 IF choice = 3  THEN RETURN NO-APPLY.
 FIND FIRST buf_tt-chk-gds EXCLUSIVE-LOCK WHERE
        RECID(buf_tt-chk-gds) = recid(tt-chk-gds).
 CASE choice:
     WHEN 1 THEN DO:
       ASSIGN
       buf_tt-chk-gds.write-off-code = 0.
     END.
     WHEN 2 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER('1':U)
             or when integer('69':U)
            THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('1':U).
            END.
            WHEN INTEGER('6':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-6':U).
            END.
            WHEN INTEGER('96':U) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER('-9':U).
            END.
        END CASE.
     END.
 END CASE.
 run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame Dialog-Frame.
 br-gds:REFRESH()  IN FRAME Dialog-Frame.
 apply "entry" to br-gds in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_cash-abs
DO:
   discnt-option = '2':U + chr(44) + '2':U.
    apply "choose" to b-adddiscnt in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_cash-abs-bon
DO:
   discnt-option = '2':U + chr(44) + '5':U.
    apply "choose" to b-addbonus in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_cash-pcnt
DO:
   discnt-option = '2':U + chr(44) + '1':U.
    apply "choose" to b-adddiscnt in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gds-abs
DO:
     discnt-option = '1':U + chr(44) + '2':U.
    apply "choose" to b-adddiscnt in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gds-abs-bon
DO:
    discnt-option = '1':U + chr(44) + '5':U.
    apply "choose" to b-addbonus in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-add-blocked-marks
DO:
  run add-blocked-marks .
END.
ON CHOOSE OF MENU-ITEM m_marks-lines
DO:
    if available (tt-chk-gds) then
    do:
       run temp-mark (input 1) .
      if available (tt-marking-lines) then
      do:
        run str/mark_browse.w (input parparentproc,
          input-output table tt-marking-lines by-reference,
          input 'ПРОСМОТР':U,
          input "Марки по чеку: " + tt-chk-doc.doc-code + " по товару " + string(tt-gds-info.gds-name) + " " + tt-gds-info.gds-name,
          input 4,
          input ""
          ) no-error .
      end.
      else
      do:
        message "Нет марок"
          view-as alert-box.
      end.
    end.
    else message "Нет марок"
        view-as alert-box.
    return no-apply .
  END.
ON CHOOSE OF MENU-ITEM m_marks-utd
DO:
    run temp-mark (input 2) .
    if available (tt-marking-lines) then
    do:
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input 'ПРОСМОТР':U,
        input "Марки по чеку: " + tt-chk-doc.doc-code,
        input 4,
        input ""
        ) no-error .
    end.
    else
    do:
      message "Нет марок по документу УПД"
        view-as alert-box.
    end.
  END.
ON LEAVE OF tt-chk-doc.sales-man IN FRAME Dialog-Frame
DO:
   assign
    tt-chk-doc.sales-man.
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input 'S':U, input tt-chk-doc.chk-date) no-error.
END.
ON RETURN OF tt-chk-doc.sales-man IN FRAME Dialog-Frame
DO:
   assign
    tt-chk-doc.sales-man.
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input 'S':U, input tt-chk-doc.chk-date) no-error.
END.
ON LEAVE OF tt-chk-doc.src-d-pcnt IN FRAME Dialog-Frame
DO:
  assign
  tt-chk-doc.src-d-pcnt.
  run proc-pcnt-discnt in this-procedure ( input tt-chk-doc.src-d-pcnt) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON LEAVE OF tt-chk-doc.src-shift-date IN FRAME Dialog-Frame
DO:
  assign
  tt-chk-doc.src-shift-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF v-susp-chk IN FRAME Dialog-Frame
DO:
  assign
    v-susp-chk.
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                if v-susp = "Иная: " then ub.susp-chk.reason-name = v-susp + v-susp-chk .
                else ub.susp-chk.reason-name = v-susp-chk .
            end.
END.
ON LEAVE OF v-link-chk IN FRAME Dialog-Frame
DO:
  assign
    v-link-chk.
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                ub.susp-chk.link-chk = v-link-chk .
            end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
  Marking = ObjSrv:Env:Marking:Sts:Mark.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-gds :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of corr-date in frame Dialog-Frame
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
on delete-character of corr-date in frame Dialog-Frame
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
on ctrl-d of corr-date in frame Dialog-Frame
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
on ctrl-b of corr-date in frame Dialog-Frame
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
on ctrl-e of corr-date in frame Dialog-Frame
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
on ctrl-f of corr-date in frame Dialog-Frame
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
  define MENU m-ed-date36
    MENU-ITEM m-ed-date36-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date36-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date36-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date36-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if corr-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      corr-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date36 :HANDLE
      corr-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle36 as handle no-undo .
  assign
    v-label-handle36 = corr-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle36)
  then do:
    if v-label-handle36 :tooltip = ""
    or v-label-handle36 :tooltip = ?
    then do:
      assign
        v-label-handle36 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date36-1 in menu m-ed-date36 DO:
    apply "ctrl-b":U to corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date36-2 in menu m-ed-date36 DO:
    apply "ctrl-d":U to corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date36-3 in menu m-ed-date36 DO:
    apply "ctrl-e":U to corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date36-4 in menu m-ed-date36 DO:
    apply "ctrl-f":U to corr-date in frame Dialog-Frame .
  END.
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-pay :handle
  ) .
run diasize_init in this-procedure .
on F9 of frame Dialog-Frame anywhere do:
define buffer buf_bar-code  for ub.bar-code.
if not available tt-chk-gds then return no-apply.
find first buF_bar-code no-lock where
           buf_bar-code.b-code = tt-chk-gds.b-code no-error .
if not available buf_bar-code then return no-apply.
run str/showgds.p ( input parparentproc
                  ,input THIS-PROCEDURE:HANDLE
                  ,input buf_bar-code.gds-code
                  ,input 'ПРОСМОТР':U) no-error .
if error-status:error then return no-apply.
apply "entry" to br-gds in frame Dialog-Frame.
return no-apply.
end.
ON value-changed OF br-gds do:
end.
ON LEAVE OF tt-chk-gds.src-qnty IN BROWSE br-gds,
            tt-chk-gds.src-price IN BROWSE br-gds,
            tt-chk-gds.src-discnt IN BROWSE br-gds,
            tt-chk-gds.src-code IN BROWSE br-gds,
            tt-chk-gds.doc-qnty IN BROWSE br-gds,
            tt-chk-gds.b-code IN BROWSE br-gds DO:
define variable old-b-code      like tt-chk-gds.b-code no-undo .
define variable old-src-code    like tt-chk-gds.src-code no-undo .
define variable old-src-qnty like tt-chk-gds.src-qnty no-undo .
define variable old-doc-qnty like tt-chk-gds.doc-qnty no-undo .
define variable old-src-price like tt-chk-gds.src-price no-undo .
define variable old-src-sum like tt-chk-gds.src-sum no-undo .
define variable old-src-discnt like tt-chk-gds.src-discnt no-undo .
define variable old-vat-summ like tt-chk-gds.VAT-sum-rubl no-undo .
    if not avail tt-chk-gds then return no-apply.
    if self:name = "b-code":U and par-mode = 'ИЗМЕНЕНИЕ':U and
    tt-chk-gds.b-code <> integer(tt-chk-gds.b-code:screen-value in browse br-gds) then do:
    RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
    if error-status:error then do:
      tt-chk-gds.b-code:screen-value in browse br-gds = string(tt-chk-gds.b-code).
      return no-apply.
    end.
    end.
    else do:
      assign
      old-b-code       = tt-chk-gds.b-code
      old-src-code     = tt-chk-gds.src-code
      old-src-qnty     = tt-chk-gds.src-qnty
      old-doc-qnty     = tt-chk-gds.doc-qnty
      old-src-price    = tt-chk-gds.src-price
      old-src-sum      = tt-chk-gds.src-sum
      old-src-discnt   = tt-chk-gds.src-discnt
      old-vat-summ     = tt-chk-gds.VAT-sum-rubl
      .
      if old-src-discnt = 0
      and decimal(tt-chk-gds.src-discnt:screen-value in browse br-gds    ) <> 0 then do:
        define variable v-vchoice as integer no-undo .
        define variable v-dchoice as integer no-undo .
        run str/askmdisc.w ( input-output v-vchoice
                            ,input-output v-dchoice) no-error.
        if v-vchoice = 0 then do:
          assign
          tt-chk-gds.src-discnt = old-src-discnt.
          display
          tt-chk-gds.src-discnt
          with browse br-gds.
          return no-apply.
        end.
      end.
      assign
      tt-chk-gds.b-code = integer(tt-chk-gds.b-code:screen-value in browse br-gds)
      tt-chk-gds.src-code = tt-chk-gds.src-code:screen-value in browse br-gds
      tt-chk-gds.src-qnty = decimal(tt-chk-gds.src-qnty:screen-value in browse br-gds    )
      tt-chk-gds.src-discnt = decimal(tt-chk-gds.src-discnt:screen-value in browse br-gds    )
      tt-chk-gds.src-price = decimal(tt-chk-gds.src-price:screen-value in browse br-gds    )
      tt-chk-gds.src-sum = tt-chk-gds.src-qnty * tt-chk-gds.src-price
      tt-chk-gds.VAT-sum-rubl = ((tt-chk-gds.src-price * tt-chk-gds.VAT-pc)/(100 + tt-chk-gds.VAT-pc)) * tt-chk-gds.src-qnty
      .
      run get-b-code in this-procedure ( input v-vchoice
                                        ,input v-dchoice
                                      ) no-error.
      if error-status:error then do:
        assign
        tt-chk-gds.b-code     =   old-b-code
        tt-chk-gds.src-code   =   old-src-code
        tt-chk-gds.src-qnty   =   old-src-qnty
        tt-chk-gds.doc-qnty   =   old-doc-qnty
        tt-chk-gds.src-price  =   old-src-price
        tt-chk-gds.src-sum    =   old-src-sum
        tt-chk-gds.src-discnt =   old-src-discnt
        tt-chk-gds.VAT-sum-rubl = old-vat-summ
        .
        display
        tt-chk-gds.b-code
        tt-chk-gds.src-code
        tt-chk-gds.src-qnty
        tt-chk-gds.doc-qnty
        tt-chk-gds.src-price
        tt-chk-gds.src-discnt
        tt-chk-gds.VAT-sum-rubl
        with browse br-gds.
        undo, return no-apply.
      end.
      find first buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                           and buf_marking-chk.line-num = tt-chk-gds.line-num
                                           no-error .
      if available buf_marking-chk
      then do :
        assign
          tt-chk-gds.b-code     =   old-b-code
          tt-chk-gds.src-code   =   old-src-code
          tt-chk-gds.src-qnty   =   old-src-qnty
          tt-chk-gds.doc-qnty   =   old-doc-qnty
          tt-chk-gds.src-price  =   old-src-price
          tt-chk-gds.src-sum    =   old-src-sum
          tt-chk-gds.src-discnt =   old-src-discnt
          tt-chk-gds.VAT-sum-rubl = old-vat-summ
        .
        display
          tt-chk-gds.b-code
          tt-chk-gds.src-code
          tt-chk-gds.src-qnty
          tt-chk-gds.doc-qnty
          tt-chk-gds.src-price
          tt-chk-gds.src-discnt
          tt-chk-gds.VAT-sum-rubl
        with browse br-gds.
      end .
    end.
end.
ON LEAVE OF tt-chk-gds.pump IN BROWSE br-gds,
            tt-chk-gds.nozzle-code IN BROWSE br-gds,
            tt-chk-gds.loc1 IN BROWSE br-gds,
            tt-chk-gds.road-tax IN BROWSE br-gds,
            tt-chk-gds.depart-id IN BROWSE br-gds,
            tt-chk-gds.depart-code IN BROWSE br-gds,
            tt-chk-gds.pl-code IN BROWSE br-gds
            DO:
    assign
    tt-chk-gds.pump = integer(tt-chk-gds.pump:screen-value in browse br-gds    )
    tt-chk-gds.nozzle-code = integer(tt-chk-gds.nozzle-code:screen-value in browse br-gds    )
    tt-chk-gds.loc1 = tt-chk-gds.loc1:screen-value in browse br-gds
    tt-chk-gds.road-tax = decimal(tt-chk-gds.road-tax:screen-value in browse br-gds    )
    tt-chk-gds.depart-id = integer(tt-chk-gds.depart-id:screen-value in browse br-gds)
    tt-chk-gds.depart-code = integer(tt-chk-gds.depart-code:screen-value in browse br-gds)
    tt-chk-gds.pl-code = integer(tt-chk-gds.pl-code:screen-value in browse br-gds)
    .
end.
ON LEAVE OF tt-chk-discnt.real-value-abs IN BROWSE br-discnt DO:
  if tt-chk-discnt.value-type <> Integer('2':U) and tt-chk-discnt.value-type <> Integer('5':U) then do:
    message
    "Для % и др. скидки редактируйте % значение скидки"
    view-as alert-box error.
    display
    tt-chk-discnt.real-value-abs
    with browse br-discnt .
  end.
  else do:
    RUN proc-leave-discnt-abs IN THIS-PROCEDURE ( input integer('2':U)).
  end.
end.
ON LEAVE OF tt-chk-discnt.real-value-pcnt IN BROWSE br-discnt DO:
  if tt-chk-discnt.value-type = Integer('2':U)  or tt-chk-discnt.value-type = Integer('5':U)  then do:
    message
    "Для абс скидки редактируйте асб значение скидки"
    view-as alert-box error.
    display
    tt-chk-discnt.real-value-pcnt
    with browse br-discnt .
  end.
  else do:
    RUN proc-leave-discnt-abs IN THIS-PROCEDURE ( input integer('1':U)).
  end.
end.
ON LEAVE OF tt-chk-pay.pay-card IN BROWSE br-pay DO:
DEFINE BUFFER buf_tt-chk-pay FOR tt-chk-pay.
  find first buf_tt-chk-pay where
          buf_tt-chk-pay.doc-code = tt-chk-pay.doc-code
      AND buf_tt-chk-pay.line-num = tt-chk-pay.line-num.
  assign
  buf_tt-chk-pay.pay-card = tt-chk-pay.tot-sum:screen-value in browse br-pay
  .
END.
ON LEAVE OF tt-chk-pay.tot-sum IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.tot-sum = decimal(tt-chk-pay.tot-sum:screen-value in browse br-pay    )
  locked_chk-pay.tot-sum = tt-chk-pay.tot-sum
  .
END.
ON LEAVE OF tt-chk-pay.pay-code IN BROWSE br-pay DO:
  define buffer buf_cash-pay  for ub.cash-pay.
  assign
  tt-chk-pay.pay-code= integer(tt-chk-pay.pay-code:screen-value in browse br-pay    )
  .
  display
  get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
  varcurr-name  with browse br-pay.
  run proc-chg-pay in this-procedure ( input no, input tt-chk-pay.curr-code ).
END.
ON LEAVE OF tt-chk-pay.curr-code IN BROWSE br-pay DO:
  define variable old-curr-code like ub.chk-pay.curr-code no-undo.
  assign
   old-curr-code = tt-chk-pay.curr-code
  tt-chk-pay.curr-code= integer(tt-chk-pay.curr-code:screen-value in browse br-pay    )
  .
  display
  get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
  varcurr-name  with browse br-pay.
  run proc-chg-pay in this-procedure ( input no, input old-curr-code).
END.
ON LEAVE OF tt-chk-pay.src-qnty IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.src-qnty = decimal(tt-chk-pay.src-qnty:screen-value in browse br-pay    )
  locked_chk-pay.src-qnty = tt-chk-pay.src-qnty
  .
END.
ON LEAVE OF tt-chk-pay.doc-qnty IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.doc-qnty = decimal(tt-chk-pay.doc-qnty:screen-value in browse br-pay    )
  locked_chk-pay.doc-qnty = tt-chk-pay.doc-qnty
  .
END.
ON LEAVE OF tt-chk-pay.src-val IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.src-val = integer(tt-chk-pay.src-val:screen-value in browse br-pay    )
  locked_chk-pay.src-val = tt-chk-pay.src-val
  .
END.
ON LEAVE OF tt-chk-pay.par-val IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.par-val = integer(tt-chk-pay.par-val:screen-value in browse br-pay    )
  locked_chk-pay.par-val = tt-chk-pay.par-val
  .
END.
ON LEAVE OF tt-chk-doc.shift-name in frame Dialog-Frame DO:
define variable v-dopi as integer no-undo .
define variable v-old-shift-name as character no-undo .
  assign
  v-old-shift-name = tt-chk-doc.shift-name
  tt-chk-doc.shift-name
  .
  assign
  v-dopi = integer(tt-chk-doc.shift-name) no-error .
  if error-status:error
  or v-dopi < 0
  or v-dopi > 99 then do:
    message
    "Неверное значение № смены"
    view-as alert-box error .
    tt-chk-doc.shift-name = v-old-shift-name .
    display
    tt-chk-doc.shift-name
    with frame Dialog-Frame .
    return no-apply.
  end.
  display
  v-dopi @ tt-chk-doc.shift-num
  with frame Dialog-Frame .
end.
ON RETURN OF tt-chk-gds.src-qnty IN BROWSE br-gds,
            tt-chk-gds.src-price IN BROWSE br-gds,
            tt-chk-gds.src-discnt IN BROWSE br-gds,
            tt-chk-gds.src-code IN BROWSE br-gds,
            tt-chk-gds.pump IN BROWSE br-gds,
            tt-chk-gds.nozzle-code IN BROWSE br-gds,
            tt-chk-gds.pl-code IN BROWSE br-gds,
            tt-chk-gds.loc1 IN BROWSE br-gds,
            tt-chk-gds.road-tax IN BROWSE br-gds,
            tt-chk-discnt.real-value-abs IN BROWSE br-discnt,
            tt-chk-discnt.real-value-pcnt IN BROWSE br-discnt,
            tt-chk-pay.tot-sum IN BROWSE br-pay,
            tt-chk-pay.curr-code IN BROWSE br-pay,
            tt-chk-pay.pay-code IN BROWSE br-pay DO:
  APPLY "LEAVE" to self.
end.
var-mode = par-mode.
p-next-prev = '':U.
n-p: do while p-next-prev = '':U :
MAIN-BLOCK:
DO TRANSACTION ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if LOOKUP(par-mode, ('ИЗМЕНЕНИЕ':U  + chr(4) + 'ДОБАВЛЕНИЕ':U + chr(4) + 'ПРОСМОТР':U + chr(4) + "susp-type"), chr(4) ) = 0 then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode" par-mode
      view-as alert-box ERROR.
      return error.
  end.
  if p-obj-type <> 'маг':U then DO:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова p-obj-type" p-obj-type
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode <> 'ПРОСМОТР':U then do:
    p-next-prev = 'quit':U.
  end.
  if par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
    assign
    shop-type = locked_chk-doc.obj-type
    shop-code = locked_chk-doc.obj-code
    .
  end.
  if par-mode = "susp-type" then do:
FIND FIRST locked_chk-doc  WHERE
                recid(locked_chk-doc) = p-doc-rec.
    assign
    shop-type = locked_chk-doc.obj-type
    shop-code = locked_chk-doc.obj-code
    .
  end.
  else do:
    assign
    shop-type = p-obj-type
    shop-code = p-obj-code
    .
  end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION convert-discount returns integer
                                          ( input p-disc-reason as integer
                                          , input p-disc-type  as integer
                                          , input p-line-type as integer) :
define variable v-disc-type as integer no-undo .
if p-line-type = integer('1':U)
or p-line-type = integer('0':U)
then do:
  if p-disc-type = 0
  or p-disc-type = 1
  or p-disc-type = 2
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-line-type = integer('3':U)
or p-line-type = integer('2':U) then do:
  if p-disc-type = 101
  or p-disc-type = 102
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-disc-reason <> 0 then do:
  CASE p-disc-reason:
    when 0 then do:
      return integer('0':U).
    end.
    when 1 then do:
      return integer('11':U).
    end.
    when 2 then do:
      return integer('1':U).
    end.
    when 3 or when 15 then do:
      return integer('7':U).
    end.
    when 4 then do:
      return integer('4':U).
    end.
    when 5 then do:
      return integer('12':U).
    end.
    when 6 then do:
      return integer('3':U).
    end.
    when 7 then do:
      return integer('13':U).
    end.
    when 8
    or
    when 9
    or
    when 10
    then do:
      return integer('20':U).
    end.
    when 11
    then do:
      return integer('21':U).
    end.
    when 13
    then do:
      return integer('22':U).
    end.
    when 16 then do:
      return integer('23':U).
    end.
  END CASE.
end.
CASE p-disc-type:
  when 0 then do:
    return integer('0':U).
  end.
  when 1 then do:
    return integer('13':U).
  end.
  when 2 then do:
    return integer('2':U).
  end.
  when 3 then do:
    return integer('4':U).
  end.
  when 4 then do:
    return integer('12':U).
  end.
  when 5 then do:
    return integer('1':U).
  end.
  when 6 then do:
    return integer('3':U).
  end.
  when 7 then do:
    return integer('14':U).
  end.
  when 8 then do:
    return integer('15':U).
  end.
  when 9 then do:
    return integer('16':U).
  end.
  when 101 then do:
    return integer('13':U).
  end.
  when 102 then do:
    return integer('5':U).
  end.
  when 103 then do:
    return integer('1':U).
  end.
  when 104 then do:
    return integer('5':U).
  end.
  when 105 then do:
    return integer('1':U).
  end.
  when 106 then do:
    return integer('1':U).
  end.
END CASE.
END FUNCTION.
run get-general-parameters in this-procedure .
procedure get-general-parameters :
define buffer buf_get-chkc_context for get-chkc_context.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  for each buf_get-chkc_context:
    delete buf_get-chkc_context.
  end.
  create buf_get-chkc_context.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_create-context in g#libchkvl
  (input  shop-type
  ,input  shop-code
  ,input  buffer buf_get-chkc_context:handle
  ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_get-chkc_context.
  assign
  buf_get-chkc_context.parparentproc = parparentproc
  buf_get-chkc_context.p-log-handle = p-log-handle
  buf_get-chkc_context.tt-wd-bh     = buffer tt-wd:handle
  .
  release buf_get-chkc_context.
  find first get-chkc_context.
end.
end procedure.
  get-chkc_context.tt-wd-bh = buffer tt-wd:handle.
  RUn get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  RUn fill-tables in this-procedure no-error.
  if error-status:error then return error.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-chk-doc.obj-type
  ,input  tt-chk-doc.obj-code
  ,output v-host-code
  )  .
  run Myenable in this-procedure .
  br-gds:num-locked-columns = 4.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-gds as INT EXTENT 33 no-undo.
DEF VAR varmvibr-gds       as INT no-undo.
DEF VAR varmvjbr-gds       as INT no-undo.
DEF VAR varmvkbr-gds       as INT no-undo.
DEF VAR varmvlbr-gds       as INT no-undo.
DEF VAR move-elementbr-gds as INT no-undo.
def var jjbr-gds           as int no-undo.
do varmvibr-gds = 1 to EXTENT(cur-clmn-numbr-gds):
  ASSIGN cur-clmn-numbr-gds[varmvibr-gds] = varmvibr-gds.
END.
RUN start-mv-clmnbr-gds.
PROCEDURE start-mv-clmnbr-gds:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  par-mode = 'ДОБАВЛЕНИЕ':U  THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33'))] , 1).
   END.
       END.
       IF  par-mode = 'ПРОСМОТР':U and not v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33'))] , 1).
   END.
       END.
       IF  par-mode = 'ИЗМЕНЕНИЕ':U and NOT v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33'))] , 1).
   END.
       END.
       IF  par-mode = 'ПРОСМОТР':U and v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33'))] , 1).
   END.
       END.
       IF  par-mode = 'ИЗМЕНЕНИЕ':U and v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds ( 1, 33).
END.
ON ctrl-cursor-left OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds (33, 1).
END.
PROCEDURE re-move-clmnbr-gds:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = source-column THEN cur-clmn-numbr-gds[varmvibr-gds] = -1.
  END.
  if br-gds:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-gds = source-column - 1 to target-column BY -1:
    DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
        if cur-clmn-numbr-gds[varmvibr-gds] = varmvjbr-gds THEN DO:
          cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-numbr-gds[varmvibr-gds] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-gds = source-column + 1 to target-column:
    DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
      if cur-clmn-numbr-gds[varmvibr-gds] = varmvjbr-gds THEN DO:
        cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-numbr-gds[varmvibr-gds] - 1.
      END.
    END.
  END.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = -1 THEN cur-clmn-numbr-gds[varmvibr-gds] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-gds:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-loc THEN move-elementbr-gds = varmvibr-gds.
  END.
  RUN re-move-clmnbr-gds (cur-clmn-loc, 1).
        if CAN-DO("1,2,3,4", STRING(move-elementbr-gds)) THEN DO:
          ASSIGN varmvkbr-gds = 1.
          DO varmvlbr-gds = 1 to NUM-ENTRIES("1,2,3,4"):
              if move-elementbr-gds = INTEGER(ENTRY (varmvlbr-gds,"1,2,3,4")) THEN NEXT.
              varmvkbr-gds = varmvkbr-gds + 1.
              RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[INTEGER(ENTRY(varmvlbr-gds,"1,2,3,4"))], varmvkbr-gds).
          END.
        END.
        if CAN-DO("5,6", STRING(move-elementbr-gds)) THEN DO:
          ASSIGN varmvkbr-gds = 1.
          DO varmvlbr-gds = 1 to NUM-ENTRIES("5,6"):
              if move-elementbr-gds = INTEGER(ENTRY (varmvlbr-gds,"5,6")) THEN NEXT.
              varmvkbr-gds = varmvkbr-gds + 1.
              RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[INTEGER(ENTRY(varmvlbr-gds,"5,6"))], varmvkbr-gds).
          END.
        END.
        if CAN-DO("7,8,9,10,11,12,13", STRING(move-elementbr-gds)) THEN DO:
          ASSIGN varmvkbr-gds = 1.
          DO varmvlbr-gds = 1 to NUM-ENTRIES("7,8,9,10,11,12,13"):
              if move-elementbr-gds = INTEGER(ENTRY (varmvlbr-gds,"7,8,9,10,11,12,13")) THEN NEXT.
              varmvkbr-gds = varmvkbr-gds + 1.
              RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[INTEGER(ENTRY(varmvlbr-gds,"7,8,9,10,11,12,13"))], varmvkbr-gds).
          END.
        END.
        if CAN-DO("14,15,16,17,18,19", STRING(move-elementbr-gds)) THEN DO:
          ASSIGN varmvkbr-gds = 1.
          DO varmvlbr-gds = 1 to NUM-ENTRIES("14,15,16,17,18,19"):
              if move-elementbr-gds = INTEGER(ENTRY (varmvlbr-gds,"14,15,16,17,18,19")) THEN NEXT.
              varmvkbr-gds = varmvkbr-gds + 1.
              RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[INTEGER(ENTRY(varmvlbr-gds,"14,15,16,17,18,19"))], varmvkbr-gds).
          END.
        END.
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-gds:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-gds = 1 to EXTENT(cur-clmn-numbr-gds):
    RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[varmvlbr-gds], varmvlbr-gds).
  END.
  RUN start-mv-clmnbr-gds.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
PROCEDURE mv-brw-real-defaultbr-gds:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-gds = 1 to EXTENT(cur-clmn-numbr-gds):
    RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[varmvlbr-gds], varmvlbr-gds).
  END.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame focus v-susp-chk.
END.
run mv-brw-real-defaultbr-gds in this-procedure .
end.
run disable_UI in this-procedure .
PROCEDURE check-ch-bc-ck :
define input parameter p-price-sale like ub.gds-obj.price-sale no-undo.
define input parameter p-price-base like ub.chk-gds.price-base no-undo.
define variable glog as logical no-undo.
if par-mode <> 'ИЗМЕНЕНИЕ':U or p-price-base = 0  then return.
if p-price-sale <> p-price-base  AND not ch-bc-ck then do:
    message
    "Цена товара, с которой пробит чек, НЕ РАВНА" skip
    "прейскурантной цене товара (услуги), на который производится замена." skip
    "Редактирование не допускается" skip
    "См. АРМ Администратор-Магазины-Параметры-Опции интерфейса при работе с чеками" skip
    "Настройка <Разрешена смена товара чека (при рекакт. чека) на товар с другой ценой>"
    view-as alert-box
    ERROR.
    return error .
end.
else do:
  if p-price-sale <> p-price-base then do:
      message
      "Цена товара, с которой пробит чек, НЕ РАВНА" skip
      "прейскурантной цене товара (услуги), на который производится замена." skip
      "Подтвердить смену товара  -  ДА, отказаться от изменения - НЕТ"
      view-as alert-box
      WARNING buttons YES-NO update glog.
      if not glog then return error.
  end.
end.
END PROCEDURE.
PROCEDURE temp-mark :
  define input parameter p-id as integer no-undo .
  define buffer buf_marking     for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer bf_marking      for ub.marking .
  define variable v-marking as character no-undo .
  empty temp-table tt-marking-lines .
  if p-id = 1 then
  do:
    for each buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-doc.doc-code and buf_marking-chk.line-num = tt-chk-gds.line-num:
      for first buf_marking no-lock where buf_marking.mark begins buf_marking-chk.mark :
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(buf_marking.gds-code)
          tt-marking-lines.stts        = StatusTHName(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking.gds-code
          tt-marking-lines.sts-utd     = buf_marking.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_marking-chk.line-num
          tt-marking-lines.doc-level   = 1
          .
        if buf_marking-chk.unit <> "UNIT" then
        do:
          for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
            create tt-marking-lines .
            assign
              tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
              tt-marking-lines.stts        = StatusTHName(bf_marking.sts)
              tt-marking-lines.mark        = bf_marking.mark
              tt-marking-lines.mark-parent = bf_marking.mark-parent
              tt-marking-lines.gds-code    = bf_marking.gds-code
              tt-marking-lines.sts-utd     = bf_marking.sts
              tt-marking-lines.unit        = bf_marking.unit
              tt-marking-lines.box-qnty    = bf_marking.box-qnty
              tt-marking-lines.LineNum     = buf_marking-chk.line-num
              tt-marking-lines.doc-level   = 2
              .
          end.
        end.
      end.
    end.
  end.
  else
  do:
    for each buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-doc.doc-code:
      for first buf_marking no-lock where buf_marking.mark begins buf_marking-chk.mark :
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(buf_marking.gds-code)
          tt-marking-lines.stts-utd    = StatusTHName(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking.gds-code
          tt-marking-lines.sts-utd     = buf_marking.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_marking-chk.line-num
          tt-marking-lines.doc-level   = 1
          .
        if buf_marking-chk.unit <> "UNIT" then
        do:
          for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
            create tt-marking-lines .
            assign
              tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
              tt-marking-lines.stts-utd    = StatusTHName(bf_marking.sts)
              tt-marking-lines.mark        = bf_marking.mark
              tt-marking-lines.mark-parent = bf_marking.mark-parent
              tt-marking-lines.gds-code    = bf_marking.gds-code
              tt-marking-lines.sts-utd     = bf_marking.sts
              tt-marking-lines.unit        = bf_marking.unit
              tt-marking-lines.box-qnty    = bf_marking.box-qnty
              tt-marking-lines.LineNum     = buf_marking-chk.line-num
              tt-marking-lines.doc-level   = 2
              .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE check-dublicate :
define buffer dub_chk-doc for ub.chk-doc.
      FIND first dub_chk-doc where
            dub_chk-doc.obj-type = tt-chk-doc.obj-type and
            dub_chk-doc.obj-code = tt-chk-doc.obj-code and
            dub_chk-doc.chk-date = tt-chk-doc.chk-date and
            dub_chk-doc.pay-desk = tt-chk-doc.pay-desk and
            dub_chk-doc.chk-time = tt-chk-doc.chk-time and
            dub_chk-doc.chk-num = tt-chk-doc.chk-num
             NO-ERROR .
if available dub_chk-doc  and
    recid(dub_chk-doc) <> recid(locked_chk-doc) then do:
    message
    "Уже есть чек" dub_chk-doc.doc-code      "по магазину" tt-chk-doc.obj-code "в котором"
    "дата" tt-chk-doc.chk-date SKIP
"время" string(tt-chk-doc.chk-time, "HH:MM:SS":U)  SKIP
"касса" tt-chk-doc.pay-desk SKIP
"номер чека на кассе" tt-chk-doc.chk-num SKIP
"продавец" tt-chk-doc.sales-man
view-as alert-box ERROR.
return error.
end.
END PROCEDURE.
PROCEDURE check-manual :
define variable loc#log as logical no-undo .
define variable v-netto as decimal no-undo .
define buffer buf_tt-chk-pay for tt-chk-pay.
if ((not can-find( first locked_chk-gds where locked_chk-gds.doc-code = tt-chk-doc.doc-code))
and tt-chk-doc.chk-type <> integer('12':U)
)
or (not can-find(first locked_chk-pay where locked_chk-pay.doc-code = tt-chk-doc.doc-code)
and lookup(string(tt-chk-doc.chk-type) , '14,15,16,17,36':U) = 0
and tt-chk-doc.chk-type <> integer('69':U)
and tt-chk-doc.chk-type <> integer('8':U))
and tt-chk-doc.chk-type <> integer('11':U)
then do:
  message
  "В чеке нет строк товаров и/или строк оплат" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if tt-chk-doc.pay-desk = 0 then do:
  message
  "Нельзя создать чек для кассы с номером 0"
  view-as alert-box error .
  return error .
end.
if v-doc-osnov = "" then do:
  message
  "В чеке нет документа основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if corr-date = ? then do:
  message
  "В чеке нет даты основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if f-num-corr = "" then do:
  message
  "В чеке нет номера основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if f-cause-corr = "" then do:
  message
  "В чеке нет описания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
for each buf_tt-chk-pay no-lock:
  assign
  v-netto = v-netto + (if get-chkc_context.r-b = 'base':U
                       then buf_tt-chk-pay.tot-base
                       else buf_tt-chk-pay.tot-rubl )
  .
end.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-osnov" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-osnov"
           buf_chk-doc-attr.attr-value = string(v-corr-osnov1)
           .
end.
else buf_chk-doc-attr.attr-value = string(v-corr-osnov1) .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-date"
           buf_chk-doc-attr.attr-value = string(corr-date)
           .
end.
else buf_chk-doc-attr.attr-value = string(corr-date) .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-num" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-num"
           buf_chk-doc-attr.attr-value = f-num-corr
           .
end.
else buf_chk-doc-attr.attr-value = f-num-corr .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-cause" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-cause"
           buf_chk-doc-attr.attr-value = f-cause-corr
           .
end.
else buf_chk-doc-attr.attr-value = f-cause-corr .
run cur-time in this-procedure(output v-date, output v-time).
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-type" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-type"
           buf_chk-doc-attr.attr-value = "manual"
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-date"
           buf_chk-doc-attr.attr-value = string(v-date,"99.99.9999")
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-time" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-time"
           buf_chk-doc-attr.attr-value = string(v-time,"HH:MM:SS")
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-shift-num" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-shift-num"
           buf_chk-doc-attr.attr-value = string(shift-num_)
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-shift-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-shift-date"
           buf_chk-doc-attr.attr-value = string(shift-date_)
           .
end.
for first ub.cash-pay no-lock where ub.cash-pay.obj-name = "Наличные",
first ub.chk-pay no-lock where ub.chk-pay.pay-code = ub.cash-pay.pay-code and ub.chk-pay.doc-code = tt-chk-doc.doc-code :
message "Необходимо скорректировать документы РКО/ПКО"
view-as alert-box.
end.
END PROCEDURE.
PROCEDURE check-this-check :
define variable v-num as integer no-undo.
define variable v-line-num as integer no-undo .
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_chk-pay for ub.chk-pay.
define buffer loc_chk-gds-pay for ub.chk-gds-pay.
define buffer buf-tt-chk-gds for ub.chk-gds.
define buffer BUF-tt-CHK-DISCNT for tt-CHK-DISCNT.
if tt-chk-doc.chk-num < 0 or tt-chk-doc.chk-num = ? then do:
  message "Заполните номер чека по кассе"
  view-as alert-box.
  return error .
end.
assign
prev-code = tt-chk-doc.doc-code.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    run proc-save-doc in this-procedure no-error.
    if error-status:error then return error.
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U and v-global-err then do:
  message     "В этом чеке имеются фатальные ошибки, которые возможно исправить не удастся!!!!!" skip     "В этом случае постарайтесь пересоздать его руками" skip     "или обратитесь к администратору Вашей системы"     view-as alert-box WARNING.
  return error.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.
 end.
run proc-save-doc in this-procedure no-error.
if error-status:error then return error.
assign
locked_chk-doc.netto = 0
locked_chk-doc.tot-doc = 0
locked_chk-doc.src-tot-doc = 0
locked_chk-doc.discnt = 0
locked_chk-doc.sub-discnt = 0
locked_chk-doc.correct = yes
locked_chk-doc.doc-qnty = 0
for-chk-type = "":U
.
for each loc_chk-discnt where
          loc_chk-discnt.doc-code = tt-chk-doc.doc-code:
   if loc_chk-discnt.record-type = 0 and loc_chk-discnt.line-num <> 0 then NEXT.
   if loc_chk-discnt.record-type = 4  then NEXT.
   delete loc_chk-discnt.
end.
for each loc_chk-gds-pay where loc_chk-gds-pay.doc-code = tt-chk-doc.doc-code:
  delete loc_chk-gds-pay.
end.
for each tt-wd:
  delete tt-wd.
end.
for each loc_chk-gds where
         loc_chk-gds.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-gds.chk-date = tt-chk-doc.chk-date
    loc_chk-gds.line-sign = (if tt-chk-doc.chk-type = integer('1':U)
                             then (loc_chk-gds.src-qnty >= 0)
                             else (loc_chk-gds.src-qnty <= 0)
                          )
    loc_chk-gds.line-type = "":U
    loc_chk-gds.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                          then tt-chk-doc.chk-time
                                          else loc_chk-gds.time-oper)
     .
End.
for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.chk-date = tt-chk-doc.chk-date
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer('1':U)
                                  then (loc_chk-pay.tot-sum >= 0)
                                  else (loc_chk-pay.tot-sum <= 0)
                                  )
     loc_chk-pay.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.
assign
sub-d = 0
.
for each loc_chk-discnt where
         loc_chk-discnt.doc-code = tt-chk-doc.doc-code
by loc_chk-discnt.doc-code
by loc_chk-discnt.line-num
by loc_chk-discnt.discnt-id
         :
    netto-for-sub-d = 0.
    for each buf-tt-chk-gds no-lock where
              buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
              Abs(buf-tt-chk-gds.line-num) < ABS(loc_chk-discnt.line-num) :
      assign
      netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt)
      .
    end.
    if (loc_chk-discnt.line-type = integer('2':U) OR
       loc_chk-discnt.line-type = integer('3':U))
    and loc_chk-discnt.record-type < 4
    then do:
      assign
      sub-d = sub-d + (if loc_chk-discnt.value-type <> integer('1':U)
                       then loc_chk-discnt.discnt-value-abs
                       else 0)
      .
      for each buf-tt-chk-gds no-lock where
               buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
               Abs(buf-tt-chk-gds.line-num) = ABS(loc_chk-discnt.line-num) :
        assign
        netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt)
       .
      end.
      FOR EACH BUF-tt-chk-discnt no-lock where
               buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
               abs(buf-tt-chk-discnt.line-num) <= abs(loc_chk-discnt.line-num):
        if buf-tt-chk-discnt.record-type >= 4 then next.
        if buf-tt-chk-discnt.discnt-id = loc_chk-discnt.discnt-id then next.
        if buf-tt-chk-discnt.line-type = integer('7':U) then do:
          assign
          netto-for-sub-d = netto-for-sub-d + buf-tt-chk-discnt.object-sum
          .
        end.
        if buf-tt-chk-discnt.line-type = integer('2':U) OR
          buf-tt-chk-discnt.line-type = integer('3':U) then do:
          assign
          netto-for-sub-d = netto-for-sub-d - buf-tt-chk-discnt.discnt-value-abs
          .
        end.
      end.
      find first buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  buf-tt-chk-gds.line-num = loc_chk-discnt.line-num no-error.
    end.
    else do:
      if v-line-num <> loc_chk-discnt.line-num then do:
        for each buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  Abs(buf-tt-chk-gds.line-num) = ABS(loc_chk-discnt.line-num) :
          assign
          netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * buf-tt-chk-gds.src-price
          .
        end.
        v-line-num = loc_chk-discnt.line-num.
      end.
      find first buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  buf-tt-chk-gds.line-num = loc_chk-discnt.line-num no-error.
      if loc_chk-discnt.line-type = integer('7':U) then do:
        create tt-wd.
        assign
        tt-wd.line-num = buf-tt-chk-gds.line-num
        tt-wd.doc-code = buf-tt-chk-gds.doc-code
        tt-wd.record-type = 0
        tt-wd.line-type = integer('7':U)
        tt-wd.discnt-id = 0
        tt-wd.wd-sum   = - loc_chk-discnt.object-sum
        .
      end.
    end.
    assign
    loc_chk-discnt.chk-date = tt-chk-doc.chk-date
    loc_chk-discnt.pay-desk = tt-chk-doc.pay-desk
    loc_chk-discnt.obj-code =   tt-chk-doc.obj-code
    loc_chk-discnt.obj-type =   tt-chk-doc.obj-type
    loc_chk-discnt.line-sign = if loc_chk-discnt.line-type = integer('7':U)
                               then no
                               else
                              (if tt-chk-doc.chk-type = integer('1':U)
                                                    then (loc_chk-discnt.discnt-value-abs >= 0)
                                                    else (loc_chk-discnt.discnt-value-abs <= 0)
                                                    )
    loc_chk-discnt.time-oper = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                then tt-chk-doc.chk-time
                                else loc_chk-discnt.time-oper)
    loc_chk-discnt.object-qnty = if (  loc_chk-discnt.line-type = integer('2':U)
                                    OR loc_chk-discnt.line-type = INTEGER('3':U)
                                    )
                                then loc_chk-discnt.object-qnty
                                else buf-tt-chk-gds.src-qnty
    loc_chk-discnt.object-sum = if (   loc_chk-discnt.line-type = integer('2':U)
                                    OR loc_chk-discnt.line-type = INTEGER('3':U)
                                    )
                                then netto-for-sub-d
                                else (
                                      if loc_chk-discnt.line-type = integer('7':U)
                                      then loc_chk-discnt.object-sum
                                      else (buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt) + loc_chk-discnt.discnt-value-abs)
                                     )
    loc_chk-discnt.discnt-value-pcnt = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                       and loc_chk-discnt.discnt-value-abs <> 0
                                       and loc_chk-discnt.discnt-value-pcnt = 0
                                       then (100 * loc_chk-discnt.discnt-value-abs / buf-tt-chk-gds.src-price / buf-tt-chk-gds.src-qnty)
                                       else loc_chk-discnt.discnt-value-pcnt )
    loc_chk-discnt.discnt-value-pcnt = if loc_chk-discnt.record-type >= 4
                                       then loc_chk-discnt.discnt-value-pcnt
                                       else (if loc_chk-discnt.object-sum <> 0
                                            then (if loc_chk-discnt.value-type = integer('2':U)
                                                  then loc_chk-discnt.discnt-value-abs / loc_chk-discnt.object-sum * 100
                                                  else loc_chk-discnt.discnt-value-pcnt)
                                        else 0)
    loc_chk-discnt.discnt-value-abs = if loc_chk-discnt.record-type >= 4
                                       then loc_chk-discnt.discnt-value-abs
                                       else (if loc_chk-discnt.object-sum <> 0
                                              then (if loc_chk-discnt.value-type = integer('2':U)
                                                    then loc_chk-discnt.discnt-value-abs
                                                    else loc_chk-discnt.discnt-value-pcnt * loc_chk-discnt.object-sum / 100)
                                              else 0)
    netto-for-sub-d = netto-for-sub-d - (if loc_chk-discnt.record-type >= 4
                                         then 0
                                         else loc_chk-discnt.discnt-value-abs)
    netto-for-sub-d = netto-for-sub-d - (if loc_chk-discnt.record-type >= 4
                                         then 0
                                         else (if loc_chk-discnt.line-type = integer('7':U)
                                         then loc_chk-discnt.object-sum
                                         else 0
                                         )
                                        )
    .
    if loc_chk-discnt.value-type = integer('1':U)
    and loc_chk-discnt.line-type = integer('2':U)
    then do:
      sub-d = sub-d + loc_chk-discnt.discnt-value-abs.
    end.
    if loc_chk-discnt.record-type < 4 then do:
    find last tt-chk-discnt where
              tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
              tt-chk-discnt.record-type = 0 no-error.
    assign
    var-discnt-id = if avail tt-chk-discnt
                    then tt-chk-discnt.discnt-id
                    else 0
    .
    end.
End.
     get-chkc_context.ll = lll.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  par-mode
  ,input  yes
  ,input  yes
  ,input  ?
  ,input  lng-sub-d
  ,input  sub-d
  ,input  var-discnt-id
  ,input-output prev-code
    ) no-error .
     assign
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
if error-status:error then do:
run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame Dialog-Frame.
 return error.
end.
if locked_chk-doc.correct <> yes
then do:
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
        run gbl/d-askw.w
          (input "Выход из режима создания чека"
          ,input "Созданный Вами чек является ошибочным" + chr(10)
            + "Вы действительно хотите сделать это?" + chr(10)
          ,input "|^"
          ,input "Сохранить|Редактировать|Не сохранять"
          ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|"
               + "Продолжить редактирование и постараться исправить все ошибки в чеке|"
               + "Чек не будет сохранен"
          ,input 2
          ,input 3
          ,output v-num
          ).
        CASE v-num:
            when 2 then do:
                return error.
            end.
             when 3 then do:
                p-doc-rec = ?.
                delete locked_chk-doc .
                return .
             end.
        END CASE.
  end.
  else do:
    run gbl/d-askw.w
      (input "Выход из режима редактирования чека"
      ,input "Редактируемый Вами чек является ошибочным" + chr(10)
      ,input "|^"
      ,input "Сохр ошибочный|Редактировать"
      ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|"
            + "Постараться исправить все ошибки в чеке"
      ,input 1
      ,input 2
      ,output v-num
      ).
      if v-num = 2 then return error.
  end.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U then
run trg/chk-doch.p (
                buffer locked_chk-doc
              , input yes
              , input no
              , input no
              , input-output v-chip-num
              , output v-is-update).
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run trg/chk-doch.p (
                  buffer locked_chk-doc
                , input no
                , input yes
                , input no
                , input-output v-chip-num
                , output v-is-update).
end.
if v-is-update or par-mode = 'ДОБАВЛЕНИЕ':U then do:
  assign
  locked_chk-doc.PS = "!":U + (if index(locked_chk-doc.ps, "shift!") > 0 then "shift!" else '':U) +
                      (if index(locked_chk-doc.ps, "shift!") > 0
                      then substring(left-trim(locked_chk-doc.ps, "!"), 6)
                      else left-trim(locked_chk-doc.PS, "!":U))
  tt-chk-doc.PS = locked_chk-doc.pS
  .
  display
  tt-chk-doc.ps
  with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE check-time :
define input parameter parscreen-value as integer no-undo.
define input parameter par-mode as character no-undo.
define variable var-limit as integer no-undo.
define buffer buf_tt-pay-info for tt-pay-info.
CASE par-mode:
    when "hour":U then do:
         var-limit = 23.
    end.
    when "min":U then do:
          var-limit = 59.
    end.
    when "sec" then do:
          var-limit = 59.
    end.
END.
  if int(parscreen-value) > var-limit then do:
    bell.
    Message "Неверное время!" view-as alert-box ERROR.
    return error.
  end.
  assign
  tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec * 60
  .
  run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input get-chkc_context.base-code,
                                     output cash-rate_,
                                     output cash-scale_,
                                     output exch-date_,
                                     output exch-time_
                                     ) no-error.
 if error-status:error then return error.
  for each buf_tt-pay-info:
  run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input tt-chk-pay.curr-code,
                                     output tt-pay-info.exch-rate,
                                     output tt-pay-info.exch-scale,
                                     output tt-pay-info.exch-date,
                                     output tt-pay-info.exch-time
                                     ) no-error.
  assign
  buf_tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss")
  .
  br-pay:refresh() in frame Dialog-Frame .
 end.
END PROCEDURE.
PROCEDURE create-z-rep :
define variable varrid-list as character no-undo.
DEFine VARiable trid as recid no-undo.
define variable base-rate_   as decimal                 no-undo .
define variable base-scale_  like ub.chk-doc.cash-scale no-undo .
define buffer lnp_chk-pay for ub.chk-pay.
define buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
IF CAN-FIND(FIRST ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = tt-chk-doc.doc-code) THEN DO:
   MESSAGE
   substitute("В чеке типа &1 не может быть строк оплат", entry (lookup (string(tt-chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run proc-save-doc No-ERROR.
  if error-status:error then return error.
end .
varrid-list = "" .
lnp = 0.
run find-bank-curs in this-procedure(
                                                          input tt-chk-doc.chk-date
                                                          ,input 0
                                                          ,output bank-rate_
                                                          ,output bank-scale_
                                                          ) no-error.
run find-curs in this-procedure(
                                                          input tt-chk-doc.chk-date
                                                          ,input tt-chk-doc.chk-time
                                                          ,input 0
                                                          ,output cash-rate_
                                                          ,output cash-scale_
                                                          ,output exch-date_
                                                          ,output exch-time_
                                                          ) no-error.
if get-chkc_context.r-b = 'base':U and
get-chkc_context.base-code <> 0 then do:
  run find-curs in this-procedure(
                                                            input tt-chk-doc.chk-date
                                                            ,input tt-chk-doc.chk-time
                                                            ,input get-chkc_context.base-code
                                                            ,output base-rate_
                                                            ,output base-scale_
                                                            ,output exch-date_
                                                            ,output exch-time_
                                                            ) no-error.
end.
else do:
  assign
  base-rate_ = 1
  base-scale_ = 1
  .
end.
create tt-chk-pay.
assign
lnp = lnp + 1
tt-chk-pay.doc-code = tt-chk-doc.doc-code
tt-chk-pay.line-num = lnp
tt-chk-pay.chk-date = tt-chk-doc.chk-date
tt-chk-pay.pay-code = 0
tt-chk-pay.curr-code = 0
tt-chk-pay.obj-code = tt-chk-doc.obj-code
tt-chk-pay.obj-type = tt-chk-doc.obj-type
tt-chk-pay.bank-rate = bank-rate_
tt-chk-pay.bank-scale = bank-scale_
tt-chk-pay.cash-rate = cash-rate_ / cash-scale_ * (if get-chkc_context.r-b = 'base':U and get-chkc_context.base-code <> 0 then base-rate_ / base-scale_ else 1)
tt-chk-pay.tot-base = 0
tt-chk-pay.tot-sum = 0
tt-chk-pay.tot-rubl = 0
tt-chk-pay.pay-card = "":U
tt-chk-pay.is-error = no
tt-chk-pay.pass-pay = integer('1':U)
.
create tt-pay-info.
buffer-copy tt-chk-pay to tt-pay-info
assign
tt-pay-info.exch-rate = cash-rate_
tt-pay-info.exch-scale = cash-scale_
tt-pay-info.exch-date = exch-date_
tt-pay-info.exch-time = exch-time_
tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
tt-pay-info.calc-rate = cash-rate_ / cash-scale_
.
CREATE locked_chk-pay .
buffer-copy tt-chk-pay to locked_chk-pay.
  trid = recid(tt-chk-pay).
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
REPOSITION br-pay to recid trid NO-ERROR.
glog = BR-pay:SET-REPOSITIONED-ROW(1, "CONDITIONAL") in frame Dialog-Frame.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
apply "entry" to br-pay in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE delete-z-rep :
DEFINE BUFFER buf_chk-pay FOR ub.chk-pay.
    FOR EACH tt-chk-pay WHERE
        tt-chk-pay.doc-code = tt-chk-doc.doc-code
   AND tt-chk-pay.curr-code = 0
    AND tt-chk-pay.pay-code = 0,
    FIRST buf_chk-pay WHERE
         buf_chk-pay.doc-code = tt-chk-doc.doc-code
   AND buf_chk-pay.line-num = tt-chk-pay.line-num:
   DELETE tt-chk-pay.
   DELETE buf_chk-pay.
END.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY Cb-chk-type fhour fmin fsec v-corr-osnov v-corr-type text-4 text-1
          v-susp-chk v-doc-osnov corr-date f-num-corr v-link-chk f-cause-corr
          v-src-d-card F-cashier F-salesman f-cli-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.src-tot-doc tt-chk-doc.chk-date tt-chk-doc.cashier
          tt-chk-doc.sales-man tt-chk-doc.obj-code tt-chk-doc.d-card
          tt-chk-doc.pay-desk tt-chk-doc.doc-num tt-chk-doc.doc-num2
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
          tt-chk-doc.src-shift-date tt-chk-doc.cash-rate tt-chk-doc.cash-scale
          tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.PS
          tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt
          tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.shift-date
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-prev B-next Cb-chk-type b-func br-attr B-print B-hist
         B-help tt-chk-doc.src-tot-doc RECT-1 tt-chk-doc.chk-date
         tt-chk-doc.cashier fhour fmin fsec tt-chk-doc.sales-man
         tt-chk-doc.obj-code tt-chk-doc.d-card B-card tt-chk-doc.pay-desk b-cd
         v-corr-osnov tt-chk-doc.doc-num tt-chk-doc.doc-num2 v-corr-type
         v-susp-chk v-doc-osnov corr-date f-num-corr BUTTON-1 b-choose-date
         BUTTON-susp v-link-chk f-cause-corr tt-chk-doc.chk-num
         tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date
         tt-chk-doc.cash-rate tt-chk-doc.cash-scale tt-chk-doc.shift-name
         tt-chk-doc.shift-num v-src-d-card b-addbonus B-adddiscnt B-addgds
         Btn_sht-from BR-gds BR-discnt BR-pay tt-chk-doc.PS b-slip-chk B-addpay
         B_mark b-cf F-cashier tt-chk-doc.tot-doc F-salesman tt-chk-doc.discnt
         tt-chk-doc.sub-discnt f-cli-name tt-chk-doc.netto tt-chk-doc.d-pcnt
         tt-chk-doc.shift-date
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
END PROCEDURE.
PROCEDURE fill-tables :
define variable v-cashier-code as integer no-undo .
define variable v-seller-code as integer no-undo .
define variable v-cashier-psn-code as integer no-undo .
define variable v-seller-psn-code as integer no-undo .
define variable v-updated as logical no-undo .
define buffer no_buffer_chk-doc for ub.chk-doc.
DEFINE VARIABLE var-is-error as logical no-undo .
define variable v-sum-promo as decimal no-undo.
define variable v-pcnt-promo as decimal no-undo.
for each tt-chk-doc:
    delete tt-chk-doc.
end.
for each tt-chk-gds:
    delete tt-chk-gds.
end.
for each tt-chk-pay:
    delete tt-chk-pay.
end.
for each tt-chk-discnt:
    delete tt-chk-discnt.
end.
for each tt-chk-doc-attr:
    delete tt-chk-doc-attr.
end.
for each tt-gds-info:
  delete tt-gds-info.
END.
for each tt-pay-info:
  delete tt-pay-info.
END.
IF par-mode = 'ДОБАВЛЕНИЕ':U then do:
  message
  "Выберите из списка кассу, для которой Вы хотите создать чек!"
  view-as alert-box.
  run sel-cd in this-procedure no-error.
  if error-status:error then do:
    undo, return error .
  end.
   run gbl/factdate.p (
                    INPUT        shop-type,
                    INPUT        shop-code,
                    INPUT-OUTPUT chk-date_,
                    INPUT-OUTPUT chk-time_,
                    INPUT-OUTPUT shift-date_,
                    INPUT-OUTPUT shift-num_,
                    INPUT-OUTPUT shift-name_,
                    INPUT        YES
                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    if shift-name_ = ? then do:
      shift-name_ = "":U.
    end.
    assign
    v-cashier-code = gbclcode-get-this-db-first-role ( input 'C':U, input get-chkc_context.db-num, input chk-date_)
    no-error .
    assign
    v-seller-code = gbclcode-get-this-db-first-role ( input 'S':U, input get-chkc_context.db-num, input chk-date_)
    no-error .
    run find-curs in this-procedure
                        (
                         input chk-date_
                        ,input chk-time_
                        ,input get-chkc_context.base-code
                        ,output cash-rate_
                        ,output cash-scale_
                        ,output exch-date_
                        ,output exch-time_
                        )  no-error.
    if error-status:error then undo, return error .
      create tt-chk-doc.
      assign
      tt-chk-doc.doc-code =   (if get-chkc_context.db-num = 0
                                then string(next-value(s-chk, ub))
                                else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
      tt-chk-doc.obj-type = shop-type
      tt-chk-doc.obj-code = shop-code
      tt-chk-doc.chk-date = chk-date_
      tt-chk-doc.chk-time = chk-time_
      tt-chk-doc.shift-num  = shift-num_
      tt-chk-doc.src-shift-date = shift-date_
      tt-chk-doc.shift-name      = shift-name_
      tt-chk-doc.cashier   = v-cashier-code
      tt-chk-doc.sales-man   = (if dflt-cd = 'MAGIA-XML':U
                               then v-seller-code + 10000
                               else v-seller-code)
      tt-chk-doc.pay-desk    = (if available buf_cash-desk then buf_cash-desk.cash-num else 0)
      tt-chk-doc.cash-rate = if get-chkc_context.r-b = 'base':U
                                        then cash-rate_
                                        else 1
      tt-chk-doc.cash-scale = if get-chkc_context.r-b = 'base':U
                                        then cash-scale_
                                        else 1
      tt-chk-doc.chk-type = integer('1':U)
      tt-chk-doc.correct = yes
      tt-chk-doc.d-card = "":U
      tt-chk-doc.src-d-card = "":U
      tt-chk-doc.src-d-pcnt = 0
      tt-chk-doc.z-number = 0
      tt-chk-doc.PS = "!"
      .
      create locked_chk-doc.
      buffer-copy tt-chk-doc to locked_chk-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = shop-type AND
                buf_obj.obj-code = shop-code No-ERROR.
end.
else do:
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
  end.
  ELSE do:
      FIND FIRST locked_chk-doc EXCLUSIVE-LOCK WHERE
                 recid(locked_chk-doc) = p-doc-rec.
  END.
  IF NOT AVAIL locked_chk-doc then
  return error.
  if locked_chk-doc.out-code <> ? and par-mode <> 'ПРОСМОТР':U and par-mode <> "susp-type" then do:
     message
     "Чек" locked_chk-doc.doc-code  "включен в продажу" locked_chk-doc.out-code SKIP
     "Изменения не допускаются"
     view-as alert-box error.
     return error.
  end.
  IF LOOKUP('сумма':U, locked_chk-doc.office) > 0
  and par-mode <> 'ПРОСМОТР':U and par-mode <> "susp-type" then do:
    message
    "Чек" locked_chk-doc.doc-code  "является чеком с продаже по группе" SKIP
    "Изменения не допускаются"
    view-as alert-box error .
    return error.
  end.
  if lookup('сум-ош':U, locked_chk-doc.office ) > 0
  and par-mode = 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-global-err = yes
    .
    message     "В этом чеке имеются фатальные ошибки, которые возможно исправить не удастся!!!!!" skip     "В этом случае постарайтесь пересоздать его руками" skip     "или обратитесь к администратору Вашей системы"     view-as alert-box WARNING.
  end.
  if locked_chk-doc.out-2-code <> ?
  and par-mode = 'ИЗМЕНЕНИЕ':U
  then do:
     message
     substitute("Чек &1 привязан к док-ту &2 - изменение невозможно"
                          , locked_chk-doc.doc-code
                          , locked_chk-doc.out-2-code)
     view-as alert-box error .
     undo, return error.
  end.
  if par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then do:
    run str/chklinfx.p (
                    buffer no_buffer_chk-doc
                   ,input locked_chk-doc.doc-code
                   ,input yes
                   ,output v-updated
                    ) no-error .
  end.
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    run str/chklinfx.p (
                    buffer locked_chk-doc
                   ,input locked_chk-doc.doc-code
                   ,input yes
                   ,output v-updated
                    ) no-error .
    if error-status:error then undo, return error .
  end.
  if error-status:error then do:
    message
    "Ошибка при попытке заполнения номеров строк чека" skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
  if not v-updated then undo, return error .
  create tt-chk-doc.
  buffer-copy locked_chk-doc to tt-chk-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-chk-doc.obj-type AND
                buf_obj.obj-code = tt-chk-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Чек" locked_chk-doc.doc-code  skip
              "Неверный объект" locked_chk-doc.obj-type locked_chk-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    if tt-chk-doc.cashier-psn-code <> ? then do:
      FIND FIRST cashier No-LOCK WHERe
                cashier.psn-code = tt-chk-doc.cashier-psn-code No-ERROR.
    end.
    if tt-chk-doc.salesman-psn-code <> ? then do:
      FIND FIRST sales-man No-LOCK WHERe
                sales-man.psn-code = tt-chk-doc.salesman-psn-code No-ERROR.
    end.
    FIND FIRST buf_cash-desk No-LOCK WHERE
               buf_cash-desk.obj-code = shop-code AND
               buf_cash-desk.cash-num = tt-chk-doc.pay-desk NO-ERROR.
    IF tt-chk-doc.chk-type = ? then do:
      assign
      cb-chk-type = if tt-chk-doc.netto >= 0 then '1':U else '6':U
      .
    end.
    else do:
      cb-chk-type = string(tt-chk-doc.chk-type).
    end.
  for each locked_chk-gds where
           locked_chk-gds.doc-code = tt-chk-doc.doc-code no-lock:
        create tt-chk-gds.
        buffer-copy locked_chk-gds to tt-chk-gds.
        create tt-gds-info.
        buffer-copy locked_chk-gds to tt-gds-info
        assign
        tt-gds-info.artic = get-good(input tt-chk-gds.b-code
                                     ,OUTPUT tt-gds-info.gds-code
                                     ,output tt-gds-info.gds-name
                                     ,output tt-gds-info.prt-name
                                     ,output var-is-error)
        tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
        tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
        tt-gds-info.src-sum-netto = GetRoundSum(tt-chk-gds.doc-code, tt-chk-gds.line-num, tt-chk-gds.src-qnty,(tt-chk-gds.src-price - tt-chk-gds.src-discnt))
        tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
        tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
        tt-gds-info.sum-netto = GetRoundSum(tt-chk-gds.doc-code, tt-chk-gds.line-num, tt-chk-gds.doc-qnty,(tt-chk-gds.price-base - tt-chk-gds.discnt))
        tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
        tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
        .
        tt-gds-info.salesman-name = get-salesman(input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code).
        assign
        v-is-top = locked_chk-gds.pump > 0
        tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
        .
    end.
    for each locked_chk-pay no-lock where
             locked_chk-pay.doc-code = tt-chk-doc.doc-code :
        create tt-chk-pay.
        buffer-copy locked_chk-pay to tt-chk-pay
        .
        assign tt-chk-pay.pay-card = (if par-mode = 'ДОБАВЛЕНИЕ':U
                                      then tt-chk-pay.pay-card
                                      else f-paycardv(tt-chk-pay.pay-card, tt-chk-pay.pay-code, tt-chk-pay.curr-code))
        .
        create tt-pay-info.
        buffer-copy locked_chk-pay to tt-pay-info
        assign
        tt-pay-info.calc-rate = tt-chk-pay.tot-rubl / tt-chk-pay.tot-sum
        .
        run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                          input tt-chk-doc.chk-time,
                                          input tt-chk-pay.curr-code,
                                          output tt-pay-info.exch-rate,
                                          output tt-pay-info.exch-scale,
                                          output tt-pay-info.exch-date,
                                          output tt-pay-info.exch-time
                                          ) no-error.
      assign
      tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss").
    end.
  for each locked_chk-doc-attr no-lock where
           locked_chk-doc-attr.doc-code = tt-chk-doc.doc-code:
        create tt-chk-doc-attr.
        buffer-copy locked_chk-doc-attr to tt-chk-doc-attr.
    end.
  for each locked_chk-discnt no-lock where
           locked_chk-discnt.doc-code = tt-chk-doc.doc-code AND
           locked_chk-discnt.record-type = 0:
        if locked_chk-discnt.line-num = 0
         AND locked_chk-discnt.line-type = integer('4':U) then NEXT.
        create tt-chk-discnt.
        buffer-copy locked_chk-discnt to tt-chk-discnt.
        v-sum-promo = ChkPromoSum(locked_chk-discnt.doc-code, locked_chk-discnt.line-num).
        if v-sum-promo <> 0
           and v-sum-promo <> ?
        then do:
           v-pcnt-promo = 100 * ( 1 - (locked_chk-discnt.object-sum / (locked_chk-discnt.object-sum + v-sum-promo))).
           assign
              tt-chk-discnt.real-value-abs = v-sum-promo
              tt-chk-discnt.real-value-pcnt = v-pcnt-promo
              .
        end.
        else assign
               tt-chk-discnt.real-value-abs = tt-chk-discnt.discnt-value-abs
               tt-chk-discnt.real-value-pcnt = tt-chk-discnt.discnt-value-pcnt
               .
  end.
end.
 for each locked_chk-discnt no-lock where
                       locked_chk-discnt.doc-code = tt-chk-doc.doc-code AND
                       locked_chk-discnt.record-type = 4:
    create tt-chk-discnt.
    buffer-copy locked_chk-discnt to tt-chk-discnt.
    assign
       tt-chk-discnt.real-value-abs = tt-chk-discnt.discnt-value-abs
       tt-chk-discnt.real-value-pcnt = tt-chk-discnt.discnt-value-pcnt
       .
  end.
if not par-mode = 'ПРОСМОТР':U and par-mode <> "susp-type" then do:
  if par-mode = 'ДОБАВЛЕНИЕ':U
  and (not get-chkc_context.shift-on
  and cas-shft) then do:
    assign
    tt-chk-doc.src-shift-date = tt-chk-doc.chk-date
    tt-chk-doc.shift-date = tt-chk-doc.chk-date
    .
  end.
end.
if tt-chk-doc.cashier > 0 then do:
  if tt-chk-doc.cashier-psn-code = 0
  or tt-chk-doc.cashier-psn-code = ? then
  assign
  v-cashier-psn-code =  gbclcode-is-this-db-role (
                                                  input 'C':U
                                                 ,input get-chkc_context.db-num
                                                 ,input tt-chk-doc.cashier
                                                 ,input tt-chk-doc.chk-date
                                                   )
  no-error .
  else v-cashier-psn-code = tt-chk-doc.cashier-psn-code.
  if v-cashier-psn-code > 0 then do:
    find first buf_cashier no-lock where
                buf_cashier.obj-type = 'чел':U
            AND buf_cashier.obj-code = v-cashier-psn-code no-error.
  end.
  else do:
      release buf_cashier.
  end.
end.
else do:
  release buf_cashier.
end.
if tt-chk-doc.sales-man > 0 then do:
  if tt-chk-doc.salesman-psn-code = 0
  or tt-chk-doc.salesman-psn-code = ? then
  assign
  v-seller-psn-code =  gbclcode-is-this-db-role ( input 'S':U
                                                   ,input get-chkc_context.db-num
                                                   ,input tt-chk-doc.sales-man
                                                   ,input tt-chk-doc.chk-date
                                                   )
  no-error .
  else v-seller-psn-code = tt-chk-doc.salesman-psn-code.
  if v-seller-psn-code > 0 then do:
    find first buf_sales-man no-lock where
                buf_sales-man.obj-type = 'чел':U
            AND buf_sales-man.obj-code = v-seller-psn-code no-error.
  end.
  else do:
    release buf_sales-man.
  end.
end.
else do:
  release buf_sales-man.
end.
if tt-chk-doc.d-card <> "":U then do:
      FIND FIRST buf_dis-card No-LOCK WHERe
                buf_dis-card.d-card = tt-chk-doc.d-card No-ERROR.
end.
else do:
  release buf_dis-card.
end.
if available buf_dis-card then do:
     find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-card.cli-type
           AND buf_clients.obj-code = buf_dis-card.cli-code no-error.
end.
else do:
release buf_clients.
end.
assign
F-cashier  = if available buf_cashier
                    then  buf_cashier.obj-name
                    else chr(63)
F-salesman = if available buf_sales-man
                    then buf_sales-man.obj-name
                    else chr(63)
f-cli-name  = if available buf_clients
                    then buf_clients.obj-name
                    else (if tt-chk-doc.d-card = "":U
                            then "":U
                            else chr(63)
                            )
fhour  = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 1, 2))
fmin  = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 4, 2))
fsec = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 7, 2))
.
END PROCEDURE.
PROCEDURE find-bank-curs :
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-curr-code like ub.currency.curr-code no-undo.
DEFINE output PARAMETER par-rate as decimal no-undo.
DEFINE output PARAMETER par-scale as decimal no-undo.
    IF par-curr-code <> 0 then do:
        FIND LAST ub.curr-bank NO-LOCK Where
                    ub.curr-bank.curr-code = par-curr-code AND
                   ub.curr-bank.exch-date < par-date NO-ERROR .
        IF NOT AVAIL ub.curr-bank then do:
            assign
             par-rate = ?
             par-scale = ?
             .
        end.
        else do:
            assign
            par-rate = ub.curr-bank.exch-rate
            par-scale =  ub.curr-bank.exch-scale
            .
        end.
    END.
    else
    assign
    par-rate = 1
    par-scale = 1
    .
END PROCEDURE.
PROCEDURE find-curs :
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-time as integer no-undo.
DEFINE INPUT PARAMETER par-curr-code like ub.currency.curr-code no-undo.
DEFINE output PARAMETER par-rate as decimal no-undo.
DEFINE output PARAMETER par-scale as decimal no-undo.
define output parameter par-exch-date as date no-undo .
define output parameter par-exch-time as integer no-undo .
    IF par-curr-code <> 0 then do:
        FIND LAST ub.curr-shop NO-LOCK Where
                             ub.curr-shop.obj-type = shop-type AND
                    ub.curr-shop.obj-code  = shop-code AND
                    ub.curr-shop.curr-code = par-curr-code AND
                   ( ( ub.curr-shop.exch-date = par-date AND
                   ub.curr-shop.exch-time <= par-time ) OR
                   ub.curr-shop.exch-date < par-date ) NO-ERROR .
        IF NOT AVAIL ub.curr-shop then do:
            message
            "Нет магазинного курса валюты на дату и время чека!" skip
            "код валюты" par-curr-code
             "дата" string(par-date, "99/99/9999")
            "время" string(par-time, "hh:mm") view-as alert-box ERROR.
           return error.
        end.
        assign
        par-rate = curr-shop.exch-rate
        par-scale =  curr-shop.exch-scale
        par-exch-date = curr-shop.exch-date
        par-exch-time = curr-shop.exch-time
        .
    END.
    else
    assign
    par-rate = 1
    par-scale = 1
    par-exch-date = 04/01/1990
    .
END PROCEDURE.
PROCEDURE find-uchet-date :
assign
tt-chk-doc.src-shift-date = if (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
                            then tt-chk-doc.src-shift-date
                                                        else tt-chk-doc.chk-date
tt-chk-doc.shift-date = if t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
                      then (tt-chk-doc.chk-date - 1)
                      else tt-chk-doc.src-shift-date
.
display
tt-chk-doc.shift-date
with frame Dialog-Frame.
run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input get-chkc_context.base-code,
                                     output cash-rate_,
                                     output cash-scale_,
                                     output exch-date_,
                                     output exch-time_
                                     ) no-error.
 if error-status:error then return error.
END PROCEDURE.
PROCEDURE get-b-code :
define input parameter p-discnt-v-type as integer no-undo .
define input parameter p-discnt-type as integer no-undo .
DEFINE VARIABLE var-discnt-id like ub.chk-discnt.discnt-id no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE var-is-error as logical no-undo .
define buffer loc_bar-code for ub.bar-code.
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer loc-tt-chk-discnt for tt-chk-discnt.
define buffer last_chk-discnt for tt-chk-discnt.
define buffer buf_goods for ub.goods.
assign
tt-chk-gds.is-error = ?
tt-chk-gds.src-sum = tt-chk-gds.src-qnty * tt-chk-gds.src-price
.
assign
bc-buf = if par-mode = 'ИЗМЕНЕНИЕ':U
         then string(tt-chk-gds.b-code)
         else tt-chk-gds.src-code
price-from-check = tt-chk-gds.src-price
.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  bc-buf
,input  price-from-check
,input  tt-chk-doc.obj-type
,input  tt-chk-doc.obj-code
,input  yes
,input  (par-mode = 'ИЗМЕНЕНИЕ':U or (string(tt-chk-gds.b-code) = entry(1, tt-chk-gds.src-code, chr(4))))
,input  get-chkc_context.sclspref
,input  get-chkc_context.scpgpref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
if available bar-code then do:
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = bar-code.gds-code.
    if bar-code.unit-cli <> buf_goods.unit-base then do:
      message
      "Можно ввести только бар-код для ОСНОВНОЙ единицы измерения"
      view-as alert-box ERROR.
      release bar-code.
      release prod-bc.
      release place.
      assign
      tt-chk-gds.b-code = ?
      tt-gds-info.gds-name = "Неопознанный товар"
      tt-gds-info.artic = "":U
      tt-gds-info.prt-name = "-":U
      tt-chk-gds.is-error = yes
      .
      return error .
    end.
    run get-price1 in this-procedure ( input buf_goods.gds-code, input bar-code.node-code) No-ERROR.
    RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
    if error-status:error then undo, return error.
  end.
  else do:
     assign
     tt-chk-gds.b-code  = bar-code.b-code
     tt-chk-gds.is-error = no
    .
  end.
end.
else assign
tt-chk-gds.b-code = ?
tt-gds-info.gds-name = "Неопознанный товар"
tt-gds-info.artic = "":U
tt-gds-info.prt-name = "-":U
tt-chk-gds.is-error = yes
.
assign
units-rate = 1
units-dpcnt = 0
price-from-check = tt-chk-gds.src-price
.
if tt-chk-gds.b-code <> ? then do:
find first loc_bar-code no-lock where
            loc_bar-code.b-code = tt-chk-gds.b-code no-error.
    if available loc_bar-code then do:
    assign
    units-rate = (if par-mode = 'ДОБАВЛЕНИЕ':U then loc_bar-code.cli-base-rate else tt-chk-gds.doc-qnty / tt-chk-gds.src-qnty)
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  loc_bar-code.gds-code
  ,input  loc_bar-code.node-code
  ,output r-bar-code
  ) no-error .
    if error-status:error then do:
      assign
      b-c = ?
      .
    end.
    else do:
      if loc_bar-code.in-code = "":U
      and loc_bar-code.part-code = "":U then do:
        assign
        b-c = r-bar-code
        .
      end.
      else do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspcode in g#library
  (input  loc_bar-code.gds-code
  ,input  loc_bar-code.node-code
  ,input  loc_bar-code.in-code
  ,input  loc_bar-code.part-code
  ,output r-bar-code
  )  .
          assign
          b-c = (if error-status:error
                then ?
                else r-bar-code)
          .
     end.
     if b-c = ? then do:
       assign
       tt-chk-gds.is-error = yes
       .
     end.
     else do:
      assign
      b-c = r-bar-code
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code
                                 ,output tt-gds-info.gds-code
                                 ,output tt-gds-info.gds-name
                                 ,output tt-gds-info.prt-name
                                 ,output var-is-error)
      tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
      .
    end.
    end.
  end.
end.
else do:
    assign
    b-c = ?
    tt-gds-info.gds-name = "Неопознанный товар"
    tt-gds-info.artic = "":U
    tt-gds-info.prt-name = "-":U
    tt-chk-gds.is-error = yes
    .
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  if tt-chk-gds.src-discnt <> 0 then do:
    if dflt-cd <> 'NCR-GM':U
    and dflt-cd <> 'NCR-AS@R':U
    then do:
      find first loc-tt-chk-discnt where
                loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
            AND  loc-tt-chk-discnt.record-type = 0
            AND loc-tt-chk-discnt.line-num = tt-chk-gds.line-num
            AND loc-tt-chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      if not avail loc-tt-chk-discnt then do:
        find last LAST_chk-discnt where
                  LAST_chk-discnt.doc-code = tt-chk-doc.doc-code and
                  last_chk-discnt.record-type = 0 no-error.
        assign
        var-discnt-id = if avail LAST_chk-discnt
                        then LAST_chk-discnt.discnt-id
                        else 0
        .
        create loc-tt-chk-discnt.
        assign
        loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
        loc-tt-chk-discnt.record-type = 0
        loc-tt-chk-discnt.line-num = tt-chk-gds.line-num
        loc-tt-chk-discnt.object-line-num = tt-chk-gds.line-num
        loc-tt-chk-discnt.discnt-id = VAR-DISCNT-ID + 1
        loc-tt-chk-discnt.pass-discnt = integer('1':U)
        loc-tt-chk-discnt.value-type = p-discnt-v-type
        loc-tt-chk-discnt.discnt-type = p-discnt-type
        loc-tt-chk-discnt.line-type = integer('1':U)
        .
        create loc_chk-discnt.
        buffer-copy loc-tt-chk-discnt to loc_chk-discnt
        .
      end.
      else do:
        find first loc_chk-discnt where
                  loc_chk-discnt.doc-code = tt-chk-doc.doc-code
              AND loc_chk-discnt.record-type = 0
              AND loc_chk-discnt.line-num = tt-chk-gds.line-num
              AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      end.
      assign
      loc-tt-chk-discnt.discnt-value-abs = (if tt-chk-gds.src-discnt * tt-chk-gds.src-qnty = ?
                                            then 0
                                            else tt-chk-gds.src-discnt * tt-chk-gds.src-qnty)
      loc_chk-discnt.discnt-value-abs = (if tt-chk-gds.src-discnt * tt-chk-gds.src-qnty = ?
                                        then 0
                                        else tt-chk-gds.src-discnt * tt-chk-gds.src-qnty)
      .
    end.
  end.
  else if tt-chk-gds.src-discnt = 0 then do:
    for each loc_chk-discnt where
                  loc_chk-discnt.doc-code = tt-chk-doc.doc-code
              AND loc_chk-discnt.record-type = 0
              AND loc_chk-discnt.line-num = tt-chk-gds.line-num
              AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num :
        if loc_chk-discnt.line-type = integer('1':U) then do:
          find first loc-tt-chk-discnt where
                    loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
                AND loc-tt-chk-discnt.record-type = loc_chk-discnt.record-type
                AND loc-tt-chk-discnt.line-num = loc_chk-discnt.line-num
                AND loc-tt-chk-discnt.object-line-num = loc_chk-discnt.object-line-num
                AND loc-tt-chk-discnt.discnt-id = loc_chk-discnt.discnt-id no-error.
          delete loc_chk-discnt.
          delete loc-tt-chk-discnt.
      end.
    end.
  end.
end.
if tt-chk-gds.src-qnty <> 0 then  do:
  price-from-check =
  ( tt-chk-gds.SRC-PRICE / ( 1 - units-dpcnt / 100 ) ) * abs( tt-chk-gds.src-qnty ) .
  assign
  tt-chk-gds.b-code = ( if b-c <> ? then b-c else 0)
  tt-chk-gds.is-error = (b-c = ?)
    tt-chk-gds.doc-qnty = if par-mode = 'ДОБАВЛЕНИЕ':U
                        then tt-chk-gds.src-qnty * units-rate
                        else tt-chk-gds.doc-qnty
  tt-chk-gds.doc-qnty = ROUND(tt-chk-gds.doc-qnty, 3)
  tt-chk-gds.price-base = round( price-from-check / abs( tt-chk-gds.doc-qnty ), 2 )
  tt-chk-gds.line-type = '':U
  .
  assign
  tt-chk-gds.discnt = if units-rate = 1
                    then (if (tt-chk-gds.pump > 0)
                          then
                          (tt-chk-gds.src-discnt  +
                            (abs(tt-chk-gds.src-qnty * tt-chk-gds.src-price) - abs(tt-chk-gds.src-sum) )
                            / abs(tt-chk-gds.src-qnty)
                          )
                          else tt-chk-gds.src-discnt
                          )
                    else
                        ( round( tt-chk-gds.src-discnt  +
                          ( price-from-check / abs( tt-chk-gds.doc-qnty )  - tt-chk-gds.src-price / abs( units-rate ) ) +
                          ( price-from-check / abs( tt-chk-gds.doc-qnty ) - tt-chk-gds.price-base ), 2 )
                        )
  tt-chk-gds.sum-base = tt-chk-gds.doc-qnty * tt-chk-gds.price-base
  .
end.
assign
tt-gds-info.src-sum-netto = (tt-chk-gds.src-price - tt-chk-gds.src-discnt) * tt-chk-gds.src-qnty
tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
tt-gds-info.sum-netto = (tt-chk-gds.price-base - tt-chk-gds.discnt) * tt-chk-gds.doc-qnty
tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
.
run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-gds.src-code
  tt-chk-gds.price-base
  tt-chk-gds.discnt
  tt-chk-gds.doc-qnty
  TT-CHK-GDS.B-CODE
  tt-gds-info.artic
  tt-gds-info.gds-name
  tt-gds-info.prt-name
  tt-chk-gds.is-error
  tt-gds-info.src-d-pcnt
  tt-gds-info.src-price-netto
  tt-gds-info.src-sum-netto
  tt-gds-info.d-pcnt
  tt-gds-info.price-netto
  tt-gds-info.sum-netto
  with browse br-gds.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame Dialog-Frame.
  glog = br-gds:refresh() in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE get-discnt :
DEFINE INPUT PARAMETER p-line-num like ub.chk-discnt.line-num.
DEFINE INPUT PARAMETER p-discnt-v-type like ub.chk-discnt.value-type no-undo.
DEFINE INPUT PARAMETER p-discnt-type like ub.chk-discnt.discnt-type no-undo.
DEFINE INPUT PARAMETER p-discnt-target like ub.chk-discnt.line-type no-undo.
define variable v-discnt-value like ub.chk-discnt.discnt-value-abs no-undo.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer buf-tt-chk-gds for tt-chk-gds.
define buffer buf-tt-chk-discnt for tt-chk-discnt.
if p-discnt-target = integer('2':U) OR
   p-discnt-target = integer('3':U)
then do:
    tt-chk-doc.real-subdiscnt = 0.
    for each buf-tt-chk-discnt no-lock where
             buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND
                     buf-tt-chk-discnt.record-type = 0 and
                      buf-tt-chk-discnt.line-type <> integer('1':U)             :
    assign
    tt-chk-doc.real-subdiscnt = tt-chk-doc.real-subdiscnt + buf-tt-chk-discnt.discnt-value-abs
     .
  end.
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame Dialog-Frame.
end.
else do:
    assign
    v-discnt-value = 0.
    for each buf-tt-chk-discnt no-lock where
            buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND
            buf-tt-chk-discnt.record-type = 0 and
            buf-tt-chk-discnt.line-num = p-line-num  AND
            buf-tt-chk-discnt.line-type = integer('1':U) :
            assign
            v-discnt-value = v-discnt-value + buf-tt-chk-discnt.discnt-value-abs
            .
    END.
    find first loc_chk-gds where
                 loc_chk-gds.doc-code = tt-chk-doc.doc-code and
                 loc_chk-gds.line-num = p-line-num no-error.
    find first buf-tt-chk-gds where
                     buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                     buf-tt-chk-gds.line-num = p-line-num no-error.
    assign
    loc_chk-gds.src-discnt = v-discnt-value / loc_chk-gds.src-qnty
    buf-tt-chk-gds.src-discnt = v-discnt-value / buf-tt-chk-gds.src-qnty
    .
    run get-b-code in this-procedure ( input p-discnt-v-type
                                     , input p-discnt-type).
end.
END PROCEDURE.
PROCEDURE get-good-proc :
define input  parameter parb-code as integer no-undo.
define output parameter pargds-code as integer no-undo.
define output parameter pargds-name as character no-undo.
define output parameter parprt-name as character no-undo.
define output parameter paris-error as logical no-undo.
define output parameter var-artic like ub.goods.artic no-undo.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.
define buffer loc_gds-prt for ub.gds-prt.
FIND FIRST loc_bar-code No-LOCK WHERE
           loc_bar-code.b-code = parb-code No-ERROR.
IF  AVAILABLE loc_bar-code then do:
    FIND FIRST loc_goods No-LOCK WHERE
                      loc_goods.gds-code = loc_bar-code.gds-code NO-ERROR.
    IF AVAILABLE loc_goods then do:
        var-artic= loc_goods.artic.
        pargds-name = loc_goods.gds-name.
        pargds-code = loc_goods.gds-code.
    end.
     FIND FIRST loc_gds-prt WHERE
                       loc_gds-prt.node-code = loc_bar-code.node-code NO-LOCK.
    assign
    paris-error = no
    parprt-name =
                    ( if loc_gds-prt.node-name = '_Пустая шкала':U then "-"
                      else ( if loc_gds-prt.upper-code = loc_goods.prt-root
                                then "-------------------" else loc_gds-prt.f-name ) ) .
end.
END PROCEDURE.
PROCEDURE GEt-params :
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type45 as character no-undo .
define variable v-value-date45 as date no-undo .
define variable v-value-decimal45 as decimal no-undo .
define variable v-value-integer45 as INTEGER no-undo .
define variable v-value-logical45 AS LOGICAL no-undo .
define variable v-tth45 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date45
    ,output v-value-decimal45
    ,output v-value-integer45
    ,output v-value-logical45
    ,output v-param-type45
    ,INPUT-OUTPUT table-handle v-tth45
    )  .
delete object v-tth45 no-error.
get-chkc_context.pos-type = dflt-cd.
get-chkc_context.p-log-handle = this-procedure:handle.
p-pos-type = dflt-cd.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'chk-view':U
    ,input  '':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = 'chk-view':U
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when 'dc-change':U then do:
      assign
      dc-change = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'ch-bc-ck':U then do:
      assign
      ch-bc-ck = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
assign
is-prt = no
.
run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'dc-ref':U
    ,input  'l-mask':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = 'dc-ref':U
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when 'l-mask':U then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен," skip
  "а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ch-bc-ck'
  ,input  get-chkc_context.host-code
  ,input  get-chkc_context.obj-type
  ,input  get-chkc_context.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
IF not error-status:error then
ch-bc-ck = (conf-par = "yes").
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
IF not error-status:error then
is-prt = (conf-par = "yes").
find first buf_shop no-lock where buf_shop.obj-code = p-obj-code .
END PROCEDURE.
PROCEDURE get-pay-proc :
define input parameter parpay-code as integer no-undo.
define input parameter parcurr-code as integer no-undo.
define output parameter parcurr-name as character no-undo.
define output parameter varpay-name like ub.cash-pay.obj-name no-undo.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
if tt-chk-doc.chk-type = integer('44':U)
or tt-chk-doc.chk-type = integer('43':U)
then do :
  case parpay-code :
    when 1031 then varpay-name = 'Наличный':U.
    when 1081 then varpay-name = 'Электронный':U.
    when 1215 then varpay-name = 'Аванс':U.
    when 1216 then varpay-name = 'Кредит':U.
    otherwise varpay-name = "Неизвестная оплата".
  end case.
  parcurr-name = "Рубль".
  return.
end.
FIND FIRST loc_cash-pay No-LOCK WHERE
                  loc_cash-pay.cdpay-code = parpay-code AND
                  loc_cash-pay.curr-code = parcurr-code No-ERROR.
if avail loc_cash-pay then do:
    varpay-name = loc_cash-pay.obj-name.
end.
else do:
  if tt-chk-doc.chk-type = integer('12':U)
  and parpay-code = 0
  and parcurr-code = 0
  then do:
    varpay-name = "Показания счетчиков".
  end.
  else do:
    varpay-name = "Неизвестная оплата".
end.
end.
FIND FIRST loc_currency No-LOCK WHERE
                  loc_currency.curr-code = parcurr-code No-ERROR.
if available loc_Currency then do:
    parcurr-name = loc_currency.curr-name.
end.
else parcurr-name = "Неизвестная валюта".
END PROCEDURE.
PROCEDURE get-pay-sums :
define parameter buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_tt-pay-info for tt-pay-info.
find first loc_tt-pay-info where
           loc_tt-pay-info.line-num = loc_tt-chk-pay.line-num  .
    CASE ABS(loc_tt-chk-pay.curr-code):
      when 0 then do:
        assign
        loc_tt-chk-pay.tot-rubl = loc_tt-chk-pay.tot-sum
        loc_tt-chk-pay.tot-base = loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
        loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
        .
      end.
      when get-chkc_context.base-code then do:
        assign
        loc_tt-chk-pay.tot-base = loc_tt-chk-pay.tot-sum
        loc_tt-chk-pay.tot-rubl = if get-chkc_context.r-b = 'base':U
                              then loc_tt-chk-pay.tot-sum * tt-chk-doc.cash-rate
                              else loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
        loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
        .
      end.
      otherwise do:
          assign
          loc_tt-chk-pay.tot-base = if get-chkc_context.r-b = 'base':U
                              then loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
                              else loc_tt-chk-pay.tot-sum
          loc_tt-chk-pay.tot-rubl = if get-chkc_context.r-b = 'base':U
                              then loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate * tt-chk-doc.cash-rate
                              else loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
          loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
          .
      end.
    END CASE.
END PROCEDURE.
PROCEDURE get-price1 :
DEFINE INPUT PARAMETER pargds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER parnode-code like ub.gds-prt.node-code no-undo.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  pargds-code
  ,input  parnode-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  tt-chk-doc.obj-type
  ,input  tt-chk-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  tt-chk-doc.obj-type
  ,input  tt-chk-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
END PROCEDURE.
PROCEDURE get-staff :
define input parameter p-num as integer no-undo.
define input parameter p-role as character no-undo.
define input parameter p-date as date no-undo .
define variable v-psn-code as integer no-undo .
if dflt-cd = 'MAGIA-XML':U then do:
  CASE p-role:
    when 'C':U then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input 'C':U
                                              ,input get-chkc_context.db-num
                                              ,input p-num
                                              ,input p-date
                                              )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_cashier no-lock where
                      buf_cashier.obj-type = 'чел':U
                  and buf_cashier.obj-code = v-psn-code no-error.
        if available buf_cashier then do:
          display
          buf_cashier.obj-name @ f-cashier
          with frame Dialog-Frame.
          find first cashier no-lock where
                    cashier.psn-code = v-psn-code.
        end.
        else do:
          release cashier.
          display
          chr(63) @ F-cashier
          with frame Dialog-Frame.
        end.
      end.
      else do:
        release buf_cashier.
        release cashier.
        display
        chr(63) @ F-cashier
        with frame Dialog-Frame.
      end.
    end.
    when 'S':U then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input 'S':U
                                               ,input get-chkc_context.db-num
                                               ,input (p-num - 10000)
                                               ,input p-date
                                               )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_sales-man no-lock where
                      buf_sales-man.obj-type = 'чел':U
                  and buf_sales-man.obj-code = v-psn-code no-error.
        if available buf_sales-man then do:
          display
          buf_sales-man.obj-name @ f-salesman
          with frame Dialog-Frame.
          find first sales-man no-lock where
                    sales-man.psn-code = v-psn-code.
        end.
        else do:
          release sales-man.
          display
          chr(63) @ F-salesman
          with frame Dialog-Frame.
        end.
      end.
      else do:
        release buf_sales-man.
        release sales-man.
        display
        chr(63) @ F-salesman
        with frame Dialog-Frame.
      end.
    end.
  END CASE.
end.
else do:
CASE p-role:
    when 'C':U then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input 'C':U
                                             ,input get-chkc_context.db-num
                                             ,input p-num
                                             ,input p-date
                                             )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_cashier no-lock where
                      buf_cashier.obj-type = 'чел':U
                  and buf_cashier.obj-code = v-psn-code no-error.
        if available buf_cashier then do:
            display
            buf_cashier.obj-name @ f-cashier
            with frame Dialog-Frame.
        end.
        else do:
            display
            chr(63) @ F-cashier
            with frame Dialog-Frame.
        end.
      end.
      else do:
        release buf_cashier.
        display
        chr(63) @ F-cashier
        with frame Dialog-Frame.
      end.
    end.
    when 'S':U then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input 'S':U
                                               ,input get-chkc_context.db-num
                                               ,input p-num
                                               ,input p-date
                                               )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_sales-man no-lock where
                      buf_sales-man.obj-type = 'чел':U
                  and buf_sales-man.obj-code = v-psn-code no-error.
        if available buf_sales-man then do:
          display
          buf_sales-man.obj-name @ f-salesman
          with frame Dialog-Frame.
        end.
        else do:
          display
          chr(63) @ F-salesman
          with frame Dialog-Frame.
        end.
        end.
        else do:
          release buf_sales-man.
          display
          chr(63) @ F-salesman
          with frame Dialog-Frame.
        end.
    end.
  END CASE.
end.
END PROCEDURE.
PROCEDURE GET-SUMS :
define variable v-is-petrol-check            as logical                 no-undo .
define variable v-is-inventory as logical no-undo .
DEFINE BUFFER BUF_TT-CHK-GDS FOR TT-CHK-GDS.
DEFINE VARIABLE var-for-src-d-pcnt as decimal no-undo .
assign
tt-chk-doc.tot-doc = 0
tt-chk-doc.discnt = 0
tt-chk-doc.netto = 0
.
if lookup(string(tt-chk-doc.chk-type) , '14,15,16,17,36':U) > 0 then do:
  v-is-petrol-check = yes.
end.
if tt-chk-doc.chk-type = integer('11':U) then do:
  assign
  v-is-inventory = yes.
end.
if not v-is-petrol-check
and not v-is-inventory
then do:
  for each buf_tt-chk-gds no-lock:
    assign
    tt-chk-doc.tot-doc = tt-chk-doc.tot-doc +   (if (tt-chk-doc.chk-type = integer('1':U)
                                                or tt-chk-doc.chk-type = integer('69':U))
                                                and buf_tt-chk-gds.write-off-code > 0 then 0
                                                else buf_tt-chk-gds.price-base * buf_tt-chk-gds.doc-qnty
                                                )
    tt-chk-doc.discnt = tt-chk-doc.discnt + (if buf_tt-chk-gds.write-off-code <> ?
                                           and buf_tt-chk-gds.write-off-code > 0
                                           then 0
                                           else  buf_tt-chk-gds.discnt * buf_tt-chk-gds.doc-qnty)
    tt-chk-doc.netto = tt-chk-doc.tot-doc - tt-chk-doc.discnt
    .
  end.
  assign
  tt-chk-doc.discnt = tt-chk-doc.discnt + (if par-mode = 'ДОБАВЛЕНИЕ':U then tt-chk-doc.real-subdiscnt else 0)
  tt-chk-doc.netto = tt-chk-doc.tot-doc - tt-chk-doc.discnt
  .
  if tt-chk-doc.src-d-pcnt <> 0 and not v-is-sub-d then do:
    assign
    var-for-src-d-pcnt = tt-chk-doc.netto * tt-chk-doc.src-d-pcnt / 100
    tt-chk-doc.netto  = tt-chk-doc.netto - var-for-src-d-pcnt
    tt-chk-doc.discnt = tt-chk-doc.discnt + var-for-src-d-pcnt
    .
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE llb as character no-undo .
DEFINE VARIABLE v-h AS handle NO-UNDO.
ASSIGN
v-h = br-discnt:FIRST-COLUMN IN FRAME Dialog-Frame
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Шаблон скидки" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipt_input_teh':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output actn#log
    )  .
end.
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipt_input_bonus':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output actn#log_bonus
    )  .
end.
if actn#log or par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then do:
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame Dialog-Frame =  'Продажа,1,Возврат,6,ВзврСпис,96,СбросТрнзкц,14,Перелив,15,ПеревТрнзкц,16,РазблТрнзкц,36,ТехПролив,17,Списание,69,Аннуляция,8,Инвентаризация,11,Закрытие_смены,13,Открытие_смены,40,Z-отчет,12,_Продажа,101,_Возврат,106,_ВзврСпис,196,_СбросТрнзкц,114,_Перелив,115,_ПеревТрнзкц,116,_ТехПролив,117,_Списание,169,_Аннуляция,108,_Инвентаризация,111,_Z-отчет,112,_СбросТрнзкц,114,_РазблТрнзкц,136,_Закрытие_смены,113,>Продажа,201,>Возврат,206,>Аннуляция,208,>>Продажа,301,>>Возврат,306,Инкассация,2,Касс_фонд,3,Перевод_опл,4,Расход_кассы,5,Декл_ден_ящ,7,Приход_Корр,43,Расход_Корр,44':U +
                                                      (if par-mode <> 'ДОБАВЛЕНИЕ':U
                                                      then (chr(44) + "Ошибка" + chr(44) + string(0))
                                                      else "":U)
.
end.
else do:
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame Dialog-Frame =  'Продажа,1,Возврат,6':U +
                                                      (if par-mode <> 'ДОБАВЛЕНИЕ':U
                                                      then (chr(44) + "Ошибка" + chr(44) + string(0))
                                                      else "":U)
.
end.
if (par-mode = 'ИЗМЕНЕНИЕ':U
or par-mode = 'ПРОСМОТР':U
or par-mode = "susp-type" )
and lookup(string(tt-chk-doc.chk-type), '8,108,208':U) > 0
and tt-chk-doc.prev-chk-type <> 0
and tt-chk-doc.prev-chk-type <> ?
then do:
    cb-chk-type:LIST-ITEM-PAIRS in frame Dialog-Frame = substitute("Анн.&1", entry (lookup (string(tt-chk-doc.prev-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)) + chr(44) + string(tt-chk-doc.chk-type).
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  cb-chk-type = '1':U.
end.
assign
tt-chk-gds.src-code:resizable IN BROWSE br-gds = YES
tt-gds-info.gds-name:resizable IN BROWSE br-gds = YES
tt-gds-info.prt-name:resizable IN BROWSE br-gds = YES
.
run tax-name in this-procedure ( input  'rdt':U, output llb).
tt-chk-gds.road-tax:label IN browse br-gds =  llb.
ASSIGN
frame Dialog-Frame:title = if par-mode = 'ДОБАВЛЕНИЕ':U
                            then substitute("ЧЕК № &1"
                                      ,tt-chk-doc.doc-code)
                          else (substitute("ЧЕК № &1 Время : &2"
                                       ,tt-chk-doc.doc-code
                                       ,string (tt-chk-doc.chk-time, "HH:MM")) +
                            if (get-chkc_context.cas-shft OR get-chkc_context.T-SHFT <> 0)
                            then substitute(" Смена от &1 N смены &2&3"
                                            ,string(tt-chk-doc.src-shift-date, "99/99/9999")
                                            ,tt-chk-doc.shift-name
                                            , (if integer(tt-chk-doc.shift-name) = tt-chk-doc.shift-num
                                               then '':U
                                               else string(tt-chk-doc.shift-num, "(>9)"))
                                            )
                            else substitute("Дата учета &1", string(tt-chk-doc.shift-date))).
if dflt-cd <> 'NCR-GM':U
and dflt-cd <> 'NCR-AS@R':U
then do:
    assign
    menu-item m_without:sensitive in menu MENU-B-adddiscnt = no
    menu-item m_gds-abs:sensitive in menu MENU-B-adddiscnt = no
    .
end.
if dflt-cd <> 'MAGIA-XML':U
and dflt-cd <> 'IBM-XML':U then do:
    assign
    menu-item m-sales-man:sensitive in menu m-prt = no
    .
end.
if par-l-mask and tt-chk-doc.src-d-card <> "" then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
else v-src-d-card = tt-chk-doc.src-d-card .
  DISPLAY cb-chk-type fhour fmin fsec F-cashier F-salesman f-cli-name
  WITH FRAME Dialog-Frame .
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
          tt-chk-doc.obj-code tt-chk-doc.d-card v-src-d-card tt-chk-doc.pay-desk
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
          tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cash-scale
          tt-chk-doc.cash-rate tt-chk-doc.shift-num tt-chk-doc.shift-name tt-chk-doc.PS
          tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt
          tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.doc-num tt-chk-doc.doc-num2
          tt-chk-doc.src-tot-doc
      WITH FRAME Dialog-Frame.
case PAR-MODE:
  WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    b-func
    cb-chk-type
    B-help
    B-card
    tt-chk-doc.chk-date
    tt-chk-doc.cashier
    fhour
    fmin
    v-doc-osnov
    BUTTON-1
    f-cause-corr
    f-num-corr
    corr-date
    Btn_sht-from
    fsec
    tt-chk-doc.sales-man
    tt-chk-doc.d-card
    v-src-d-card
    b-choose-date
    b-cd tt-chk-doc.chk-num tt-chk-doc.z-number
    tt-chk-doc.doc-num
    tt-chk-doc.doc-num2
    tt-chk-doc.src-d-pcnt
    tt-chk-doc.cash-scale when get-chkc_context.r-b = 'base':U and get-chkc_context.base-code <> 0
    tt-chk-doc.cash-rate when get-chkc_context.r-b = 'base':U and get-chkc_context.base-code <> 0
    tt-chk-doc.src-shift-DATE WHEN (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name WHEN (get-chkc_context.CAS-SHFT AND NOT get-chkc_context.SHiFT-ON)
    B-adddiscnt  b-addbonus B-addgds br-discnt BR-gds BR-pay tt-chk-doc.PS B-addpay tt-chk-doc.doc-num tt-chk-doc.doc-num2
    WITH FRAME Dialog-Frame.
    assign
    tt-chk-gds.b-code:read-only in browse br-gds = yes
    tt-chk-gds.depart-code:read-only in browse br-gds = yes
    tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
    tt-chk-pay.doc-qnty:read-only in browse br-pay = yes
    tt-chk-pay.par-val:read-only in browse br-pay = yes
    tt-chk-pay.doc-qnty:visible in browse br-pay = no
    tt-chk-pay.par-val:visible in browse br-pay = no
    .
    if dflt-cd = 'NCR-GM':U
    or  dflt-cd = 'NCR-AS@R':U
    then do:
      assign
      tt-chk-gds.src-discnt:read-only in browse br-gds = yes
      .
      disable
      tt-chk-doc.src-d-pcnt
      with frame Dialog-Frame.
    end.
    hide
    b-hist
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame Dialog-Frame.
  END.
  WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    B-prev
    B-next
    B-print
    B-help
    b-adddiscnt
    b-addbonus
    b-slip-chk
    br-gds br-discnt br-pay
    b-hist
    b-cf WHEN tt-chk-doc.chk-type = INTEGER('12':U)
    WITH FRAME Dialog-Frame.
    assign
    tt-chk-gds.b-code:read-only in browse br-gds = yes
    tt-chk-gds.src-code:read-only in browse br-gds = yes
    tt-chk-gds.pump:read-only in browse br-gds = yes
    tt-chk-gds.nozzle-code:read-only in browse br-gds = yes
    tt-chk-gds.pl-code:read-only in browse br-gds = yes
    tt-chk-gds.loc1:read-only in browse br-gds = yes
    tt-chk-gds.src-price:read-only in browse br-gds = yes
    tt-chk-gds.src-discnt:read-only in browse br-gds = yes
    tt-chk-gds.src-qnty:read-only in browse br-gds = yes
    tt-chk-gds.road-tax:read-only in browse br-gds = yes
    tt-chk-gds.depart-id:read-only in browse br-gds = yes
    tt-chk-gds.depart-code:read-only in browse br-gds = yes
    tt-chk-pay.pay-code:read-only in browse br-pay = yes
    tt-chk-pay.curr-code:read-only in browse br-pay = yes
    tt-chk-pay.tot-sum:read-only in browse br-pay = yes
    tt-chk-pay.pay-card:read-only in browse br-pay = yes
    tt-chk-pay.cash-rate:read-only in browse br-pay = yes
    tt-chk-pay.src-qnty:read-only in browse br-pay = yes
    tt-chk-pay.src-val:read-only in browse br-pay = yes
    tt-chk-pay.doc-qnty:read-only in browse br-pay = yes
    tt-chk-pay.par-val:read-only in browse br-pay = yes
    tt-chk-discnt.real-value-abs:read-only in browse br-discnt = yes
    tt-chk-discnt.real-value-pcnt:read-only in browse br-discnt = yes
    tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
    b-addgds:label = "Товар"
    Br-gds:POPUP-MENU IN FRAME Dialog-Frame       = ?
    Br-pay:POPUP-MENU IN FRAME Dialog-Frame       = ?
    .
    hide
    b-exit
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame Dialog-Frame.
    if par-mode = 'ПРОСМОТР':U then
    b-quit:label = "&Выход".
  END.
  WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    B-help
    b-hist
    b-cf WHEN tt-chk-doc.chk-type = INTEGER('12':U)
    b-card
    b-func
    v-doc-osnov
    BUTTON-1
    f-cause-corr
    f-num-corr
    corr-date
    tt-chk-doc.src-d-card when (tt-chk-doc.src-d-card = "-0":U
                                and
                                (index(tt-chk-doc.d-card, "*" ) > 0
                                or
                                index(tt-chk-doc.d-card, "!" ) > 0)
                               )
    b-addgds b-adddiscnt b-addbonus
    b-slip-chk
    tt-chk-doc.chk-date  when not get-chkc_context.shift-on
    tt-chk-doc.cashier
    tt-chk-doc.d-card
    tt-chk-doc.z-number
    tt-chk-doc.src-shift-DATE WHEN (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name WHEN (get-chkc_context.CAS-SHFT AND NOT get-chkc_context.SHiFT-ON)
    br-discnt BR-gds BR-pay tt-chk-doc.PS
    tt-chk-doc.d-card when dc-change
    tt-chk-doc.doc-num
    tt-chk-doc.doc-num2
    WITH FRAME Dialog-Frame.
    hide
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame Dialog-Frame .
    assign
    tt-chk-gds.src-code:read-only in browse br-gds = yes
    tt-chk-gds.b-code:read-only in browse br-gds = yes
    tt-chk-gds.pump:read-only in browse br-gds = yes
    tt-chk-gds.src-price:read-only in browse br-gds = yes
    tt-chk-gds.src-discnt:read-only in browse br-gds = yes
    tt-chk-gds.src-qnty:read-only in browse br-gds = yes
    tt-chk-gds.road-tax:read-only in browse br-gds = yes
    tt-chk-gds.depart-id:read-only in browse br-gds = yes
    tt-chk-pay.tot-sum:read-only in browse br-pay = (if tt-chk-doc.chk-type = integer('12':U)
                                                     then no
                                                     else yes)
    tt-chk-pay.pay-card:read-only in browse br-pay = yes
    tt-chk-pay.src-qnty:read-only in browse br-pay = yes
    tt-chk-pay.src-val:read-only in browse br-pay= yes
    tt-chk-discnt.real-value-abs:read-only in browse br-discnt = yes
    tt-chk-discnt.real-value-pcnt:read-only in browse br-discnt = yes
    b-addgds:label = "Товар"
    .
    if dflt-cd = 'NCR-GM':U
    or dflt-cd = 'NCR-AS@R':U
    then do:
      assign
      tt-chk-gds.src-discnt:read-only in browse br-gds = yes
      .
    end.
  END.
end case.
IF par-mode <> 'ДОБАВЛЕНИЕ':U
or not get-chkc_context.is-catering
THEN DO:
    menu-item m-write-off:sensitive in menu M-prt = no.
    menu-item m-modificator:sensitive in menu M-prt = no.
END.
if par-mode <> 'ДОБАВЛЕНИЕ':U
then do:
  menu-item m-sales-man:sensitive in menu m-prt = no.
end.
if not cas-shft then do:
    hide
    tt-chk-doc.src-shift-date
    tt-chk-doc.shift-num
    tt-chk-doc.shift-name
    in frame Dialog-Frame.
end.
if not actn#log_bonus then do:
  disable  tt-chk-doc.d-card v-src-d-card B-card with frame Dialog-Frame .
end.
b-adddiscnt:POPUP-MENU IN FRAME Dialog-Frame = ?.
b-addbonus:POPUP-MENU IN FRAME Dialog-Frame = ?.
VIEW FRAME Dialog-Frame.
CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
hide br-discnt in frame Dialog-Frame.
IF b-cf:SENSITIVE IN FRAME Dialog-Frame = NO THEN HIDE
b-cf IN FRAME Dialog-Frame.
hide BR-corr in frame Dialog-Frame.
hide v-corr-osnov v-corr-type in frame Dialog-Frame.
if tt-chk-doc.chk-type = integer('43':U)
or tt-chk-doc.chk-type = integer('44':U)
then do :
  v-corr-osnov = tt-chk-doc.doc-num .
  if num-entries(tt-chk-doc.doc-num2, ":") = 2
  then do :
    if entry(1, tt-chk-doc.doc-num2, ":") = "0"
    then v-corr-type = "самостоятельно" .
    else
    if entry(1, tt-chk-doc.doc-num2, ":") = "1"
    then v-corr-type = "по предписанию" .
    else
    v-corr-type = "неизвестн." .
  end.
  else
  v-corr-type = "неизвестн." .
  hide BR-gds in frame Dialog-Frame.
  open query br-corr for each tt-chk-gds WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code .
  display BR-corr v-corr-osnov v-corr-type with frame Dialog-Frame.
  enable BR-corr with frame Dialog-Frame.
  hide tt-chk-doc.doc-num2 tt-chk-doc.doc-num in frame Dialog-Frame.
end.
    if par-mode <> "susp-type" then
    do:
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
            and buf_chk-doc-attr.attr-code = "corr-osnov":
            v-corr-osnov1 = integer(buf_chk-doc-attr.attr-value).
            v-doc-osnov = OsnovCorr(v-corr-osnov1) .
        end.
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
            and buf_chk-doc-attr.attr-code = "corr-date":
            corr-date = date(buf_chk-doc-attr.attr-value) .
        end.
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
            and buf_chk-doc-attr.attr-code = "corr-num":
            f-num-corr = buf_chk-doc-attr.attr-value .
        end.
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
            and buf_chk-doc-attr.attr-code = "corr-cause":
            f-cause-corr = buf_chk-doc-attr.attr-value .
        end.
        display
            text-1
            v-doc-osnov
            corr-date
            f-cause-corr
            f-num-corr
            with frame Dialog-Frame .
        hide
            text-4
            button-susp
            v-susp-chk
            v-link-chk
            in frame Dialog-Frame .
    end.
    else
    do:
        for first ub.susp-chk no-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code:
            v-susp-chk = ub.susp-chk.reason-name .
            v-link-chk = ub.susp-chk.link-chk .
        end.
        hide
            text-1
            v-doc-osnov
            corr-date
            f-cause-corr
            f-num-corr
            button-1
            b-choose-date
            in frame Dialog-Frame .
        display text-4 v-susp-chk v-link-chk with frame Dialog-Frame .
        enable
            button-susp
            v-susp-chk
            v-link-chk
            b-exit
            with frame Dialog-Frame .
            v-susp-chk:read-only = true .
    end.
for each tt-gds-info no-lock:
EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(tt-chk-doc.obj-type, tt-chk-doc.obj-code) no-error.
      RUN gds-attr-value (
                          INPUT tt-gds-info.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
      if v-gds-attr-value > ""
      and EDOParSec:GetIsMarkingForType(v-gds-attr-value)
      then do :
      enable
      B_mark
      with frame Dialog-Frame .
      leave .
      end.
end.
END PROCEDURE.
PROCEDURE pays-display :
DEFINE INPUT PARAMETER p-change-curr as logical no-undo.
DEFINE VARIABLE curr-rate                  like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                 like ub.curr-shop.exch-scale  no-undo .
FIND FIRST ub.cash-pay WHERE
          ub.cash-pay.cdpay-code = tt-chk-pay.pay-code AND
          ub.cash-pay.curr-code = tt-chk-pay.curr-code NO-LOCK NO-ERROR.
if NOT available ub.cash-pay
AND tt-chk-doc.chk-type <> INTEGER('12':U) then do:
  assign
  tt-chk-pay.is-error = yes
  .
end.
CASE ABS(tt-chk-pay.curr-code):
  when 0 then do:
    assign
    tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum
    .
    if get-chkc_context.cas-curs then do:
      assign
      tt-chk-pay.tot-base = tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output tt-pay-info.exch-rate
                        ,output tt-pay-info.exch-scale
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time
                        )  no-error.
    end.
    else do:
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output cash-rate_
                        ,output cash-scale_
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time
                        )  no-error.
      assign
      tt-chk-pay.is-error = error-status:error
      tt-chk-pay.tot-base = tt-chk-pay.tot-sum / cash-rate_ * cash-scale_
      tt-pay-info.exch-rate = cash-rate_
      tt-pay-info.exch-scale = cash-scale_
      .
    end.
  end.
  when get-chkc_context.base-code then do:
    assign
    tt-chk-pay.tot-base = tt-chk-pay.tot-sum
    .
    if cas-curs then do:
      assign
      tt-chk-pay.tot-rubl = if get-chkc_context.r-b = 'base':U
                          then tt-chk-pay.tot-sum * tt-chk-doc.cash-rate
                          else tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output tt-pay-info.exch-rate
                        ,output tt-pay-info.exch-scale
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time
                        )  no-error.
    end.
    else do:
            run find-curs in this-procedure
                              (
                               input tt-chk-doc.chk-date
                              ,input tt-chk-doc.chk-time
                              ,input get-chkc_context.base-code
                              ,output cash-rate_
                              ,output cash-scale_
                              ,output exch-date_
                              ,output exch-time_
                              )  no-error.
        assign
        tt-chk-pay.is-error = error-status:error
        tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
        tt-pay-info.exch-rate = cash-rate_
        tt-pay-info.exch-scale = cash-scale_
        .
    end.
  end.
  otherwise do:
    if cas-curs then do:
      assign
      tt-chk-pay.tot-base = if get-chkc_context.r-b = 'base':U
                         then tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
                         else tt-chk-pay.tot-base
                          tt-chk-pay.tot-rubl = if get-chkc_context.r-b = 'base':U
                         then tt-chk-pay.tot-sum / cass-rate * tt-chk-doc.cash-rate
                         else tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      if not get-chkc_context.r-b = 'base':U then do:
                run find-curs in this-procedure
                          (
                           input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input get-chkc_context.base-code
                          ,output cash-rate_
                          ,output cash-scale_
                          ,output exch-date_
                          ,output exch-time_
                          )  no-error.
          assign
          tt-chk-pay.is-error = error-status:error
          tt-chk-pay.tot-base = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
          .
      end.
      run find-curs in this-procedure
                          (
                          input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input tt-chk-pay.curr-code
                          ,output tt-pay-info.exch-rate
                          ,output tt-pay-info.exch-scale
                          ,output tt-pay-info.exch-date
                          ,output tt-pay-info.exch-time
                          )  no-error.
    end.
    else do:
        run find-curs in this-procedure
              (
               input tt-chk-doc.chk-date
              ,input tt-chk-doc.chk-time
              ,input tt-chk-pay.curr-code
              ,output cash-rate_
              ,output cash-scale_
              ,output tt-pay-info.exch-date
              ,output tt-pay-info.exch-time
              )  no-error.
        assign
        tt-chk-pay.is-error = error-status:error
        tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
        tt-pay-info.exch-rate = cash-rate_
        tt-pay-info.exch-scale = cash-scale_
        curr-rate = cash-rate_
        curr-scale = cash-scale_
        .
                    run find-curs in this-procedure
                          (
                           input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input get-chkc_context.base-code
                          ,output cash-rate_
                          ,output cash-scale_
                          ,output exch-date_
                          ,output exch-time_
                          )  no-error.
          assign
          tt-chk-pay.is-error = error-status:error
          tt-chk-pay.tot-base = tt-chk-pay.tot-sum * (curr-rate / curr-scale)  /
                             cash-rate_ * cash-scale_
          .
    end.
  end.
END CASE.
assign
tt-pay-info.calc-rate = tt-chk-pay.tot-rubl / tt-chk-pay.tot-sum
tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss").
.
display
tt-chk-pay.tot-sum
tt-chk-pay.tot-base
tt-chk-pay.tot-rubl
tt-chk-pay.cash-rate
tt-pay-info.calc-rate
tt-pay-info.exch-date
tt-pay-info.exch-time-str
tt-pay-info.exch-rate
tt-pay-info.exch-scale
with browse br-pay.
glog = br-pay:refresh() in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-addbonus :
define variable v-line-num AS integer NO-UNDO.
define variable v-src-d-card AS character NO-UNDO.
define variable v-discnt-type as integer no-undo .
define variable v-discnt-id AS integer NO-UNDO.
define variable v-kateg AS integer NO-UNDO.
define variable v-updated AS LOGICAL NO-UNDO.
define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer buf_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not actn#log_bonus then do:
  message "Отсутствует право: Редактирование бонусов, скидок и ДК в чеках"
  view-as alert-box.
  return.
end.
if v-br-discnt-current-type = 4 then do:
  if available tt-chk-discnt THEN DO:
     RUN proc-leave-discnt-abs in THIS-PROCEDURE ( input integer('2':U)).
  END.
end.
if not br-discnt:visible in frame Dialog-Frame
OR v-br-discnt-current-type = 0
then do:
    ASSIGN
    v-br-discnt-current-type = 4.
    hide br-gds in frame Dialog-Frame.
    display br-discnt with frame Dialog-Frame.
    ASSIGN
    b-addgds:label = "Товары"
    b-adddiscnt:label = "Скидки"
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = YES
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = YES
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = YES
    v-br-discnt-current-type = 4
    .
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
     if par-mode = 'ДОБАВЛЕНИЕ':U then do:
        assign
        b-addbonus:POPUP-MENU IN FRAME Dialog-Frame = menu MENU-b-addbonus:handle
        b-addbonus:MENU-MOUSE = 1
        b-addbonus:label = "Добавить Бoнус"
        b-adddiscnt:popup-menu = ?
        .
    end.
    if par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then do:
      ENABLE
      b-addgds
      b-adddiscnt
      with frame Dialog-Frame.
      DISABLE
      b-addbonus
      with frame Dialog-Frame.
    end.
    return.
end.
if not par-mode = 'ДОБАВЛЕНИЕ':U then return.
if discnt-option = "":U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run str/add-bon.w ( input parparentproc
                 ,input par-mode
                 ,input-output v-line-num
                 ,input-output v-src-d-card
                 ,input-output v-discnt-type
                 ,input-output v-discnt-id
                 ,input-output v-kateg
                 ,output v-updated ) no-error.
 if not v-updated then return error.
  find first buf_tt-chk-discnt no-lock where
            buf_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
        and buf_tt-chk-discnt.record-type = 4
        and buf_tt-chk-discnt.discnt-id = v-discnt-id
        and buf_tt-chk-discnt.line-num = v-line-num
        no-error.
  if available buf_tt-chk-discnt then do:
    message
    "В данном чеке уже есть строка начисления бонуса с таким номером внешней транзакции"
    view-as alert-box error .
    undo, return error.
  end.
end.
if integer(entry(1, discnt-option)) = integer('2':U)
and v-line-num = 0 then do:
  message "Нельзя начислять бонус на подитог сразу после шапки чека"
  view-as alert-box ERROR.
  return error.
end.
find last tt-chk-discnt where
                   tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
          tt-chk-discnt.record-type = 4 no-error.
assign
var-discnt-id = if avail tt-chk-discnt
                      then tt-chk-discnt.discnt-id
                      else 0
.
find first last-tt-chk-gds where
             last-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
             last-tt-chk-gds.line-num = v-line-num no-error.
if not avail last-tt-chk-gds then do:
    message "В чеке нет строчки с номером" v-line-num
    view-as alert-box ERROR.
    return error.
end.
create tt-chk-discnt.
assign
tt-chk-discnt.doc-code = tt-chk-doc.doc-code
tt-chk-discnt.line-num = v-line-num
tt-chk-discnt.record-type = 4
tt-chk-discnt.discnt-id = v-discnt-id
tt-chk-discnt.line-type = integer(entry(1, discnt-option))
tt-chk-discnt.pass-discnt = integer('1':U)
tt-chk-discnt.value-type = integer(entry(2, discnt-option))
tt-chk-discnt.discnt-type = v-discnt-type
tt-chk-discnt.src-d-card = v-src-d-card
tt-chk-discnt.d-card = v-src-d-card
tt-chk-discnt.kateg = v-kateg
tt-chk-discnt.discnt-value-abs = 0
tt-chk-discnt.discnt-value-pcnt  = 0
tt-chk-discnt.object-line-num = tt-chk-discnt.line-num
var-discnt-id = var-discnt-id + 1
.
create locked_chk-discnt.
buffer-copy tt-chk-discnt to locked_chk-discnt.
discnt-option = "":U.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
    find first loc_tt-chk-discnt WHERE
               loc_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND loc_tt-chk-discnt.discnt-id = v-discnt-id
           AND loc_tt-chk-discnt.record-type = 4 NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-discnt then do:
      reposition br-discnt to recid recid(loc_tt-chk-discnt).
    end.
  apply "entry" to br-discnt in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-adddiscnt :
define variable var-line-num as character no-undo.
define variable v-wro-code as integer no-undo .
define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not actn#log_bonus then do:
  message "Отсутствует право: Редактирование бонусов, скидок и ДК в чеках"
  view-as alert-box.
  return.
end.
if v-br-discnt-current-type = 0 then do:
  if available tt-chk-discnt THEN DO:
     RUN proc-leave-discnt-abs in THIS-PROCEDURE (input (if tt-chk-discnt.value-type = integer('2':U)
                                                        then integer('2':U)
                                                        else integer('1':U))).
  END.
end.
if not br-discnt:visible in frame Dialog-Frame
OR v-br-discnt-current-type = 4
then do:
    ASSIGN
    v-br-discnt-current-type = 0.
    hide br-gds in frame Dialog-Frame.
    display br-discnt with frame Dialog-Frame.
    ASSIGN
    b-addgds:label = "Товары"
    b-addbonus:LABEL = "Бонусы"
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = NO
    v-br-discnt-current-type = 0
    .
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
     if par-mode = 'ДОБАВЛЕНИЕ':U then do:
        assign
        b-adddiscnt:POPUP-MENU IN FRAME Dialog-Frame = menu MENU-B-adddiscnt:handle
        b-adddiscnt:MENU-MOUSE = 1
        b-adddiscnt:label = "Добавить скидку"
        b-addbonus:popup-menu = ?
        .
    end.
    if par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then do:
      ENABLE
      b-addgds
      b-addbonus
      with frame Dialog-Frame.
      DISABLE
      b-adddiscnt
      with frame Dialog-Frame.
      b-addbonus:popup-menu = ?.
    end.
    return.
end.
if not par-mode = 'ДОБАВЛЕНИЕ':U then return.
if discnt-option = "":U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if tt-chk-doc.src-d-pcnt <> 0 then do:
  if lookup('2':U, discnt-option) > 0 then do:
    message
    "В данном чеке будут одновременно выставлены:" SKIp
    "% скидка на товары клиента и абсолютная скидка на итог" skip
    "По правилам разбора чека до тех пор, пока в чеке есть абсолютная скидка на итог,"
    "% скидка на товары будет иметь только информационное значение " skip
    "и не будет применяться к товарам чека"
    view-as alert-box WARNING.
  end.
end.
run gbl/d-prompt.w (
    ('title=':u + "Введите номер строки, после которой была начислена скидка" + '\':u
  + 'text1=':u + "Номер строки" + '\':u
  + 'format=' + ">9" + '\':u
  + 'type=int\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=4\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=no\':u)
  ,input-output var-line-num
  ).
if return-value = 'false':u then do:
  return error.
end.
if integer(entry(1, discnt-option)) = integer('2':U)
and integer(var-line-num) = 0 then do:
  message "Нельзя начислять скидку на подитог сразу после шапки чека"
  view-as alert-box ERROR.
  return error.
end.
find last tt-chk-discnt where
                   tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
          tt-chk-discnt.record-type = 0 no-error.
assign
var-discnt-id = if avail tt-chk-discnt
                      then tt-chk-discnt.discnt-id
                      else 0
.
find first last-tt-chk-gds where
             last-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
             last-tt-chk-gds.line-num = integer(var-line-num) no-error.
if not avail last-tt-chk-gds then do:
    message "В чеке нет строчки с номером" var-line-num
    view-as alert-box ERROR.
    return error.
end.
create tt-chk-discnt.
assign
tt-chk-discnt.doc-code = tt-chk-doc.doc-code
tt-chk-discnt.line-num = integer(var-line-num)
tt-chk-discnt.record-type = 0
tt-chk-discnt.discnt-id = var-discnt-id + 1
tt-chk-discnt.line-type = integer(entry(1, discnt-option))
tt-chk-discnt.pass-discnt = integer('1':U)
tt-chk-discnt.value-type = integer(entry(2, discnt-option))
tt-chk-discnt.discnt-type = integer('0':U)
tt-chk-discnt.d-card = "":U
tt-chk-discnt.discnt-value-abs = 0
tt-chk-discnt.discnt-value-pcnt  = 0
tt-chk-discnt.object-line-num = (if tt-chk-discnt.line-type = integer('1':U)
                                 then  tt-chk-discnt.line-num
                                 else 0)
var-discnt-id = var-discnt-id + 1
.
if tt-chk-discnt.line-type = integer('2':U)  then do:
  assign
  v-is-sub-d = yes
  .
end.
create locked_chk-discnt.
buffer-copy tt-chk-discnt to locked_chk-discnt.
discnt-option = "":U.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U OR WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  'ПРОСМОТР':U or when "susp-type" THEN DO:        OPEN QUERY BR-discnt FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
    find first loc_tt-chk-discnt WHERE
               loc_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND loc_tt-chk-discnt.discnt-value-abs = 0
           AND loc_tt-chk-discnt.record-type = 0
    NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-discnt then do:
      reposition br-discnt to recid recid(loc_tt-chk-discnt).
    end.
  apply "entry" to br-discnt in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-addgds :
define variable varrid-list as character no-undo.
define variable ii as integer no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define variable v-wro-code as integer no-undo .
define variable v-mark as character no-undo .
define variable v-ok as logical no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
define buffer lng_chk-gds for ub.chk-gds.
define buffer loc_tt-chk-gds for tt-chk-gds.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.
if not br-gds:visible in frame Dialog-Frame
then do:
    hide br-discnt in frame Dialog-Frame.
    display
    br-gds with frame Dialog-Frame.
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-gds :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    assign
    b-adddiscnt:POPUP-MENU IN FRAME Dialog-Frame = ?
    b-addbonus:POPUP-MENU IN FRAME Dialog-Frame = ?
    b-addgds:label = if par-mode = 'ДОБАВЛЕНИЕ':U then "Добавить товар" else b-addgds:label
    b-adddiscnt:label = "Скидки"
    b-addbonus:LABEL = "Бонусы"
    .
    if par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then do:
      ENABLE
      b-adddiscnt
      b-addbonus
      with frame Dialog-Frame.
      DISABLE
      b-addgds
      with frame Dialog-Frame.
    end.
    CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
    return.
end.
if not par-mode = 'ДОБАВЛЕНИЕ':U then return.
varrid-list = "" .
run ref/gds-ref.p (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input tt-chk-doc.obj-type
                ,input tt-chk-doc.obj-code
                ,input ?
              , output varrid-list ).
if varrid-list = "" then return error.
ii = 1.
FIND LAST lng_chk-gds No-LOCK WHERE
          lng_chk-gds.doc-code = TT-CHK-doc.doc-code
          USE-INDEX ln NO-ERROR.
 if avail lng_chk-gds then lng = lng_chk-gds.line-num.
 else lng = 0.
 _ii:
 DO WHILE (ii <= num-entries(varrid-list) )
 on error undo _ii, next _ii
 :
      FIND FIRST loc_goods WHERE
                 recid( loc_goods ) = integer( entry(ii,varrid-list) ) NO-LOCK .
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
      FIND FIRST loc_bar-code WHERE
                 loc_bar-code.node-code = ub.gds-prt.node-code AND
                loc_bar-code.gds-code = loc_goods.gds-code AND
                loc_bar-code.in-code = "" AND
                loc_bar-code.part-code = ""  AND
                loc_bar-code.unit-cli = loc_goods.unit-base NO-LOCK .
      run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
      if error-status:error then return no-apply.
      assign
      lng = lng + 1
      .
      CASE tt-chk-doc.chk-type:
        when INTEGER('96':U) then do:
          v-wro-code = INTEGER('-9':U).
        end.
        when INTEGER('69':U)  then do:
          v-wro-code = INTEGER('1':U).
        end.
        when INTEGER('17':U)  then do:
          v-wro-code = INTEGER('17':U).
        end.
      END CASE.
      create tt-chk-gds.
      assign
      tt-chk-gds.doc-code = tt-chk-doc.doc-code
      tt-chk-gds.line-num = lng
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.src-price = ( if gp-price-sale <> ? then gp-price-sale else 0)
      tt-chk-gds.src-discnt = 0
      tt-chk-gds.src-qnty = 0
      tt-chk-gds.src-sum = 0
      tt-chk-gds.price-base = 0
      tt-chk-gds.doc-qnty = 0
      tt-chk-gds.discnt = 0
      tt-chk-gds.sum-base = 0
      tt-chk-gds.is-error = no
      tt-chk-gds.b-code = loc_bar-code.b-code
      tt-chk-gds.pass-gds = integer('1':U)
      tt-chk-gds.write-off-code = v-wro-code
      tt-chk-gds.nozzle-code = 0
      tt-chk-gds.src-pl-code = 0
      tt-chk-gds.pl-code = 0
      tt-chk-gds.density = 0
      tt-chk-gds.pump = 0
      tt-chk-gds.loc1 = '':U
      .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output tt-chk-gds.VAT-pc
  ) no-error .
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(tt-chk-doc.obj-type, tt-chk-doc.obj-code).
      RUN gds-attr-value (
                          INPUT loc_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
      if v-gds-attr-value > ""
      and EDOParSec:GetIsMarkingForType(v-gds-attr-value)
      then do :
        run str/enter-mark.w (input loc_goods.gds-code,
                              output v-mark,
                              output v-ok,
                              output v-b-code) .
        if v-ok
        then do :
          find first buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                                      and buf_marking-chk.line-num = tt-chk-gds.line-num
                                                      and buf_marking-chk.mark     = v-mark
                                                      no-error .
          if not available buf_marking-chk
          then do :
            create buf_marking-chk .
            assign
              buf_marking-chk.doc-code = tt-chk-gds.doc-code
              buf_marking-chk.line-num = tt-chk-gds.line-num
              buf_marking-chk.mark     = v-mark
            .
          end .
          assign
            buf_marking-chk.date-modify = today
            buf_marking-chk.time-modify = time
          .
          assign
            tt-chk-gds.src-qnty = 1
            tt-chk-gds.doc-qnty = 1
            tt-chk-gds.b-code = v-b-code
            tt-chk-gds.src-code = string(v-b-code)
          .
          for first ub.marking no-lock where ub.marking.mark = buf_marking-chk.mark :
            assign buf_marking-chk.unit = ub.marking.unit-ext .
            if buf_marking-chk.unit = "LEVEL1"
            then
            assign
              tt-chk-gds.doc-qnty = tt-chk-gds.src-qnty * 10
              tt-chk-gds.src-price  = tt-chk-gds.src-price * 10
              tt-chk-gds.src-sum    = tt-chk-gds.src-sum * 10
              tt-chk-gds.src-discnt = tt-chk-gds.src-discnt * 10
            .
          end .
          enable
          B_mark
          with frame Dialog-Frame .
        end .
        else do :
          delete tt-chk-gds .
          ii = ii + 1 .
          undo _ii, next _ii.
        end .
      end .
      create locked_chk-gds.
      buffer-copy tt-chk-gds to locked_chk-gds.
      create tt-gds-info.
      buffer-copy tt-chk-gds to tt-gds-info
      assign
      tt-gds-info.artic = loc_goods.artic
      tt-gds-info.gds-name = loc_goods.gds-name
      tt-gds-info.prt-name = "-":U
      ii = ii + 1
      varline-rid = recid(tt-chk-gds)
      .
      CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
      REPOSITION Br-gds to recid varline-rid no-error.
      if error-status:error then do:
        undo _ii, next _ii.
      end.
      if get-chkc_context.doc-prt and gds-prt.node-name <> '_Пустая шкала':U then do:
          run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input yes) no-error.
          if error-status:error then do:
            undo _ii, next _ii.
          end.
      end.
    end.
    CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
    find first loc_tt-chk-gds WHERE
               loc_tt-chk-gds.doc-code = tt-chk-doc.doc-code AND
               loc_tt-chk-gds.src-qnty = 0 NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-gds then do:
      reposition br-gds to recid recid(loc_tt-chk-gds).
    end.
apply "entry" to br-gds in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-addpay :
define variable varrid-list as character no-undo.
DEFine VARiable trid as recid no-undo.
define variable base-rate_   as decimal                 no-undo .
define variable base-scale_  like ub.chk-doc.cash-scale no-undo .
define buffer lnp_chk-pay for ub.chk-pay.
define buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
run proc-save-doc in this-procedure No-ERROR.
if error-status:error then return error.
end .
varrid-list = "" .
run ref/cashpays.w (
              input parparentproc
             ,input "b-sel"
             ,input 'все':U
             ,input get-chkc_context.host-code
             ,input locked_chk-doc.obj-type
             ,input locked_chk-doc.obj-code
             ,output varrid-list ) .
if varrid-list = "" then return error.
FIND LAST lnp_chk-pay No-LOCK WHERE
          lnp_chk-pay.doc-code = TT-chk-doc.doc-code
          USE-INDEX ln NO-ERROR.
if avail lnp_chk-pay then lnp = lnp_chk-pay.line-num.
else lnp = 0.
FIND FIRST loc_cash-pay WHERE
                        recid( loc_cash-pay ) = integer( varrid-list ) NO-LOCK .
run find-bank-curs in this-procedure (
                                      input tt-chk-doc.chk-date
                                      ,input loc_cash-pay.curr-code
                                      ,output bank-rate_
                                      ,output bank-scale_
                                      ) no-error.
run find-curs in this-procedure (
                                input tt-chk-doc.chk-date
                                ,input tt-chk-doc.chk-time
                                ,input loc_cash-pay.curr-code
                                ,output cash-rate_
                                ,output cash-scale_
                                ,output exch-date_
                                ,output exch-time_
                                ) no-error.
if get-chkc_context.r-b = 'base':U and
get-chkc_context.base-code <> 0 then do:
  run find-curs in this-procedure (
                                  input tt-chk-doc.chk-date
                                  ,input tt-chk-doc.chk-time
                                  ,input get-chkc_context.base-code
                                  ,output base-rate_
                                  ,output base-scale_
                                  ,output exch-date_
                                  ,output exch-time_
                                  ) no-error.
end.
else do:
  assign
  base-rate_ = 1
  base-scale_ = 1
  .
end.
create tt-chk-pay.
assign
lnp = lnp + 1
tt-chk-pay.doc-code = tt-chk-doc.doc-code
tt-chk-pay.line-num = lnp
tt-chk-pay.chk-date = tt-chk-doc.chk-date
tt-chk-pay.pay-code = loc_cash-pay.cdpay-code
tt-chk-pay.curr-code = loc_cash-pay.curr-code
tt-chk-pay.obj-code = tt-chk-doc.obj-code
tt-chk-pay.obj-type = tt-chk-doc.obj-type
tt-chk-pay.bank-rate = bank-rate_
tt-chk-pay.bank-scale = bank-scale_
tt-chk-pay.cash-rate = cash-rate_ / cash-scale_ * (if get-chkc_context.r-b = 'base':U and get-chkc_context.base-code <> 0 then base-rate_ / base-scale_ else 1)
tt-chk-pay.tot-base = 0
tt-chk-pay.tot-sum = 0
tt-chk-pay.tot-rubl = 0
tt-chk-pay.pay-card = "":U
tt-chk-pay.is-error = no
tt-chk-pay.pass-pay = integer('1':U)
.
create tt-pay-info.
buffer-copy tt-chk-pay to tt-pay-info
assign
tt-pay-info.exch-rate = cash-rate_
tt-pay-info.exch-scale = cash-scale_
tt-pay-info.exch-date = exch-date_
tt-pay-info.exch-time = exch-time_
tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
tt-pay-info.calc-rate = cash-rate_ / cash-scale_
.
CREATE locked_chk-pay .
buffer-copy tt-chk-pay to locked_chk-pay.
  trid = recid(tt-chk-pay).
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U  THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:      OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
REPOSITION br-pay to recid trid NO-ERROR.
glog = BR-pay:SET-REPOSITIONED-ROW(1, "CONDITIONAL") in frame Dialog-Frame.
apply "entry" to br-pay in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-slip :
define input parameter p-slip-type as character no-undo .
  define buffer buf_chk-doc-attr for ub.chk-doc-attr .
  define buffer buf_chk-pay-attr for ub.chk-pay-attr .
  find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
                                        and buf_chk-doc-attr.attr-code = "CheckId"
                                        no-error .
  if not available buf_chk-doc-attr
  or (available buf_chk-doc-attr and trim(buf_chk-doc-attr.attr-value) = "")
  then do :
    message "Слипы не найдены!" view-as alert-box .
    return .
  end .
  if p-slip-type = "chk"
  then do :
    run str/chk-slips.w (input v-cntxt-db-num-obj,
                         input trim(buf_chk-doc-attr.attr-value),
                         input ?)
                        .
  end .
  if p-slip-type = "pay"
  then do :
    find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = tt-chk-doc.doc-code
                                          and buf_chk-pay-attr.attr-code = "RRN"
                                          and buf_chk-pay-attr.line-num = tt-chk-pay.line-num
                                          no-error .
    if not available buf_chk-pay-attr
    or (available buf_chk-pay-attr and trim(buf_chk-pay-attr.attr-value) = "")
    then do :
      find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = tt-chk-doc.doc-code
                                            and buf_chk-pay-attr.attr-code = "CPDOC"
                                            and buf_chk-pay-attr.line-num = tt-chk-pay.line-num
                                            no-error .
      if not available buf_chk-pay-attr
      or (available buf_chk-pay-attr and trim(buf_chk-pay-attr.attr-value) = "")
      then do :
        message "В чеке нет атрибута 'RRN/CPDOC' для поиска слипов по оплате!" view-as alert-box error .
        return .
      end .
    end .
    run str/chk-slips.w (input v-cntxt-db-num-obj,
                         input trim(buf_chk-doc-attr.attr-value),
                         input trim(buf_chk-pay-attr.attr-value))
                        .
  end .
END PROCEDURE.
PROCEDURE proc-chg-gds :
define variable varrid-list as character no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define buffer lng_chk-gds for ub.chk-gds.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.
if not (par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'ДОБАВЛЕНИЕ':U) then return.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run proc-save-doc in this-procedure No-ERROR.
  if error-status:error then return error.
end.
if not available tt-gds-info
then do :
  find first tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num .
end .
varrid-list = "" .
run ref/gds-ref.p (
                input parparentproc
              ,input "b-sel,b-mark"
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input tt-chk-doc.obj-type
              ,input tt-chk-doc.obj-code
              ,input ?
             , output varrid-list ).
if varrid-list <> "" then do:
  ii = 1.
      FIND FIRST loc_goods WHERE
                 recid( loc_goods ) = integer( entry(1,varrid-list) ) NO-LOCK .
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
      FIND FIRST loc_bar-code WHERE
                 loc_bar-code.node-code = ub.gds-prt.node-code AND
                loc_bar-code.gds-code = loc_goods.gds-code AND
                loc_bar-code.in-code = "" AND
                loc_bar-code.part-code = ""  AND
                loc_bar-code.unit-cli = loc_goods.unit-base NO-LOCK .
      run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
      if error-status:error then undo, return error.
      RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
      if error-status:error then undo, return error.
      assign
      tt-chk-gds.doc-code = tt-chk-doc.doc-code
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.is-error = no
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.b-code = loc_bar-code.b-code
      tt-gds-info.artic = loc_goods.artic
      tt-gds-info.gds-code = loc_goods.gds-code
      tt-gds-info.gds-name = loc_goods.gds-name
      tt-gds-info.prt-name = "-":U.
       .
      if get-chkc_context.doc-prt and gds-prt.node-name <> '_Пустая шкала':U then do:
          run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input no).
      end.
    end.
    display
    tt-chk-gds.b-code
    tt-chk-gds.src-code
    tt-gds-info.artic
    tt-gds-info.gds-name
    tt-gds-info.prt-name
    tt-chk-gds.is-error
    with browse br-gds.
  apply "entry" to br-gds in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-chg-pay :
define input parameter p-reference as logical no-undo.
define input parameter p-old-curr-code like ub.chk-pay.curr-code no-undo.
define variable varrid-list as character no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
if not (par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'ДОБАВЛЕНИЕ':U) then return.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  run proc-save-doc in this-procedure No-ERROR.
  if error-status:error then return error.
end .
varrid-list = "" .
if p-reference then do:
    run ref/cashpays.w (
                input parparentproc
              ,input "b-sel"
              ,input 'все':U
              ,input get-chkc_context.host-code
              ,input locked_chk-doc.obj-type
              ,input locked_chk-doc.obj-code
              ,output varrid-list ) .
    if varrid-list = "":U then return error.
    FIND FIRST loc_cash-pay WHERE
                           recid( loc_cash-pay ) = integer( varrid-list ) NO-LOCK .
  assign
    tt-chk-pay.pay-code = loc_cash-pay.cdpay-code
    tt-chk-pay.curr-code = loc_cash-pay.curr-code
    .
end.
    run find-bank-curs in this-procedure (
                                          input tt-chk-doc.chk-date
                                          ,input (if p-reference
                                                  then loc_cash-pay.curr-code
                                                  else tt-chk-pay.curr-code)
                                          ,output bank-rate_
                                          ,output bank-scale_
                                          ) no-error.
    run find-curs in this-procedure (
                                     input tt-chk-doc.chk-date
                                    ,input tt-chk-doc.chk-time
                                    ,input (if p-reference
                                            then loc_cash-pay.curr-code
                                            else tt-chk-pay.curr-code)
                                    ,output cash-rate_
                                    ,output cash-scale_
                                    ,output exch-date_
                                    ,output exch-time_
                                    ) no-error.
    assign
    tt-chk-pay.bank-rate = (if p-old-curr-code <> tt-chk-pay.curr-code
                                          then bank-rate_
                                          else tt-chk-pay.bank-rate)
    tt-chk-pay.bank-scale = (if p-old-curr-code <> tt-chk-pay.curr-code
                                        then bank-scale_
                                        else tt-chk-pay.bank-scale)
    tt-chk-pay.cash-rate = if not get-chkc_context.cas-curs AND p-old-curr-code <> tt-chk-pay.curr-code
                                        then cash-rate_ / cash-scale_
                                       else tt-chk-pay.cash-rate
    tt-chk-pay.is-error = no
    tt-pay-info.calc-rate = cash-rate_ / cash-scale_
    tt-pay-info.exch-rate = cash-rate_
    tt-pay-info.exch-scale = cash-scale_
    tt-pay-info.exch-date = exch-date_
    tt-pay-info.exch-time = exch-time_
    tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
   .
run get-pay-sums in this-procedure ( buffer tt-chk-pay).
display
tt-chk-pay.pay-code
tt-chk-pay.curr-code
tt-chk-pay.is-error
tt-chk-pay.bank-rate
tt-chk-pay.bank-scale
tt-chk-pay.cash-rate
tt-chk-pay.tot-rubl
tt-chk-pay.tot-base
get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
varcurr-name
tt-pay-info.calc-rate
tt-pay-info.exch-rate
tt-pay-info.exch-scale
tt-pay-info.exch-date
tt-pay-info.exch-time-str
with browse br-pay.
apply "entry" to br-pay in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-leave-discnt-abs :
define input parameter p-type as integer no-undo .
DEFINE VARIABLE v-old-discnt-value like ub.chk-discnt.discnt-value-abs  no-undo .
if par-mode = 'ПРОСМОТР':U or par-mode = "susp-type" then return.
IF NOT AVAILABLE TT-CHK-DISCNT THEN RETURN NO-APPLY.
if p-type = integer('2':U) then do:
  assign
  v-old-discnt-value = tt-chk-discnt.discnt-value-abs
  .
end.
else do:
  assign
  v-old-discnt-value = tt-chk-discnt.discnt-value-pcnt
  .
end.
if dflt-cd <> 'NCR-GM':U and
  dflt-cd <> 'NCR-AS@R':U and
  tt-chk-discnt.object-line-num <> 0
  and tt-chk-discnt.record-type = 0
  then do:
  message
  "Нельзя менять значение скидки для скидки по товарной строке"
  view-as alert-box .
  assign
  tt-chk-discnt.real-value-abs:screen-value in browse br-discnt = string(v-old-discnt-value)
  .
  if p-type = integer('2':U) then  do:
    assign
    tt-chk-discnt.real-value-abs:screen-value in browse br-discnt = string(v-old-discnt-value)
    .
  end.
  else do:
    assign
    tt-chk-discnt.real-value-pcnt:screen-value in browse br-discnt = string(v-old-discnt-value)
    .
  end.
end.
else do:
  find first locked_chk-discnt where
        locked_chk-discnt.doc-code = tt-chk-doc.doc-code
    AND locked_chk-discnt.line-num = tt-chk-discnt.line-num
    AND locked_chk-discnt.object-line-num = tt-chk-discnt.object-line-num
    AND locked_chk-discnt.discnt-id = tt-chk-discnt.discnt-id.
  IF LOCKED_chk-discnt.value-type = INTEGER('2':U) or LOCKED_chk-discnt.value-type = INTEGER('5':U)  THEN DO:
      assign
      locked_chk-discnt.discnt-value-abs = decimal(tt-chk-discnt.real-value-abs:screen-value in browse br-discnt    )
      tt-chk-discnt.discnt-value-abs = locked_chk-discnt.discnt-value-abs
      .
  END.
  ELSE DO:
      assign
      locked_chk-discnt.discnt-value-pcnt = decimal(tt-chk-discnt.real-value-pcnt:screen-value in browse br-discnt    )
      tt-chk-discnt.discnt-value-pcnt = locked_chk-discnt.discnt-value-pcnt
      locked_chk-discnt.discnt-value-abs = tt-chk-discnt.discnt-value-pcnt * tt-chk-discnt.object-sum / 100
      tt-chk-discnt.discnt-value-abs = locked_chk-discnt.discnt-value-abs
      .
  END.
  if tt-chk-discnt.record-type < 4 then do:
    run get-discnt in this-procedure(
                                            input tt-chk-discnt.line-num
                                            ,input tt-chk-discnt.value-type
                                          ,input tt-chk-discnt.line-type
                                          ,input tt-chk-discnt.discnt-type
                                            ).
    run get-sums in this-procedure no-error.
    display
    tt-chk-doc.tot-doc
    tt-chk-doc.discnt
    tt-chk-doc.netto
    tt-chk-doc.src-tot-doc
    with frame Dialog-Frame.
  end.
end.
END PROCEDURE.
PROCEDURE add-blocked-marks :
  define buffer buf_marking for ub.marking .
  define buffer lng_chk-gds for chk-gds.
  define buffer loc_tt-chk-gds for tt-chk-gds.
  define buffer loc_bar-code for bar-code.
  define buffer loc_goods for goods.
  define buffer buf_prod-bc for ub.prod-bc .
  define variable v-GTIN as character no-undo .
  define variable v-wro-code as integer no-undo .
  define variable v-mark as character no-undo .
  DEFINE VARIABLE varline-rid as recid  no-undo.
  define variable ii as integer no-undo .
  FIND LAST lng_chk-gds No-LOCK WHERE
            lng_chk-gds.doc-code = TT-CHK-doc.doc-code
            USE-INDEX ln NO-ERROR.
  if avail lng_chk-gds then lng = lng_chk-gds.line-num.
  else lng = 0.
  ii = 0 .
  _ii:
  for each buf_marking no-lock where buf_marking.obj-type = v-cntxt-obj-type
                                 and buf_marking.obj-code = v-cntxt-obj-code
                                 and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                                 :
    FIND FIRST loc_goods WHERE
               loc_goods.gds-code = buf_marking.gds-code NO-LOCK .
    FIND FIRST gds-prt WHERE
               gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
    v-GTIN = getGtinByDM(buf_marking.mark) .
    for each loc_bar-code no-lock WHERE
              loc_bar-code.gds-code = loc_goods.gds-code AND
              loc_bar-code.in-code = "" AND
              loc_bar-code.part-code = "",
    each buf_prod-bc no-lock where buf_prod-bc.b-code = loc_bar-code.b-code
                               and buf_prod-bc.b-str  = v-GTIN :
      leave .
    end .
    if not available loc_bar-code
    then do :
      FIND FIRST loc_bar-code WHERE
               loc_bar-code.node-code = gds-prt.node-code AND
              loc_bar-code.gds-code = loc_goods.gds-code AND
              loc_bar-code.in-code = "" AND
              loc_bar-code.part-code = ""  AND
              loc_bar-code.unit-cli = loc_goods.unit-base no-lock .
    end .
    run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
    if error-status:error then return no-apply.
    assign
    lng = lng + 1
    .
    CASE tt-chk-doc.chk-type:
      when INTEGER('96':U) then do:
        v-wro-code = INTEGER('-9':U).
      end.
      when INTEGER('69':U)  then do:
        v-wro-code = INTEGER('1':U).
      end.
      when INTEGER('17':U)  then do:
        v-wro-code = INTEGER('17':U).
      end.
    END CASE.
    create tt-chk-gds.
    assign
    tt-chk-gds.doc-code = tt-chk-doc.doc-code
    tt-chk-gds.line-num = lng
    tt-chk-gds.src-code = string(loc_bar-code.b-code)
    tt-chk-gds.src-price = ( if gp-price-sale <> ? then gp-price-sale else 0)
    tt-chk-gds.src-discnt = 0
    tt-chk-gds.src-qnty = 0
    tt-chk-gds.src-sum = 0
    tt-chk-gds.price-base = 0
    tt-chk-gds.doc-qnty = 0
    tt-chk-gds.discnt = 0
    tt-chk-gds.sum-base = 0
    tt-chk-gds.is-error = no
    tt-chk-gds.b-code = loc_bar-code.b-code
    tt-chk-gds.pass-gds = integer('1':U)
    tt-chk-gds.write-off-code = v-wro-code
    tt-chk-gds.nozzle-code = 0
    tt-chk-gds.src-pl-code = 0
    tt-chk-gds.pl-code = 0
    tt-chk-gds.density = 0
    tt-chk-gds.pump = 0
    tt-chk-gds.loc1 = '':U
    .
    v-mark = buf_marking.mark .
    find first buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                                and buf_marking-chk.line-num = tt-chk-gds.line-num
                                                and buf_marking-chk.mark     = v-mark
                                                no-error .
    if not available buf_marking-chk
    then do :
      create buf_marking-chk .
      assign
        buf_marking-chk.doc-code = tt-chk-gds.doc-code
        buf_marking-chk.line-num = tt-chk-gds.line-num
        buf_marking-chk.mark     = v-mark
      .
    end .
    assign
      buf_marking-chk.date-modify = today
      buf_marking-chk.time-modify = time
    .
    assign
      tt-chk-gds.src-qnty = 1
      tt-chk-gds.doc-qnty = 1
    .
    assign buf_marking-chk.unit = buf_marking.unit-ext .
    if buf_marking-chk.unit = "LEVEL1"
    then
    assign
      tt-chk-gds.doc-qnty = tt-chk-gds.src-qnty * 10
      tt-chk-gds.src-price  = tt-chk-gds.src-price * 10
      tt-chk-gds.src-sum    = tt-chk-gds.src-sum * 10
      tt-chk-gds.src-discnt = tt-chk-gds.src-discnt * 10
    .
    create locked_chk-gds.
    buffer-copy tt-chk-gds to locked_chk-gds.
    create tt-gds-info.
    buffer-copy tt-chk-gds to tt-gds-info
    assign
    tt-gds-info.artic = loc_goods.artic
    tt-gds-info.gds-name = loc_goods.gds-name
    tt-gds-info.prt-name = "-":U
    ii = ii + 1
    varline-rid = recid(tt-chk-gds)
    .
    CASE par-mode:     WHEN 'ДОБАВЛЕНИЕ':U     OR     WHEN 'ИЗМЕНЕНИЕ':U THEN DO:        IF dflt-cd = 'MAGIA-XML':U THEN OPEN QUERY BR-gds FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY BR-gds FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN 'ПРОСМОТР':U or when "susp-type" THEN DO:            IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
    REPOSITION Br-gds to recid varline-rid no-error.
    if error-status:error then do:
      undo _ii, next _ii.
    end.
    if shop.doc-prt and gds-prt.node-name <> '_Пустая шкала':U then do:
        run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input yes) no-error.
        if error-status:error then do:
          undo _ii, next _ii.
        end.
    end.
  end .
  if ii = 0
  then do :
    message "Нет заблокированных марок на объекте" view-as alert-box .
  end .
  else do :
    message "Добавлены товары по " string(ii) " заблокированным маркам" view-as alert-box .
    enable
    B_mark
    with frame Dialog-Frame .
  end .
END PROCEDURE.
PROCEDURE proc-pcnt-discnt :
define input parameter p-src-d-pcnt like ub.chk-doc.src-d-pcnt no-undo.
if v-is-sub-d then do:
  message
  "В данном чеке будут одновременно выставлены:" SKIp
  "% скидка на товары клиента и абсолютная скидка на итог" skip
  "По правилам разбора чека до тех пор, пока в чеке есть абсолютная скидка на итог,"
  "% скидка на товары будет иметь только информационное значение " skip
  "и не будет применяться к товарам чека"
  view-as alert-box WARNING.
  return.
end.
run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save-doc :
DEFINE VARIABLE var-rid as recid no-undo.
define variable var-chk-type as character no-undo.
DEFINE VARIABLE varline-rid as recid no-undo .
define variable v-is-petrol-check            as logical                 no-undo .
define buffer buf-tt-chk-gds for tt-chk-gds .
define buffer buf-tt-gds-info for tt-gds-info .
define buffer loc-chk-gds for ub.chk-gds.
define buffer buf-tt-chk-pay for tt-chk-pay .
define buffer loc-chk-pay for ub.chk-pay.
define buffer buf-tt-chk-discnt for tt-chk-discnt .
define buffer loc-chk-discnt for ub.chk-discnt.
define buffer buf_c-chk-doc for ub.c-chk-doc.
assign
frame Dialog-Frame fhour
frame Dialog-Frame fmin
frame Dialog-Frame fsec
frame Dialog-Frame cb-chk-type
.
if par-mode = 'ИЗМЕНЕНИЕ':U then
run trg/chk-doch.p (
                 buffer locked_chk-doc
              , input no
              , input no
              , input no
              , input-output v-chip-num
              , output v-is-update).
assign
tt-chk-doc.cashier
tt-chk-doc.chk-date
tt-chk-doc.chk-num
tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec
tt-chk-doc.chk-type = if cb-chk-type = '1':U
                      or
                      cb-chk-type = '6':U
                      or
                      cb-chk-type = '96':U
                      or
                      cb-chk-type = '69':U
                      or
                      cb-chk-type = '14':U
                      or
                      cb-chk-type = '15':U
                      or
                      cb-chk-type = '16':U
                      or
                      cb-chk-type = '17':U
                      or
                      cb-chk-type = '8':U
                      or
                      cb-chk-type = '11':U
                      or
                      cb-chk-type = '12':U
                      or
                      cb-chk-type = '36':U
                      or
                      cb-chk-type = '301':U
                      or
                      cb-chk-type = '306':U
                      or
                      cb-chk-type = '201':U
                      or
                      cb-chk-type = '206':U
                      or
                      cb-chk-type = '208':U
                      then integer(cb-chk-type)
                      else 0
tt-chk-doc.obj-code
tt-chk-doc.pay-desk
tt-chk-doc.ps
tt-chk-doc.src-shift-date
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.d-card
tt-chk-doc.src-d-card
tt-chk-doc.src-d-pcnt
tt-chk-doc.sales-man
tt-chk-doc.cash-rate
tt-chk-doc.cash-scale
tt-chk-doc.z-number
tt-chk-doc.doc-num
tt-chk-doc.doc-num2
.
buffer-copy tt-chk-doc
except
d-pcnt
tot-doc
netto
discnt
sub-discnt
office
correct
cashier-psn-code
salesman-psn-code
out-code
to locked_chk-doc
assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame Dialog-Frame .
for each buf-tt-chk-gds no-lock where
         buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code,
    first loc-chk-gds where
          loc-chk-gds.doc-code = buf-tt-chk-gds.doc-code
     AND  loc-chk-gds.line-num = buf-tt-chk-gds.line-num,
    first buf-tt-gds-info no-lock where
          buf-tt-gds-info.line-num = buf-tt-chk-gds.line-num:
  assign
  loc-chk-gds.src-code = buf-tt-chk-gds.src-code
  loc-chk-gds.b-code = buf-tt-chk-gds.b-code
  loc-chk-gds.src-qnty = buf-tt-chk-gds.src-qnty
  loc-chk-gds.src-price = buf-tt-chk-gds.src-price
  loc-chk-gds.src-discnt = buf-tt-chk-gds.src-discnt
  loc-chk-gds.src-sum = buf-tt-chk-gds.src-sum
  loc-chk-gds.road-tax = buf-tt-chk-gds.road-tax
  loc-chk-gds.pump = buf-tt-chk-gds.pump
  loc-chk-gds.nozzle-code  = buf-tt-chk-gds.nozzle-code
  loc-chk-gds.loc1 = buf-tt-chk-gds.loc1
  loc-chk-gds.pl-code = buf-tt-chk-gds.pl-code
  loc-chk-gds.src-pl-code = buf-tt-chk-gds.src-pl-code
  loc-chk-gds.sales-man = buf-tt-chk-gds.sales-man
  loc-chk-gds.depart-id = (if buf-tt-chk-gds.depart-id = ? then 0 else buf-tt-chk-gds.depart-id )
  loc-chk-gds.depart-code = (if buf-tt-chk-gds.depart-code = ? then 0 else buf-tt-chk-gds.depart-code)
  loc-chk-gds.depart-type = 'маг':U
  loc-chk-gds.doc-qnty = (if par-mode = 'ДОБАВЛЕНИЕ':U then buf-tt-chk-gds.doc-qnty else loc-chk-gds.doc-qnty)
  loc-chk-gds.write-off-code = (if par-mode = 'ДОБАВЛЕНИЕ':U then buf-tt-chk-gds.write-off-code else loc-chk-gds.write-off-code)
  .
END.
for each buf-tt-chk-pay no-lock where
         buf-tt-chk-pay.doc-code = tt-chk-doc.doc-code,
    first loc-chk-pay where
          loc-chk-pay.doc-code = buf-tt-chk-pay.doc-code
     AND  loc-chk-pay.line-num = buf-tt-chk-pay.line-num:
  assign
  loc-chk-pay.pay-code = buf-tt-chk-pay.pay-code
  loc-chk-pay.curr-code = buf-tt-chk-pay.curr-code
  loc-chk-pay.pay-card = buf-tt-chk-pay.pay-card
  loc-chk-pay.cash-rate = buf-tt-chk-pay.cash-rate
  loc-chk-pay.tot-sum = buf-tt-chk-pay.tot-sum
  .
END.
for each buf-tt-chk-discnt no-lock where
         buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
     and buf-tt-chk-discnt.record-type = 4,
    first loc-chk-discnt where
          loc-chk-discnt.doc-code = buf-tt-chk-discnt.doc-code
      and loc-chk-discnt.record-type = buf-tt-chk-discnt.record-type
      AND loc-chk-discnt.line-num = buf-tt-chk-discnt.line-num
      and loc-chk-discnt.object-line-num = buf-tt-chk-discnt.object-line-num
      and loc-chk-discnt.discnt-id = buf-tt-chk-discnt.discnt-id
      :
  buffer-copy buf-tt-chk-discnt to loc-chk-discnt.
  if buf-tt-chk-discnt.line-type = integer('1':U) then do:
    find first loc-chk-gds no-lock where
              loc-chk-gds.doc-code = buf-tt-chk-discnt.doc-code
          and loc-chk-gds.line-num = buf-tt-chk-discnt.object-line-num no-error.
    if not available loc-chk-gds then do:
      delete buf-tt-chk-discnt.
      delete loc-chk-discnt.
    end.
    else do:
    end.
  end.
END.
if lookup(string(tt-chk-doc.chk-type) , '14,15,16,17,36':U) > 0 then do:
  v-is-petrol-check = yes.
end.
if v-is-petrol-check then do:
  assign
  tt-chk-doc.tot-doc = 0
  tt-chk-doc.discnt = 0
  tt-chk-doc.netto = 0
  .
end.
END PROCEDURE.
PROCEDURE reposition-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-chk-doc-recid as recid no-undo .
define buffer buf_chk-doc for ub.chk-doc .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-chk-doc-recid
      ).
    if v-new-chk-doc-recid <> ?
    then do:
      find first buf_chk-doc no-lock
        where recid(buf_chk-doc) = v-new-chk-doc-recid
        no-error .
      if lookup(string(buf_chk-doc.chk-type), '2,3,4,5,7':U) > 0 then do:
      end.
      assign
      p-doc-rec = v-new-chk-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список чеков не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
define buffer buf_goods for ub.goods.
case p-direction :
  when "first":U
  then do:
    get first br-gds.
  end.
  when "last":U
  then do:
    get last br-gds.
  end.
  when "prev":U
  then do:
    get prev br-gds.
    if not available tt-gds-info then do:
      message
      "Это первый товар чека"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next br-gds.
    if not available tt-gds-info then do:
      message
      "Это последний товар чека"
      view-as alert-box.
    end.
  end.
end case .
if available tt-gds-info then do:
  IF tt-gds-info.gds-code = 0 THEN DO:
    MESSAGE
    "Нет товара для данной строки чека!"
    VIEW-AS ALERT-BOX WARNING.
  END.
  ELSE DO:
    find first buf_goods no-lock where
        buf_goods.gds-code = tt-gds-info.gds-code no-error.
    if available tt-gds-info then do:
      assign
      p-recid = recid(buf_goods)
      .
    end.
  END.
end.
run reposition-query-br-gds in this-procedure
  (input recid(tt-chk-gds)
  ).
END PROCEDURE.
PROCEDURE reposition-query-br-gds :
define input parameter p-recid as recid no-undo .
if p-recid <> ?
then do:
  reposition br-gds to recid p-recid no-error.
end.
do with frame Dialog-Frame:
  apply "entry":u to browse BR-corr .
  apply "VALUE-CHANGED":u to browse BR-corr .
end.
END PROCEDURE.
PROCEDURE sel-cd :
define variable ri-list as character no-undo .
define buffer loc_cash-desk  for ub.cash-desk.
run ref/cashlist.w
    (input  parparentproc
    ,input  'b-sel':U
    ,input  'объект':U
    ,input  get-chkc_context.db-num
    ,input  get-chkc_context.host-code
    ,input  'маг':U
    ,input  shop-code
    ,input  ?
    ,output ri-list
    ) no-error.
if ri-list = '' then do:
  undo, return error .
end.
FIND FIRST loc_cash-desk No-LOCK WHERE
          recid(loc_cash-desk) = integer(ri-list) no-error.
if not available loc_cash-desk then do:
  undo, return error .
end.
if loc_cash-desk.autonomy = integer('2':U) then do:
  message
  "Нельзя создать чек для КАССОВОГО МЕНЕДЖЕРА!"
  view-as alert-box error.
  undo, return error .
end.
if loc_cash-desk.pos-type <> dflt-cd then do:
  message
  substitute("На &1&2 установлен тип кассы по умолчанию - &3&4" +
            "Вы уверены, что хотите создать чек для кассы с типом &5?"
            , 'маг':U
            , shop-code
            , dflt-cd
            , chr(10)
            , loc_cash-desk.pos-type)
  view-as alert-box question buttons yes-no update glog.
  if not glog then undo, return error .
end.
find first buf_cash-desk no-lock where
          recid(buf_cash-desk) = recid(loc_cash-desk).
get-chkc_context.pos-type = buf_cash-desk.pos-type.
END PROCEDURE.
PROCEDURE setparts :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter parunit-cli like ub.bar-code.unit-cli no-undo.
define input  parameter parnode-code like ub.bar-code.node-code no-undo.
define variable v-prt-rec as recid no-undo .
DEFine BUFFER loc-goods for ub.goods.
define buffer loc-parts for ub.parts.
define buffer loc-bar-code for ub.bar-code.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  tt-chk-doc.obj-type
    ,input  tt-chk-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then
return ERROR .
run str/parts-l.w
  (input parparentproc
  ,input tt-chk-doc.obj-type
  ,input tt-chk-doc.obj-code
  ,input p-gds-code
  ,input ""
  ,input 'ПРОСМОТР':U
  ,input 'остатки':U
  ,input 'текущий':U
  ,input 'выбор':U
  ,output v-prt-rec
  ) .
if v-prt-rec <> ? then do:
  FIND FIRST loc-parts No-LOCK WHERE recid(loc-parts) = v-prt-rec No-ERROR.
  IF NOT avail loc-parts then return no-apply.
  FIND FIRST loc-goods No-LOCK where
              loc-goods.artic = loc-parts.artic AND
              loc-goods.prod-type = loc-parts.prod-type AND
              loc-goods.prod-code = loc-parts.prod-code No-ERROR.
  FIND FIRST loc-bar-code NO-LOCK WHERE
            loc-bar-code.gds-code = loc-goods.gds-code AND
            loc-bar-code.unit-cli = parunit-cli AND
            loc-bar-code.in-code   = loc-parts.in-code AND
            loc-bar-code.part-code = loc-parts.part-code AND
            loc-bar-code.node-code  = parnode-code NO-ERROR.
  IF AVAIl loc-bar-code then do:
      assign
      tt-chk-gds.b-code = loc-bar-code.b-code
      tt-chk-gds.src-code = (if par-mode = 'ИЗМЕНЕНИЕ':U
                             then tt-chk-gds.src-code else
                             string(loc-bar-code.b-code))
      .
      DISPLAY
      tt-chk-gds.b-code
      tt-chk-gds.src-code
      tt-chk-gds.is-error
      with browse br-gds.
  end.
  else do:
    return error.
  end.
end.
END PROCEDURE.
PROCEDURE setprts :
DEF INPUT PARAMETER rcg as recid no-undo.
DEF INPUT PARAMETER rcb as recid no-undo.
DEF INPUT PARAMETER p-goods-prt-root like ub.goods.prt-root no-undo.
DEF INPUT PARAMETER ff as logical no-undo.
DEFINE VARIABLE varline-rid as recid no-undo.
DEFINE buffer loc_bar-code for ub.bar-code.
DEFINE buffer root_bar-code for ub.bar-code.
define buffer loc_gds-prt for ub.gds-prt.
    define buffer buf_goods  for ub.goods .
    find first buf_goods no-lock
      where recid(buf_goods) = rcg
      .
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input parparentproc
      ,input  buf_goods.gds-code
      ,input  'выбор':U
      ,input  tt-chk-doc.obj-type
      ,input  tt-chk-doc.obj-code
      ,input  ""
      ,input  ""
      ,output v-sel-node-code
      ) .
    if v-sel-node-code <> ? then do:
        FIND FIRST loc_gds-prt No-LOCK
          WHERE loc_gds-prt.node-code = v-sel-node-code
          No-ERROR.
        IF NOT avail loc_gds-prt then return error.
        if NOT loc_gds-prt.is-term then do:
          message
          "Признак" loc_gds-prt.f-name "нетерминальный" skip
          view-as alert-box Warning.
        end.
        FIND FIRST loc_bar-code No-LOCK WHERE
                   recid(loc_bar-code) = rcb No-ERROR.
        FIND FIRST root_bar-code No-LOCK WHERE
                    root_bar-code.gds-code = loc_bar-code.gds-code AND
                    root_bar-code.unit-cli = loc_bar-code.unit-cli AND
                    root_bar-code.in-code   = "" AND
                    root_bar-code.part-code = "" AND
                    root_bar-code.node-code  = loc_gds-prt.node-code NO-ERROR.
        IF AVAIl root_bar-code then do:
          assign
          tt-chk-gds.src-code = (if par-mode = 'ИЗМЕНЕНИЕ':U
                                 then tt-chk-gds.src-code
                                 else string(root_bar-code.b-code))
          tt-chk-gds.b-code = root_bar-code.b-code.
          DISPLAY
          tt-chk-gds.b-code
          tt-chk-gds.src-code
          tt-chk-gds.is-error
          with browse br-gds.
          run get-price1 in this-procedure ( input loc_bar-code.gds-code, input root_bar-code.node-code) No-ERROR.
          if error-status:error then undo, return error.
          RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
          if error-status:error then undo, return error.
          if gp-price-sale <> ? then do:
            if ff then do:
              assign
              tt-chk-gds.src-price = gp-price-sale
              .
              DISPLAY
              tt-chk-gds.src-price
              with browse br-gds.
            end.
          end.
          assign
          tt-gds-info.prt-name = ( if loc_gds-prt.node-name = '_Пустая шкала':U
                                  then "-":U
                                  else ( if loc_gds-prt.upper-code = p-goods-prt-root
                                          then "-------------------":U
                                          else loc_gds-prt.f-name ) )
          .
          display
            tt-gds-info.prt-name
            tt-chk-gds.is-error
            with browse br-gds.
        end.
        else do:
          message
            "Отсутствует бар-код для признака" loc_gds-prt.f-name
            view-as alert-box WARNING.
          return.
        end.
    end.
END PROCEDURE.
PROCEDURE write-log-and-file :
define input parameter p-tab-position   as integer      no-undo.
DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
message
p-log-string
view-as alert-box error .
END PROCEDURE.
FUNCTION get-good RETURNS CHARACTER
  (
    input  parb-code as integer
  , output pargds-code AS integer
  , output pargds-name as character
  , output parprt-name as character
  , output paris-error as logical) :
define variable var-artic like ub.goods.artic No-undo.
run get-good-proc in this-procedure (
input parb-code
,output pargds-code
,output pargds-name
,output parprt-name
,output paris-error
,output var-artic) no-error.
RETURN var-artic.
END FUNCTION.
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
define variable varpay-name like ub.cash-pay.obj-name no-undo.
run get-pay-proc in this-procedure (
input  parpay-code
,input  parcurr-code
,output parcurr-name
,output varpay-name ) no-error.
RETURN varpay-name.
END FUNCTION.
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer) :
define variable v-psn-code like ub.clients.obj-code No-undo.
define buffer buf_clients for ub.clients.
if p-salesman = 0
or p-salesman = ? then DO:
  P-PSN-CODE = 0.
  return '':U.
END.
assign
v-psn-code = gbclcode-is-this-db-role  ( input 'S':U
                                          ,input get-chkc_context.db-num
                                          ,input p-salesman - (if dflt-cd = 'MAGIA-XML':U
                                                              then 10000
                                                              else 0)
                                          ,input p-date
                                                              )
no-error .
if v-psn-code = ? then do:
  p-psn-code = 0.
  return chr(63).
end.
else do:
  assign
  p-psn-code = v-psn-code
  .
  find first buf_clients no-lock where
            buf_clients.obj-type = 'чел':U
        AND buf_clients.obj-code = p-psn-code no-error .
  if not available buf_clients then return chr(63).
  return buf_Clients.obj-name.
end.
END FUNCTION.
FUNCTION get-templ-rl-name RETURNS CHARACTER
  ( INPUT p-templ-rl-root AS INTEGER ) :
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
if p-templ-rl-root = 0 then return "".
FIND FIRST buf_dis-rule NO-LOCK WHERE buf_dis-rule.rule-num = p-templ-rl-root NO-ERROR.
IF AVAILABLE buf_dis-rule THEN RETURN buf_dis-rule.des.
RETURN "!!!Неизвестный шаблон скидки".
END FUNCTION.
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.
END FUNCTION.
