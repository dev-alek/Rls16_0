/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать отчета о выручке  BreakByCass

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable acc-count-ln as integer no-undo . /* кол-во линий оплат для отображения в хронометраже */
define variable acc-count-step as integer no-undo . /* шаг хронометража */
define variable acc-day-base as decimal no-undo .
define variable acc-day-rubl as decimal no-undo .
define variable acc-day-cnt  as integer no-undo . /* кол-во чеков за все дни */
define variable acc-day-nf   as integer no-undo . /* кол-во чеков за все дни нефискальных */
define variable acc-desk-rubl  as decimal no-undo .
define variable acc-desk-base  as decimal no-undo .
define variable acc-desk-count as integer no-undo .
define variable acc-desk-count-nf as integer no-undo .
define variable acc-curr-sum  as decimal no-undo .
define variable acc-curr-base as decimal no-undo .
define variable acc-curr-rubl as decimal no-undo .
define variable v-skip-line    as logical no-undo . /* true: пропустить запись */
define variable v-is-sub-count as logical no-undo. /* true: вычесть чек из общего количества как нефискальный */
/* define variable v-is-sub-pay   as logical no-undo .  true: вычесть оплату чека как нефискального 15/IV-2019 вычитается через sub-count */
define variable v-report-name       as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-vsex-cas          as character no-undo .
define variable v-avg-chk           as decimal decimals  2 no-undo .
define variable v-times             as character no-undo.
define variable v-td-date           as character no-undo .

define variable v-chk-count as integer no-undo .
define query qben-chk-count for ben-chk-count .

define stream OutStr-html.

{ gbl/cur-time.i }
{ gbl/prn-lib.i   }
{ rep/html-conv.i }
/*{ rep/e-nobenq.i }*/

/* --------------------------------------------------------------------- */
function putRowAmount1 returns character private
(input p-curr-name as character
,input p-total1    as decimal
) :
define variable v-row-amount as character no-undo .
define variable v-curr-name  as character no-undo .

  v-curr-name = if p-curr-name > "" then p-curr-name else "<br />":U .
  v-row-amount = substitute (
      '<td>&1</td><td num="0.00" val="&2">&2</td><td><br /></td><td><br /></td>'
      , v-curr-name
      , fnc-convert-dot-to-colon(p-total1, "->>>>>>>>>>>9.99", 2)
  ) .

  return v-row-amount .
end function . /* end_of putRowAmount1 */  
/* ----------------------------------------------------------------------*/
function putRowAmount returns character private
(input p-curr-name as character
,input p-total1    as decimal
,input p-total2    as decimal
,input p-total3    as decimal
) :
define variable v-row-amount as character no-undo .
define variable v-curr-name  as character no-undo .

  v-curr-name = if p-curr-name > "" then p-curr-name else "<br />":U .
  v-row-amount = substitute (
      '<td>&1</td><td num="0.00" val="&2">&2</td><td num="0.00" val="&3">&3</td><td num="0.00" val="&4">&4</td>'
      , v-curr-name
      , fnc-convert-dot-to-colon(p-total1, "->>>>>>>>>>>9.99", 2)
      , fnc-convert-dot-to-colon(p-total2, "->>>>>>>>>>>9.99", 2)
      , fnc-convert-dot-to-colon(p-total3, "->>>>>>>>>>>9.99", 2)
  ) .

  return v-row-amount .
