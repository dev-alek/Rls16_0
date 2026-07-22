block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-autocu.p $
$Archive: cus/r-autocu.p $

Отчет для лотереи АВТОКУШ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/03/09
Author: Bakhtadze Natalya
Creation date: 09/03/09

*/

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-autocu.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: cus/r-autocu.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "$Отчет для лотереи АВТОКУШ $":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ cmp/obj-list.i }
{ ref/cp-attr.i }
{ rep/cpapcep.i  "NEW SHARED" }
{ rep/cpapcep.i  "proc" }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ cmp/r-page0.i }
{ cmp/r-pril.i }
{ rep/r-pychk0.i defalgo    }
{ gbl/thbjattr.i }

define variable parparentproc as widget-handle no-undo .
define variable p-date-start as date no-undo .
define variable p-date-end as date no-undo .

define variable v-curr-r-b as character no-undo .
define variable cplot as character no-undo .
define variable rep-sort as character no-undo .
define variable par-type as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-b-code as integer no-undo .
define variable line as character no-undo .
define variable v-current-gds-code as integer no-undo .
define variable v-current-cdpay-code as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-num-units as character no-undo .

define temp-table temp-acush no-undo
field b-code as integer
field gds-code as integer
field cdpay-code as integer
field curr-code as integer
field prefix as character
field qnty as decimal
field sum as decimal /*в r - b - как в чеке*/
field num-units as integer
index pi is unique primary
b-code
cdpay-code
curr-code
prefix
.

define buffer buf_temp-acush for temp-acush.
define buffer all_temp-acush for temp-acush.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-doc for ub.chk-doc.

{ gbl/curr-r-b.i v-curr-r-b }
run cpapcep in this-procedure .

p-date-start = X-date-start.
p-date-end = X-date-end.
parparentproc = my-handle.


define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

run adm/shattri.p (
    input "get":U
    ,input  '' /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-report-glob}
    ,input  {&attr-report-glob_rep-sort} /*p-param-code*/
    ,output rep-sort
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error or rep-sort = "":U then do:
  delete object v-tth.
  define variable v-tooltip as character no-undo .
  define variable v-label as character no-undo .
  define variable v-tooltip-code as character no-undo .
  run thbjattr_tooltip in this-procedure (
                                            input  {&attr-report-glob}
                                           ,input  {&attr-report-glob_rep-sort}
                                           ,output v-tooltip
                                           ,output v-label
                                           ,output v-tooltip-code ) no-error.
  if error-status:error then do:
    assign
    v-tooltip-code = {&attr-report-glob_rep-sort}
    v-tooltip = {&attr-report-glob}
    .
  end.
  message
  substitute("Не найден или незаполнен параметр:&2&1&2Секция <&3>"
             , v-tooltip-code
             , {&new-line}
             ,v-tooltip)
  view-as alert-box error .
  return .
end.

delete object v-tth.

run adm/shattri.p (
    input "get":U
    ,input  '' /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-report-glob}
    ,input  {&attr-report-glob_cplot} /*p-param-code*/
    ,output cplot
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error or cplot = "":U then do:
  delete object v-tth.
  run thbjattr_tooltip in this-procedure (
                                            input  {&attr-report-glob}
                                           ,input  {&attr-report-glob_cplot}
                                           ,output v-tooltip
                                           ,output v-label
                                           ,output v-tooltip-code ) no-error.
  if error-status:error then do:
    assign
    v-tooltip-code = {&attr-report-glob_cplot}
    v-tooltip = {&attr-report-glob}
    .
  end.

  message
  substitute("Не найден или незаполнен параметр:&2&1&2Секция <&3>"
             , v-tooltip-code
             , {&new-line}
             ,v-tooltip)
  view-as alert-box error .
  return .
end.

delete object v-tth.


run waitfram-show in this-procedure ("Ждите...").

/*соберем данные*/

for each buf_temp-acush:
  delete buf_temp-acush.
end.


