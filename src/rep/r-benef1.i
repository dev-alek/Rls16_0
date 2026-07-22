/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать отчета о выручке по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/06
Author: Bakhtadze Natalya
Creation date: 01/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }
{ gbl/prn-lib.i   }
{ rep/html-conv.i }

&global-define  no-benefits    "Не было никакой выручки на выбранных объектах ~
в течение заданного Вами периода времени."


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
function putRowDayTotal1 returns character private
(input p-numchk-fisc as integer
,input p-total1    as decimal
) :
define variable v-day-amount as character no-undo .

  v-day-amount = substitute (
    '<td colspan="3">средн.чек: &1</td><td num="0.00" val="&2" class="sumtotal">&2</td><td><br /></td><td><br /></td>'
    , ROUND(p-total1 / p-numchk-fisc, 2)
    , fnc-convert-dot-to-colon(p-total1, "->>>>>>>>>>>9.99", 2)
  ) .

  return v-day-amount .
end function . /* end_of putRowDayTotal1 */  
/* ----------------------------------------------------------------------*/
function putRowDayTotal returns character private
(input p-numchk-fisc as integer
,input p-total1    as decimal
,input p-total2    as decimal
) :
define variable v-day-amount as character no-undo .

  v-day-amount = substitute (
    '<td colspan="3">средн.чек: &1</td><td num="0.00" val="&2" class="sumtotal">&2</td><td><br /></td><td num="0.00" val="&3" class="sumtotal">&3</td>'
    , ROUND(p-total1 / p-numchk-fisc, 2)
    , fnc-convert-dot-to-colon(p-total1, "->>>>>>>>>>>9.99", 2)
    , fnc-convert-dot-to-colon(p-total2, "->>>>>>>>>>>9.99", 2)  
  ) .

  return v-day-amount .
end function . /* end_of putRowDayTotal */  
/* ----------------------------------------------------------------------*/

define VARIABLE v-report-id         as integer   no-undo .
define variable v-report-name       as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define stream OutStr-html.

define variable v-vsex-cas  as character no-undo.
define variable v-avg-chk   as decimal decimals  2 no-undo .
define variable v-times     as character no-undo.
define variable v-td-date   as character no-undo.
define variable v-pcnt      as decimal decimals  2 no-undo .
define variable v-accum     as decimal no-undo .
define variable v-accum-b   as decimal no-undo .
define variable v-accum-r   as decimal no-undo .
define variable v-accum-t   as decimal no-undo .
define variable v-accum-s   as decimal no-undo .
define variable v-chk-count as integer no-undo .
define variable v-err-message as character no-undo .
define query qben-chk-count for ben-chk-count .


empty temp-table benefits .
empty temp-table inkas-num .
empty temp-table day_sum .
empty temp-table all-days_sum .
empty temp-table ben-chk-count .


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

/* 30/IV-2019 сообщение об отсутствии выручки выводится по отсутствию записей в benefits
run no-benq(output found).
if not found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box information .
  return.
end.
*/
run no-benqi(output NotInc).
&if "{2}" = "time" &then
  run rep/r-bennq1.p (
                 input parparentproc
                ,input cas-num
                ,input T-time
                ,input v-curr-r-b
                ,output allday-basesum
                ,output allday-Rublsum
                ,output ObjAmount
                ,output ChkAmount
                ) no-error.
&else
  run rep/r-beneq1.p (
                 input parparentproc
                ,input cas-num
                ,input no
                ,input v-curr-r-b
                ,output allday-basesum
                ,output allday-Rublsum
                ,output ObjAmount
                ,output ChkAmount
                ) no-error.
&endif
  if error-status:error then do :
    v-err-message = substitute("Ошибка формирования отчёта&1&2&1&3&1всего ошибок &4",
                               {&new-line}, return-value, error-status:get-message(1), error-status:num-messages) .
    message v-err-message view-as alert-box.
    return error return-value.
  end .

if not can-find (first benefits) then do:
  message {&no-benefits} view-as alert-box information .
  return.
end.