end function . /* end_of putRowAmount */  
/* ----------------------------------------------------------------------*/
procedure CreateBenefits2 private :
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-pay-code  as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define input parameter p-pay-desk  as integer no-undo .
define input parameter p-sum       as decimal no-undo .
define input parameter p-base      as decimal no-undo .
define input parameter p-rubl      as decimal no-undo .
define buffer buf_benefits for benefits .
define buffer buf_cash-pay for ub.cash-pay .
define buffer buf_currency for ub.currency .

  find first buf_benefits
       where buf_benefits.obj-type  = p-obj-type
         and buf_benefits.obj-code  = p-obj-code
         and buf_benefits.pay-code  = p-pay-code
         and buf_benefits.curr-code = p-curr-code
 /* ! */ and buf_benefits.pay-desk  = p-pay-desk no-error .
  if not available buf_benefits then do:
    FIND FIRST buf_cash-pay NO-LOCK
         WHERE buf_cash-pay.cdpay-code = p-pay-code
           AND buf_cash-pay.curr-code  = p-curr-code NO-ERROR.
    FIND FIRST buf_currency NO-LOCK
         WHERE buf_currency.curr-code = p-curr-code NO-ERROR.
    create buf_benefits.
    assign
      buf_benefits.pay-desk  = p-pay-desk
      buf_benefits.obj-type  = p-obj-type
      buf_benefits.obj-code  = p-obj-code
      buf_benefits.pay-code  = p-pay-code
      buf_benefits.pay-name  = if available buf_cash-pay then buf_cash-pay.obj-name  else "Неопознанная оплата"
      buf_benefits.curr-code = p-curr-code
      buf_benefits.curr-name = if available buf_currency then buf_currency.curr-name else "Неопознанная валюта"
      buf_benefits.tot-sum   = p-sum
      buf_benefits.tot-base  = p-base
      buf_benefits.tot-rubl  = p-rubl
    .
  end .
  else assign
    buf_benefits.tot-sum  = buf_benefits.tot-sum  + p-sum
    buf_benefits.tot-base = buf_benefits.tot-base + p-base
    buf_benefits.tot-rubl = buf_benefits.tot-rubl + p-rubl
  .
end procedure . /* end_of CreateBenefits2 */  
/* ----------------------------------------------------------------------*/

&global-define  no-benefits    "Не было никакой выручки на выбранных объектах ~
в течение заданного Вами периода времени."


empty temp-table benefits .
empty temp-table inkas-num .
empty temp-table day_sum .
empty temp-table all-days_sum .
empty temp-table ben-chk-count .


assign
date_string = cur-time-print()
.

/* 09/VIII-2019 сообщение об отсутствии выручки выводится по отсутствию записей в benefits
run no-benq(output found).

run waitfram-hide in this-procedure .
if not found then do:
  message {&no-benefits} view-as alert-box information .
  return.
end.
*/
assign
ChkAmount = 0
ObjAmount = 0
AllDay-BaseSum = 0
AllDay-RublSum = 0
  acc-count-ln = 0 
  acc-count-step = 0 
.

FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :
  ACCUMULATE obj-list.obj-code ( COUNT ).
  assign
  acc-day-base = 0
  acc-day-rubl = 0
  acc-day-cnt = 0
  acc-day-nf  = 0
  .
  /* X-radio-task =
    "Календарные даты", 1,
    "Сменные сутки", 2,
    "Сменные сутки и порядок", 3,
    "По сменам", 4  
  */
  CASE X-radio-Task > 1 :
    WHEN YES THEN DO:
      _chk-doc3:
      FOR EACH chk-doc WHERE
                chk-doc.obj-type = obj-list.obj-type AND
              chk-doc.obj-code = obj-list.obj-code AND
              chk-doc.shift-date >= x-date-start AND
              chk-doc.shift-date <= x-date-end AND
              (IF cas-num > 0 then chk-doc.pay-desk = cas-num else TRUE) NO-LOCK
      BREAK
      by chk-doc.obj-type
      by chk-doc.obj-code
      by chk-doc.pay-desk :
        IF FIRST-OF(chk-doc.pay-desk) then assign
          acc-desk-rubl = 0
          acc-desk-base = 0
          acc-desk-count = 0
          acc-desk-count-nf = 0
        .
        v-skip-line = 
        (
             X-Radio-task = 3 AND
             ((chk-doc.shift-date = x-date-start AND chk-doc.shift-num < X-shift-start) OR
              (chk-doc.shift-date = x-date-end   AND chk-doc.shift-num > X-shift-end))
        ) OR (
             X-radio-task = 4 AND
             chk-doc.shift-num <> X-Shift-Alone
&if "{1}" = "time" &then
        ) OR (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= chk-doc.chk-time
                                         AND times.time2 >= chk-doc.chk-time)
