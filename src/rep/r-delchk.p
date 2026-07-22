block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по удаленным чекам

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10

*/
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter dateTo as date no-undo .
define input parameter dateFrom as date no-undo .
define input parameter onlyDel as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по удаленным чека".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/html-conv.i }
{ gbl/prn-lib.i     }
{ ref/chk-type-desc.i } 
{ gbl/usrfulnf.i }  
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }     
{ rep/errorChk.i }
{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */

define buffer buf_obj-list  for obj-list .
define buffer buf_clients   for ub.clients .
define buffer buf_c-chk-doc for ub.c-chk-doc .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_c-chk-gds for ub.c-chk-gds .
define buffer buf_chk-doc   for ub.chk-doc .
define buffer buf_chk-gds   for ub.chk-gds .
define buffer buf_chk-pay   for ub.c-chk-pay .
 
define variable p-report-id     as character no-undo .
define variable p-log-file-name as character no-undo .
define variable p-batch         as integer   no-undo .
define variable p-codex-id      as integer   no-undo .
define variable p-ruleset-id    as integer   no-undo .
define variable p-plain-txt     as logical   no-undo .
define variable p-xls           as logical   no-undo .
define variable p-dir-name      as character no-undo .
define variable namePay         as character no-undo .
define variable varcurr-name    as character no-undo .

define variable v-nameObj       as character no-undo .
define variable v-nameHost      as character no-undo .
define variable v-period        as character no-undo .
define variable v-delPeriod     as character no-undo .
define variable v-obj-code      as integer   no-undo .
define variable v-obj-type      as character no-undo .
define variable namePNPO        as character no-undo .
define variable nameGoods       as character no-undo .
define variable kk              as integer   no-undo .
define variable jj              as integer   no-undo .
define variable ff              as integer   no-undo .
define variable vv              as integer   no-undo .

define temp-table tt-chk-gds like ub.c-chk-gds 
   field base-sum as decimal.
define temp-table tt-chk-pay like ub.c-chk-pay .
DEFINE NEW SHARED TEMP-TABLE tt-pay-info no-undo
  FIELD line-num      like ub.chk-pay.line-num
  field calc-rate     like ub.curr-shop.exch-rate
  field exch-date     like ub.curr-shop.exch-date
  field exch-time     like ub.curr-shop.exch-time
  field exch-time-str as character
  field exch-rate     like ub.curr-shop.exch-rate
  field exch-scale    like ub.curr-shop.exch-scale
  index pi is unique PRIMARY
  line-num
  .

define stream Out-Stream.
define stream OutStr-html.


FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.

function pr-objname returns character 
  (input p-obj-code as integer ) forward.

define variable v-file-name-rep-htm as character no-undo .

define variable ii                  as integer   no-undo .

if dateFrom = ? and dateTo <> ? then dateFrom = today .
if dateFrom <> ? and dateTo = ? then dateTo = 01/01/1970 .

run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
  
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
{ rep/htmlhead.i }
  .

/*Наименование объекта*/
find first ub.clients no-lock where ub.clients.obj-code = v-cntxt-host-code-obj and ub.clients.obj-type = {&cmp} no-error .
if available (ub.clients) then v-nameHost = ub.clients.obj-name .

for each buf_obj-list where buf_obj-list.obj-type = {&shop} no-lock:
  if not onlyDel then 
  do:
    if x-TOG-Shift = yes then 
    do:
      for each buf_c-chk-doc no-lock 
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.shift-date >= X-date-Start
        and buf_c-chk-doc.shift-date <= x-Date-End
        and buf_c-chk-doc.is-del:       
        if buf_c-chk-doc.shift-date = x-Date-Start and buf_c-chk-doc.shift-num < x-Shift-Start then next .
        if buf_c-chk-doc.shift-date = x-Date-End and buf_c-chk-doc.shift-num > x-Shift-End then next .  
          
        if dateFrom <> ? or dateTo <> ? then 
        do:
          if buf_c-chk-doc.corr-date < dateTo then next .
          if buf_c-chk-doc.corr-date > dateFrom then next . 
        end.
        run tt-tempError .
      end.
    end.
    else 
    do:
      for each buf_c-chk-doc no-lock 
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.chk-date >= x-Date-Start 
        and buf_c-chk-doc.chk-date <= x-Date-End
        and buf_c-chk-doc.is-del:
        if dateFrom <> ? or dateTo <> ? then 
        do:
          if buf_c-chk-doc.corr-date < dateTo then next .
          if buf_c-chk-doc.corr-date > dateFrom then next . 
        end.          
        run tt-tempError .
      end.
    end.
  end.
  else 
  do:
    for each buf_c-chk-doc no-lock 
      where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
      and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
      and buf_c-chk-doc.corr-date >= dateTo 
      and buf_c-chk-doc.corr-date <= dateFrom
      and buf_c-chk-doc.is-del
      :
      run tt-tempError .
    end.
  end.
end.

run pr-header .
run pr-line .
run pr-foot .

procedure tt-tempError:
  define buffer buf_errorChk for tt-errorChk .
  for each tt-errorChk:
    if lookup(tt-errorChk.attr-code,buf_c-chk-doc.office,",") > 0 then 
      tt-errorChk.is-true = true . 
  end.
  for first tt-errorChk where tt-errorChk.attr-code = "0" and tt-errorChk.is-true:
    find first buf_errorChk where buf_errorChk.attr-code = " " no-error .
    buf_errorChk.is-true = true . 
  end.
end procedure .
procedure pr-header:
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
  ff = 0 .
  for each tt-errorChk where tt-errorChk.is-true:
    ff = ff + 1 .
  end.

  if x-TOG-Shift then 
  do:
    v-period = "По сменам: с " + string (x-Date-Start,"99.99.9999") + " "+ string (x-Shift-Start) + " по " + string (x-Date-End,"99.99.9999") + " " + string (x-Shift-End) .
  end.
  else 
  do:
    v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.        
                 
  if dateTo <> ? and dateFrom <> ? then 
  do:
    if dateFrom <> dateTo then 
      v-delPeriod = "Период удаления чека: с " + string(dateTo,"99.99.9999") + " по " + string(dateFrom,"99.99.9999") .
    else 
      v-delPeriod = "Дата удаления чека: " + string(dateTo,"99.99.9999") .
  end.
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">' + string(v-nameHost) + ' </td>' skip
    '<td colspan="15" style="text-align: left; font-weight:bold;">Расшифровка состояний чека на момент удаления</td>' skip
    '</tr>' skip  
    .
  if ff > 0 then 
  do:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="7" style="text-align: left;">дата формирования: ' + string(today,"99.99.99") + ' ' + string(time,"HH:MM") + ' </td>' skip
      '<td colspan="15" style="text-align: left; font-weight:bold;">Состояние чека с ошибкой:</td>' skip
      '</tr>' skip  
      .
  end. 
  else 
  do:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="7" style="text-align: left;">дата формирования: ' + string(today,"99.99.99") + ' ' + string(time,"HH:MM") + ' </td>' skip
      '<td colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
      '</tr>' skip  
      .
  end.       
          
  if ff > 0 then 
  do:
    ii = 0 .
    for each tt-errorChk where tt-errorChk.is-true:  
      ii = ii + 1 .
      if ii = 1 then 
      do:
        if not onlyDel then 
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
        end.
        else 
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip .
        end.
        put stream OutStr-html unformatted
          '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
          '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
          '</tr>' skip  
          .
      end.
      else if ii = 2 then 
        do:
          if v-delPeriod <> "" then 
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
          end.
          else 
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td colspan="7" style="text-align: left;"></td>' skip .
          end.
          put stream OutStr-html unformatted
            '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
            '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
            '</tr>' skip  
            .
        end.
        else 
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip
            '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
            '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
            '</tr>' skip  
            .          
        end.

    end.  /*for each tt-errorChk where tt-errorChk.is-true: */

    if ii = 1 then 
    do:
      if not onlyDel then 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
        '</tr>' skip  
        .
      if v-delPeriod <> "" then 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
        '</tr>' skip  
        .  
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
        '</tr>' skip  
        .  
    end.
    else if ii = 2 then 
      do:
        if v-delPeriod <> "" then 
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
        end.
        else 
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip .
        end.
        put stream OutStr-html unformatted
          '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
          '</tr>' skip  
          .    
        
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip 
          '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
          '</tr>' skip  
          .    
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
          '</tr>' skip  
          .  
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip 
          '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
          '</tr>' skip  
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip 
          '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
          '</tr>' skip  
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
          '</tr>' skip  
          .  
      end. 
  end.
  else 
  do:
    if not onlyDel then 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;"></td>' skip .
    end.
    put stream OutStr-html unformatted
      '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
      '</tr>' skip  
      .
    if v-delPeriod <> "" then 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;"></td>' skip .
    end.
/*    put stream OutStr-html unformatted                                                                                                                                           */
/*      '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу.</td>' skip*/
/*      '</tr>' skip                                                                                                                                                               */
/*      .                                                                                                                                                                          */
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
      '</tr>' skip  
      .  
  end.
  put stream OutStr-html unformatted
    '</thead>' skip .
  
end.

procedure pr-line:
                      
                    
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Смена</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата смены в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Соcтояние на момент удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер чека (Касса)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер чека (ТН)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Создан в ТН</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Время чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Время удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Смена на дату удаления</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Продукт/Товар в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Кол-во</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Цена за ед.</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма по строке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма по чеку</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ФИО Пользователя</TD>' skip
    '</TR>'skip
    .
                            
  for each buf_obj-list where buf_obj-list.obj-type = {&shop} no-lock:

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="22" style="text-align: left; font-weight:bold;">По объекту: ' + string(buf_obj-list.obj-code) + ' ' + pr-objname(buf_obj-list.obj-code) + ' </td>' skip
      '</tr>' skip   
      '</thead>' skip .

    if not onlyDel then 
    do:
      if x-TOG-Shift = yes then 
      do:
        for each buf_c-chk-doc no-lock 
          where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
          and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
          and buf_c-chk-doc.shift-date >= X-date-Start
          and buf_c-chk-doc.shift-date <= x-Date-End
          and buf_c-chk-doc.is-del:       
          if buf_c-chk-doc.shift-date = x-Date-Start and buf_c-chk-doc.shift-num < x-Shift-Start then next .
          if buf_c-chk-doc.shift-date = x-Date-End and buf_c-chk-doc.shift-num > x-Shift-End then next .  
          
          if dateFrom <> ? or dateTo <> ? then 
          do:
            if buf_c-chk-doc.corr-date < dateTo then next .
            if buf_c-chk-doc.corr-date > dateFrom then next . 
          end.
          run primtReport .
        end.
      end.
      else 
      do:
        for each buf_c-chk-doc no-lock 
          where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
          and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
          and buf_c-chk-doc.chk-date >= x-Date-Start 
          and buf_c-chk-doc.chk-date <= x-Date-End
          and buf_c-chk-doc.is-del:
          if dateFrom <> ? or dateTo <> ? then 
          do:
            if buf_c-chk-doc.corr-date < dateTo then next .
            if buf_c-chk-doc.corr-date > dateFrom then next . 
          end.          
          run primtReport .
        end.
      end.
    end.
    else 
    do:
      for each buf_c-chk-doc no-lock 
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code 
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.corr-date >= dateTo 
        and buf_c-chk-doc.corr-date <= dateFrom
        and buf_c-chk-doc.is-del
        :
        run primtReport .
      end.
    end.
  end.
end.
procedure primtReport:
  for first ub.clients no-lock where ub.clients.obj-code = buf_c-chk-doc.obj-code and ub.clients.obj-type = buf_c-chk-doc.obj-type:
    for first buf_clients no-lock where buf_clients.obj-code = ub.clients.host-code and buf_clients.obj-type = {&cmp}:
      namePNPO = buf_clients.obj-name .
    end.
  end.
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + namePNPO + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + ub.clients.obj-name + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.pay-desk) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.shift-num = 0 then "" + '</TD>' else string(buf_c-chk-doc.shift-name) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.src-shift-date <> ? then STRING(buf_c-chk-doc.src-shift-date,"99.99.9999") + '</TD>' else ""  + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + ENTRY(LOOKUP(string(buf_c-chk-doc.chk-type), {&CHK_CODE_LIST}),{&CHK_NAME_LIST}) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.office) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-num) + ":" + string(buf_c-chk-doc.z-number) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.doc-code) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.is-add then "+" + '</TD>' else "-" + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-date,"99.99.9999") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-time,"HH:MM") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-date,"99.99.9999") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-time,"HH:MM") + '</TD>' skip
    .

        vv = 0 .

  for each ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_c-chk-doc.obj-code and ub.shift-obj.obj-type = buf_c-chk-doc.obj-type and 
    ub.shift-obj.status_ <> {&sht-expected} and 
    (ub.shift-obj.open-date < buf_c-chk-doc.corr-date or ub.shift-obj.open-date = buf_c-chk-doc.corr-date) and
    if ub.shift-obj.close-date <> ? then (ub.shift-obj.close-date > buf_c-chk-doc.corr-date or ub.shift-obj.close-date = buf_c-chk-doc.corr-date or ub.shift-obj.status_ = {&sht-current}) 
    else ub.shift-obj.close-date = ?:
      if ub.shift-obj.status_ <> {&sht-current} then do:
      if ub.shift-obj.open-date = buf_c-chk-doc.corr-date and ub.shift-obj.open-time > buf_c-chk-doc.corr-time then next .
      if ub.shift-obj.close-date = buf_c-chk-doc.corr-date and ub.shift-obj.close-time < buf_c-chk-doc.corr-time then next .
      end.
      put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center;">' + string(ub.shift-obj.shift-date,"99.99.9999") + " " + string(ub.shift-obj.shift-name) + '</TD>' skip
        .
      vv = 1 .  
      leave .
  end.
  if vv = 0 then 
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      .
  end.


  ii = 0 .
  kk = 0 .
  jj = 0 .
  namePay = "" .
  empty temp-table tt-chk-pay .
  empty temp-table tt-chk-gds .

  for each buf_c-chk-gds no-lock where buf_c-chk-gds.doc-code = buf_c-chk-doc.doc-code:
    find first tt-chk-gds no-lock where tt-chk-gds.doc-code = buf_c-chk-gds.doc-code and 
      tt-chk-gds.line-num = buf_c-chk-gds.line-num and
      tt-chk-gds.b-code = buf_c-chk-gds.b-code no-error .
    if available (tt-chk-gds) then next .
    kk = kk + 1 .
    create tt-chk-gds .
    buffer-copy buf_c-chk-gds to tt-chk-gds .
    tt-chk-gds.base-sum = GetRoundSumChkDel(tt-chk-gds.doc-code, 
                                            tt-chk-gds.line-num,
                                            tt-chk-gds.chip-num, 
                                            tt-chk-gds.doc-qnty, 
                                            tt-chk-gds.price-base).  
  end .
  for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_c-chk-doc.doc-code:
    find first tt-chk-pay no-lock where tt-chk-pay.doc-code = buf_chk-pay.doc-code and 
      tt-chk-pay.line-num = buf_chk-pay.line-num no-error .
    if available (tt-chk-pay) then next .
    create tt-chk-pay .
    buffer-copy buf_chk-pay to tt-chk-pay .
  end .

  for each tt-chk-pay:
    namePay = namePay + ", " + get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) .
  end.
  namePay = trim (namePay,",") .
  find first tt-chk-gds no-error .
  if available (tt-chk-gds) then 
  do:
    for each tt-chk-gds:
      find first ub.bar-code no-lock where ub.bar-code.b-code = tt-chk-gds.b-code no-error .
      if available (ub.bar-code) then 
      do:
        find first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code no-error .
        if available (ub.goods) then nameGoods = ub.goods.gds-name .
        else nameGoods = "" .
      end.
      else nameGoods = "" .
      if jj = 0 then 
      do:
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + nameGoods + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.base-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base * tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD rowspan = "' string(kk) + '" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_c-chk-doc.tot-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_c-chk-doc.tot-doc,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          .
        put stream OutStr-html unformatted
          '<TD rowspan = "' + string(kk) + '" text_wrap="true" style="text-align: center;">' + namePay + '</TD>' skip
          .
        put stream OutStr-html unformatted
          '<TD rowspan = "' + string(kk) + '" text_wrap="true" style="text-align: center;">' +  usrfulnf(buf_c-chk-doc.corr-user-name) + '</TD>' skip
          '</TR>'skip
          .
        jj = jj + 1.
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" style="text-align: center;">' + namePNPO + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + ub.clients.obj-name + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.pay-desk) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.shift-num = 0 then "" + '</TD>' else string(buf_c-chk-doc.shift-name) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.src-shift-date <> ? then STRING(buf_c-chk-doc.src-shift-date,"99.99.9999") + '</TD>' else ""  + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + ENTRY(LOOKUP(string(buf_c-chk-doc.chk-type), {&CHK_CODE_LIST}),{&CHK_NAME_LIST}) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.office) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-num) + ":" + string(buf_c-chk-doc.z-number) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.doc-code) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.is-add then "+" + '</TD>' else "-" + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-time,"HH:MM") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-time,"HH:MM") + '</TD>' skip
          .

        vv = 0 .

    for each ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_c-chk-doc.obj-code and ub.shift-obj.obj-type = buf_c-chk-doc.obj-type and 
      (ub.shift-obj.open-date < buf_c-chk-doc.corr-date or ub.shift-obj.open-date = buf_c-chk-doc.corr-date) and
      ub.shift-obj.status_ <> {&sht-expected} and
      if ub.shift-obj.close-date <> ? then (ub.shift-obj.close-date > buf_c-chk-doc.corr-date or ub.shift-obj.close-date = buf_c-chk-doc.corr-date) else ub.shift-obj.close-date = ?:
      if ub.shift-obj.open-date = buf_c-chk-doc.corr-date and ub.shift-obj.open-time > buf_c-chk-doc.corr-time then next .
      if ub.shift-obj.close-date = buf_c-chk-doc.corr-date and ub.shift-obj.close-time < buf_c-chk-doc.corr-time then next .

          put stream OutStr-html unformatted
            '<TD text_wrap="true" style="text-align: center;">' + string(ub.shift-obj.shift-date,"99.99.9999") + " " + string(ub.shift-obj.shift-name) + '</TD>' skip
            .
          vv = 1 .  
          leave .
        end.
        if vv = 0 then 
        do:
          put stream OutStr-html unformatted
            '<TD text_wrap="true" style="text-align: center;"></TD>' skip
            .
        end.
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + string(nameGoods) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.base-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base * tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '</TR>'skip
          .
      end. 
    end.
  end.
  else 
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' +  usrfulnf(buf_c-chk-doc.corr-user-name) + '</TD>' skip
      '</TR>'skip
      .
  end.