for each obj-list :
  run waitfram-show in this-procedure ( substitute("Ждите...Обработка чеков по &1&2", obj-list.obj-type, obj-list.obj-code)).
  /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
  run rep/rpychk0.p ( input "r-autocu"
                      ,input obj-list.obj-type
                      ,input obj-list.obj-code
                      ,input p-date-start /*p-date-from*/
                      ,input p-date-end /*p-date-to*/
                      ,input ? /*p-shift-date-from*/
                      ,input ? /*p-shift-date-to*/
                      ,input ? /*p-shift-num-start*/
                      ,input ? /*p-shift-num-end*/
                      ,input ? /*p-inkas-code*/
                      ).
  _chk-gds-pay:
  FOR EACH buf_chk-doc No-LOCK WHERE
          buf_chk-doc.obj-type = obj-list.obj-type
      and buf_chk-doc.obj-code = obj-list.obj-code
      and buf_chk-doc.chk-date >= p-date-start
      and buf_chk-doc.chk-date <= p-date-end,
     each buf_chk-gds-pay no-lock where
          buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
      and buf_chk-gds-pay.algo-num = {&current-algo-1}
          :
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds-pay.
    if v-doc-code <> buf_chk-doc.doc-code then do:
      v-num-units = ''.
      v-doc-code = buf_chk-doc.doc-code.
    end.
    if replace(replace(replace(replace(buf_chk-doc.office, {&gds-office}, ''), {&gds-goods}, ''), {&shift-err}, ''), {&comma-char}, '') <> '' then next _chk-gds-pay.
    if buf_chk-gds-pay.rec-type <> 1 then next _chk-gds-pay.
    find first buf_temp-acush where
                buf_temp-acush.b-code = buf_chk-gds-pay.b-code
            and buf_temp-acush.cdpay-code = buf_chk-gds-pay.pay-code
            and buf_temp-acush.curr-code = buf_chk-gds-pay.curr-code
            and buf_temp-acush.prefix = buf_chk-gds-pay.pay-card no-error.
    if not available buf_temp-acush then do:
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
      if available buf_bar-code then do:
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_bar-code.b-code no-error.
      end.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-code = buf_chk-gds-pay.b-code no-error.
      create buf_temp-acush.
      assign
      buf_temp-acush.b-code = buf_chk-gds-pay.b-code
      buf_temp-acush.gds-code = (if available buf_goods
                                 then buf_goods.gds-code
                                 else 0)
      buf_temp-acush.cdpay-code = buf_chk-gds-pay.pay-code
      buf_temp-acush.curr-code = buf_chk-gds-pay.curr-code
      buf_temp-acush.prefix = buf_chk-gds-pay.pay-card
      .
    end.
    assign
    buf_temp-acush.qnty = buf_temp-acush.qnty +  buf_chk-gds-pay.eff-doc-qnty
    buf_temp-acush.sum = buf_temp-acush.sum + buf_chk-gds-pay.tot-r-b * (if v-curr-r-b = {&r-b-rubl} then 1 else  buf_chk-gds-pay.eff-base-rate)
    buf_temp-acush.num-units = buf_temp-acush.num-units +
                               (if lookup(string(buf_chk-gds-pay.cpline-num), v-num-units) = 0 then 1 else 0) +
                               (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 2
                                then
                                integer(entry(3, buf_chk-gds-pay.line-type, {&delim-par})) - 1
                                else 0)
    v-num-units = v-num-units + {&comma-char} + string(buf_chk-gds-pay.cpline-num)
    .
  end.
end.

find first buf_temp-acush no-error.
if not available buf_temp-acush then do:
  run waitfram-hide in this-procedure .
  message
  "Не найдено данных для отчета в заданном периоде времени"
  view-as alert-box warning.
  return.
end.

assign
sheetf.Excel-Column-Lable =  "Топливо,Оплата,Л,Сумма,Количество"
sheetf.colformat = ""
sheetf.sizes = "40,45,16,15,11"
str3 = string( "(Все суммы в {&abbr_rublyah})" )
.
DEFINE FRAME OutFrame
buf_goods.gds-name column-label "Топливо" format "X(40)"
buf_cash-pay.obj-name column-label "Оплата" format "X(45)"
buf_temp-acush.qnty column-label "Л" format "->>>,>>>,>>>9.999"
buf_temp-acush.sum column-label "Сумма" format "->>>,>>>,>>9.99"
buf_temp-acush.num-units column-label "Количество" format "->>,>>>,>>9"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 70 format "X(23)" SKIP
Line format "X(134)" AT 1
with width {&A4_CW0} down stream-io.

FORM HEADER
Line format "X(134)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width {&A4_CW0}
PAGE-BOTTOM no-labels no-box.