&endif
        ) .
        if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          found = false .
          if v-is-sub-count then do :
            for EACH chk-pay NO-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code :
              if chk-pay.tot-sum <> 0 then do :
                found = true .
                leave .
              end .
            END .
          end .
          else do :
            for EACH chk-pay NO-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code
            BREAK
            BY chk-pay.pay-code
            BY chk-pay.curr-code:
              if chk-pay.tot-sum <> 0 then do :
                found = true .
                { rep/e-bcrbnp.i  }
              end .
            END .
          end .
          if found then assign
            acc-desk-count    = acc-desk-count    + 1
            acc-desk-count-nf = acc-desk-count-nf + 1 when (v-is-sub-count)
          .
        end .
        
        if last-of( chk-doc.pay-desk ) then do:
          create day_sum.
          assign
            day_sum.obj-type = obj-list.obj-type
            day_sum.obj-code = obj-list.obj-code
            day_sum.pay-desk = chk-doc.pay-desk
            day_sum.tot-rubl = acc-desk-rubl
            day_sum.tot-base = acc-desk-base
            day_sum.chk-cnt-all =  acc-desk-count
            day_sum.chk-cnt-nf  =  acc-desk-count-nf
          .
          assign
            acc-day-rubl = acc-day-rubl + day_sum.tot-rubl
            acc-day-base = acc-day-base + day_sum.tot-base
            acc-day-cnt  = acc-day-cnt  + day_sum.chk-cnt-all
            acc-day-nf   = acc-day-nf   + day_sum.chk-cnt-nf
          .
        end.

      END.
    END. /*when YES*/
    WHEN NO THEN DO:
      _chk-doc4:
      FOR EACH chk-doc WHERE
                  chk-doc.obj-type = obj-list.obj-type AND
                chk-doc.obj-code = obj-list.obj-code AND
                chk-doc.chk-date >= x-date-start AND
                chk-doc.chk-date <= x-date-end AND
                (IF cas-num > 0 then chk-doc.pay-desk = cas-num else TRUE) NO-LOCK
        BREAK
        by chk-doc.obj-type
        by chk-doc.obj-code
        by chk-doc.pay-desk :
        IF FIRST-OF(chk-doc.pay-desk) then assign
          acc-desk-rubl = 0
          acc-desk-base = 0
          acc-desk-count = 0
          acc-desk-count-nf = 0
        .
&if "{1}" = "time" &then
        v-skip-line = 
        (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= chk-doc.chk-time
                                         AND times.time2 >= chk-doc.chk-time)
        ) .
&else 
        v-skip-line = false . 
&endif
        if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          found = false .
          if v-is-sub-count then do :
            for EACH chk-pay NO-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code :
              if chk-pay.tot-sum <> 0 then do :
                found = true .
                leave .
              end .
            END .
          end .
          else do :
            for EACH chk-pay NO-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code
            BREAK
            BY chk-pay.pay-code
            BY chk-pay.curr-code:
              if chk-pay.tot-sum <> 0 then do :
                found = true .
                { rep/e-bcrbnp.i  }
              end .
            END .
          end .
          if found then assign
            acc-desk-count    = acc-desk-count    + 1
            acc-desk-count-nf = acc-desk-count-nf + 1 when (v-is-sub-count)
          .
        end .
          
        if last-of( chk-doc.pay-desk ) then do:
          create day_sum.
          assign
            day_sum.obj-type = obj-list.obj-type
            day_sum.obj-code = obj-list.obj-code
            day_sum.pay-desk = chk-doc.pay-desk
            day_sum.tot-rubl = acc-desk-rubl
            day_sum.tot-base = acc-desk-base
            day_sum.chk-cnt-all =  acc-desk-count
            day_sum.chk-cnt-nf  =  acc-desk-count-nf
          .
          assign
            acc-day-rubl = acc-day-rubl + day_sum.tot-rubl
            acc-day-base = acc-day-base + day_sum.tot-base
            acc-day-cnt  = acc-day-cnt  + day_sum.chk-cnt-all
            acc-day-nf   = acc-day-nf   + day_sum.chk-cnt-nf
          .
        end.

      END.
    END. /*when no*/
  END CASE.
  
  
  CREATE all-days_sum .
  assign
    all-days_sum.obj-type = obj-list.obj-type
    all-days_sum.obj-code = obj-list.obj-code
    all-days_sum.tot-base = acc-day-base
    all-days_sum.tot-rubl = acc-day-rubl
    all-days_sum.chk-cnt-all  = acc-day-cnt
    all-days_sum.chk-cnt-nf   = acc-day-nf
  .
  assign
    AllDay-BaseSum = AllDay-BaseSum + acc-day-base
    AllDay-RublSum = AllDay-RublSum + acc-day-rubl
    ObjAmount      = ObjAmount + 1
    ChkAmount      = ChkAmount + (all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf)
  .