if x-date-start = x-date-end
then choice = TRUE .
else choice = HowBreak .

    run prn-lib-get-report-name  in this-procedure (
                                                       input parParentProc
                                                      ,output v-report-name
                                                    ).
  assign
    v-file-name-rep-htm = v-report-name + ".html"
    date_string = cur-time-print()
    v-vsex-cas = IF cas-num = 0 then "ВСЕХ КАСС" ELSE ("КАССЫ " + string(cas-num))
    v-avg-chk  = if ChkAmount > 0 then round(                  
&if "{1}" = "rubl" &then 
 AllDay-RublSum / ChkAmount 
&else
 AllDay-BaseSum / ChkAmount 
&endif
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
    '  <tr class="set_columns">' skip
    '    <td style="width:  53px;"></td>' skip /* benefits.date_    "Дата "      "99.99.99" */
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
    '    <td style="width: 49px;"></td>' skip /* benefits.pcnt             "% от суммы" format "->>>>9.99%" */
    '    <td style="width: 41px;"></td>' skip /* chk-cnt-all - chk-cnt-nf  "кол-во фискальных чеков" format ">>>>9" */
    '  </tr>' skip

    /* Теперь шапка таблицы */
    '  <tr>' skip
    '    <td colspan="8">' + date_string + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="8">ОТЧЕТ  О  ВЫРУЧКЕ  ' + str1
         + '<br />' + str4
         + '<br />( сформирован по ВСЕМ ЧЕКАМ '
         + (IF NotInc then v-vsex-cas + ", включая невошедшие в отчеты о продажах" else v-vsex-cas )
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
      '    <td colspan="8">Выборочно по времени: '
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
    '    <th>Дата</th>' skip
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

/* define buffer t-benefits for benefits. 30/IV-2019 не используется */
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
  all-days_sum.tot-r-b  ( TOTAL )
  all-days_sum.chk-cnt-all ( TOTAL )
  all-days_sum.chk-cnt-nf  ( TOTAL )
  obj-list.obj-code ( COUNT ) .

    run waitfram-show in this-procedure ( obj-list.obj-type + string( obj-list.obj-code ) +
                                  ", компоновка отчёта " ) .
  
    FIND FIRST clients no-lock
         WHERE clients.obj-type = obj-list.obj-type
           AND clients.obj-code = obj-list.obj-code no-error .
    put stream OutStr-html unformatted
      '  <tr><td colspan="8">'
      if available clients then clients.obj-name else '<br />'
      '</td></tr>' skip
    .
  
  if choice then do:
    FOR EACH benefits WHERE
              benefits.obj-type = obj-list.obj-type AND
              benefits.obj-code = obj-list.obj-code
    BREAK
    BY benefits.obj-type
    BY benefits.obj-code
    BY benefits.date_
    BY benefits.pay-code
    BY benefits.curr-code :
      if first-of( benefits.date_ ) then do:
        /*
        doprubl = 0.
        for each t-benefits No-LOCK where
                t-benefits.obj-type = obj-list.obj-type AND
                t-benefits.obj-code = obj-list.obj-code AND
                t-benefits.date_ = benefits.date_:
            doprubl = doprubl +  t-benefits.tot-rubl.
        END.
        */
        FIND FIRST day_sum WHERE
                  day_sum.obj-type = obj-list.obj-type AND
                  day_sum.obj-code = obj-list.obj-code AND
                  day_sum.date_ = benefits.date_   NO-ERROR.
          /*        day_sum.tot-rubl  = doprubl. */
        DatePrinted = FALSE .
      end. /*if first-of( benefits.date_ ) */
&if "{1}" = "rubl" &then
      benefits.pcnt = round( benefits.tot-r-b / day_sum.tot-r-b * 100 , 2 ) .
&else
      benefits.pcnt = round( benefits.tot-rubl / day_sum.tot-rubl * 100 , 2 ) .
&endif

      if benefits.tot-base <> 0 or day_sum.chk-cnt-all > 0 or day_sum.chk-cnt-nf > 0
      then do:
        if DatePrinted then assign
          v-td-date = '<br />'
        .
        else assign
          v-td-date   = string(benefits.date_)
          DatePrinted = TRUE
        .
        open query qben-chk-count
         preselect each ben-chk-count
                  where ben-chk-count.date_     = benefits.date_
                    and ben-chk-count.pay-code  = benefits.pay-code
                    and ben-chk-count.obj-code  = obj-list.obj-code
                    and ben-chk-count.obj-type  = obj-list.obj-type
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
      
      if last-of( benefits.date_ ) then  do:
        if day_sum.chk-cnt-all > day_sum.chk-cnt-nf then do:
          put stream OutStr-html unformatted
            '  <tr>'
&if "{1}" = "tot" &then
            putRowDayTotal  ( day_sum.chk-cnt-all - day_sum.chk-cnt-nf, day_sum.tot-base, day_sum.tot-rubl )   
&elseif "{1}" = "base" &then
            putRowDayTotal1 ( day_sum.chk-cnt-all - day_sum.chk-cnt-nf, day_sum.tot-r-b )   
&elseif "{1}" = "rubl" &then
            putRowDayTotal1 ( day_sum.chk-cnt-all - day_sum.chk-cnt-nf, day_sum.tot-rubl )   
&endif
            '<td>100.00%</td>'
            substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  day_sum.chk-cnt-all - day_sum.chk-cnt-nf  )
            '</tr>' skip
          .
        end.

      end. /* end_of last_of benefits.date_ */
      if last-of (benefits.obj-code) then do:
        put stream OutStr-html unformatted
            '<tr><td colspan="3">ИТОГО:</td>' 
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
            '<td>100.00%</td>'
            substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf  )
            '</tr>' skip
        .
      end.
    END. /* end_of for_each benefits */
  end.
  else do: /*сводный за период */
    FOR EACH benefits WHERE
             benefits.obj-type = obj-list.obj-type AND
             benefits.obj-code = obj-list.obj-code
    BREAK
    BY benefits.obj-type
    BY benefits.obj-code
    BY benefits.pay-code
    BY benefits.curr-code :
      ACCUMULATE
        benefits.tot-base ( TOTAL )
        benefits.tot-rubl ( TOTAL )
        benefits.tot-r-b ( TOTAL )
        benefits.tot-sum ( SUB-TOTAL BY benefits.curr-code )
        benefits.tot-base ( SUB-TOTAL BY benefits.curr-code )
        benefits.tot-rubl ( SUB-TOTAL BY benefits.curr-code )
        benefits.tot-r-b ( SUB-TOTAL BY benefits.curr-code )
      .
      if first-of( benefits.curr-code ) then do:
        v-accum-b = 0 .
        v-accum-t = 0 .
        define buffer buf_benefits for benefits .
        for each buf_benefits where buf_benefits.obj-type  = benefits.obj-type
                                and buf_benefits.obj-code  = benefits.obj-code
                                and buf_benefits.pay-code  = benefits.pay-code
                                and buf_benefits.curr-code = benefits.curr-code :
          v-accum-b = v-accum-b + buf_benefits.tot-base .
          v-accum-t = v-accum-t + buf_benefits.tot-r-b .
        end .
      end. /*if first-of( benefits.date_ ) */

      if last-of( benefits.curr-code ) then do:
        define variable v-if-accum as decimal no-undo .
        &if "{1}" = "tot" &then
          v-if-accum = v-accum-b .
        &else
          v-if-accum = v-accum-t .
        &endif
        if v-if-accum <> 0 then do :

        open query qben-chk-count
         preselect each ben-chk-count
                  where ben-chk-count.obj-type  = obj-list.obj-type
                    and ben-chk-count.obj-code  = obj-list.obj-code
                    and ben-chk-count.pay-code  = benefits.pay-code
                    and ben-chk-count.curr-code = benefits.curr-code.
        v-chk-count = query qben-chk-count:num-results .
        close query qben-chk-count.
        
        put stream OutStr-html unformatted
          '  <tr>'
              '<td></td>'
              '<td>' + benefits.pay-name + '</td>'
        .