end.


put stream OutStr-html unformatted
  '</tbody>' skip .
  
  
procedure pr-foot:        
  put stream OutStr-html unformatted
  
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
end.  
                            
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
  if avail loc_cash-pay then 
  do:
    varpay-name = loc_cash-pay.obj-name.
  end.
  else 
  do:
    if buf_c-chk-doc.chk-type = integer({&rcpt-z-rep})
      and parpay-code = 0
      and parcurr-code = 0 then 
    do:
      varpay-name = "Неизвестная оплата".
    end.
  end.
END PROCEDURE.

PROCEDURE get-report-num :

   define output parameter p-report-num as integer no-undo .

   do
      on error undo, return error return-value
      :
      run gbl/getrpnum.p (output p-report-num).
   end.

END PROCEDURE.

FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define variable varpay-name like ub.cash-pay.obj-name no-undo.

  run get-pay-proc in this-procedure (
    input  parpay-code
    ,input  parcurr-code
    ,output parcurr-name
    ,output varpay-name ).
  return varpay-name.

END FUNCTION.
        
FUNCTION pr-objname RETURNS character
  ( INPUT p-obj-code AS integer) :

  define variable v-obj-name as character no-undo .

  find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = {&shop} no-error .
  if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
 
  RETURN v-obj-name.

END FUNCTION.
        