END. /*FOR EACH OBJ-LIST*/


if not can-find (first benefits) then do:
  message {&no-benefits} view-as alert-box information .
  return.
end.

/*define variable v-curr-r-b as character no-undo .*/
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
&if "{1}" = "rubl" &then
sale-price-type = "{&abbr_rubley}".
&else
sale-price-type = base-type.
&endif
end.
else sale-price-type = "{&abbr_rubley}".

for each benefits :
  benefits.tot-r-b = if v-curr-r-b = {&r-b-base} then benefits.tot-base else benefits.tot-rubl .
end .
for each day_sum :
  day_sum.tot-r-b = if v-curr-r-b = {&r-b-base} then day_sum.tot-base else day_sum.tot-rubl .
end .
for each all-days_sum :
  all-days_sum.tot-r-b = if v-curr-r-b = {&r-b-rubl} then all-days_sum.tot-rubl else all-days_sum.tot-base .
end .
 
run waitfram-hide in this-procedure .


    run prn-lib-get-report-name  in this-procedure (
                                                       input parParentProc
                                                      ,output v-report-name
                                                    ).
  assign
    v-file-name-rep-htm = v-report-name + ".html"
    v-vsex-cas = IF cas-num = 0 then "ВСЕХ КАСС" ELSE ("КАССЫ " + string(cas-num))
    v-avg-chk  = if ChkAmount > 0 then round(                  
      (if v-curr-r-b = {&r-b-rubl} then AllDay-RublSum else AllDay-BaseSum)  /  ChkAmount
                                             , 2 ) else 0 
  .
&if "{2}" = "time" &then
  v-times = "" .
  IF T-time then
    FOR EACH times No-LOCK :
      v-times = v-times + times + {&space-char} .
    END .
&endif

do : /* prepare_header */
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    '<html>' skip
    '<head>' skip
    '  <meta charset="utf-8">' skip
    '  <style type="text/css">' skip
    '      table ~{border-collapse: collapse~;~}' skip
    '      tbody td, th ~{border: 1px solid black~; height: 14px~;}' skip
    '      tbody td:nth-child(4), tbody td:nth-child(5), tbody td:nth-child(6) ~{text-align: right~; padding-right: 4px~;~}' skip
    '      tfoot td ~{height: 14px~;}' skip
    '      .sumtotal ~{text-align: right~; padding-right: 4px~;~}' skip
    '  </style>' skip
    '</head>' skip
    '<body>' skip
    '<TABLE name="1" fit_to_page="true" orientation="portrait">' skip
    '<thead>' skip
    
    /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
    '  <tr>' skip
    '    <td style="width:  35px;"></td>' skip /* benefits.date_    "Дата","Касса"      "99.99.99" */
    '    <td style="width: 124px;"></td>' skip /* benefits.pay-name "Вид оплаты" "X(41)" */
&if "{1}" = "tot" &then
    '    <td style="width: 31px;"></td>' skip /* benefits.curr-name "Валюта"    "X(19)" */
    '    <td style="width: 71px;"></td>' skip /* benefits.tot-sum   "Сумма!в валюте" "->>>>,>>>,>>>,>>9.99" */
    '    <td style="width: 63px;"></td>' skip /* benefits.tot-base  "Сумма!в Б.Вал."    "->>>>>,>>>,>>9.99" */
    '    <td style="width: 63px;"></td>' skip /* benefits.tot-rubl  "Сумма!в {&abbr_rublyah}" "->>>>,>>>,>>>,>>9.99" */
&elseif "{1}" = "base" &then
    '    <td style="width: 31px;"></td>' skip /* заглушка для выравнивания с benefits.curr-name в &tot */
    '    <td style="width: 71px;"></td>' skip /* benefits.tot-r-b  "Сумма (вал.продаж)" format "->,>>>,>>>,>>>,>>9.99" */
    '    <td style="width: 63px;"></td>' skip /* заглушка для выравнивания с суммами в &tot */
    '    <td style="width: 63px;"></td>' skip /* заглушка для выравнивания с суммами в &tot */