&if "{1}" = "tot" &then
          v-accum-s = ACCUM SUB-TOTAL BY benefits.curr-code benefits.tot-sum .
          v-accum-r = ACCUM SUB-TOTAL BY benefits.curr-code benefits.tot-rubl .
          v-pcnt = round(  v-accum-b  /  all-days_sum.tot-base  *  100  ,  2  ) . 
        put stream OutStr-html unformatted
          putRowAmount (benefits.curr-name, v-accum-s, v-accum-b, v-accum-r)
        .
&else
  &if "{1}" = "base" &then
        v-pcnt = round(  v-accum-t  /  all-days_sum.tot-r-b  *  100   , 2 ) .
        v-accum = v-accum-t .
  &endif
  &if "{1}" = "rubl" &then
        v-accum-r = ACCUM SUB-TOTAL BY benefits.CURR-code benefits.tot-rubl .
        v-pcnt = round(  v-accum-r  /  all-days_sum.tot-rubl  *  100    , 2 ) .
        v-accum = v-accum-r .
  &endif
        put stream OutStr-html unformatted
          putRowAmount1 ("", v-accum)
        .
&endif
          put stream OutStr-html unformatted
            substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(v-pcnt,"->>9.99",2)  )
            substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  v-chk-count  )
            '</tr>' skip
          .
        end.
      end. /* end_of last_of curr-code */
      
      if last-of (benefits.obj-code) then do:
        put stream OutStr-html unformatted
            '  <tr><td colspan="3">ИТОГО:</td>' 
&if "{1}" = "tot" &then
            substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL benefits.tot-base,"->>>>>>>>>>>9.99",2)  )
            '<td></td>'
            substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL benefits.tot-rubl,"->>>>>>>>>>>9.99",2)  )
&elseif "{1}" = "base" &then
            substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL benefits.tot-r-b,"->>>>>>>>>>>9.99",2)  )
            '<td></td>'
            '<td></td>'
&elseif "{1}" = "rubl" &then
            substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL benefits.tot-rubl,"->>>>>>>>>>>9.99",2)  )
            '<td></td>'
            '<td></td>'
&endif
            '<td>100.00%</td>'
            substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf  )
            '</tr>' skip
        .
      end.
    END. /* end_of for_each benefits */
    
  end. /* end_of choice сводный за период */
  

  if last( obj-list.obj-code ) AND ( ACCUM COUNT obj-list.obj-code ) > 1 then  do:
    put stream OutStr-html unformatted
      '<tr><td colspan="3">ИТОГО по всем</td>' + 
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


if choice AND ( ObjAmount > 1 ) then do:
  /* FORM with frame ZUM-PayCodes-{1}. */
  FOR EACH benefits
  BREAK
  BY benefits.pay-code :
    ACCUMULATE
/*    benefits.tot-sum ( SUB-TOTAL BY benefits.pay-code ) */
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