run prn-lib-open-stream  in this-procedure (
                                            input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
run rep/extitle.p ( input 1).
run waitfram-show in this-procedure ("Ждите..." ).
PUT stream PrnLibStream UNFORMATTED
"Отчет о продажах топлива по лотерейным билетам АВТОКУШ"
format "x(60)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED
str1 skip
str2 skip
str4 skip
str3 skip
.
PUT stream PrnLibStream UNFORMATTED
reportheader SKIP(0).
FORM with FRAME OutFrame.
VIEW STREAM PrnLibStream FRAME BottomFrame .
VIEW STREAM PrnLibStream FRAME OutFrame .
do v-ii = 1 to num-entries(rep-sort):
  assign
  v-current-gds-code = integer(entry(v-ii, rep-sort)).
  do v-jj = 1 to num-entries(cplot):
    assign
    v-current-cdpay-code = entry(v-jj, cplot).
    for each buf_temp-acush where
              buf_temp-acush.gds-code = v-current-gds-code
         and  buf_temp-acush.cdpay-code = integer(v-current-cdpay-code)
         and buf_temp-acush.curr-code = 0:
      find first all_temp-acush where
                  all_temp-acush.b-code = 0
              and all_temp-acush.cdpay-code = 0
              and all_temp-acush.curr-code = 0
              and all_temp-acush.prefix = '' no-error.
      if not available all_temp-acush then do:
        create all_temp-acush.
        assign
        all_temp-acush.b-code = 0
        all_temp-acush.cdpay-code = 0
        all_temp-acush.curr-code = 0
        all_temp-acush.prefix = ''
        .
      end.
      assign
      all_temp-acush.qnty = all_temp-acush.qnty +  buf_temp-acush.qnty
      all_temp-acush.sum = all_temp-acush.sum + buf_temp-acush.sum
      all_temp-acush.num-units = all_temp-acush.num-units + buf_temp-acush.num-units
      .
      find first buf_goods no-lock where
                buf_goods.gds-code = buf_temp-acush.gds-code no-error.
      find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_temp-acush.cdpay-code
            and buf_cash-pay.curr-code = buf_temp-acush.curr-code no-error.

      DISPLAY STREAM PrnLibStream
      (if available buf_goods
      then buf_goods.gds-name
      else substitute("Топливо - код товара &1", buf_temp-acush.gds-code)) @ buf_goods.gds-name
      (if available buf_cash-pay
      then (buf_cash-pay.obj-name + buf_temp-acush.prefix)
      else substitute("Тип касс.платежа &1/&2", buf_temp-acush.cdpay-code, buf_temp-acush.prefix) ) @ buf_cash-pay.obj-name
      buf_temp-acush.qnty
      buf_temp-acush.sum
      buf_temp-acush.num-units
      WITH FRAME OutFrame.
      down stream PrnLibstream 1
      with frame OutFrame.
      {&PutExcel}
      (if available buf_goods
      then buf_goods.gds-name
      else substitute("Топливо - код товара &1", buf_temp-acush.gds-code)) {&tabulation}
      (if available buf_cash-pay
      then (buf_cash-pay.obj-name + buf_temp-acush.prefix)
      else substitute("Тип касс.платежа &1/&2", buf_temp-acush.cdpay-code, buf_temp-acush.prefix) ) {&tabulation}
      round(buf_temp-acush.qnty, 3) {&tabulation}
      round(buf_temp-acush.sum, 2) {&tabulation}
      buf_temp-acush.num-units
      skip.
    end.
  end.
end.
underline stream prnlibstream
buf_goods.gds-name
buf_cash-pay.obj-name
buf_temp-acush.qnty
buf_temp-acush.sum
buf_temp-acush.num-units
WITH FRAME OutFrame.
find first all_temp-acush where
           all_temp-acush.gds-code = 0
      and  all_temp-acush.cdpay-code = 0
      and  all_temp-acush.curr-code = 0
      and  all_temp-acush.prefix = '' no-error.
DISPLAY STREAM PrnLibStream
"ИТОГО" @ buf_goods.gds-name
(if available all_temp-acush
then all_temp-acush.qnty
else 0) @  buf_temp-acush.qnty
(if available all_temp-acush
then all_temp-acush.sum
else 0) @  buf_temp-acush.sum
(if available all_temp-acush
then all_temp-acush.num-units
else 0) @  buf_temp-acush.num-units
WITH FRAME OutFrame.
down stream PrnLibstream 1
with frame OutFrame.
{&PutExcel}
"ИТОГО" {&tabulation}
"" {&tabulation}
(if available all_temp-acush
then round(all_temp-acush.qnty, 3)
else 0)  {&tabulation}
(if available all_temp-acush
then round(all_temp-acush.sum, 2)
else 0) {&tabulation}
(if available all_temp-acush
then all_temp-acush.num-units
else 0)
skip.

run waitfram-hide in this-procedure .
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
{&CloseExcel}

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
define variable v-report-name as character no-undo .