&else
    '    <td style="width: 31px;"></td>' skip /* заглушка для выравнивания с benefits.curr-name в &tot */
    '    <td style="width: 71px;"></td>' skip /* benefits.tot-rubl  like chk-pay.tot-rubl */
    '    <td style="width: 63px;"></td>' skip /* заглушка для выравнивания с суммами в &tot */
    '    <td style="width: 63px;"></td>' skip /* заглушка для выравнивания с суммами в &tot */
&endif
    '    <td style="width: 49px;"></td>' skip /* benefits.pcnt     "% от суммы" format "->>>>9.99%" */
    '    <td style="width: 41px;"></td>' skip /* chk-cnt-all - chk-cnt-nf  "кол-во фискальных чеков" format ">>>>9" */
    '  </tr>' skip


    /* Теперь шапка таблицы */
    '  <tr>' skip
    '    <td colspan="8">' + date_string + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="8">ОТЧЕТ  О  ВЫРУЧКЕ ' + str1
         + '<br />' + str4
         + '<br />( сформирован по ВСЕМ ЧЕКАМ '
         + (IF NotInc then v-vsex-cas + ", включая невошедшие в отчеты о продажах" else v-vsex-cas)
         + ' )'
         + '<br />'
         + substitute("( всего чеков : &1, в среднем &2 &3 / чек )",  ChkAmount,  v-avg-chk,  sale-price-type  )
         + '</td>' skip
    '  </tr>' skip
  .

&if "{2}" = "time" &then
  IF T-time then do:
    put stream OutStr-html unformatted
      '  <tr>' skip
      '    <td colspan="7">Выборочно по времени: '
         + v-times
         + '</td>' skip
      '  </tr>' skip
    .
  end.
&endif

  put stream OutStr-html unformatted
    '</thead>' skip
    
    /* Здесь начинается таблица отчета */
    '<tbody>' skip
    
    /* Первые строки – шапка табоицы с тэгами th */
    '  <tr>' skip
    '    <th>Касса</th>' skip
    '    <th>Вид оплаты</th>' skip
&if "{1}" = "tot" &then
    '    <th>Валюта продаж</th>' skip
    '    <th>Сумма в валюте продаж</th>' skip
    '    <th>Сумма в Б.Вал.</th>' skip
    '    <th>Сумма в {&abbr_rublyah}</th>' skip
&elseif "{1}" = "base" &then
    '    <th></th>' skip
    '    <th>Сумма в ' (if v-curr-r-b = {&r-b-base} then 'Б.Вал.' else '{&abbr_rublyah}') '</th>' skip
    '    <th></th>' skip
    '    <th></th>' skip
&else
    '    <th></th>' skip
    '    <th>Сумма в {&abbr_rublyah}</th>' skip
    '    <th></th>' skip
    '    <th></th>' skip
&endif
    '    <th>~% от суммы</th>' skip
    '    <th>Кол-во фиск. чеков</th>' skip
    '  </tr>' skip    
  .
end . /* end_of prepare_header */

FOR EACH obj-list WHERE
          obj-list.obj-type = {&shop} ,
    EACH all-days_sum WHERE
          all-days_sum.obj-type = obj-list.obj-type AND
          all-days_sum.obj-code = obj-list.obj-code
