DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_cashier FOR ub.clients.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_sales-man FOR ub.clients.
DEFINE BUFFER cashier FOR ub.person.
DEFINE BUFFER gds_bar-code FOR ub.bar-code.
DEFINE BUFFER gds_goods FOR ub.goods.
DEFINE BUFFER gds_parts FOR ub.parts.
DEFINE BUFFER gds_prod-bc FOR ub.prod-bc.
DEFINE BUFFER locked_c-chk-discnt FOR ub.c-chk-discnt.
DEFINE BUFFER locked_c-chk-doc FOR ub.c-chk-doc.
DEFINE BUFFER locked_c-chk-doc-attr FOR ub.c-chk-doc-attr.
DEFINE BUFFER locked_c-chk-gds FOR ub.c-chk-gds.
DEFINE BUFFER locked_c-chk-pay FOR ub.c-chk-pay.
DEFINE BUFFER pay_cash-pay FOR ub.cash-pay.
DEFINE BUFFER pay_currency FOR ub.currency.
DEFINE BUFFER sales-man FOR ub.person.
DEFINE NEW SHARED TEMP-TABLE tt-chk-discnt NO-UNDO LIKE ub.chk-discnt.
DEFINE BUFFER buf_chk-doc-attr FOR ub.chk-doc-attr .
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE ub.chk-doc
       field real-subdiscnt as decimal.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE ub.chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-gds NO-UNDO LIKE ub.chk-gds.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE ub.chk-pay.
define input parameter parParentProc as Widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-doc-rec as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
return round-m-sum.
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE var-mode as character no-undo.
DEFINE VARIABLE ch-bc-ck as logical no-undo init no.
DEFINE VARIABLE is-prt as logical no-undo init no.
define variable hnum as logical no-undo init no.
define variable ibmgroup as logical no-undo init yes.
define variable L as int no-undo initial 0.
define variable v-is-top as logical no-undo .
define variable v-is-catering as logical no-undo .
define variable v-src-d-card  like ub.chk-doc.src-d-card no-undo .
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
DEFINE VARIABLE new-opened as logical no-undo init yes.
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
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
define variable p-view-log as logical no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE NEW SHARED TEMp-TABLE tt-gds-info no-undo
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
line-num
.
DEFINE NEW SHARED TEMp-TABLE tt-pay-info no-undo
FIELD line-num like ub.chk-pay.line-num
field calc-rate like ub.curr-shop.exch-rate
field exch-date like ub.curr-shop.exch-date
field exch-time like ub.curr-shop.exch-time
field exch-time-str as character
field exch-rate like ub.curr-shop.exch-rate
field exch-scale like ub.curr-shop.exch-scale
index pi is unique PRIMARY
line-num
.
DEFINE VARIABLE v-br-discnt-current-type AS INTEGER NO-UNDO.
FUNCTION get-good RETURNS CHARACTER
  ( input  parb-code as integer, output pargds-name as character, output parprt-name as character, output paris-error as logical)  FORWARD.
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer)  FORWARD.
DEFINE BUTTON B-bonus
     LABEL "Бонусы"
     SIZE 14 BY 1.
DEFINE BUTTON B-discnt
     LABEL "Скидки"
     SIZE 14 BY 1.
DEFINE BUTTON B-gds
     LABEL "Товары"
     SIZE 15 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 27 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-cashier AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.63 BY .67 NO-UNDO.
DEFINE VARIABLE f-cause-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Описание корректировки"
     VIEW-AS FILL-IN
     SIZE 64 BY 1 TOOLTIP "Краткое описание причины проведения корректировки" NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Клиент"
      VIEW-AS TEXT
     SIZE 20.63 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE F-salesman AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.63 BY .67 NO-UNDO.
DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.
DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.
DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.
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
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 100.5 BY 3.5 TOOLTIP "Основание корректировки".
DEFINE QUERY BR-discnt FOR
      tt-chk-discnt SCROLLING.
DEFINE QUERY BR-gds FOR
      tt-chk-gds,
      tt-gds-info SCROLLING.
DEFINE QUERY BR-pay FOR
      tt-chk-pay,
      tt-pay-info SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-chk-doc SCROLLING.