BREAK
BY obj-list.obj-type
BY obj-list.obj-code :
  ACCUMULATE
  all-days_sum.tot-base ( TOTAL )
  all-days_sum.tot-rubl ( TOTAL )
  all-days_sum.tot-r-b ( TOTAL )
  all-days_sum.chk-cnt-all ( TOTAL )
  all-days_sum.chk-cnt-nf  ( TOTAL )
  obj-list.obj-code ( COUNT ) .
    if first-of( obj-list.obj-code ) then do:
      FIND FIRST clients WHERE
                   clients.obj-type = obj-list.obj-type  AND
                   clients.obj-code = obj-list.obj-code  NO-LOCK no-error .
      put stream OutStr-html unformatted
          '  <tr><td colspan="8">'
          if available clients then clients.obj-name else '<br />'
          '</td></tr>'
      .
    end.
    
  FOR EACH benefits WHERE
              benefits.obj-type = obj-list.obj-type AND
              benefits.obj-code = obj-list.obj-code
  BREAK
  BY benefits.obj-type
  BY benefits.obj-code
  BY benefits.pay-desk
  BY benefits.pay-code
  BY benefits.curr-code :
    if first-of( benefits.pay-desk ) then do:
        FIND FIRST day_sum WHERE
                    day_sum.obj-type = obj-list.obj-type AND
                    day_sum.obj-code = obj-list.obj-code AND
                    day_sum.pay-desk = benefits.pay-desk NO-ERROR.
        DatePrinted = FALSE .
    end.

    /* benefits накапливается повалютно по видам оплаты внутри каждой кассы */
    /* по каждой валюте внутри вида оплаты очередной кассы магазина */
&if "{1}" = "rubl" &then
    benefits.pcnt = round( benefits.tot-rubl / day_sum.tot-rubl * 100 , 2 ) .
&else
    benefits.pcnt = round( benefits.tot-r-b / day_sum.tot-r-b * 100 , 2 ) .
&endif
    if benefits.tot-base  <> 0
    or (day_sum.chk-cnt-all > day_sum.chk-cnt-nf)
    then do:
      if DatePrinted then assign
        v-td-date = '<br />'
      .
      else assign
        v-td-date   = string(benefits.pay-desk)
        DatePrinted = TRUE
      .
      open query qben-chk-count
       preselect each ben-chk-count
                where ben-chk-count.obj-type  = obj-list.obj-type
                  and ben-chk-count.obj-code  = obj-list.obj-code
                  and ben-chk-count.pay-desk  = benefits.pay-desk
                  and ben-chk-count.pay-code  = benefits.pay-code
                  and ben-chk-count.curr-code = benefits.curr-code.
      v-chk-count = query qben-chk-count:num-results .
      close query qben-chk-count.
        
      put stream OutStr-html unformatted
        '  <tr>'
        '<td>' + v-td-date + '</td>'
        '<td>' + benefits.pay-name + '</td>'
&if "{1}" = "tot" &then
        putRowAmount (benefits.curr-name, benefits.tot-sum, benefits.tot-base, benefits.tot-rubl)
&elseif "{1}" = "base" &THEN
        putRowAmount1 ("", benefits.tot-r-b)
&elseif "{1}" = "rubl" &then
        putRowAmount1 ("", benefits.tot-rubl)
&endif
        substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(benefits.pcnt,    "->>9.99",2)  )
        substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  v-chk-count  )
        '</tr>' skip
      .
    end.

    /* по одной кассе */
    if last-of( benefits.pay-desk ) then do:
      if day_sum.chk-cnt-all > day_sum.chk-cnt-nf then do:
        put stream OutStr-html unformatted
&if "{1}" = "tot" &then
          substitute(  '  <td colspan="3">средн.чек: &1</td>',
            ROUND(day_sum.tot-base / (day_sum.chk-cnt-all - day_sum.chk-cnt-nf), 2)  )
          substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(day_sum.tot-base,"->>>>>>>>>>>9.99",2)  )
          '<td></td>'
          substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(day_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
&endif
&if "{1}" = "base" &then
          substitute(  '  <td colspan="3">средн.чек: &1</td>',
            ROUND(day_sum.tot-r-b  / (day_sum.chk-cnt-all - day_sum.chk-cnt-nf) , 2)  )
          substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(day_sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
          '<td></td>'
          '<td></td>'
&endif
&if "{1}" = "rubl" &then
          substitute(  '  <td colspan="3">средн.чек: &1</td>',
            ROUND(day_sum.tot-rubl / (day_sum.chk-cnt-all - day_sum.chk-cnt-nf), 2)  ) 
          substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(day_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
          '<td></td>'
          '<td></td>'
&endif
          '<td>100.00%</td>'
          substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  day_sum.chk-cnt-all - day_sum.chk-cnt-nf  )
          '</tr>' skip
        .     
      end.
    end. /* end_of last-of benefits.pay-desk */
    
    /* по одному магазину: итог по всем кассам за весь период */
    if last-of( benefits.obj-code ) then do:
      put stream OutStr-html unformatted
        '  <tr><td colspan="3">ИТОГО:</td>'
&if "{1}" = "tot" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(all-days_sum.tot-base,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(all-days_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
&elseif "{1}" = "base" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(all-days_sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        '<td></td>'
&elseif "{1}" = "rubl" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(all-days_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        '<td></td>'
&endif
        '<td></td>'
        substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf  )
        '</tr>' skip
      .
    end. /* end_of last-of obj-code */
  END. /* end_of for_each benefits... */

  /* итого по всем магазинам */
  if last( obj-list.obj-code ) AND ( ACCUM COUNT obj-list.obj-code ) > 1 then do:
    put stream OutStr-html unformatted
      '  <tr><td colspan="3">ИТОГО по всем</td>'
&if "{1}" = "tot" &then
      substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL all-days_sum.tot-base,"->>>>>>>>>>>9.99",2)  )
      '<td></td>'
      substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL all-days_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
&elseif "{1}" = "base" &then
      substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL all-days_sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
      '<td></td>'
      '<td></td>'
&elseif "{1}" = "rubl" &then
      substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL all-days_sum.tot-rubl,"->>>>>>>>>>>9.99",2)  )
      '<td></td>'
      '<td></td>'
&endif
      '<td></td>'
      substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',
        (ACCUM TOTAL all-days_sum.chk-cnt-all) - (ACCUM TOTAL all-days_sum.chk-cnt-nf)  )
      '</tr>' skip
    .
  end.
END.    /* FOR EACH obj-list ... */

if  ObjAmount > 1  then do:
  /* FORM with frame ZUM-PayCodes-{1} . */
  FOR EACH benefits
  BREAK
  BY benefits.pay-code :
    ACCUMULATE
    benefits.tot-base ( SUB-TOTAL BY benefits.pay-code )
    benefits.tot-rubl ( SUB-TOTAL BY benefits.pay-code )
    benefits.tot-r-b  ( SUB-TOTAL BY benefits.pay-code )
    .
    if last-of( benefits.pay-code ) AND
        ( ACCUM SUB-TOTAL BY benefits.pay-code benefits.tot-base ) <> 0 then do:
      open query qben-chk-count
       preselect each ben-chk-count
                where ben-chk-count.pay-code  = benefits.pay-code.
      v-chk-count = query qben-chk-count:num-results .
      close query qben-chk-count.
      
      put stream OutStr-html unformatted
        substitute(  '  <tr><td colspan="3">/итого по &1</td>',  benefits.pay-name  ) 
&if "{1}" = "tot" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM SUB-TOTAL BY benefits.pay-code benefits.tot-base,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM SUB-TOTAL BY benefits.pay-code benefits.tot-rubl,"->>>>>>>>>>>9.99",2)  )
&elseif "{1}" = "base" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM SUB-TOTAL BY benefits.pay-code benefits.tot-r-b,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        '<td></td>'
&elseif "{1}" = "rubl" &then
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM SUB-TOTAL BY benefits.pay-code benefits.tot-rubl,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        '<td></td>'
&endif
        '<td></td>'
        substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  v-chk-count  )
        '</tr>' skip
      .
    end.
  END.
end.

put stream OutStr-html unformatted
  '</tbody>' skip
  '<tfoot>' skip
.

if ( ACCUM COUNT obj-list.obj-code ) < 2 then do:
  put stream OutStr-html unformatted
    '  <tr><td colspan="8"><br /></td></tr>' skip
    '  <tr><td colspan="4">Директор _______________</td><td colspan="4">Старший продавец ______________</td></tr>' skip
    '  <tr><td colspan="8"><br /></td></tr>' skip
    '  <tr><td colspan="4">Бухгалтер ______________</td><td colspan="4">Кассир ________________________</td></tr>' skip
  .
end.

put stream OutStr-html unformatted
  '</tfoot>' skip
  '</table>' skip
  '</body>' skip
  '</html>' skip
.
output stream OutStr-html close.     
run prn-lib-reportviewer in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ,input "" 
    ) no-error.
if error-status:error then
do:
    message return-value view-as alert-box.
    return .
end.

/* $Workfile$ e n d */