DEFINE BROWSE BR-discnt
  QUERY BR-discnt SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-discnt.line-num COLUMN-LABEL "N строки!начисления"
      entry (lookup (string(tt-chk-discnt.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) COLUMN-LABEL "Тип знач"
tt-chk-discnt.object-line-num COLUMN-LABEL "N строки товара!-объекта"
entry (lookup (string(tt-chk-discnt.line-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) COLUMN-LABEL "Объект скидки/бонуса" FORMAT "X(20)"
(IF tt-chk-discnt.record-type < 4
       THEN entry (lookup (string(tt-chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)
       ELSE STRING(tt-chk-discnt.discnt-type)) COLUMN-LABEL "Тип скидки/!код схемы" FORMAT "X(20)"
tt-chk-discnt.discnt-value-abs COLUMN-LABEL "Знач. скидки/!бонуса"
tt-chk-discnt.src-d-card COLUMN-LABEL "№ Карты!для начисления"
tt-chk-discnt.discnt-id COLUMN-LABEL "ID транзакц" FORMAT ">>>>>>>>9"
tt-chk-discnt.kateg COLUMN-LABEL "Код !валюты" FORMAT "->>>9"
  ENABLE
  tt-chk-discnt.discnt-value-abs
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.67.
DEFINE BROWSE BR-gds
  QUERY BR-gds SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.src-code COLUMN-LABEL "Исходный код" format "X(19)" width 14
      tt-chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      tt-chk-gds.b-code
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
      tt-chk-gds.loc1 COLUMN-LABEL  "Рез." FORMAT ">>9"
      entry (lookup (STRING(if tt-chk-gds.write-off-code = ? then 0 else tt-chk-gds.write-off-code),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U) COLUMN-LABEL "Код спис" FORMAT "X(20)"
      tt-chk-gds.depart-id COLUMN-LABEL "Объект!кухни!в чеке"
      tt-chk-gds.depart-code COLUMN-LABEL "Объект!кухни!в БД"
      tt-chk-gds.sales-man COLUMN-LABEL "Код!продавца"
      tt-gds-info.salesman-name COLUMN-LABEL "Продавец" FORMAT "X(16)"
      tt-chk-gds.road-tax COLUMN-LABEL "Дор. налог/! или тара"
      tt-chk-gds.price-service COLUMN-LABEL "Цена сервиса"
  ENABLE
      tt-chk-gds.src-code
      tt-chk-gds.b-code
      tt-chk-gds.doc-qnty
      tt-chk-gds.pump
      tt-chk-gds.nozzle-code
      tt-chk-gds.loc1
      tt-chk-gds.depart-id
      tt-chk-gds.depart-code
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt
      tt-chk-gds.road-tax
      tt-chk-gds.price-service
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.67 ROW-HEIGHT-CHARS .67.
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
      tt-chk-pay.pay-card COLUMN-LABEL "Номер платежной!карты"
      tt-pay-info.calc-rate COLUMN-LABEL "Рассчит.курс!вал.пл-жа в БД"
      tt-pay-info.exch-date COLUMN-LABEL "Дата курса!маг-на" format "99/99/9999"
      tt-pay-info.exch-time-str COLUMN-LABEL "Время курса!маг-на" format "X(8)"
      tt-pay-info.exch-rate COLUMn-LABEL "Курс маг-на!вал.пл-жа"
      tt-pay-info.exch-scale COLUMn-LABEL "Масштаб маг-на!вал. пл-жа"
      tt-chk-pay.cash-rate COLUMN-LABEL "Курс вал. пл-жа!/к б.в.кассы"
      tt-chk-pay.bank-rate
      tt-chk-pay.bank-scale
  ENABLE
      tt-chk-pay.pay-code
      tt-chk-pay.curr-code
      tt-chk-pay.tot-sum
      tt-chk-pay.pay-card
      tt-chk-pay.cash-rate
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101 BY 4.21 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 23
     B-next AT ROW 1 COL 27
     Cb-chk-type AT ROW 1 COL 39 COLON-ALIGNED NO-LABEL
     B-help AT ROW 1 COL 95
     tt-chk-doc.chk-date AT ROW 2.08 COL 11.5 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-chk-doc.cashier AT ROW 2.08 COL 33.63 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     fhour AT ROW 3.33 COL 11.5 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.33 COL 14.88 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.33 COL 19 COLON-ALIGNED NO-LABEL
     tt-chk-doc.sales-man AT ROW 3.33 COL 33.63 COLON-ALIGNED
          LABEL "Продавец"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.obj-code AT ROW 4.46 COL 11.5 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tt-chk-doc.d-card AT ROW 4.46 COL 33.63 COLON-ALIGNED
          LABEL "Диск. карта"
          VIEW-AS FILL-IN
          SIZE 20.88 BY 1
     tt-chk-doc.pay-desk AT ROW 5.58 COL 11.5 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     v-corr-osnov AT ROW 6.75 COL 11.5 COLON-ALIGNED WIDGET-ID 58
     v-corr-type AT ROW 6.75 COL 80.13 COLON-ALIGNED WIDGET-ID 60
     v-doc-osnov AT ROW 8.75 COL 11.5 COLON-ALIGNED WIDGET-ID 56
     corr-date AT ROW 8.75 COL 55.13 COLON-ALIGNED WIDGET-ID 24
     f-num-corr AT ROW 8.75 COL 100.13 RIGHT-ALIGNED WIDGET-ID 30
     f-cause-corr AT ROW 10.25 COL 100.13 RIGHT-ALIGNED WIDGET-ID 32
     tt-chk-doc.chk-num AT ROW 11.5 COL 11.5 COLON-ALIGNED
          LABEL "N по кассе" FORMAT "->>>>>>9"
          VIEW-AS FILL-IN
          SIZE 8.38 BY 1
     tt-chk-doc.z-number AT ROW 11.5 COL 34.75 COLON-ALIGNED
          LABEL "Z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     tt-chk-doc.src-d-pcnt AT ROW 11.5 COL 63.63 COLON-ALIGNED
          LABEL "Скидка клиен.(%)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.src-shift-date AT ROW 12.67 COL 11.25 COLON-ALIGNED
          LABEL "&Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 12.75 BY 1
     tt-chk-doc.cash-rate AT ROW 12.67 COL 63.5 COLON-ALIGNED
          LABEL "Курс нац вал."
          VIEW-AS FILL-IN
          SIZE 19.88 BY 1
     tt-chk-doc.cash-scale AT ROW 12.67 COL 93.13 COLON-ALIGNED
          LABEL "Масштаб"
          VIEW-AS FILL-IN
          SIZE 6.88 BY 1
     tt-chk-doc.shift-name AT ROW 13.75 COL 11.25 COLON-ALIGNED
          LABEL "№ смены"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-chk-doc.shift-num AT ROW 13.75 COL 20 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4.13 BY 1
     tt-chk-doc.src-d-card AT ROW 13.75 COL 36.25 COLON-ALIGNED
          LABEL "ДК в чеке"
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     B-bonus AT ROW 13.75 COL 59.38
     B-discnt AT ROW 13.75 COL 73.38
     B-gds AT ROW 13.75 COL 87.38
     BR-discnt AT ROW 14.75 COL 1
     BR-gds AT ROW 14.83 COL 1
     BR-pay AT ROW 21.54 COL 1
     tt-chk-doc.PS AT ROW 25.79 COL 1.25 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 100.75 BY 2
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     F-cashier AT ROW 2 COL 42 COLON-ALIGNED NO-LABEL
     tt-chk-doc.tot-doc AT ROW 2.08 COL 76.5 COLON-ALIGNED
          LABEL "Сумма брутто"
           VIEW-AS TEXT
          SIZE 20 BY 1
     F-salesman AT ROW 3 COL 42 COLON-ALIGNED NO-LABEL
     tt-chk-doc.discnt AT ROW 3.33 COL 76.5 COLON-ALIGNED
          LABEL "Скидка общ."
           VIEW-AS TEXT
          SIZE 20 BY 1
     tt-chk-doc.sub-discnt AT ROW 4.46 COL 76.5 COLON-ALIGNED
          LABEL "Сумма списаний"
           VIEW-AS TEXT
          SIZE 20 BY 1
     f-cli-name AT ROW 5.58 COL 33.75 COLON-ALIGNED
     tt-chk-doc.netto AT ROW 5.58 COL 76.5 COLON-ALIGNED
          LABEL "Сумма оплат(нетто)"
           VIEW-AS TEXT
          SIZE 20 BY 1
     tt-chk-doc.d-pcnt AT ROW 11.5 COL 93.25 COLON-ALIGNED
          LABEL "Скидка итоговая(%)"
           VIEW-AS TEXT
          SIZE 6.25 BY 1
     tt-chk-doc.shift-date AT ROW 12.67 COL 36.25 COLON-ALIGNED
          LABEL "Дата учета" FORMAT "99/99/9999"
           VIEW-AS TEXT
          SIZE 10.5 BY 1
          FGCOLOR 12
     "Основание корректировки" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 7.83 COL 41.13 WIDGET-ID 28
     "Время:" VIEW-AS TEXT
          SIZE 6.5 BY 1 AT ROW 3 COL 11 RIGHT-ALIGNED
     "Тип чека" VIEW-AS TEXT
          SIZE 8.63 BY 1.04 AT ROW 1 COL 31
          FGCOLOR 4
     RECT-1 AT ROW 8 COL 1.63 WIDGET-ID 26
     SPACE(0.74) SKIP(16.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
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
ON CHOOSE OF B-bonus IN FRAME Dialog-Frame
DO:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-bonus in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-discnt IN FRAME Dialog-Frame
DO:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-discnt in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-gds IN FRAME Dialog-Frame
DO:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-gds in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run reposition-c-chk-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run reposition-c-chk-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  p-next-prev = "quit":U.
END.
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
DO:
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
    if not ub.shop.is-catering then do:
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
  tt-chk-doc.chk-type = integer(CB-chk-type)
  locked_c-chk-doc.chk-type = integer(CB-chk-type).
  case CB-chk-type:
    when '96':U
    or when '69':U
    then do:
      ASSIGN
      b-discnt:SENSITIVE IN FRAME Dialog-Frame = YES
      .
    end.
    WHEN  '14':U
    OR
    WHEN  '16':U
    OR
    WHEN  '15':U
    OR
    WHEN  '17':U
    OR
    WHEN  '36':U THEN DO:
         assign
         b-discnt:SENSITIVE IN FRAME Dialog-Frame = NO
         .
    end.
    otherwise do:
        if v-is-catering then
        ASSIGN
        b-discnt:SENSITIVE IN FRAME Dialog-Frame = YES
        .
    END.
  END CASE.
END.
ON LEAVE OF corr-date IN FRAME Dialog-Frame
DO:
  assign corr-date.
END.
ON LEAVE OF f-cause-corr IN FRAME Dialog-Frame
DO:
  assign f-cause-corr.
END.
ON LEAVE OF f-num-corr IN FRAME Dialog-Frame
DO:
  assign f-num-corr.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
                  , input ?
                  , input buf_bar-code.gds-code
                  , input 'ПРОСМОТР':U) no-error .
if error-status:error then return no-apply.
apply "entry" to br-gds in frame Dialog-Frame.
return no-apply.
end.
ON value-changed OF br-gds do:
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
end.
var-mode = par-mode.
p-next-prev = ''.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-obj-type <> 'маг':U then DO:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова p-obj-type" p-obj-type
      view-as alert-box ERROR.
      return error.
  end.
  if not par-mode = 'ПРОСМОТР':U then
  p-next-prev = "QUIT".
  FIND FIRST locked_c-chk-doc NO-LOCK WHERE
              recid(locked_c-chk-doc) = p-doc-rec.
  assign
  shop-type = locked_c-chk-doc.obj-type
  shop-code = locked_c-chk-doc.obj-code
  .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUn get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  RUn fill-tables in this-procedure no-error.
  if error-status:error then return error.
  run Myenable in this-procedure .
  br-gds:num-locked-columns = 4.
  if new-opened then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-gds as INT EXTENT 29 no-undo.
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
       IF  par-mode = 'ПРОСМОТР':U and not v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29'))] , 1).
   END.
       END.
       IF  par-mode = 'ПРОСМОТР':U and v-is-top THEN DO:
   DO jjbr-gds = NUM-ENTRIES('1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29') TO 1 BY -1:
     RUN re-move-clmnbr-gds ( cur-clmn-numbr-gds[INTEGER(ENTRY (jjbr-gds, '1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds ( 1, 29).
END.
ON ctrl-cursor-left OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds (29, 1).
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
.
    new-opened = no.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
run disable_UI in this-procedure .
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
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY Cb-chk-type fhour fmin fsec v-corr-osnov v-corr-type v-doc-osnov
          corr-date f-num-corr f-cause-corr F-cashier F-salesman f-cli-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
          tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
          tt-chk-doc.src-shift-date tt-chk-doc.cash-scale tt-chk-doc.cash-rate
          tt-chk-doc.shift-name tt-chk-doc.shift-num v-src-d-card
          tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt
          tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt
          tt-chk-doc.shift-date
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-prev B-next Cb-chk-type B-help RECT-1 tt-chk-doc.chk-date
         tt-chk-doc.cashier fhour fmin fsec tt-chk-doc.sales-man
         tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk v-corr-osnov
         v-corr-type v-doc-osnov corr-date f-num-corr f-cause-corr
         tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
         tt-chk-doc.src-shift-date tt-chk-doc.cash-rate tt-chk-doc.cash-scale
         tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.src-d-card
         B-bonus B-discnt B-gds BR-discnt BR-gds BR-pay tt-chk-doc.PS F-cashier
         tt-chk-doc.tot-doc F-salesman tt-chk-doc.discnt tt-chk-doc.sub-discnt
         f-cli-name tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.shift-date
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.
END PROCEDURE.
PROCEDURE fill-tables :
define variable v-cashier-code as integer no-undo .
define variable v-seller-code as integer no-undo .
define variable v-cashier-psn-code as integer no-undo .
define variable v-seller-psn-code as integer no-undo .
define variable v-updated as logical no-undo .
define buffer no_buffer_chk-doc for ub.chk-doc.
DEFINE VARIABLE var-is-error as logical no-undo .
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
  FIND FIRST locked_c-chk-doc NO-LOCK WHERE
              recid(locked_c-chk-doc) = p-doc-rec.
IF NOT AVAIL locked_c-chk-doc then
return error.
create tt-chk-doc.
buffer-copy locked_c-chk-doc to tt-chk-doc.
  FIND FIRST buf_obj No-LOCK WHERe
              buf_obj.obj-type = tt-chk-doc.obj-type AND
              buf_obj.obj-code = tt-chk-doc.obj-code No-ERROR.
  if not avail buf_obj then do:
    message "Чек" locked_c-chk-doc.doc-code  skip
            "Неверный объект" locked_c-chk-doc.obj-type locked_c-chk-doc.obj-code
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
for each locked_c-chk-gds no-lock where
          locked_c-chk-gds.doc-code = tt-chk-doc.doc-code
       and locked_c-chk-gds.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-gds.
      buffer-copy locked_c-chk-gds to tt-chk-gds.
      create tt-gds-info.
      buffer-copy locked_c-chk-gds to tt-gds-info
      assign
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code, output tt-gds-info.gds-name, output tt-gds-info.prt-name, output var-is-error)
      tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
      tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
      tt-gds-info.src-sum-netto = (tt-chk-gds.src-price - tt-chk-gds.src-discnt) * tt-chk-gds.src-qnty
      tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
      tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
      tt-gds-info.sum-netto = (tt-chk-gds.price-base - tt-chk-gds.discnt) * tt-chk-gds.doc-qnty
      tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
      tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
      .
      tt-gds-info.salesman-name = get-salesman(input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code).
      assign
      v-is-top = locked_c-chk-gds.pump > 0
      tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
      .
  end.
  for each locked_c-chk-pay no-lock where
            locked_c-chk-pay.doc-code = tt-chk-doc.doc-code
        and locked_c-chk-pay.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-pay.
      buffer-copy locked_c-chk-pay to tt-chk-pay
      .
      assign tt-chk-pay.pay-card = f-paycardv(tt-chk-pay.pay-card, tt-chk-pay.pay-code, tt-chk-pay.curr-code)
      .
      create tt-pay-info.
      buffer-copy locked_c-chk-pay to tt-pay-info
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
for each locked_c-chk-doc-attr no-lock where
         locked_c-chk-doc-attr.doc-code = tt-chk-doc.doc-code
     and locked_c-chk-doc-attr.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-doc-attr.
      buffer-copy locked_c-chk-doc-attr to tt-chk-doc-attr.
end.
for each locked_c-chk-discnt no-lock where
         locked_c-chk-discnt.doc-code = tt-chk-doc.doc-code
     AND (locked_c-chk-discnt.record-type = 0
         or
         locked_c-chk-discnt.record-type = 4)
     and locked_c-chk-discnt.chip-num = locked_c-chk-doc.chip-num :
      if locked_c-chk-discnt.line-num = 0
        AND locked_c-chk-discnt.line-type = integer('4':U) then NEXT.
      create tt-chk-discnt.
      buffer-copy locked_c-chk-discnt to tt-chk-discnt.
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
tt-chk-doc.shift-date = if get-chkc_context.t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
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
    run get-price1 in this-procedure (buf_goods.gds-code, bar-code.node-code) No-ERROR.
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
    units-rate = tt-chk-gds.doc-qnty / tt-chk-gds.src-qnty
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code, output tt-gds-info.gds-name, output tt-gds-info.prt-name, output var-is-error)
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
      loc-tt-chk-discnt.value-type = integer('0':U)
      loc-tt-chk-discnt.discnt-type = integer('0':U)
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
    loc-tt-chk-discnt.discnt-value-abs = tt-chk-gds.src-discnt * tt-chk-gds.src-qnty
    loc_chk-discnt.discnt-value-abs = tt-chk-gds.src-discnt * tt-chk-gds.src-qnty
    .
  end.
end.
else if tt-chk-gds.src-discnt = 0 then do:
      find first loc_chk-discnt where
                 loc_chk-discnt.doc-code = tt-chk-doc.doc-code
             AND loc_chk-discnt.record-type = 0
             AND loc_chk-discnt.line-num = tt-chk-gds.line-num
             AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      if avail loc_chk-discnt then do:
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
if tt-chk-gds.src-qnty <> 0 then  do:
  price-from-check =
  ( tt-chk-gds.SRC-PRICE / ( 1 - units-dpcnt / 100 ) ) * abs( tt-chk-gds.src-qnty ) .
  assign
  tt-chk-gds.b-code = ( if b-c <> ? then b-c else 0)
  tt-chk-gds.is-error = (b-c = ?)
    tt-chk-gds.doc-qnty =  tt-chk-gds.doc-qnty
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
  with frame Dialog-Frame.
  glog = br-gds:refresh() in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE get-discnt :
DEFINE INPUT PARAMETER p-line-num like ub.chk-discnt.line-num.
DEFINE INPUT PARAMETER p-discnt-v-type like ub.chk-discnt.value-type no-undo.
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
    run get-b-code in this-procedure .
end.
END PROCEDURE.
PROCEDURE get-good-proc :
define input  parameter parb-code as integer no-undo.
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type31 as character no-undo .
define variable v-value-date31 as date no-undo .
define variable v-value-decimal31 as decimal no-undo .
define variable v-value-integer31 as INTEGER no-undo .
define variable v-value-logical31 AS LOGICAL no-undo .
define variable v-tth31 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date31
    ,output v-value-decimal31
    ,output v-value-integer31
    ,output v-value-logical31
    ,output v-param-type31
    ,INPUT-OUTPUT table-handle v-tth31
    )  .
delete object v-tth31 no-error.
get-chkc_context.pos-type = dflt-cd.
get-chkc_context.p-log-handle = this-procedure:handle.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
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
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
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
END PROCEDURE.
PROCEDURE get-pay-proc :
define input parameter parpay-code as integer no-undo.
define input parameter parcurr-code as integer no-undo.
define output parameter parcurr-name as character no-undo.
define output parameter varpay-name like ub.cash-pay.obj-name no-undo.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
FIND FIRST loc_cash-pay No-LOCK WHERE
                  loc_cash-pay.cdpay-code = parpay-code AND
                  loc_cash-pay.curr-code = parcurr-code No-ERROR.
if avail loc_cash-pay then do:
    varpay-name = loc_cash-pay.obj-name.
end.
else do:
  if tt-chk-doc.chk-type = integer('12':U)
  and parpay-code = 0
  and parcurr-code = 0 then do:
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if not v-is-petrol-check then do:
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
  tt-chk-doc.discnt = tt-chk-doc.discnt + tt-chk-doc.real-subdiscnt
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
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame Dialog-Frame =  'Продажа,1,Возврат,6,ВзврСпис,96,СбросТрнзкц,14,Перелив,15,ПеревТрнзкц,16,РазблТрнзкц,36,ТехПролив,17,Списание,69,Аннуляция,8,Инвентаризация,11,Закрытие_смены,13,Открытие_смены,40,Z-отчет,12,_Продажа,101,_Возврат,106,_ВзврСпис,196,_СбросТрнзкц,114,_Перелив,115,_ПеревТрнзкц,116,_ТехПролив,117,_Списание,169,_Аннуляция,108,_Инвентаризация,111,_Z-отчет,112,_СбросТрнзкц,114,_РазблТрнзкц,136,_Закрытие_смены,113,>Продажа,201,>Возврат,206,>Аннуляция,208,>>Продажа,301,>>Возврат,306,Инкассация,2,Касс_фонд,3,Перевод_опл,4,Расход_кассы,5,Декл_ден_ящ,7,Приход_Корр,43,Расход_Корр,44':U +
                                                      (if par-mode <> 'ДОБАВЛЕНИЕ':U
                                                      then (chr(44) + "Ошибка" + chr(44) + string(0))
                                                      else "":U)
.
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
frame Dialog-Frame:title = substitute("ЧЕК № &1 Время : &2"
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
                            else substitute("Дата учета &1", string(tt-chk-doc.shift-date)).
 if par-l-mask then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
else v-src-d-card = tt-chk-doc.src-d-card .
 DISPLAY
 cb-chk-type
 fhour
 fmin
 fsec
 F-cashier
 F-salesman
 f-cli-name
 WITH FRAME Dialog-Frame .
 IF AVAILABLE tt-chk-doc THEN
DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
      tt-chk-doc.obj-code tt-chk-doc.d-card v-src-d-card tt-chk-doc.pay-desk
      tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
      tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cash-scale
      tt-chk-doc.cash-rate tt-chk-doc.shift-num tt-chk-doc.shift-name tt-chk-doc.PS
      tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt
      tt-chk-doc.netto tt-chk-doc.d-pcnt
  WITH FRAME Dialog-Frame .
ENABLE
B-quit
B-prev
B-next
B-help
br-gds
br-discnt
br-pay
b-discnt
b-bonus
b-gds
WITH FRAME Dialog-Frame.
assign
tt-chk-gds.b-code:read-only in browse br-gds = yes
tt-chk-gds.src-code:read-only in browse br-gds = yes
tt-chk-gds.pump:read-only in browse br-gds = yes
tt-chk-gds.nozzle-code:read-only in browse br-gds = yes
tt-chk-gds.loc1:read-only in browse br-gds = yes
tt-chk-gds.src-price:read-only in browse br-gds = yes
tt-chk-gds.src-discnt:read-only in browse br-gds = yes
tt-chk-gds.src-qnty:read-only in browse br-gds = yes
tt-chk-gds.road-tax:read-only in browse br-gds = yes
tt-chk-gds.price-service:read-only in browse br-gds = yes
tt-chk-gds.depart-id:read-only in browse br-gds = yes
tt-chk-gds.depart-code:read-only in browse br-gds = yes
tt-chk-pay.pay-code:read-only in browse br-pay = yes
tt-chk-pay.curr-code:read-only in browse br-pay = yes
tt-chk-pay.tot-sum:read-only in browse br-pay = yes
tt-chk-pay.pay-card:read-only in browse br-pay = yes
tt-chk-pay.cash-rate:read-only in browse br-pay = yes
tt-chk-discnt.discnt-value-abs:read-only in browse br-discnt = yes
tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
.
if tt-chk-doc.chk-type = integer('12':U) then do:
  assign
  tt-chk-pay.pay-code:visible in browse br-pay = no
  tt-chk-pay.curr-code:visible in browse br-pay = no
  tt-chk-pay.pay-card:visible in browse br-pay = no
  tt-chk-pay.tot-sum:label in browse br-pay = "Сумма"
  .
end.
else do:
  assign
  tt-chk-pay.pay-code:visible in browse br-pay = yes
  tt-chk-pay.curr-code:visible in browse br-pay = yes
  tt-chk-pay.pay-card:visible in browse br-pay = yes
  tt-chk-pay.tot-sum:label in browse br-pay = "Сумма платежа"
  .
end.
if not cas-shft then do:
  hide
  tt-chk-doc.src-shift-date
  tt-chk-doc.shift-num
  tt-chk-doc.shift-name
  in frame Dialog-Frame.
end.
VIEW FRAME Dialog-Frame.
IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.
OPEN QUERY BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,            first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.
CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code     AND tt-chk-discnt.record-type = v-br-discnt-current-type     by tt-chk-discnt.line-num.   END.   WHEN 'ПРОСМОТР':U THEN DO:         OPEN QUERY BR-discnt FOR EACH tt-chk-discnt              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND                                tt-chk-discnt.record-type = v-br-discnt-current-type no-LOCK            by tt-chk-discnt.line-num.   END. END CASE.
hide br-discnt in frame Dialog-Frame.
for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code = "corr-osnov":
  v-doc-osnov = OsnovCorr(integer(buf_chk-doc-attr.attr-value)) .
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
v-doc-osnov
corr-date
f-cause-corr
f-num-corr
with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE pays-display :
DEFINE INPUT PARAMETER p-change-curr as logical no-undo.
DEFINE VARIABLE curr-rate                  like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                 like ub.curr-shop.exch-scale  no-undo .
FIND FIRST ub.cash-pay WHERE
          ub.cash-pay.cdpay-code = tt-chk-pay.pay-code AND
          ub.cash-pay.curr-code = tt-chk-pay.curr-code NO-LOCK NO-ERROR.
if NOT available ub.cash-pay then do:
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
PROCEDURE proc-b-bonus :
define variable var-line-num as character no-undo.
define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not br-discnt:visible in frame Dialog-Frame
or v-br-discnt-current-type = 0
then do:
    hide br-gds in frame Dialog-Frame.
    assign
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = yes
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = yes
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = yes
    v-br-discnt-current-type = 4
    .
    display br-discnt with frame Dialog-Frame.
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code     AND tt-chk-discnt.record-type = v-br-discnt-current-type     by tt-chk-discnt.line-num.   END.   WHEN 'ПРОСМОТР':U THEN DO:         OPEN QUERY BR-discnt FOR EACH tt-chk-discnt              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND                                tt-chk-discnt.record-type = v-br-discnt-current-type no-LOCK            by tt-chk-discnt.line-num.   END. END CASE.
      ENABLE
      b-gds
      b-discnt
      with frame Dialog-Frame.
      DISABLE
      b-bonus
      with frame Dialog-Frame.
   return.
end.
END PROCEDURE.
PROCEDURE proc-b-discnt :
define variable var-line-num as character no-undo.
define variable v-wro-code as integer no-undo .
define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not br-discnt:visible in frame Dialog-Frame
or v-br-discnt-current-type = 4
then do:
    hide br-gds in frame Dialog-Frame.
    assign
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = no
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = no
    v-br-discnt-current-type = 0
    .
    display br-discnt with frame Dialog-Frame.
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
  run diasize_restore-current-size in this-procedure .
  CASE par-mode:   WHEN 'ДОБАВЛЕНИЕ':U   OR   WHEN 'ИЗМЕНЕНИЕ':U THEN DO:     OPEN QUERY BR-discnt FOR EACH tt-chk-discnt WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code     AND tt-chk-discnt.record-type = v-br-discnt-current-type     by tt-chk-discnt.line-num.   END.   WHEN 'ПРОСМОТР':U THEN DO:         OPEN QUERY BR-discnt FOR EACH tt-chk-discnt              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND                                tt-chk-discnt.record-type = v-br-discnt-current-type no-LOCK            by tt-chk-discnt.line-num.   END. END CASE.
  ENABLE
  b-gds
  b-bonus
  with frame Dialog-Frame.
  DISABLE
  b-discnt
  with frame Dialog-Frame.
   return.
end.
END PROCEDURE.
PROCEDURE proc-b-gds :
define variable varrid-list as character no-undo.
define variable ii as integer no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define variable v-wro-code as integer no-undo .
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
    ENABLE
    b-discnt
    with frame Dialog-Frame.
    DISABLE
    b-gds
    with frame Dialog-Frame.
    IF dflt-cd = 'MAGIA-XML':U THEN         OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY BR-gds FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,                          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.
end.
END PROCEDURE.
PROCEDURE reposition-c-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-chk-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-c-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-chk-doc-recid
      ).
    if v-new-c-chk-doc-recid <> ?
    then do:
      define buffer buf_c-chk-doc for ub.c-chk-doc .
      find first buf_c-chk-doc no-lock
        where recid(buf_c-chk-doc) = v-new-c-chk-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-chk-doc-recid
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
PROCEDURE write-log-and-file :
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer no-undo .
define input parameter p-log-string     as character no-undo .
message
p-log-string
view-as alert-box error .
END PROCEDURE.
FUNCTION get-good RETURNS CHARACTER
  ( input  parb-code as integer, output pargds-name as character, output parprt-name as character, output paris-error as logical) :
define variable var-artic like ub.goods.artic No-undo.
run get-good-proc in this-procedure (
input parb-code
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
return varpay-name.
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
